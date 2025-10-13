import 'package:flutter/material.dart';

class NavHome extends StatefulWidget {
  const NavHome({super.key});

  @override
  State<NavHome> createState() => _NavHomeState();
}

class _NavHomeState extends State<NavHome> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 65,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25), // Shadow color
                    offset: Offset(0, 0), // Shadow position
                    blurRadius: 20, // Blur effect
                    spreadRadius: 5, // Spread effect
                  ),
                ],
              ),

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HOME ----------------------------------------------------------------
                    ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.zero,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Color(0xFF646464),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        elevation: MaterialStateProperty.all<double>(
                          0,
                        ), // Remove elevation
                        shadowColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 30),
                            SizedBox(width: 10),
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        // Navigator.pushNamed(context, '/cblist');
                      },
                    ),

                    // VerticalDivider(
                    //   color: Colors.grey,
                    //   thickness: 1,
                    //   width: 20, // space taken horizontally
                    // ),

                    // SETTINGS ----------------------------------------------------------------
                    ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.zero,
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Color(0xFF646464),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        elevation: MaterialStateProperty.all<double>(
                          0,
                        ), // Remove elevation
                        shadowColor: MaterialStateProperty.all<Color>(
                          Colors.transparent,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.manage_accounts_sharp, size: 30),
                            SizedBox(width: 10),
                            Text(
                              'Managers',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/connectedDevices');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/addnewcb');
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Icon(Icons.add, color: Colors.white, size: 30),
                decoration: BoxDecoration(
                  color: Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30), // Shadow color
                      offset: Offset(0, 6), // Shadow position
                      blurRadius: 5, // Blur effect
                      spreadRadius: 0, // Spread effect
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
