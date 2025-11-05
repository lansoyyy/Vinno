import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_CircuitBreakerOption/bracket-on-off.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BracketOptionPage extends StatefulWidget {
  final Map<String, dynamic>? cbData;

  const BracketOptionPage({super.key, this.cbData});

  @override
  State<BracketOptionPage> createState() => _BracketOptionPageState();
}

class _BracketOptionPageState extends State<BracketOptionPage> {
  bool click = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isToggling = false;
  StreamSubscription<DatabaseEvent>? _servoStatusSubscription;
  StreamSubscription<DatabaseEvent>? _cbDataSubscription;
  int? tripCount;

  @override
  void initState() {
    super.initState();
    // Initialize click state based on CB data
    if (widget.cbData != null) {
      click = !(widget.cbData!['isOn'] ?? true);
    }
    // Start listening to real-time CB data updates
    _startRealtimeDataListener();
    // Load trip count
    _loadTripCount();
  }

  void _startRealtimeDataListener() {
    if (widget.cbData == null) return;

    _cbDataSubscription = _dbRef
        .child('circuitBreakers')
        .child(widget.cbData!['scbId'])
        .onValue
        .listen((event) {
      if (event.snapshot.exists && mounted) {
        final updatedData =
            Map<String, dynamic>.from(event.snapshot.value as Map);

        setState(() {
          // Update the cbData with real-time values
          updatedData.forEach((key, value) {
            widget.cbData![key] = value;
          });

          // Update the click state based on real-time isOn value
          click = !(updatedData['isOn'] ?? true);

          // Recompute power when voltage or current changes
          final voltage = (updatedData['voltage'] ?? 0).toDouble();
          final current = (updatedData['current'] ?? 0).toDouble();
          widget.cbData!['power'] = voltage * current;
        });
      }
    });
  }

  // Load trip count for this circuit breaker
  Future<void> _loadTripCount() async {
    if (widget.cbData == null) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('tripHistory')
          .where('userId', isEqualTo: user.uid)
          .where('scbId', isEqualTo: widget.cbData!['scbId'])
          .get();

      if (mounted) {
        setState(() {
          tripCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      print('Error loading trip count: $e');
    }
  }

  @override
  void dispose() {
    _servoStatusSubscription?.cancel();
    _cbDataSubscription?.cancel();
    super.dispose();
  }

  void buttonClick() {
    setState(() {
      click = !click;
    });
  }

  Future<void> _toggleCircuitBreaker() async {
    if (widget.cbData == null || isToggling) return;

    setState(() {
      isToggling = true;
    });

    try {
      // Store current state for potential rollback
      final originalIsOnValue = widget.cbData!['isOn'] ?? true;
      final newIsOnValue = !originalIsOnValue;

      // Get current servo status before toggle
      final servoSnapshot = await _dbRef
          .child('circuitBreakers')
          .child(widget.cbData!['scbId'])
          .child('servoStatus')
          .get();

      final originalServoStatus = servoSnapshot.value;

      // Toggle the isOn field in Firebase
      await _dbRef
          .child('circuitBreakers')
          .child(widget.cbData!['scbId'])
          .update({
        'isOn': newIsOnValue,
      });

      // Update local state immediately for UI responsiveness
      setState(() {
        widget.cbData!['isOn'] = newIsOnValue;
        click = !newIsOnValue; // Invert for UI display
      });

      // Show initial success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newIsOnValue
              ? 'Turning circuit breaker ON...'
              : 'Turning circuit breaker OFF...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Monitor servo status for 5 seconds
      bool servoStatusChanged = false;
      Timer? timeoutTimer;

      _servoStatusSubscription = _dbRef
          .child('circuitBreakers')
          .child(widget.cbData!['scbId'])
          .child('servoStatus')
          .onValue
          .listen((event) {
        final currentServoStatus = event.snapshot.value;

        // Check if servo status has changed from original
        if (currentServoStatus != originalServoStatus) {
          servoStatusChanged = true;
          _servoStatusSubscription?.cancel();
          timeoutTimer?.cancel();

          setState(() {
            isToggling = false;
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Circuit breaker successfully ${newIsOnValue ? 'turned ON' : 'turned OFF'}'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });

      // Set timeout for 5 seconds
      timeoutTimer = Timer(Duration(seconds: 5), () {
        _servoStatusSubscription?.cancel();

        if (!servoStatusChanged) {
          // Rollback the isOn value since servo didn't respond
          _rollbackCircuitBreakerState(originalIsOnValue);
        }
      });
    } catch (e) {
      setState(() {
        isToggling = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error toggling circuit breaker: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _rollbackCircuitBreakerState(bool originalIsOnValue) async {
    try {
      // Rollback the isOn field in Firebase
      await _dbRef
          .child('circuitBreakers')
          .child(widget.cbData!['scbId'])
          .update({
        'isOn': originalIsOnValue,
      });

      // Update local state to original
      setState(() {
        widget.cbData!['isOn'] = originalIsOnValue;
        click = !originalIsOnValue; // Invert for UI display
        isToggling = false;
      });

      // Show rollback message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Circuit breaker failed to respond. State reverted to ${originalIsOnValue ? 'ON' : 'OFF'}'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      setState(() {
        isToggling = false;
      });

      // Show error message even for rollback failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to revert circuit breaker state: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showToggleConfirmationDialog() async {
    if (widget.cbData == null) return;

    final currentState = widget.cbData!['isOn'] ?? true;
    final action = currentState ? 'turn OFF' : 'turn ON';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Circuit Breaker Action'),
          content:
              Text('Are you sure you want to $action this circuit breaker?'),
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
      await _toggleCircuitBreaker();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stack: Button to On/Off the Circuit Breaker
              BracketOnOff(
                name: widget.cbData?['scbName'] ?? 'Unknown',
                click: click,
                onPress: isToggling ? () {} : _showToggleConfirmationDialog,
              ), // height = 280
              // Options
              Container(
                height: MediaQuery.of(context).size.height * .6,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25), // Shadow color
                      offset: Offset(0, -4), // Shadow position
                      blurRadius: 4, // Blur effect
                      spreadRadius: 0, // Spread effect
                    ),
                  ],
                ),

                // Informations --------------------------------------------------------------------------
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  children: [
                                    // Voltage Section 1 ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.electric_meter_outlined,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Voltage (V)",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${widget.cbData?['voltage'] ?? 0}",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "V",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // View Voltage Button
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 155.0,
                                              height: 35,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.25),
                                                      offset: Offset(
                                                        2,
                                                        4,
                                                      ), // x, y offset
                                                      blurRadius: 4,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    5,
                                                  ), // Match button shape
                                                ),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets
                                                                    .zero),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Color(
                                                                0xFF2ECC71)),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'View Threshold Settings',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/voltagesetting',
                                                      arguments: widget.cbData,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Divider -------------------------------------------------------------------
                                    buildDivider(),

                                    // Current ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.electric_bolt_rounded,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Current (A)",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${widget.cbData?['current'] ?? 0}",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "A",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Divider -------------------------------------------------------------------
                                    buildDivider(),

                                    // Power  ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .energy_savings_leaf_outlined,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Power (W)",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${(widget.cbData?['power'] ?? 0).toStringAsFixed(1)}",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "W",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Divider -------------------------------------------------------------------
                                    buildDivider(),

                                    // Temperature  ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.thermostat_sharp,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Temperature (C)",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${widget.cbData?['temperature'] ?? 0}",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "C",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Divider -------------------------------------------------------------------
                                    buildDivider(),

                                    // Energy  ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.thermostat_sharp,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Energy (KwH)",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "${widget.cbData?['energy'] ?? 0}",
                                                  style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "KwH",
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Divider -------------------------------------------------------------------
                                    buildDivider(),

                                    // Activity Logs  ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.history, size: 30),
                                            SizedBox(width: 5),
                                            Text(
                                              "Activity Logs",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // View History Button
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 90.0,
                                              height: 35,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.25),
                                                      offset: Offset(
                                                        2,
                                                        4,
                                                      ), // x, y offset
                                                      blurRadius: 4,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    5,
                                                  ), // Match button shape
                                                ),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets
                                                                    .zero),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Color(
                                                                0xFF2ECC71)),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text('View Logs'),
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/history',
                                                      arguments: widget.cbData,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Divider -------------------------------------------------------------------
                                    buildDivider(),

                                    // Trip History  ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.electrical_services,
                                              size: 30,
                                            ),
                                            SizedBox(width: 5),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Trip History",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "Total Trips: ${tripCount ?? 0}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // View History Button
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 110.0,
                                              height: 35,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.25),
                                                      offset: Offset(
                                                        2,
                                                        4,
                                                      ), // x, y offset
                                                      blurRadius: 4,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    5,
                                                  ), // Match button shape
                                                ),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets
                                                                    .zero),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Color(
                                                                0xFF2ECC71)),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text('View History'),
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/nav_history',
                                                      arguments: widget.cbData,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Divider -------------------------------------------------------------------
                                    buildDivider(),

                                    // Trip History  ----------------------------------------------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.info_outline, size: 30),
                                            SizedBox(width: 5),
                                            Text(
                                              "About",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // View History Button
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 110.0,
                                              height: 35,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.25),
                                                      offset: Offset(
                                                        2,
                                                        4,
                                                      ), // x, y offset
                                                      blurRadius: 4,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    5,
                                                  ), // Match button shape
                                                ),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        MaterialStateProperty
                                                            .all<EdgeInsets>(
                                                                EdgeInsets
                                                                    .zero),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(
                                                                Colors.white),
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color>(Color(
                                                                0xFF2ECC71)),
                                                    shape: MaterialStateProperty
                                                        .all<
                                                            RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text('View About'),
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/about',
                                                      arguments: widget.cbData,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 50),
                                  ],
                                ), // Column
                              ), // Padding (Location Padding ends here)
                            ), // IntrinsicHeight
                          ), // ConstrainedBox
                        ); // SingleChildScrollView
                      }, // builder
                    ),

                    // NAVIGATION ---------------------------------------------------------------------------------------------
                    NavigationPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Divider(color: Colors.grey.withOpacity(0.5), thickness: 2.0),
    );
  }
}
