import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cc_core/components/downloadInfo.dart';
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

  Widget newTile(
    String name,
    String appScreen,
    String appScreenParam,
    File image,
  ) {
    return Container(
      width: 300,
      height: 70,
      color: Colors.grey[100],
      margin: EdgeInsets.all(3),
      child: InkWell(
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
        child: Row(
          children: <Widget>[
            image != null
                ? Image.file(
                    image,
                    fit: BoxFit.fitHeight,
                    height: 70,
                    width: 70,
                  )
                : Container(height: 70, width: 70),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                name != null ? name : "",
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
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
      returnValues.add(val); // so I don't have to loop through the array twice
      // get the image file for later ues
      if (val["tileImageUrl"] != null && val["tileImageUrl"] != "") {
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
              listItems.add(newTile(vals[i]["name"], vals[i]["appScreen"], vals[i]["appScreenParam"], images[i]));
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
