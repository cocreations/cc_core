library cc_core;

import 'package:flutter/material.dart';
import 'package:cc_core/config/appConfig.dart';
import 'package:cc_core/models/core/ccAppBuilder.dart';

export 'package:cc_core/utils/parserModule.dart';
export 'package:cc_core/config/appConfig.dart';

class CcCore {
  static Widget buildCcApp(ConfigData configData) {
    return CcAppBuilder(configData);
  }
}
