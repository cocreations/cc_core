import 'dart:convert';

import 'package:cc_core/models/core/ccData.dart';

class TranslationLayer {
  TranslationLayer(this.translationLayerJson);
  final Map<String, dynamic> translationLayerJson;

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

  /// Parses any wacky input data into the clean sophisticated data the app uses.
  Map<int, Map<String, String>> parse(String data, String table) {
    Map inputData = jsonDecode(data);

    // if the table doesn't exist within the translationLayerJson, just return the data we were given
    if (!translationLayerJson.containsKey(table)) {
      return standardizeTranslationData(data);
    }

    Map template = translationLayerJson[table]!;

    if (template["output"] == null) {
      return standardizeTranslationData(data);
    }

    template = template["output"];

    Map<String, Map<String, String>> returnData = {};

    print("INPUT DATA\n\n$inputData\n\n.");
    print("TEMPLATE\n\n$template\n\n.");

    inputData.forEach((key, val) {
      returnData[key.toString()] = Map.from(template);

      returnData[key.toString()]!.updateAll((k, v) {
        String newVal = v.replaceAllMapped(RegExp(r"{[0-9a-zA-Z]+}"), (match) {
          return inputData[key][match.input.substring(match.start + 1, match.end - 1)] ?? "";
        });

        return newVal;
      });

      //returnData[key.toString()]![k] = returnData[key.toString()]![k]!.replaceAll("", replace);
    });

    print("OUTPUT DATA\n\n$returnData\n\n.");

    return standardizeTranslationData(jsonEncode(returnData));
  }

  Map<int, Map<String, String>> standardizeTranslationData(String data) {
    Map<int, Map<String, String>> returnData = {};
    Map jsonData = jsonDecode(data);
    int i = 0;
    // TODO: make this use an array rather than an object with id keys
    // putting all the data in a standardize format
    jsonData.forEach((k, v) {
      returnData.putIfAbsent(i, () => {'dataId': '$k', 'dataJson': '${jsonEncode(v)}'});
      i++;
    });

    return returnData;
  }
}
