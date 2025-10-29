// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_ActivityLogs/activity_log_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_cb_1/services/firebase_auth_service.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? scbId;
  Map<String, List<Map<String, dynamic>>> _groupedActivities = {};
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get scbId from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      scbId = args['scbId'];
      _fetchActivityLogs();
    }
  }

  final FirebaseAuthService _authService = FirebaseAuthService();
  Future<void> _fetchActivityLogs() async {
    if (scbId == null) return;

    try {
      final snapshot = await _firestore
          .collection('activityLogs')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('scbId', isEqualTo: scbId)
          .orderBy('timestamp', descending: true)
          .get();

      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp == null) continue;
        User? currentUser = _authService.currentUser;
        final date = timestamp.toDate();
        final monthYear = '${_getMonthName(date.month)} ${date.year}';
        DocumentSnapshot? userData =
            await _authService.getUserData(currentUser!.uid);
        final dayData = {
          'date': date.day.toString(),
          'day': _getDayName(date.weekday),
          'activities': [
            {
              'activity': _formatActivity(data),
              'person': userData!['name'] ?? 'Unknown User',
              'time': _formatTime(timestamp),
            }
          ],
        };

        if (grouped.containsKey(monthYear)) {
          // Check if we already have this day
          final existingDayIndex = grouped[monthYear]!.indexWhere(
            (item) => item['date'] == dayData['date'],
          );

          if (existingDayIndex != -1) {
            // Add activity to existing day
            final existingDay = grouped[monthYear]![existingDayIndex];
            final activities =
                existingDay['activities'] as List<Map<String, dynamic>>;
            final newActivity =
                dayData['activities'] as List<Map<String, dynamic>>;
            activities.add(newActivity[0]);
          } else {
            // Add new day
            grouped[monthYear]!.add(dayData);
          }
        } else {
          // Add new month with first day
          grouped[monthYear] = [dayData];
        }
      }

      setState(() {
        _groupedActivities = grouped;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching activity logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  String _formatActivity(Map<String, dynamic> data) {
    final action = data['action'] as String? ?? '';
    final thresholdType = data['thresholdType'] as String? ?? '';
    final enabled = data['enabled'] as bool? ?? false;

    switch (action.toLowerCase()) {
      case 'edit':
        return 'has edited the $thresholdType.';
      case 'on':
        return 'turned ON the CB.';
      case 'off':
        return 'turned OFF the CB.';
      case 'update':
        return 'has updated the $thresholdType.';
      case 'create':
        return 'has created a new $thresholdType.';
      case 'delete':
        return 'has deleted the $thresholdType.';
      default:
        if (enabled) {
          return 'enabled the $thresholdType.';
        } else {
          return 'disabled the $thresholdType.';
        }
    }
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 30,
                      top: 50,
                      right: 30,
                      bottom: 30,
                    ),
                    child: Center(
                      child: Text(
                        'Activity Logs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // History
              Expanded(
                child: _isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF2ECC71)),
                      )
                    : _groupedActivities.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No activity logs yet',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _groupedActivities.keys.length,
                            itemBuilder: (context, index) {
                              final monthYear =
                                  _groupedActivities.keys.elementAt(index);
                              final monthParts = monthYear.split(' ');
                              final monthName = monthParts[0];
                              final year = monthParts[1];

                              return HistoryTile(
                                dateName: monthName,
                                dateYear: year,
                                scbId: scbId ?? '',
                                eventData: _groupedActivities[monthYear]!,
                              );
                            },
                          ),
              ),

              SizedBox(height: 60),
            ],
          ),

          // NAVIGATION
          NavigationPage(),
        ],
      ),
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
