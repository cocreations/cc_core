import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';

class EmptyImageScreen extends StatefulWidget {
  EmptyImageScreen({this.url});
  final String? url;
  @override
  _EmptyImageScreenState createState() => _EmptyImageScreenState();
}

class _EmptyImageScreenState extends State<EmptyImageScreen> {
  Widget imageWidget = Center(child: CircularProgressIndicator());
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // getting file from the db
      CcData data = CcData(CcApp.of(context)!.database);
      data.getFile(widget.url, "images").then(
            (i) => setState(
              () {
                loading = false;
                imageWidget = Image.file(i!);
              },
            ),
          );
    } else {
      loading = true;
    }
    return Scaffold(
      body: Center(
        //Text(widget.string)
        child: imageWidget,
      ),
    );
  }
}
