import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'icons_helper.dart';

class Anchor {
  Anchor(this.text, this.key);
  final String text;
  final GlobalKey key;
}

enum AnchorType { HIGHLIGHT, HEADER }

class QuestionAnswer {
  QuestionAnswer({@required this.title, @required this.fullText});
  final String title;
  final String fullText;

  Map toDict() {
    return {"title": title, "fullText": fullText};
  }
}

class PageItem {
  PageItem({
    @required this.id,
    @required this.title,
    @required this.image,
  });
  final String id;
  final String title;
  final IconData image;

  Map toDict() {
    print("page item todict $id $title");
    return {
      "id": this.id,
      "title": this.title,
    };
  }
}

class Chapter extends PageItem {
  Chapter(
      {@required String id,
      @required String title,
      @required IconData image,
      @required this.pages})
      : super(id: id, title: title, image: image);
  final List<PageItem> pages;

  Map toDict() {
    print("chapter todict ${pages.length}");
    Map map = super.toDict();
    print("chapter todict $map");
    map["pages"] = pages.map((page) => page.toDict()).toList();
    return map;
  }
}

class Section extends PageItem {
  Section(
      {@required String id,
      @required String title,
      @required IconData image,
      @required this.description,
      @required this.qas})
      : super(id: id, title: title, image: image);

  final String description;
  final List<QuestionAnswer> qas;

  Map toDict() {
    Map map = super.toDict();
    map["description"] = description;
    map["qas"] = this.qas.map((qa) => qa.toDict());
    return map;
  }
}

class Model {
  static Model _instance = Model._();

  Future<Chapter> _home;
  Future<Chapter> get home => _home;
  AssetsAudioPlayer get _assetsAudioPlayer =>
      AssetsAudioPlayer.withId("convida");

  Model._() {
    _assetsAudioPlayer.audioSessionId.listen((event) => print("asdfasdf"));
    _assetsAudioPlayer.onReadyToPlay
        .listen((audio) => print("ready to play $audio"));
    _assetsAudioPlayer.audioSessionId.listen((sessionId) {
      print("audioSessionId : $sessionId");
    });
    _assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print("playlistAudioFinished : $data");
    });
    _assetsAudioPlayer.onErrorDo = (error) {
      print(error.error.message);
      error.player.stop();
    };
    AssetsAudioPlayer.addNotificationOpenAction((notification) {
      return false;
    });
    _home = _loadText().then((home) {
      return home;
      print("loading audio");
      // List<Audio> audios = home.Sections.map<Audio>((Section) {
      //   String path = "assets/assets/${Section.id}.mp3";

      //   print("loading $path");
      //   return Audio(
      //     path,
      //     metas: Metas(
      //       id: Section.id,
      //       title: Section.description,
      //       artist: "COnVIDa",
      //     ),
      //   );
      // }).toList();
      // return _assetsAudioPlayer.open(Playlist(audios: audios)).then((_) {
      //   print("model fully initialied, nbSections: ${home.Sections.length}");
      //   return home;
      // });
    });
  }
  void _onError(ErrorHandler err) {
    print(err);
  }

  factory Model.instance() {
    return _instance;
  }

  Future<void> playAudioForSection(String sectionId) async {
    print("will play audio for $sectionId");
    // _Sections.then((cs) {
    //   int index = cs.indexWhere((Section) => Section.id == SectionId);
    //   if (index != -1) {
    //     print("will play audio at index $index");
    //     String asset = "assets/$SectionId.mp3";
    //     rootBundle.load(asset).then((bytes) {
    //       print("audioFile $asset is ${bytes.lengthInBytes} long");
    //     });

    //     _assetsAudioPlayer
    //         .playlistPlayAtIndex(index)
    //         .then((_) => _assetsAudioPlayer.play());
    //   }
    // });
  }

  void stopAudio() {
    _assetsAudioPlayer.pause();
  }

  QuestionAnswer _getQuestionAnswer(String text) {
    int titleEnd = text.indexOf("\n");
    String title = text.substring(0, titleEnd).trim();
    String fullText = text.substring(titleEnd, text.length).trim();
    return QuestionAnswer(title: title, fullText: fullText);
  }

  Section _getSection(
      String title, String fullText, String image, String id, int level) {
    print("_getSection: $title");
    fullText = fullText.trim();
    String description;
    if (!fullText.startsWith('¿')) {
      int descriptionLength = fullText.indexOf("¿");
      if (descriptionLength == -1) {
        description = fullText;
        fullText = "";
      } else {
        description = fullText.substring(0, descriptionLength).trim();
        fullText =
            fullText.substring(descriptionLength, fullText.length).trim();
      }
    }

    List<QuestionAnswer> sections = fullText
        .split(new RegExp(r"^¿", multiLine: true))
        .map<QuestionAnswer>((section) {
          if (section.isEmpty) {
            return null;
          }
          return _getQuestionAnswer(section);
        })
        .where((section) => section != null)
        .toList();

    Section section = Section(
        id: id,
        title: title,
        description: description,
        image: getIconUsingPrefix(name: image),
        qas: sections);

    return section;
  }

  PageItem _parsePage(String text, int level) {
    int headerEnd = text.indexOf("\n");
    String header = text.substring(0, headerEnd).trim();
    String fullText = text.substring(headerEnd, text.length).trim();
    RegExp exp = new RegExp(r"^\[(.*)\:(.*)\]\s*(.*)");
    RegExpMatch match = exp.firstMatch(header);

    String title = match.group(3);
    String image = match.group(2);
    String id = match.group(1);

    int childLevel = level + 1;
    String childRegex = "^" + "#" * childLevel + " ";

    print("_parsePage $title $level '$childRegex'");
    if (fullText.contains(new RegExp(childRegex, multiLine: true))) {
      return _getChapter(title, fullText, image, id, childLevel);
    } else {
      return _getSection(title, fullText, image, id, level);
    }
  }

  Chapter _getChapter(
      String title, String fullText, String image, String id, int level) {
    String regex = "^" + "\\#" * level + " ";
    print("_getChapter " + title);
    List<PageItem> pages = fullText
        .split(new RegExp(regex, multiLine: true))
        .map<PageItem>((text) {
          if (text.isEmpty) {
            return null;
          }
          PageItem child = _parsePage(text, level);
          if (child == null) {
            print("CHILD IS NULL");
          }
          return child;
        })
        .where((page) => page != null)
        .toList();
    return Chapter(
        id: id,
        title: title,
        image: getIconUsingPrefix(name: image),
        pages: pages);
  }

  Future<Chapter> _loadText() async {
    print("loading text");
    String locale = Intl.shortLocale(Intl.defaultLocale);

    return rootBundle.load("assets/txt-$locale.md").then((bytes) {
      String newText = utf8.decode(bytes.buffer.asUint8List());
      Chapter chapter =
          _getChapter("convida", newText, "convida", "convida", 1);
      return chapter;
    });
  }
}
