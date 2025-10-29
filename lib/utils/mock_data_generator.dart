import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MockDataGenerator {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate mock circuit breaker data for testing
  Future<void> generateMockCircuitBreakers() async {
    try {
      // Get current user
      final user = _auth.currentUser;
      if (user == null) {
        print('Error: User not logged in');
        return;
      }

      // Get user data to determine account type
      DocumentSnapshot? userData = await _getUserData(user.uid);
      String? ownerId = user.uid;

      if (userData != null && userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        // If user is Admin or Staff, use the 'createdBy' field as ownerId
        if (data['accountType'] == 'Admin' || data['accountType'] == 'Staff') {
          ownerId = data['createdBy'] ?? user.uid;
        }
      }

      // Mock circuit breaker data
      List<Map<String, dynamic>> mockCircuitBreakers = [
        {
          'scbId': 'CB-KITCHEN-001',
          'scbName': 'Kitchen Circuit Breaker',
          'circuitBreakerRating': 100.0,
          'wifiName': 'HomeWiFi_5G',
          'wifiPassword': 'password123',
          'isOn': true,
          'voltage': 220.5,
          'current': 15.2,
          'temperature': 35.5,
          'power': 3351.6,
          'energy': 45.2,
          'latitude': 14.6488,
          'longitude': 121.0509,
          'loc': '',
        },
      ];

      // Save each circuit breaker to the database
      for (var cb in mockCircuitBreakers) {
        // Add owner ID and timestamp
        cb['ownerId'] = ownerId;
        cb['createdAt'] = ServerValue.timestamp;

        // Save to circuitBreakers node
        await _dbRef.child('circuitBreakers').child(cb['scbId']).set(cb);

        // Also add reference under user's circuit breakers
        await _dbRef
            .child('users')
            .child(ownerId!)
            .child('circuitBreakers')
            .child(cb['scbId'])
            .set(true);

        print('Added circuit breaker: ${cb['scbName']}');
      }

      print('Mock circuit breaker data added successfully!');
    } catch (e) {
      print('Error adding mock data: $e');
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot?> _getUserData(String uid) async {
    try {
      // Check in owners collection first
      DocumentSnapshot doc =
          await _firestore.collection('owners').doc(uid).get();
      if (doc.exists) {
        return doc;
      }

      // Check in admins collection
      doc = await _firestore.collection('admins').doc(uid).get();
      if (doc.exists) {
        return doc;
      }

      // Check in staff collection
      doc = await _firestore.collection('staff').doc(uid).get();
      if (doc.exists) {
        return doc;
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Generate mock historical data for circuit breakers
  Future<void> generateMockHistoricalData() async {
    try {
      // Get current user
      final user = _auth.currentUser;
      if (user == null) {
        print('Error: User not logged in');
        return;
      }

      // Get user data to determine account type
      DocumentSnapshot? userData = await _getUserData(user.uid);
      String? ownerId = user.uid;

      if (userData != null && userData.exists) {
        Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
        // If user is Admin or Staff, use the 'createdBy' field as ownerId
        if (data['accountType'] == 'Admin' || data['accountType'] == 'Staff') {
          ownerId = data['createdBy'] ?? user.uid;
        }
      }

      // Get all circuit breakers for the user
      final snapshot = await _dbRef.child('circuitBreakers').get();
      if (!snapshot.exists) {
        print('No circuit breakers found');
        return;
      }

      final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
      List<String> breakerIds = [];

      data.forEach((key, value) {
        final cbData = Map<String, dynamic>.from(value as Map);
        if (cbData['ownerId'] == ownerId) {
          breakerIds.add(key);
        }
      });

      // Generate historical data for each circuit breaker
      for (String breakerId in breakerIds) {
        await _generateHistoricalDataForBreaker(breakerId);
      }

      print('Mock historical data added successfully!');
    } catch (e) {
      print('Error adding mock historical data: $e');
    }
  }

  // Generate historical data for a specific circuit breaker
  Future<void> _generateHistoricalDataForBreaker(String breakerId) async {
    final random = DateTime.now().millisecondsSinceEpoch;

    // Generate data for different time periods
    Map<String, Map<String, dynamic>> historicalData = {
      'day': _generateDayData(random),
      'week': _generateWeekData(random),
      'month': _generateMonthData(random),
      'year': _generateYearData(random),
    };

    // Save historical data
    for (String period in historicalData.keys) {
      await _dbRef
          .child('historicalData')
          .child(breakerId)
          .child(period)
          .set(historicalData[period]);
    }

    // Generate real-time data points
    List<double> realTimeData = _generateRealTimeDataPoints();
    await _dbRef
        .child('realTimeData')
        .child(breakerId)
        .child('voltage')
        .set(realTimeData.asMap());

    await _dbRef
        .child('realTimeData')
        .child(breakerId)
        .child('current')
        .set(realTimeData.asMap());

    await _dbRef
        .child('realTimeData')
        .child(breakerId)
        .child('power')
        .set(realTimeData.asMap());

    await _dbRef
        .child('realTimeData')
        .child(breakerId)
        .child('temperature')
        .set(realTimeData.asMap());

    print('Generated historical data for breaker: $breakerId');
  }

  // Generate data for a day (hourly)
  Map<String, dynamic> _generateDayData(int seed) {
    Map<String, dynamic> data = {};
    final random = Random(seed);

    for (int i = 0; i < 24; i++) {
      String hour = i.toString().padLeft(2, '0') + ':00';
      data[hour] =
          10.0 + random.nextDouble() * 40.0; // Random values between 10-50
    }

    return data;
  }

  // Generate data for a week (daily)
  Map<String, dynamic> _generateWeekData(int seed) {
    Map<String, dynamic> data = {};
    final random = Random(seed);
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (String day in days) {
      data[day] =
          50.0 + random.nextDouble() * 100.0; // Random values between 50-150
    }

    return data;
  }

  // Generate data for a month (weekly)
  Map<String, dynamic> _generateMonthData(int seed) {
    Map<String, dynamic> data = {};
    final random = Random(seed);

    for (int i = 1; i <= 4; i++) {
      String week = 'Week $i';
      data[week] =
          200.0 + random.nextDouble() * 300.0; // Random values between 200-500
    }

    return data;
  }

  // Generate data for a year (monthly)
  Map<String, dynamic> _generateYearData(int seed) {
    Map<String, dynamic> data = {};
    final random = Random(seed);
    List<String> months = [
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

    for (String month in months) {
      data[month] = 500.0 +
          random.nextDouble() * 1000.0; // Random values between 500-1500
    }

    return data;
  }

  // Generate real-time data points
  List<double> _generateRealTimeDataPoints() {
    final random = Random();
    return List.generate(20, (index) => 200.0 + random.nextDouble() * 50.0);
  }
}
