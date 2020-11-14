import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'icons_helper.dart';

class Anchor {
  Anchor(this.text, this.key);
  final String text;
  final GlobalKey key;
}

enum AnchorType { HIGHLIGHT, HEADER }

class Section {
  Section({@required this.title, @required this.fullText});
  final String title;
  final String fullText;
}

class Chapter {
  Chapter(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.image,
      @required this.sections});
  final String id;
  final String title;
  final String description;
  final IconData image;
  final List<Section> sections;
}

class Model {
  static Future<List<Chapter>> _chapters;
  static Future<List<Chapter>> get chapters {
    if (_chapters == null) {
      Model model = Model._();
      _chapters = model._loadText();
    }
    return _chapters;
  }

  Model._();

  Section _getSection(String text) {
    int titleEnd = text.indexOf("\n");
    String title = text.substring(0, titleEnd).trim();
    String fullText = text.substring(titleEnd, text.length).trim();
    return Section(title: title, fullText: fullText);
  }

  Chapter _getChapter(String title, String fullText, String image, String id) {
    fullText = fullText.trim();
    String description;
    if (!fullText.startsWith('#')) {
      int descriptionLength = fullText.indexOf("##");
      if (descriptionLength == -1) {
        description = fullText;
        fullText = "";
      } else {
        description = fullText.substring(0, descriptionLength).trim();
        fullText =
            fullText.substring(descriptionLength, fullText.length).trim();
      }
    }

    List<Section> sections = fullText
        .split(new RegExp(r"^\#\# ", multiLine: true))
        .map<Section>((section) {
          if (section.isEmpty) {
            return null;
          }
          return _getSection(section);
        })
        .where((chapter) => chapter != null)
        .toList();

    return Chapter(
        id: id,
        title: title,
        description: description,
        image: getIconUsingPrefix(name: image),
        sections: sections);
  }

  Chapter _parseChapter(String text) {
    int titleEnd = text.indexOf("\n");
    String title = text.substring(0, titleEnd).trim();
    String fullText = text.substring(titleEnd, text.length).trim();
    RegExp exp = new RegExp(r"^\[(.*)\:(.*)\]\s*(.*)");
    RegExpMatch match = exp.firstMatch(title);

    return _getChapter(
      match.group(3),
      fullText,
      match.group(2),
      match.group(1),
    );
  }

  List<Chapter> _parseChapters(String text) {
    return text
        .split(new RegExp(r"^\# ", multiLine: true))
        .map<Chapter>((chapter) {
          if (chapter.isEmpty) {
            return null;
          }
          return _parseChapter(chapter);
        })
        .where((chapter) => chapter != null)
        .toList();
  }

  Future<List<Chapter>> _loadText() async {
    print("loading text");
    String locale = Intl.shortLocale(Intl.defaultLocale);

    return rootBundle.load("assets/txt-$locale.md").then((bytes) {
      String newText = utf8.decode(bytes.buffer.asUint8List());
      List<Chapter> pages = _parseChapters(newText);
      return pages;
    });
  }
}
