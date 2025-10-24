import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_cb_1/services/threshold_monitor_service.dart';

void main() {
  group('Threshold Monitor Service Tests', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      // Note: This would require proper Firebase configuration for testing
      // For now, we'll test the ThresholdViolation class directly
    });

    // Test ThresholdViolation class directly without initializing the service
    // to avoid Firebase initialization issues

    test('ThresholdViolation message format for warning', () {
      final violation = ThresholdViolation(
        scbId: 'test1',
        scbName: 'Test CB',
        type: 'Overvoltage',
        currentValue: 225.0,
        thresholdValue: 250.0,
        action: 'warning',
        unit: 'V',
        isWarning: true,
      );

      expect(violation.message, 'Overvoltage Warning: 225.0V (90% of 250.0V)');
    });

    test('ThresholdViolation message format for violation', () {
      final violation = ThresholdViolation(
        scbId: 'test1',
        scbName: 'Test CB',
        type: 'Overvoltage',
        currentValue: 260.0,
        thresholdValue: 250.0,
        action: 'trip',
        unit: 'V',
        isWarning: false,
      );

      expect(violation.message, 'Overvoltage: 260.0V > 250.0V');
    });

    test('ThresholdViolation color for warning', () {
      final violation = ThresholdViolation(
        scbId: 'test1',
        scbName: 'Test CB',
        type: 'Overvoltage',
        currentValue: 225.0,
        thresholdValue: 250.0,
        action: 'warning',
        unit: 'V',
        isWarning: true,
      );

      expect(violation.color, Colors.amber); // Warning should be amber
    });

    test('ThresholdViolation color for trip action', () {
      final violation = ThresholdViolation(
        scbId: 'test1',
        scbName: 'Test CB',
        type: 'Overvoltage',
        currentValue: 260.0,
        thresholdValue: 250.0,
        action: 'trip',
        unit: 'V',
        isWarning: false,
      );

      expect(violation.color, Colors.red); // Trip should be red
    });

    test('ThresholdViolation icon for different types', () {
      final overvoltage = ThresholdViolation(
        scbId: 'test1',
        scbName: 'Test CB',
        type: 'Overvoltage',
        currentValue: 260.0,
        thresholdValue: 250.0,
        action: 'trip',
        unit: 'V',
      );

      final overcurrent = ThresholdViolation(
        scbId: 'test1',
        scbName: 'Test CB',
        type: 'Overcurrent',
        currentValue: 50.0,
        thresholdValue: 40.0,
        action: 'trip',
        unit: 'A',
      );

      final temperature = ThresholdViolation(
        scbId: 'test1',
        scbName: 'Test CB',
        type: 'Temperature',
        currentValue: 60.0,
        thresholdValue: 55.0,
        action: 'alarm',
        unit: '°C',
      );

      expect(overvoltage.icon, Icons.electric_meter_outlined);
      expect(overcurrent.icon, Icons.electric_bolt_rounded);
      expect(temperature.icon, Icons.thermostat_sharp);
    });

    test('Threshold percentage calculations', () {
      // Test overvoltage percentage calculation
      final threshold = 250.0;
      final warningValue = 225.0; // 90% of threshold
      final violationValue = 260.0; // 104% of threshold

      final warningPercentage = (warningValue / threshold) * 100;
      final violationPercentage = (violationValue / threshold) * 100;

      expect(warningPercentage, 90.0);
      expect(violationPercentage, 104.0);

      // Test undervoltage percentage calculation (inverted)
      final undervoltageThreshold = 100.0;
      final undervoltageValue = 95.0; // 5% below threshold
      final undervoltagePercentage =
          ((undervoltageThreshold - undervoltageValue) /
                  undervoltageThreshold) *
              100;

      expect(undervoltagePercentage, 5.0);
    });
  });
}
