import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'model.dart';
import 'text_load_layout.dart';
import 'about_page.dart';

class SectionPage extends StatelessWidget {
  SectionPage({Key key, this.section})
      : _audioData = rootBundle.load("assets/${section.id}.mp3").then((value) {
          return value.buffer.asUint8List();
        }).catchError((_) {
          return null;
        }),
        super(key: key) {
    _mPlayer.openAudioSession();
  }
  final Section section;
  final FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  final Future<Uint8List> _audioData;

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  Widget qaWidget(BuildContext context, QuestionAnswer qa) {
    return Card(
      margin: EdgeInsets.fromLTRB(5, 10, 5, 0),
      color: Theme.of(context).accentColor,
      child: ExpansionTile(
          backgroundColor: Theme.of(context).accentColor,
          leading: Icon(Icons.question_answer_rounded),
          trailing: FutureBuilder(
            future: _audioData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GestureDetector(
                    child: Icon(Icons.play_arrow),
                    onTap: () {
                      _mPlayer.startPlayer(
                          fromDataBuffer: snapshot.data, codec: Codec.mp3);
                    });
              }
              return Container(
                width: 0,
                height: 0,
              );
            },
          ),
          title: Container(
              child: Text(
            qa.title,
            style: Theme.of(context).accentTextTheme.subtitle1,
          )),
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: MarkdownBody(data: qa.fullText),
              color: Theme.of(context).canvasColor,
            )
          ]),
    );
  }

  Widget buildMainView(BuildContext context) {
    List<Widget> widgets = [];
    if (section.description != null) {
      widgets.add(Container(
          color: Theme.of(context).canvasColor,
          padding: EdgeInsets.fromLTRB(10, 15, 0, 10),
          child: MarkdownBody(data: section.description)));
    }

    List<Widget> sections =
        section.qas.map<Widget>((qa) => qaWidget(context, qa)).toList();
    widgets.add(Container(
        // color: Theme.of(context).highlightColor,
        child: Column(children: sections)));
    return Container(
      constraints: BoxConstraints(minWidth: 300, maxWidth: 800),
      child: Scrollbar(child: ListView(children: widgets)),
    );
  }

  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    return TextLoadLayout(builder: (context, sections) {
      // String sectionId = ModalRoute.of(context).settings.name;
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Icon(section.image),
            Container(width: 10),
            Text(section.title)
          ]),
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
        body: Container(
            color: Theme.of(context).highlightColor,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Center(
              child: buildMainView(context),
            )),
      );
    });
  }
}
