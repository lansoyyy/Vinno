import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';

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
      });
      return breakers;
    });
  }

  // Get historical data for a specific circuit breaker
  Future<Map<String, dynamic>> getHistoricalData(
      String breakerId, String period,
      {String metric = 'energy'}) async {
    try {
      // First try to get data from new structure (voltage/CB-LIVING-002/)
      final snapshot = await _dbRef.child(metric).child(breakerId).get();

      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        final labels = _getDynamicPeriodLabels(period);
        Map<String, dynamic> result = {};

        // Convert data entries to list with timestamps
        List<MapEntry<dynamic, dynamic>> dataEntries = data.entries.toList();

        // Sort by timestamp
        dataEntries.sort((a, b) {
          final aTimestamp =
              (a.value is Map && a.value.containsKey('timestamp'))
                  ? a.value['timestamp'] as int
                  : 0;
          final bTimestamp =
              (b.value is Map && b.value.containsKey('timestamp'))
                  ? b.value['timestamp'] as int
                  : 0;
          return aTimestamp.compareTo(bTimestamp);
        });

        // Group data by time periods based on timestamps
        final now = DateTime.now();
        final Map<String, List<double>> groupedData = {};

        for (String label in labels) {
          groupedData[label] = [];
        }

        for (var entry in dataEntries) {
          if (entry.value is Map &&
              entry.value.containsKey(metric) &&
              entry.value.containsKey('timestamp')) {
            final timestamp = entry.value['timestamp'] as int;
            final dateTime =
                DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
            final value = (entry.value[metric] as num).toDouble();

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

        // Calculate average for each period
        for (String label in labels) {
          if (groupedData[label]!.isNotEmpty) {
            double sum = groupedData[label]!.reduce((a, b) => a + b);
            result[label] = sum / groupedData[label]!.length;
          } else {
            // If no data for this period, use 0 or interpolate
            result[label] = 0.0;
          }
        }

        return result;
      }

      // First try to get data from historicalData node (for future implementation)
      final historicalSnapshot = await _dbRef
          .child('historicalData')
          .child(breakerId)
          .child(period)
          .get();

      if (historicalSnapshot.exists) {
        return Map<String, dynamic>.from(historicalSnapshot.value as Map);
      }

      // If no historical data exists, use current readings from circuit breaker
      final breakerSnapshot =
          await _dbRef.child('circuitBreakers').child(breakerId).get();

      if (breakerSnapshot.exists) {
        final breakerData =
            Map<String, dynamic>.from(breakerSnapshot.value as Map);
        final labels = _getDynamicPeriodLabels(period);
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

  // Get current readings for all circuit breakers from metric collections
  Stream<Map<String, double>> getCurrentReadings() {
    return getCircuitBreakers().asyncMap((breakers) async {
      double totalVoltage = 0;
      double totalCurrent = 0;
      double totalPower = 0;
      double totalTemperature = 0;
      double totalEnergy = 0;

      for (var breaker in breakers) {
        String breakerId = breaker['scbId'];

        // Read from voltage collection
        final voltageSnapshot =
            await _dbRef.child('voltage').child(breakerId).limitToLast(1).get();
        if (voltageSnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(voltageSnapshot.value as Map);
          final latestEntry = data.values.first;
          if (latestEntry is Map && latestEntry.containsKey('voltage')) {
            totalVoltage += (latestEntry['voltage'] as num).toDouble();
          }
        } else {
          totalVoltage += breaker['voltage'] as double;
        }

        // Read from current collection
        final currentSnapshot =
            await _dbRef.child('current').child(breakerId).limitToLast(1).get();
        if (currentSnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(currentSnapshot.value as Map);
          final latestEntry = data.values.first;
          if (latestEntry is Map && latestEntry.containsKey('current')) {
            totalCurrent += (latestEntry['current'] as num).toDouble();
          }
        } else {
          totalCurrent += breaker['current'] as double;
        }

        // Read from power collection
        final powerSnapshot =
            await _dbRef.child('power').child(breakerId).limitToLast(1).get();
        if (powerSnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(powerSnapshot.value as Map);
          final latestEntry = data.values.first;
          if (latestEntry is Map && latestEntry.containsKey('power')) {
            totalPower += (latestEntry['power'] as num).toDouble();
          }
        } else {
          totalPower += breaker['power'] as double;
        }

        // Read from temperature collection
        final temperatureSnapshot = await _dbRef
            .child('temperature')
            .child(breakerId)
            .limitToLast(1)
            .get();
        if (temperatureSnapshot.exists) {
          final data =
              Map<dynamic, dynamic>.from(temperatureSnapshot.value as Map);
          final latestEntry = data.values.first;
          if (latestEntry is Map && latestEntry.containsKey('temperature')) {
            totalTemperature += (latestEntry['temperature'] as num).toDouble();
          }
        } else {
          totalTemperature += breaker['temperature'] as double;
        }

        // Read from energy collection
        final energySnapshot =
            await _dbRef.child('energy').child(breakerId).limitToLast(1).get();
        if (energySnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(energySnapshot.value as Map);
          final latestEntry = data.values.first;
          if (latestEntry is Map && latestEntry.containsKey('energy')) {
            totalEnergy += (latestEntry['energy'] as num).toDouble();
          }
        } else {
          totalEnergy += breaker['energy'] as double;
        }
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

        // Read from voltage collection
        final voltageSnapshot =
            await _dbRef.child('voltage').child(breakerId).get();
        if (voltageSnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(voltageSnapshot.value as Map);
          data.forEach((key, value) {
            if (value is Map && value.containsKey('voltage')) {
              double voltage = (value['voltage'] as num).toDouble();
              maxVoltage = max(maxVoltage, voltage);
            }
          });
        } else {
          maxVoltage = max(maxVoltage, breaker['voltage'] as double);
        }

        // Read from current collection
        final currentSnapshot =
            await _dbRef.child('current').child(breakerId).get();
        if (currentSnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(currentSnapshot.value as Map);
          data.forEach((key, value) {
            if (value is Map && value.containsKey('current')) {
              double current = (value['current'] as num).toDouble();
              maxCurrent = max(maxCurrent, current);
            }
          });
        } else {
          maxCurrent = max(maxCurrent, breaker['current'] as double);
        }

        // Read from power collection
        final powerSnapshot =
            await _dbRef.child('power').child(breakerId).get();
        if (powerSnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(powerSnapshot.value as Map);
          data.forEach((key, value) {
            if (value is Map && value.containsKey('power')) {
              double power = (value['power'] as num).toDouble();
              maxPower = max(maxPower, power);
            }
          });
        } else {
          maxPower = max(maxPower, breaker['power'] as double);
        }

        // Read from temperature collection
        final temperatureSnapshot =
            await _dbRef.child('temperature').child(breakerId).get();
        if (temperatureSnapshot.exists) {
          final data =
              Map<dynamic, dynamic>.from(temperatureSnapshot.value as Map);
          data.forEach((key, value) {
            if (value is Map && value.containsKey('temperature')) {
              double temperature = (value['temperature'] as num).toDouble();
              maxTemperature = max(maxTemperature, temperature);
            }
          });
        } else {
          maxTemperature =
              max(maxTemperature, breaker['temperature'] as double);
        }

        // Read from energy collection
        final energySnapshot =
            await _dbRef.child('energy').child(breakerId).get();
        if (energySnapshot.exists) {
          final data = Map<dynamic, dynamic>.from(energySnapshot.value as Map);
          data.forEach((key, value) {
            if (value is Map && value.containsKey('energy')) {
              double energy = (value['energy'] as num).toDouble();
              maxEnergy = max(maxEnergy, energy);
            }
          });
        } else {
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
      // First try to get data from the new structure (voltage/CB-LIVING-002/randomId/)
      final snapshot =
          await _dbRef.child(dataType).child(breakerId).limitToLast(20).get();

      if (snapshot.exists) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        List<MapEntry> entries = data.entries.toList();

        // Sort by timestamp
        entries.sort((a, b) {
          final aTimestamp = a.value['timestamp'] as int? ?? 0;
          final bTimestamp = b.value['timestamp'] as int? ?? 0;
          return aTimestamp.compareTo(bTimestamp);
        });

        // Extract the values in chronological order
        return entries.map((entry) {
          final value = entry.value[dataType] as num? ?? 0;
          return value.toDouble();
        }).toList();
      }

      // Fallback to old structure
      final oldSnapshot = await _dbRef
          .child('realTimeData')
          .child(breakerId)
          .child(dataType)
          .limitToLast(20)
          .get();

      if (oldSnapshot.exists) {
        final data = Map<dynamic, dynamic>.from(oldSnapshot.value as Map);
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
        // Show last 7 days with proper day names and dates
        List<String> dayNames = [];
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dayName = _getDayName(date.weekday);
          final dayOfMonth = date.day;
          final monthName = _getMonthName(date.month);
          dayNames.add('$dayName $monthName $dayOfMonth');
        }
        return dayNames;
      case 'week':
        // Generate week ranges for the last 4 weeks
        List<String> weekRanges = [];
        for (int i = 3; i >= 0; i--) {
          final weekStart =
              now.subtract(Duration(days: (i * 7) + now.weekday - 1));
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
        // Show last 12 months with proper month names
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

        for (int i = 11; i >= 0; i--) {
          final monthDate = DateTime(now.year, now.month - i, 1);
          final monthIndex = (monthDate.month - 1) % 12;
          monthNames.add(allMonths[monthIndex]);
        }
        return monthNames;
      case 'year':
        // Show last 4 years
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
        // Group by day with date (Mon Nov 5, Tue Nov 6, etc.)
        final dayName = _getDayName(dateTime.weekday);
        final monthName = _getMonthName(dateTime.month);
        final dayOfMonth = dateTime.day;
        final label = '$dayName $monthName $dayOfMonth';

        // Find matching label in our list
        for (String searchLabel in labels) {
          if (searchLabel.contains(dayName) &&
              searchLabel.contains('$monthName $dayOfMonth')) {
            return searchLabel;
          }
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
        // Group by month names (Jan, Feb...)
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
        if (dateTime.month >= 1 && dateTime.month <= 12) {
          return months[dateTime.month - 1];
        }
        return null;

      case 'year':
        // Group by year (2022, 2023...)
        return '${dateTime.year}';

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
