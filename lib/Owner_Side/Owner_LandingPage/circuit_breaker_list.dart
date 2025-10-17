// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/circuit_breaker_tile.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/nav_home.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/statistics_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

  // Changed from hardcoded list to dynamic list from Firebase
  List<Map<String, dynamic>> bracketList = [];
  bool isLoading = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCircuitBreakers();
  }

  Future<void> _fetchCircuitBreakers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      currentUserId = user.uid;

      // Listen to circuit breakers in real-time
      _dbRef.child('circuitBreakers').onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data == null) {
          setState(() {
            bracketList = [];
            isLoading = false;
          });
          return;
        }

        List<Map<String, dynamic>> loadedCBs = [];

        data.forEach((key, value) {
          final cbData = Map<String, dynamic>.from(value as Map);
          // Only load circuit breakers owned by current user
          if (cbData['ownerId'] == currentUserId) {
            loadedCBs.add({
              'scbId': key,
              'scbName': cbData['scbName'] ?? 'Unknown',
              'isOn': cbData['isOn'] ?? false,
              'circuitBreakerRating': cbData['circuitBreakerRating'] ?? 0,
              'voltage': cbData['voltage'] ?? 0,
              'current': cbData['current'] ?? 0,
              'temperature': cbData['temperature'] ?? 0,
              'power': cbData['power'] ?? 0,
              'energy': cbData['energy'] ?? 0,
              'latitude': cbData['latitude'] ?? 0.0,
              'longitude': cbData['longitude'] ?? 0.0,
              'wifiName': cbData['wifiName'] ?? '',
            });
          }
        });

        setState(() {
          bracketList = loadedCBs;
          isLoading = false;
        });
      });
    } catch (e) {
      print('Error fetching circuit breakers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Switch Changed - Update Firebase
  Future<void> switchChanged(bool? value, int index) async {
    final cb = bracketList[index];
    final newState = !cb['isOn'];

    // Optimistically update UI
    setState(() {
      bracketList[index]['isOn'] = newState;
    });

    try {
      // Update in Firebase
      await _dbRef
          .child('circuitBreakers')
          .child(cb['scbId'])
          .update({'isOn': newState});
    } catch (e) {
      // Revert on error
      setState(() {
        bracketList[index]['isOn'] = !newState;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating circuit breaker: $e')),
      );
    }
  }

  void _saveForUndo() {
    // Undo functionality disabled for now with Firebase
    // Can be implemented with local state management if needed
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
                              Text(
                                "Edit Mode  |  ",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
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
                                            (item) => item['scbName'] as String,
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
                                onTap: () async {
                                  // Delete selected circuit breakers from Firebase
                                  for (var cb in bracketList) {
                                    if (selectedBracketNames
                                        .contains(cb['scbName'])) {
                                      await _dbRef
                                          .child('circuitBreakers')
                                          .child(cb['scbId'])
                                          .remove();
                                    }
                                  }
                                  setState(() {
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
                      : isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2ECC71),
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.only(top: 0, bottom: 120),
                                itemCount: bracketList.length,
                                itemBuilder: (context, index) {
                                  final cb = bracketList[index];
                                  return CircuitBreakerTile(
                                    bracketName: cb['scbName'],
                                    turnOn: cb['isOn'],
                                    onChanged: (value) =>
                                        switchChanged(value, index),
                                    isEditMode: isEditMode,
                                    isSelected: selectedBracketNames.contains(
                                      cb['scbName'],
                                    ),
                                    onCheckboxChanged: (checked) {
                                      setState(() {
                                        final name = cb['scbName'];
                                        if (checked == true) {
                                          selectedBracketNames.add(name);
                                        } else {
                                          selectedBracketNames.remove(name);
                                        }
                                      });
                                    },
                                    cbData: cb, // Pass complete CB data
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
                                selectedBracketNames.clear();
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
                            child: Text('Done', textAlign: TextAlign.center),
                            onPressed: () {
                              setState(() {
                                isEditMode = false;
                                selectedBracketNames.clear();
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
