import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'model.dart';
import 'text_load_layout.dart';

class SearchMatch {
  SearchMatch(this.nbMatches, this.widget);
  final int nbMatches;
  final Widget widget;
}

class SearchPage extends StatelessWidget {
  static const String route = '/search';
  SearchPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  Widget getResultCard(BuildContext context, String title, String? subtitle,
      String content, String input, IconData? icon) {
    return Card(
        margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: ListTile(
                  leading: Icon(icon),
                  subtitle: subtitle == null ? null : Text(subtitle),
                  title: Text(
                    title,
                    style: Theme.of(context).accentTextTheme.subtitle1,
                  )),
              color: Theme.of(context).accentColor,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: MarkdownBody(data: content),
            )
          ],
        ));
  }

  List<Widget> searchResult(
      BuildContext context, List<Section> sections, String input) {
    input = input.toLowerCase();
    List<SearchMatch> allMatches = [];
    sections.forEach((section) {
      if (section.description != null) {
        int nbMatches = input
            .allMatches([section.title, section.description]
                .join(" |||| ")
                .toLowerCase())
            .length;
        if (nbMatches > 0) {
          allMatches.add(SearchMatch(
              nbMatches,
              getResultCard(context, section.title, null, section.description,
                  input, section.image)));
        }
      }
      section.qas.forEach((qa) {
        int nbMatches = input
            .allMatches([section.title, qa.fullText, qa.title]
                .join(" |||| ")
                .toLowerCase())
            .length;
        if (nbMatches > 0) {
          allMatches.add(SearchMatch(
              nbMatches,
              getResultCard(context, qa.title, section.title, qa.fullText,
                  input, Icons.question_answer)));
        }
      });
    });

    allMatches.sort((a, b) => a.nbMatches.compareTo(b.nbMatches));
    return allMatches.map((m) => m.widget).toList();
  }

  List<Section> getSections(Chapter chapter) {
    List<Section> sections = [];
    chapter.pages.forEach((page) {
      if (page is Chapter) {
        sections.addAll(getSections(page));
      } else if (page is Section) {
        sections.add(page);
      }
    });
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return TextLoadLayout(builder: (context, home) {
      List<Section> sections = getSections(home);
      final TextEditingController textController = TextEditingController();
      return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: textController,
              decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Theme.of(context).canvasColor,
                filled: true,
                icon: Icon(Icons.search),
                hintText: SitLocalizations.of(context).searchPlaceholder,
              ),
            ),
          ),
          body: Scrollbar(
              child: Container(
            color: Theme.of(context).highlightColor,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: textController,
                builder: (context, TextEditingValue value, child) {
                  String input = value.text.trim();
                  if (input.length < 3) {
                    return Container();
                  }
                  return ListView(
                    children: searchResult(context, sections, input),
                  );
                },
              ),
            ),
          )));
    });
  }
}
