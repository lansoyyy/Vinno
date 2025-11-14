import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:smart_cb_1/util/const.dart';

class StatisticsService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _refreshTimer;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Start periodic data refresh every 10 seconds
  void startPeriodicRefresh(VoidCallback callback) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      callback();
    });
  }

  // Stop periodic refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Dispose method to clean up resources
  void dispose() {
    stopPeriodicRefresh();
  }

  // Fetch all circuit breakers for the current user
  Stream<List<Map<String, dynamic>>> getCircuitBreakers() {
    if (currentUserId == null) return Stream.value([]);

    return _dbRef.child('circuitBreakers').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      List<Map<String, dynamic>> breakers = [];
      data.forEach((key, value) {
        final cbData = Map<String, dynamic>.from(value as Map);

        if (box.read('accountType') == 'Owner') {
          if (cbData['ownerId'] == currentUserId) {
            breakers.add({
              'scbId': key,
              'scbName': cbData['scbName'] ?? 'Unknown',
              'isOn': cbData['isOn'] ?? false,
              'circuitBreakerRating': cbData['circuitBreakerRating'] ?? 0,
              'voltage': (cbData['voltage'] ?? 0).toDouble(),
              'current': (cbData['current'] ?? 0).toDouble(),
              'temperature': (cbData['temperature'] ?? 0).toDouble(),
              'power': (cbData['power'] ?? 0).toDouble(),
              'energy': (cbData['energy'] ?? 0).toDouble(),
              'latitude': cbData['latitude'] ?? 0.0,
              'longitude': cbData['longitude'] ?? 0.0,
              'wifiName': cbData['wifiName'] ?? '',
              'servoStatus': ''
            });
          }
        } else {
          if (cbData['ownerId'] == box.read('createdBy')) {
            breakers.add({
              'scbId': key,
              'scbName': cbData['scbName'] ?? 'Unknown',
              'isOn': cbData['isOn'] ?? false,
              'circuitBreakerRating': cbData['circuitBreakerRating'] ?? 0,
              'voltage': (cbData['voltage'] ?? 0).toDouble(),
              'current': (cbData['current'] ?? 0).toDouble(),
              'temperature': (cbData['temperature'] ?? 0).toDouble(),
              'power': (cbData['power'] ?? 0).toDouble(),
              'energy': (cbData['energy'] ?? 0).toDouble(),
              'latitude': cbData['latitude'] ?? 0.0,
              'longitude': cbData['longitude'] ?? 0.0,
              'wifiName': cbData['wifiName'] ?? '',
              'servoStatus': ''
            });
          }
        }
      });
      return breakers;
    });
  }

  // Get historical data for a specific circuit breaker
  Future<Map<String, dynamic>> getHistoricalData(
      String breakerId, String period,
      {String metric = 'energy'}) async {
    try {
      print(
          'Fetching historical data for breakerId: $breakerId, period: $period, metric: $metric');

      // First, get the circuit breaker creation date to filter data properly
      final breakerSnapshot =
          await _dbRef.child('circuitBreakers').child(breakerId).get();
      DateTime? breakerCreationDate;

      if (breakerSnapshot.exists) {
        final breakerData =
            Map<String, dynamic>.from(breakerSnapshot.value as Map);
        // Try to get creation date from timestamp or use a default
        if (breakerData.containsKey('createdAt')) {
          // Check if timestamp is already in milliseconds or in seconds
          int timestamp = breakerData['createdAt'];
          if (timestamp < 10000000000) {
            // It's in seconds, convert to milliseconds
            timestamp = timestamp * 1000;
          }
          breakerCreationDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        } else if (breakerData.containsKey('timestamp')) {
          // Check if timestamp is already in milliseconds or in seconds
          int timestamp = breakerData['timestamp'];
          if (timestamp < 10000000000) {
            // It's in seconds, convert to milliseconds
            timestamp = timestamp * 1000;
          }
          breakerCreationDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
        print('Breaker creation date: $breakerCreationDate');
      }

      // Get data from the correct collection structure: metric/circuitBreakerId/randomId/
      final snapshot = await _dbRef.child(metric).child(breakerId).get();
      print('=== FETCHING FROM: $metric/$breakerId ===');
      print('Snapshot exists: ${snapshot.exists}');

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        final labels = _getDynamicPeriodLabels(period);
        Map<String, dynamic> result = {};

        print('Data entries count: ${data.entries.length}');
        print('Labels for period "$period": $labels');

        // Debug: Print first few entries to understand the data structure
        print('=== $metric DATA DEBUG ===');
        print('Raw data keys: ${data.keys.take(5).toList()}');
        int count = 0;
        data.forEach((key, value) {
          if (count < 5) {
            // Only print first 5 entries
            print('Entry $count: key=$key, value=$value');
            if (value is Map) {
              print('  - Has $metric field: ${value.containsKey(metric)}');
              if (value.containsKey(metric)) {
                print(
                    '  - $metric value: ${value[metric]} (type: ${value[metric].runtimeType})');
              }
              print(
                  '  - Has timestamp field: ${value.containsKey('timestamp')}');
              if (value.containsKey('timestamp')) {
                print(
                    '  - Timestamp value: ${value['timestamp']} (type: ${value['timestamp'].runtimeType})');
              }
            }
            count++;
          }
        });
        print('=== END $metric DATA DEBUG ===');

        // Convert data entries to list with timestamps
        List<MapEntry<dynamic, dynamic>> dataEntries = data.entries.toList();

        // Sort by timestamp
        dataEntries.sort((a, b) {
          final aTimestamp =
              (a.value is Map && a.value.containsKey('timestamp'))
                  ? (a.value['timestamp'] as num).toInt()
                  : 0;
          final bTimestamp =
              (b.value is Map && b.value.containsKey('timestamp'))
                  ? (b.value['timestamp'] as num).toInt()
                  : 0;
          return aTimestamp.compareTo(bTimestamp);
        });

        // Group data by time periods based on timestamps
        final now = DateTime.now();
        final Map<String, List<double>> groupedData = {};

        for (String label in labels) {
          groupedData[label] = [];
        }

        int validDataPoints = 0;
        int skippedDataPoints = 0;
        int corruptDataPoints = 0;

        // Define realistic maximum values for each metric to filter out corrupt data
        final Map<String, double> maxRealisticValues = {
          'energy': 1000.0, // Max 1000 kWh per reading
          'power': 50000.0, // Max 50kW
          'voltage': 500.0, // Max 500V
          'current': 200.0, // Max 200A
          'temperature': 150.0, // Max 150°C
        };

        final double maxValue = maxRealisticValues[metric] ?? 100000.0;

        for (var entry in dataEntries) {
          if (entry.value is Map &&
              entry.value.containsKey(metric) &&
              entry.value.containsKey('timestamp')) {
            // Check if timestamp is already in milliseconds or in seconds
            int timestamp = (entry.value['timestamp'] as num).toInt();
            if (timestamp < 10000000000) {
              // It's in seconds, convert to milliseconds
              timestamp = timestamp * 1000;
            }
            final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final value = (entry.value[metric] as num).toDouble();

            // Skip data before breaker creation date
            if (breakerCreationDate != null &&
                dateTime.isBefore(breakerCreationDate)) {
              skippedDataPoints++;
              continue;
            }

            // Filter out unrealistic/corrupt values
            if (value.abs() > maxValue) {
              corruptDataPoints++;
              if (corruptDataPoints <= 3) {
                print(
                    '⚠️ Skipping corrupt data: $metric=$value (exceeds max $maxValue)');
              }
              continue;
            }

            validDataPoints++;

            // Log first few valid data points to verify correct values
            if (validDataPoints <= 3) {
              print(
                  'Sample data point $validDataPoints: $metric=${value}, timestamp=$timestamp, date=$dateTime');
            }

            // Determine which period this data point belongs to
            String? labelForData =
                _getLabelForTimestamp(dateTime, period, labels, now);
            if (labelForData != null) {
              if (groupedData.containsKey(labelForData)) {
                groupedData[labelForData]!.add(value);
              }
            }
          }
        }

        print(
            'Valid: $validDataPoints, Skipped (old): $skippedDataPoints, Corrupt (filtered): $corruptDataPoints');
        print('Grouped data summary:');
        groupedData.forEach((label, values) {
          if (values.isNotEmpty) {
            print(
                '  $label: ${values.length} values, avg=${values.reduce((a, b) => a + b) / values.length}');
          }
        });

        // Calculate average for each period
        for (String label in labels) {
          if (groupedData[label]!.isNotEmpty) {
            double sum = groupedData[label]!.reduce((a, b) => a + b);
            double average = sum / groupedData[label]!.length;

            // For energy data, ensure we handle negative values correctly
            // The average should reflect the actual data, including negative values
            result[label] = average;
          } else {
            // If no data for this period, use 0 (not mock data)
            result[label] = 0.0;
          }
        }

        print('=== FINAL RESULT for $metric/$breakerId/$period ===');
        print('Result: $result');
        print('=== END RESULT ===');
        return result;
      }

      // If no historical data exists, return empty data (no mock data)
      final labels = _getDynamicPeriodLabels(period);
      Map<String, dynamic> data = {};

      for (String label in labels) {
        data[label] = 0.0;
      }

      print('=== NO DATA FOUND for $metric/$breakerId/$period ===');
      print('Returning empty data: $data');
      print('=== END NO DATA ===');
      return data;
    } catch (e) {
      print(
          '❌ ERROR fetching historical data for $metric/$breakerId/$period: $e');
      print('⚠️ RETURNING EMPTY DATA - Check Firebase indexes!');
      // Return empty data instead of mock data to make the issue visible
      final labels = _getDynamicPeriodLabels(period);
      Map<String, dynamic> emptyData = {};
      for (String label in labels) {
        emptyData[label] = 0.0;
      }
      return emptyData;
    }
  }

  // Get aggregated data for all circuit breakers
  Future<Map<String, dynamic>> getAggregatedData(String period,
      {String metric = 'energy'}) async {
    try {
      final breakers = await getCircuitBreakers().first;
      Map<String, dynamic> aggregatedData = {};

      // Initialize with empty data
      final labels = _getDynamicPeriodLabels(period);
      for (String label in labels) {
        aggregatedData[label] = 0.0;
      }

      // Aggregate data from all breakers
      for (var breaker in breakers) {
        final data =
            await getHistoricalData(breaker['scbId'], period, metric: metric);
        data.forEach((key, value) {
          if (aggregatedData.containsKey(key)) {
            aggregatedData[key] =
                (aggregatedData[key] ?? 0.0) + (value as double);
          }
        });
      }

      return aggregatedData;
    } catch (e) {
      print('Error fetching aggregated data: $e');
      return _generateMockData(period);
    }
  }

  // Get properly aggregated data for consumption (main breaker represents total)
  Future<Map<String, dynamic>> getConsumptionAggregatedData(String period,
      {String metric = 'energy'}) async {
    try {
      final breakers = await getCircuitBreakers().first;
      if (breakers.isEmpty) return _generateMockData(period);

      // Find the main breaker (first breaker or the one with highest rating)
      var mainBreaker = breakers.reduce((a, b) {
        final aRating = a['circuitBreakerRating'] ?? 0;
        final bRating = b['circuitBreakerRating'] ?? 0;
        return (aRating as int) > (bRating as int) ? a : b;
      });

      // Get data from main breaker only (represents total consumption)
      final data =
          await getHistoricalData(mainBreaker['scbId'], period, metric: metric);

      // Ensure data is properly aggregated per period
      Map<String, dynamic> aggregatedData = {};
      final labels = _getDynamicPeriodLabels(period);

      for (String label in labels) {
        if (data.containsKey(label)) {
          aggregatedData[label] = data[label];
        } else {
          aggregatedData[label] = 0.0;
        }
      }

      return aggregatedData;
    } catch (e) {
      print('Error fetching consumption aggregated data: $e');
      return _generateMockData(period);
    }
  }

  // Get current readings - returns the LATEST reading from the most recent timestamp
  // from the main breaker (highest rating)
  Stream<Map<String, double>> getCurrentReadings() {
    return getCircuitBreakers().asyncMap((breakers) async {
      if (breakers.isEmpty) {
        return {
          'voltage': 0.0,
          'current': 0.0,
          'power': 0.0,
          'temperature': 0.0,
          'energy': 0.0,
        };
      }

      // Find the main breaker (highest rating) to get current readings from
      var mainBreaker = breakers.reduce((a, b) {
        final aRating = a['circuitBreakerRating'] ?? 0;
        final bRating = b['circuitBreakerRating'] ?? 0;
        return (aRating as int) > (bRating as int) ? a : b;
      });

      String breakerId = mainBreaker['scbId'];
      double latestVoltage = 0.0;
      double latestCurrent = 0.0;
      double latestPower = 0.0;
      double latestTemperature = 0.0;
      double latestEnergy = 0.0;

      try {
        // Read from voltage collection
        final voltageSnapshot = await _dbRef
            .child('voltage')
            .child(breakerId)
            .orderByChild('timestamp')
            .limitToLast(1)
            .get();
        if (voltageSnapshot.exists && voltageSnapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(voltageSnapshot.value as Map);
          if (data.isNotEmpty) {
            final latestEntry = data.values.first;
            if (latestEntry is Map && latestEntry.containsKey('voltage')) {
              latestVoltage = (latestEntry['voltage'] as num).toDouble();
            }
          }
        } else {
          latestVoltage = (mainBreaker['voltage'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        print('Error reading voltage for $breakerId: $e');
        latestVoltage = (mainBreaker['voltage'] as num?)?.toDouble() ?? 0.0;
      }

      try {
        // Read from current collection
        final currentSnapshot = await _dbRef
            .child('current')
            .child(breakerId)
            .orderByChild('timestamp')
            .limitToLast(1)
            .get();
        if (currentSnapshot.exists && currentSnapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(currentSnapshot.value as Map);
          if (data.isNotEmpty) {
            final latestEntry = data.values.first;
            if (latestEntry is Map && latestEntry.containsKey('current')) {
              latestCurrent = (latestEntry['current'] as num).toDouble();
            }
          }
        } else {
          latestCurrent = (mainBreaker['current'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        print('Error reading current for $breakerId: $e');
        latestCurrent = (mainBreaker['current'] as num?)?.toDouble() ?? 0.0;
      }

      try {
        // Read from power collection
        final powerSnapshot = await _dbRef
            .child('power')
            .child(breakerId)
            .orderByChild('timestamp')
            .limitToLast(1)
            .get();
        if (powerSnapshot.exists && powerSnapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(powerSnapshot.value as Map);
          if (data.isNotEmpty) {
            final latestEntry = data.values.first;
            if (latestEntry is Map && latestEntry.containsKey('power')) {
              latestPower = (latestEntry['power'] as num).toDouble();
            }
          }
        } else {
          latestPower = (mainBreaker['power'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        print('Error reading power for $breakerId: $e');
        latestPower = (mainBreaker['power'] as num?)?.toDouble() ?? 0.0;
      }

      try {
        // Read from temperature collection
        final temperatureSnapshot = await _dbRef
            .child('temperature')
            .child(breakerId)
            .orderByChild('timestamp')
            .limitToLast(1)
            .get();
        if (temperatureSnapshot.exists && temperatureSnapshot.value != null) {
          final data =
              Map<dynamic, dynamic>.from(temperatureSnapshot.value as Map);
          if (data.isNotEmpty) {
            final latestEntry = data.values.first;
            if (latestEntry is Map && latestEntry.containsKey('temperature')) {
              latestTemperature =
                  (latestEntry['temperature'] as num).toDouble();
            }
          }
        } else {
          latestTemperature =
              (mainBreaker['temperature'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        print('Error reading temperature for $breakerId: $e');
        latestTemperature =
            (mainBreaker['temperature'] as num?)?.toDouble() ?? 0.0;
      }

      try {
        // Read from energy collection
        final energySnapshot = await _dbRef
            .child('energy')
            .child(breakerId)
            .orderByChild('timestamp')
            .limitToLast(1)
            .get();
        if (energySnapshot.exists && energySnapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(energySnapshot.value as Map);
          if (data.isNotEmpty) {
            final latestEntry = data.values.first;
            if (latestEntry is Map && latestEntry.containsKey('energy')) {
              latestEnergy = (latestEntry['energy'] as num).toDouble();
            }
          }
        } else {
          latestEnergy = (mainBreaker['energy'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (e) {
        print('Error reading energy for $breakerId: $e');
        latestEnergy = (mainBreaker['energy'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'voltage': latestVoltage,
        'current': latestCurrent,
        'power': latestPower,
        'temperature': latestTemperature,
        'energy': latestEnergy,
      };
    });
  }

  // Get threshold exceeded count
  Future<int> getThresholdExceededCount() async {
    try {
      final breakers = await getCircuitBreakers().first;
      int count = 0;

      for (var breaker in breakers) {
        // Check if any threshold is exceeded
        if (breaker['voltage'] > 250 ||
            breaker['current'] > 30 ||
            breaker['temperature'] > 80 ||
            breaker['power'] > 5000) {
          count++;
        }
      }

      return count;
    } catch (e) {
      print('Error getting threshold count: $e');
      return 0;
    }
  }

  // Get highest readings from metric collections
  Future<Map<String, double>> getHighestReadings() async {
    try {
      final breakers = await getCircuitBreakers().first;
      double maxVoltage = 0;
      double maxCurrent = 0;
      double maxPower = 0;
      double maxTemperature = 0;
      double maxEnergy = 0;

      for (var breaker in breakers) {
        String breakerId = breaker['scbId'];

        try {
          // Read from voltage collection (structure: voltage/circuitBreakerId/randomId/)
          final voltageSnapshot = await _dbRef
              .child('voltage')
              .child(breakerId)
              .limitToLast(100)
              .get();
          if (voltageSnapshot.exists && voltageSnapshot.value != null) {
            final data =
                Map<dynamic, dynamic>.from(voltageSnapshot.value as Map);
            if (data.isNotEmpty) {
              print(
                  'Voltage data found for breaker $breakerId: ${data.length} entries');
              data.forEach((key, value) {
                if (value is Map && value.containsKey('voltage')) {
                  double voltage = (value['voltage'] as num).toDouble();
                  maxVoltage = max(maxVoltage, voltage);
                }
              });
            } else {
              maxVoltage = max(maxVoltage, breaker['voltage'] as double);
              print(
                  'No voltage data found, using fallback: ${breaker['voltage']} for breaker: $breakerId');
            }
          } else {
            maxVoltage = max(maxVoltage, breaker['voltage'] as double);
            print(
                'No voltage snapshot, using fallback: ${breaker['voltage']} for breaker: $breakerId');
          }
        } catch (e) {
          print('Error reading voltage for $breakerId: $e');
          maxVoltage = max(maxVoltage, breaker['voltage'] as double);
        }

        try {
          // Read from current collection (structure: current/circuitBreakerId/randomId/)
          final currentSnapshot = await _dbRef
              .child('current')
              .child(breakerId)
              .limitToLast(100)
              .get();
          if (currentSnapshot.exists && currentSnapshot.value != null) {
            final data =
                Map<dynamic, dynamic>.from(currentSnapshot.value as Map);
            if (data.isNotEmpty) {
              print(
                  'Current data found for breaker $breakerId: ${data.length} entries');
              data.forEach((key, value) {
                if (value is Map && value.containsKey('current')) {
                  double current = (value['current'] as num).toDouble();
                  maxCurrent = max(maxCurrent, current);
                }
              });
            } else {
              maxCurrent = max(maxCurrent, breaker['current'] as double);
              print(
                  'No current data found, using fallback: ${breaker['current']} for breaker: $breakerId');
            }
          } else {
            maxCurrent = max(maxCurrent, breaker['current'] as double);
            print(
                'No current snapshot, using fallback: ${breaker['current']} for breaker: $breakerId');
          }
        } catch (e) {
          print('Error reading current for $breakerId: $e');
          maxCurrent = max(maxCurrent, breaker['current'] as double);
        }

        try {
          // Read from power collection (structure: power/circuitBreakerId/randomId/)
          final powerSnapshot = await _dbRef
              .child('power')
              .child(breakerId)
              .limitToLast(100)
              .get();
          if (powerSnapshot.exists && powerSnapshot.value != null) {
            final data = Map<dynamic, dynamic>.from(powerSnapshot.value as Map);
            if (data.isNotEmpty) {
              print(
                  'Power data found for breaker $breakerId: ${data.length} entries');
              data.forEach((key, value) {
                if (value is Map && value.containsKey('power')) {
                  double power = (value['power'] as num).toDouble();
                  maxPower = max(maxPower, power);
                }
              });
            } else {
              maxPower = max(maxPower, breaker['power'] as double);
              print(
                  'No power data found, using fallback: ${breaker['power']} for breaker: $breakerId');
            }
          } else {
            maxPower = max(maxPower, breaker['power'] as double);
            print(
                'No power snapshot, using fallback: ${breaker['power']} for breaker: $breakerId');
          }
        } catch (e) {
          print('Error reading power for $breakerId: $e');
          maxPower = max(maxPower, breaker['power'] as double);
        }

        try {
          // Read from temperature collection (structure: temperature/circuitBreakerId/randomId/)
          final temperatureSnapshot = await _dbRef
              .child('temperature')
              .child(breakerId)
              .limitToLast(100)
              .get();
          if (temperatureSnapshot.exists && temperatureSnapshot.value != null) {
            final data =
                Map<dynamic, dynamic>.from(temperatureSnapshot.value as Map);
            if (data.isNotEmpty) {
              print(
                  'Temperature data found for breaker $breakerId: ${data.length} entries');
              data.forEach((key, value) {
                if (value is Map && value.containsKey('temperature')) {
                  double temperature = (value['temperature'] as num).toDouble();
                  maxTemperature = max(maxTemperature, temperature);
                }
              });
            } else {
              maxTemperature =
                  max(maxTemperature, breaker['temperature'] as double);
              print(
                  'No temperature data found, using fallback: ${breaker['temperature']} for breaker: $breakerId');
            }
          } else {
            maxTemperature =
                max(maxTemperature, breaker['temperature'] as double);
            print(
                'No temperature snapshot, using fallback: ${breaker['temperature']} for breaker: $breakerId');
          }
        } catch (e) {
          print('Error reading temperature for $breakerId: $e');
          maxTemperature =
              max(maxTemperature, breaker['temperature'] as double);
        }

        try {
          // Read from energy collection (structure: energy/circuitBreakerId/randomId/)
          final energySnapshot = await _dbRef
              .child('energy')
              .child(breakerId)
              .limitToLast(100)
              .get();
          if (energySnapshot.exists && energySnapshot.value != null) {
            final data =
                Map<dynamic, dynamic>.from(energySnapshot.value as Map);
            if (data.isNotEmpty) {
              print(
                  'Energy data found for breaker $breakerId: ${data.length} entries');
              data.forEach((key, value) {
                if (value is Map && value.containsKey('energy')) {
                  double energy = (value['energy'] as num).toDouble();
                  // For energy, we need to find the absolute maximum value (highest positive or lowest negative)
                  // This ensures we capture the full range of energy values
                  if (energy.abs() > maxEnergy.abs()) {
                    maxEnergy = energy;
                  }
                }
              });
            } else {
              maxEnergy = max(maxEnergy, breaker['energy'] as double);
              print(
                  'No energy data found, using fallback: ${breaker['energy']} for breaker: $breakerId');
            }
          } else {
            maxEnergy = max(maxEnergy, breaker['energy'] as double);
            print(
                'No energy snapshot, using fallback: ${breaker['energy']} for breaker: $breakerId');
          }
        } catch (e) {
          print('Error reading energy for $breakerId: $e');
          maxEnergy = max(maxEnergy, breaker['energy'] as double);
        }
      }

      return {
        'voltage': maxVoltage,
        'current': maxCurrent,
        'power': maxPower,
        'temperature': maxTemperature,
        'energy': maxEnergy,
      };
    } catch (e) {
      print('Error getting highest readings: $e');
      return {
        'voltage': 0.0,
        'current': 0.0,
        'power': 0.0,
        'temperature': 0.0,
        'energy': 0.0,
      };
    }
  }

  // Get real-time data points for line graph
  Future<List<double>> getRealTimeData(
      String breakerId, String dataType) async {
    try {
      // Get data from the correct structure: dataType/circuitBreakerId/randomId/
      // First get all data without ordering to ensure we get the latest entries
      final snapshot = await _dbRef
          .child(dataType)
          .child(breakerId)
          .limitToLast(
              100) // Get more entries to ensure we have enough after sorting
          .get();

      print(
          'Real-time data snapshot for $dataType/$breakerId - exists: ${snapshot.exists}');

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        List<MapEntry> entries = data.entries.toList();
        print('Real-time data entries count: ${entries.length}');

        // Sort by timestamp in descending order to get the latest first
        entries.sort((a, b) {
          int aTimestamp = 0;
          int bTimestamp = 0;

          if (a.value is Map && a.value.containsKey('timestamp')) {
            aTimestamp = (a.value['timestamp'] as num).toInt();
            if (aTimestamp < 10000000000) {
              // It's in seconds, convert to milliseconds
              aTimestamp = aTimestamp * 1000;
            }
          }

          if (b.value is Map && b.value.containsKey('timestamp')) {
            bTimestamp = (b.value['timestamp'] as num).toInt();
            if (bTimestamp < 10000000000) {
              // It's in seconds, convert to milliseconds
              bTimestamp = bTimestamp * 1000;
            }
          }

          return bTimestamp
              .compareTo(aTimestamp); // Descending order (newest first)
        });

        // Take the latest 20 entries and sort them in chronological order
        List<MapEntry> latestEntries = entries.take(20).toList();
        latestEntries.sort((a, b) {
          int aTimestamp = 0;
          int bTimestamp = 0;

          if (a.value is Map && a.value.containsKey('timestamp')) {
            aTimestamp = (a.value['timestamp'] as num).toInt();
            if (aTimestamp < 10000000000) {
              aTimestamp = aTimestamp * 1000;
            }
          }

          if (b.value is Map && b.value.containsKey('timestamp')) {
            bTimestamp = (b.value['timestamp'] as num).toInt();
            if (bTimestamp < 10000000000) {
              bTimestamp = bTimestamp * 1000;
            }
          }

          return aTimestamp
              .compareTo(bTimestamp); // Ascending order (oldest first)
        });

        // Extract the values in chronological order
        List<double> values = [];
        for (var entry in latestEntries) {
          if (entry.value is Map && entry.value.containsKey(dataType)) {
            final value = entry.value[dataType] as num? ?? 0;
            // Handle negative values properly for all metrics, especially energy
            values.add(value.toDouble());
          }
        }

        print('Real-time values extracted: ${values.length} values');
        return values.isNotEmpty ? values : _generateMockRealTimeData();
      }

      print('No real-time data found, using mock data');
      return _generateMockRealTimeData();
    } catch (e) {
      print('Error fetching real-time data: $e');
      return _generateMockRealTimeData();
    }
  }

  // Helper method to get period labels
  List<String> _getPeriodLabels(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'day':
        return ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '24:00'];
      case 'week':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'month':
        return ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      case 'year':
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
      default:
        return [];
    }
  }

  // Helper method to get dynamic period labels based on current date
  List<String> _getDynamicPeriodLabels(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'day':
        // Show days of the current week: Mon, Tue, Wed... (current week only)
        List<String> daysOfWeek = [];
        // Find the start of the current week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

        for (int i = 0; i < 7; i++) {
          final day = startOfWeek.add(Duration(days: i));
          daysOfWeek.add(_getDayName(day.weekday));
        }
        return daysOfWeek;
      case 'week':
        // Generate week ranges for the last 4 weeks: Oct 7 - Nov 2, Nov 3–9, Nov 10–16...
        List<String> weekRanges = [];
        for (int i = 3; i >= 0; i--) {
          // Calculate the start of the week (Monday)
          final currentWeekMonday =
              now.subtract(Duration(days: now.weekday - 1));
          final weekStart = currentWeekMonday.subtract(Duration(days: i * 7));
          final weekEnd = weekStart.add(Duration(days: 6));

          final startMonthName = _getMonthName(weekStart.month);
          final startDay = weekStart.day;
          final endMonthName = _getMonthName(weekEnd.month);
          final endDay = weekEnd.day;

          if (startMonthName == endMonthName) {
            weekRanges.add('$startMonthName $startDay-$endDay');
          } else {
            weekRanges.add('$startMonthName $startDay - $endMonthName $endDay');
          }
        }
        return weekRanges;
      case 'month':
        // Show last 6 months with 3-letter names: Jan, Feb...
        List<String> monthNames = [];
        final allMonths = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];

        for (int i = 5; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final monthIndex = (monthDate.month - 1) % 12;
          monthNames.add(allMonths[monthIndex]);
        }
        return monthNames;
      case 'year':
        // Show last 4 years: 2022, 2023...
        List<String> years = [];
        for (int i = 3; i >= 0; i--) {
          years.add('${now.year - i}');
        }
        return years;
      default:
        return [];
    }
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1]; // weekday: 1=Monday, 7=Sunday
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Helper method to determine which label a timestamp belongs to
  String? _getLabelForTimestamp(
      DateTime dateTime, String period, List<String> labels, DateTime now) {
    switch (period) {
      case 'day':
        // Group by day names (Mon, Tue, Wed...) - only for current week
        final dayName = _getDayName(dateTime.weekday);

        // Check if the date is within the current week
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));

        if (dateTime.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
            dateTime.isBefore(endOfWeek.add(Duration(days: 1)))) {
          return labels.contains(dayName) ? dayName : null;
        }
        return null;

      case 'week':
        // Group by week ranges (Oct 29-Nov 4, Nov 5-11, etc.)
        for (String weekRange in labels) {
          // Parse the week range to get start and end dates
          if (weekRange.contains(' - ')) {
            // Different months: "Oct 29 - Nov 4"
            final parts = weekRange.split(' - ');
            final startParts = parts[0].split(' ');
            final endParts = parts[1].split(' ');

            if (startParts.length >= 2 && endParts.length >= 2) {
              final startMonth = _getMonthNumber(startParts[0]);
              final startDay = int.tryParse(startParts[1]) ?? 1;
              final endMonth = _getMonthNumber(endParts[0]);
              final endDay = int.tryParse(endParts[1]) ?? 1;

              // Adjust year if needed
              int startYear = now.year;
              int endYear = now.year;
              if (startMonth > now.month) startYear--;
              if (endMonth > now.month) endYear--;

              final startDate = DateTime(startYear, startMonth, startDay);
              final endDate = DateTime(endYear, endMonth, endDay);

              if ((dateTime.isAtSameMomentAs(startDate) ||
                      dateTime.isAfter(startDate)) &&
                  (dateTime.isAtSameMomentAs(endDate) ||
                      dateTime.isBefore(endDate))) {
                return weekRange;
              }
            }
          } else {
            // Same month: "Nov 5-11"
            final parts = weekRange.split(' ');
            if (parts.length >= 2) {
              final month = _getMonthNumber(parts[0]);
              final dateRange = parts[1].split('-');
              if (dateRange.length == 2) {
                final startDay = int.tryParse(dateRange[0]) ?? 1;
                final endDay = int.tryParse(dateRange[1]) ?? 1;

                // Adjust year if needed
                int year = now.year;
                if (month > now.month) year--;

                final startDate = DateTime(year, month, startDay);
                final endDate = DateTime(year, month, endDay);

                if ((dateTime.isAtSameMomentAs(startDate) ||
                        dateTime.isAfter(startDate)) &&
                    (dateTime.isAtSameMomentAs(endDate) ||
                        dateTime.isBefore(endDate))) {
                  return weekRange;
                }
              }
            }
          }
        }
        return null;

      case 'month':
        // Group by month names (Jan, Feb...) - only last 6 months
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];

        // Check if the date is within the last 6 months
        final sixMonthsAgo = DateTime(now.year, now.month - 5, 1);
        if (dateTime.isAfter(sixMonthsAgo.subtract(Duration(days: 1))) &&
            dateTime.month >= 1 &&
            dateTime.month <= 12) {
          return months[dateTime.month - 1];
        }
        return null;

      case 'year':
        // Group by year (2022, 2023...) - only last 4 years
        final fourYearsAgo = now.year - 3;
        if (dateTime.year >= fourYearsAgo) {
          return '${dateTime.year}';
        }
        return null;

      default:
        return null;
    }
  }

  // Helper method to convert month name to month number
  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  // Generate mock data (fallback when Firebase data is not available)
  Map<String, dynamic> _generateMockData(String period) {
    final labels = _getDynamicPeriodLabels(period);
    Map<String, dynamic> mockData = {};

    for (String label in labels) {
      mockData[label] = 0.0; // Return 0 instead of mock data
    }

    return mockData;
  }

  // Generate mock real-time data
  List<double> _generateMockRealTimeData() {
    final random = Random();
    return List.generate(20, (index) => 200.0 + random.nextDouble() * 50.0);
  }
}
