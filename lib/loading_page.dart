import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  LoadingPage({key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("loading page build");
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
