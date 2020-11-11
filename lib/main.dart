import 'dart:convert';
import 'package:convida/loading_page.dart';
import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  App();

  @override
  _AppState createState() => _AppState();
}

typedef LanguageCallback = void Function(String);

final Map<String, IconData> kKnownIcons = {
  "help": Icons.help,
  "hospital": Icons.local_hospital,
  "symptoms": Icons.sick,
  "treatment": Icons.medical_services,
  "special_conditions": Icons.accessibility,
  "share": Icons.share,
  "prevention": Icons.security,
  "home": Icons.home,
  "settings": Icons.settings
};

class _AppState extends State<App> {
  String _locale = 'es';
  onChangeLanguage(String language) {
    print("setting locale to $language");
    if (_locale != language) {
      setState(() {
        _locale = language;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        locale: Locale(_locale),
        localizationsDelegates: [
          SitLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: kSupportedLocales.map((l) => Locale(l)),
        home: AppBody(this.onChangeLanguage, _locale));
  }
}

class AppBody extends StatelessWidget {
  final LanguageCallback onChangeLanguage;
  final String _locale;
  AppBody(this.onChangeLanguage, this._locale);

  Section getSection(String text) {
    print("get section $text");
    int titleEnd = text.indexOf("\n");
    String title = text.substring(0, titleEnd).trim();
    String fullText = text.substring(titleEnd, text.length).trim();
    return Section(title: title, fullText: fullText);
  }

  Chapter getChapter(String title, String fullText, String image) {
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
          return getSection(section);
        })
        .where((chapter) => chapter != null)
        .toList();

    print("chapter $title $description $image -----");
    return Chapter(
        title: title,
        description: description,
        image: kKnownIcons[image],
        sections: sections);
  }

  Chapter parseChapter(String text) {
    int titleEnd = text.indexOf("\n");
    String title = text.substring(0, titleEnd).trim();
    String fullText = text.substring(titleEnd, text.length).trim();
    RegExp exp = new RegExp(r"^\[(.*)\]\s*(.*)");
    RegExpMatch match = exp.firstMatch(title);

    return getChapter(
      match.group(2),
      fullText,
      match.group(1),
    );
  }

  List<Chapter> parseChapters(String text) {
    return text
        .split(new RegExp(r"^\# ", multiLine: true))
        .map<Chapter>((chapter) {
          if (chapter.isEmpty) {
            return null;
          }
          return parseChapter(chapter);
        })
        .where((chapter) => chapter != null)
        .toList();
  }

  Future<List<Chapter>> loadText(String locale) async {
    print("loading text");
    return rootBundle.load("assets/txt-$locale.md").then((bytes) {
      String newText = utf8.decode(bytes.buffer.asUint8List());
      List<Chapter> pages = parseChapters(newText);
      // newText.split(new RegExp(r"^\# ", multiLine: true));
      // List<Chapter> pages = chapters
      //     .map<Chapter>((chapter) {
      //       if (chapter.isEmpty) {
      //         return null;
      //       }
      //       ;
      //       int titleEnd = chapter.indexOf("\n");
      //       String title = chapter.substring(0, titleEnd).trim();
      //       RegExp exp = new RegExp(r"^\[(.*)\]\s*(.*)");
      //       RegExpMatch match = exp.firstMatch(title);
      //       String fullText =
      //           chapter.substring(titleEnd, chapter.length).trim();
      //       print(match.group(2));

      //       String description = null;
      //       List<Section> sections = [];

      //       fullText.split("\n").forEach((line) {});

      //       return Chapter(
      //         title: match.group(2),
      //         description: fullText,
      //         image: kKnownIcons[match.group(1)],
      //       );
      //     })
      //     .where((page) => page != null)
      //     .toList();
      return pages;
    });
  }

  String getLocale() => Intl.shortLocale(Intl.defaultLocale);

  @override
  Widget build(BuildContext context) {
    String locale = getLocale();
    if (locale != _locale) {
      Future.delayed(Duration(microseconds: 0), () => onChangeLanguage(locale));

      return Container();
    }
    print("build locale $locale ");
    return FutureBuilder(
        future: loadText(locale),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return HomePage(chapters: snapshot.data);
          }
          return LoadingPage(
            title: SitLocalizations.of(context).title,
          );
        });
  }
}
