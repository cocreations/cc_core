import 'package:cc_core/utils/textUtils.dart';
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
  List<String> args = [];

  BoxFit imageFit = BoxFit.contain;

  void parseOptionalArg(String arg) {
    List<String> kv = arg.split(":");

    switch (kv.first) {
      case "imageFit":
        // i don't need to add a kv.last == "contain" because it's already the default
        if (kv.last == "crop") {
          imageFit = BoxFit.cover;
        } else if (kv.last == "stretch") {
          imageFit = BoxFit.fill;
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      if (widget.arg != null) {
        args = TextUtils.parseParam(widget.arg);

        print("ImageBackgroundScreen = $args");

        CcData data = CcData(CcApp.of(context)!.database);

        // need to run through all the other optional arguments
        if (args.length > 2) {
          for (var i = 2; i < args.length; i++) {
            if (args[i].contains(":")) {
              parseOptionalArg(args[i]);
            }
          }
        }

        data.getFile(args.first, "images").then((i) {
          setState(() {
            imageWidget = Image.file(
              i!,
              fit: imageFit,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            );
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //Text(widget.string)
        child: Stack(
          alignment: Alignment.center,
          children: [
            imageWidget,
            args.length >= 2
                ? SingleChildScrollView(
                    child: Html(
                      data: args[1],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
