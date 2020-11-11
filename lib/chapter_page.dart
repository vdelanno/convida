import 'package:convida/markdown_view.dart';
import 'package:convida/search_widget.dart';
import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'home_layout.dart';
import 'model.dart';
import 'markdown_scrollbar.dart';

class ChapterPage extends StatelessWidget {
  ChapterPage({Key key, this.chapter})
      : model = PageDataModel(text: chapter.fullText),
        super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Chapter chapter;
  final PageDataModel model;
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

  void searchInputUpdated(String value) {
    String toSearch = value.trim();
    String newText = chapter.fullText;
    if (toSearch.isNotEmpty) {
      newText = markdownSearch(chapter.fullText, toSearch);
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

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Icon(chapter.image),
          Container(width: 10),
          Text(chapter.title)
        ]),
      ),
      body: Container(
          color: Theme.of(context).highlightColor,
          child: Center(
            child: buildMainView(context),
          )),
    );
  }
}
