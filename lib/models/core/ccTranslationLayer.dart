import 'dart:convert';

import 'package:cc_core/models/core/ccData.dart';

class TranslationLayer {
  TranslationLayer(this.translationLayerJson);
  final Map<String, dynamic> translationLayerJson;

  bool shouldTranslate(String table) {
    if (translationLayerJson[table] != null) {
      return translationLayerJson[table]["table"] != null;
    }
    return false;
  }

  /// Returns an empty list if there are no filters in the specified table
  List<DataFilter> getFilters(String table) {
    if (translationLayerJson[table] != null) {
      if (translationLayerJson[table]["filters"] != null) {
        List<DataFilter> filters = [];

        translationLayerJson[table]["filters"].forEach((f) {
          filters.add(DataFilter.parseMap(f));
        });

        return filters;
      }
    }
    return [];
  }

  /// Returns the table the database is actually supposed to pull from
  String getTable(String table) {
    if (!translationLayerJson.containsKey(table)) return table;
    if (!translationLayerJson[table].containsKey("table")) return table;
    return translationLayerJson[table]["table"] ?? table;
  }

  /// Parses any wacky input data into the clean sophisticated data the app uses.
  ///
  /// Expects standardized data i.e. the output of any dataConnection get request
  Map parse(Map data, String table) {
    // if the table doesn't exist within the translationLayerJson, just return the data we were given
    if (!translationLayerJson.containsKey(table)) {
      return data;
    }

    Map inputData = fromStandardData(data);

    Map template = translationLayerJson[table]!;

    if (template["output"] == null) {
      return standardizeTranslationData(data);
    }

    template = template["output"];

    Map<String, Map<String, String>> returnData = {};

    inputData.forEach((key, val) {
      returnData[key.toString()] = Map.from(template);

      returnData[key.toString()]!.updateAll((k, v) {
        String newVal = v.replaceAllMapped(RegExp(r"{[ -z]+}"), (match) {
          if (inputData[key][match.input.substring(match.start + 1, match.end - 1)] == null) {
            return "";
          }

          if (inputData[key][match.input.substring(match.start + 1, match.end - 1)] is String) {
            return inputData[key][match.input.substring(match.start + 1, match.end - 1)];
          }

          return jsonEncode(inputData[key][match.input.substring(match.start + 1, match.end - 1)]!);
        });

        return newVal;
      });

      //returnData[key.toString()]![k] = returnData[key.toString()]![k]!.replaceAll("", replace);
    });

    return standardizeTranslationData(returnData);
  }

  Map<int, Map<String, String>> standardizeTranslationData(Map data) {
    Map<int, Map<String, String>> returnData = {};
    int i = 0;
    // TODO: make this use an array rather than an object with id keys
    // putting all the data in a standardize format
    data.forEach((k, v) {
      returnData.putIfAbsent(i, () => {'dataId': '$k', 'dataJson': '${jsonEncode(v)}'});
      i++;
    });

    return returnData;
  }

  Map fromStandardData(Map inputData) {
    Map output = {};

    inputData.forEach((key, value) {
      if (!(value["dataJson"] is String)) {
        output[value["dataId"]] = value["dataJson"];
      } else {
        output[value["dataId"]] = jsonDecode(value["dataJson"]);
      }
    });

    return output;
  }
}
