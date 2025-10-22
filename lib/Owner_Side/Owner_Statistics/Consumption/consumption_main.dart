import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_day.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_month.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_week.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_year.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/statistics_menu.dart';
import 'package:smart_cb_1/services/statistics_service.dart';

class ConsumptionMain extends StatefulWidget {
  const ConsumptionMain({super.key});

  @override
  State<ConsumptionMain> createState() => _ConsumptionMainState();
}

class _ConsumptionMainState extends State<ConsumptionMain> {
  final StatisticsService _statisticsService = StatisticsService();
  Map<String, Map<String, double>> breakerData = {};
  Map<String, Map<String, double>> dayData = {};
  Map<String, Map<String, double>> weekData = {};
  Map<String, Map<String, double>> monthData = {};
  Map<String, Map<String, double>> yearData = {};
  List<Map<String, dynamic>> circuitBreakers = [];
  String selectedBreaker = 'All Breakers';
  bool isLoading = true;
  Map<String, double> currentReadings = {};
  Map<String, double> highestReadings = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch circuit breakers
      _statisticsService.getCircuitBreakers().listen((breakers) {
        setState(() {
          circuitBreakers = breakers;
          _initializeBreakerData();
        });
      });

      // Fetch current readings
      _statisticsService.getCurrentReadings().listen((readings) {
        setState(() {
          currentReadings = readings;
        });
      });

      // Fetch highest readings
      final highest = await _statisticsService.getHighestReadings();
      setState(() {
        highestReadings = highest;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeBreakerData() {
    // Initialize with "All Breakers" option
    breakerData['All Breakers'] = {};

    // Add individual circuit breakers
    for (var breaker in circuitBreakers) {
      breakerData[breaker['scbName']] = {};
    }

    // Fetch data for each breaker for all periods
    _fetchBreakerData('All Breakers', 'day');
    _fetchBreakerData('All Breakers', 'week');
    _fetchBreakerData('All Breakers', 'month');
    _fetchBreakerData('All Breakers', 'year');

    for (var breaker in circuitBreakers) {
      _fetchBreakerData(breaker['scbName'], 'day');
      _fetchBreakerData(breaker['scbName'], 'week');
      _fetchBreakerData(breaker['scbName'], 'month');
      _fetchBreakerData(breaker['scbName'], 'year');
    }
  }

  Future<void> _fetchBreakerData(String breakerName, String period) async {
    try {
      Map<String, dynamic> data;
      if (breakerName == 'All Breakers') {
        data = await _statisticsService.getAggregatedData(period);
      } else {
        final breaker = circuitBreakers.firstWhere(
          (b) => b['scbName'] == breakerName,
          orElse: () => {'scbId': ''},
        );
        data = await _statisticsService.getHistoricalData(
            breaker['scbId'], period);
      }

      final processedData = <String, double>{};
      data.forEach((key, value) {
        processedData[key] = value.toDouble();
      });

      setState(() {
        switch (period) {
          case 'day':
            dayData[breakerName] = processedData;
            break;
          case 'week':
            weekData[breakerName] = processedData;
            break;
          case 'month':
            monthData[breakerName] = processedData;
            break;
          case 'year':
            yearData[breakerName] = processedData;
            break;
        }
      });
    } catch (e) {
      print('Error fetching breaker data: $e');
    }
  }

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
                            isLoading || breakerData.isEmpty
                                ? Container(
                                    width: 200,
                                    height: 30,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : DropdownButtonHideUnderline(
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
                                      selectedItemBuilder:
                                          (BuildContext context) {
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
                                        setState(
                                            () => selectedBreaker = value!);
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
                      ConsumptionDay(dailyData: dayData[selectedBreaker] ?? {}),
                      ConsumptionWeek(
                        weeklyData: weekData[selectedBreaker] ?? {},
                      ),
                      ConsumptionMonth(
                          monthlyData: monthData[selectedBreaker] ?? {}),
                      ConsumptionYear(
                          yearlyData: yearData[selectedBreaker] ?? {}),
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
                                  isLoading
                                      ? CircularProgressIndicator(
                                          color: Color(0xFF2ECC71),
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          currentReadings['energy']
                                                  ?.toStringAsFixed(1) ??
                                              '0.0',
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
                                  isLoading
                                      ? CircularProgressIndicator(
                                          color: Color(0xFF2ECC71),
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          highestReadings['energy']
                                                  ?.toStringAsFixed(1) ??
                                              '0.0',
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
