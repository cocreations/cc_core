import 'package:flutter/material.dart';

class DualWidgetScrollView extends StatefulWidget {
  DualWidgetScrollView({this.topChild, this.bottomChild, this.height = 300, Key key}) : super(key: key);
  final Widget topChild;
  final Widget bottomChild;
  final double height;

  @override
  _DualWidgetScrollViewState createState() => _DualWidgetScrollViewState();
}

class _DualWidgetScrollViewState extends State<DualWidgetScrollView> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (_scrollController.position.pixels - details.primaryDelta < (widget.height + 10)) {
          _scrollController.jumpTo(_scrollController.position.pixels - details.primaryDelta);
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity > 0) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: (600 - (details.primaryVelocity ~/ 10)).clamp(100, 600)),
            curve: Curves.easeOutExpo,
          );
        } else if (details.primaryVelocity < 0) {
          _scrollController.animateTo(
            widget.height,
            duration: Duration(milliseconds: (600 + (details.primaryVelocity ~/ 10)).clamp(100, 600)),
            curve: Curves.easeOutExpo,
          );
        } else {
          if (_scrollController.offset > 150) {
            _scrollController.animateTo(
              widget.height,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutExpo,
            );
          } else {
            _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutExpo,
            );
          }
        }
      },
      child: Container(
        height: widget.height + 50,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            Container(
              height: widget.height,
              child: widget.topChild != null ? widget.topChild : Container(),
            ),
            _FunkyBar(
              maxScrollOffset: widget.height,
              scrollController: _scrollController,
              key: widget.key != null ? Key(widget.key.toString().replaceAll(RegExp(r"[\[<'>\]]"), "") + "_FunkyBar") : null,
              onTapArrowDown: () {
                _scrollController.animateTo(
                  widget.height,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutExpo,
                );
              },
              onTapArrowUp: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutExpo,
                );
              },
            ),
            Container(
              height: widget.height,
              child: widget.bottomChild != null ? widget.bottomChild : Container(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunkyBar extends StatefulWidget {
  _FunkyBar({
    @required this.scrollController,
    @required this.maxScrollOffset,
    this.minScrollOffset,
    this.onTapArrowDown,
    this.onTapArrowUp,
    Key key,
  }) : super(key: key);

  final ScrollController scrollController;
  final double maxScrollOffset;
  final double minScrollOffset;
  final void Function() onTapArrowDown;
  final void Function() onTapArrowUp;

  @override
  _FunkyBarState createState() => _FunkyBarState();
}

class _FunkyBarState extends State<_FunkyBar> {
  double _minScrollOffset = 0;
  double leftBar = 0;
  double rightBar = 0;

  @override
  void initState() {
    if (widget.minScrollOffset != null) _minScrollOffset = widget.minScrollOffset;
    widget.scrollController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(() => setState(() {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scrollController.positions.isNotEmpty) {
      var offset = ((widget.scrollController.offset - _minScrollOffset) * 1.2) / (widget.maxScrollOffset - _minScrollOffset);
      offset -= 0.6;

      offset = offset.clamp(-0.6, 0.6);

      leftBar = -offset;
      rightBar = offset;
    }

    return InkWell(
      onTap: () {
        if (rightBar < 0) {
          if (widget.onTapArrowDown != null) {
            widget.onTapArrowDown();
          }
        } else {
          if (widget.onTapArrowUp != null) {
            widget.onTapArrowUp();
          }
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 22.5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: leftBar,
              child: Container(
                margin: EdgeInsets.only(right: 25),
                height: 5,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                ),
              ),
            ),
            Transform.rotate(
              angle: rightBar,
              child: Container(
                margin: EdgeInsets.only(left: 25),
                height: 5,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
