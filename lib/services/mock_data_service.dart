import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class MockDataService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final Random _random = Random();

  // Circuit breaker IDs to generate data for
  final List<String> circuitBreakerIds = [
    'CB-LIVING-002',
    'CB-KITCHEN-001',
    'CB-BEDROOM-003',
    'CB-BATHROOM-004',
    'CB-GARAGE-005'
  ];

  // Generate mock data for all sensor types
  Future<void> generateMockData() async {
    print('Starting mock data generation...');

    for (String cbId in circuitBreakerIds) {
      await _generateDataForCircuitBreaker(cbId);
    }

    print('Mock data generation completed!');
  }

  // Generate data for a single circuit breaker
  Future<void> _generateDataForCircuitBreaker(String cbId) async {
    print('Generating data for $cbId...');

    // Generate 50 data points for each sensor type
    int dataPointsCount = 50;

    // Generate Voltage data
    await _generateSensorData(
        sensorType: 'voltage',
        cbId: cbId,
        dataPointsCount: dataPointsCount,
        baseValue: 220.0,
        variance: 15.0,
        unit: 'V');

    // Generate Temperature data
    await _generateSensorData(
        sensorType: 'temperature',
        cbId: cbId,
        dataPointsCount: dataPointsCount,
        baseValue: 35.0,
        variance: 10.0,
        unit: '°C');

    // Generate Power data
    await _generateSensorData(
        sensorType: 'power',
        cbId: cbId,
        dataPointsCount: dataPointsCount,
        baseValue: 1500.0,
        variance: 500.0,
        unit: 'W');

    // Generate Current data
    await _generateSensorData(
        sensorType: 'current',
        cbId: cbId,
        dataPointsCount: dataPointsCount,
        baseValue: 12.0,
        variance: 3.0,
        unit: 'A');

    // Generate Energy data
    await _generateSensorData(
        sensorType: 'energy',
        cbId: cbId,
        dataPointsCount: dataPointsCount,
        baseValue: 50.0,
        variance: 15.0,
        unit: 'kWh');
  }

  // Generate data for a specific sensor type
  Future<void> _generateSensorData({
    required String sensorType,
    required String cbId,
    required int dataPointsCount,
    required double baseValue,
    required double variance,
    required String unit,
  }) async {
    DatabaseReference sensorRef = _dbRef.child(sensorType).child(cbId);

    // Generate data points over the last 24 hours
    DateTime now = DateTime.now();
    int currentTimeStamp =
        now.millisecondsSinceEpoch ~/ 1000; // Convert to seconds

    for (int i = 0; i < dataPointsCount; i++) {
      // Generate timestamp for each data point (spaced out over time)
      int timeStamp = currentTimeStamp -
          (dataPointsCount - i) *
              1728; // ~1728 seconds apart (24 hours / 50 points)

      // Generate realistic value with some randomness
      double randomFactor = 0.8 + _random.nextDouble() * 0.4; // 0.8 to 1.2
      double value = baseValue * randomFactor;

      // Add some trend variation
      if (i % 10 == 0) {
        value +=
            variance * (_random.nextDouble() - 0.5) * 2; // Occasional spikes
      }

      // Ensure value is positive
      value = value.abs();

      // Create a unique ID for this data point
      String dataId = '${sensorType}_${timeStamp}_${_random.nextInt(10000)}';

      // Store the data
      await sensorRef.child(dataId).set({
        sensorType: value,
        'timestamp': timeStamp,
        'unit': unit,
        'cbId': cbId
      });
    }

    print('Generated $dataPointsCount data points for $sensorType of $cbId');
  }

  // Generate current circuit breaker data (for real-time display)
  Future<void> generateCurrentCircuitBreakerData() async {
    print('Generating current circuit breaker data...');

    for (String cbId in circuitBreakerIds) {
      double voltage = 220.0 + (_random.nextDouble() - 0.5) * 30.0;
      double temperature = 35.0 + (_random.nextDouble() - 0.5) * 20.0;
      double power = 1500.0 + (_random.nextDouble() - 0.5) * 1000.0;
      double current = 12.0 + (_random.nextDouble() - 0.5) * 6.0;
      double energy = 50.0 + (_random.nextDouble() - 0.5) * 30.0;

      await _dbRef.child('circuitBreakers').child(cbId).set({
        'scbName': cbId.replaceAll('-', ' '),
        'isOn': _random.nextBool(),
        'circuitBreakerRating': 30.0,
        'voltage': voltage,
        'current': current,
        'temperature': temperature,
        'power': power,
        'energy': energy,
        'latitude': 14.5995 + (_random.nextDouble() - 0.5) * 0.1,
        'longitude': 120.9842 + (_random.nextDouble() - 0.5) * 0.1,
        'wifiName': 'WiFi_${cbId.split('-').last}',
        'ownerId': 'mock_user_id',
        'thresholds': {
          'overvoltage': {'enabled': true, 'value': 250.0, 'action': 'trip'},
          'undervoltage': {'enabled': true, 'value': 200.0, 'action': 'trip'},
          'overcurrent': {'enabled': true, 'value': 20.0, 'action': 'trip'},
          'overpower': {'enabled': true, 'value': 3000.0, 'action': 'trip'},
          'temperature': {'enabled': true, 'value': 60.0, 'action': 'trip'}
        }
      });
    }

    print('Current circuit breaker data generated!');
  }

  // Generate all mock data in one call
  Future<void> generateAllMockData() async {
    await generateCurrentCircuitBreakerData();
    await generateMockData();
  }
}
