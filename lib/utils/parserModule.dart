import 'package:flutter/material.dart';

/// A ParserModule is a component that allows CcApp to parse custom json and screen data.
///
/// Extend this module to add custom app specific screens to your app.
///
/// Here is an example of a Text widget ParserModule.
///
/// ```dart
///
///   class TextParserModule extends ParserModule {
///      @override
///      String get name => "text";
///
///      @override
///      Widget buildWidget(String? arg) {
///        return Text(arg);
///      }
///    }
///
/// ```
abstract class ParserModule {
  String get name;
  Widget buildWidget(String? arg);
}

/// NullParser is returned by ParserModules if it fails to parse the widget.
class NullParser extends ParserModule {
  @override
  String get name => "null";

  @override
  Widget buildWidget(String? arg) {
    return Text("Failed to parse.");
  }
}

/// This can be added to the widget parser to allow your app to parse your custom app specific json.
///
/// Simply add ParserModules with a set of your custom modules to the widget parser and you'll be good to go.
///
/// Example.
/// ``` dart
/// ParserModules modules = ParserModules({
///   TextParserModule(),
///   VideoPlayerParserModule(),
///   CameraParserModule(),
/// });
/// ```
class ParserModules {
  ParserModules(this.modules);
  final Set<ParserModule> modules;

  Widget parse(String? name, String? arg) {
    ParserModule module = modules.firstWhere((mod) => mod.name == name, orElse: () {
      print(Exception("Couldn't find module $name in modules $modules"));
      return NullParser();
    });

    return module.buildWidget(arg);
  }
}
