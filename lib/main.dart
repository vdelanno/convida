import 'dart:convert';
import 'package:convida/loading_page.dart';
import 'package:convida/sit_localizations.dart';
import 'package:convida/text_load_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'about_page.dart';
import 'convida_page.dart';
import 'section_page.dart';
import 'chapter_page.dart';
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

class _AppState extends State<App> {
  String _locale;
  onChangeLanguage() {
    String language = Model.textLocale.value;
    print("setting locale to $language");
    if (_locale != language) {
      setState(() {
        _locale = language;
      });
    }
  }

  @override
  initState() {
    super.initState();
    Model.textLocale.addListener(onChangeLanguage);
  }

  @override
  void deactivate() {
    Model.textLocale.removeListener(onChangeLanguage);
    super.deactivate();
  }

  @override
  dispose() {
    Model.textLocale.removeListener(onChangeLanguage);
    super.dispose();
  }

  MaterialApp _buildApp(BuildContext context) {
    String locale = _locale;
    if (locale == null) {
      locale = Model.DEFAULT_LOCALE;
    }
    return new MaterialApp(
      locale: Locale(locale),
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
        // '/': (context) => ConvidaPage(pageId: "convida"),
        AboutPage.route: (context) => AboutPage(),
        SearchPage.route: (context) => SearchPage(),
      },
      onGenerateRoute: (settings) {
        print("canPop ${settings.name}? ${Navigator.canPop(context)}");
        return MaterialPageRoute(
            settings: RouteSettings(name: settings.name),
            builder: (context) {
              String pageId = settings.name.substring(1);
              if (pageId.isEmpty) {
                pageId = "convida";
              }
              return ConvidaPage(pageId: pageId);
            });
      },
      supportedLocales: kSupportedLocales.map((l) => Locale(l)),
    );
  }

  MaterialApp _buildLoading(BuildContext context) {
    return new MaterialApp(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
            settings: RouteSettings(name: settings.name),
            builder: (context) {
              return LoadingPage();
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildApp(context);
  }
}
