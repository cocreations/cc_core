import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:cc_core/components/leftSideMenu.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:cc_core/utils/databaseCache.dart';

class CcStyler {
  CcStyler({
    this.appBarBackground = Colors.blue,
    this.appBarBanner,
    this.backgroundColor = Colors.white,
    this.appBarButtonColor = Colors.white,
    this.primaryColor = Colors.blue,
    this.accentColor = Colors.blueAccent,
    this.sideDrawerType = DrawerType.standard,
  });
  final Color appBarBackground;
  final Widget? appBarBanner;
  final Color backgroundColor;
  final Color appBarButtonColor;
  final Color primaryColor;
  final Color accentColor;
  final DrawerType sideDrawerType;

  @override
  String toString() {
    return "{appBarBackground:$appBarBackground, backgroundColor:$backgroundColor, appBarButtonColor:$appBarButtonColor, primaryColor:$primaryColor, accentColor:$accentColor, sideDrawerType:$sideDrawerType}";
  }

  /// A static method that takes image assets and turns them into a CcStyler
  static CcStyler buildWithAssets({
    bool hasAppBar = true,
    String? fallbackAppBanner = "App",
    Color appBarBackground = Colors.blue,
    String? appBarBanner,
    Color backgroundColor = Colors.white,
    Color appBarButtonColor = Colors.white,
    Color primaryColor = Colors.blue,
    Color accentColor = Colors.blueAccent,
    DrawerType sideDrawerType = DrawerType.standard,
  }) {
    List<Widget> widgets = [];

    if (appBarBanner != null) {
      widgets.insert(0, Image.asset(appBarBanner, width: 200));
    } else {
      widgets.insert(0, Text(fallbackAppBanner!));
    }

    return CcStyler(
      appBarBackground: appBarBackground,
      appBarBanner: hasAppBar ? widgets[0] : null,
      backgroundColor: backgroundColor,
      appBarButtonColor: appBarButtonColor,
      primaryColor: primaryColor,
      accentColor: accentColor,
      sideDrawerType: sideDrawerType,
    );
  }

  /// A static method that takes image urls and turns them into a CcStyler
  static Future<CcStyler> buildWithUrls(
    DBCache database,
    BuildContext context, {
    bool hasAppBar = true,
    String? fallbackAppBanner = "App",
    Color appBarBackground = Colors.blue,
    String? appBarBanner,
    Color backgroundColor = Colors.white,
    Color appBarButtonColor = Colors.white,
    Color primaryColor = Colors.blue,
    Color accentColor = Colors.blueAccent,
    DrawerType sideDrawerType = DrawerType.standard,
  }) async {
    List<int> fileIds = [];
    List<String> urls = [];
    List<Widget> widgets = [];
    if (appBarBanner != null) {
      urls.add(appBarBanner);
      fileIds.add(0);
    }
    List<File?> files = await CcData(database).getFiles(urls, "style", context);

    if (files[fileIds.indexOf(0)] != null) {
      widgets.insert(fileIds.indexOf(0), Image.file(files[fileIds.indexOf(0)]!, width: 200));
    } else {
      widgets.insert(fileIds.indexOf(0), Text(fallbackAppBanner!));
    }

    return CcStyler(
      appBarBackground: appBarBackground,
      appBarBanner: hasAppBar ? widgets[fileIds.indexOf(0)] : null,
      backgroundColor: backgroundColor,
      appBarButtonColor: appBarButtonColor,
      primaryColor: primaryColor,
      accentColor: accentColor,
      sideDrawerType: sideDrawerType,
    );
  }
}
