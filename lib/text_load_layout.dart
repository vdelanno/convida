import 'package:convida/sit_localizations.dart';
import 'package:flutter/cupertino.dart';

import 'loading_page.dart';
import 'model.dart';

typedef AsyncWidgetBuilder<T> = Widget Function(
    BuildContext context, Chapter chapter);

class TextLoadLayout extends StatelessWidget {
  TextLoadLayout({@required this.builder});
  final AsyncWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
          future: Model.instance().home,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return builder(context, snapshot.data);
            }
            return LoadingPage(
              title: SitLocalizations.of(context).title,
            );
          }),
    );
  }
}
