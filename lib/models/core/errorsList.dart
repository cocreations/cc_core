/*
  Basic error code structure
  1*** you messed up (the user did something wrong)
  2*** they messed up (the info the app was given is incorrect)
  3*** I messed up (everything should have gone fine but the app didn't do what it was supposed to)
  4*** the device up (everything should have gone fine but the device didn't do what it was supposed to)
  add more later...

  Unlike warnings, errors are a lot more generic.
  So instead of having a code for every little thing,
  theres gonna be different codes for different error types.

  There's one more difference with this structure, instead of every error code being written explicitly,
  they are gonna be generated based on the first number, the middle two numbers, and the last number.

  so it'll go something like this:

  [3][02][0]
   |  |   |
   |  |   -------- more specific sub error relating to the error type. E.g. 301[2] could be "file corrupted"
   |  ------------ general error type. An error type table can be found below
   --------------- who caused the error, so 1 is the user, 2 is the dev, or whoever set up the app, and 3 is the app it self

  *01*: file error
  *02*: network error
  *03*: database error

  ***1: not found
  ***2: corrupted
  ***3: timed out
*/

class ErrorsList {
  static String getErrorInfo(int code, String data, [bool pretty = false]) {
    String codeString = code.toString();

    int who = int.parse(codeString[0]);
    int error = int.parse(codeString[1] + codeString[2]);
    int subError = int.parse(codeString[3]);

    //  0 = generic

    const Map<int, String> whoMap = {
      0: "Something has gone wrong, ",
      1: "Input error occurred, ",
      2: "Build error occurred, ",
      3: "App error occurred, ",
      4: "Device error occurred, ",
    };

    const Map<int, String> errorMap = {
      0: "unexpected",
      1: "file",
      2: "network",
      3: "database",
    };

    const Map<int, String> subErrorMap = {
      0: " error: ",
      1: " not found: ",
      2: " corrupted: ",
      3: " timed out: ",
    };

    // remember to update this if you add more errors
    if (who <= 4 && error <= 3 && subError <= 3) {
      if (pretty) {
        return "${errorMap[error]} error.\n$data";
      }
      return "${whoMap[who]}${errorMap[error]}${subErrorMap[subError]}$data";
    }
    throw Exception(
      "Seriously? You got an error on displaying errors? you idiot.",
    );
  }
}
