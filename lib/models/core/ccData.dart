import 'dart:convert';
import 'dart:io' show File, SocketException, InternetAddress, Directory;
import 'dart:async';

import 'package:cc_core/models/core/ccApp.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cc_core/components/errors.dart';

import 'package:cc_core/utils/databaseCache.dart';
import 'package:cc_core/utils/fileCache.dart';
import 'package:path_provider/path_provider.dart';
import 'ccDataConnection.dart';

enum Op {
  /// "=="
  equals,

  /// Array Contains will only return true if the field is an array and it contains the value
  arrayContains,
}

/// The filter for a getWhere search
class DataFilter {
  /// The field to filter by.
  final String field;

  /// The value to compare to.
  final String value;

  /// The operator to filter by.
  final Op op;

  DataFilter(this.field, this.op, this.value);

  @override
  String toString() {
    return "{$field $op $value}";
  }
}

const MONTHS = {
  'Jan': '01',
  'Feb': '02',
  'Mar': '03',
  'Apr': '04',
  'May': '05',
  'Jun': '06',
  'Jul': '07',
  'Aug': '08',
  'Sep': '09',
  'Oct': '10',
  'Nov': '11',
  'Dec': '12',
};

/// ## CcData
///
/// This class handles all data related things throughout the app/s
class CcData {
  final DBCache? database;

  /// In seconds
  ///
  /// By default CcData will use the databases expiry as its expiry time.
  /// But if you need to override this for whatever reason, you can do so here.
  final int? expireAfterOverride;

  /// If true, the object can expire.
  ///
  /// Defaults to true.
  final bool canExpire;
  CcData(this.database, {this.expireAfterOverride, this.canExpire = true});

  /// Returns the file extension of the url with the leading dot
  ///
  /// if the url does not have a file extension, an empty string will be returned
  static String getExtension(String url) {
    final Uri? uri = Uri.tryParse(url);

    if (uri == null) {
      return "";
    }

    if (uri.pathSegments.isEmpty) {
      return "";
    }

    String ext = "${uri.pathSegments.last.contains(".") ? uri.pathSegments.last.split(".").last : ""}";

    if (ext.isNotEmpty) ext = ".$ext";
    return ext;
  }

  /// Ensures there is at least one url in a list.
  static bool containsUsableUrl(List<String> urls) {
    if (urls.isEmpty) return false;
    return urls.any((url) {
      var uri = Uri.tryParse(url);
      if (uri == null) return false;
      try {
        if (uri.origin.isNotEmpty) return true;
        return false;
      } catch (e) {
        return false;
      }
    });
  }

  /// Ensures every url in the list is valid.
  static bool allUrlsUsable(List<String> urls) {
    if (urls.isEmpty) return false;
    return urls.every((url) {
      var uri = Uri.tryParse(url);
      if (uri == null) return false;
      try {
        if (uri.origin.isNotEmpty) return true;
        return false;
      } catch (e) {
        return false;
      }
    });
  }

  /// Removes all non alphanumeric characters
  static String sanitizeName(String name) {
    String sanitizedName = "";
    // I hate regex
    sanitizedName = name.replaceAll(RegExp(r'[^a-z0-9]', caseSensitive: false), "_");
    return sanitizedName;
  }

  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(Duration(seconds: 12), onTimeout: () => []);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// Amazon uses RFC822 time in their timestamps, so I found this converter on [stack overflow](https://stackoverflow.com/a/62310160/8112258)
  DateTime? _parseRfc822(String input) {
    var splits = input.split(' ');
    if (splits[5] == "GMT") {
      splits[5] = "Z";
    } else {
      splits[5] = " " + splits[5];
    }
    var reformatted = splits[3] + '-' + MONTHS[splits[2]]! + '-' + (splits[1].length == 1 ? '0' + splits[1] : splits[1]) + ' ' + splits[4] + splits[5];
    return DateTime.tryParse(reformatted);
  }

  /// Gets data from the database or server backend if the db doesn't have it
  Future<Map?> getDBData(String? table, CcDataConnection dataConnection) async {
    Map? data;

    bool isConnected = dataConnection.requiresInternet ? await hasInternet() : true;

    Map<String, String?> readyData() {
      Map<String, String?> saveReadyMap = Map();
      data!.forEach((typeKey, typeVal) {
        saveReadyMap.addAll({typeVal["dataId"].toString(): typeVal["dataJson"]});
      });
      return saveReadyMap;
    }

    // grab the cache
    List cachedData;
    try {
      cachedData = await database!.loadFromCache(table);
    } catch (e) {
      print(e);
      throw (e);
    }

    // if we have cache
    if (cachedData != null && cachedData.isNotEmpty) {
      // if the object cant expire
      // just return the object
      if (!canExpire) return cachedData.asMap();

      double? oldestElement = double.maxFinite;
      // get the lowest "lastUpdated" number, meaning the oldest cache
      cachedData.forEach((element) {
        if (element["lastUpdated"] != null && oldestElement! > element["lastUpdated"]) oldestElement = element["lastUpdated"].toDouble();
      });
      DateTime lastTime = DateTime.fromMillisecondsSinceEpoch((oldestElement! * 1000).floor(), isUtc: true);

      // if the oldest cache plus the expireAfter is older than the current time
      // then refresh the cache if we can
      if (lastTime.add(Duration(seconds: database!.expireAfter)).isBefore(DateTime.now().toUtc())) {
        if (isConnected || !dataConnection.requiresInternet) {
          data = await (dataConnection.loadData(table) as FutureOr<Map<dynamic, dynamic>?>);

          database!.batchSave(table, readyData());

          return data;
        } else {
          return cachedData.asMap();
        }
      } else {
        return cachedData.asMap();
      }
    } else if (isConnected || !dataConnection.requiresInternet) {
      data = await (dataConnection.loadData(table) as FutureOr<Map<dynamic, dynamic>?>);

      database!.batchSave(table, readyData());

      return data;
    } else {
      return null;
    }
  }

  /// Same as [getDBData] with the an added filter.
  Future<Map?> getDBDataWhere(
    String table,
    CcDataConnection? dataConnection,
    List<DataFilter> filters, {

    /// Whether or not you want to save the filtered data that is obtained from the dataConnection to the cache.
    bool cacheFromDataConnection = true,
  }) async {
    Map? data;

    bool isConnected = await hasInternet();

    Map<String, String?> readyData() {
      Map<String, String?> saveReadyMap = Map();
      data!.forEach((typeKey, typeVal) {
        saveReadyMap.addAll({typeVal["dataId"].toString(): typeVal["dataJson"]});
      });
      return saveReadyMap;
    }

    // grab the cache
    List? cachedData;
    try {
      cachedData = await database!.getWhere(table, filters);
    } catch (e) {
      print(e);
    }

    // if we have cache
    if (cachedData != null && cachedData.isNotEmpty) {
      if (!canExpire) return cachedData.asMap();

      double? oldestElement = double.maxFinite;
      // get the lowest "lastUpdated" number, meaning the oldest cache
      cachedData.forEach((element) {
        if (element["lastUpdated"] != null && oldestElement! > element["lastUpdated"]) oldestElement = element["lastUpdated"];
      });
      DateTime lastTime = DateTime.fromMillisecondsSinceEpoch((oldestElement! * 1000).floor(), isUtc: true);

      // if the oldest cache plus the expireAfter is older than the current time
      // then refresh the cache if we can
      if (lastTime.add(Duration(seconds: database!.expireAfter)).isBefore(DateTime.now().toUtc())) {
        if (isConnected || !dataConnection!.requiresInternet) {
          data = await (dataConnection!.getWhere(table, filters) as FutureOr<Map<dynamic, dynamic>?>);

          database!.batchSave(table, readyData());

          return data;
        } else {
          return cachedData.asMap();
        }
      } else {
        return cachedData.asMap();
      }
    } else if (isConnected || !dataConnection!.requiresInternet) {
      data = await (dataConnection!.getWhere(table, filters) as FutureOr<Map<dynamic, dynamic>?>);

      database!.batchSave(table, readyData());

      return data;
    } else {
      return null;
    }
  }

  /// You need a file? We got a file!
  Future<File?> getFile(
    /// The web url of the file to fetch.
    /// We use a hashed version of the url for the filename so thats why its not specified.
    String? url,

    /// This is not the file name but the directory its stored in.
    /// The file name is a hash of the url.
    String dir, {

    /// Will check the HEAD of the file on the server to make sure we have the latest version of the file.
    bool checkFileForModifications = false,

    /// Only works if [checkFileForModifications] is true.
    /// If true, this will return the old cached file and download the new one in the background.
    bool updateFileInBackground = true,

    /// This will be called if there is an error getting the file
    void Function(Error)? onFileError,
  }) async {
    String sanitizedDir = sanitizeName(dir);

    FileCache fileCache = FileCache();
    if (url == null) {
      throw Exception("Cannot get file, URL is null");
    }

    if (url.isEmpty) {
      throw Exception("Cannot get file, URL is empty");
    }

    // we're using a hash for the filename so we don't have to worry about getting an identical file error
    String fileName = "${sha1.convert(utf8.encode(url)).toString()}${getExtension(url)}";

    bool fileExists = await fileCache.checkFileExists(sanitizedDir, fileName);

    if (fileExists) {
      DateTime localFileUpdatedDTS;
      DateTime remoteFileUpdatedDTS;

      if (checkFileForModifications) {
        if (await hasInternet()) {
          String? lastMod;

          // this looks really ugly but we need to await quite a few things
          localFileUpdatedDTS = await (await fileCache.retrieveFile(sanitizedDir, fileName)).lastModified();

          try {
            // this should be damn near instant so don't worry about waiting for this
            lastMod = (await http.head(Uri.parse(url))).headers["last-modified"];
          } catch (e) {
            print(e);
          }

          if (lastMod != null) {
            try {
              remoteFileUpdatedDTS = DateTime.parse(lastMod);
            } catch (FormatException) {
              // maybe it's formatted differently to what standard parse expects,
              // like this instead ? : 'Tue, 23 Feb 2021 00:17:59 GMT'
              remoteFileUpdatedDTS = DateFormat("EEE, d MMM yyyy hh:mm:ss 'GMT'").parse(lastMod, true);
              // if not then the exception will happen anyway ..
            }

            if (localFileUpdatedDTS.isBefore(remoteFileUpdatedDTS)) {
              if (updateFileInBackground) {
                fileCache.cacheFile(url, sanitizedDir, fileName).catchError((e) {
                  if (onFileError != null) {
                    onFileError(Error(3020, e.toString()));
                  }
                });

                return fileCache.retrieveFile(sanitizedDir, fileName).catchError((e) {
                  if (onFileError != null) {
                    onFileError(Error(3010, e.toString()));
                  }
                });
              }

              return fileCache.cacheFile(url, sanitizedDir, fileName).catchError((e) {
                if (onFileError != null) {
                  onFileError(Error(3020, e.toString()));
                }
              });
            }
          }
        } else {
          return fileCache.retrieveFile(sanitizedDir, fileName).catchError((e) {
            if (onFileError != null) {
              onFileError(Error(3010, e.toString()));
            }
          });
        }
      }

      return fileCache.retrieveFile(sanitizedDir, fileName).catchError((e) {
        if (onFileError != null) {
          onFileError(Error(3010, e.toString()));
        }
      });
    } else {
      return fileCache.cacheFile(url, sanitizedDir, fileName).catchError((e) {
        if (onFileError != null) {
          onFileError(Error(3020, e.toString()));
        }
      });
    }
  }

  /// You need files? We got files!
  Future<List<File?>?> getFiles(
    /// The web urls of the files to fetch.
    /// We use a hashed version of the urls for the filenames so thats why its not specified.
    List<String?> urls,

    /// This is not the file name but the directory its stored in.
    String dir,

    /// duh
    BuildContext context, {

    /// A callback that gives you the percentage (double) and a completion status (bool), and the Files (List<File>) when they're done
    void Function(double, bool, List<File?>?)? callback,

    /// Will skip over 404 errors
    bool skip404 = false,

    /// Will check the HEAD of the file on the server to make sure we have the latest version of the file.
    bool checkFileForModifications = false,

    /// Only works if [checkFileForModifications] is true.
    /// If true, this will return the old cached file and download the new one in the background.
    bool updateFileInBackground = true,

    /// If true, any files that cannot be retrieved will be null
    bool allowNullFiles = false,

    /// This will be called if there is an error getting a certain file

    void Function(Error)? onFileError,
  }) async {
    String sanitizedDir = sanitizeName(dir);
    FileCache fileCache = FileCache();
    List<String> fileNames = [];
    List<String> fileNamesDownloaded = [];
    List<String> fileNamesNotDownloaded = [];
    List<String?> urlsNotDownloaded = [];
    List<String?> urlsDownloaded = []; // used for checking HEAD
    List<File?> files = List<File?>.filled(urls.length, null);
    List<int> d = [];
    List<int> nd = [];
    double notDownloadedPer = 0;
    double downloadedPer = 0;

    bool isConnected = await hasInternet();

    void fileCallback(List<File?>? f) {
      if (callback != null) {
        var per = ((((notDownloadedPer / 100) * fileNamesNotDownloaded.length) + ((downloadedPer / 100) * fileNamesDownloaded.length)) / files.length) * 100;
        var comp = false;
        if (per == 100) {
          comp = true;
        }
        callback(per, comp, f);
      }
    }

    void downloadCallback(double per, bool comp, List<File?>? files) {
      notDownloadedPer = per;
      fileCallback(null);
    }

    // we're using a hash for the filename so we don't have to worry about getting an identical file error
    // dude you mentioned that like 3 times now, WE GET IT, YOU USE A HASH FOR THE FILE NAMES!
    for (var i = 0; i < urls.length; i++) {
      if (urls[i] != null) {
        fileNames.add("${sha1.convert(utf8.encode(urls[i]!)).toString()}${getExtension(urls[i]!)}");
      }
    }

    // this is pretty self explanatory, checks if the files exist then downloads them if they don't
    List<FileDownloadStatus> filesExist = await fileCache.checkFilesExists(sanitizedDir, fileNames);
    for (var i = 0; i < filesExist.length; i++) {
      if (filesExist[i].downloaded) {
        // we've got this 'd' here to keep track of where in the list these files were
        // if we don't keep track of the files, it can get really messy
        d.add(i);
        fileNamesDownloaded.add(fileNames[i]);
        urlsDownloaded.add(urls[i]);
      } else {
        // and same with the 'nd'
        nd.add(i);
        fileNamesNotDownloaded.add(fileNames[i]);
        urlsNotDownloaded.add(urls[i]);
      }
    }
    List<File?> downloaded = [];
    List<File?> notDownloaded = [];
    if (fileNamesDownloaded.length > 0) {
      // We need to get the files first to avoid unnecessarily calling retrieveFiles twice
      downloaded.addAll(await fileCache.retrieveFiles(sanitizedDir, fileNamesDownloaded));

      if (isConnected) {
        // this checker is a lot more chunky then the single file version,
        // but it's all in the name of efficiency
        if (checkFileForModifications) {
          List<Future<http.Response>> futureResponses = [];
          List<String?> lastModsHead = []; // this is the server HEAD
          List<DateTime> lastModsLocal = []; // and this is for the local file
          List<String?> urlsToUpdate = [];
          List<String> namesToUpdate = [];
          // need to keep track of the position in the download list incase the user doesn't want to do it in the background
          List<int> indexInDownloadedList = [];

          downloaded.forEach((file) async {
            lastModsLocal.add(await file!.lastModified());
          });

          try {
            urlsDownloaded.forEach((url) {
              futureResponses.add(http.head(Uri.parse(url!)).catchError((e) {
                print("Future error handling is the worst! $e");
              }));
            });
          } catch (e) {
            print("caught error while getting heads: $e");
          }

          try {
            var responses = await Future.wait(futureResponses);

            responses.forEach((response) {
              if (response != null) {
                lastModsHead.add(response.headers["last-modified"]);
              }
            });
          } catch (e) {
            print("caught error while getting heads: $e");
          }
          // if all of these don't sync up, we're f*cked
          if (lastModsHead.length == urlsDownloaded.length && lastModsHead.length == fileNamesDownloaded.length && lastModsHead.length == lastModsLocal.length) {
            for (var i = 0; i < lastModsHead.length; i++) {
              DateTime remoteFileUpdatedDTS;
              if (lastModsHead[i] != null) {
                try {
                  remoteFileUpdatedDTS = DateTime.parse(lastModsHead[i]!);
                } catch (FormatException) {
                  // maybe it's formatted differently to what standard parse expects,
                  // like this instead ? : 'Tue, 23 Feb 2021 00:17:59 GMT'
                  // remoteFileUpdatedDTS ??= _parseRfc822(lastModsHead[i]);
                  remoteFileUpdatedDTS = DateFormat("EEE, d MMM yyyy hh:mm:ss 'GMT'").parse(lastModsHead[i]!, true);
                  // if not then the exception will happen anyway ..
                }

                if (lastModsLocal[i].isBefore(remoteFileUpdatedDTS)) {
                  // again, need this incase of !updateFileInBackground
                  indexInDownloadedList.add(i);
                  urlsToUpdate.add(urlsDownloaded[i]);
                  namesToUpdate.add(fileNamesDownloaded[i]);
                }
              }
            }
            if (updateFileInBackground) {
              fileCache.cacheFiles(
                urlsToUpdate,
                sanitizedDir,
                namesToUpdate,
                allowNullFiles: allowNullFiles,
                onFileError: (w) {
                  if (onFileError != null) {
                    print("calling onFileError with $w");
                    onFileError(w);
                    return null;
                  }
                },
              );
            } else {
              // grab the new files
              var freshFiles = await fileCache.cacheFiles(
                urlsToUpdate,
                sanitizedDir,
                namesToUpdate,
                allowNullFiles: allowNullFiles,
                onFileError: (w) {
                  if (onFileError != null) {
                    print("calling onFileError with $w");
                    onFileError(w);
                    return null;
                  }
                },
              );

              // replace the outdated files with the new ones
              if (freshFiles.length == indexInDownloadedList.length) {
                for (var i = 0; i < freshFiles.length; i++) {
                  downloaded[indexInDownloadedList[i]] = freshFiles[i];
                }
              }
            }
          } else {
            if (onFileError != null) {
              onFileError(Error(3020, "while downloading or updating files"));
            }
            throw Exception("got ${lastModsHead.length} from server and ${fileNamesDownloaded.length} from cache while the requested amount was ${urls.length}\n URLS: $urls\n");
          }
        }
      }
      downloadedPer = 100;

      fileCallback(null);
    }
    if (fileNamesNotDownloaded.length > 0 && isConnected) {
      notDownloaded.addAll(await fileCache.cacheFiles(
        urlsNotDownloaded,
        sanitizedDir,
        fileNamesNotDownloaded,
        context: context,
        callback: downloadCallback,
        allowNullFiles: allowNullFiles,
        skip404: skip404,
        onFileError: (w) {
          if (onFileError != null) {
            print("calling onFileError with $w");
            onFileError(w);
            return null;
          }
        },
      ));
    }
    if ((nd.length != notDownloaded.length) || (d.length != downloaded.length)) {
      if (onFileError != null) {
        onFileError(Error(3010, "Could not retrieve all requested files. Ensure the device has enough space and is online."));
        return null;
      } else {
        throw Exception(
          """
          Could not retrieve all requested files.
          Ensure the device has enough space and is online.
          This happens when the length of the list<file> requested and the length of the list<file> downloaded / retrieved from the file system were not the same.
          """,
        );
      }
    }
    for (var i = 0; i < files.length; i++) {
      // this is making sure everything all goes back where it's supposed to
      if (d.contains(i)) {
        files[i] = downloaded[d.indexOf(i)];
      } else if (nd.contains(i)) {
        files[i] = notDownloaded[nd.indexOf(i)];
      }
    }
    fileCallback(files);
    return files;
  }

  Future<List<File>> filesFromDirectory(String directory) async {
    String dir = (await getApplicationDocumentsDirectory()).path;

    return Directory("$dir/$directory/").list().toList().then((value) {
      List<File> files = [];

      value.forEach((element) {
        files.add(File(element.path));
      });
      return files;
    });
  }

  /// takes the data from the db and converts it to a map the ccAppMenus can understand
  Map<String, List> parseMenus(Map data) {
    Map<String, List> menus = {
      "leftSide": [],
      "bottom": [],
      "homeScreen": [],
      "intro": [],
    };
    data.forEach((k, v) {
      v = jsonDecode(v["dataJson"]);
      if (v["type"] == null) {
        throw ("ERROR \"type\" could not be found in $v");
      }
      if (v["type"] == "leftSide") {
        menus["leftSide"]!.add(v);
      } else if (v["type"] == "bottom") {
        menus["bottom"]!.add(v);
      } else if (v["type"] == "homeScreen") {
        menus["homeScreen"] = [v];
      } else if (v["type"] == "intro") {
        menus["intro"] = [v];
      } else {
        throw ("parseMenus Error: Unknown menu ${v['type']}");
      }
    });
    return menus;
  }

  /// takes the data from the db and converts it to a map the ccStyler can understand
  Map<String, String?> parseStyle(Map data) {
    Map<String, String?> style = {};
    data.forEach((k, v) {
      v = jsonDecode(v["dataJson"]);
      style['${v["name"]}'] = v["value"];
    });
    return style;
  }
}
