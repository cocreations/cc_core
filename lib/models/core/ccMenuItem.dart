import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccAppScreen.dart';

/// ## CcMenuItem
///
/// This class represents a menu item in a menu
///
/// It defines the title of the menu item, the optional icon, and the screen it should open
class CcMenuItem {
  final String id;
  final String title;
  final CcAppScreen screen;
  final Icon? icon;

  /// optional

  /// Creates a CcMenuItem
  ///
  /// Pass in the screen identifier as a string (must correspond to a screen defined in the widgetParser)
  /// An optional parameter can also be sent to the widget screen
  CcMenuItem({
    required this.id,
    required this.title,
    required this.screen,
    this.icon,
  });

  /// ### Creates a CcMenuItem from json data
  ///
  /// Expects:
  /// ```dart
  ///  name: "hello world"
  ///  appScreen: "EmptyTestScreen",
  ///  appScreenParam: "Hello World"
  ///
  ///```
  //TODO: make this static and throw if id, title, or screen is null
  static CcMenuItem createFromJson(Map json) {
    String id = json["id"].toString();
    String title = json["name"].toString();
    CcAppScreen screen = CcAppScreen.createFromJson(json);
    Icon? icon;
    if (json["icon"] != null) {
      try {
        icon = Icon(IconData(int.parse(json["icon"]), fontFamily: "MaterialIcons"));
      } catch (e) {}
    }
    return CcMenuItem(id: id, title: title, screen: screen, icon: icon);
  }
}
