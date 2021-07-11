import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:charcode/ascii.dart';

import 'model.dart';

/// Parse [highlight items]
class HighlighSyntax extends md.InlineSyntax {
  static final _highlightRegex = r'''[^\^]+''';
  HighlighSyntax() : super('^^($_highlightRegex)^^', startCharacter: $caret);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element anchor = md.Element.text('anchor', "");
    anchor.attributes['text'] = match.input;
    anchor.attributes['type'] = AnchorType.HIGHLIGHT.index.toString();

    // parser.advanceBy(2);
    parser.addNode(anchor);
    // parser.addNode(md.Element('mark', state.children));
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
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return null;
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
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
class AnchorSyntax extends md.InlineSyntax {
  static final _anchorRegex = r'''[^\]]+''';
  AnchorSyntax() : super('[[($_anchorRegex)]]', startCharacter: $lbracket);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    md.Element anchor = md.Element.text('anchor', "");
    anchor.attributes['text'] = match[1]!;
    anchor.attributes['type'] = AnchorType.HEADER.index.toString();
    parser.addNode(anchor);
    // parser.children.forEach((element) => parser.addNode(element));

    return true;
  }

  // @override
  // bool onMatchEnd(md.InlineParser parser, Match match, md.TagState state) {
  //   md.Element anchor = md.Element.text('anchor', "");
  //   anchor.attributes['text'] =
  //       state.children.map((e) => e.textContent).join(" ");
  //   anchor.attributes['type'] = AnchorType.HEADER.index.toString();
  //   parser.addNode(anchor);
  //   state.children.forEach((element) => parser.addNode(element));
  //   // parser.advanceBy(0);
  //   return true;
  // }
}

class AnchorBuilder extends MarkdownElementBuilder {
  final Map<AnchorType, List<Anchor>> anchors = Map<AnchorType, List<Anchor>>();
  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return null;
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    GlobalKey dataKey = new GlobalKey(debugLabel: "anchor");
    anchors
        .putIfAbsent(
            AnchorType.values[int.parse(element.attributes['type']!)], () => [])
        .add(Anchor(element.attributes['text']!, dataKey));
    // return SelectableText.rich(TextSpan(text: "\u2063"),
    return SelectableText.rich(
        TextSpan(
            text: "",
            style: TextStyle(color: Colors.red, backgroundColor: Colors.blue),
            semanticsLabel: "anchor"),
        key: dataKey);
  }
}

/// Parses preformatted code blocks between two ~~~ or ``` sequences.
///
/// See the CommonMark spec: https://spec.commonmark.org/0.29/#fenced-code-blocks
final _qaPattern = RegExp(r'^[ ]{0,3}(\?{3,})(.*)$');

class QandASyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => _qaPattern;

  const QandASyntax();

  @override
  bool canParse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current);
    if (match == null) return false;
    final codeFence = match.group(1);
    final infoString = match.group(2);
    // From the CommonMark spec:
    //
    // > If the info string comes after a backtick fence, it may not contain
    // > any backtick characters.
    return (codeFence?.codeUnitAt(0) != $backquote ||
        !infoString!.codeUnits.contains($backquote));
  }

  @override
  List<String> parseChildLines(md.BlockParser parser) {
    String endBlock = '';

    var childLines = <String>[];
    parser.advance();

    while (!parser.isDone) {
      var match = pattern.firstMatch(parser.current);
      if (match == null || !match[1]!.startsWith(endBlock)) {
        childLines.add(parser.current);
        parser.advance();
      } else {
        parser.advance();
        break;
      }
    }

    return childLines;
  }

  @override
  md.Node parse(md.BlockParser parser) {
    // Get the syntax identifier, if there is one.
    // var match = pattern.firstMatch(parser.current);
    // String endBlock = match!.group(1)!;
    // // var infoString = match.group(2);

    var childLines = parseChildLines(parser);

    // The Markdown tests expect a trailing newline.
    childLines.add('');
    String header = childLines[0].trim();
    String content =
        childLines.getRange(1, childLines.length).join("\n").trim();

    // var text = childLines.join('\n').trim();
    // if (parser.document.encodeHtml) {
    //   text = escapeHtml(text);
    // }
    // print("text ?? $text ??");
    var qa = md.Element("qa", [md.Element.text("", content)]);
    qa.attributes["header"] = header;
    // var qa = md.Text(content);

    // the info-string should be trimmed
    // http://spec.commonmark.org/0.22/#example-100
    // infoString = infoString.trim();
    // if (infoString.isNotEmpty) {
    //   // only use the first word in the syntax
    //   // http://spec.commonmark.org/0.22/#example-100
    //   var firstSpace = infoString.indexOf(' ');
    //   if (firstSpace >= 0) {
    //     infoString = infoString.substring(0, firstSpace);
    //   }
    //   // if (parser.document.encodeHtml) {
    //   //   infoString = escapeHtmlAttribute(infoString);
    //   // }
    //   code.attributes['class'] = 'language-$infoString';
    // }

    // var element = md.Element('pre', [code]);

    return qa;
  }
}

class QaBuilder extends MarkdownElementBuilder {
  @override
  bool visitElementBefore(md.Element element) {
    return true;
  }

  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return null;
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return ExpansionTile(
        leading: Icon(Icons.question_answer_rounded),
        title: Text(
          element.attributes['header']!,
          style: preferredStyle,
        ),
        children: [
          MarkdownBody(data: element.textContent),
        ]);
  }
}
