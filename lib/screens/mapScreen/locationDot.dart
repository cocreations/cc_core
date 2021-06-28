// import 'dart:async';
// import 'dart:math';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/plugin_api.dart';
// import 'package:latlong/latlong.dart';
// import 'package:flutter_compass/flutter_compass.dart';
// // import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
// import 'package:permission_handler/permission_handler.dart';

// class LocationDot {
//   LatLng latLng;
//   double direction = 0.0;
//   bool trackingDirection = false;
//   int iosBackgroundTaskId;
//   StreamSubscription<double> compass;
//   void Function(LatLng) _onLocationUpdate;
//   void Function(double) _onDirectionUpdate;

//   Future<void> init([
//     BuildContext context,
//     void Function(LatLng) onLocationUpdate,
//     void Function(double) onDirectionUpdate,
//   ]) async {
//     _onLocationUpdate = onLocationUpdate;
//     _onDirectionUpdate = onDirectionUpdate;

//     if (await Permission.location.isUndetermined) {
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (dContext) => AlertDialog(
//           backgroundColor: Color(0xFF000000),
//           title: Text(
//             "Location permissions",
//             style: TextStyle(color: Colors.orange),
//           ),
//           content: SingleChildScrollView(
//             child: Text(
//               "Soundtrails uses location and background location to enable location-based activation of audio stories even when the screen is switched off or the app is closed.\nSoundtrails also uses ${Platform.isIOS ? "Motion & Fitness" : "Physical Activity"} for more accurate location and better power efficiency.\nLocation data doesn't leave the device and doesn't get stored anywhere.",
//               style: TextStyle(color: Colors.orange),
//             ),
//           ),
//           actions: [
//             ElevatedButton(
//               onPressed: () async {
//                 await Permission.location.request();
//                 Navigator.of(dContext).pop();
//               },
//               child: Text("Allow background location"),
//               style: ElevatedButton.styleFrom(primary: Colors.orange),
//             ),
//           ],
//         ),
//       );
//     }

//     await bg.BackgroundGeolocation.ready(bg.Config(
//       desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
//       distanceFilter: 0,
//       fastestLocationUpdateInterval: 2000,
//       activityType: bg.Config.ACTIVITY_TYPE_OTHER,
//       isMoving: true,
//       stationaryRadius: 25,
//       notification: bg.Notification(
//         smallIcon: "drawable/ic_launcher_foreground",
//       ),
//       // if android, be satisfied with "When is use" location access
//       locationAuthorizationRequest: Platform.isAndroid ? "WhenInUse" : "Always",

//       backgroundPermissionRationale: bg.PermissionRationale(
//         message: "This app uses location data to enable accurate activation of audio stories when the display is switched off. Location data doesn't leave the device and doesn't get stored anywhere.",
//       ),
//     ));

//     await bg.BackgroundGeolocation.start().catchError((e) => print("GOT ERROR IN LOCATIONDOT.dart $e"));

//     if (Platform.isIOS) {
//       iosBackgroundTaskId = await bg.BackgroundGeolocation.startBackgroundTask();
//     }

//     bg.BackgroundGeolocation.onLocation((event) {
//       if (latLng == null) latLng = LatLng(0, 0);

//       // we cant just make a new instance of latLng otherwise `locationDot.latLng` will just return the old instance

//       final double lat = event.coords.latitude;
//       final double lng = event.coords.longitude;

//       latLng.latitude = lat;
//       latLng.longitude = lng;

//       if (_onLocationUpdate != null) _onLocationUpdate(LatLng(lat, lng));
//     }, (e) {
//       // Don't throw an error here - this will happen, and it is no fault of the code
//       // throw Exception("Error in bg.BackgroundGeolocation.onLocation $e");
//       print("Error in bg.BackgroundGeolocation.onLocation $e"); // instead
//       // Here are reasons why it could happen (from background_geolocation.dart)
//       // ## Error Codes
//       //
//       // | Code  | Error                       |
//       // |-------|-----------------------------|
//       // | 0     | Location unknown            |
//       // | 1     | Location permission denied  |
//       // | 2     | Network error               |
//       // | 408   | Location timeout            |

//       // TODO: NB: It might be nice to pop up a dialogue if the error code is 1 - and tell them we need access
//     });

//     compass = FlutterCompass.events.listen((event) {
//       if (event == null) {
//         trackingDirection = false;
//       } else {
//         direction = event;
//         trackingDirection = true;
//         if (_onDirectionUpdate != null) _onDirectionUpdate(event);
//       }
//     });
//     compass.onError((e) => trackingDirection = false);
//   }

//   double calcAngle(dir) {
//     // Original comment : don't mind the magic numbers. They work, that's all you need to know
//     // and that calc was off by a 1/4 of a circle so adjust it thus :
//     // NB: This is improved, but still terrible - it sometimes just jumps,
//     // I think this is a failing of the plugin ... needs further investigation and work

//     // I have found the plugin only uses the phones compass so it has no way of correcting for
//     // magnetic interference.
//     // I'm not really sure how it's supposed to be fixed.
//     if (dir == null) return 0;

//     dir += 90;
//     if (dir > 360) dir -= 360;
//     var angle = dir / 180 * pi;
//     return angle;
//   }

//   /// Stop location tracking
//   void dispose() {
//     if (iosBackgroundTaskId != null) bg.BackgroundGeolocation.stopBackgroundTask(iosBackgroundTaskId);
//     bg.BackgroundGeolocation.stop();
//     if (compass != null) compass.cancel();
//     bg.BackgroundGeolocation.destroyLocations();
//     _onLocationUpdate = null;
//     _onDirectionUpdate = null;
//   }

//   MarkerLayerOptions showMarker() {
//     if (latLng == null) {
//       latLng = LatLng(0, 0);
//       print("latLng was null");
//     }

//     if (latLng.latitude == 0.0 && latLng.longitude == 0.0) {
//       Permission.location.isGranted.then((hasLocation) {
//         if (hasLocation) {
//           bg.BackgroundGeolocation.getCurrentPosition().then((value) => null);
//         }
//       });
//     }

//     return MarkerLayerOptions(
//       markers: [
//         Marker(
//           height: 100,
//           width: 100,
//           point: latLng,
//           builder: (ctx) => Stack(
//             alignment: Alignment.center,
//             children: [
//               trackingDirection
//                   ? ClipOval(
//                       child: Transform.rotate(
//                         angle: calcAngle(direction),
//                         child: CustomPaint(
//                           size: Size(100.0, 100.0),
//                           painter: ConePainter(
//                             Colors.orange[400],
//                           ),
//                         ),
//                       ),
//                     )
//                   : Container(),
//               Container(
//                 height: 30,
//                 width: 30,
//                 decoration: BoxDecoration(
//                   color: Colors.orange[400],
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//               ),
//               Container(
//                 height: 16,
//                 width: 16,
//                 decoration: BoxDecoration(
//                   color: Colors.orange[800],
//                   borderRadius: BorderRadius.circular(20.0),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // this was shamelessly stolen from user_location_plugin
// class ConePainter extends CustomPainter {
//   ConePainter(this.color);
//   final Color color;
//   @override
//   void paint(Canvas canvas, Size size) {
//     // create a bounding square, based on the centre and radius of the arc
//     Rect rect = Rect.fromCircle(
//       center: Offset(50.0, 50.0),
//       radius: 40.0,
//     );

//     // a fancy rainbow gradient
//     final Gradient gradient = RadialGradient(
//       stops: [
//         0.3,
//         1.0,
//       ],
//       colors: [
//         color.withAlpha(250),
//         color.withAlpha(50),
//       ],
//     );

//     // create the Shader from the gradient and the bounding square
//     final Paint paint = new Paint()..shader = gradient.createShader(rect);

//     // and draw an arc
//     canvas.drawArc(rect, pi * 6 / 8, pi * 3 / 8, true, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return oldDelegate != this;
//   }
// }
