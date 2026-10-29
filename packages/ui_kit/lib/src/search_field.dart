import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// Where recent searches are kept. Each app points this at its own local
/// storage at start-up; until then they last for the session only.
abstract interface class SearchHistoryStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class _MemoryStore implements SearchHistoryStore {
  final _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}

class _FunctionStore implements SearchHistoryStore {
  _FunctionStore(this._read, this._write);

  final Future<String?> Function(String key) _read;
  final Future<void> Function(String key, String value) _write;

  @override
  Future<String?> read(String key) => _read(key);

  @override
  Future<void> write(String key, String value) => _write(key, value);
}

/// Recent searches per list, newest first, like other apps keep them
/// (2026-10-27). Lists also add the item a person opened from a search,
/// so it is one tap away next time.
abstract final class SearchHistory {
  static SearchHistoryStore store = _MemoryStore();

  /// Keeps recent searches in the app's own local settings.
  static void use({
    required Future<String?> Function(String key) read,
    required Future<void> Function(String key, String value) write,
  }) => store = _FunctionStore(read, write);

  /// How many terms are kept per list.
  static const keep = 8;

  static String _key(String list) => 'search.$list';

  static Future<List<String>> recent(String list) async {
    try {
      final raw = await store.read(_key(list));
      if (raw == null) return const [];
      return [for (final t in jsonDecode(raw) as List) t as String];
    } catch (_) {
      return const [];
    }
  }

  /// Puts [term] first in [list]'s recent searches.
  static Future<void> add(String list, String term) async {
    final t = term.trim();
    if (t.length < 2) return;
    final now = [
      t,
      for (final r in await recent(list))
        if (r.toLowerCase() != t.toLowerCase()) r,
    ].take(keep).toList();
    await store.write(_key(list), jsonEncode(now));
  }

  static String _itemsKey(String list) => 'search.$list.items';

  /// Things opened from a search (a place on a map), newest first.
  static Future<List<Map<String, Object?>>> recentItems(String list) async {
    try {
      final raw = await store.read(_itemsKey(list));
      if (raw == null) return const [];
      return [
        for (final t in jsonDecode(raw) as List)
          (t as Map).cast<String, Object?>(),
      ];
    } catch (_) {
      return const [];
    }
  }

  static Future<void> addItem(
    String list,
    String id,
    Map<String, Object?> item,
  ) async {
    final now = [
      {...item, 'id': id},
      for (final r in await recentItems(list))
        if (r['id'] != id) r,
    ].take(keep).toList();
    await store.write(_itemsKey(list), jsonEncode(now));
  }

  static Future<void> remove(String list, String term) async {
    final now = [
      for (final r in await recent(list))
        if (r != term) r,
    ];
    await store.write(_key(list), jsonEncode(now));
  }
}

/// A search box with a clear (×) button. [value] keeps it in step when the
/// search is cleared elsewhere (for example "Reset filters"). With
/// [history], recent searches for that list show under the box while it
/// is focused; one tap searches again.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.history,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;

  /// The list's name for its recent searches, such as 'console.devices'.
  final String? history;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _c = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  var _recent = const <String>[];
  Timer? _settle;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
    _load();
  }

  Future<void> _load() async {
    final list = widget.history;
    if (list == null) return;
    final r = await SearchHistory.recent(list);
    if (mounted) setState(() => _recent = r);
  }

  void _onFocus() {
    if (_focus.hasFocus) {
      _load();
    } else {
      _remember();
    }
    setState(() {});
  }

  Future<void> _remember() async {
    _settle?.cancel();
    final list = widget.history;
    if (list == null || _c.text.trim().length < 2) return;
    await SearchHistory.add(list, _c.text);
    await _load();
  }

  void _search(String v) {
    if (_c.text != v) {
      _c.value = TextEditingValue(
        text: v,
        selection: TextSelection.collapsed(offset: v.length),
      );
    }
    widget.onChanged(v);
    setState(() {});
    // A search left in place for a moment counts as made.
    _settle?.cancel();
    if (widget.history != null) {
      _settle = Timer(const Duration(seconds: 2), _remember);
    }
  }

  @override
  void didUpdateWidget(SearchField old) {
    super.didUpdateWidget(old);
    if (widget.value != _c.text) _c.text = widget.value;
  }

  @override
  void dispose() {
    _settle?.cancel();
    _focus.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = UiKitLocalizations.of(context);
    final shown = [
      for (final r in _recent)
        if (r.toLowerCase().contains(_c.text.trim().toLowerCase()) &&
            r != _c.text.trim())
          r,
    ];
    final box = TextField(
      controller: _c,
      focusNode: _focus,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: _c.text.isEmpty
            ? null
            : IconButton(
                tooltip: l10n.searchClear,
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _settle?.cancel();
                  _search('');
                  _settle?.cancel();
                },
              ),
      ),
      onChanged: _search,
      onSubmitted: (_) => _remember(),
    );
    if (widget.history == null || !_focus.hasFocus || shown.isEmpty) {
      return box;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.searchRecent,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              for (final r in shown.take(SearchHistory.keep))
                InputChip(
                  avatar: const Icon(Icons.history, size: 18),
                  label: Text(r),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    _search(r);
                    _remember();
                  },
                  deleteButtonTooltipMessage: l10n.searchForget,
                  onDeleted: () async {
                    await SearchHistory.remove(widget.history!, r);
                    await _load();
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Holds a search for a list built elsewhere (2026-10-27): [builder] gets
/// the search box to place and a test for each row's words.
class SearchBuilder extends StatefulWidget {
  const SearchBuilder({
    super.key,
    required this.label,
    required this.history,
    required this.builder,
  });

  final String label;
  final String history;
  final Widget Function(
    BuildContext context,
    Widget field,
    bool Function(Iterable<String?> words) matches,
  )
  builder;

  @override
  State<SearchBuilder> createState() => _SearchBuilderState();
}

class _SearchBuilderState extends State<SearchBuilder> {
  var _query = '';

  bool _matches(Iterable<String?> words) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final all = words.whereType<String>().join(' ').toLowerCase();
    return q.split(RegExp(r'\s+')).every(all.contains);
  }

  @override
  Widget build(BuildContext context) => SearchQuery(
    query: _query,
    child: Builder(
      builder: (context) => widget.builder(
        context,
        SearchField(
          value: _query,
          label: widget.label,
          history: widget.history,
          onChanged: (v) => setState(() => _query = v),
        ),
        _matches,
      ),
    ),
  );
}

/// The search a [SearchBuilder] holds, for parts of its page that search
/// on their own (people to write to), so one box searches the whole page.
class SearchQuery extends InheritedWidget {
  const SearchQuery({super.key, required this.query, required super.child});

  final String query;

  static String? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SearchQuery>()?.query;

  @override
  bool updateShouldNotify(SearchQuery old) => old.query != query;
}
