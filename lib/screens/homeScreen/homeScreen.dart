import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({this.leftSideMenu, this.bottomNavBar, this.child});
  final Widget leftSideMenu;
  final Widget bottomNavBar;
  final Widget child;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CcApp.of(context).styler.appBarBanner,
        backgroundColor: CcApp.of(context).styler.appBarBackground,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(color: CcApp.of(context).styler.appBarButtonColor),
        centerTitle: true,
      ),
      bottomNavigationBar: widget.bottomNavBar,
      drawer: widget.leftSideMenu,
      body: widget.child,
    );
  }
}
