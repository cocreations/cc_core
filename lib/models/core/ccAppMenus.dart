import 'package:cc_core/models/core/ccMenuItem.dart';

/// ## CcAppMenus
///
/// These are the different menus available at the top level of a CC App
class CcAppMenus {
  final List<CcMenuItem> bottomMenu;
  final List<CcMenuItem> sideMenu;
  final CcMenuItem homeScreen;

  CcAppMenus({
    this.bottomMenu,
    this.sideMenu,
    this.homeScreen,
  });

  /// ### Creates CcAppMenus from json data

  /// Expects:
  ///
  ///  ```dart
  ///  bottom:[
  ///    {
  ///    name: "hello world"
  ///    appScreen: "EmptyTestScreen",
  ///    appScreenParam: "Hello World"
  ///    }
  ///  ],
  ///  leftSide:[
  ///    {
  ///    name: "hello world"
  ///    appScreen: "EmptyTestScreen",
  ///    appScreenParam: "Hello World"
  ///    }
  ///  ]
  /// ```
  ///
  static CcAppMenus createFromJson(Map json) {
    List<CcMenuItem> bottomMenu = [];
    List<CcMenuItem> sideMenu = [];
    CcMenuItem homeScreen;
    if (json == null) {
      throw Exception("ERROR null was passed instead of Map<String, List>");
    }
    if (json["bottom"] != null) {
      json["bottom"].forEach((item) {
        bottomMenu.add(CcMenuItem.createFromJson(item));
      });
    }
    if (json["leftSide"] != null) {
      json["leftSide"].forEach((item) {
        sideMenu.add(CcMenuItem.createFromJson(item));
      });
    }
    if (json["homeScreen"] != null) {
      homeScreen = CcMenuItem.createFromJson(json["homeScreen"][0]);
    }

    return CcAppMenus(
      bottomMenu: bottomMenu,
      sideMenu: sideMenu,
      homeScreen: homeScreen,
    );
  }
}
