import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:flutter/material.dart';

class EmptyTestScreen extends StatefulWidget {
  EmptyTestScreen({this.string});
  final String? string;
  @override
  _EmptyTestScreenState createState() => _EmptyTestScreenState();
}

class _EmptyTestScreenState extends State<EmptyTestScreen> {
  Widget display = Text("loading");

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      CcApp.of(context)!.dataSource.getWhere("menus", [
        DataFilter("name", Op.equals, "Home"),
      ]);
      CcApp.of(context)!.dataSource.getWhere("menus", [
        DataFilter("appScreenParam", Op.arrayContains, "swipe"),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // testing code here

    return Scaffold(
      body: Center(
        child: Text(widget.string!),
      ),
    );
  }
}
