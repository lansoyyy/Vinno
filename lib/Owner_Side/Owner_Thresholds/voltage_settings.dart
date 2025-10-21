import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/overcurrent_option.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/overpower_option.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/overvoltage_option.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/temperature_option.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/undervoltage_option.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_cb_1/services/threshold_monitor_service.dart';

class VoltageSettingsPage extends StatefulWidget {
  const VoltageSettingsPage({super.key});

  @override
  State<VoltageSettingsPage> createState() => _VoltageSettingsPageState();
}

class _VoltageSettingsPageState extends State<VoltageSettingsPage> {
  bool isExpanded = false;
  bool isChosen = false;
  Map<String, dynamic>? cbData;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool isSaving = false;

  // Threshold values (must be within slider ranges)
  double overvoltageValue = 0; // max: 300
  String overvoltageAction = 'Trip';
  double undervoltageValue = 0; // max: 300
  String undervoltageAction = 'Trip';
  double overcurrentValue = 0; // max: 150
  String overcurrentAction = 'Trip';
  double overpowerValue = 0; // max: 4000 (changed from 5000)
  String overpowerAction = 'Trip';
  double temperatureValue = 0; // max: 55 (changed from 80)
  String temperatureAction = 'Trip';

  @override
  void initState() {
    super.initState();
    // Load existing thresholds will be done after getting cbData
  }

  Future<void> _loadExistingThresholds() async {
    if (cbData == null) return;

    try {
      final snapshot = await _dbRef
          .child('circuitBreakers')
          .child(cbData!['scbId'])
          .child('thresholds')
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          if (data['overvoltage'] != null) {
            overvoltageValue = (data['overvoltage']['value'] ?? 0).toDouble();
            overvoltageAction =
                _capitalizeAction(data['overvoltage']['action'] ?? 'trip');
          }
          if (data['undervoltage'] != null) {
            undervoltageValue = (data['undervoltage']['value'] ?? 0).toDouble();
            undervoltageAction =
                _capitalizeAction(data['undervoltage']['action'] ?? 'trip');
          }
          if (data['overcurrent'] != null) {
            overcurrentValue = (data['overcurrent']['value'] ?? 0).toDouble();
            overcurrentAction =
                _capitalizeAction(data['overcurrent']['action'] ?? 'trip');
          }
          if (data['overpower'] != null) {
            overpowerValue = (data['overpower']['value'] ?? 0).toDouble();
            overpowerAction =
                _capitalizeAction(data['overpower']['action'] ?? 'trip');
          }
          if (data['temperature'] != null) {
            temperatureValue = (data['temperature']['value'] ?? 0).toDouble();
            temperatureAction =
                _capitalizeAction(data['temperature']['action'] ?? 'trip');
          }
        });
      }
    } catch (e) {
      print('Error loading thresholds: $e');
    }
  }

  // Helper method to capitalize action strings from Firebase
  String _capitalizeAction(String action) {
    if (action.isEmpty) return 'Trip';
    // Convert 'off' -> 'Off', 'alarm' -> 'Alarm', 'trip' -> 'Trip'
    return action[0].toUpperCase() + action.substring(1).toLowerCase();
  }

  // Log all threshold changes to Firestore
  Future<void> _logThresholdChanges() async {
    if (cbData == null) return;

    final scbId = cbData!['scbId'];
    final scbName = cbData!['scbName'];

    // Log each threshold change
    await ThresholdMonitorService.logThresholdChange(
      scbId: scbId,
      scbName: scbName,
      thresholdType: 'Overvoltage',
      value: overvoltageValue,
      action: overvoltageAction,
      enabled: overvoltageAction != 'Off',
    );

    await ThresholdMonitorService.logThresholdChange(
      scbId: scbId,
      scbName: scbName,
      thresholdType: 'Undervoltage',
      value: undervoltageValue,
      action: undervoltageAction,
      enabled: undervoltageAction != 'Off',
    );

    await ThresholdMonitorService.logThresholdChange(
      scbId: scbId,
      scbName: scbName,
      thresholdType: 'Overcurrent',
      value: overcurrentValue,
      action: overcurrentAction,
      enabled: overcurrentAction != 'Off',
    );

    await ThresholdMonitorService.logThresholdChange(
      scbId: scbId,
      scbName: scbName,
      thresholdType: 'Overpower',
      value: overpowerValue,
      action: overpowerAction,
      enabled: overpowerAction != 'Off',
    );

    await ThresholdMonitorService.logThresholdChange(
      scbId: scbId,
      scbName: scbName,
      thresholdType: 'Temperature',
      value: temperatureValue,
      action: temperatureAction,
      enabled: temperatureAction != 'Off',
    );
  }

  void ExpandTile(bool expanded) {
    setState(() {
      isExpanded = expanded;
    });
  }

  Future<void> _saveThresholdSettings() async {
    if (cbData == null) return;

    setState(() {
      isSaving = true;
    });

    try {
      // Save threshold configurations to Firebase with actual values
      await _dbRef
          .child('circuitBreakers')
          .child(cbData!['scbId'])
          .child('thresholds')
          .set({
        'overvoltage': {
          'enabled': overvoltageAction != 'Off',
          'value': overvoltageValue,
          'action': overvoltageAction.toLowerCase(),
        },
        'undervoltage': {
          'enabled': undervoltageAction != 'Off',
          'value': undervoltageValue,
          'action': undervoltageAction.toLowerCase(),
        },
        'overcurrent': {
          'enabled': overcurrentAction != 'Off',
          'value': overcurrentValue,
          'action': overcurrentAction.toLowerCase(),
        },
        'overpower': {
          'enabled': overpowerAction != 'Off',
          'value': overpowerValue,
          'action': overpowerAction.toLowerCase(),
        },
        'temperature': {
          'enabled': temperatureAction != 'Off',
          'value': temperatureValue,
          'action': temperatureAction.toLowerCase(),
        },
        'updatedAt': ServerValue.timestamp,
      });

      setState(() {
        isSaving = false;
      });

      // Log threshold changes to Firestore
      await _logThresholdChanges();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Threshold settings saved successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get circuit breaker data from route arguments
    if (cbData == null) {
      cbData =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      // Load existing thresholds after getting cbData
      if (cbData != null) {
        _loadExistingThresholds();
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: CustomClipPath(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2ECC71), Color(0xFF1EA557)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      height: 135,
                    ),
                  ),
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Voltage Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: isSaving ? null : _saveThresholdSettings,
                          child: Text(
                            isSaving ? 'Saving...' : 'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isSaving ? Colors.white70 : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  cbData?['scbName'] ?? 'Circuit Breaker',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

              // THRESHOLDS
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      OvervoltageSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                        initialValue: overvoltageValue,
                        initialAction: overvoltageAction,
                        onChanged: (value, action) {
                          setState(() {
                            overvoltageValue = value;
                            overvoltageAction = action;
                          });
                        },
                      ),
                      UndervoltageSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                        initialValue: undervoltageValue,
                        initialAction: undervoltageAction,
                        onChanged: (value, action) {
                          setState(() {
                            undervoltageValue = value;
                            undervoltageAction = action;
                          });
                        },
                      ),
                      OvercurrentSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                        initialValue: overcurrentValue,
                        initialAction: overcurrentAction,
                        onChanged: (value, action) {
                          setState(() {
                            overcurrentValue = value;
                            overcurrentAction = action;
                          });
                        },
                      ),
                      OverpowerSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                        initialValue: overpowerValue,
                        initialAction: overpowerAction,
                        onChanged: (value, action) {
                          setState(() {
                            overpowerValue = value;
                            overpowerAction = action;
                          });
                        },
                      ),
                      TemperatureOption(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                        initialValue: temperatureValue,
                        initialAction: temperatureAction,
                        onChanged: (value, action) {
                          setState(() {
                            temperatureValue = value;
                            temperatureAction = action;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60),

              // THRESHOLDS
            ],
          ),

          // NAVIGATION
          NavigationPage(),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 5.0),
      child: Divider(color: Color(0xFF2ECC71).withOpacity(0.5), thickness: 3.0),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    final path = Path();

    // (0,0) 1. Point
    path.lineTo(0, h - 50); //line 2
    path.quadraticBezierTo(
      w * 0.5, // 3 Point
      h, // 3 Point
      w, // 4 Point
      h - 50, // 4 Point
    ); // 4 Point
    path.lineTo(w, 0); // 5 Point
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
