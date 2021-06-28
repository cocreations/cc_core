import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:sentry/sentry.dart';

/// We use Sentry to capture errors in the app
/// This class also includes device information in the generated Sentry Exception, if available

class MyAppError {

  static Future<Event> sentryEvent(Exception exception, StackTrace stack) async {

    // also output to the log for local debugging
    print('EXCEPTION : $exception');
    print(stack);

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    /// return Event with IOS extra information to send it to Sentry
    if (Platform.isIOS) {
      final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return Event(
        extra: <String, dynamic>{
          'name': iosDeviceInfo.name,
          'model': iosDeviceInfo.model,
          'systemName': iosDeviceInfo.systemName,
          'systemVersion': iosDeviceInfo.systemVersion,
          'localizedModel': iosDeviceInfo.localizedModel,
          'utsname': iosDeviceInfo.utsname.sysname,
          'identifierForVendor': iosDeviceInfo.identifierForVendor,
          'isPhysicalDevice': iosDeviceInfo.isPhysicalDevice,
        },
        exception: exception,
        stackTrace: stack,
      );
    }

    /// return Event with Andriod extra information to send it to Sentry
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return Event(
        extra: <String, dynamic>{
          'type': androidDeviceInfo.type,
          'model': androidDeviceInfo.model,
          'device': androidDeviceInfo.device,
          'id': androidDeviceInfo.id,
          'androidId': androidDeviceInfo.androidId,
          'brand': androidDeviceInfo.brand,
          'display': androidDeviceInfo.display,
          'hardware': androidDeviceInfo.hardware,
          'manufacturer': androidDeviceInfo.manufacturer,
          'product': androidDeviceInfo.product,
          'version': androidDeviceInfo.version.release,
          'supported32BitAbis': androidDeviceInfo.supported32BitAbis,
          'supported64BitAbis': androidDeviceInfo.supported64BitAbis,
          'supportedAbis': androidDeviceInfo.supportedAbis,
          'isPhysicalDevice': androidDeviceInfo.isPhysicalDevice,
        },
        exception: exception,
        stackTrace: stack,
      );
    }

    /// Return standard Error in case of non-specifed paltform
    ///
    /// if there is no detected platform, 
    /// just return a normal event with no extra information 
    return Event(
      exception: exception,
      stackTrace: stack,
    );
  }

}
