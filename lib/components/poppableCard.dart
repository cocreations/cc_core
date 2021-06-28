import 'package:flutter/material.dart';

/// # PoppableCard
/// A darkmode-compliant card with an X in the corner to dismiss
class PoppableCard extends StatelessWidget {
  PoppableCard({
    this.child,
    this.borderRadius = 1,
    this.colour = Colors.white,
    this.width,
    this.height,
  });
  final double borderRadius;
  final Widget child;
  final Color colour;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    Color colour = Colors.white;
    Color iconColour = Colors.black;
    // if (MediaQuery.of(context).platformBrightness == Brightness.dark) {
    //   colour = Colors.black;
    //   iconColour = Colors.white;
    // }
    return Material(
      color: colour,
      child: Container(
        width: width,
        height: height,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 30),
              alignment: Alignment.centerRight,
              child: FlatButton.icon(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.close, color: iconColour), label: Container()),
            ),
            Container(child: child),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
