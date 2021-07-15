import 'dart:io';

import 'package:cc_core/models/core/ccTranslationLayer.dart';
import 'package:cc_core/models/core/customAppData.dart';
import 'package:cc_core/utils/parserModule.dart';

class ConfigData {
  ConfigData({
    this.dataSource,
    this.configSource,
    this.appName,
    this.appData,
    this.parserModules,
    this.cacheRefresh = 1440,
    this.translationLayer,
  });

  /// Data source effectively the location of all the data the app will use to populate itself.
  /// So this will be things like building a home screen with a list of tiles that lead to images and things.
  ///
  ///
  /// Data source takes a map with either 2 or 3 values, depending on what backend type you want to use.
  /// The first key is
  /// ``` dart
  /// "backendType": "",
  /// ```
  /// the value can either be
  /// * asset
  /// * firebase
  /// * airTable
  ///
  /// ## Asset
  /// Asset will take .json files and use them as if they are tables in an 'external' database.
  /// This isn't recommended as the database, and by extension the app, cant update dynamically without a app store / play store update.
  /// The other key for asset is `folderPath` and that will take a path from the top level app directory into whatever folder you wish.
  /// This directory must be in pubspec.yaml though.
  ///
  /// The final dataSource will look something like this
  ///
  /// ``` dart
  /// {
  /// "backendType": "asset",
  /// "folderPath": "assets/bundledFiles/"
  /// }
  /// ```
  ///
  /// ## Firebase
  /// Firebase uses a cloud firestore database and only needs a base id to operate.
  /// Keep in mind there is no security here, and the firebase db needs to be publicly accessible.
  ///
  /// The final dataSource will look something like this
  ///
  /// ``` dart
  /// {
  /// "backendType": "firebase",
  /// "baseId": "my-amazing-app"
  /// }
  /// ```
  ///
  /// ## AirTable
  /// AirTable is a nocode database solution that makes it really easy to build databases and prototype quickly.
  /// AirTable does have a limit of 5 requests per second which makes it a bad choice for a production database.
  /// AirTable needs a base id and an [api key](https://airtable.com/api) to operate.
  ///
  /// The final dataSource will look something like this
  ///
  /// ``` dart
  /// {
  /// "backendType": "airTable",
  /// "baseId": "appMYAWESOMEAPP",
  /// "apiKey": "keyTOTALLYAREALKEY"
  /// }
  /// ```
  ///
  final Map<String, String>? dataSource;

  /// Config source effectively the location of the layout and style data.
  ///
  /// This is where the app looks for the `menu` and `style` tables.
  ///
  /// Config source is the same as data source as it takes a map with either 2 or 3 values, depending on what backend type you want to use.
  /// The first key is
  /// ``` dart
  /// "backendType": "",
  /// ```
  /// the value can either be
  /// * asset
  /// * firebase
  /// * airTable
  ///
  /// ## Asset
  /// Asset will take .json files and use them as if they are tables in an 'external' database.
  /// This is the best solution for this kind of data as it's fast and rarely updated.
  /// The other key for asset is `folderPath` and that will take a path from the top level app directory into whatever folder you wish.
  /// This directory must be in pubspec.yaml though.
  ///
  /// The final dataSource will look something like this
  ///
  /// ``` dart
  /// {
  /// "backendType": "asset",
  /// "folderPath": "assets/bundledFiles/"
  /// }
  /// ```
  ///
  /// ## Firebase
  /// Firebase uses a cloud firestore database and only needs a base id to operate.
  /// Keep in mind there is no security here, and the firebase db needs to be publicly accessible.
  /// And this also may lead to a slow initial startup time.
  ///
  /// The final dataSource will look something like this
  ///
  /// ``` dart
  /// {
  /// "backendType": "firebase",
  /// "baseId": "my-amazing-app"
  /// }
  /// ```
  ///
  /// ## AirTable
  /// AirTable is a nocode database solution that makes it really easy to build databases and prototype quickly.
  /// AirTable does have a limit of 5 requests per second, on top of the fact it isn't as fast as local makes making it a bad choice for production environments.
  /// AirTable needs a base id and an [api key](https://airtable.com/api) to operate.
  ///
  /// The final dataSource will look something like this
  ///
  /// ``` dart
  /// {
  /// "backendType": "airTable",
  /// "baseId": "appMYAWESOMEAPP",
  /// "apiKey": "keyTOTALLYAREALKEY"
  /// }
  /// ```
  ///
  final Map<String, String>? configSource;

  /// This is just the name of the app. Used for things like database file names and things.
  final String? appName;

  /// This allows you to make an app-wide custom app state to augment and extend the capabilities of CcApp.
  final CustomAppData? appData;

  /// These allow you to add your own widgets and screens into the json widget parser.
  final ParserModules? parserModules;

  /// How often the cache should refresh its data in minutes.
  /// Defaults to 1440 which is one day.
  ///
  /// The cache will still be used after the set time has passed if the app can't get an internet connection.
  /// But it will prioritize getting fresh data if it can.
  final int cacheRefresh;

  /// The path to the translation layer json file.
  ///
  /// Example: `"lib/translationLayer.json"`
  ///
  /// Remember to add the path to the assets section in pubspec.yaml
  /// ```yaml
  ///   assets:
  ///     - lib/translationLayer.json
  /// ```
  ///
  /// The translation layer that sits between the data / config source and the app.
  /// This can be used to parse data and allow the app to use databases that weren't originally intended to be used by the app.
  /// For more information, check the README.md
  final String? translationLayer;
}
