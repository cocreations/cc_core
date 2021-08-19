import 'dart:async';
import 'dart:convert';

import 'package:cc_core/models/core/builderWidgetController.dart';
import 'package:cc_core/screens/introScreen/introScreen.dart';
import 'package:cc_core/utils/parserModule.dart';
import 'package:flutter/material.dart';

import 'package:cc_core/components/bottomMenu.dart';
import 'package:cc_core/components/leftSideMenu.dart';
import 'package:cc_core/screens/homeScreen/homeScreen.dart';
import 'package:cc_core/utils/widgetParser.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccAppMenus.dart';
import 'package:cc_core/models/core/ccMenuItem.dart';

class BuilderWidget extends StatefulWidget {
  BuilderWidget({this.controller});

  final BuilderWidgetController? controller;
  @override
  _BuilderWidgetState createState() => _BuilderWidgetState();
}

class _BuilderWidgetState extends State<BuilderWidget> {
  StreamSubscription<BuilderPacket>? controller;

  @override
  void dispose() {
    if (controller != null) controller!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      controller = widget.controller!.updateStream.stream.listen((event) {
        _onControllerEvent(event);
      });
    }
    Future.delayed(Duration.zero).then((_) async {
      var shownIntro = await CcApp.of(context)!.database.loadSingleEntry("0", "_appData");

      if (shownIntro != null) shownIntro = jsonDecode(shownIntro["dataJson"]);

      if (shownIntro == null || shownIntro["shownIntro"] == null || shownIntro["shownIntro"] == "false") {
        CcApp.of(context)!.database.saveDataToCache("_appData", "0", jsonEncode({"shownIntro": "true"}));
        if (CcApp.of(context)!.menus!.intro != null) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => IntroScreen(CcApp.of(context)!.menus!.intro!.screen),
              ),
            );
          }
        }
      }
    });
  }

  void _onControllerEvent(BuilderPacket event) {
    switch (event.command) {
      case Command.display:
        showWidget(event.widget!, event.arg);
        break;
      case Command.showIntro:
        if (CcApp.of(context)!.menus!.intro != null) {
          if (mounted) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => IntroScreen(CcApp.of(context)!.menus!.intro!.screen),
              ),
            );
          }
        }
        break;
      case Command.updateAppBar:
        if (mounted) {
          setState(() {
            appBarOverride = event.arg;
          });
        }
        break;
    }
  }

  /// ontap for keeping track of the bottom menu
  void _ontap(CcMenuItem i) {
    setState(() {
      display = WidgetParser(i.screen.screenWidgetName, i.screen.parameter);
    });
  }

  /// parses a widget then displays it
  void showWidget(String appScreen, String? appScreenParam) {
    setState(() {
      display = WidgetParser(appScreen, appScreenParam);
    });
  }

  /// the widget to show when the app is first launched
  Widget homeScreen = Container();

  /// the widget currently being shown
  Widget? display;

  /// the thing BuilderWidget returns
  Widget returnWidget = Container();

  /// the bottom bar widget if there is one
  Widget? bottomMenu;

  /// the screens that the bottom menu buttons point to
  List<Widget> bottomMenuScreens = [];

  /// the left side menu if there is one
  Widget? leftSideMenu;

  /// all the menus and stuff
  CcAppMenus? menus;

  /// Overrides the default app bar so it can be changed on the fly
  String? appBarOverride;

  /// duh
  List<BottomNavigationBarItem> bottomMenuItems = [];

  @override
  Widget build(BuildContext context) {
    // getting data
    if (menus == null) {
      setState(() {
        menus = CcApp.of(context)!.menus;
      });
    }
    // data has been got so display it
    if (menus != null) {
      // hey theres a bottom menu so lets display that
      if (menus != null && menus!.bottomMenu != null && menus!.bottomMenu!.length >= 2) {
        if (bottomMenuItems.isEmpty) {
          bottomMenu = BottomMenu(menus, _ontap);
        }
      }
      if (menus!.sideMenu != null) {
        leftSideMenu = LeftSideMenu(menus, showWidget);
      }
      if (menus!.homeScreen != null && display == null) {
        homeScreen = WidgetParser(
          menus!.homeScreen!.screen.screenWidgetName,
          menus!.homeScreen!.screen.parameter,
        );
        showWidget(
          menus!.homeScreen!.screen.screenWidgetName,
          menus!.homeScreen!.screen.parameter,
        );
      }
      returnWidget = HomeScreen(
        child: display,
        bottomNavBar: bottomMenu,
        leftSideMenu: leftSideMenu,
        appBarOverride: appBarOverride != null ? Text(appBarOverride!) : null,
      );
    }
    return returnWidget;
  }
}
