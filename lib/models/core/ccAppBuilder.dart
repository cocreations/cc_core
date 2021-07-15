import 'dart:convert';
import 'dart:io';

import 'package:cc_core/models/core/ccTranslationLayer.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/builderWidget.dart';
import 'package:cc_core/components/leftSideMenu.dart';
import 'package:cc_core/config/appConfig.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:cc_core/models/core/ccDataConnection.dart';
import 'package:cc_core/models/core/ccStyler.dart';
import 'package:cc_core/utils/databaseCache.dart';
import 'package:flutter/services.dart';
import 'ccApp.dart';
import 'ccAppMenus.dart';
import 'ccAppScreen.dart';

class CcAppBuilder extends StatefulWidget {
  CcAppBuilder(this.appConfig);

  final ConfigData appConfig;
  @override
  _CcAppBuilderState createState() => _CcAppBuilderState();
}

class _CcAppBuilderState extends State<CcAppBuilder> {
  DBCache? database;
  bool loaded = false;
  CcAppMenus? menus;
  CcAppScreen? homeScreen;
  CcDataConnection? dataSource;
  CcDataConnection? configSource;
  Map? styleConfigData;
  CcData? data;
  CcStyler? style;

  DrawerType _parseDrawerType(String? string) {
    switch (string) {
      case "appBarBannerAtTop":
        return DrawerType.appBarBannerAtTop;
      case "compendiumStyle":
        return DrawerType.compendiumStyle;
      case "standard":
        return DrawerType.standard;
      default:
        return DrawerType.standard;
    }
  }

  Future<CcStyler> _getStyle() async {
    var styleData = await data!.getDBData("style", configSource!);

    if (styleData == null) return CcStyler();

    styleData = data!.parseStyle(styleData);

    if (styleData["appBarBanner"] != null && styleData["appBarBanner"].startsWith("http")) {
      return CcStyler.buildWithUrls(
        database,
        context,
        fallbackAppBanner: widget.appConfig.appName != null ? widget.appConfig.appName : "App",
        appBarBanner: styleData["appBarBanner"] != null ? styleData["appBarBanner"] : null,
        appBarBackground: styleData["appBarBackground"] != null ? Color(int.parse(styleData["appBarBackground"])) : Colors.blue,
        backgroundColor: styleData["backgroundColor"] != null ? Color(int.parse(styleData["backgroundColor"])) : Colors.white,
        appBarButtonColor: styleData["appBarButtonColor"] != null ? Color(int.parse(styleData["appBarButtonColor"])) : Colors.white,
        primaryColor: styleData["primaryColor"] != null ? Color(int.parse(styleData["primaryColor"])) : Colors.blue,
        accentColor: styleData["accentColor"] != null ? Color(int.parse(styleData["accentColor"])) : Colors.blueAccent,
        sideDrawerType: styleData["sideDrawerType"] != null ? _parseDrawerType(styleData["sideDrawerType"]) : DrawerType.standard,
      );
    } else {
      return CcStyler.buildWithAssets(
        database,
        context,
        fallbackAppBanner: widget.appConfig.appName != null ? widget.appConfig.appName : "App",
        appBarBanner: styleData["appBarBanner"] != null ? styleData["appBarBanner"] : null,
        appBarBackground: styleData["appBarBackground"] != null ? Color(int.parse(styleData["appBarBackground"])) : Colors.blue,
        backgroundColor: styleData["backgroundColor"] != null ? Color(int.parse(styleData["backgroundColor"])) : Colors.white,
        appBarButtonColor: styleData["appBarButtonColor"] != null ? Color(int.parse(styleData["appBarButtonColor"])) : Colors.white,
        primaryColor: styleData["primaryColor"] != null ? Color(int.parse(styleData["primaryColor"])) : Colors.blue,
        accentColor: styleData["accentColor"] != null ? Color(int.parse(styleData["accentColor"])) : Colors.blueAccent,
        sideDrawerType: styleData["sideDrawerType"] != null ? _parseDrawerType(styleData["sideDrawerType"]) : DrawerType.standard,
      );
    }
  }

  Future<CcAppMenus> _getMenus() async {
    if (configSource!.requiresInternet) {
      // if we need internet, just cache the data for later use
      final json = await data!.getDBData("menus", configSource!);

      return CcAppMenus.createFromJson(data!.parseMenus(json ?? {}));
    } else {
      // otherwise, just get it from the local source
      final json = await configSource!.loadData("menus");
      return CcAppMenus.createFromJson(data!.parseMenus(json));
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      if (widget.appConfig.translationLayer != null) {
        String? translationFile;
        try {
          translationFile = await rootBundle.loadString(widget.appConfig.translationLayer!);
        } catch (e) {
          print("TRANSLATION FILE NOT FOUND!!!");
        }

        if (translationFile != null) {
          database = DBCache(
            widget.appConfig.appName,
            widget.appConfig.cacheRefresh * 60,
            TranslationLayer(jsonDecode(translationFile)),
          );
        }
      }
      database ??= DBCache(widget.appConfig.appName, widget.appConfig.cacheRefresh * 60);

      data ??= CcData(database);
      dataSource ??= GetDataSource.getDataSource(widget.appConfig.dataSource!);
      configSource ??= GetDataSource.getDataSource(widget.appConfig.configSource!);

      final List<Future> appData = [
        _getMenus().then((value) => menus = value),
        _getStyle().then((value) => style = value),
      ];

      Future.wait(appData).then((_) => setState(() => loaded = true));
    });
  }

  @override
  Widget build(BuildContext context) {
    // need to make sure we have menus and style data
    if (loaded) {
      return CcApp(
        cacheRefresh: widget.appConfig.cacheRefresh * 60,
        child: MaterialApp(
          theme: ThemeData(
            appBarTheme: AppBarTheme(brightness: Brightness.dark),
            primaryColor: style!.primaryColor,
            accentColor: style!.accentColor,
          ),
          title: widget.appConfig.appName!,
          home: BuilderWidget(),
        ),
        styler: style,
        appId: widget.appConfig.appName!,
        configSource: configSource,
        dataSource: dataSource!,
        database: database!,
        homeScreen: homeScreen,
        menus: menus,
        appData: widget.appConfig.appData,
        parserModules: widget.appConfig.parserModules,
      );
    }
    return Container(
      color: Color.fromARGB(255, 30, 30, 30),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: CircularProgressIndicator(strokeWidth: 5),
        ),
      ),
    );
  }
}
