import 'package:convida/markdown_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'model.dart';
import 'markdown_scrollbar.dart';

class ChapterPage extends StatelessWidget {
  ChapterPage({Key key, this.chapter})
      : model = PageDataModel(text: chapter.description),
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

  Widget sectionWidget(BuildContext context, Section section) {
    return Card(
        margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Text(
                section.title,
                style: Theme.of(context).accentTextTheme.subtitle1,
              ),
              color: Theme.of(context).accentColor,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: MarkdownBody(data: section.fullText),
            )
          ],
        ));
  }

  Widget buildMainView(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 300, maxWidth: 800),
      child: Scrollbar(
        child: ValueListenableBuilder(
            valueListenable: model.text,
            builder: (context, value, child) {
              List<Widget> widgets = [];
              if (chapter.description != null) {
                widgets.add(Container(
                    color: Theme.of(context).canvasColor,
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                    child: MarkdownBody(data: chapter.description)));
              }

              List<Widget> sections = chapter.sections
                  .map<Widget>((section) => sectionWidget(context, section))
                  .toList();
              widgets.add(Container(
                  // color: Theme.of(context).highlightColor,
                  child: Column(children: sections)));
              return ListView(children: widgets, controller: _scrollController);
            }),
      ),
    );
  }

  void searchInputUpdated(String value) {
    String toSearch = value.trim();
    String newText = chapter.description;
    if (toSearch.isNotEmpty) {
      newText = markdownSearch(chapter.description, toSearch);
    }
    if (newText != model.text.value) {
      searchIndex.value = 0;
      model.text.value = newText;
    }
  }

  @override
  Widget build(BuildContext context) {
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
