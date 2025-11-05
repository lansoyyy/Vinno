import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/overcurrent_option.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/overpower_option.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/overvoltage_option.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Thresholds/temperature_option.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_cb_1/services/threshold_monitor_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? userRole;

  // CB Computation Constants
  static const double STANDARD_VOLTAGE = 220.0; // Philippines standard
  static const double DEFAULT_OVERVOLTAGE = 280.0;
  static const double MAX_CB_RATING =
      100.0; // Maximum CB current rating in Amps

  // Threshold values (must be within slider ranges)
  double overvoltageValue = DEFAULT_OVERVOLTAGE; // Default: 280V, max: 400V
  String overvoltageAction = 'Trip';
  double overcurrentValue =
      20.0; // Default to 20A, will be set based on CB rating
  String overcurrentAction = 'Trip';
  double overpowerValue = 4400.0; // Default: 220V * 20A = 4400W
  String overpowerAction = 'Trip';
  double temperatureValue = 50.0; // Default: 50°C, max: 55
  String temperatureAction = 'Notify';

  // CB Rating (from database or default)
  double cbRating = 20.0; // Default 20A breaker

  @override
  void initState() {
    super.initState();
    _getUserRole();
    // Load existing thresholds will be done after getting cbData
  }

  Future<void> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check user role from Firestore
      final userData =
          await _dbRef.parent?.child('owners').child(user.uid).get();
      if (userData?.exists == true) {
        setState(() {
          userRole = 'Owner';
        });
      } else {
        final adminData =
            await _dbRef.parent?.child('admins').child(user.uid).get();
        if (adminData?.exists == true) {
          setState(() {
            userRole = 'Admin';
          });
        } else {
          setState(() {
            userRole = 'Staff';
          });
        }
      }
    }
  }

  Future<void> _loadExistingThresholds() async {
    if (cbData == null) return;

    try {
      // Load CB rating if available
      final cbSnapshot =
          await _dbRef.child('circuitBreakers').child(cbData!['scbId']).get();

      if (cbSnapshot.exists) {
        final cbInfo = Map<String, dynamic>.from(cbSnapshot.value as Map);
        cbRating =
            (cbInfo['rating'] ?? 20.0).toDouble().clamp(1.0, MAX_CB_RATING);
      }

      final snapshot = await _dbRef
          .child('circuitBreakers')
          .child(cbData!['scbId'])
          .child('thresholds')
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          if (data['overvoltage'] != null) {
            overvoltageValue =
                (data['overvoltage']['value'] ?? DEFAULT_OVERVOLTAGE)
                    .toDouble();
            overvoltageAction =
                _capitalizeAction(data['overvoltage']['action'] ?? 'trip');
          }
          if (data['overcurrent'] != null) {
            overcurrentValue =
                (data['overcurrent']['value'] ?? cbRating).toDouble();
            overcurrentAction =
                _capitalizeAction(data['overcurrent']['action'] ?? 'trip');
          } else {
            // Default overcurrent to CB rating
            overcurrentValue = cbRating;
          }
          if (data['overpower'] != null) {
            overpowerValue =
                (data['overpower']['value'] ?? (STANDARD_VOLTAGE * cbRating))
                    .toDouble();
            overpowerAction =
                _capitalizeAction(data['overpower']['action'] ?? 'trip');
          } else {
            // Default overpower = Voltage * Current
            overpowerValue = STANDARD_VOLTAGE * cbRating;
          }
          if (data['temperature'] != null) {
            temperatureValue =
                (data['temperature']['value'] ?? 50.0).toDouble();
            temperatureAction =
                _capitalizeAction(data['temperature']['action'] ?? 'notify');
          }
        });
      } else {
        // No thresholds exist, set defaults based on CB rating
        setState(() {
          overcurrentValue = cbRating;
          overpowerValue = STANDARD_VOLTAGE * cbRating;
          temperatureValue = 50.0;
        });
      }
    } catch (e) {
      print('Error loading thresholds: $e');
    }
  }

  // Helper method to capitalize action strings from Firebase
  String _capitalizeAction(String action) {
    if (action.isEmpty) return 'Trip';
    // Convert 'off' -> 'Off', 'notify' -> 'Notify', 'trip' -> 'Trip'
    if (action.toLowerCase() == 'alarm') {
      return 'Notify'; // Convert old 'alarm' to new 'notify'
    }
    return action[0].toUpperCase() + action.substring(1).toLowerCase();
  }

  // Log all threshold changes to Firestore as a summary
  Future<void> _logThresholdChanges() async {
    if (cbData == null) return;

    final scbId = cbData!['scbId'];
    final scbName = cbData!['scbName'];

    // Create a list of all threshold changes
    final List<Map<String, dynamic>> thresholdChanges = [
      {
        'thresholdType': 'Overvoltage',
        'value': overvoltageValue,
        'action': overvoltageAction,
        'enabled': overvoltageAction != 'Off',
      },
      {
        'thresholdType': 'Overcurrent',
        'value': overcurrentValue,
        'action': overcurrentAction,
        'enabled': overcurrentAction != 'Off',
      },
      {
        'thresholdType': 'Overpower',
        'value': overpowerValue,
        'action': overpowerAction,
        'enabled': overpowerAction != 'Off',
      },
      {
        'thresholdType': 'Temperature',
        'value': temperatureValue,
        'action': temperatureAction,
        'enabled': temperatureAction != 'Off',
      },
    ];

    // Log as a single summary entry
    await ThresholdMonitorService.logThresholdSettingsSummary(
      scbId: scbId,
      scbName: scbName,
      thresholdChanges: thresholdChanges,
    );
  }

  void ExpandTile(bool expanded) {
    setState(() {
      isExpanded = expanded;
    });
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Save'),
          content:
              Text('Are you sure you want to save these threshold settings?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _saveThresholdSettings(); // Proceed with saving
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
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

    // Check if user is Staff and deny access
    if (userRole == 'Staff') {
      return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Colors.grey[400],
              ),
              SizedBox(height: 20),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Only Admins and Owners can access Threshold Settings',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
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
                          'Threshold Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: isSaving ? null : _showSaveConfirmationDialog,
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
                      OvercurrentSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                        initialValue: overcurrentValue,
                        initialAction: overcurrentAction,
                        cbRating: cbRating,
                        onChanged: (value, action) {
                          setState(() {
                            overcurrentValue = value;
                            overcurrentAction = action;
                            // Auto-update overpower when overcurrent changes
                            overpowerValue = STANDARD_VOLTAGE * value;
                          });
                        },
                      ),
                      OverpowerSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                        initialValue: overpowerValue,
                        initialAction: overpowerAction,
                        cbRating: cbRating,
                        onChanged: (value, action) {
                          setState(() {
                            overpowerValue = value;
                            overpowerAction = action;
                            // Auto-update overcurrent when overpower changes
                            overcurrentValue = value / STANDARD_VOLTAGE;
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
