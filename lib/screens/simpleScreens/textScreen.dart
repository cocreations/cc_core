import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';

class TextScreen extends StatefulWidget {
  TextScreen({this.string});
  final String string;
  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Html(
        data: widget.string,
        style: {"body": Style(textAlign: TextAlign.center)},
      ),
    );
  }
}
