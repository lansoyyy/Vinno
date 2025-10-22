// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/circuit_breaker_tile.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/nav_home.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/statistics_menu.dart';

class CircuitBreakerList extends StatefulWidget {
  const CircuitBreakerList({super.key});

  @override
  State<CircuitBreakerList> createState() => _CircuitBreakerListState();
}

class _CircuitBreakerListState extends State<CircuitBreakerList> {
  bool isEditMode = false; // tracks if user is editing
  Set<String> selectedBracketNames = {}; // stores indexes of selected tiles
  late List<List<dynamic>> originalBracketList;

  List<List<List<dynamic>>> undoStack = [];
  List<List<List<dynamic>>> redoStack = [];

  List bracketList = [
    ["Kitchen", true],
    ["Hallway", false],
    ["Bathroom", true],
    ["Fridge", true],
    ["Freezer", true],
    ["Security System", true],
    ["Outdoor Lights", false],
  ];

  // Switch Changed
  void switchChanged(bool? value, int index) {
    setState(() {
      bracketList[index][1] = !bracketList[index][1];
    });
  }

  void _saveForUndo() {
    undoStack.add(bracketList.map((e) => [...e]).toList());
    redoStack.clear(); // Clear redo stack when a new action is made
  }

  // add new Bracket
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      top: 50,
                      right: 30,
                      bottom: 30,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Settings
                        if (!isEditMode)
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/settingspage');
                            },
                            child: Icon(Icons.settings, size: 30),
                          ),

                        if (isEditMode)
                          Row(
                            children: [
                              // Undo Changes
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (undoStack.isNotEmpty) {
                                      redoStack.add(
                                        bracketList.map((e) => [...e]).toList(),
                                      );
                                      bracketList = undoStack.removeLast();
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.undo_rounded,
                                  size: 30,
                                  color: undoStack.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),

                              Text(
                                '|',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20,
                                ),
                              ),

                              // Redo Changes
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (redoStack.isNotEmpty) {
                                      undoStack.add(
                                        bracketList.map((e) => [...e]).toList(),
                                      );
                                      bracketList = redoStack.removeLast();
                                    }
                                  });
                                },
                                child: Icon(
                                  Icons.redo_rounded,
                                  size: 30,
                                  color: redoStack.isNotEmpty
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),

                        Text(
                          isEditMode ? "Edit Breakers" : "Circuit Breakers",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // Edit Bracket Button
                        if (!isEditMode)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isEditMode = true;
                                selectedBracketNames.clear();

                                //Copy of BracketList
                                originalBracketList =
                                    bracketList.map((e) => [...e]).toList();
                              });
                            },
                            child: Icon(Icons.edit, size: 30),
                          ),

                        // Delete Bracket/s Button
                        if (isEditMode)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Select All
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedBracketNames.length <
                                        bracketList.length) {
                                      // Select all
                                      selectedBracketNames = bracketList
                                          .map<String>(
                                            (item) => item[0] as String,
                                          )
                                          .toSet();
                                    } else {
                                      // Deselect all
                                      selectedBracketNames.clear();
                                    }
                                  });
                                },
                                child: Column(
                                  children: [
                                    Icon(
                                      selectedBracketNames.length ==
                                              bracketList.length
                                          ? Icons.check_box_rounded
                                          : Icons
                                              .check_box_outline_blank_rounded,
                                      size: 30,
                                      color: selectedBracketNames.length ==
                                              bracketList.length
                                          ? Colors.black.withOpacity(0.7)
                                          : Colors.black.withOpacity(0.5),
                                    ),
                                    Text(
                                      'All',
                                      style: TextStyle(
                                        color: selectedBracketNames.length ==
                                                bracketList.length
                                            ? Colors.black
                                            : Colors.black.withOpacity(0.5),
                                        fontWeight:
                                            selectedBracketNames.length ==
                                                    bracketList.length
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: 10),

                              // Delete Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _saveForUndo();
                                    bracketList.removeWhere(
                                      (item) => selectedBracketNames.contains(
                                        item[0],
                                      ),
                                    );
                                    selectedBracketNames.clear();
                                  });
                                },
                                child: Icon(
                                  Icons.delete_rounded,
                                  size: 30,
                                  color: selectedBracketNames.isEmpty
                                      ? Colors.black.withOpacity(0.7)
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Statistics
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsMenu(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 30,
                        right: 30,
                        bottom: 10,
                      ),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Icon(
                                Icons.data_thresholding_outlined,
                                color: Colors.white,
                                size: 45,
                              ),

                              SizedBox(width: 10),

                              //Task Name
                              Text(
                                "Statistics",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF2ECC71),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                0.25,
                              ), // Shadow color
                              offset: Offset(0, 4), // Shadow position
                              blurRadius: 4, // Blur effect
                              spreadRadius: 0, // Spread effect
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Lists of Brackets
                  bracketList.isEmpty
                      // No Brackets
                      ? isEditMode
                          ? Text('')
                          : Center(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No brackets available.',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 50,
                                      ),
                                      child: Text(
                                        'Tap the plus ‘ + ‘ icon to start adding a new Smart Bracket ',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                      // There are Brackets
                      : Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 0, bottom: 120),
                            itemCount: bracketList.length,
                            itemBuilder: (context, index) {
                              return CircuitBreakerTile(
                                bracketName: bracketList[index][0],
                                turnOn: bracketList[index][1],
                                onChanged: (value) =>
                                    switchChanged(value, index),
                                isEditMode: isEditMode,
                                isSelected: selectedBracketNames.contains(
                                  bracketList[index][0],
                                ),
                                onCheckboxChanged: (checked) {
                                  setState(() {
                                    final name = bracketList[index][0];
                                    if (checked == true) {
                                      selectedBracketNames.add(name);
                                    } else {
                                      selectedBracketNames.remove(name);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                ],
              ),
              if (isEditMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.white.withOpacity(0.5),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel Button
                        Container(
                          width: 151,
                          height: 46,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: Offset(0, 4), // x, y offset
                                blurRadius: 2,
                                spreadRadius: 0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.zero,
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.black,
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.white,
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            child: Text('Cancel', textAlign: TextAlign.center),
                            onPressed: () {
                              setState(() {
                                isEditMode = false;
                                bracketList = originalBracketList
                                    .map((e) => [...e])
                                    .toList();
                                selectedBracketNames.clear();
                                redoStack.clear();
                                undoStack.clear();
                              });
                            },
                          ),
                        ),

                        // Save Button
                        Container(
                          width: 151,
                          height: 46,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: Offset(0, 4), // x, y offset
                                blurRadius: 2,
                                spreadRadius: 0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.zero,
                              ),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.black,
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.white,
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            child: Text('Save', textAlign: TextAlign.center),
                            onPressed: () {
                              setState(() {
                                isEditMode = false;
                                redoStack.clear();
                                undoStack.clear();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!isEditMode)
                // NAVIGATION ---------------------------------------------------------------------------------------------
                NavHome(),
            ],
          ),
        ),
      ),
    );
  }
}
