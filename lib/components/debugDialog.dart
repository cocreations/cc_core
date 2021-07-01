import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';

class DebugDialog {
  DebugDialog();

  bool canDisplay = false;

  Future<void> init(BuildContext context) async {
    canDisplay = await CcData(CcApp.of(context).database, canExpire: false).getDBDataWhere("settings", CcApp.of(context).configSource, [DataFilter("name", Op.equals, "Show debug popups")], cacheFromDataConnection: false).then((value) {
      if (value == null || value.isEmpty) return false;
      return jsonDecode(value.values.first["dataJson"])["value"] == "true";
    });
  }

  void show(BuildContext context, String debugMessage, [String debugTitle = "debug"]) {
    if (canDisplay) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          clipBehavior: Clip.antiAlias,
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.bug_report),
              Text(debugTitle),
            ],
          ),
          content: Container(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              debugMessage,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }
  }
}
