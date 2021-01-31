import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  LoadingPage({this.title, key}) : super(key: key);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Row(children: [
          Text("COnVIDa"),
        ])),
        body: Container(
          color: Theme.of(context).highlightColor,
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          )),
        ));
  }
}
