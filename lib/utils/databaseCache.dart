import 'dart:async';
import 'dart:convert';
import 'dart:io' show Directory;

import 'package:cc_core/models/core/ccData.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cc_core/config/appConfig.dart';

// TODO: make database an instance of Database, not a future
// make a method called init() which will open the database with the dbName
// make all the await database calls just database.something
// add an isReady property which will get set to true when init() finishes
// if a method like saveDataToCache() is called when isReady is false, call init and await its result

// TODO: Add expiry to cache
// get the current dateTime in utc
// add that time in (milliseconds / 1000).floor() whenever data is cached
// return that time as a dateTime object in {"cachedAt":dateTime}

/// ## DBCache
/// creates an instance of a database with [dbName] being the name of the database file
class DBCache {
  // if this is set to a standard database object it'll brake because it needs time to open
  Future<Database> database;

  /// [dbName] is the file name of the db
  final String dbName;

  /// In seconds.
  final int expireAfter;

  /// this is only for testing DO NOT USE IN PRODUCTION
  final Directory testingDir;
  // final String appName = ConfigData.appName;

  DBCache(this.dbName, this.expireAfter, {this.testingDir}) {
    database = _openDBCache(dbName);
  }

  // finds and opens the database
  Future<Database> _openDBCache(String dbName) async {
    Directory directory;

    if (testingDir == null) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = testingDir;
    }
    String path = join(directory.path, "databases/", "$dbName.db");
    Database db = await openDatabase(path);
    return db;
  }

  // makes sure the table exists before trying to read from or write to it
  // returns false if there is an error or something goes wrong
  Future<bool> _checkTable(String table) async {
    if (database != null) {
      try {
        await database.then((db) {
          db.execute(
            "CREATE TABLE IF NOT EXISTS $table ("
            "dataId TEXT PRIMARY KEY,"
            "dataJson TEXT,"
            "lastUpdated INTEGER"
            ");",
          );
        });
        return true;
      } catch (e) {
        print("ERROR CHECKING TABLE: $e");
        return false;
      }
    } else {
      print("ERROR: database does not exist (if you are seeing this something has gone terribly wrong)");
      return false;
    }
  }

  /// Adds a lot of data to the database cache
  ///
  /// returns true if it succeeds
  Future<bool> batchSave(
    /// the database table to use
    String dataTable,

    /// the data to add
    ///
    /// this will use the map key as the dataId and map value as the dataJson
    ///
    /// All keys and values in the map will be converted to String
    Map data,
  ) async {
    return _checkTable(dataTable).then((succeeded) async {
      if (succeeded) {
        await database.then((db) async {
          Batch batch = db.batch();

          data.forEach((k, v) {
            batch.rawInsert("INSERT OR REPLACE INTO $dataTable(dataId, dataJson, lastUpdated) VALUES (?,?,?)", [k.toString(), v.toString(), (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).floor()]);
          });

          batch.commit(noResult: true);
        });
        return true;
      }
      return false;
    });
  }

  Future<bool> clearTable(String table) async {
    return _checkTable(table).then((succeeded) async {
      if (succeeded) {
        int val = await database.then((db) {
          return db.delete(table, where: "1");
        });
        print(val);
        if (val <= 0) return false;
        return true;
      } else {
        throw Exception("clearTable error. Failed to clear $table.");
      }
    });
  }

  /// query the db for a single db entry
  Future<Map<String, dynamic>> loadSingleEntry(
    /// the id of the row
    String id,
    String dataTable,
  ) {
    return _checkTable(dataTable).then((succeeded) async {
      if (succeeded) {
        List<Map<String, dynamic>> returnData = await database.then((db) {
          return db.query(dataTable, where: "dataId='$id'");
        });
        if (returnData == null || returnData.isEmpty) {
          return null;
        } else {
          return returnData[0];
        }
      } else {
        throw Exception("loadSingleEntry error. Failed to load $id from $dataTable.");
      }
    });
  }

  /// query the db with a filter
  Future<List<Map<String, dynamic>>> getWhere(
    /// the filter
    String dataTable,
    List<DataFilter> filters,
  ) {
    if (filters.isEmpty) {
      return loadFromCache(dataTable);
    }

    return _checkTable(dataTable).then((succeeded) async {
      if (succeeded) {
        List<String> jsonDBFilters = [];

        filters.forEach((filter) {
          if (filter.op == Op.equals) {
            jsonDBFilters.add("dataJson LIKE '%\"${filter.field}\":\"${filter.value}\"%'");
          } else if (filter.op == Op.arrayContains) {
            // this just ensures the returned value will be an array
            jsonDBFilters.add("dataJson LIKE '%\"${filter.field}\":[%'");
          }
        });

        List<Map<String, dynamic>> returnData = await database.then((db) async {
          return List<Map<String, dynamic>>.from(await db.query(dataTable, where: '${jsonDBFilters.join(" AND ")}'));
        });

        // this actually where we check if the array contains the correct value
        if (filters.any((element) => element.op == Op.arrayContains)) {
          List<int> toBeRemoved = [];

          if (returnData != null && returnData.isNotEmpty) {
            for (var i = 0; i < returnData.length; i++) {
              var json = jsonDecode(returnData[i]["dataJson"]);

              filters.forEach((element) {
                if (element.op == Op.arrayContains) {
                  if (json[element.field] is List) {
                    if (!json[element.field].contains(element.value)) {
                      toBeRemoved.add(i);
                    }
                  } else {
                    // if the field is not an array, reject it
                    toBeRemoved.add(i);
                  }
                }
              });
            }
          }
          toBeRemoved.sort();

          for (var i = toBeRemoved.length - 1; 0 <= i; i--) {
            returnData.removeAt(toBeRemoved[i]);
          }
        }

        if (returnData == null || returnData.isEmpty) {
          return null;
        } else {
          return returnData;
        }
      } else {
        throw Exception("getWhere error. Failed to load $filters from $dataTable.");
      }
    });
  }

  /// loads whatever is in the [dataTable]
  Future<List<Map<String, dynamic>>> loadFromCache(String dataTable) async {
    return _checkTable(dataTable).then((succeeded) async {
      if (succeeded) {
        List<Map<String, dynamic>> returnData = await database.then((db) {
          return db.query(dataTable);
        });
        return returnData;
      } else {
        throw Exception("loadFromCache error. Failed to load $dataTable.");
      }
    });
  }

  /// Adds data to the database cache
  /// returns -1 if it fails and 1 if it succeeds
  Future<int> saveDataToCache(
    /// the database table to use
    String dataTable,

    /// the dataId field
    String dataId,

    /// the actual json data
    String dataJson,
  ) async {
    return _checkTable(dataTable).then((succeeded) async {
      if (succeeded) {
        int result = await database.then((db) async {
          return db.rawInsert("INSERT OR REPLACE INTO $dataTable(dataId, dataJson, lastUpdated) VALUES (?,?,?)", [dataId.toString(), dataJson.toString(), (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).floor()]);
        });
        return result;
      } else {
        return -1;
      }
    });
  }
}
