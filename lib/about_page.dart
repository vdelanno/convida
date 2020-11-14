import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AboutPage extends StatelessWidget {
  static const String route = '/about';
  AboutPage({
    Key key,
  }) : super(key: key);

  Future<String> loadText() async {
    print("loading text");
    return rootBundle.load("assets/about.md").then((bytes) {
      return utf8.decode(bytes.buffer.asUint8List());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SitLocalizations.of(context).title),
      ),
      body: FutureBuilder(
          future: loadText(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Scrollbar(child: MarkdownBody(data: snapshot.data));
            }
            return Container();
          }),
    );
  }
}
