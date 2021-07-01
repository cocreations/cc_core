import 'package:cc_core/models/core/ccMenuItem.dart';

/// ## CcAppMenus
///
/// These are the different menus available at the top level of a CC App
class CcAppMenus {
  final List<CcMenuItem> bottomMenu;
  final List<CcMenuItem> sideMenu;
  final CcMenuItem homeScreen;
  final CcMenuItem intro;

  CcAppMenus({
    this.bottomMenu,
    this.sideMenu,
    this.homeScreen,
    this.intro,
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
    CcMenuItem intro;
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
    if (json["homeScreen"] != null && json["homeScreen"].isNotEmpty) {
      homeScreen = CcMenuItem.createFromJson(json["homeScreen"][0]);
    }
    if (json["intro"] != null && json["intro"].isNotEmpty) {
      intro = CcMenuItem.createFromJson(json["intro"][0]);
    }

    return CcAppMenus(
      bottomMenu: bottomMenu,
      sideMenu: sideMenu,
      homeScreen: homeScreen,
      intro: intro,
    );
  }
}
