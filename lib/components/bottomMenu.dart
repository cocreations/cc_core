import 'package:flutter/material.dart';
import 'package:cc_core/models/core/ccAppMenus.dart';

class BottomMenu extends StatefulWidget {
  BottomMenu(this.menuItems, this.onTap);
  final Function onTap;
  final CcAppMenus? menuItems;
  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  void _ontap(int tappedItem) {
    widget.onTap(widget.menuItems!.bottomMenu![tappedItem]);
    setState(() {
      _selectedIndex = tappedItem;
    });
  }

  int _selectedIndex = 0;
  List<BottomNavigationBarItem> items = [];

  @override
  Widget build(BuildContext context) {
    if (items.length == 0) {
      for (var menuItem in widget.menuItems!.bottomMenu!) {
        items.add(BottomNavigationBarItem(
          // label: menuItem.title,
          icon: menuItem.icon ?? Container(),
        ));
      }
    }
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      items: items,
      onTap: _ontap,
    );
  }
}
