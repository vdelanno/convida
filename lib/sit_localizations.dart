import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:convida/l10n/messages_all.dart';
import 'package:convida/l10n/messages_es.dart';
import 'package:convida/l10n/messages_en.dart';
import 'package:convida/l10n/messages_qu.dart';

final kSupportedLocales = {
  'es': 'es', // English, no country code
  'en': 'en',
  'qu': 'en'
};

class SitLocalizations {
  /// Initialize localization systems and messages
  static Future<SitLocalizations> load(Locale locale) async {
    // If we're given "en_US", we'll use it as-is. If we're
    // given "en", we extract it and use it.
    final String localeName =
        locale.countryCode == null || locale.countryCode.isEmpty
            ? locale.languageCode
            : locale.toString();
    // We make sure the locale name is in the right format e.g.
    // converting "en-US" to "en_US".
    final String canonicalLocaleName = Intl.canonicalizedLocale(localeName);
    // Load localized messages for the current locale.
    // await initializeMessages(canonicalLocaleName);
    // We'll uncomment the above line after we've built our messages file
    // Force the locale in Intl.
    Intl.defaultLocale = canonicalLocaleName;

    return SitLocalizations();
  }

  String get title => Intl.message(
        'COnVIDa',
        name: 'title',
        desc: 'App title',
      );
  String get searchPlaceholder => Intl.message(
        'Search...',
        name: 'searchPlaceholder',
        desc: 'The placeholder in the search entry',
      );
  String get loadingText => Intl.message(
        'Loading...',
        name: 'loadingText',
        desc: 'Text displayed in the loading page',
      );
  String get sideMenuHeader => Intl.message(
        'Quick Access',
        name: 'sideMenuHeader',
        desc: 'side menu header text',
      );

  /// Retrieve localization resources for the widget tree
  /// corresponding to the given `context`
  static SitLocalizations of(BuildContext context) =>
      Localizations.of<SitLocalizations>(context, SitLocalizations);
}

class SitLocalizationsDelegate extends LocalizationsDelegate<SitLocalizations> {
  const SitLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) =>
      kSupportedLocales.containsKey(locale.languageCode);
  @override
  Future<SitLocalizations> load(Locale locale) => SitLocalizations.load(locale);
  @override
  bool shouldReload(LocalizationsDelegate<SitLocalizations> old) => false;
}
