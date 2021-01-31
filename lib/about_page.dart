import 'package:convida/model.dart';
import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

typedef void LanguageChangeCallback(String newLanguage);

class AboutPage extends StatelessWidget {
  static const String route = '/about';
  AboutPage({Key key}) : super(key: key);

  Future<String> loadText() async {
    print("loading text");
    return rootBundle.load("assets/about.md").then((bytes) {
      return utf8.decode(bytes.buffer.asUint8List());
    });
  }

  Widget _aboutSection(
      BuildContext context, String title, IconData icon, Widget widget) {
    return Card(
        margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: ListTile(
                  leading: Icon(icon),
                  title: Text(
                    title,
                    style: Theme.of(context).accentTextTheme.subtitle1,
                  )),
              color: Theme.of(context).accentColor,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 5, 5, 5),
              child: widget,
            )
          ],
        ));
  }

  Widget languageSelector(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Model.textLocale,
        builder: (context, language, child) {
          if (language != null) {
            return DropdownButton(
                value: language as String,
                items: [
                  DropdownMenuItem(value: "es", child: Text("Español")),
                  DropdownMenuItem(value: "en", child: Text("English")),
                ],
                onChanged: (String newValue) {
                  print("changed to $newValue");
                  Model.textLocale.value = newValue;
                });
          }
          return DropdownButton(items: [
            DropdownMenuItem(value: "es", child: Text("Español")),
            DropdownMenuItem(value: "en", child: Text("English")),
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadText(),
      builder: (context, snapshot) {
        Widget child = Container();
        if (snapshot.connectionState == ConnectionState.done) {
          child = Scrollbar(
            child: ListView(children: [
              _aboutSection(context, "Language", Icons.language,
                  languageSelector(context)),
              _aboutSection(context, "ConVIDa information", Icons.notes,
                  MarkdownBody(data: snapshot.data))
            ]),
          );
        }
        return Scaffold(
            appBar: AppBar(
              title: Text(SitLocalizations.of(context).title),
            ),
            body: child);
      },
    );
  }
}
