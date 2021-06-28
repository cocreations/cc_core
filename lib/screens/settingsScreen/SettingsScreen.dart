import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Setting> settings = [];
  Map<String, String> settingsToUpdate = {};
  bool loading = true;

  List<Widget> buildList() {
    List<Widget> builtList = [];

    builtList.add(
      Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "Settings",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
      ),
    );

    for (var i = 0; i < settings.length; i++) {
      builtList.add(
        settings[i].toListItem(context, (value) {
          setState(() {});
          print("$i ${settings[i].name}");
          settingsToUpdate["$i"] = jsonEncode(settings[i].toMap());
        }),
      );
    }

    builtList.add(
      Center(
        child: FlatButton(
          child: Text("Reset to default"),
          onPressed: () {
            for (var i = 0; i < settings.length; i++) {
              settings[i].resetToDefault();
              settingsToUpdate["$i"] = jsonEncode(settings[i].toMap());
            }
            setState(() {});
          },
        ),
      ),
    );

    return builtList;
  }

  @override
  void deactivate() {
    print(settingsToUpdate);
    CcApp.of(context).database.batchSave("settings", settingsToUpdate);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      loading = false;

      /// We use the "default" set of settings to display the list on the screen
      /// Which is probably set in assets/bundledFiles/settings.json (or whatever the app config specifies)
      ///
      /// We go to the local SQLite DB on the phone to get the local value
      /// This means if the 'default' set of settings changes - that will always be the list of settings shown,
      /// regardless of other settings in the local DB (so if we add or remove settings this will get reflected in this screen)
      ///
      List<Map<String, dynamic>> localSqlSettings; // this is what is stored on the users phone in the SQLite DB
      Map<int, Map<String, String>> defaultSettings; // this is the default
      void compareLocalSettingsToAssetDefaults() {
        /// Note that we base the setting id as being the index, and we load only the value from the local DB

        defaultSettings.forEach((defKey, defValue) {
          Map value = jsonDecode(defValue["dataJson"]);
          for (var localIndex = 0; localIndex < localSqlSettings.length; localIndex++) {
            // dataId is now the id for the setting and therefore cannot be changed once set.
            // if a setting needs to be removed, its dataId must never be used again.
            if (localSqlSettings[localIndex]["dataId"] == defKey.toString()) {
              value["value"] = jsonDecode(localSqlSettings[localIndex]["dataJson"])["value"];
            }
          }
          settings.add(Setting.fromMap(jsonDecode(jsonEncode(value)), defKey));
        });

        setState(() {});
      }

      Future<List<Map<String, dynamic>>> localDBSettingsFuture = CcApp.of(context).database.loadFromCache("settings");
      localDBSettingsFuture.then((localDBSettings) {
        localSqlSettings = localDBSettings;

        if (defaultSettings != null) compareLocalSettingsToAssetDefaults();
      });

      CcApp.of(context).configSource.loadData("settings").then((defaultConfigSettings) {
        defaultSettings = defaultConfigSettings;

        if (localSqlSettings != null) compareLocalSettingsToAssetDefaults();
      });
    }

    return ListView(children: buildList());
  }
}

class Setting {
  Setting({this.name, this.value, this.defaultValue, this.type, this.extraInfo, this.id});
  String name;
  SettingType type;
  String extraInfo;
  dynamic value;
  dynamic defaultValue;
  int id;

  /// only works with CcData
  static Setting fromMap(Map map, int id) {
    var value;
    var defaultValue;
    var type;

    switch (map["type"]) {
      case "bool":
        type = SettingType.BOOL;
        value = map["value"] == "true";
        defaultValue = map["defaultValue"] == "true";
        break;
      case "string":
        type = SettingType.STRING;
        value = map["value"];
        defaultValue = map["defaultValue"];
        break;
      default:
        type = SettingType.STRING;
        value = map["value"];
        defaultValue = map["defaultValue"];
    }

    return Setting(
      name: map["name"],
      value: value,
      defaultValue: defaultValue,
      type: type,
      extraInfo: map["extraInfo"],
      id: id,
    );
  }

  Map toMap() {
    Map map = {};

    var mapValue;
    var mapDefaultValue;
    var mapType;

    switch (type) {
      case SettingType.BOOL:
        mapType = "bool";
        mapValue = "$value";
        mapDefaultValue = "$defaultValue";
        break;
      case SettingType.STRING:
        mapType = "string";
        mapValue = value;
        mapDefaultValue = defaultValue;
        break;
      default:
        mapType = "string";
        mapValue = value;
        mapDefaultValue = defaultValue;
    }

    if (name != null) map["name"] = name;
    if (value != null) map["value"] = mapValue;
    if (defaultValue != null) map["defaultValue"] = mapDefaultValue;
    if (type != null) map["type"] = mapType;
    if (extraInfo != null) map["extraInfo"] = extraInfo;

    return map;
  }

  void resetToDefault() {
    value = defaultValue;
  }

  Widget toListItem(BuildContext context, void Function(dynamic) onChange) {
    Widget valueWidget;

    if (type == SettingType.BOOL) {
      valueWidget = Switch(
        value: value,
        key: Key("$id switch"),
        onChanged: (v) {
          value = v;
          onChange(v);
        },
        activeColor: Colors.orange,
      );
    } else if (type == SettingType.STRING) {
      valueWidget = TextField(
        key: Key("$id textField"),
        onChanged: (value) => onChange(value),
      );
    }

    return Container(
      height: 80,
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              extraInfo != null
                  ? IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          content: Container(
                            margin: EdgeInsets.all(5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(extraInfo),
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: FlatButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text("OK"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          valueWidget,
        ],
      ),
    );
  }
}

enum SettingType {
  BOOL,
  STRING,
}
