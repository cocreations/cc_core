import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({this.leftSideMenu, this.bottomNavBar, this.child});
  final Widget? leftSideMenu;
  final Widget? bottomNavBar;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CcApp.of(context)!.styler!.appBarBanner,
        backgroundColor: CcApp.of(context)!.styler!.appBarBackground,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: CcApp.of(context)!.styler!.appBarButtonColor),
        centerTitle: true,
      ),
      bottomNavigationBar: bottomNavBar,
      drawer: leftSideMenu,
      body: child,
    );
  }
}
