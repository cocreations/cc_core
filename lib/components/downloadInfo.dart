import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';

enum LoadingBarType {
  loadingCircle,
  loadingBar,
  fancyLoadingBar,
}

class DownloadInfo extends StatefulWidget {
  DownloadInfo(
    this.stream,
    this.dataCallback, {
    this.leadingImage,
    this.name,
    this.onChange,
    this.showOnComplete = true,
    this.showOn0Percent = true,
    this.loadingBarType = LoadingBarType.loadingBar,
    this.percentageText = "DOWNLOADING",
    this.overrideColour,
  });

  /// Percentage is between 0 and 1.
  final Stream<double> stream;
  final File? leadingImage;
  final String? name;
  final void Function()? onChange;
  final void Function() dataCallback;
  final bool showOnComplete;
  final bool showOn0Percent;
  final LoadingBarType loadingBarType;

  /// this is the text to show before the percentage, because this is a download bar, it defaults to "DOWNLOADING"
  /// but it could also say "UPDATING", or "FARTING" if you want to get fired
  final String percentageText;

  final Color? overrideColour;

  @override
  _DownloadInfoState createState() => _DownloadInfoState();
}

class _DownloadInfoState extends State<DownloadInfo> {
  double progress = 0;
  double textOpacity = 1;

  Color? barColour;

  late StreamSubscription<double> _streamSubscription;

  bool shouldShow() => ((widget.showOnComplete || progress < 1) && (widget.showOn0Percent || progress > 0));

  void _changeOpacity() {
    if (mounted) setState(() => textOpacity = textOpacity == 1 ? 0.6 : 1);
  }

  double? calculateValue() {
    if (progress == null || (progress.isInfinite || progress.isNaN) || progress > 0) {
      return null;
    }
    return progress;
  }

  @override
  void initState() {
    _streamSubscription = widget.stream.listen((event) {
      if (mounted) {
        if (event >= 1) {
          widget.dataCallback();
        }
        setState(() {
          progress = event;
        });
        if (widget.onChange != null) {
          widget.onChange!();
        }
      }
    });
    super.initState();
    Future.delayed(Duration(milliseconds: 100)).then((value) => _changeOpacity());
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldShow()) {
      return Container();
    }

    if (barColour == null) {
      if (widget.overrideColour != null) {
        barColour = widget.overrideColour;
      } else {
        barColour = CcApp.of(context)!.styler!.accentColor;
      }
    }

    if (widget.loadingBarType == LoadingBarType.loadingBar) {
      return Container(
        height: 15,
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color?>(barColour),
          backgroundColor: barColour!.withOpacity(0.4),
          value: calculateValue(),
        ),
      );
    } else if (widget.loadingBarType == LoadingBarType.fancyLoadingBar) {
      String loadingBarText = "${widget.percentageText} ${(progress * 100).toString().split(".").first}%";
      if (progress == 0) loadingBarText = "LOADING...";

      return Container(
        height: 60,
        child: Row(
          children: [
            widget.leadingImage != null ? Image.file(widget.leadingImage!) : Container(),
            Expanded(
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    minHeight: 60,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    backgroundColor: Colors.white24,
                    value: calculateValue(),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        widget.name != null
                            ? Text(
                                widget.name!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              )
                            : Container(),
                        AnimatedOpacity(
                          duration: Duration(seconds: 1),
                          onEnd: () => _changeOpacity(),
                          curve: Curves.easeInOutSine,
                          opacity: textOpacity,
                          child: Text(
                            loadingBarText,
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Container(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color?>(barColour),
          value: calculateValue(),
        ),
      );
    }
  }
}
