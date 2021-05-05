import 'dart:convert';

import 'package:convida/sit_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    Map map = super.toDict();
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
  static final String DEFAULT_LOCALE = "en";
  static ValueNotifier<String> textLocale = ValueNotifier<String>(null);
  static Future<String> _loadTextLocale() {
    return SharedPreferences.getInstance().then((prefs) {
      String locale;
      try {
        print("getTextLocale loading");
        locale = prefs.getString("language");
        print("getTextLocale loaded $locale");
      } catch (e) {
        print("could not load language: $e");

        locale = Intl.shortLocale(Intl.defaultLocale);
      }

      if (!kSupportedLocales.containsKey(locale)) {
        locale = DEFAULT_LOCALE;
      }

      print("getTextLocale loading $locale");

      textLocale.value = locale;

      return locale;
    });
  }

  static void _updateTextLocale() {
    String locale = textLocale.value;
    SharedPreferences.getInstance().then((prefs) {
      try {
        print("saving language: $locale");
        prefs.setString("language", locale);
      } catch (e) {
        print("could not save language: $e");
      }
    }).then((dynamic) {
      print("saved language: $locale");
    });
    _instance = Model._();
  }

  Model._() {
    Future<String> locale = Future.value(textLocale.value);
    if (textLocale.value == null) {
      print("Model constructor");
      locale = _loadTextLocale();
      textLocale.addListener(() => Model._updateTextLocale());
    }
    _home = locale.then((le) => _loadText()).then((home) {
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

    if (fullText.contains(new RegExp(childRegex, multiLine: true))) {
      return _getChapter(title, fullText, image, id, childLevel);
    } else {
      return _getSection(title, fullText, image, id, level);
    }
  }

  Chapter _getChapter(
      String title, String fullText, String image, String id, int level) {
    String regex = "^" + "\\#" * level + " ";
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
    if (Model.textLocale.value == null) {
      return Future.value(Chapter(
          id: "convida",
          image: getIconUsingPrefix(name: "cached"),
          pages: [],
          title: "loading"));
    }
    return rootBundle.load("assets/txt-${textLocale.value}.md").then((bytes) {
      String newText = utf8.decode(bytes.buffer.asUint8List());
      try {
        Chapter chapter =
            _getChapter("convida", newText, "convida", "convida", 1);
        return chapter;
      } catch (e) {
        print("failed to load text: $e");
        return null;
      }
    });
  }
}
