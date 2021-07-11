import 'package:flutter/material.dart';
import 'section_page.dart';
import 'chapter_page.dart';
import 'model.dart';
import 'text_load_layout.dart';

class ConvidaPage extends StatelessWidget {
  ConvidaPage({Key? key, required this.pageId}) : super(key: key) {
    print("ConvidaPage($pageId)");
  }
  final String pageId;

  Widget? getWidget(String id, PageItem current) {
    print("getWidget $id / ${current.id}");
    if (id == current.id) {
      if (current is Chapter) {
        print("build a chapter");
        return ChapterPage(chapter: current);
      } else if (current is Section) {
        print("build a section");
        return SectionPage(section: current);
      }
    }

    if (current is Chapter) {
      for (int i = 0; i < current.pages.length; ++i) {
        Widget? widget = getWidget(id, current.pages[i]);
        if (widget != null) {
          return widget;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    print("ConvidaPage build($pageId)");
    return TextLoadLayout(
      builder: (context, chapter) {
        Widget? widget = getWidget(pageId, chapter);
        if (widget != null) {
          return widget;
        } else {
          widget = getWidget("convida", chapter);
          return widget != null ? widget : Container();
        }
      },
    );
  }
}
