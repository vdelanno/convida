import 'dart:math';

import 'package:convida/model.dart';
import 'package:flutter/material.dart';

class ScrollbarItem {
  ScrollbarItem(this.paint, this.rect);

  final Paint paint;
  final Rect rect;
}

class MyScrollbarPainter extends CustomPainter {
  MyScrollbarPainter({this.model, this.thickness, this.repaintNotifier})
      : super(repaint: repaintNotifier) {
    model.anchors.addListener(() => _updateItems());
  }

  final double thickness;
  final ChangeNotifier repaintNotifier;
  final Model model;
  final List<List<ScrollbarItem>> items = [];

  void _updateItems() {
    if (model.markdownViewkey.currentContext == null) {
      return;
    }

    final Rect widgetRect = getRect(model.markdownViewkey);
    final double sizeFactor = 1 / widgetRect.height;
    List<List<ScrollbarItem>> newItems = [];
    newItems.add(model.highlights
        .map((highlight) => getHighlight(highlight, widgetRect.top, sizeFactor))
        .toList());
    newItems.add(model.headers
        .map((header) => getHeader(header, widgetRect.top, sizeFactor))
        .toList());

    items.clear();
    items.addAll(newItems);

    repaintNotifier.notifyListeners();
  }

  Rect getRect(GlobalKey key) {
    if (key.currentContext == null) {
      return Rect.fromLTRB(0, 0, 0, 0);
    }
    final RenderBox renderObj = key.currentContext.findRenderObject();
    final Offset topLeft = renderObj.localToGlobal(Offset.zero);
    final Size size = renderObj.size;
    return topLeft & size;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect clip = Offset(size.width - (thickness - 5), 0) &
        Size(thickness - 5, size.height);
    items.forEach((layer) {
      canvas.saveLayer(null, Paint()..blendMode = BlendMode.multiply);
      layer.forEach((item) {
        final Rect rect = Rect.fromLTRB(
          clip.left + item.rect.left * clip.width,
          item.rect.top * clip.height,
          clip.left + item.rect.right * clip.width,
          item.rect.bottom * clip.height,
        );
        canvas.drawRect(rect, item.paint);
      });
      // canvas.restore();
    });
    items.forEach((layer) {
      canvas.restore();
    });
  }

  ScrollbarItem getHeader(Anchor header, double top, double sizeFactor) {
    int headerLevel =
        header.text.substring(0, header.text.indexOf(" ")).split(".").length;

    final Rect headerRect = getRect(header.key);
    double xOffset = (headerLevel - 1) / 10.0;
    final Rect headerBound = Rect.fromLTRB(
        xOffset,
        (headerRect.top - top) * sizeFactor,
        1.0,
        (headerRect.bottom - top) * sizeFactor);

    int colValue = min((headerLevel - 1) * 30, 255);
    return ScrollbarItem(
      Paint()..color = Color.fromARGB(255, colValue, colValue, colValue),
      headerBound,
    );
  }

  ScrollbarItem getHighlight(Anchor highlight, double top, double sizeFactor) {
    final Rect highlightRect = getRect(highlight.key);
    final Rect highlightBound = Rect.fromLTRB(
        0,
        (highlightRect.top - top) * sizeFactor,
        1.0,
        (highlightRect.bottom - top) * sizeFactor);

    return ScrollbarItem(Paint()..color = Colors.yellow, highlightBound);
  }

  //5
  @override
  bool shouldRepaint(MyScrollbarPainter oldDelegate) {
    return true;
  }
}

class MarkdownScrollBar extends StatelessWidget {
  MarkdownScrollBar(
      {Key key, this.thickness, this.model, this.controller, this.child})
      : super(key: key);

  final Model model;
  final double thickness;
  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        foregroundPainter: MyScrollbarPainter(
          thickness: thickness,
          model: model,
          repaintNotifier: ChangeNotifier(),
        ),
        child: Scrollbar(
            thickness: thickness,
            isAlwaysShown: true,
            controller: controller,
            child: Row(children: [
              Expanded(child: child),
              Container(width: thickness)
            ])));
  }
}
