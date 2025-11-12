// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Warnings extends StatefulWidget {
  const Warnings({super.key});

  @override
  State<Warnings> createState() => _WarningsState();
}

class _WarningsState extends State<Warnings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? scbId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get scbId from route arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      scbId = args['scbId'];
    }
  }

  List WarningDates = [
    ["December 20, 2025", "9:00 PM"],
    ["December 19, 2025", "8:45 PM"],
    ["December 18, 2025", "6:30 AM"],
    ["December 17, 2025", "2:15 PM"],
    ["December 16, 2025", "7:50 PM"],
    ["December 15, 2025", "5:10 PM"],
    ["December 14, 2025", "8:00 AM"],
    ["December 13, 2025", "9:35 PM"],
    ["December 12, 2025", "10:05 PM"],
    ["December 11, 2025", "1:25 PM"],
    ["December 10, 2025", "11:40 AM"],
    ["December 9, 2025", "4:10 PM"],
    ["December 8, 2025", "7:55 PM"],
    ["December 7, 2025", "6:15 PM"],
    ["December 6, 2025", "9:25 AM"],
    ["December 5, 2025", "8:45 AM"],
    ["December 4, 2025", "10:30 PM"],
    ["December 3, 2025", "3:20 PM"],
    ["December 2, 2025", "2:50 PM"],
    ["December 1, 2025", "12:00 PM"],
    ["November 30, 2025", "9:15 PM"],
    ["November 29, 2025", "6:45 PM"],
    ["November 28, 2025", "4:30 PM"],
    ["November 27, 2025", "10:15 AM"],
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('alarmHistory')
            .where('scbId', isEqualTo: scbId)
            .where('action', isEqualTo: 'alarm') // Only include notify events
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, alarmSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('warningHistory')
                .where('scbId', isEqualTo: scbId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, warningSnapshot) {
              if (alarmSnapshot.connectionState == ConnectionState.waiting ||
                  warningSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
                );
              }

              // Combine both collections
              final List<QueryDocumentSnapshot> allWarnings = [];

              if (alarmSnapshot.hasData) {
                allWarnings.addAll(alarmSnapshot.data!.docs);
              }

              if (warningSnapshot.hasData) {
                allWarnings.addAll(warningSnapshot.data!.docs);
              }

              if (allWarnings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No warning events recorded yet',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                );
              }

              // Sort combined list by timestamp (descending)
              allWarnings.sort((a, b) {
                final aTimestamp = a['timestamp'] as Timestamp?;
                final bTimestamp = b['timestamp'] as Timestamp?;

                if (aTimestamp == null && bTimestamp == null) return 0;
                if (aTimestamp == null) return 1;
                if (bTimestamp == null) return -1;

                return bTimestamp.compareTo(aTimestamp);
              });

              final warnings = allWarnings;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Table(
                            border: TableBorder.symmetric(
                              inside: BorderSide(color: Colors.transparent),
                              outside: BorderSide(color: Colors.transparent),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(3), // "Date" column (narrower)
                              1: FlexColumnWidth(1.1), // "Time" column (wider)
                            },
                            children: [
                              // Header Row
                              TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Date',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      'Time',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Data Rows
                              for (var doc in warnings)
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _formatDate(doc['timestamp']),
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '${doc['type']} (${_getEventLabel(doc)})',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300,
                                              color: _getEventColor(doc),
                                            ),
                                          ),
                                          Text(
                                            '${doc['currentValue']}${doc['unit']} / ${doc['thresholdValue']}${doc['unit']}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                              color: _getEventColor(doc),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        _formatTime(doc['timestamp']),
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    final date = timestamp.toDate();
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  String _getEventLabel(QueryDocumentSnapshot doc) {
    final action = doc['action'] as String?;
    if (action == 'alarm') {
      return 'NOTIFY';
    } else if (action == 'warning') {
      return 'WARNING';
    }
    return 'UNKNOWN';
  }

  Color _getEventColor(QueryDocumentSnapshot doc) {
    final action = doc['action'] as String?;
    if (action == 'alarm') {
      return Colors.blue[700]!; // Blue for notify events
    } else if (action == 'warning') {
      return Colors.orange[700]!; // Orange for warning events
    }
    return Colors.grey[600]!;
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
