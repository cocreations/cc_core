import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/screens/introScreen/SwipeScreen.dart';
import 'package:cc_core/screens/listScreens/ListViewScreen.dart';
import 'package:cc_core/screens/listScreens/TiledListScreen.dart';
import 'package:cc_core/screens/mediaPlayers/audioPlayerScreen.dart';
import 'package:cc_core/screens/simpleScreens/imageBackgroundScreen.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/screens/emptyTestScreen/emptyImageScreen.dart';
import 'package:cc_core/screens/emptyTestScreen/emptyTestScreen.dart';
import 'package:cc_core/screens/mapScreen/mapScreen.dart';
import 'package:cc_core/screens/simpleScreens/TextScreen.dart';
import 'package:cc_core/screens/settingsScreen/settingsScreen.dart';

class WidgetParser extends StatelessWidget {
  WidgetParser(this.widget, this.arg);
  final String? widget;
  final String? arg;
  @override
  Widget build(BuildContext context) {
    switch (widget) {
      case "EmptyTestScreen":
        return EmptyTestScreen(string: arg);
      case "EmptyImageScreen":
        return EmptyImageScreen(url: arg);
      case "TextScreen":
        return TextScreen(string: arg!);
      case "ImageBackgroundScreen":
        return ImageBackgroundScreen(arg);
      case "MapScreen":
        return MapScreen(mbTilesUrl: arg);
      case "ListViewScreen":
        return ListViewScreen(arg);
      case "TiledListScreen":
        return TiledListScreen(arg);
      case "SettingsScreen":
        return SettingsScreen();
      case "LargeAudioPlayer":
        return AudioPlayerScreen(arg, PlayerType.large);
      case "SmallAudioPlayer":
        return AudioPlayerScreen(arg, PlayerType.small);
      case "SingleButtonAudioPlayer":
        return AudioPlayerScreen(arg, PlayerType.buttonOnly);
      case "SwipeableIntroScreen":
        return SwipeScreen(arg);
      default:
        if (CcApp.of(context)!.parserModules != null) {
          return CcApp.of(context)!.parserModules!.parse(widget, arg);
        }

        return Container(
          child: Center(
            child: Text("Failed to parse '$widget'\nEnsure parserModules have been set correctly and double check the spelling of the screen.\n(Names are case sensitive)"),
          ),
        );
    }
  }
}
