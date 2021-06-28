// import 'dart:async';
// import 'dart:convert';
// import 'dart:io' show File;

// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:cc_core/components/downloadInfo.dart';
// import 'package:cc_core/models/core/ccApp.dart';
// import 'package:cc_core/models/core/ccData.dart';
// import 'package:cc_core/models/soundtrails/stWalkData.dart';
// import 'package:cc_core/screens/stScreens/stDetailsScreen.dart';
// import 'package:cc_core/utils/widgetParser.dart';
// import 'package:cc_core/models/soundtrails/stApp.dart';

// class ListViewScreen extends StatefulWidget {
//   ListViewScreen(
//     this.tableName, {
//     this.slideActions,
//     this.soundtrailDataOverride,
//     this.forceUpdateData,
//   });
//   final String tableName;

//   /// WARNING: id won't exist unless you have [soundtrailDataOverride] set
//   final List<Widget> Function(String itemId, void Function()) slideActions;

//   /// Overrides the soundtrail list
//   final List<StWalkData> soundtrailDataOverride;

//   /// this will force a state rebuild with the new data provided.
//   ///
//   /// Expects:
//   /// ```dart
//   /// {
//   ///   "soundtrailDataOverride": soundtrailDataOverride,
//   /// }
//   /// ```
//   ///
//   /// In order to use [forceUpdateData], [soundtrailDataOverride] must not be null.
//   final Stream<Map> forceUpdateData;

//   @override
//   _ListViewScreenState createState() => _ListViewScreenState();
// }

// class _ListViewScreenState extends State<ListViewScreen> {
//   Widget display = Center(
//     child: CircularProgressIndicator(),
//   ); // I think I need to replace these with a new animation
//   // nah, you're fine. I think that works
//   bool isLoaded = false;
//   // I swear the amount of times I've used this set up ^
//   List<Widget> listItems = [];
//   List<String> imageUrls = [];
//   List<StWalkData> soundtrailData = [];
//   List<Map> listItemData = [];
//   List images = [];

//   StreamSubscription<Map> dataOverride;

//   List<List<bool>> stSwipeList;

//   bool loadedAllData = false;

//   Widget list;

//   String listType;

//   void onSlideButtonPressed() {
//     setState(() {
//       loadedAllData = false;
//     });
//   }

//   void _openPage(NavigatorState navigator, Widget widget, String title) {
//     navigator.push(
//       // test this tomorrow
//       MaterialPageRoute(
//         // we need to use a scaffold so we have a back button
//         builder: (BuildContext context) => Scaffold(
//           body: widget,
//           appBar: AppBar(
//             title: Text(
//               title,
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
//         loadedAllData = true;

//         soundtrailData = widget.soundtrailDataOverride;
//         listItemData.clear();
//         images.clear();

//         widget.soundtrailDataOverride.forEach((stWalkData) {
//           listItemData.add(stWalkData.listItemData);
//           listItemData.last["id"] = stWalkData.id;
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

//     Widget showSoundtrailDistance(int soundtrailDataIndex) {
//       if (soundtrailData[soundtrailDataIndex] != null) {
//         if (soundtrailData[soundtrailDataIndex].distanceFromUser != null) {
//           if (soundtrailData[soundtrailDataIndex].distanceFromUser <= 100) {
//             return Positioned(
//               left: 80,
//               bottom: 8,
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
//               left: 80,
//               bottom: 8,
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

//     if (isLoaded) {
//       listItems = [];
//       if (!loadedAllData) {
//         if (CcApp.of(context).appData is StApp) {
//           if (widget.soundtrailDataOverride != null) {
//             loadedAllData = true;
//           }
//         }
//       }
//       for (var i = 0; i < listItemData.length; i++) {
//         Widget desc;
//         Stream<double> downloadBar;
//         if (soundtrailData.isNotEmpty) {
//           if (soundtrailData[i] != null) {
//             if (soundtrailData[i].name == listItemData[i]["name"]) {
//               downloadBar = soundtrailData[i].downloadHandler.percentage;
//             }
//           }
//         }
//         if (CcApp.of(context).appData is StApp) {
//           if (loadedAllData) {
//             // I was gonna use a html parser but the parser doesn't have overflow,
//             // so this is the wonderful solution I came up with.
//             var text = soundtrailData[i].desc != null ? soundtrailData[i].desc : "";

//             text = text.replaceAll(RegExp(r'<.>'), "");

//             desc = Container(
//               width: 190,
//               height: 50,
//               child: Text(
//                 text,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           } else {
//             desc = Container(
//               child: CircularProgressIndicator(),
//               height: 20,
//               width: 20,
//             );
//           }
//         }
//         desc ??= Container();
//         listItems.add(
//           // make a new tile
//           Container(
//             width: 300,
//             height: 70,
//             color: Colors.grey[100],
//             margin: EdgeInsets.all(3),
//             child: Slidable(
//               actionPane: SlidableDrawerActionPane(),
//               actionExtentRatio: 0.15,
//               secondaryActions: widget.slideActions(
//                 listItemData[i]["id"],
//                 onSlideButtonPressed,
//               ),
//               child: InkWell(
//                 key: Key(listItemData[i]["name"].toString()),
//                 onTap: () {
//                   if (soundtrailData[i] != null) {
//                     _openPage(
//                       Navigator.of(context),
//                       StDetailsScreen(stWalkData: soundtrailData[i]),
//                       listItemData[i]["name"],
//                     );
//                   } else {
//                     _openPage(
//                       Navigator.of(context),
//                       WidgetParser(
//                         listItemData[i]["appScreen"],
//                         listItemData[i]["appScreenParam"],
//                       ),
//                       listItemData[i]["name"],
//                     );
//                   }
//                 },
//                 child: Stack(
//                   alignment: AlignmentDirectional.bottomCenter,
//                   children: [
//                     Row(
//                       children: <Widget>[
//                         Image.file(
//                           images[i],
//                           fit: BoxFit.fitHeight,
//                           height: 70,
//                           width: 70,
//                         ),
//                         Container(
//                           margin: EdgeInsets.only(left: 20),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                 listItemData[i]["name"] != null ? listItemData[i]["name"] : "",
//                                 style: TextStyle(
//                                   fontFamily: "Montserrat",
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               desc
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     showSoundtrailDistance(i),
//                     downloadBar != null
//                         ? Container(
//                             height: 5,
//                             child: DownloadInfo(
//                               downloadBar,
//                               () {
//                                 if (mounted) setState(() {});
//                               },
//                               showOn0Percent: false,
//                               showOnComplete: false,
//                               onChange: () {
//                                 if (mounted) setState(() {});
//                               },
//                               overrideColour: soundtrailData[i].downloadHandler.processing == Processing.update ? Colors.green : Colors.orange,
//                             ),
//                           )
//                         : Container(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//         if (mounted) {
//           setState(() {
//             isLoaded = true;
//           });
//         }
//       }

//       display = AnimatedSwitcher(
//         child: ListView(
//           key: ValueKey(listItems.length),
//           padding: EdgeInsets.all(10),
//           shrinkWrap: true,
//           children: listItems,
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
//             display = Center(
//               child: CircularProgressIndicator(),
//             );
//           });
//         }
//       });
//     }
//     return display;
//   }
// }
