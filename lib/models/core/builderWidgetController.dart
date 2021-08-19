import 'dart:async';

/// This can be used to control the builder widget from outside its own state.
/// Since this widget is responsible for almost every ui aspect of the generic app,
/// it's good to have a way of exposing events that would normally be hidden.
class BuilderWidgetController {
  BuilderWidgetController() {
    updateStream = StreamController.broadcast(
      onListen: () => hasListener = true,
      onCancel: () => hasListener = false,
    );
  }

  late StreamController<BuilderPacket> updateStream;

  bool hasListener = false;

  /// Parses and displays a widget
  void displayWidget(String widget, String? arg) {
    if (hasListener) {
      updateStream.add(BuilderPacket(Command.display, arg, widget));
    }
  }

  /// Runs the intro screen if one exists
  void showIntroScreen() {
    if (hasListener) {
      updateStream.add(BuilderPacket(Command.showIntro));
    }
  }

  /// Updates the app bar with new text.
  /// Doesn't parse urls at the moment, might do that later.
  void updateAppBar(String? newText) {
    if (hasListener) {
      updateStream.add(BuilderPacket(Command.updateAppBar, newText));
    }
  }

  void dispose() {
    updateStream.close();
  }
}

class BuilderPacket {
  BuilderPacket(this.command, [this.arg, this.widget]);

  final Command command;
  final String? widget;
  final String? arg;
}

enum Command {
  display,
  showIntro,
  updateAppBar,
}
