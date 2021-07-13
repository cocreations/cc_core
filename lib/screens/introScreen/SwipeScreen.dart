import 'dart:convert';

import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:cc_core/utils/widgetParser.dart';
import 'package:flutter/material.dart';

class SwipeScreen extends StatefulWidget {
  SwipeScreen(this.arg, {this.shouldHavePopButton = false});
  final String? arg;
  final bool shouldHavePopButton;

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  int currentPage = 0;
  double _dragStartLocation = 0;
  bool loading = true;

  String endButtonText = "Ok";

  List<Widget> pages = [];

  List<bool> canScrollPast = [];

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;

  final ScrollController _controller = ScrollController();

  Widget buildDots() {
    List<Widget> dots = [];

    if (pages != null) {
      for (var i = 0; i < pages.length; i++) {
        if (i == currentPage) {
          dots.add(
            Container(
              width: 10,
              height: 10,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade400.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: Colors.black26, style: BorderStyle.solid, width: 9),
                shape: BoxShape.circle,
              ),
            ),
          );
        } else {
          dots.add(
            Container(
              color: Colors.transparent,
              width: 10,
              height: 10,
              margin: EdgeInsets.symmetric(horizontal: 5),
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade400.withOpacity(0.4),
              ),
            ),
          );
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.fromLTRB(1, 3, 1, 3),
      margin: EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: dots,
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Duration getAnimationDuration(double? dx) {
    if (dx == 0.0) {
      return Duration(milliseconds: 500);
    }
    if (dx! < 0) {
      return Duration(milliseconds: (1000000 / (dx * -1)).round().clamp(150, 500));
    }

    return Duration(milliseconds: (100000 / dx).round().clamp(150, 500));
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((_) {
      List<String> args = widget.arg!.split(",");
      if (args.first.isEmpty) return;
      if (args.length >= 2) endButtonText = args[1];
      CcData(CcApp.of(context)!.database).getDBData(args.first, CcApp.of(context)!.dataSource).then((dbData) {
        List vals = List.from(dbData!.values);
        pages = [];
        for (var val in vals) {
          val = jsonDecode(val["dataJson"]);
          pages.add(
            Container(
              width: MediaQuery.of(context).size.width,
              child: Material(child: WidgetParser(val["appScreen"], val["appScreenParam"])),
            ),
          );
        }

        if (widget.shouldHavePopButton) {
          pages.last = Stack(
            alignment: Alignment.bottomCenter,
            children: [
              pages.last,
              Container(
                margin: EdgeInsets.only(bottom: 35),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(endButtonText),
                  style: ElevatedButton.styleFrom(primary: CcApp.of(context)!.styler!.primaryColor),
                ),
              ),
            ],
          );
        }

        if (mounted) {
          setState(() => loading = false);
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (pages.isEmpty && pages.isNotEmpty) {
      pages.forEach((element) {
        pages.add(Container(
          width: screenWidth,
          height: screenHeight,
          child: element,
        ));
      });
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Material(
        child: Center(
          child: Container(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(CcApp.of(context)!.styler!.primaryColor)),
          ),
        ),
      );
    }

    if (widget.arg!.split(",").first.isEmpty) {
      return Center(
        child: Text("No arguments were supplied.\nPlease read appScreens.md for more info."),
      );
    }

    return GestureDetector(
      onHorizontalDragStart: (details) => _dragStartLocation = _controller.offset,
      onHorizontalDragUpdate: (details) {
        if (details.primaryDelta != null) {
          if (_controller.offset - details.primaryDelta! < 0) {
            _controller.jumpTo(0);
          } else if (_controller.offset - details.primaryDelta! > (screenWidth * pages.length) - screenWidth) {
            _controller.jumpTo((screenWidth * pages.length) - screenWidth);
          } else {
            _controller.jumpTo(_controller.offset - details.primaryDelta!);
          }
        }
      },
      onHorizontalDragEnd: (details) {
        final double vel = details.velocity.pixelsPerSecond.dx;
        double animateTo;

        if (vel == 0) {
          animateTo = (screenWidth * (_dragStartLocation / screenWidth).round());
        } else if (vel > 0) {
          animateTo = (screenWidth * (_dragStartLocation / screenWidth).round()) - screenWidth;
          if (animateTo < 0) animateTo = 0;
        } else {
          animateTo = (screenWidth * (_dragStartLocation / screenWidth).round()) + screenWidth;
          if (animateTo > (screenWidth * pages.length) - screenWidth) animateTo = (screenWidth * pages.length) - screenWidth;
        }

        _controller.animateTo(
          animateTo,
          duration: getAnimationDuration(details.primaryVelocity),
          curve: Curves.easeOut,
        );
        setState(() {
          currentPage = (animateTo / screenWidth).round();
        });
      },
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _controller,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(children: pages),
          ),
          Align(
            child: buildDots(),
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}
