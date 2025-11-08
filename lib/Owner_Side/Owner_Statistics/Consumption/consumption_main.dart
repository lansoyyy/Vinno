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
  String selectedBreaker = '';
  bool isLoading = true;
  Map<String, double> currentReadings = {};
  Map<String, double> highestReadings = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Start periodic refresh every 10 seconds
    _statisticsService.startPeriodicRefresh(_refreshCurrentReadings);
  }

  @override
  void dispose() {
    _statisticsService.stopPeriodicRefresh();
    super.dispose();
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

  void _refreshCurrentReadings() {
    _statisticsService.getCurrentReadings().listen((readings) {
      if (mounted) {
        setState(() {
          currentReadings = readings;
        });
      }
    });
  }

  void _initializeBreakerData() {
    // Clear existing data
    breakerData.clear();
    dayData.clear();
    weekData.clear();
    monthData.clear();
    yearData.clear();

    // Find the main breaker (highest rating) for consumption
    if (circuitBreakers.isNotEmpty) {
      var mainBreaker = circuitBreakers.reduce((a, b) {
        final aRating = a['circuitBreakerRating'] ?? 0;
        final bRating = b['circuitBreakerRating'] ?? 0;
        return (aRating as int) > (bRating as int) ? a : b;
      });

      // Only add the main breaker for consumption (represents total consumption)
      final mainBreakerName = mainBreaker['scbName'];
      breakerData[mainBreakerName] = {};
      dayData[mainBreakerName] = {};
      weekData[mainBreakerName] = {};
      monthData[mainBreakerName] = {};
      yearData[mainBreakerName] = {};

      // Set selected breaker to main breaker
      selectedBreaker = mainBreakerName;

      // Fetch data for main breaker for all periods
      _fetchBreakerData(mainBreakerName, 'day');
      _fetchBreakerData(mainBreakerName, 'week');
      _fetchBreakerData(mainBreakerName, 'month');
      _fetchBreakerData(mainBreakerName, 'year');
    }
  }

  Future<void> _fetchBreakerData(String breakerName, String period) async {
    try {
      // For consumption, use main breaker data which represents total consumption
      final data = await _statisticsService.getConsumptionAggregatedData(period,
          metric: 'energy');

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
                              'Total Consumption',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Main Breaker',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
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
