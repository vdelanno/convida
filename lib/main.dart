import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: MyHomePage(title: 'COnVIDa'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  ValueNotifier<String> text = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    rootBundle.load("txt.md").then((bytes) {
      String newText = utf8.decode(bytes.buffer.asUint8List());
      List<String> lines = [];
      List<int> headers = [];
      newText.split("\n").forEach((line) {
        line = line.trimRight();

        if (line.length == 0) return;

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
            lines.add(line.replaceRange(indent + 1, indent + 1,
                headers.map((h) => h.toString()).join(".") + " "));
            return;
          }
        }
        lines.add(line);
      });
      text.value = lines.join("\n");
      // text.value = lines.join("\n");
    });
    // return _mapController.addImage(name, bytes.buffer.asUint8List());

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("COnVIDa"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ValueListenableBuilder(
            valueListenable: text,
            builder: (context, value, child) => Markdown(data: value)),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
