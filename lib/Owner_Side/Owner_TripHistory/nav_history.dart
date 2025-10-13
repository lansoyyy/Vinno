import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_TripHistory/trips.dart';
import 'package:smart_cb_1/Owner_Side/Owner_TripHistory/warnings.dart';

class NavHistory extends StatefulWidget {
  const NavHistory({super.key});

  @override
  State<NavHistory> createState() => _NavHistoryState();
}

class _NavHistoryState extends State<NavHistory> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // must match the number of tabs
      child: Scaffold(
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
                        height: 220,
                      ),
                    ),
                    Column(
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
                                  Navigator.pushNamed(
                                    context,
                                    '/bracketoption',
                                  );
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                              ),

                              SizedBox(width: 15),

                              Text(
                                'Trip History',
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
                        SizedBox(height: 5),
                        Text(
                          'Circuit Breaker #',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ✅ Fixed: TabBar inside DefaultTabController
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TabBar(
                    labelColor: Colors.green,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3.0,
                    indicatorColor: Colors.green,
                    tabs: [
                      Tab(text: 'Warnings'),
                      Tab(text: 'Trips'),
                    ],
                  ),
                ),

                Expanded(child: TabBarView(children: [Warnings(), Trips()])),
              ],
            ),

            // NAVIGATION ---------------------------------------------------------------------------------------------
            NavigationPage(),
          ],
        ),
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
    path.lineTo(0, h - 50);
    path.quadraticBezierTo(w * 0.5, h, w, h - 50);
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
