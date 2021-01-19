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

class QuestionAnswer {
  QuestionAnswer({@required this.title, @required this.fullText});
  final String title;
  final String fullText;

  Map toDict() {
    return {"title": title, "fullText": fullText};
  }
}

class PageItem {
  PageItem({
    @required this.id,
    @required this.title,
    @required this.image,
  });
  final String id;
  final String title;
  final IconData image;

  Map toDict() {
    print("page item todict $id $title");
    return {
      "id": this.id,
      "title": this.title,
    };
  }
}

class Chapter extends PageItem {
  Chapter(
      {@required String id,
      @required String title,
      @required IconData image,
      @required this.pages})
      : super(id: id, title: title, image: image);
  final List<PageItem> pages;

  Map toDict() {
    print("chapter todict ${pages.length}");
    Map map = super.toDict();
    print("chapter todict $map");
    map["pages"] = pages.map((page) => page.toDict()).toList();
    return map;
  }
}

class Section extends PageItem {
  Section(
      {@required String id,
      @required String title,
      @required IconData image,
      @required this.description,
      @required this.qas})
      : super(id: id, title: title, image: image);

  final String description;
  final List<QuestionAnswer> qas;

  Map toDict() {
    Map map = super.toDict();
    map["description"] = description;
    map["qas"] = this.qas.map((qa) => qa.toDict());
    return map;
  }
}

class Model {
  static Model _instance = Model._();

  Future<Chapter> _home;
  Future<Chapter> get home => _home;
  Model._() {
    _home = _loadText().then((home) {
      return home;
    });
  }

  factory Model.instance() {
    return _instance;
  }

  QuestionAnswer _getQuestionAnswer(String text) {
    int titleEnd = text.indexOf("\n");
    String title = text.substring(0, titleEnd).trim();
    String fullText = text.substring(titleEnd, text.length).trim();
    return QuestionAnswer(title: title, fullText: fullText);
  }

  Section _getSection(
      String title, String fullText, String image, String id, int level) {
    print("_getSection: $title");
    fullText = fullText.trim();
    String description;
    if (!fullText.startsWith('¿')) {
      int descriptionLength = fullText.indexOf("¿");
      if (descriptionLength == -1) {
        description = fullText;
        fullText = "";
      } else {
        description = fullText.substring(0, descriptionLength).trim();
        fullText =
            fullText.substring(descriptionLength, fullText.length).trim();
      }
    }

    List<QuestionAnswer> sections = fullText
        .split(new RegExp(r"^¿", multiLine: true))
        .map<QuestionAnswer>((section) {
          if (section.isEmpty) {
            return null;
          }
          return _getQuestionAnswer(section);
        })
        .where((section) => section != null)
        .toList();

    Section section = Section(
        id: id,
        title: title,
        description: description,
        image: getIconUsingPrefix(name: image),
        qas: sections);

    return section;
  }

  PageItem _parsePage(String text, int level) {
    int headerEnd = text.indexOf("\n");
    String header = text.substring(0, headerEnd).trim();
    String fullText = text.substring(headerEnd, text.length).trim();
    RegExp exp = new RegExp(r"^\[(.*)\:(.*)\]\s*(.*)");
    RegExpMatch match = exp.firstMatch(header);

    String title = match.group(3);
    String image = match.group(2);
    String id = match.group(1);

    int childLevel = level + 1;
    String childRegex = "^" + "#" * childLevel + " ";

    print("_parsePage $title $level '$childRegex'");
    if (fullText.contains(new RegExp(childRegex, multiLine: true))) {
      return _getChapter(title, fullText, image, id, childLevel);
    } else {
      return _getSection(title, fullText, image, id, level);
    }
  }

  Chapter _getChapter(
      String title, String fullText, String image, String id, int level) {
    String regex = "^" + "\\#" * level + " ";
    print("_getChapter " + title);
    List<PageItem> pages = fullText
        .split(new RegExp(regex, multiLine: true))
        .map<PageItem>((text) {
          if (text.isEmpty) {
            return null;
          }
          PageItem child = _parsePage(text, level);
          if (child == null) {
            print("CHILD IS NULL");
          }
          return child;
        })
        .where((page) => page != null)
        .toList();
    return Chapter(
        id: id,
        title: title,
        image: getIconUsingPrefix(name: image),
        pages: pages);
  }

  Future<Chapter> _loadText() async {
    print("loading text");
    String locale = Intl.shortLocale(Intl.defaultLocale);

    return rootBundle.load("assets/txt-$locale.md").then((bytes) {
      String newText = utf8.decode(bytes.buffer.asUint8List());
      Chapter chapter =
          _getChapter("convida", newText, "convida", "convida", 1);
      return chapter;
    });
  }
}
