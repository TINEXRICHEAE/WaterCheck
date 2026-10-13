import 'package:flutter/material.dart';

import '../l10n/ui_kit_localizations.dart';

/// A search box with a clear (×) button. [value] keeps it in step when the
/// search is cleared elsewhere (for example "Reset filters").
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _c = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(SearchField old) {
    super.didUpdateWidget(old);
    if (widget.value != _c.text) _c.text = widget.value;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: _c,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      labelText: widget.label,
      border: const OutlineInputBorder(),
      isDense: true,
      suffixIcon: _c.text.isEmpty
          ? null
          : IconButton(
              tooltip: UiKitLocalizations.of(context).searchClear,
              icon: const Icon(Icons.clear),
              onPressed: () {
                _c.clear();
                widget.onChanged('');
                setState(() {});
              },
            ),
    ),
    onChanged: (v) {
      widget.onChanged(v);
      setState(() {});
    },
  );
}
