import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Parse [highlight items]
class HighlighSyntax extends md.TagSyntax {
  static final _pattern = r'\^\^';
  HighlighSyntax()
      : super(_pattern, requiresDelimiterRun: false, allowIntraWord: true);

  @override
  bool onMatchEnd(md.InlineParser parser, Match match, md.TagState state) {
    var runLength = match.group(0).length;
    var matchStart = parser.pos;
    var matchEnd = parser.pos + runLength - 1;
    var openingRunLength = state.endPos - state.startPos;
    parser.advanceBy(0);
    parser.addNode(md.Element('mark', state.children));
    return true;
  }
  // @override
  // bool onMatch(md.InlineParser parser, Match match) {
  //   md.Element el = md.Element.withTag("mark");
  //   el.children.add(md.Element.text("span", match[1]));
  //   parser.addNode(el);
  //   return true;
  // }
}

class HighlightBuilder extends MarkdownElementBuilder {
  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  Widget visitText(md.Text text, TextStyle preferredStyle) {
    return null;
  }

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) {
    return null;
    TextStyle style = preferredStyle == null
        ? TextStyle(backgroundColor: Colors.yellow)
        : preferredStyle.copyWith(backgroundColor: Colors.yellow);
    SelectableText widget =
        SelectableText.rich(TextSpan(text: element.textContent, style: style));
    return widget;
  }
}

// Parse [anchor items]
class AnchorSyntax extends md.TagSyntax {
  AnchorSyntax()
      : super(r'\[\[',
            end: r'\]\]', requiresDelimiterRun: false, allowIntraWord: true);

  @override
  bool onMatchEnd(md.InlineParser parser, Match match, md.TagState state) {
    var runLength = match.group(0).length;
    var matchStart = parser.pos;
    var matchEnd = parser.pos + runLength - 1;
    var openingRunLength = state.endPos - state.startPos;

    parser.addNode(md.Element('anchor', state.children));
    return true;
  }
}

class Anchor {
  Anchor(this.text, this.key);
  final String text;
  final GlobalKey key;
}

class AnchorBuilder extends MarkdownElementBuilder {
  final List<Anchor> anchors = List<Anchor>();
  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  Widget visitText(md.Text text, TextStyle preferredStyle) {
    return null;
  }

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) {
    final GlobalKey dataKey = new GlobalKey();
    SelectableText widget = SelectableText.rich(
        TextSpan(text: element.textContent, style: preferredStyle),
        key: dataKey);

    anchors.add(Anchor(element.textContent, dataKey));
    return widget;
  }
}
