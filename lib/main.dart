import 'dart:convert';
import 'package:convida/loading_page.dart';
import 'package:convida/sit_localizations.dart';
import 'package:convida/text_load_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'about_page.dart';
import 'chapter_page.dart';
import 'home_page.dart';
import 'icons_helper.dart';
import 'model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'search_page.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  App();

  @override
  _AppState createState() => _AppState();
}

typedef LanguageCallback = void Function(String);

// 1.	Aclarando dudas (Clarifying doubts)
//    help / question mark
// 2.	Transmisión (Transmission)3
//    sharing
// 3.	Prevención (Prevention)
//    shield
// 4.	Molestias (Síntomas) (Symptoms)
//    sick guy
// 5.	Personas especiales (Special people)
//    accessibility_new
// 6.	Cuando hay un enfermo en casa (When there is someone sick at home)
//    home
// 7.	Señales de alarma (Emergency warning signs)
//    medical_services / ambulance
// 8.	Exámenes (Tests)
//    vial
// 9.	Tratamiento (Treatment)
//    healing

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
      localeResolutionCallback: (locale, supportedLocales) {
        print("resolve $locale");
        return Locale(locale.languageCode);
      },
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        AboutPage.route: (context) => AboutPage(),
        SearchPage.route: (context) => SearchPage(),
      },
      onGenerateRoute: (settings) {
        print("canPop ${settings.name}? ${Navigator.canPop(context)}");
        return MaterialPageRoute(
            settings: RouteSettings(name: settings.name),
            builder: (context) => ChapterPage());
      },
      supportedLocales: kSupportedLocales.map((l) => Locale(l)),
      // home: AppBody(this.onChangeLanguage, _locale)
    );
  }
}

class AppBody extends StatelessWidget {
  final LanguageCallback onChangeLanguage;
  final String _locale;
  AppBody(this.onChangeLanguage, this._locale);

  @override
  Widget build(BuildContext context) {
    print("default localed ${Intl.defaultLocale}");
    String locale = Intl.shortLocale(Intl.defaultLocale);
    if (locale != _locale) {
      Future.delayed(Duration(microseconds: 0), () => onChangeLanguage(locale));

      return Container();
    }
    print("build locale $locale ");
    return TextLoadLayout(builder: (context, chapters) => HomePage());
  }
}
