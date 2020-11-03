import 'dart:convert';
import 'package:convida/loading_page.dart';
import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';
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

  Future<String> loadText(String locale) async {
    return rootBundle.load("assets/txt-$locale.md").then((bytes) {
      String newText = utf8.decode(bytes.buffer.asUint8List());
      List<String> lines = [];
      List<int> headers = [];
      newText.split("\n").forEach((line) {
        line = line.trimRight();

        if (line.length == 0) {
          lines.add(line);
          return;
        }

        if (line.startsWith("#")) {
          int indent = line.indexOf(" ");
          if (indent < 5) {
            while (headers.length > indent) {
              headers.removeLast();
            }
            if (indent == headers.length) {
              headers[indent - 1] = headers[indent - 1] + 1;
            } else {
              for (int i = headers.length; i < indent; ++i) {
                headers.add(1);
              }
            }
            String indentstr =
                "[[" + headers.map((h) => h.toString()).join(".") + " ";
            String suffix = "]]";
            lines.add(
                line.replaceRange(indent + 1, indent + 1, indentstr) + suffix);
            return;
          }
        }
        lines.add(line);
      });
      return lines.join("\n");
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
            return HomePage(fullText: snapshot.data);
          }
          return LoadingPage(
            title: SitLocalizations.of(context).title,
          );
        });
  }
}
