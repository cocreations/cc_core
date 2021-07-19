import 'dart:io';

import 'package:cc_core/components/audioWidget.dart';
import 'package:cc_core/models/core/audioItem.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

enum PlayerType { large, small, buttonOnly }

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen(this.args, this.playerType, {Key? key}) : super(key: key);

  final String? args;
  final PlayerType playerType;

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  String title = "";
  File? image;
  AudioItem? audioItem;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) async {
      List<String> args = widget.args!.split(",");

      // I wanted to use a switch case with no break here, but dart wouldn't let me :(
      if (args.length >= 3 && args[2] != null && args[2].isNotEmpty) image = await CcData(CcApp.of(context)!.database).getFile(args[2], "${CcApp.of(context)!.appId}Audio");
      if (args.length >= 2 && args[1] != null && args[1].isNotEmpty) title = args[1];
      if (args[0].isNotEmpty) {
        audioItem = await CcData(CcApp.of(context)!.database).getFile(args[0], "${CcApp.of(context)!.appId}Audio").then((file) {
          return AudioItem.buildFromFile(file);
        });
      } else {
        audioItem = await AudioItem.buildFromFile(null);
      }

      if (mounted) setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Container(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CcApp.of(context)!.styler!.primaryColor)),
        ),
      );
    }

    switch (widget.playerType) {
      case PlayerType.large:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 35),
              child: image != null ? Image.file(image!) : Container(),
            ),
            Html(
              data: title,
              shrinkWrap: true,
              style: {"body": Style(fontSize: FontSize.large)},
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: AudioWidget(
                audioItem: audioItem,
              ),
            )
          ],
        );
      case PlayerType.small:
        return AudioWidget(
          imageFile: image,
          audioItem: audioItem,
          name: title,
        );
      case PlayerType.buttonOnly:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 35),
              child: image != null ? Image.file(image!) : Container(),
            ),
            Html(
              data: title,
              shrinkWrap: true,
              style: {"body": Style(fontSize: FontSize.large)},
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: AudioWidget(
                playButtonSize: 38,
                onlyButton: true,
                audioItem: audioItem,
              ),
            )
          ],
        );
    }

    return Center(
      child: Text("Something went wrong  * ﹏ * "),
    );
  }
}
