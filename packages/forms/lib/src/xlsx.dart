import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'zip.dart';

/// A small Excel (.xlsx) writer and reader: plain text and number cells in
/// named sheets, enough for exports and XLSForm. Plain style, no formulas.

String _column(int i) {
  var n = i + 1;
  final b = StringBuffer();
  while (n > 0) {
    final r = (n - 1) % 26;
    b.write(String.fromCharCode(65 + r));
    n = (n - 1) ~/ 26;
  }
  return b.toString().split('').reversed.join();
}

String _escape(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    // Control characters other than tab and line breaks are not allowed.
    .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');

/// Sheet names: at most 31 characters, none of []:*?/\ , unique.
List<String> _sheetNames(Iterable<String> names) {
  final used = <String>{};
  return [
    for (final n in names)
      () {
        var base = n.replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ').trim();
        if (base.isEmpty) base = 'Sheet';
        if (base.length > 31) base = base.substring(0, 31);
        var name = base;
        for (var i = 2; !used.add(name.toLowerCase()); i++) {
          final tail = ' ($i)';
          name =
              '${base.substring(0, (31 - tail.length).clamp(0, base.length))}$tail';
        }
        return name;
      }(),
  ];
}

/// An .xlsx file with one sheet per entry: a list of rows of cells (text,
/// numbers, booleans as text, null as empty).
Uint8List writeXlsx(Map<String, List<List<Object?>>> sheets) {
  final names = _sheetNames(sheets.keys);
  final a = <String, List<int>>{};
  void add(String path, String content) => a[path] = utf8.encode(content);

  const xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';
  add(
    '[Content_Types].xml',
    '$xml<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
        '${[for (var i = 1; i <= names.length; i++) '<Override PartName="/xl/worksheets/sheet$i.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'].join()}'
        '</Types>',
  );
  add(
    '_rels/.rels',
    '$xml<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        '</Relationships>',
  );
  add(
    'xl/workbook.xml',
    '$xml<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>'
        '${[for (var i = 0; i < names.length; i++) '<sheet name="${_escape(names[i])}" sheetId="${i + 1}" r:id="rId${i + 1}"/>'].join()}'
        '</sheets></workbook>',
  );
  add(
    'xl/_rels/workbook.xml.rels',
    '$xml<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '${[for (var i = 1; i <= names.length; i++) '<Relationship Id="rId$i" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet$i.xml"/>'].join()}'
        '<Relationship Id="rId${names.length + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        '</Relationships>',
  );
  // The least Excel expects: one font, fill, border and cell format.
  add(
    'xl/styles.xml',
    '$xml<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<fonts count="1"><font><sz val="11"/><name val="Calibri"/></font></fonts>'
        '<fills count="2"><fill><patternFill patternType="none"/></fill>'
        '<fill><patternFill patternType="gray125"/></fill></fills>'
        '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
        '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
        '<cellXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/></cellXfs>'
        '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
        '</styleSheet>',
  );
  var i = 0;
  for (final rows in sheets.values) {
    i++;
    final b = StringBuffer(
      '$xml<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
      '<sheetData>',
    );
    for (var r = 0; r < rows.length; r++) {
      b.write('<row r="${r + 1}">');
      for (var c = 0; c < rows[r].length; c++) {
        final v = rows[r][c];
        if (v == null || (v is String && v.isEmpty)) continue;
        final ref = '${_column(c)}${r + 1}';
        if (v is num && v.isFinite) {
          b.write('<c r="$ref"><v>$v</v></c>');
        } else {
          b.write(
            '<c r="$ref" t="inlineStr"><is><t xml:space="preserve">'
            '${_escape('$v')}</t></is></c>',
          );
        }
      }
      b.write('</row>');
    }
    b.write('</sheetData></worksheet>');
    add('xl/worksheets/sheet$i.xml', b.toString());
  }
  return zipFiles(a);
}

/// Reads an .xlsx file: each sheet's rows, by sheet name, as text (numbers
/// as written, e.g. "3" or "2.5"). Empty cells are empty strings.
Map<String, List<List<String>>> readXlsx(List<int> bytes) {
  final a = ZipDecoder().decodeBytes(bytes);
  String? text(String path) {
    final f = a.findFile(path);
    return f == null ? null : utf8.decode(f.content);
  }

  final shared = <String>[];
  final sst = text('xl/sharedStrings.xml');
  if (sst != null) {
    for (final si in XmlDocument.parse(sst).findAllElements('si')) {
      shared.add(si.findAllElements('t').map((t) => t.innerText).join());
    }
  }
  final rels = <String, String>{};
  final relXml = text('xl/_rels/workbook.xml.rels');
  if (relXml != null) {
    for (final r in XmlDocument.parse(relXml).findAllElements('Relationship')) {
      final target = r.getAttribute('Target') ?? '';
      rels[r.getAttribute('Id') ?? ''] = target.startsWith('/')
          ? target.substring(1)
          : 'xl/$target';
    }
  }
  final workbook = text('xl/workbook.xml');
  if (workbook == null) throw const FormatException('not an Excel file');
  final out = <String, List<List<String>>>{};
  for (final s in XmlDocument.parse(workbook).findAllElements('sheet')) {
    final id = s.attributes
        .where((x) => x.name.local == 'id')
        .map((x) => x.value)
        .firstOrNull;
    final sheet = text(rels[id] ?? '');
    if (sheet == null) continue;
    final rows = <List<String>>[];
    for (final row in XmlDocument.parse(sheet).findAllElements('row')) {
      final r = int.tryParse(row.getAttribute('r') ?? '') ?? rows.length + 1;
      while (rows.length < r - 1) {
        rows.add([]);
      }
      final cells = <String>[];
      for (final c in row.findElements('c')) {
        final ref = c.getAttribute('r') ?? '';
        final letters = RegExp('^[A-Z]+').stringMatch(ref) ?? '';
        var col = cells.length;
        if (letters.isNotEmpty) {
          col = 0;
          for (final ch in letters.codeUnits) {
            col = col * 26 + (ch - 64);
          }
          col -= 1;
        }
        final type = c.getAttribute('t');
        final v = c.getElement('v')?.innerText ?? '';
        final value = switch (type) {
          's' => shared.elementAtOrNull(int.tryParse(v) ?? -1) ?? '',
          'inlineStr' => c.findAllElements('t').map((t) => t.innerText).join(),
          'b' => v == '1' ? 'TRUE' : 'FALSE',
          _ => v,
        };
        while (cells.length < col) {
          cells.add('');
        }
        if (cells.length == col) {
          cells.add(value);
        } else {
          cells[col] = value;
        }
      }
      rows.add(cells);
    }
    out[s.getAttribute('name') ?? 'Sheet${out.length + 1}'] = rows;
  }
  return out;
}
