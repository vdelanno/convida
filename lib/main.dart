import 'dart:convert';
import 'package:convida/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();

  Future<String> loadText() async {
    return rootBundle.load("assets/txt.md").then((bytes) {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'COnVIDa',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FutureBuilder(
            future: loadText(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return HomePage(title: 'COnVIDa', fullText: snapshot.data);
              }
              return LoadingPage(title: 'COnVIDa');
            }));
  }
}
