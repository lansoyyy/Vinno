import 'package:flutter/material.dart';
import 'package:smart_cb_1/MainFunctions/Navigation/navigation_page.dart';
import 'package:smart_cb_1/MainFunctions/Thresholds/overcurrent_option.dart';
import 'package:smart_cb_1/MainFunctions/Thresholds/overpower_option.dart';
import 'package:smart_cb_1/MainFunctions/Thresholds/overvoltage_option.dart';
import 'package:smart_cb_1/MainFunctions/Thresholds/temperature_option.dart';
import 'package:smart_cb_1/MainFunctions/Thresholds/undervoltage_option.dart';

class VoltageSettingsPage extends StatefulWidget {
  const VoltageSettingsPage({super.key});

  @override
  State<VoltageSettingsPage> createState() => _VoltageSettingsPageState();
}

class _VoltageSettingsPageState extends State<VoltageSettingsPage> {
  bool isExpanded = false;
  bool isChosen = false;

  void ExpandTile(bool expanded) {
    setState(() {
      isExpanded = expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      extendBodyBehindAppBar: true,

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/bracketoption');
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Voltage Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Bracket 1',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),

              // THRESHOLDS
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      OvervoltageSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                      ),

                      UndervoltageSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                      ),

                      OvercurrentSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                      ),

                      OverpowerSetting(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                      ),

                      TemperatureOption(
                        onPress: ExpandTile,
                        divider: buildDivider(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 60),

              // THRESHOLDS
            ],
          ),

          // NAVIGATION
          NavigationPage(),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0, bottom: 5.0),
      child: Divider(color: Color(0xFF2ECC71).withOpacity(0.5), thickness: 3.0),
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
