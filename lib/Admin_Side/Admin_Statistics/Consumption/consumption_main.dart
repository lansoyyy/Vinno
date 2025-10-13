import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_day.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_month.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_week.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_year.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/statistics_menu.dart';

class ConsumptionMain extends StatefulWidget {
  const ConsumptionMain({super.key});

  @override
  State<ConsumptionMain> createState() => _ConsumptionMainState();
}

class _ConsumptionMainState extends State<ConsumptionMain> {
  // for line graph
  final List<double> sampleValues = [
    12.5,
    15.0,
    18.2,
    20.0,
    22.5,
    19.0,
    17.5,
    21.0,
    23.3,
    24.0,
    18.5,
    16.0,
    19.5,
    21.2,
    22.8,
    20.5,
    18.0,
    17.3,
    19.0,
    20.7,
  ];

  final Map<String, Map<String, double>> breakerData = {
    'All Breakers': {
      'Mon': 20.3,
      'Tue': 22,
      'Wed': 53,
      'Thu': 5.34,
      'Fri': 55,
      'Sat': 45,
      'Sun': 45,
    },

    'Circuit Breaker in the Kitchen': {
      'Mon': 6,
      'Tue': 8,
      'Wed': 5,
      'Thu': 7,
      'Fri': 9,
      'Sat': 9,
      'Sun': 6,
    },
    'Breaker 2': {
      'Mon': 4,
      'Tue': 5,
      'Wed': 7,
      'Thu': 6,
      'Fri': 8,
      'Sat': 7,
      'Sun': 5,
    },
    'Breaker 3': {
      'Mon': 9,
      'Tue': 8,
      'Wed': 8,
      'Thu': 9,
      'Fri': 7,
      'Sat': 8,
      'Sun': 9,
    },
    'Living Room Breaker': {
      'Mon': 7.2,
      'Tue': 8.1,
      'Wed': 6.5,
      'Thu': 7.9,
      'Fri': 8.3,
      'Sat': 9.0,
      'Sun': 7.8,
    },

    'Bedroom Breaker': {
      'Mon': 5.5,
      'Tue': 5.7,
      'Wed': 5.9,
      'Thu': 6.0,
      'Fri': 6.1,
      'Sat': 6.2,
      'Sun': 5.8,
    },

    'Air Conditioner Breaker': {
      'Mon': 10.5,
      'Tue': 11.2,
      'Wed': 9.8,
      'Thu': 12.0,
      'Fri': 11.5,
      'Sat': 13.4,
      'Sun': 12.8,
    },

    'Washer & Dryer Breaker': {
      'Mon': 8.0,
      'Tue': 7.4,
      'Wed': 8.2,
      'Thu': 8.9,
      'Fri': 9.1,
      'Sat': 9.3,
      'Sun': 8.7,
    },

    'Garage Breaker': {
      'Mon': 3.2,
      'Tue': 3.8,
      'Wed': 4.0,
      'Thu': 3.5,
      'Fri': 3.7,
      'Sat': 4.2,
      'Sun': 4.1,
    },

    'Outdoor Lights Breaker': {
      'Mon': 2.0,
      'Tue': 2.2,
      'Wed': 2.1,
      'Thu': 2.3,
      'Fri': 2.0,
      'Sat': 2.4,
      'Sun': 2.2,
    },
  };

  String selectedBreaker = 'All Breakers';
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,

            color: Color(0xFFF6F6F6),
            child: Column(
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
                        height: 170,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50, bottom: 30),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StatisticsMenu(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 50, bottom: 30),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Consumption',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),

                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedBreaker,
                                dropdownColor: Colors.white,
                                alignment: Alignment.center,
                                iconEnabledColor: Colors.white,
                                // Style applies to selected value fallback only
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                items: breakerData.keys.map((breaker) {
                                  return DropdownMenuItem<String>(
                                    value: breaker,
                                    child: Center(
                                      child: Text(
                                        breaker,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ), // dropdown items
                                      ),
                                    ),
                                  );
                                }).toList(),

                                // This builder customizes the selected item display separately
                                selectedItemBuilder: (BuildContext context) {
                                  return breakerData.keys.map((breaker) {
                                    return Center(
                                      child: Text(
                                        breaker,
                                        style: const TextStyle(
                                          color: Colors
                                              .white, // selected value text color
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList();
                                },

                                onChanged: (value) {
                                  setState(() => selectedBreaker = value!);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: TabBar(
                    labelColor: Colors.green,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelColor: Colors.grey,

                    indicatorColor: Colors.green,
                    tabs: [
                      Tab(text: 'DAY'),
                      Tab(text: 'WEEK'),
                      Tab(text: 'MONTH'),
                      Tab(text: 'YEAR'),
                    ],
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: TabBarView(
                    children: [
                      ConsumptionDay(dailyData: breakerData[selectedBreaker]!),
                      ConsumptionWeek(
                        weeklyData: breakerData[selectedBreaker]!,
                      ),
                      ConsumptionMonth(
                        monthlyData: breakerData[selectedBreaker]!,
                      ),
                      ConsumptionYear(
                        yearlyData: breakerData[selectedBreaker]!,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF000000).withOpacity(0.25),
                          offset: Offset(-4, 4), // x, y offset
                          blurRadius: 2,
                          spreadRadius: 0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: [
                        // cURRENT READING
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF000000).withOpacity(0.25),
                                offset: Offset(-4, 4), // x, y offset
                                blurRadius: 2,
                                spreadRadius: 0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.electric_meter,
                                    size: 37,
                                    color: Color(0xFF2ECC71),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Current Reading:',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '200',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    ' kwh',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // HIGHEST READING
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF000000).withOpacity(0.25),
                                offset: Offset(-4, 4), // x, y offset
                                blurRadius: 2,
                                spreadRadius: 0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    size: 37,
                                    color: Color(0xFF2ECC71),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Highest Reading:',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '999',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    ' kwh',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
