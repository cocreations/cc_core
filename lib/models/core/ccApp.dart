import 'package:cc_core/models/core/ccAppBuilder.dart';
import 'package:cc_core/utils/parserModule.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/builderWidget.dart';
import 'package:cc_core/config/appConfig.dart';
import 'package:cc_core/models/core/ccAppMenus.dart';
import 'package:cc_core/models/core/ccAppScreen.dart';
import 'package:cc_core/models/core/ccDataConnection.dart';
import 'package:cc_core/models/core/ccStyler.dart';
import 'package:cc_core/models/core/customAppData.dart';
// import 'package:cc_core/models/soundtrails/stApp.dart';
import 'package:cc_core/utils/databaseCache.dart';

/// ## CcApp (CoCreations App) is the top level object of this framework
///
/// The CcApp defines all the information required to instantiate a new "virtual" CoCreations App
class CcApp extends InheritedWidget {
  final String appId;

  /// this is where the app gets things like menu layouts and style data
  final CcDataConnection configSource;

  /// this is where the app gets data that specific screens need, like soundtrails or images
  final CcDataConnection dataSource;
  final DBCache database;
  final Widget child;
  final CcAppMenus menus;
  final CcAppScreen homeScreen;
  final CcStyler styler;
  final CustomAppData appData;
  final ParserModules parserModules;
  /// In seconds
  final int cacheRefresh;

  CcApp({
    Key key,
    @required this.appId,
    @required this.dataSource,
    @required this.configSource,
    @required this.database,
    @required this.child,
    this.styler,
    this.menus,
    this.homeScreen,
    this.appData,
    this.parserModules,
    this.cacheRefresh = 86400,
  })  : assert(appId != null),
        assert(dataSource != null),
        assert(database != null),
        assert(child != null),
        super(key: key, child: child);

  // /// ### Creates a CcApp from json data

  // /// This is never used.
  // ///
  // /// Remove this later

  // /// Expects:
  // /// ```dart
  // ///
  // ///
  // ///    dataId: "menus",
  // ///     dataJson: {
  // ///      menus: {
  // ///        bottom:[
  // ///          {
  // ///          name: "hello world"
  // ///          appScreen: "EmptyTestScreen",
  // ///          appScreenParam: "Hello World"
  // ///          }
  // ///        ],
  // ///        leftSide:[
  // ///          {
  // ///          name: "hello world"
  // ///          appScreen: "EmptyTestScreen",
  // ///          appScreenParam: "Hello World"
  // ///          }
  // ///        ]
  // ///      }
  // ///    }
  // /// ```
  // /// kinda thing, ya know?
  // ///
  // static CcApp createFromJson(Map json, CustomAppData appData) {
  //   return CcApp(
  //     appId: json["dataId"],
  //     dataSource: GetDataSource.getDataSource(ConfigData.configSource),
  //     configSource: GetDataSource.getDataSource(ConfigData.dataSource),
  //     database: DBCache(),
  //     child: BuilderWidget(),
  //     menus: CcAppMenus.createFromJson(json["dataJson"]["menus"]),
  //     homeScreen: CcAppScreen.createFromJson(json["dataJson"]["menus"]["bottom"][0]),
  //     appData: appData,
  //   );
  // }

  static CcAppBuilder buildApp(ConfigData configData) {
    return CcAppBuilder(configData);
  }

  /// loadNewApp()
  ///
  /// This takes the `connection` information and creates the CoCreations App
  ///
  /// In this way the actual app completely changes itself based on just data
  /// that it reads from the data connection source
  loadNewApp() {
    // TODO !
  }

  static CcApp of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CcApp>();
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
}
