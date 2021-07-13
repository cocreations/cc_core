import 'dart:async';
import 'dart:io' show File, Directory, FileSystemEntity;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cc_core/components/errors.dart';
import 'package:path_provider/path_provider.dart';

/// ### FileDownloadStatus
/// Is this file downloaded ?
class FileDownloadStatus {
  String fileName;
  int downloadedPercentage = 0; // not currently used
  bool downloaded;

  FileDownloadStatus(this.fileName, this.downloaded);
}

/// ## FileCache
/// Caches files... what'd you expect?
class FileCache {
  FileCache();

  /// downloads a file and caches it to a specific folder
  /// returns null if it fails
  Future<File?> cacheFile(String url, String folderName, String fileName) async {
    // do a http get to grab the file
    http.Response? response;

    try {
      response = await http.get(Uri.parse(url));
    } catch (e, stacktrace) {
      print("failed to get file: $e\nStacktrace: $stacktrace");
    }

    if (response == null) return null;

    if (response.statusCode == 200) {
      Directory path = await getApplicationDocumentsDirectory();
      // make the directory if it doesn't exist
      Directory folder = await Directory("${path.path}/$folderName").create();
      // finally make a new file
      File file = await File('${folder.path}/$fileName').create();
      // and add the http response data to it
      file.writeAsBytesSync(response.bodyBytes);
      return file;
    } else {
      // oh no! the status code wasn't 200
      print("ERROR: http error ${response.statusCode}");
      return null;
    }
  }

  /// downloads a list of files and caches them to a specific folder
  /// returns null if it fails
  Future<List<File?>> cacheFiles(
    List<String?> urls,
    String folderName,
    List<String> fileNames, {
    BuildContext? context,
    void Function(double, bool, List<File?>?)? callback,
    bool skip404 = false,

    /// If true, any files that cannot be retrieved will be null
    bool allowNullFiles = false,

    /// This will be called if there is an error getting a certain file
    ///
    /// If this is null an exception will be thrown
    void Function(Error)? onFileError,
  }) async {
    if (urls.length < 1 || fileNames.length < 1) {
      return [];
    }

    Directory path = await getApplicationDocumentsDirectory();

    Directory folder = await Directory("${path.path}/$folderName").create();

    List<File?> files = List<File?>.filled(urls.length, null, growable: true);

    int loops = 0;
    bool complete = false;
    void callbackHandler() {
      loops++;
      double per = loops / urls.length;
      if (loops >= urls.length) {
        complete = true;
      }
      if (callback != null) {
        callback(per, complete, null);
      }
      if (complete) {
        if (callback != null) {
          callback(per, complete, files);
        }
      }
    }

    List<Future> fileFutures = [];

    Future runFuture(int i) async {
      // this is a bit of a weird one, but basically I need to run this code asynchronously
      // but I also need to ensure it's all complete by the end
      // so I'm just running this function in a loop and adding the resulting futures to a list
      // which then gets awaited with Future.wait();
      http.Response val;

      try {
        val = await http.get(Uri.parse(urls[i]!));
      } catch (e) {
        if (onFileError != null) {
          onFileError(Error(3020, "$e"));
          if (allowNullFiles) return;
        }
        return Future.error(Exception("error fetching files, EXCEPTION: $e"));
      }

      // just need to make sure we didn't have any problems

      if (val == null) {
        if (onFileError != null) {
          onFileError(Error(3020, "http.get(${urls[i]}) returned null. I didn't even know this was possible."));
        } else {
          throw Exception("http.get(${urls[i]}) straight up didn't work");
        }
      }

      if (val.statusCode == 200) {
        // finally make a new file
        files[i] = await File('${folder.path}/${fileNames[i]}').create();

        // and add the http response data to it
        files[i]!.writeAsBytesSync(val.bodyBytes);
        callbackHandler();
      } else if (val.statusCode == 404 && skip404) {
        if (onFileError != null) {
          onFileError(Error(3011, val.request!.url.toString()));
        }
        callbackHandler();
      } else {
        if (onFileError != null) {
          onFileError(Error(3020, "${val.request!.url.toString()} returned with a ${val.statusCode}"));
          if (allowNullFiles) return;
        }
        return Future.error(Exception("error fetching files, URL: ${urls[i]}, returned ${val.statusCode}"));
      }
    }

    for (var i = 0; i < urls.length; i++) {
      fileFutures.add(runFuture(i));
    }

    await Future.wait(fileFutures);

    return files;
  }

  /// retrieves a list of files from the file system
  Future<List<File>> retrieveFiles(String folderName, List<String> fileNames) async {
    Directory path = await getApplicationDocumentsDirectory();
    List<File> files = <File>[];

    for (var fileName in fileNames) {
      files.add(File('${path.path}/$folderName/$fileName'));
    }
    return files;
  }

  /// retrieves a specific file from the file system
  Future<File> retrieveFile(String folderName, String fileName) async {
    Directory path = await getApplicationDocumentsDirectory();
    File file = File('${path.path}/$folderName/$fileName');
    return file;
  }

  /// checks if a file exists, best to use this before trying to access it.
  Future<bool> checkFileExists(String folderName, String fileName) async {
    Directory path = await getApplicationDocumentsDirectory();
    // check file
    bool isFile = await FileSystemEntity.isFile('${path.path}/$folderName/$fileName');
    return isFile;
  }

  /// checks if a file exists, best to use this before trying to access it.
  Future<List<FileDownloadStatus>> checkFilesExists(
    String folderName,
    List<String> fileNames,
  ) async {
    List<FileDownloadStatus> result = [];

    Directory path = await getApplicationDocumentsDirectory();
    // check file
    for (var fileName in fileNames) {
      // if one of the files fails we just return a false
      bool gotThisOne = await FileSystemEntity.isFile('${path.path}/$folderName/$fileName');
      result.add(FileDownloadStatus(fileName, gotThisOne));
    }
    return result;
  }

  /// Returns the size of the file in kilobytes (1024 bytes)
  ///
  /// If the file doesn't exist, it will return 0
  Future<double> getFileSize(String folderName, String fileName) async {
    bool fileExists = await checkFileExists(folderName, fileName);
    if (!fileExists) return 0;

    Directory path = await getApplicationDocumentsDirectory();

    File file = File('${path.path}/$folderName/$fileName');

    return file.length().then((length) => length / 1024);
  }

  /// Returns a list of file sizes in kilobytes (1024 bytes)
  ///
  /// If a file doesn't exist, it will return 0
  Future<List<double>> getFilesSize(
    String folderName,
    List<String> fileNames,
  ) async {
    List<double> fileSizes = List.generate(fileNames.length, (_) => 0);

    Directory path = await getApplicationDocumentsDirectory();

    List<Future> fileSizeFutures = [];

    for (var i = 0; i < fileSizes.length; i++) {
      File file = File('${path.path}/$folderName/${fileNames[i]}');
      fileSizeFutures.add(file.length().then((length) {
        if (length > 0) {
          fileSizes[i] = length / 1024;
        }
      }));
    }

    await Future.wait(fileSizeFutures);

    return fileSizes;
  }

  /// Deletes a file, returns true if success, else returns false
  Future<bool> deleteFile(String folderName, String fileName) async {
    Directory path = await getApplicationDocumentsDirectory();
    if (!await FileSystemEntity.isFile('${path.path}/$folderName/$fileName')) return true;
    FileSystemEntity file = await File('${path.path}/$folderName/$fileName').delete(recursive: true);
    if (file.existsSync()) return false;

    return true;
  }

  /// deletes files, throws if it fails
  Future<void> deleteFiles(
    String folderName,
    List<String> fileNames,
  ) async {
    Directory path = await getApplicationDocumentsDirectory();
    for (var fileName in fileNames) {
      if (!await FileSystemEntity.isFile('${path.path}/$folderName/$fileName')) continue;
      FileSystemEntity file = await File('${path.path}/$folderName/$fileName').delete(recursive: true);
      if (file.existsSync()) return Future.error("failed to delete ${path.path}/$folderName/$fileName");
    }
  }
}
