import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef TextChangeCallback = void Function(String);

class SearchWidget extends StatelessWidget {
  SearchWidget({this.onTextChange}) {
    _searchController.addListener(() => _inputTextChanged());
  }
  final TextChangeCallback onTextChange;

  final TextEditingController _searchController = new TextEditingController();
  final ValueNotifier<String> _text = new ValueNotifier<String>("");
  final ValueNotifier<bool> _isSearch = ValueNotifier<bool>(true);

  void _searchInputUpdated() {
    if ((_searchController.text.isEmpty || _searchController.text.length > 2) &&
        _searchController.text != _text.value &&
        onTextChange != null) {
      _text.value = _searchController.text;
      onTextChange(_searchController.text);
    }
  }

  void _inputTextChanged() {
    _isSearch.value =
        _searchController.text.isEmpty || _searchController.text != _text.value;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).primaryTextTheme.headline6,
      controller: _searchController,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Buscar...',
          suffix: ValueListenableBuilder(
            builder: (context, isSearch, child) {
              if (isSearch) {
                return GestureDetector(
                    child: Icon(Icons.search),
                    onTap: () => _searchInputUpdated());
              } else {
                return GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () {
                      _searchController.text = "";
                      _searchInputUpdated();
                    });
              }
            },
            valueListenable: _isSearch,
          )),
      onSubmitted: (value) => _searchInputUpdated(),
      onChanged: (value) => _inputTextChanged(),
    );
  }
}
