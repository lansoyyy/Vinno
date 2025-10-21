import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_CircuitBreakerOption/bracket-on-off.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:firebase_database/firebase_database.dart';

class BracketOptionPage extends StatefulWidget {
  final Map<String, dynamic>? cbData;

  const BracketOptionPage({super.key, this.cbData});

  @override
  State<BracketOptionPage> createState() => _BracketOptionPageState();
}

class _BracketOptionPageState extends State<BracketOptionPage> {
  bool click = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool isToggling = false;

  @override
  void initState() {
    super.initState();
    // Initialize click state based on CB data
    if (widget.cbData != null) {
      click = !(widget.cbData!['isOn'] ?? true);
    }
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
      // Toggle the isOn field in Firebase
      final newIsOnValue = !(widget.cbData!['isOn'] ?? true);

      await _dbRef
          .child('circuitBreakers')
          .child(widget.cbData!['scbId'])
          .update({
        'isOn': newIsOnValue,
      });

      // Update local state
      setState(() {
        widget.cbData!['isOn'] = newIsOnValue;
        click = !newIsOnValue; // Invert for UI display
        isToggling = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newIsOnValue
              ? 'Circuit Breaker turned ON'
              : 'Circuit Breaker turned OFF'),
          duration: Duration(seconds: 2),
        ),
      );
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
                click: click,
                onPress: isToggling ? () {} : _toggleCircuitBreaker,
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
                                                    'View Voltage Settings',
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
                                                  "${widget.cbData?['power'] ?? 0}",
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
                                            Text(
                                              "Trip History",
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
