import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:cc_core/models/core/ccData.dart';

/// ## CcDataConnection
///
/// The abstract class for defining a data source to populate the app from
abstract class CcDataConnection {
  bool get requiresInternet;
  Future<dynamic> loadData(String? table);
  Future<dynamic> getWhere(String table, List<DataFilter> filters);
}

/// Takes a string from config and returns a CcDataConnection
class GetDataSource {
  static CcDataConnection? getDataSource(Map configMap) {
    switch (configMap['backendType']) {
      case "airTable":
        return AirTableDataConnection(configMap["apiKey"], configMap["baseId"]);
      case "firebase":
        return FirebaseDataConnection(configMap["baseId"]);
      case "asset":
        return AssetDataConnection(configMap["folderPath"]);
      default:
        return null;
    }
  }
}

/// ## AirTableDataConnection
///
/// Implements CcDataConnection, using an "Air Table" as the data source
/// TODO : Make a document defining how to use this, and add the link to that here !
class AirTableDataConnection extends CcDataConnection {
  bool get requiresInternet => true;
  final String? apiKey;
  final String? baseId;
  List? validationErrors;

  AirTableDataConnection(this.apiKey, this.baseId);

  Future<dynamic> loadData(String? table) async {
    //does a get request with all the auth data and stuff to airtable
    http.Response response = await http.get(Uri.parse("https://api.airtable.com/v0/$baseId/$table?maxRecords=500"), headers: {"Authorization": "Bearer $apiKey"});

    if (response.statusCode == 200) {
      return standardizeAirtableData(response.body);
    } else {
      throw ("ERROR loading data, http error ${response.statusCode}.");
    }
  }

  Future<Map<int, Map<String, String>>> getWhere(String table, List<DataFilter> filter) async {
    List<String> stringFilters = [];

    for (var f in filter) {
      if (f.op == Op.arrayContains) {
        stringFilters.add("IF(REGEX_MATCH(%7B${f.field}%7D%2C%20%22${f.value}%22)%2C%20TRUE()%2C%20FALSE())");
      } else if (f.op == Op.equals) {
        stringFilters.add("IF(%7B${f.field}%7D%20%3D%20%22${f.value}%22%2C%20TRUE()%2C%20FALSE())");
      }
    }

    http.Response response = await http.get(Uri.parse("https://api.airtable.com/v0/$baseId/$table?maxRecords=500&filterByFormula=AND(${stringFilters.join("%2C%20")})"), headers: {"Authorization": "Bearer $apiKey"});

    if (response.statusCode == 200) {
      return standardizeAirtableData(response.body);
    } else {
      throw ("ERROR loading data, http error ${response.statusCode}.");
    }
  }

  static Map<int, Map<String, String>> standardizeAirtableData(String jsonData) {
    Map<int, Map<String, String>> returnData = {};
    Map data = jsonDecode(jsonData);
    int i = 0;

    // putting all the data in a standardize format
    data['records'].forEach((item) {
      var id = item['fields']['id'];
      id ??= item['id'];

      returnData.putIfAbsent(i, () => {'dataId': '$id', 'dataJson': ""});
      returnData[i]!['dataJson'] = jsonEncode(item['fields']);
      i++;
    });

    return returnData;
    /*
    {
      table: { eg menus
        {
          type: [ eg leftSide
            {
              name: "name",
              appScreen: "testScreen",
              appScreenParam: "hello world!",
            },
            {...
            }
          ]
        }
      }
    }
    */
  }
}

/// ## FirebaseDataConnection
///
///
/// Implements CcDataConnection, using a Firebase as the data source
/// TODO : Make a document defining how to use this, and add the link to that here !
class FirebaseDataConnection extends CcDataConnection {
  bool get requiresInternet => true;
  final String? baseId;
  List? validationErrors;

  FirebaseDataConnection(this.baseId);

  Future<dynamic> loadData(String? table) async {
    // need to fix this later when we have more people
    http.Response response = await http.post(
      Uri.parse("https://firestore.googleapis.com/v1/projects/$baseId/databases/(default)/documents:runQuery"),
      headers: {"Content-Type": "application/json"},
      body: "{\"structuredQuery\":{\"from\":[{\"collectionId\":\"$table\"}]}}",
      //"{\"structuredQuery\":{\"from\":[{\"collectionId\":\"$table\"}],\"where\":{\"fieldFilter\":{\"field\":{\"fieldPath\":\"editor\"},\"op\":\"EQUAL\",\"value\":{\"stringValue\":\"33bXNjmpYMhDHS4qYcaZjMMK7hm1\"}}}}}",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return standardizeFirebaseData(response.body);
    } else {
      throw ("ERROR loading data, http error ${response.statusCode}.");
    }
  }

  /// Gets a list of docs where key equals value in [filters]
  Future<dynamic> getWhere(String table, List<DataFilter> filters) async {
    // need to fix this later when we have more people
    // TODO: fix firebase post

    // ensuring filter is actually being used
    if (filters.isEmpty) {
      return loadData(table);
    }

    List<String> jsonFirebaseFilters = [];

    filters.forEach((filter) {
      if (filter.op == Op.equals) {
        jsonFirebaseFilters.add("{\"fieldFilter\":{\"field\":{\"fieldPath\":\"${filter.field}\"},\"op\":\"EQUAL\",\"value\":{\"stringValue\":\"${filter.value}\"}}}");
      } else if (filter.op == Op.arrayContains) {
        jsonFirebaseFilters.add("{\"fieldFilter\":{\"field\":{\"fieldPath\":\"${filter.field}\"},\"op\":\"ARRAY_CONTAINS\",\"value\":{\"stringValue\":\"${filter.value}\"}}}");
      }
    });

    http.Response response = await http.post(
      Uri.parse("https://firestore.googleapis.com/v1/projects/$baseId/databases/(default)/documents:runQuery"),
      headers: {"Content-Type": "application/json"},
      body: "{\"structuredQuery\":{\"from\":[{\"collectionId\":\"$table\"}],\"where\":{\"compositeFilter\":{\"op\":\"AND\", \"filters\":[${jsonFirebaseFilters.join(",")}]}}}}",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return standardizeFirebaseData(response.body);
    } else {
      throw ("ERROR loading data, http error ${response.statusCode}.");
    }
  }

  static Map<int, Map<String, String>> standardizeFirebaseData(String jsonData) {
    Map<int, Map<String, String>> returnData = {};
    List data = jsonDecode(jsonData);
    int i = 0;

    dynamic removeUselessFirebaseStuff(Map data) {
      dynamic returnVal = "";

      if (data.containsKey("arrayValue")) {
        returnVal = [];
        if (data["arrayValue"]["values"] != null) {
          data["arrayValue"]["values"].forEach((v) {
            returnVal.add(removeUselessFirebaseStuff(v));
          });
        }
      } else if (data.containsKey("mapValue")) {
        returnVal = {};

        if (data["mapValue"]["fields"] != null) {
          data["mapValue"]["fields"].forEach((k, v) {
            returnVal[k] = removeUselessFirebaseStuff(v);
          });
        }
      } else if (data.containsKey("geoPointValue")) {
        if (data["geoPointValue"]["latitude"] != null && data["geoPointValue"]["longitude"] != null) {
          returnVal = [data["geoPointValue"]["latitude"], data["geoPointValue"]["longitude"]];
        }
      } else {
        returnVal = data.values.first.toString();
      }
      return returnVal;
    }

    // putting all the data in a standardize format
    data.forEach((item) {
      if (item.isNotEmpty && item['document'] != null) {
        var id = item['document']['name'].toString().split("/").last;
        var fields = {};

        returnData.putIfAbsent(i, () => {'dataId': '$id', 'dataJson': ""});

        item['document']['fields'].forEach((key, value) {
          fields.putIfAbsent(key, () => removeUselessFirebaseStuff(value));
        });
        returnData[i]!['dataJson'] = jsonEncode(fields);
        i++;
      }
    });

    return returnData;
    /*
    {
      table: { eg menus
        {
          type: [ eg leftSide
            {
              name: "name",
              appScreen: "testScreen",
              appScreenParam: "hello world!",
            },
            {...
            }
          ]
        }
      }
    }
    */
  }
}

/// ## AssetDataConnection
///
/// Uses the flutter asset system to bundle data with the app
///
class AssetDataConnection extends CcDataConnection {
  bool get requiresInternet => false;
  AssetDataConnection(this.folderPath);

  final String? folderPath;

  /// don't include the .json extension
  Future loadData(String? assetName) async {
    String path;
    if (folderPath!.endsWith("/")) {
      path = "$folderPath$assetName";
    } else {
      path = "$folderPath/$assetName";
    }
    if (!path.endsWith(".json")) {
      path += ".json";
    }

    final ByteData data = await rootBundle.load(path);

    return standardizeAssetData(utf8.decode(data.buffer.asUint8List()));
  }

  Future getWhere(String assetName, List<DataFilter> filters) async {
    var data = await loadData(assetName);

    Map returnData = {};

    if (data is Map) {
      data.forEach((key, value) {
        var json = jsonDecode(value["dataJson"]);

        // this really isn't the most elegant solution but it should work
        for (var i = 0; i <= filters.length; i++) {
          // this is really strange
          // but basically if we reach the end of the filters list it means that value should be added to the returnData

          if (i >= filters.length) {
            returnData[key] = value;
            break;
          }

          if (filters[i].op == Op.equals) {
            if (json[filters[i].field] != filters[i].value) {
              break;
            }
          } else if (filters[i].op == Op.arrayContains) {
            // now this is even more confusing than the last thing
            // so if the field is a list and it has the value it will continue to on to match the rest of the filters in the list
            // but if it fails any of these it need to skip the current field as specified in [Op.arrayContains]
            if (json[filters[i].field] is List) {
              if (!json[filters[i].field].contains(filters[i].value)) {
                continue;
              }
              break;
            }
            break;
          }
        }
      });
    }

    return returnData;
  }

  static Map<int, Map<String, String>> standardizeAssetData(String jsonData) {
    Map<int, Map<String, String>> returnData = {};
    Map data = jsonDecode(jsonData);
    int i = 0;
    // TODO: make this use an array rather than an object with id keys
    // putting all the data in a standardize format
    data.forEach((k, v) {
      returnData.putIfAbsent(i, () => {'dataId': '$k', 'dataJson': '${jsonEncode(v)}'});
      i++;
    });

    return returnData;
  }
}

/* TODO !
/// ## JsonRestDataConnection 
/// 
/// Implements CcDataConnection, using a standard REST (with JSON) as the data source
/// TODO : Implement this !
/// TODO : Make a document defining how to use this, and add the link to that here !
class JsonRestDataConnection extends CcDataConnection {

  final String baseUrl;

  Future<dynamic> loadData(String table) {
    return Future();
  }

  JsonRestDataConnection( this.baseUrl );

}
*/

/** 
class JustADemo {

String backendType;
String apiKey;
String dbId;
String baseUrl;

CcDataConnection dataConn;

void myCode() {

    if (backendType == "airTable") {
      dataConn = AirTableDataConnection( apiKey, dbId );
    } else if (backendType == "jsonRest") {
      dataConn = JsonRestDataConnection( baseUrl );
    }

    dataConn.fetchData('menu');

  }

}
*/
