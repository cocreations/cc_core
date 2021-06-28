// import 'dart:async';
// import 'dart:convert';
// import 'dart:io' show File;

// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:cc_core/components/downloadInfo.dart';
// import 'package:cc_core/models/core/ccApp.dart';
// import 'package:cc_core/models/core/ccData.dart';
// import 'package:cc_core/models/soundtrails/stWalkData.dart';
// import 'package:cc_core/screens/stScreens/stDetailsScreen.dart';
// import 'package:cc_core/utils/widgetParser.dart';

// /// just a normal
// /// ## TiledListScreen
// class TiledListScreen extends StatefulWidget {
//   TiledListScreen(
//     this.tableName, {
//     this.soundtrailDataOverride,
//     this.forceUpdateData,
//   });
//   final String tableName;

//   /// Overrides the soundtrail list
//   final List<StWalkData> soundtrailDataOverride;

//   /// this will force a state rebuild with the new data provided.
//   ///
//   /// Expects:
//   /// ```dart
//   /// {
//   ///   "imagesOverride": imagesOverride,
//   ///   "listItemDataOverride": listItemDataOverride,
//   /// }
//   /// ```
//   ///
//   /// In order to use [forceUpdateData], [soundtrailDataOverride] must not be null.
//   final Stream<Map> forceUpdateData;

//   @override
//   _TiledListScreenState createState() => _TiledListScreenState();
// }

// class _TiledListScreenState extends State<TiledListScreen> {
//   Widget display = Center(child: CircularProgressIndicator());

//   // I think I need to replace these with a new animation
//   // nah that one works

//   bool isLoaded = false;
//   // I swear the amount of times I've used this set up ^

//   // I was going to add all these to one list of maps, but it doesn't deal with dynamic type very well
//   List<Widget> listItems = [];
//   List<String> imageUrls = [];
//   List<Map> listItemData = []; // this is the data that the list uses to build itself
//   List<File> images = [];
//   List<StWalkData> soundtrailData = [];

//   StreamSubscription<Map> dataOverride;

//   bool soundtrailFilesDownloaded = false;

//   Widget list;

//   void _openPage(NavigatorState navigator, Widget widget, String title) {
//     navigator.push(
//       // test this tomorrow
//       MaterialPageRoute(
//         // we need to use a scaffold so we have a back button
//         builder: (BuildContext context) => Scaffold(
//           body: widget,
//           appBar: AppBar(
//             title: Text(
//               title != null ? title : "",
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: CcApp.of(context).styler.appBarBackground,
//             iconTheme: IconThemeData(
//               color: CcApp.of(context).styler.appBarButtonColor,
//             ),
//             centerTitle: true,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     if (dataOverride != null) dataOverride.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isLoaded) {
//       if (widget.soundtrailDataOverride != null) {
//         isLoaded = true;

//         listItemData.clear();
//         images.clear();

//         soundtrailData = widget.soundtrailDataOverride;

//         widget.soundtrailDataOverride.forEach((stWalkData) {
//           listItemData.add(stWalkData.listItemData);
//           images.add(stWalkData.image);
//         });

//         if (widget.forceUpdateData != null) {
//           dataOverride = widget.forceUpdateData.listen(
//             (event) {
//               listItemData.clear();
//               images.clear();

//               event["soundtrailDataOverride"].forEach((stWalkData) {
//                 listItemData.add(stWalkData.listItemData);
//                 images.add(stWalkData.image);
//               });

//               setState(() {
//                 soundtrailData = event["soundtrailDataOverride"];
//               });
//             },
//             onError: (e) {
//               print("Stream error in TiledListScreen:\n$e");
//             },
//             cancelOnError: false,
//           );
//         }
//       }
//     }

//     Future<List> getData() async {
//       CcData data = CcData(CcApp.of(context).database);
//       // grab the data from the new table
//       Map dbData = await data.getDBData(widget.tableName, CcApp.of(context).dataSource);

//       List vals = List.from(dbData.values);

//       List returnValues = [];

//       for (var val in vals) {
//         val = jsonDecode(val["dataJson"]);

//         returnValues.add(val); // so I don't have to loop through the array twice
//         // get the image file for later ues

//         if (val["tileImageUrl"] != null && val["tileImageUrl"] != "") {
//           imageUrls.add(val["tileImageUrl"]);
//         } else {
//           imageUrls.add("https://i.redd.it/sequence_lhtq7kjhlpp21.png");
//         }
//       }
//       // if (returnValues.first.containsKey("soundtrailKmlFileUrl")) {
//       //   for (var val in returnValues) {
//       //     imageUrls.add(val["soundtrailKmlFileUrl"]);
//       //   }
//       // }

//       return returnValues;
//     }

//     void gotImages(List<File> files) {
//       if (mounted) {
//         setState(() {
//           images = files;
//           isLoaded = true;
//         });
//       }
//     }

//     Widget showSoundtrailDistance(int soundtrailDataIndex) {
//       if (soundtrailData[soundtrailDataIndex] != null) {
//         if (soundtrailData[soundtrailDataIndex].distanceFromUser != null) {
//           if (soundtrailData[soundtrailDataIndex].distanceFromUser <= 100) {
//             return Positioned(
//               left: 10,
//               bottom: 10,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//                 child: Text(
//                   "${soundtrailData[soundtrailDataIndex].distanceFromUser.ceil()} km",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.orange,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             );
//           }
//           if (soundtrailData[soundtrailDataIndex].distanceFromUser <= 1000) {
//             return Positioned(
//               left: 10,
//               bottom: 10,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//                 child: Text(
//                   "${soundtrailData[soundtrailDataIndex].distanceFromUser.ceil()} km",
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[300],
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             );
//           }
//         }
//       }
//       return Container();
//     }

//     if (isLoaded) {
//       return AnimatedSwitcher(
//         child: GridView.builder(
//           key: ValueKey(listItems.length),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             crossAxisSpacing: 10,
//             mainAxisSpacing: 10,
//           ),
//           padding: EdgeInsets.all(10),
//           shrinkWrap: true,
//           itemCount: listItemData.length,
//           itemBuilder: (BuildContext context, int i) {
//             Stream<double> downloadBar;
//             if (soundtrailData.isNotEmpty) {
//               if (soundtrailData[i] != null) {
//                 if (soundtrailData[i].name == listItemData[i]["name"]) {
//                   downloadBar = soundtrailData[i].downloadHandler.percentage;
//                 }
//               }
//             }
//             // soundtrailData

//             // make a new tile
//             return InkWell(
//               key: Key(listItemData[i]["name"].toString()),
//               onTap: () {
//                 if (soundtrailData[i] != null) {
//                   _openPage(
//                     Navigator.of(context),
//                     StDetailsScreen(stWalkData: soundtrailData[i]),
//                     listItemData[i]["name"],
//                   );
//                 } else {
//                   _openPage(
//                     Navigator.of(context),
//                     WidgetParser(
//                       listItemData[i]["appScreen"],
//                       listItemData[i]["appScreenParam"],
//                     ),
//                     listItemData[i]["name"],
//                   );
//                 }
//               },
//               child: Stack(
//                 alignment: AlignmentDirectional.bottomCenter,
//                 children: [
//                   Stack(
//                     // make the nice little image with a text overlay
//                     // (this is where the image file comes in)
//                     alignment: AlignmentDirectional.center,
//                     children: <Widget>[
//                       images[i] != null
//                           ? Image.file(
//                               images[i],
//                               fit: BoxFit.cover,
//                               width: 300,
//                               height: 300,
//                             )
//                           : Image.asset("assets/missing-image-placeholder.jpg"),
//                       Container(
//                         color: Colors.black54,
//                         width: double.maxFinite,
//                         padding: EdgeInsets.symmetric(vertical: 5),
//                         child: Text(
//                           listItemData[i]["name"] != null ? listItemData[i]["name"] : "",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: "Montserrat",
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   showSoundtrailDistance(i),
//                   downloadBar != null
//                       ? Container(
//                           height: 5,
//                           child: DownloadInfo(
//                             downloadBar,
//                             () {
//                               if (mounted) setState(() {});
//                             },
//                             showOn0Percent: false,
//                             showOnComplete: false,
//                             onChange: () {
//                               if (mounted) setState(() {});
//                             },
//                             overrideColour: soundtrailData[i].downloadHandler.processing == Processing.update ? Colors.green : Colors.orange,
//                           ),
//                         )
//                       : Container(),
//                 ],
//               ),
//             );
//           },
//         ),
//         switchOutCurve: Curves.easeOutExpo,
//         switchInCurve: Curves.fastOutSlowIn,
//         transitionBuilder: (child, animation) => FadeTransition(
//           child: child,
//           opacity: animation,
//         ),
//         duration: Duration(milliseconds: 300),
//       );
//     } else {
//       getData().then((vals) {
//         if (mounted) {
//           CcData(CcApp.of(context).database).getFiles(imageUrls, widget.tableName, context).then((value) => gotImages);
//           setState(() {
//             listItemData = vals;
//           });
//         }
//       });
//     }
//     return Center(child: CircularProgressIndicator());
//   }
// }
