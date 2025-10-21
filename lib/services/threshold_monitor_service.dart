import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThresholdMonitorService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Map<String, Map<String, dynamic>> _lastNotifiedThresholds = {};

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
          final overvoltage = Map<String, dynamic>.from(thresholdData['overvoltage']);
          if (overvoltage['enabled'] == true) {
            final threshold = (overvoltage['value'] ?? 0).toDouble();
            final currentVoltage = (cbData['voltage'] ?? 0).toDouble();
            final action = overvoltage['action'] ?? 'trip';
            
            if (currentVoltage > threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overvoltage',
                currentValue: currentVoltage,
                thresholdValue: threshold,
                action: action,
                unit: 'V',
              ));
            }
          }
        }

        // Check Undervoltage
        if (thresholdData['undervoltage'] != null) {
          final undervoltage = Map<String, dynamic>.from(thresholdData['undervoltage']);
          if (undervoltage['enabled'] == true) {
            final threshold = (undervoltage['value'] ?? 0).toDouble();
            final currentVoltage = (cbData['voltage'] ?? 0).toDouble();
            final action = undervoltage['action'] ?? 'trip';
            
            if (currentVoltage < threshold && currentVoltage > 0) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Undervoltage',
                currentValue: currentVoltage,
                thresholdValue: threshold,
                action: action,
                unit: 'V',
              ));
            }
          }
        }

        // Check Overcurrent
        if (thresholdData['overcurrent'] != null) {
          final overcurrent = Map<String, dynamic>.from(thresholdData['overcurrent']);
          if (overcurrent['enabled'] == true) {
            final threshold = (overcurrent['value'] ?? 0).toDouble();
            final currentCurrent = (cbData['current'] ?? 0).toDouble();
            final action = overcurrent['action'] ?? 'trip';
            
            if (currentCurrent > threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overcurrent',
                currentValue: currentCurrent,
                thresholdValue: threshold,
                action: action,
                unit: 'A',
              ));
            }
          }
        }

        // Check Overpower
        if (thresholdData['overpower'] != null) {
          final overpower = Map<String, dynamic>.from(thresholdData['overpower']);
          if (overpower['enabled'] == true) {
            final threshold = (overpower['value'] ?? 0).toDouble();
            final currentPower = (cbData['power'] ?? 0).toDouble();
            final action = overpower['action'] ?? 'trip';
            
            if (currentPower > threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Overpower',
                currentValue: currentPower,
                thresholdValue: threshold,
                action: action,
                unit: 'W',
              ));
            }
          }
        }

        // Check Temperature
        if (thresholdData['temperature'] != null) {
          final temperature = Map<String, dynamic>.from(thresholdData['temperature']);
          if (temperature['enabled'] == true) {
            final threshold = (temperature['value'] ?? 0).toDouble();
            final currentTemp = (cbData['temperature'] ?? 0).toDouble();
            final action = temperature['action'] ?? 'trip';
            
            if (currentTemp > threshold) {
              violations.add(ThresholdViolation(
                scbId: scbId,
                scbName: cbData['scbName'] ?? 'Unknown',
                type: 'Temperature',
                currentValue: currentTemp,
                thresholdValue: threshold,
                action: action,
                unit: '°C',
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
      case 'trip':
        // Turn off the circuit breaker
        await _dbRef
            .child('circuitBreakers')
            .child(violation.scbId)
            .update({'isOn': false});
        
        // Log trip event to Firestore
        await _logTripEvent(violation);
        break;
      
      case 'alarm':
        // Just show in-app alert, don't turn off
        // Log alarm event to Firestore
        await _logAlarmEvent(violation);
        break;
      
      case 'off':
        // Turn off the circuit breaker (action "off" means turn off CB)
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
    final lastNotified = _lastNotifiedThresholds[key];
    
    if (lastNotified == null) {
      _lastNotifiedThresholds[key] = {
        'timestamp': DateTime.now(),
        'value': violation.currentValue,
      };
      return true;
    }
    
    final timeSinceLastNotification = 
        DateTime.now().difference(lastNotified['timestamp'] as DateTime);
    
    // Only notify again if 30 seconds have passed
    if (timeSinceLastNotification.inSeconds > 30) {
      _lastNotifiedThresholds[key] = {
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

  ThresholdViolation({
    required this.scbId,
    required this.scbName,
    required this.type,
    required this.currentValue,
    required this.thresholdValue,
    required this.action,
    required this.unit,
  });

  String get message {
    return '$type: ${currentValue.toStringAsFixed(1)}$unit > ${thresholdValue.toStringAsFixed(1)}$unit';
  }

  Color get color {
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
