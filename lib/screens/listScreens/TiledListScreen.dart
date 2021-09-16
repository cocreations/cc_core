import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:cc_core/screens/listScreens/tileStyle.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:cc_core/utils/widgetParser.dart';

class TiledListScreen extends StatefulWidget {
  TiledListScreen(this.tableName);
  final String? tableName;

  @override
  _TiledListScreenState createState() => _TiledListScreenState();
}

class _TiledListScreenState extends State<TiledListScreen> with WidgetsBindingObserver {
  List<Widget> listItems = [];
  List<String?> imageUrls = [];
  List<File?> images = [];
  List tileData = [];
  List<TileStyle> listItemStyle = [];

  Orientation get orientation => WidgetsBinding.instance!.window.physicalSize.aspectRatio > 1 ? Orientation.landscape : Orientation.portrait;

  @override
  void didChangeMetrics() {
    print("metrics changed");
    buildTiles();
  }

  void buildTiles() {
    listItems = [];
    for (var i = 0; i < tileData.length; i++) {
      listItems.add(
        tile(
          tileData[i]["name"],
          tileData[i]["appScreen"],
          tileData[i]["appScreenParam"],
          images[i],
          listItemStyle[i],
          tileData[i]["displayAppScreen"],
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _openPage(NavigatorState navigator, Widget widget, String? title) {
    navigator.push(
      // test this tomorrow
      MaterialPageRoute(
        // we need to use a scaffold so we have a back button
        builder: (BuildContext context) => Scaffold(
          body: widget,
          appBar: AppBar(
            title: Text(
              title!,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: CcApp.of(context)!.styler!.appBarBackground,
            iconTheme: IconThemeData(
              color: CcApp.of(context)!.styler!.appBarButtonColor,
            ),
            centerTitle: true,
          ),
        ),
      ),
    );
  }

  Widget tile(
    String? name,
    String? appScreen,
    String? appScreenParam,
    File? image,
    TileStyle style,
    bool showAppScreenOnCard,
  ) {
    if (showAppScreenOnCard) {
      return WidgetParser(appScreen, appScreenParam);
    }

    // This is all super complicated and messy.
    // But basically this is here so the image sizes will update when the device goes into landscape mode.
    // MediaQuery.of(context).size is based on the device size when in portrait mode.
    final double width = orientation == Orientation.portrait ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.height;

    List<Widget> stack = [];
    stack.add(Container(
      width: (width / 2) - 2,
      height: (width / 2) - 2,
      child: Stack(
        alignment: style.namePosition,
        children: <Widget>[
          image != null
              ? Image.file(
                  image,
                  width: (width / 2) - 2,
                  height: (width / 2) - 2,
                  fit: BoxFit.cover,
                )
              : Container(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: style.nameBackground,
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            child: Text(
              name != null ? name : "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Roboto",
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ));
    if (appScreen != null) {
      stack.add(Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Colors.black12.withOpacity(0.5),
          focusColor: CcApp.of(context)!.styler!.primaryColor.withOpacity(0.2),
          splashColor: CcApp.of(context)!.styler!.primaryColor.withOpacity(0.2),
          highlightColor: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(style.cornerRadius)),
          key: Key(name!),
          onTap: () {
            _openPage(
              Navigator.of(context),
              WidgetParser(
                appScreen,
                appScreenParam,
              ),
              name,
            );
          },
        ),
      ));
    }
    return Card(
      elevation: style.elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            style.cornerRadius,
          ),
        ),
      ),
      margin: EdgeInsets.all(3),
      child: Container(
        width: (width / 2) - 2,
        height: (width / 2) - 2,
        color: Colors.grey[100],
        child: Stack(children: stack),
      ),
    );
  }

  Future<List> getData() async {
    CcData data = CcData(CcApp.of(context)!.database);
    // grab the data from the new table

    Map? dbData = await data.getDBData(widget.tableName!, CcApp.of(context)!.dataSource);

    List vals = dbData != null ? List.from(dbData.values) : [];

    List returnValues = [];
    for (var val in vals) {
      val = jsonDecode(val["dataJson"]);

      // making this a bool based on the two options
      val["displayAppScreen"] = val["displayAppScreen"] == "asCardContent";

      returnValues.add(val); // so I don't have to loop through the array twice
      // get the image file for later ues

      listItemStyle.add(TileStyle.parseStyle(val["style"]));

      // if val["displayAppScreen"] is true, it means we don't need to see the image, so just get the 404 image
      // efficacy needs to be improved here

      if ((val["tileImageUrl"] != null && val["tileImageUrl"] != "") && !val["displayAppScreen"]) {
        imageUrls.add(val["tileImageUrl"]);
      } else {
        imageUrls.add("");
      }
    }

    return returnValues;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);

    if (widget.tableName != null) {
      Future.delayed(Duration.zero).then((_) {
        getData().then((vals) {
          tileData = vals;
          if (mounted) {
            CcData(CcApp.of(context)!.database).getFiles(imageUrls, widget.tableName!, context).then((imageFiles) {
              images = imageFiles;
              buildTiles();
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tableName == null) {
      return Container(
        child: Center(
          child: Text("No database table was supplied"),
        ),
      );
    }

    if (listItems.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2),
      children: listItems,
    );
  }
}
