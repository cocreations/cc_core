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
  Widget build(BuildContext context) {
    // testing code here

    return Scaffold(
      body: Center(
        child: Text(widget.string!),
      ),
    );
  }
}
