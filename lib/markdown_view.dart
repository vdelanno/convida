import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import 'markdown_extensions.dart';
import 'model.dart';

class MarkdownView extends StatelessWidget {
  MarkdownView({@required this.model}) : super(key: model.markdownViewkey);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final Model model;

  String highlightMarkdown(String text, String substr) {
    return text.replaceAllMapped(new RegExp('($substr)', caseSensitive: false),
        (Match m) => "^^${m[1]}^^");
  }

  String markdownSearch(String text, String substr) {
    return highlightMarkdown(text, substr);
    List<String> headers = [];
    List<String> lastHeaders = [];
    List<String> lines = [];
    text.split("\n").forEach((line) {
      if (line.startsWith("#")) {
        int indent = line.indexOf(" ");
        if (indent > headers.length) {
          headers.add(line);
        } else {
          headers = headers.sublist(0, indent);
          headers[indent - 1] = line;
        }
      } else {
        String highlighted = highlightMarkdown(line, substr);
        if (highlighted.length != line.length) {
          for (int i = 0; i < headers.length; ++i) {
            if (i >= lastHeaders.length || headers[i] != lastHeaders[i]) {
              lines.add(headers[i]);
            }
          }
          lastHeaders = List.from(headers);
          lines.add(highlighted);
        }
      }
    });
    return lines.join("\n");
  }

  Future openLink(String text, String href, String title) async {
    print("openLink");
    if (!await canLaunch(href)) {
      print("cannot not launch $href");
    } else if (!await launch(href)) {
      print('Could not launch $href');
    } else {
      print('Could launch $href');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding markdown");
    AnchorBuilder anchorBuilder = AnchorBuilder();
    HighlightBuilder highlightBuilder = HighlightBuilder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      anchorBuilder.anchors.forEach((key, anchors) {
        anchors.removeWhere((a) => a.key.currentContext == null);
      });
      model.anchors.value = anchorBuilder.anchors;
    });

    return MarkdownBody(
        data: model.text.value,
        onTapLink: (text, href, title) => openLink(text, href, title),
        selectable: true,
        inlineSyntaxes: [
          HighlighSyntax(),
          AnchorSyntax()
        ],
        blockSyntaxes: [],
        builders: {
          'mark': highlightBuilder,
          'anchor': anchorBuilder,
        });
  }
}
