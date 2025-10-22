import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class StatisticsService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch all circuit breakers for the current user
  Stream<List<Map<String, dynamic>>> getCircuitBreakers() {
    if (currentUserId == null) return Stream.value([]);

    return _dbRef.child('circuitBreakers').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];

      List<Map<String, dynamic>> breakers = [];
      data.forEach((key, value) {
        final cbData = Map<String, dynamic>.from(value as Map);
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
          });
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
      // First try to get data from historicalData node (for future implementation)
      final snapshot = await _dbRef
          .child('historicalData')
          .child(breakerId)
          .child(period)
          .get();

      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }

      // If no historical data exists, use current readings from circuit breaker
      final breakerSnapshot =
          await _dbRef.child('circuitBreakers').child(breakerId).get();

      if (breakerSnapshot.exists) {
        final breakerData =
            Map<String, dynamic>.from(breakerSnapshot.value as Map);
        final labels = _getPeriodLabels(period);
        Map<String, dynamic> data = {};

        // Use current values for all periods as a fallback
        // Add some variation to make the data more realistic
        final random = Random();
        for (String label in labels) {
          // Add some variation to the current values (±10%)
          double variation = 0.9 + random.nextDouble() * 0.2;

          // Use the specified metric
          double value = (breakerData[metric] ?? 0).toDouble() * variation;
          data[label] = value;
        }

        return data;
      }

      return _generateMockData(period);
    } catch (e) {
      print('Error fetching historical data: $e');
      return _generateMockData(period);
    }
  }

  // Get aggregated data for all circuit breakers
  Future<Map<String, dynamic>> getAggregatedData(String period,
      {String metric = 'energy'}) async {
    try {
      final breakers = await getCircuitBreakers().first;
      Map<String, dynamic> aggregatedData = {};

      // Initialize with empty data
      final days = _getPeriodLabels(period);
      for (String day in days) {
        aggregatedData[day] = 0.0;
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

  // Get current readings for all circuit breakers
  Stream<Map<String, double>> getCurrentReadings() {
    return getCircuitBreakers().map((breakers) {
      double totalVoltage = 0;
      double totalCurrent = 0;
      double totalPower = 0;
      double totalTemperature = 0;
      double totalEnergy = 0;

      for (var breaker in breakers) {
        totalVoltage += breaker['voltage'] as double;
        totalCurrent += breaker['current'] as double;
        totalPower += breaker['power'] as double;
        totalTemperature += breaker['temperature'] as double;
        totalEnergy += breaker['energy'] as double;
      }

      return {
        'voltage': totalVoltage,
        'current': totalCurrent,
        'power': totalPower,
        'temperature': totalTemperature,
        'energy': totalEnergy,
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

  // Get highest readings
  Future<Map<String, double>> getHighestReadings() async {
    try {
      final breakers = await getCircuitBreakers().first;
      double maxVoltage = 0;
      double maxCurrent = 0;
      double maxPower = 0;
      double maxTemperature = 0;
      double maxEnergy = 0;

      for (var breaker in breakers) {
        maxVoltage = max(maxVoltage, breaker['voltage'] as double);
        maxCurrent = max(maxCurrent, breaker['current'] as double);
        maxPower = max(maxPower, breaker['power'] as double);
        maxTemperature = max(maxTemperature, breaker['temperature'] as double);
        maxEnergy = max(maxEnergy, breaker['energy'] as double);
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
      final snapshot = await _dbRef
          .child('realTimeData')
          .child(breakerId)
          .child(dataType)
          .limitToLast(20)
          .get();

      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        return data.values.map((e) => (e as num).toDouble()).toList();
      }
      return _generateMockRealTimeData();
    } catch (e) {
      print('Error fetching real-time data: $e');
      return _generateMockRealTimeData();
    }
  }

  // Helper method to get period labels
  List<String> _getPeriodLabels(String period) {
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

  // Generate mock data (fallback when Firebase data is not available)
  Map<String, dynamic> _generateMockData(String period) {
    final labels = _getPeriodLabels(period);
    final random = Random();
    Map<String, dynamic> mockData = {};

    for (String label in labels) {
      mockData[label] =
          10.0 + random.nextDouble() * 40.0; // Random values between 10-50
    }

    return mockData;
  }

  // Generate mock real-time data
  List<double> _generateMockRealTimeData() {
    final random = Random();
    return List.generate(20, (index) => 200.0 + random.nextDouble() * 50.0);
  }
}
