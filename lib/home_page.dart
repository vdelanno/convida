import 'package:convida/markdown_view.dart';
import 'package:convida/search_widget.dart';
import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'home_layout.dart';
import 'model.dart';
import 'markdown_scrollbar.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key, this.fullText})
      : model = Model(text: fullText),
        super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String fullText;
  final Model model;
  final ValueNotifier<int> searchIndex = ValueNotifier<int>(-1);
  final ScrollController _scrollController = ScrollController();

  String markdownSearch(String text, String substr) {
    return text.replaceAllMapped(new RegExp('($substr)', caseSensitive: false),
        (Match m) => "^^${m[1]}^^");
  }

  Widget buildMainView(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      constraints: BoxConstraints(minWidth: 300, maxWidth: 800),
      padding: EdgeInsets.fromLTRB(5, 0, 0, 10),
      child: MarkdownScrollBar(
        model: model,
        thickness: 30,
        controller: _scrollController,
        child: ValueListenableBuilder(
            valueListenable: model.text,
            builder: (context, value, child) {
              return ListView(children: [
                MarkdownView(model: model),
              ], controller: _scrollController);
            }),
      ),
    );
  }

  Widget buildDrawer(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: model.anchors,
        builder: (context, value, child) {
          if (value == null) {
            return Container();
          }
          List<Anchor> headers = value[AnchorType.HEADER] as List<Anchor>;
          if (headers == null) headers = [];
          List<Widget> children = <Widget>[
                AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(SitLocalizations.of(context).sideMenuHeader,
                      style: Theme.of(context).textTheme.headline5),
                  // padding: EdgeInsets.all(1.0),
                  // margin: EdgeInsets.only(bottom: 1.0)
                ),
                AppBar(
                    automaticallyImplyLeading: false,
                    title: SearchWidget(
                        onNextItem: () => moveSelection(1),
                        onPreviousItem: () => moveSelection(-1),
                        onTextChange: (value) => searchInputUpdated(value)))
              ] +
              headers
                  .where((anchor) =>
                      anchor.text
                          .substring(0, anchor.text.indexOf(" "))
                          .split(".")
                          .length <
                      3)
                  .map<Widget>((anchor) => ListTile(
                      title: Text(anchor.text),
                      onTap: () {
                        _scrollController.position.ensureVisible(
                            anchor.key.currentContext.findRenderObject());
                        Navigator.pop(context);
                      }))
                  .toList();
          return ListView(
            children: children,
          );
        });
  }

  void searchInputUpdated(String value) {
    String toSearch = value.trim();
    String newText = fullText;
    if (toSearch.isNotEmpty) {
      newText = markdownSearch(fullText, toSearch);
    }
    if (newText != model.text.value) {
      searchIndex.value = 0;
      model.text.value = newText;
    }
  }

  void moveSelection(int offset) {
    final List<Anchor> highlights =
        model.anchors.value.putIfAbsent(AnchorType.HIGHLIGHT, () => []);
    if (highlights.isNotEmpty) {
      searchIndex.value = (searchIndex.value + offset) % highlights.length;
      _scrollController.position.ensureVisible(
          highlights[searchIndex.value].key.currentContext.findRenderObject());
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      moveSelection(0);
    });

    return HomeLayout(
      title: GestureDetector(
          child: Text(SitLocalizations.of(context).title),
          onTap: () => searchInputUpdated("")),
      drawer: buildDrawer(context),
      mainView: buildMainView(context),
    );
  }
}
