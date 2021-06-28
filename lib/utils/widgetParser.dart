import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/screens/listScreens/ListViewScreen.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/screens/emptyTestScreen/emptyImageScreen.dart';
import 'package:cc_core/screens/emptyTestScreen/emptyTestScreen.dart';
import 'package:cc_core/screens/mapScreen/mapScreen.dart';
import 'package:cc_core/screens/simpleScreens/TextScreen.dart';
import 'package:cc_core/screens/settingsScreen/settingsScreen.dart';

class WidgetParser extends StatelessWidget {
  WidgetParser(this.widget, this.arg);
  final String widget;
  final String arg;
  @override
  Widget build(BuildContext context) {
    switch (widget) {
      case "EmptyTestScreen":
        return EmptyTestScreen(string: arg);
      case "EmptyImageScreen":
        return EmptyImageScreen(url: arg);
      case "TextScreen":
        return TextScreen(string: arg);
      case "MapScreen":
        return MapScreen(mbTilesUrl: arg);
      case "ListViewScreen":
        return ListViewScreen(arg);
      case "SettingsScreen":
        return SettingsScreen();
      default:
        if (CcApp.of(context).parserModules != null) {
          var returnWidget = CcApp.of(context).parserModules.parse(widget, arg);
          if (returnWidget != null) {
            return returnWidget;
          }
        }

        return Container(
          child: Center(
            child: Text("Failed to parse '$widget'"),
          ),
        );
    }
  }
}
