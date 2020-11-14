import 'package:convida/sit_localizations.dart';
import 'package:flutter/cupertino.dart';

import 'loading_page.dart';
import 'model.dart';

typedef AsyncWidgetBuilder<T> = Widget Function(
    BuildContext context, List<Chapter> chapters);

class TextLoadLayout extends StatelessWidget {
  TextLoadLayout({@required this.builder});
  final AsyncWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Model.chapters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return builder(context, snapshot.data);
          }
          return LoadingPage(
            title: SitLocalizations.of(context).title,
          );
        });
  }
}
