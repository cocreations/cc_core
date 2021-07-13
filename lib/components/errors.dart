import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/models/core/errorsList.dart';

class Errors {
  Errors(this.errors);
  final List<Error> errors;

  displayWidget() {
    return ListView(children: errors);
  }

  /// Takes a list of Errors and displays them as a popup
  ///
  /// get the list of errors from [buildErrors]
  Future<void> displayErrorsPopup(BuildContext context, {void Function()? onClose, void Function()? onRetry}) async {
    try {
      return showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: ListView(
              shrinkWrap: true,
              children: [
                Column(children: errors),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      onPressed: () {
                        if (onClose != null) onClose();
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        onRetry != null ? "Cancel" : "Close",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    onRetry != null
                        ? FlatButton(
                            onPressed: () {
                              onRetry();
                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              "Retry",
                              style: TextStyle(color: Colors.black),
                            ),
                            color: Colors.orange,
                          )
                        : Container()
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error loading displayErrorsPopup(): $e");
    }
  }
}

class PrettyError extends StatelessWidget {
  PrettyError(this.code, this.description);

  /// the error code to use
  ///
  /// since the error codes are relatively smart,
  /// I probably won't need any more info other than a description
  final int code;

  /// the aforementioned description
  final String description;

  Future<void> displayErrorPopup(BuildContext context, {void Function()? onClose, void Function()? onRetry}) async {
    try {
      return showDialog(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                build(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      onPressed: () {
                        if (onClose != null) onClose();
                        Navigator.pop(dialogContext);
                      },
                      child: Text(
                        onRetry != null ? "Cancel" : "Close",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    onRetry != null
                        ? FlatButton(
                            onPressed: () {
                              onRetry();
                              Navigator.pop(dialogContext);
                            },
                            child: Text(
                              "Retry",
                              style: TextStyle(color: Colors.black),
                            ),
                            color: Colors.orange,
                          )
                        : Container()
                  ],
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Error loading displayErrorsPopup(): $e");
    }
  }

  @override
  String toString({
    TextTreeConfiguration? parentConfiguration,
    DiagnosticLevel minLevel = DiagnosticLevel.info,
  }) {
    String errorInfo = ErrorsList.getErrorInfo(code, description);
    return "${ErrorsList.getErrorInfo(code, "", true)} [Code $code: $errorInfo]";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            children: [
              Center(child: Icon(Icons.error_outline, color: Colors.black38)),
              Text(
                "  ${ErrorsList.getErrorInfo(code, "", true).trim()}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(
            description,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// ## A single error
class Error extends StatelessWidget {
  Error(this.code, this.property, [this.data]);

  /// the error code to use
  final int code;

  /// the property or data or other thing that caused the error
  ///
  /// the name of a missing image for instance
  ///
  /// I didn't really know what to name this so I hope you understand what I'm rambling about
  final String property;

  /// any other data that needed to be included like... well I don't actually know.
  /// You'll know when the time comes to use it.
  final String? data;

  PrettyError toPrettyError([String? description]) {
    if (description != null) {
      return PrettyError(code, description);
    }
    return PrettyError(code, property);
  }

  @override
  String toString({
    TextTreeConfiguration? parentConfiguration,
    DiagnosticLevel minLevel = DiagnosticLevel.info,
  }) {
    String errorInfo = ErrorsList.getErrorInfo(code, property);
    return "Code $code: $errorInfo\n";
  }

  Widget build(BuildContext context) {
    String errorInfo = ErrorsList.getErrorInfo(code, property);

    return Container(
      padding: EdgeInsets.all(20),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            children: [
              Icon(Icons.error, color: Colors.red[800]),
              Text(
                "Error code: $code",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
          Text(
            "$errorInfo",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
