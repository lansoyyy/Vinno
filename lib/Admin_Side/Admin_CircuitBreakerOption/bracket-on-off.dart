// ignore_for_file: must_be_immutable, prefer_const_constructors_in_immutables, unrelated_type_equality_checks

import 'package:flutter/material.dart';

class BracketOnOff extends StatelessWidget {
  final bool click;
  final VoidCallback onPress;

  BracketOnOff({super.key, required this.click, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //ClipPath: The Curved Shape (ON/OFF)
        ClipPath(
          clipper: CustomClipPath(),
          child: Container(
            decoration: BoxDecoration(
              gradient: click == false
                  ? LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF1EA557)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Color(0xFFF85D4D), Color(0xFF792E2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            height: 280,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(
            left: 30,
            top: 50,
            right: 30,
            bottom: 30,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/cblist');
                },
                child: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),

              SizedBox(width: 15),

              Text(
                'Circuit Breaker Name',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 280, // or whatever height you want to constrain the area
          // Align: Power Button
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: click == false
                    ? const LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF1CA656)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFF85D4D), Color(0xFF792E2E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xffFFFDFD),
                    spreadRadius: 13,
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(15), // match IconButton padding
              child: IconButton(
                icon: Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 110,
                  weight: 700,
                ),
                onPressed: onPress,
              ),
            ),
          ),
        ),
      ],
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
    path.lineTo(0, h - 130); //line 2
    path.quadraticBezierTo(
      w * 0.5, // 3 Point
      h + 15, // 3 Point
      w, // 4 Point
      h - 130, // 4 Point
    ); // 4 Point
    path.lineTo(w, 0); // 5 Point
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
