// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryDate extends StatelessWidget {
  final String dateMonth;
  final String dateDay;
  final String dateYear;
  final String day;
  final String scbId;
  final List<Map<String, dynamic>>? activities;

  const HistoryDate({
    super.key,
    required this.dateMonth,
    required this.dateDay,
    required this.dateYear,
    required this.day,
    this.scbId = '',
    this.activities,
  });

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

              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  '$dateMonth $dateDay, $dateYear | $day',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

              // Activities
              Expanded(
                child: activities != null
                    ? _buildActivitiesList(activities!)
                    : _buildActivitiesFromFirebase(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(List<Map<String, dynamic>> activitiesList) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 20),
      itemCount: activitiesList.length,
      itemBuilder: (context, index) {
        final activityItem = activitiesList[index];
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 5,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_pin,
                    size: 50,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TIME
                        Text(
                          activityItem['time'] ?? 'No Time',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Activity
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ), // default text color
                            children: [
                              TextSpan(
                                text: '${activityItem['person']} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: activityItem['activity'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              buildDivider(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivitiesFromFirebase() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('activityLogs')
          .where('scbId', isEqualTo: scbId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No activities for this day',
                style: TextStyle(fontSize: 15),
              ),
            ),
          );
        }

        // Filter activities for the specific date
        final allActivities = snapshot.data!.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              if (timestamp == null) return null;

              final date = timestamp.toDate();
              final dateString = '${date.month} $dateDay, $dateYear';
              final monthName = _getMonthName(date.month);
              final expectedDateString = '$monthName $dateDay, $dateYear';

              // Only include activities for this specific date
              if (dateString != expectedDateString) return null;

              return {
                'id': doc.id,
                'person': data['userName'] ?? 'Unknown User',
                'activity': _formatActivity(data),
                'time': _formatTime(data['timestamp']),
                'data': data,
              };
            })
            .where((item) => item != null)
            .cast<Map<String, dynamic>>()
            .toList();

        return _buildActivitiesList(allActivities);
      },
    );
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

  String _formatActivity(Map<String, dynamic> data) {
    final action = data['action'] as String? ?? '';
    final thresholdType = data['thresholdType'] as String? ?? '';
    final enabled = data['enabled'] as bool? ?? false;
    final activityType = data['activityType'] as String? ?? '';

    // Handle different activity types
    switch (activityType) {
      case 'threshold_settings_summary':
        final changeCount = data['changeCount'] as int? ?? 0;
        return 'made changes to Threshold Settings ($changeCount changes).';
      case 'circuit_breaker_action':
        switch (action.toLowerCase()) {
          case 'on':
            return 'turned ON the CB.';
          case 'off':
            return 'turned OFF the CB.';
          default:
            return 'changed the CB state.';
        }
      case 'threshold_change':
        switch (action.toLowerCase()) {
          case 'edit':
            return 'has edited the $thresholdType.';
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
      default:
        // Fallback for legacy entries or other activity types
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
  }

  String _formatActivitySummary(Map<String, dynamic> activityItem) {
    // Check if this is a threshold summary entry
    if (activityItem.containsKey('action') &&
        activityItem.containsKey('thresholdType') &&
        activityItem.containsKey('count')) {
      final action = activityItem['action'] as String? ?? '';
      final thresholdType = activityItem['thresholdType'] as String? ?? '';
      final count = activityItem['count'] as int? ?? 0;

      switch (action.toLowerCase()) {
        case 'edit':
          return 'User made $count changes to $thresholdType settings';
        case 'update':
          return 'User made $count changes to $thresholdType settings';
        case 'create':
          return 'User created $count new $thresholdType settings';
        case 'delete':
          return 'User deleted $count $thresholdType settings';
        default:
          return 'User $action $thresholdType settings';
      }
    } else {
      // Regular activity, use original formatting
      return _formatActivity(activityItem);
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'No Time';
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is String) {
      date = DateTime.parse(timestamp);
    } else {
      return 'No Time';
    }
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 0.0),
      child: Divider(
          color: Color(0xFF4A4A4A).withValues(alpha: 0.2), thickness: 2.0),
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
