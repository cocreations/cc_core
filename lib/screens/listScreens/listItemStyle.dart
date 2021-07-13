import 'package:flutter/material.dart';

class ListItemStyle {
  ListItemStyle({
    this.imageSize = 70,
    this.cornerRadius = 4,
    this.elevation = 1,
    this.screenOnListItem = false,
    this.cardColor = Colors.white,
  });
  final double imageSize;
  final double elevation;
  final double cornerRadius;
  final bool screenOnListItem;
  final Color cardColor;

  static ListItemStyle parseStyle(String? style) {
    if (style == null || style.isEmpty) return ListItemStyle();

    List<String> kvs = style.split(",");
    Map<String, String> map = {};

    kvs.removeWhere((element) => !element.contains(":"));

    if (kvs.isEmpty) return ListItemStyle();

    kvs.forEach((element) {
      map[element.split(":")[0]] = element.split(":")[1];
    });

    return ListItemStyle(
      cornerRadius: map["cornerRadius"] != null ? double.parse(map["cornerRadius"]!) : 4,
      elevation: map["elevation"] != null ? double.parse(map["elevation"]!) : 1,
      imageSize: map["imageSize"] != null ? double.parse(map["imageSize"]!) : 70,
      screenOnListItem: map["screenOnListItem"] == "true",
      cardColor: map["cardColor"] != null ? Color(int.parse(map["cardColor"]!)) : Colors.white,
    );
  }
}
