import 'package:flutter/material.dart';

class ScrollableTransition extends StatefulWidget {
  ScrollableTransition({
    this.sliver,
    this.background,
    this.page,
    this.sliverHeight = 80,
    this.tapSliverToOpen = true,
    this.controller,
    this.fadeColor = Colors.black,
    this.onTransitionComplete,
    this.maxHeightOffset = 0,
  });

  /// The sliver that sits at the bottom of the page
  final Widget? sliver;

  /// The page that is opened when you swipe up on the sliver
  final Widget? page;

  /// The widget to display behind the page
  final Widget? background;

  /// The height of the sliver
  final double sliverHeight;

  /// When this is true, you can tap the sliver to open the page
  final bool tapSliverToOpen;

  /// The color that is overlaid while the transition is in progress
  final Color fadeColor;

  final ScrollableTransitionController? controller;

  /// Called when the transition is complete
  final void Function()? onTransitionComplete;

  /// Offset the max height
  ///
  /// This can be used if you don't want the page to cover the whole screen
  final double maxHeightOffset;

  @override
  _ScrollableTransitionState createState() => _ScrollableTransitionState();
}

// for tomorrow:
// add the test to fill screen when let go at a certain point
// maybe add cool "fling" thing (if the user is swiping fast it will keep moving)
// add a "open" and "closed" child (openChild and sliverChild idk)
class _ScrollableTransitionState extends State<ScrollableTransition> with SingleTickerProviderStateMixin {
  late double height;
  late double maxHeight;

  Duration _duration = Duration.zero;

  ScrollableTransitionController? _controller;

  double overlayOpacity() {
    if (_controller!.isOpen) {
      return ((maxHeight - height) / 100).clamp(0.0, 1.0);
    }
    return ((height - widget.sliverHeight) / 100).clamp(0.0, 1.0);
  }

  void animateOpen() {
    _duration = Duration(milliseconds: 350);
    setState(() {
      height = maxHeight;
      _controller!._isOpen = true;
    });
  }

  void animateClose() {
    _duration = Duration(milliseconds: 250);
    setState(() {
      height = widget.sliverHeight;
      _controller!._isOpen = false;
    });
  }

  @override
  void initState() {
    height = widget.sliverHeight;
    if (widget.controller != null) {
      _controller = widget.controller;
    } else {
      _controller = ScrollableTransitionController();
    }
    _controller!.attachScrollableTransition(animateOpen, animateClose);
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    maxHeight = (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top) - widget.maxHeightOffset;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        widget.background!,
        GestureDetector(
          child: AnimatedContainer(
            duration: _duration,
            height: height,
            curve: Curves.easeOutQuint,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(widget.fadeColor.withOpacity(overlayOpacity()), BlendMode.srcOver),
              child: _controller!.isOpen ? Wrap(children: [widget.page!]) : widget.sliver,
            ),
            onEnd: widget.onTransitionComplete,
          ),
          onVerticalDragStart: (details) {
            setState(() {
              _duration = Duration.zero;
            });
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 1) {
              animateClose();
            } else if (details.primaryVelocity! < -1) {
              animateOpen();
            } else {
              if ((maxHeight / 2) > height) {
                animateClose();
              } else {
                animateOpen();
              }
            }
          },
          onVerticalDragUpdate: (details) {
            if (height - details.delta.dy > widget.sliverHeight) {
              setState(() {
                // measures from the top of the screen so this needs to subtract
                height -= details.delta.dy;
              });
            }
          },
          onTap: () {
            if (widget.tapSliverToOpen && height == widget.sliverHeight) animateOpen();
          },
        ),
      ],
    );
  }
}

class ScrollableTransitionController {
  // I don't know how to make controllers so please make this better in future versions
  void Function()? _open;
  void Function()? _close;

  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void attachScrollableTransition(void Function() open, void Function() close) {
    _open = open;
    _close = close;
  }

  void dispose() {
    _open = null;
    _close = null;
  }

  void open() => _open!();

  void close() => _close!();
}
