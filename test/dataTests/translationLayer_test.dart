import 'dart:convert';
import 'dart:io';

import 'package:cc_core/models/core/ccTranslationLayer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Test translation layer", () {
    test("table", () async {
      final layerFile = File('test/dataTests/layer.json');
      final layer = await layerFile.readAsString();

      final translator = TranslationLayer(jsonDecode(layer));

      expect(translator.getTable("songs"), "entertainment");
    });

    test("translate", () async {
      final inputFile = File('test/dataTests/input.json');
      final layerFile = File('test/dataTests/layer.json');
      final outputFile = File('test/dataTests/outputUnfiltered.json');

      final input = await inputFile.readAsString();
      final layer = await layerFile.readAsString();
      final output = await outputFile.readAsString();

      final translator = TranslationLayer(jsonDecode(layer));

      final translatedData = translator.parse(translator.standardizeTranslationData(jsonDecode(input)), "songs");

      expect(translatedData.toString(), translator.standardizeTranslationData(jsonDecode(output)).toString());
    });
  });
}
