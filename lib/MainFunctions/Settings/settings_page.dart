import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool LightMode = false;

  void buttonClick(bool value) {
    setState(() {
      LightMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),

      body: Column(
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
                  height: 140,
                ),
              ),

              Row(
                children: [
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
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(width: 20),

                        Text(
                          'Settings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          Container(
            height: MediaQuery.of(context).size.height * .8,
            padding: const EdgeInsets.only(
              left: 35,
              right: 35,
              top: 0,
              bottom: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile //////////////////////////////////////////////////////////////////////////////////////
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Edit Profile',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, size: 30),
                              SizedBox(width: 25),
                              Text(
                                'Profile',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),

                          Icon(Icons.arrow_forward_ios_rounded, size: 20),
                        ],
                      ),
                    ),

                    // Security //////////////////////////////////////////////////////////////////////////////////////
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 20),
                      child: Text(
                        'Security',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    // Change Pin
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.password_rounded, size: 30),
                              SizedBox(width: 25),
                              Text(
                                'Change Pin',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),

                          Icon(Icons.arrow_forward_ios_rounded, size: 20),
                        ],
                      ),
                    ),

                    // Account Recovery
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cloud_outlined, size: 30),
                              SizedBox(width: 25),
                              Text(
                                'Account Recovery',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Text(
                                'Set Now',
                                style: TextStyle(
                                  color: Color(0xFF00822B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_ios_rounded, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Display //////////////////////////////////////////////////////////////////////////////////////
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, top: 20),
                      child: Text(
                        'Display',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dark_mode, size: 30),
                              SizedBox(width: 25),
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),

                          Switch(
                            value: LightMode,
                            onChanged: (value) => buttonClick(value),
                            activeColor: Colors.white,
                            inactiveTrackColor: Colors.grey,
                            thumbColor: MaterialStateProperty.all(
                              LightMode
                                  ? Colors.black.withOpacity(0.75)
                                  : Colors.black.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    // Logout
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(
                                255,
                                16,
                                98,
                                49,
                              ).withOpacity(0.8),
                              offset: Offset(0, 4), // x, y offset
                              blurRadius: 2,
                              spreadRadius: 0,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Match button shape
                        ),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.zero,
                            ),
                            foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.white,
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF2ECC71),
                            ),
                            shape:
                                MaterialStateProperty.all<
                                  RoundedRectangleBorder
                                >(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                          ),
                          child: Text(
                            'Log Out',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    Image(
                      image: AssetImage('assets/vinno_black.png'),
                      width: 165,
                    ),

                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //         context,
                        //         MaterialPageRoute(builder: (context) => BracketOptionPage()),
                        //       );
                      },
                      child: Text(
                        'Terms and Condition',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
