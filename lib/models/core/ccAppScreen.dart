import 'package:flutter/material.dart';

/// ## CcAppScreen
///
/// This class represents a single screen in a CoCreations app
///
/// A CoCreations app is essentially made up of series of screens
/// (as well as menus to access them)
class CcAppScreen {
  final String screenWidgetName;
  final String parameter;

  /// Creates a CoCreations App Screen
  ///
  /// Pass in the screen identifier as a string (must correspond to a screen defined in the widgetParser)
  /// An optional parameter can also be sent to the widget screen
  CcAppScreen({
    @required this.screenWidgetName,
    this.parameter,
  });

  /// ### Creates a CcAppScreen from json data

  /// Expects:
  ///``` dart
  ///
  ///  appScreen: "EmptyTestScreen",
  ///  appScreenParam: "Hello World"
  ///
  /// ```
  CcAppScreen.createFromJson(Map json)
      : this.screenWidgetName = json["appScreen"].toString() ?? null,
        this.parameter = json["appScreenParam"].toString() ?? null;
}
