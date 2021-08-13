class TextUtils {
  /// Parses a scv into a list while ignoring escaped commas (\,)
  static List<String> parseParam(String? appScreenParam) {
    if (appScreenParam == null) {
      return [];
    }

    String string = appScreenParam.replaceAll("\\,", "##COMMA##");
    List<String> list = string.split(",");

    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].replaceAll("##COMMA##", ",");
    }

    return list;
  }
}
