import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_cb_1/services/threshold_monitor_service.dart';
import 'package:smart_cb_1/util/const.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NavHome extends StatefulWidget {
  const NavHome({super.key});

  @override
  State<NavHome> createState() => _NavHomeState();
}

class _NavHomeState extends State<NavHome> {
  final ThresholdMonitorService _thresholdService = ThresholdMonitorService();
  final Set<String> _processedViolations = {};
  Timer? _locationUpdateTimer;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _setupThresholdListener();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  // Setup listener for threshold violations
  void _setupThresholdListener() {
    _thresholdService.monitorThresholds().listen((violations) {
      for (var violation in violations) {
        final violationKey =
            '${violation.scbId}_${violation.type}_${violation.isWarning}_${violation.currentValue.toStringAsFixed(1)}';

        // Only process each unique violation once
        if (!_processedViolations.contains(violationKey)) {
          _processedViolations.add(violationKey);

          print(
              'Processing violation: ${violation.type}, isWarning: ${violation.isWarning}, action: ${violation.action}');

          if (_thresholdService.shouldNotify(violation)) {
            print('Should notify: true');
            // Execute action for all violations (warnings and critical)
            // Warnings (90-99%) will log only, critical (100%+) will turn off CB
            print('Executing action: ${violation.action}');
            _thresholdService.executeThresholdAction(violation);

            // Vibrate when threshold alert is triggered
            _triggerVibration();
          } else {
            print('Should notify: false');
          }
        }
      }

      // Clean up old processed violations to prevent memory leak
      if (_processedViolations.length > 100) {
        _processedViolations.clear();
      }
    });
  }

  // Trigger vibration when threshold alert is triggered
  Future<void> _triggerVibration() async {
    // Check if the device supports vibration
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // Vibrate with a pattern: 0.5s on, 0.2s off, 0.5s on
      await Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
  }

  // Start periodic location updates every minute
  void _startLocationUpdates() {
    // Update location immediately on start
    _updateUserLocation();

    // Set up timer to update every 1 minute (60 seconds)
    _locationUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) {
        _updateUserLocation();
      },
    );
  }

  // Update user's location in Firestore
  Future<void> _updateUserLocation() async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in, skipping location update');
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permission permanently denied');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String userType = box.read('accountType') == 'Staff'
          ? 'staff'
          : box.read('accountType') == 'Owner'
              ? 'owners'
              : 'admins';

      // Update Firestore with new location
      await _firestore.collection(userType).doc(user.uid).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'lastLocationUpdate': FieldValue.serverTimestamp(),
      });

      print('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Threshold Monitor Overlay
        StreamBuilder<List<ThresholdViolation>>(
          stream: _thresholdService.monitorThresholds(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox.shrink();
            }

            final violations = snapshot.data!;

            // Show alert banner at top
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 8,
                color: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: violations.any((v) => !v.isWarning)
                        ? Colors.red.shade50
                        : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: violations.any((v) => !v.isWarning)
                          ? Colors.red
                          : Colors.amber,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: violations.any((v) => !v.isWarning)
                              ? Colors.red
                              : Colors.amber,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                violations.any((v) => !v.isWarning)
                                    ? Icons.warning_rounded
                                    : Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 24),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                violations.any((v) => !v.isWarning)
                                    ? 'Threshold Alert (${violations.where((v) => !v.isWarning).length})'
                                    : 'Threshold Warning (${violations.length})',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(8),
                          itemCount: violations.length,
                          itemBuilder: (context, index) {
                            final violation = violations[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: violation.color.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    violation.icon,
                                    color: violation.color,
                                    size: 24,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          violation.scbName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          violation.message,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: violation.color,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      violation.action.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Visibility(
          visible: box.read('accountType') != 'Staff',
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 65,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25), // Shadow color
                      offset: Offset(0, 0), // Shadow position
                      blurRadius: 20, // Blur effect
                      spreadRadius: 5, // Spread effect
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HOME ----------------------------------------------------------------
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.zero,
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFF646464),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.white,
                          ),
                          elevation: MaterialStateProperty.all<double>(
                            0,
                          ), // Remove elevation
                          shadowColor: MaterialStateProperty.all<Color>(
                            Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, size: 30),
                              SizedBox(width: 10),
                              Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/pin_location');
                        },
                      ),

                      // VerticalDivider(
                      //   color: Colors.grey,
                      //   thickness: 1,
                      //   width: 20, // space taken horizontally
                      // ),

                      // SETTINGS ----------------------------------------------------------------
                      ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.zero,
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFF646464),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.white,
                          ),
                          elevation: MaterialStateProperty.all<double>(
                            0,
                          ), // Remove elevation
                          shadowColor: MaterialStateProperty.all<Color>(
                            Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.manage_accounts_sharp, size: 30),
                              SizedBox(width: 10),
                              Text(
                                'Managers',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/connectedDevices');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        box.read('accountType') == 'Staff'
            ? GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/pin_location');
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Icon(Icons.location_on_rounded,
                          color: Colors.white, size: 30),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.30), // Shadow color
                            offset: Offset(0, 6), // Shadow position
                            blurRadius: 5, // Blur effect
                            spreadRadius: 0, // Spread effect
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/addnewcb');
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      child: Icon(Icons.add, color: Colors.white, size: 30),
                      decoration: BoxDecoration(
                        color: Color(0xFF2ECC71),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.30), // Shadow color
                            offset: Offset(0, 6), // Shadow position
                            blurRadius: 5, // Blur effect
                            spreadRadius: 0, // Spread effect
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
