import 'package:convida/model.dart';
import 'package:flutter/material.dart';

class ScrollbarItem {
  ScrollbarItem(this.paint, this.rect);

  final Paint paint;
  final Rect rect;
}

class MyScrollbarPainter extends CustomPainter {
  MyScrollbarPainter({this.model, this.repaintNotifier})
      : super(repaint: repaintNotifier) {
    model.anchors.addListener(() => _updateItems());
  }

  final ChangeNotifier repaintNotifier;
  final Model model;
  final List<ScrollbarItem> items = <ScrollbarItem>[];

  void _updateItems() {
    if (model.markdownViewkey.currentContext == null) {
      return;
    }

    final Rect widgetRect = getRect(model.markdownViewkey);
    final double sizeFactor = 1 / widgetRect.height;
    List<ScrollbarItem> newItems = [];
    model.highlights.forEach((highlight) {
      newItems.add(getHighlight(highlight, widgetRect.top, sizeFactor));
    });
    model.headers.forEach((header) {
      newItems.add(getHeader(header, widgetRect.top, sizeFactor));
    });

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
    items.forEach((item) {
      final Rect rect = Rect.fromLTRB(
        item.rect.left * size.width,
        item.rect.top * size.height,
        item.rect.right * size.width,
        item.rect.bottom * size.height,
      );
      canvas.drawRect(rect, item.paint);
    });
  }

  ScrollbarItem getHeader(Anchor header, double top, double sizeFactor) {
    final List<Paint> paints = [
      Paint()
        ..color = Color.fromARGB(128, 0, 0, 0)
        ..strokeWidth = 3.0,
      Paint()
        ..color = Color.fromARGB(128, 50, 50, 50)
        ..strokeWidth = 2.0,
      Paint()
        ..color = Color.fromARGB(128, 128, 128, 128)
        ..strokeWidth = 1.0
    ];
    int headerLevel =
        header.text.substring(0, header.text.indexOf(" ")).split(".").length;

    final Rect headerRect = getRect(header.key);
    double xOffset = (headerLevel - 1) / 10.0;
    final Rect headerBound = Rect.fromLTRB(
        xOffset,
        (headerRect.top - top) * sizeFactor,
        1.0,
        (headerRect.bottom - top) * sizeFactor);

    return ScrollbarItem(
      paints[headerLevel - 1],
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
  MarkdownScrollBar({Key key, this.model, this.controller}) : super(key: key);

  final Model model;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomPaint(
        painter:
            MyScrollbarPainter(model: model, repaintNotifier: ChangeNotifier()),
        child: Container(),
      ),
      onTapUp: (TapUpDetails details) {
        double targetHeight = controller.position.maxScrollExtent;
        double widgetHeight = context.size.height;
        controller.position.animateTo(
            (details.localPosition.dy / widgetHeight) * targetHeight,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic);
      },
    );
  }
}
