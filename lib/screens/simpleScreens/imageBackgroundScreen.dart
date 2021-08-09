import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:flutter_html/flutter_html.dart';

class ImageBackgroundScreen extends StatefulWidget {
  ImageBackgroundScreen(this.arg);
  final String? arg;
  @override
  _ImageBackgroundScreenState createState() => _ImageBackgroundScreenState();
}

class _ImageBackgroundScreenState extends State<ImageBackgroundScreen> {
  Widget imageWidget = Center(child: CircularProgressIndicator());
  bool loading = true;
  List<String> args = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      if (widget.arg != null) {
        args = widget.arg!.split(",");

        CcData data = CcData(CcApp.of(context)!.database);

        data.getFile(args.first, "images").then(
              (i) => setState(
                () {
                  loading = false;
                  imageWidget = Image.file(i!);
                },
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      // getting file from the db

    } else {
      loading = true;
    }
    return Scaffold(
      body: Center(
        //Text(widget.string)
        child: Stack(
          children: [
            imageWidget,
            args.length >= 2
                ? Html(
                    data: args[1],
                    style: {"body": Style(textAlign: TextAlign.center)},
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
