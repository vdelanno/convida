import 'package:flutter/material.dart';

class HomeLayout extends StatelessWidget {
  HomeLayout(
      {Key? key,
      required this.title,
      required this.mainView,
      required this.drawer})
      : super(key: key);
  final Widget title;
  final Widget mainView;
  final Widget drawer;
  final ValueNotifier<bool> showDrawer = ValueNotifier<bool>(true);

  Widget buildMainView(BuildContext context, EdgeInsets padding) {
    return Container(
        color: Theme.of(context).highlightColor,
        padding: padding,
        child: Center(child: mainView));
  }

  Widget buildDrawer(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showDrawer,
      builder: (context, value, child) => AnimatedContainer(
          width: value == true ? 300 : 0,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          child: child),
      child: drawer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Widget drawer = buildDrawer(context);
      if (constraints.maxWidth < 800) {
        return Scaffold(
          drawer: Drawer(child: drawer),
          body: buildMainView(context, EdgeInsets.zero),
          appBar: AppBar(title: title),
        );
      } else {
        return Scaffold(
            body: Row(children: [
          drawer,
          Expanded(
              child: Scaffold(
            // drawer: buildDrawer(context),
            appBar: AppBar(
                leading: GestureDetector(
                  child: Icon(Icons.menu),
                  onTap: () => showDrawer.value = !showDrawer.value,
                ),
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: title),
            body: buildMainView(
              context,
              EdgeInsets.fromLTRB(5, 0, 0, 0),
            ),
          ))
        ]));
      }
    });
  }
}
