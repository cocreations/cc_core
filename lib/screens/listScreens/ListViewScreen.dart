import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:cc_core/screens/listScreens/listItemStyle.dart';
import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccData.dart';
import 'package:cc_core/utils/widgetParser.dart';

class ListViewScreen extends StatefulWidget {
  ListViewScreen(this.tableName);
  final String tableName;

  @override
  _ListViewScreenState createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  Widget display = Center(
    child: CircularProgressIndicator(),
  ); // I think I need to replace these with a new animation
  // nah, you're fine. I think that works

  List<Widget> listItems = [];
  List<String> imageUrls = [];
  List<ListItemStyle> listItemStyle = [];

  void _openPage(NavigatorState navigator, Widget widget, String title) {
    navigator.push(
      // test this tomorrow
      MaterialPageRoute(
        // we need to use a scaffold so we have a back button
        builder: (BuildContext context) => Scaffold(
          body: widget,
          appBar: AppBar(
            title: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: CcApp.of(context).styler.appBarBackground,
            iconTheme: IconThemeData(
              color: CcApp.of(context).styler.appBarButtonColor,
            ),
            centerTitle: true,
          ),
        ),
      ),
    );
  }

  Widget tileContent(
    String name,
    String appScreen,
    String appScreenParam,
    File image,
    ListItemStyle style,
    bool showAppScreenOnCard,
  ) {
    if (showAppScreenOnCard) {
      return WidgetParser(appScreen, appScreenParam);
    }
    List<Widget> stack = [];
    stack.add(Row(
      children: <Widget>[
        image != null
            ? Image.file(
                image,
                fit: BoxFit.fitHeight,
                height: style.imageSize,
                width: style.imageSize,
              )
            : Container(
                height: style.imageSize,
                width: style.imageSize,
              ),
        Container(
          margin: EdgeInsets.only(left: 20),
          child: Text(
            name != null ? name : "",
            style: TextStyle(
              fontFamily: "Roboto",
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ));
    if (appScreen != null) {
      stack.add(Material(
        color: Colors.transparent,
        child: InkWell(
          hoverColor: Colors.black12.withOpacity(0.5),
          focusColor: CcApp.of(context).styler.primaryColor.withOpacity(0.2),
          splashColor: CcApp.of(context).styler.primaryColor.withOpacity(0.2),
          highlightColor: Colors.black12,
          borderRadius: BorderRadius.all(Radius.circular(style.cornerRadius)),
          key: Key(name),
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
    return Stack(children: stack);
  }

  Widget newTile(
    String name,
    String appScreen,
    String appScreenParam,
    File image,
    ListItemStyle style,
    bool showAppScreenOnCard,
  ) {
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
        width: MediaQuery.of(context).size.width * 0.85,
        color: Colors.grey[100],
        height: style.imageSize,
        child: tileContent(name, appScreen, appScreenParam, image, style, showAppScreenOnCard),
      ),
    );
  }

  Future<List> getData() async {
    CcData data = CcData(CcApp.of(context).database);
    // grab the data from the new table
    Map dbData = await data.getDBData(widget.tableName, CcApp.of(context).dataSource);
    List vals = List.from(dbData.values);
    List returnValues = [];
    for (var val in vals) {
      val = jsonDecode(val["dataJson"]);

      // making this a bool based on the two options
      val["displayAppScreen"] = val["displayAppScreen"] == "asCardContent";

      returnValues.add(val); // so I don't have to loop through the array twice
      // get the image file for later ues

      listItemStyle.add(ListItemStyle.parseStyle(val["style"]));

      // if val["displayAppScreen"] is true, it means we don't need to see the image, so just get the 404 image
      // efficacy needs to be improved here
      if ((val["tileImageUrl"] != null && val["tileImageUrl"] != "") || !val["displayAppScreen"]) {
        imageUrls.add(val["tileImageUrl"]);
      } else {
        imageUrls.add("https://i.redd.it/sequence_lhtq7kjhlpp21.png");
      }
    }

    return returnValues;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) {
      getData().then((vals) {
        if (mounted) {
          CcData(CcApp.of(context).database).getFiles(imageUrls, widget.tableName, context).then((images) {
            listItems = [];
            for (var i = 0; i < vals.length; i++) {
              listItems.add(newTile(vals[i]["name"], vals[i]["appScreen"], vals[i]["appScreenParam"], images[i], listItemStyle[i], vals[i]["displayAppScreen"]));
            }
            if (mounted) {
              setState(() {
                display = ListView(
                  padding: EdgeInsets.all(10),
                  shrinkWrap: true,
                  children: listItems,
                );
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return display;
  }
}
