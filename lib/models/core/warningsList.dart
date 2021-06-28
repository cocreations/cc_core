/*
  Basic warning code structure
  1*** you messed up (the user did something wrong)
  2*** they messed up (the info the app was given is incorrect)
  add more later...
*/
/* 
  slightly more detailed warning structure
  11** can't setup right
  23** missing or invalid data value
  24** missing or invalid file
*/


class WarningsList {
  static getWarningInfo(int code, String data) {
    Map<int, String> codes = {
      1101: "Needs internet to update local database",
      1102: "Not enough space to download assets",
      1103: "Exception occurred: $data",

      // Document stuff
      2301: "'$data' not a valid value in Document",
      2302: "'$data' missing from Document",
      2303: "'$data' not a supported tag in Document",
      2311: "Invalid values for 'mapImageBounds' \n($data)",
      // 2307: "STX version $data isn't supported by this version of the app. App supports STX version ${StApp.stxVersion}",
      // Placemark stuff
      2304: "'$data' not a valid value in Placemark",
      2305: "'$data' missing from Placemark",
      2306: "'$data' not a supported tag in Placemark",
      // 404s
      2400: "Could not find asset at $data",
      2401: "Could not find image asset $data on remote sever.\nPlease check with support team.",
      2402: "Could not find audio asset $data on remote sever.\nPlease check with support team.",
      2405: "Could not find stx file $data on remote sever.\nPlease check with support team.",
      // Data size stuff
      2403: "Image asset $data exceeds max value before warning (1M)\nThis may increase loading times.",
      2404: "Audio asset $data exceeds max value before warning (5M)\nThis may increase loading times.",
      // Random file stuff
      2406: "File operation could not be completed.\n$data\nPlease check with support team.",
    };
    if (codes.containsKey(code)) {
      return codes[code];
    } else {
      throw Exception(
        "Seriously? You got an error on displaying errors? you idiot.",
      );
    }
  }
}
