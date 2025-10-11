// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:smart_cb_1/MainFunctions/ActivityLogs/activity_log_tile.dart';
import 'package:smart_cb_1/MainFunctions/Navigation/navigation_page.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List historyDates = [
    ["December", "2024"],
    ["November", "2024"],
    ["October", "2024"],
    ["September", "2024"],
    ["August", "2024"],
    ["July", "2024"],
    ["June", "2024"],
  ];

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
                        Navigator.pushNamed(context, '/bracketoption');
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
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: historyDates.length,
                    itemBuilder: (context, index) {
                      return HistoryTile(
                        dateName: historyDates[index][0],
                        dateYear: historyDates[index][1],
                      );
                    },
                  ),
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
