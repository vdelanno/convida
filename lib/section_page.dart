import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'icons_helper.dart';
import 'model.dart';
import 'text_load_layout.dart';

class SectionPage extends StatelessWidget {
  SectionPage({Key key, this.section}) : super(key: key);
  final Section section;

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
      String sectionId = ModalRoute.of(context).settings.name;
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Icon(section.image),
            Container(width: 10),
            Text(section.title)
          ]),
          // actions: [
          //   ValueListenableBuilder(
          //     valueListenable: isPlaying,
          //     builder: (context, value, child) {
          //       if (!value) {
          //         Model.instance().stopAudio();
          //         return FlatButton(
          //           child: Icon(
          //               getIconUsingPrefix(name: "assistiveListeningSystems")),
          //           onPressed: () => isPlaying.value = true,
          //         );
          //       }
          //       print("audio for assets/audios/${section.id}.mp3");
          //       Model.instance().playAudioForSection(section.id);

          //       return FlatButton(
          //         child: Icon(Icons.pause),
          //         onPressed: () => isPlaying.value = false,
          //       );
          //       AudioWidget.assets(
          //         path: "assets/audios/${section.id}.mp3",
          //         child: FlatButton(
          //           child: Icon(Icons.pause),
          //           onPressed: () => isPlaying.value = false,
          //         ),
          //         volume: 100,
          //         play: true,
          //         onReadyToPlay: (duration) {
          //           print("onReadyToPlay");
          //         },
          //         onFinished: () => isPlaying.value = false,
          //         onPositionChanged: (current, duration) {
          //           print("onPositionChanged");
          //         },
          //       );
          //     },
          //   )
          //   //   ElevatedButton(
          //   //       onPressed: () {
          //   //       },
          //   //       child: Icon(Icons.play_arrow))
          // ],
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
