import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:forms/forms.dart';
import 'package:test/test.dart';

void main() {
  test('zip files read back, with little-endian records', () {
    final bytes = zipFiles({
      'a.csv': utf8.encode('﻿x,y\r\n1,2\r\n'),
      'Ünï.txt': utf8.encode('hello'),
    });
    final view = ByteData.sublistView(bytes);
    expect(view.getUint32(0, Endian.little), 0x04034b50);
    expect(
      view.getUint32(bytes.length - 22, Endian.little),
      0x06054b50,
      reason: 'end of central directory where zip tools look for it',
    );
    final a = ZipDecoder().decodeBytes(bytes, verify: true);
    expect([for (final f in a.files) f.name], ['a.csv', 'Ünï.txt']);
    expect(utf8.decode(a.findFile('Ünï.txt')!.content), 'hello');
  });

  test('an .xlsx file reads back', () {
    final x = writeXlsx({
      'Records': [
        ['number', 'age', 'name'],
        ['HH-001', 34, 'Akello & "Sons" <x>'],
        ['HH-002', 2.5, 'line\nbreak'],
      ],
      'Members': [
        ['a'],
        [1],
      ],
    });
    final back = readXlsx(x);
    expect(back.keys, ['Records', 'Members']);
    expect(back['Records']![1], ['HH-001', '34', 'Akello & "Sons" <x>']);
  });
}
