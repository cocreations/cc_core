import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({this.leftSideMenu, this.bottomNavBar, this.child, this.appBarOverride});
  final Widget? leftSideMenu;
  final Widget? bottomNavBar;
  final Widget? child;
  final Widget? appBarOverride;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CcApp.of(context)!.styler!.appBarBanner != null
          ? AppBar(
              title: appBarOverride ?? CcApp.of(context)!.styler!.appBarBanner,
              backgroundColor: CcApp.of(context)!.styler!.appBarBackground,
              brightness: Brightness.dark,
              iconTheme: IconThemeData(color: CcApp.of(context)!.styler!.appBarButtonColor),
              centerTitle: true,
            )
          : null,
      bottomNavigationBar: bottomNavBar,
      drawer: leftSideMenu,
      body: child,
    );
  }
}
