import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:cc_core/screens/settingsScreen/SettingsScreen.dart';

/// Just some helper functions for cleaner settings use
class SettingsData {
  // Will either return a bool or a string depending on setting type
  Future getSettingValueFromName(BuildContext context, String name) async {
    Map<dynamic, dynamic> settingJson = await CcData(CcApp.of(context).database).getDBDataWhere(
      "settings",
      CcApp.of(context).configSource,
      [DataFilter("name", Op.equals, name)],
      cacheFromDataConnection: false,
    );

    // id is not currently used so we'll just set it to -1
    Setting setting = Setting.fromMap(jsonDecode(settingJson.values.first["dataJson"]), -1);

    return setting.value;
  }

  /// Returns full setting object
  Future<Setting> getSettingFromName(BuildContext context, String name) async {
    Map<dynamic, dynamic> settingJson = await CcData(CcApp.of(context).database).getDBDataWhere(
      "settings",
      CcApp.of(context).configSource,
      [DataFilter("name", Op.equals, name)],
      cacheFromDataConnection: false,
    );

    // id is not currently used so we'll just set it to -1
    Setting setting = Setting.fromMap(jsonDecode(settingJson.values.first["dataJson"]), -1);

    return setting;
  }
}
