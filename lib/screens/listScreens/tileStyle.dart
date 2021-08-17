import 'package:flutter/material.dart';

class TileStyle {
  TileStyle({
    this.imageSize = 70,
    this.cornerRadius = 4,
    this.elevation = 1,
    this.screenOnListItem = false,
    this.nameBackground = Colors.white,
    this.namePosition = Alignment.center,
  });
  final double imageSize;
  final double elevation;
  final double cornerRadius;
  final bool screenOnListItem;
  final Color nameBackground;
  final Alignment namePosition;

  static TileStyle parseStyle(String? style) {
    if (style == null || style.isEmpty) return TileStyle();

    List<String> kvs = style.split(",");
    Map<String, String> map = {};

    kvs.removeWhere((element) => !element.contains(":"));

    if (kvs.isEmpty) return TileStyle();

    kvs.forEach((element) {
      map[element.split(":")[0]] = element.split(":")[1];
    });

    return TileStyle(
      cornerRadius: map["cornerRadius"] != null ? double.parse(map["cornerRadius"]!) : 4,
      elevation: map["elevation"] != null ? double.parse(map["elevation"]!) : 1,
      imageSize: map["imageSize"] != null ? double.parse(map["imageSize"]!) : 70,
      screenOnListItem: map["screenOnListItem"] == "true",
      nameBackground: map["nameBackground"] != null ? Color(int.parse(map["nameBackground"]!)) : Colors.white,
      namePosition: map["nameBackground"] != null ? TileStyle()._getPos(map["namePosition"]!) : Alignment.center,
    );
  }

  Alignment _getPos(String pos) {
    switch (pos) {
      case "topLeft":
        return Alignment.topLeft;
      case "bottomLeft":
        return Alignment.bottomLeft;
      case "topRight":
        return Alignment.topRight;
      case "bottomRight":
        return Alignment.bottomRight;
      case "centre":
        return Alignment.center;
      default:
        return Alignment.center;
    }
  }
}
