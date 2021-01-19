import 'dart:math';

import 'package:convida/section_page.dart';
import 'package:convida/search_page.dart';
import 'package:convida/sit_localizations.dart';
import 'package:convida/text_load_layout.dart';
import 'package:flutter/material.dart';
import 'about_page.dart';
import 'model.dart';

class ChapterPage extends StatelessWidget {
  ChapterPage({Key key, this.chapter}) : super(key: key);
  final Chapter chapter;

  String sectionUrl(PageItem page) {
    return "/${page.id}";
  }

  Widget sectionWidget(BuildContext context, PageItem page) {
    return Center(
        child: Container(
      width: 210,
      height: 210,
      child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, "/${page.id}",
              arguments: {Section: Section}),
          child: Container(
            padding: EdgeInsets.all(15),
            child: Column(children: [
              Icon(page.image, size: 120),
              Expanded(
                  child: Text(page.title,
                      textAlign: TextAlign.center, style: TextStyle()
                      // style: Theme.of(context).textTheme.headline5,
                      ))
            ]),
          )),
    ));
  }

  @override
  Widget build(BuildContext context) {
    print("building chapter page");
    return LayoutBuilder(builder: (context, constraints) {
      int width = constraints.maxWidth ~/ 215;
      return Scaffold(
        appBar: AppBar(
          title: Text(SitLocalizations.of(context).title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'About',
              onPressed: () {
                Navigator.pushNamed(context, AboutPage.route);
              },
            ),
          ],
        ),
        body: GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: max(2, width),
          padding: EdgeInsets.all(5),
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          // Generate 100 widgets that display their index in the List.
          children: chapter.pages
              .map((page) => sectionWidget(context, page))
              .toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, SearchPage.route);
          },
          tooltip: 'search',
          child: const Icon(Icons.search),
        ),
      );
    });
  }
}
