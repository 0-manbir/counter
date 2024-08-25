import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:counter/variables.dart';
import 'package:counter/main.dart';
import 'package:counter/util/counter_item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  _CounterAppState createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  List<CounterItem> items = [];
  List<FocusNode> focusNodes = [];

  bool isPopupOpen = false;
  int popupIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  _loadItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemsJson = prefs.getString('counterItems');
    if (itemsJson != null) {
      List<dynamic> itemsList = json.decode(itemsJson);
      setState(() {
        items = itemsList.map((item) => CounterItem.fromJson(item)).toList();
        focusNodes = List.generate(items.length, (_) => FocusNode());
        _addFocusListeners();
      });
    }
  }

  _saveItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String itemsJson = json.encode(items.map((item) => item.toJson()).toList());
    await prefs.setString('counterItems', itemsJson);
  }

  void _addFocusListeners() {
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (!focusNodes[i].hasFocus) {
          _updateItemName(i, items[i].name);
        }
      });
    }
  }

  void _addItem() {
    setState(() {
      items.add(CounterItem(name: ''));
      focusNodes.add(FocusNode());
      _addFocusListeners();
      _saveItems();
      focusNodes.last.requestFocus();
    });
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
      focusNodes.removeAt(index);
      _saveItems();
    });
  }

  void _incrementCount(int index) {
    setState(() {
      items[index].count++;
      _saveItems();
    });
  }

  void _decrementCount(int index) {
    setState(() {
      items[index].count--;
      _saveItems();
    });
  }

  void _updateItemName(int index, String newName) {
    setState(() {
      items[index].name = newName.isEmpty ? "Count" : newName;
      _saveItems();
    });
  }

  void _showAsPopup(int index) async {
    // is Normal View------------------------------
    if (isPopupOpen) {
      setState(() {
        isPopupOpen = false;
        popupIndex = -1;
      });
      doWhenWindowReady(() {
        const initialSize = defaultWindowSize;
        appWindow.minSize = const Size(0, 0);
        appWindow.size = initialSize;
        appWindow.title = "Simple Counter";
        appWindow.show();
      });

      await windowManager.ensureInitialized();
      windowManager.setAlwaysOnTop(false);

      return;
    }

    // is Popup View-------------------------------
    setState(() {
      isPopupOpen = true;
      popupIndex = index;
    });

    doWhenWindowReady(() {
      const initialSize = popupWindowSize;
      appWindow.minSize = popupWindowMinSize;
      appWindow.size = initialSize;
      appWindow.show();
    });

    await windowManager.ensureInitialized();
    windowManager.setAlwaysOnTop(true);
  }

  @override
  Widget build(BuildContext context) {
    return isPopupOpen
        ? MoveWindow(
            child: listItem(context, popupIndex, true),
            onDoubleTap: () {},
          )
        : Scaffold(
            body: Column(
              children: [
                // App Bar
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: WindowTitleBarBox(
                    child: Row(
                      children: [
                        Expanded(
                          child: MoveWindow(
                            child: Row(
                              children: [
                                const SizedBox(width: 12.0),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => _addItem(),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6.0,
                                        horizontal: 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        color: Colors.grey[200],
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.add_rounded,
                                            size: 16.0,
                                            color: Colors.black,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            "New Item",
                                            style: TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "Simple Counter",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                        const WindowButtons(),
                      ],
                    ),
                  ),
                ),

                // Main App Body
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Text(
                            "Add an Item!",
                            style: TextStyle(
                              fontSize: 26.0,
                              color: Colors.grey[300],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return listItem(context, index, false);
                          },
                        ),
                ),
              ],
            ),
          );
  }

  Widget listItem(BuildContext context, int index, bool isPopupView) {
    return GestureDetector(
      child: Container(
        padding:
            isPopupView ? null : const EdgeInsets.symmetric(horizontal: 12.0),
        margin: isPopupView
            ? null
            : const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
        decoration: BoxDecoration(
          borderRadius: isPopupView ? null : BorderRadius.circular(25.0),
          color: isPopupView ? Colors.transparent : counterItemBG,
        ),
        child: Row(
          children: [
            isPopupView
                ? Container()
                : MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.grey[600],
                        size: 24.0,
                      ),
                      onTap: () => _deleteItem(index),
                    ),
                  ),
            const SizedBox(width: 8.0),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: isPopupView
                    ? Text(
                        items[index].name,
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[700],
                        ),
                      )
                    : TextField(
                        controller:
                            TextEditingController(text: items[index].name),
                        focusNode: focusNodes[index],
                        onChanged: (newName) {
                          items[index].name = newName;
                        },
                        decoration: InputDecoration(
                          labelText: 'Item Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 8.0),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Icon(
                        Icons.open_in_new_rounded,
                        size: isPopupView ? 24.0 : 26.0,
                        color: Colors.grey[600],
                      ),
                      onPanDown: (details) => _showAsPopup(index),
                    ),
                  ),
                  const Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Icon(
                        Icons.remove_circle_rounded,
                        size: 32.0,
                        color: Colors.red[200],
                      ),
                      onPanDown: (details) => _decrementCount(index),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${items[index].count}',
                      style: TextStyle(
                        fontSize: isPopupView ? 20.0 : 24.0,
                        color: Colors.grey[800],
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: Icon(
                        Icons.add_circle_rounded,
                        size: 32.0,
                        color: Colors.green[200],
                      ),
                      onPanDown: (details) => _incrementCount(index),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
