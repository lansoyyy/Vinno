import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThresholdMonitorService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, Map<String, dynamic>> _lastNotifiedThresholds = {};
  Map<String, Map<String, dynamic>> _lastWarningNotifiedThresholds = {};

  // Start monitoring all circuit breakers for the current user
  Stream<List<ThresholdViolation>> monitorThresholds() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield [];
      return;
    }

    await for (final event in _dbRef.child('circuitBreakers').onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        yield [];
        continue;
      }

      List<ThresholdViolation> violations = [];

      for (var entry in data.entries) {
        final scbId = entry.key as String;
        final cbData = Map<String, dynamic>.from(entry.value as Map);

        // Only monitor circuit breakers owned by current user
        if (cbData['ownerId'] != user.uid) continue;

        // Check if circuit breaker is ON
        if (cbData['isOn'] != true) continue;

        // Get thresholds
        final thresholds = cbData['thresholds'] as Map<dynamic, dynamic>?;
        if (thresholds == null) continue;

        // Check each threshold
        final thresholdData = Map<String, dynamic>.from(thresholds);

        // Check Overvoltage
        if (thresholdData['overvoltage'] != null) {
          final overvoltage =
              Map<String, dynamic>.from(thresholdData['overvoltage']);
          if (overvoltage['enabled'] == true) {
            final threshold = (overvoltage['value'] ?? 0).toDouble();
            final currentVoltage = (cbData['voltage'] ?? 0).toDouble();
            final action = overvoltage['action'] ?? 'trip';
            final warningThreshold =
                threshold * 0.9; // 90% of threshold for warning

            // Check if we should show a warning (90% threshold)
            if (currentVoltage > warningThreshold &&
                currentVoltage <= threshold) {
              print(
                  'Overvoltage WARNING: $currentVoltage > $warningThreshold (90% of $threshold)');
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overvoltage',
                currentValue: currentVoltage,
                thresholdValue: threshold,
                action: 'warning', // Special action for warnings
                unit: 'V',
                isWarning: true,
              ));
            }
            // Check if we should trigger the action (100% threshold)
            else if (currentVoltage > threshold) {
              print(
                  'Overvoltage VIOLATION: $currentVoltage > $threshold (100%)');
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overvoltage',
                currentValue: currentVoltage,
                thresholdValue: threshold,
                action: action,
                unit: 'V',
                isWarning: false,
              ));
            }
          }
        }

        // Check Undervoltage
        if (thresholdData['undervoltage'] != null) {
          final undervoltage =
              Map<String, dynamic>.from(thresholdData['undervoltage']);
          if (undervoltage['enabled'] == true) {
            final threshold = (undervoltage['value'] ?? 0).toDouble();
            final currentVoltage = (cbData['voltage'] ?? 0).toDouble();
            final action = undervoltage['action'] ?? 'trip';
            final warningThreshold = threshold *
                1.1; // 110% of threshold for warning (since we're checking for lower values)

            // Check if we should show a warning (90% threshold)
            if (currentVoltage < warningThreshold &&
                currentVoltage >= threshold &&
                currentVoltage > 0) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Undervoltage',
                currentValue: currentVoltage,
                thresholdValue: threshold,
                action: 'warning', // Special action for warnings
                unit: 'V',
                isWarning: true,
              ));
            }
            // Check if we should trigger the action (100% threshold)
            else if (currentVoltage < threshold && currentVoltage > 0) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Undervoltage',
                currentValue: currentVoltage,
                thresholdValue: threshold,
                action: action,
                unit: 'V',
                isWarning: false,
              ));
            }
          }
        }

        // Check Overcurrent
        if (thresholdData['overcurrent'] != null) {
          final overcurrent =
              Map<String, dynamic>.from(thresholdData['overcurrent']);
          if (overcurrent['enabled'] == true) {
            final threshold = (overcurrent['value'] ?? 0).toDouble();
            final currentCurrent = (cbData['current'] ?? 0).toDouble();
            final action = overcurrent['action'] ?? 'trip';
            final warningThreshold =
                threshold * 0.9; // 90% of threshold for warning

            // Check if we should show a warning (90% threshold)
            if (currentCurrent > warningThreshold &&
                currentCurrent <= threshold) {
              print(
                  'Overcurrent WARNING: $currentCurrent > $warningThreshold (90% of $threshold)');
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overcurrent',
                currentValue: currentCurrent,
                thresholdValue: threshold,
                action: 'warning', // Special action for warnings
                unit: 'A',
                isWarning: true,
              ));
            }
            // Check if we should trigger the action (100% threshold)
            else if (currentCurrent > threshold) {
              print(
                  'Overcurrent VIOLATION: $currentCurrent > $threshold (100%)');
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overcurrent',
                currentValue: currentCurrent,
                thresholdValue: threshold,
                action: action,
                unit: 'A',
                isWarning: false,
              ));
            }
          }
        }

        // Check Overpower
        if (thresholdData['overpower'] != null) {
          final overpower =
              Map<String, dynamic>.from(thresholdData['overpower']);
          if (overpower['enabled'] == true) {
            final threshold = (overpower['value'] ?? 0).toDouble();
            final currentPower = (cbData['power'] ?? 0).toDouble();
            final action = overpower['action'] ?? 'trip';
            final warningThreshold =
                threshold * 0.9; // 90% of threshold for warning

            // Check if we should show a warning (90% threshold)
            if (currentPower > warningThreshold && currentPower <= threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overpower',
                currentValue: currentPower,
                thresholdValue: threshold,
                action: 'warning', // Special action for warnings
                unit: 'W',
                isWarning: true,
              ));
            }
            // Check if we should trigger the action (100% threshold)
            else if (currentPower > threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overpower',
                currentValue: currentPower,
                thresholdValue: threshold,
                action: action,
                unit: 'W',
                isWarning: false,
              ));
            }
          }
        }

        // Check Temperature
        if (thresholdData['temperature'] != null) {
          final temperature =
              Map<String, dynamic>.from(thresholdData['temperature']);
          if (temperature['enabled'] == true) {
            final threshold = (temperature['value'] ?? 0).toDouble();
            final currentTemp = (cbData['temperature'] ?? 0).toDouble();
            final action = temperature['action'] ?? 'trip';
            final warningThreshold =
                threshold * 0.9; // 90% of threshold for warning

            // Check if we should show a warning (90% threshold)
            if (currentTemp > warningThreshold && currentTemp <= threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Temperature',
                currentValue: currentTemp,
                thresholdValue: threshold,
                action: 'warning', // Special action for warnings
                unit: '°C',
                isWarning: true,
              ));
            }
            // Check if we should trigger the action (100% threshold)
            else if (currentTemp > threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Temperature',
                currentValue: currentTemp,
                thresholdValue: threshold,
                action: action,
                unit: '°C',
                isWarning: false,
              ));
            }
          }
        }
      }

      yield violations;
    }
  }

  // Execute action based on threshold violation
  Future<void> executeThresholdAction(ThresholdViolation violation) async {
    final action = violation.action.toLowerCase();

    switch (action) {
      case 'warning':
        // Just show warning notification, don't turn off

        await _logWarningEvent(violation);
        break;

      case 'trip':
        // Turn off the circuit breaker
        print('Trip action - Turning OFF circuit breaker');
        await _dbRef
            .child('circuitBreakers')
            .child(violation.scbId)
            .update({'isOn': false});

        // Log trip event to Firestore
        await _logTripEvent(violation);
        break;

      case 'alarm':
        print('Alarm action - Turning OFF circuit breaker');
        await _dbRef
            .child('circuitBreakers')
            .child(violation.scbId)
            .update({'isOn': false});
        // Just show in-app alert, don't turn off
        // Log alarm event to Firestore
        await _logAlarmEvent(violation);
        break;

      case 'off':
        // Turn off the circuit breaker (action "off" means turn off CB)
        print('Off action - Turning OFF circuit breaker');
        await _dbRef
            .child('circuitBreakers')
            .child(violation.scbId)
            .update({'isOn': false});

        // Log off event to Firestore
        await _logOffEvent(violation);
        break;
    }
  }

  // Log trip event to Firestore
  Future<void> _logTripEvent(ThresholdViolation violation) async {
    try {
      await _firestore.collection('tripHistory').add({
        'scbId': violation.scbId,
        'scbName': violation.scbName,
        'type': violation.type,
        'currentValue': violation.currentValue,
        'thresholdValue': violation.thresholdValue,
        'unit': violation.unit,
        'action': 'trip',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error logging trip event: $e');
    }
  }

  // Log alarm event to Firestore
  Future<void> _logAlarmEvent(ThresholdViolation violation) async {
    try {
      await _firestore.collection('alarmHistory').add({
        'scbId': violation.scbId,
        'scbName': violation.scbName,
        'type': violation.type,
        'currentValue': violation.currentValue,
        'thresholdValue': violation.thresholdValue,
        'unit': violation.unit,
        'action': 'alarm',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error logging alarm event: $e');
    }
  }

  // Log off event to Firestore
  Future<void> _logOffEvent(ThresholdViolation violation) async {
    try {
      await _firestore.collection('tripHistory').add({
        'scbId': violation.scbId,
        'scbName': violation.scbName,
        'type': violation.type,
        'currentValue': violation.currentValue,
        'thresholdValue': violation.thresholdValue,
        'unit': violation.unit,
        'action': 'off',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error logging off event: $e');
    }
  }

  // Log warning event to Firestore
  Future<void> _logWarningEvent(ThresholdViolation violation) async {
    try {
      await _firestore.collection('warningHistory').add({
        'scbId': violation.scbId,
        'scbName': violation.scbName,
        'type': violation.type,
        'currentValue': violation.currentValue,
        'thresholdValue': violation.thresholdValue,
        'unit': violation.unit,
        'action': 'warning',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error logging warning event: $e');
    }
  }

  // Log threshold configuration change to Firestore
  static Future<void> logThresholdChange({
    required String scbId,
    required String scbName,
    required String thresholdType,
    required double value,
    required String action,
    required bool enabled,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('activityLogs').add({
        'scbId': scbId,
        'scbName': scbName,
        'activityType': 'threshold_change',
        'thresholdType': thresholdType,
        'value': value,
        'action': action,
        'enabled': enabled,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });
    } catch (e) {
      print('Error logging threshold change: $e');
    }
  }

  // Check if we should notify for this violation (prevent spam)
  bool shouldNotify(ThresholdViolation violation) {
    final key = '${violation.scbId}_${violation.type}';

    // Use different notification tracking for warnings vs actual violations
    final lastNotifiedMap = violation.isWarning
        ? _lastWarningNotifiedThresholds
        : _lastNotifiedThresholds;

    final lastNotified = lastNotifiedMap[key];

    if (lastNotified == null) {
      lastNotifiedMap[key] = {
        'timestamp': DateTime.now(),
        'value': violation.currentValue,
      };
      return true;
    }

    final timeSinceLastNotification =
        DateTime.now().difference(lastNotified['timestamp'] as DateTime);

    // Only notify again if 30 seconds have passed
    if (timeSinceLastNotification.inSeconds > 30) {
      lastNotifiedMap[key] = {
        'timestamp': DateTime.now(),
        'value': violation.currentValue,
      };
      return true;
    }

    return false;
  }
}

class ThresholdViolation {
  final String scbId;
  final String scbName;
  final String type;
  final double currentValue;
  final double thresholdValue;
  final String action;
  final String unit;
  final bool isWarning;

  ThresholdViolation({
    required this.scbId,
    required this.scbName,
    required this.type,
    required this.currentValue,
    required this.thresholdValue,
    required this.action,
    required this.unit,
    this.isWarning = false,
  });

  String get message {
    if (isWarning) {
      return '$type Warning: ${currentValue.toStringAsFixed(1)}$unit (90% of ${thresholdValue.toStringAsFixed(1)}$unit)';
    }
    return '$type: ${currentValue.toStringAsFixed(1)}$unit > ${thresholdValue.toStringAsFixed(1)}$unit';
  }

  Color get color {
    if (isWarning) {
      return Colors.amber; // Yellow/amber color for warnings
    }

    switch (action.toLowerCase()) {
      case 'trip':
        return Colors.red;
      case 'alarm':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (type) {
      case 'Overvoltage':
      case 'Undervoltage':
        return Icons.electric_meter_outlined;
      case 'Overcurrent':
        return Icons.electric_bolt_rounded;
      case 'Overpower':
        return Icons.energy_savings_leaf_outlined;
      case 'Temperature':
        return Icons.thermostat_sharp;
      default:
        return Icons.warning;
    }
  }
}
