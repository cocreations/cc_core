import 'package:flutter/material.dart';
import 'package:cc_core/components/backgroundRipple.dart';
import 'package:cc_core/models/core/ccApp.dart';
import 'package:cc_core/models/core/ccAppMenus.dart';
// import 'package:cc_core/models/soundtrails/stApp.dart';

enum DrawerType {
  standard,
  appBarBannerAtTop,
  compendiumStyle,
}

class LeftSideMenu extends StatelessWidget {
  LeftSideMenu(this.items, this.onTap, {this.customBackground});

  /// A list of objects that have an 'appScreen' parameter.
  final CcAppMenus items;

  /// An ontap event for each item in the list that passes the 'appScreen' and 'appScreenParam' through
  final void Function(String, String) onTap;

  /// A custom background for the side menu
  ///
  /// Only works for compendiumStyle for now
  final Widget Function(Widget) customBackground;

  @override
  Widget build(BuildContext context) {
    DrawerType drawerType = CcApp.of(context).styler.sideDrawerType;
    List<Widget> buttons = [Container(height: 30)];

    if (drawerType == DrawerType.appBarBannerAtTop) {
      buttons[0] = Container(height: 90, margin: EdgeInsets.only(top: 25), child: Center(child: CcApp.of(context).styler.appBarBanner));
    }

    for (var i = 0; i < items.sideMenu.length; i++) {
      Widget icon = Container();
      if (items.sideMenu[i].icon != null) {
        icon = items.sideMenu[i].icon;
        icon = Container(
          child: icon,
          margin: EdgeInsets.only(right: 40),
        );
      }
      buttons.add(
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            return onTap(
              items.sideMenu[i].screen.screenWidgetName,
              items.sideMenu[i].screen.parameter,
            );
          },
          child: Container(
            width: 300,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                icon,
                Text(
                  items.sideMenu[i].title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Shout out to Haakon for this excellent design
    if (drawerType == DrawerType.compendiumStyle) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: CcApp.of(context).styler.backgroundColor,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: customBackground != null
            ? customBackground(
                Container(
                  padding: EdgeInsets.only(left: 28, top: 28, bottom: 28),
                  child: Column(
                    children: buttons,
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.only(left: 28, top: 28, bottom: 28),
                child: Column(
                  children: buttons,
                ),
              ),
      );
    }

    return Drawer(
      child: Column(
        children: buttons,
      ),
    );
  }
}
