import 'dart:math';

import 'package:convida/chapter_page.dart';
import 'package:convida/markdown_view.dart';
import 'package:convida/search_widget.dart';
import 'package:convida/sit_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'home_layout.dart';
import 'model.dart';
import 'markdown_scrollbar.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key, this.chapters}) : super(key: key);

  List<Chapter> chapters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      print(constraints.maxWidth);
      int width = (constraints.maxWidth / 215).toInt();
      return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(SitLocalizations.of(context).title)),
        body: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: max(2, width),
          padding: EdgeInsets.all(5),
          // Generate 100 widgets that display their index in the List.
          children: chapters.map((chapter) {
            print(chapter.image);
            return Center(
                child: Container(
              width: 210,
              height: 210,
              child: ElevatedButton(
                  onPressed: () => {
                        Navigator.push(context, PageRouteBuilder(
                            pageBuilder: (BuildContext context, _, __) {
                          return ChapterPage(chapter: chapter);
                        }))
                      },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(children: [
                      Icon(chapter.image, size: 120),
                      Expanded(
                          child: Text(chapter.title,
                              textAlign: TextAlign.center, style: TextStyle()
                              // style: Theme.of(context).textTheme.headline5,
                              ))
                    ]),
                  )),
            ));
          }).toList(),
        ),
      );
    });
  }
}
