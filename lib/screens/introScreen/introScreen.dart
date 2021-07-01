import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccAppScreen.dart';
import 'package:cc_core/screens/introScreen/SwipeScreen.dart';
import 'package:cc_core/utils/widgetParser.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen(this.screen, {Key key}) : super(key: key);

  final CcAppScreen screen;

  @override
  Widget build(BuildContext context) {
    if (screen.screenWidgetName == "SwipeableIntroScreen") return SwipeScreen(screen.parameter, shouldHavePopButton: true);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Material(child: WidgetParser(screen.screenWidgetName, screen.parameter)),
        Container(
          margin: EdgeInsets.only(bottom: 30),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Ok"),
            style: ElevatedButton.styleFrom(primary: CcApp.of(context).styler.primaryColor),
          ),
        ),
      ],
    );
  }
}
