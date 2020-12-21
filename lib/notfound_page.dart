import 'package:convida/sit_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  NotFoundPage({@required this.title, key}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Row(children: [
          Text("title"),
        ])),
        body: Container(
          color: Theme.of(context).highlightColor,
          child: Center(child: Text("404 not found")),
        ));
  }
}
