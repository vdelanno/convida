import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import 'model.dart';

/// Parse [highlight items]
class HighlighSyntax extends md.TagSyntax {
  static final _pattern = r'\^\^';
  HighlighSyntax()
      : super(_pattern,
            end: _pattern, requiresDelimiterRun: true, allowIntraWord: true);

  @override
  bool onMatchEnd(md.InlineParser parser, Match match, md.TagState state) {
    md.Element anchor = md.Element.text('anchor', "");
    anchor.attributes['text'] = match.input;
    anchor.attributes['type'] = AnchorType.HIGHLIGHT.index.toString();

    parser.addNode(anchor);
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
    return false;
  }

  @override
  Widget visitText(md.Text text, TextStyle preferredStyle) {
    return null;
  }

  @override
  Widget visitElementAfter(md.Element element, TextStyle preferredStyle) {
    TextStyle style = preferredStyle == null
        ? TextStyle(backgroundColor: Colors.yellow)
        : preferredStyle.copyWith(backgroundColor: Colors.yellow);
    // MarkdownBuilder newBuilder = builder.clone();
    // builder.build(element.children);

    SelectableText widget = SelectableText.rich(TextSpan(
        text: element.textContent, style: style, semanticsLabel: "highlight"));
    return widget;
  }
}

// Parse [anchor items]
class AnchorSyntax extends md.TagSyntax {
  AnchorSyntax()
      : super(r'\[\[',
            end: r'\]\]', requiresDelimiterRun: true, allowIntraWord: true);

  @override
  bool onMatchEnd(md.InlineParser parser, Match match, md.TagState state) {
    md.Element anchor = md.Element.text('anchor', "");
    anchor.attributes['text'] =
        state.children.map((e) => e.textContent).join(" ");
    anchor.attributes['type'] = AnchorType.HEADER.index.toString();
    parser.addNode(anchor);
    state.children.forEach((element) => parser.addNode(element));
    // parser.advanceBy(0);
    return true;
  }
}

class AnchorBuilder extends MarkdownElementBuilder {
  final Map<AnchorType, List<Anchor>> anchors = Map<AnchorType, List<Anchor>>();
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
    GlobalKey dataKey = new GlobalKey(debugLabel: "anchor");
    anchors
        .putIfAbsent(
            AnchorType.values[int.parse(element.attributes['type'])], () => [])
        .add(Anchor(element.attributes['text'], dataKey));
    // return SelectableText.rich(TextSpan(text: "\u2063"),
    return SelectableText.rich(
        TextSpan(
            text: "",
            style: TextStyle(color: Colors.red, backgroundColor: Colors.blue),
            semanticsLabel: "anchor"),
        key: dataKey);
  }
}
