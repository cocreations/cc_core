import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/models/core/warningsList.dart';

class Warnings {
  Warnings(this.warnings);
  List<Warning> warnings;

  bool get isEmpty => warnings.isEmpty;
  bool get isNotEmpty => warnings.isNotEmpty;

  Widget displayWidget() {
    return ListView(children: warnings);
  }

  /// adds a new warning to the end of the list
  void add(Warning warning) {
    warnings.add(warning);
  }

  /// Takes a list of Warnings and displays them as a popup
  ///
  /// get the list of warnings from [buildWarnings]
  void displayWarningsPopup(BuildContext context) {
    try {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: ListView(
              shrinkWrap: true,
              children: [
                Column(children: warnings),
                FlatButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    "Close",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error loading displayWarningsPopup(): $e");
    }
  }
}

/// ## A single warning
class Warning extends StatelessWidget {
  Warning(this.code, this.property, [this.triggeredBy, this.data]);

  /// the warning code to use
  final int code;

  /// the property or data or other thing that caused the warning
  ///
  /// the name of a missing image for instance
  ///
  /// I didn't really know what to name this so I hope you understand what I'm rambling about
  final String property;

  /// the object that triggered the warning
  final String triggeredBy;

  /// any other data that needed to be included like... well I don't actually know.
  /// You'll know when the time comes to use it.
  final String data;
  @override
  String toString({
    TextTreeConfiguration parentConfiguration,
    DiagnosticLevel minLevel = DiagnosticLevel.info,
  }) {
    String warningInfo = WarningsList.getWarningInfo(code, property);
    if (triggeredBy != null) {
      return "Code $code triggered by $triggeredBy: $warningInfo\n";
    }

    return "Code $code: $warningInfo\n";
  }

  Widget build(BuildContext context) {
    String warningInfo = WarningsList.getWarningInfo(code, property);

    return Container(
      padding: EdgeInsets.all(20),
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            children: [
              Icon(Icons.warning, color: Colors.yellow[600]),
              Text(
                "Warning code: $code",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(
            "$warningInfo",
            style: TextStyle(fontSize: 16),
          ),
          triggeredBy != null
              ? Text(
                  "triggered by $triggeredBy",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                )
              : Container(),
        ],
      ),
    );
  }
}
