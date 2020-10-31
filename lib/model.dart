import 'package:flutter/widgets.dart';

class Anchor {
  Anchor(this.text, this.key);
  final String text;
  final GlobalKey key;
}

enum AnchorType { HIGHLIGHT, HEADER }

class Model {
  Model({String text = ""}) {
    this.text.value = text;
  }

  final GlobalKey markdownViewkey = GlobalKey();
  final ValueNotifier<String> text = ValueNotifier<String>("");
  final ValueNotifier<Map<AnchorType, List<Anchor>>> anchors =
      ValueNotifier<Map<AnchorType, List<Anchor>>>(
          Map<AnchorType, List<Anchor>>());

  List<Anchor> get highlights {
    final List<Anchor> highlights =
        anchors.value.putIfAbsent(AnchorType.HIGHLIGHT, () => []);
    return highlights;
  }

  List<Anchor> get headers {
    final List<Anchor> headers =
        anchors.value.putIfAbsent(AnchorType.HEADER, () => []);
    return headers;
  }
}
