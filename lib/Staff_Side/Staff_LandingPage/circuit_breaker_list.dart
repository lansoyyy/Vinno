// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Staff_Side/Staff_LandingPage/circuit_breaker_tile.dart';
import 'package:smart_cb_1/Staff_Side/Staff_Statistics/statistics_menu.dart';

class CircuitBreakerList extends StatefulWidget {
  const CircuitBreakerList({super.key});

  @override
  State<CircuitBreakerList> createState() => _CircuitBreakerListState();
}

class _CircuitBreakerListState extends State<CircuitBreakerList> {
  Set<String> selectedBracketNames = {}; // stores indexes of selected tiles

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
  Future<void> switchChanged(bool? value, int index) async {
    final currentState = bracketList[index][1];
    final action = currentState ? 'turn OFF' : 'turn ON';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Circuit Breaker Action'),
          content: Text(
              'Are you sure you want to $action ${bracketList[index][0]} circuit breaker?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: currentState ? Colors.red : Color(0xFF2ECC71),
              ),
              child: Text(action.toUpperCase()),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        bracketList[index][1] = !bracketList[index][1];
      });
    }
  }

  // add new Bracket
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: CircleBorder(),
        onPressed: () {
          // Navigator.pushNamed(context, '');
        },
        child: Icon(Icons.my_location_rounded, color: Colors.red),
      ),
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
                    child: Stack(
                      children: [
                        // Settings
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/settingspage');
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.settings, size: 30),
                          ),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Circuit Breakers",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                      ? Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
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
                              );
                            },
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
