import 'package:flutter/material.dart';

/// THIS REQUIRES THE SOUNDTRAILS ASSET PACK
class BackgroundRipple extends StatelessWidget {
  BackgroundRipple({
    this.child,
    this.rippleSeed = 1,
  });

  final Widget? child;

  /// this ensures that the ripple is not different every time the user enters a screen
  final int rippleSeed;

  Widget _getAsset(int seed) {
    if (seed.isEven) {
      if ((seed ~/ 2).isEven) {
        return Positioned(
          child: Image.asset(
            "assets/bundledFiles/backgroundRipple/background_1.png",
            height: 500,
            width: 500,
            fit: BoxFit.contain,
          ),
          bottom: 0,
          right: -120,
        );
      }
      return Positioned(
        child: Image.asset(
          "assets/bundledFiles/backgroundRipple/background_2.png",
          height: 500,
          width: 500,
          fit: BoxFit.contain,
        ),
        left: -100,
      );
    }
    if ((seed ~/ 2).isEven)
      return Positioned(
        child: Image.asset(
          "assets/bundledFiles/backgroundRipple/background_3.png",
          height: 450,
          width: 450,
          fit: BoxFit.contain,
        ),
        top: 0,
      );
    return _getAsset((seed ~/ 2));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            _getAsset(rippleSeed),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.75),
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            )
          ],
        ),
        child!,
      ],
    );
  }
}
