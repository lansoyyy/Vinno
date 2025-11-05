import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Voltage/voltage_day.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Voltage/voltage_month.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Voltage/voltage_realtime.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Voltage/voltage_week.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Voltage/voltage_year.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/statistics_menu.dart';
import 'package:smart_cb_1/services/statistics_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class VoltageMain extends StatefulWidget {
  const VoltageMain({super.key});

  @override
  State<VoltageMain> createState() => _VoltageMainState();
}

class _VoltageMainState extends State<VoltageMain> {
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
  int thresholdExceededCount = 0;
  List<double> realTimeValues = [];

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
          if (selectedBreaker.isEmpty && breakers.isNotEmpty) {
            selectedBreaker = breakers.first['scbName'];
          }
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
      });

      // Fetch threshold exceeded count
      final thresholdCount =
          await _statisticsService.getThresholdExceededCount();
      setState(() {
        thresholdExceededCount = thresholdCount;
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

    // Add individual circuit breakers
    for (var breaker in circuitBreakers) {
      breakerData[breaker['scbName']] = {};
      dayData[breaker['scbName']] = {};
      weekData[breaker['scbName']] = {};
      monthData[breaker['scbName']] = {};
      yearData[breaker['scbName']] = {};
    }

    // Fetch data for each breaker for all periods
    for (var breaker in circuitBreakers) {
      _fetchBreakerData(breaker['scbName'], 'day');
      _fetchBreakerData(breaker['scbName'], 'week');
      _fetchBreakerData(breaker['scbName'], 'month');
      _fetchBreakerData(breaker['scbName'], 'year');
    }
  }

  Future<void> _fetchBreakerData(String breakerName, String period) async {
    try {
      final breaker = circuitBreakers.firstWhere(
        (b) => b['scbName'] == breakerName,
        orElse: () => {'scbId': ''},
      );
      final data = await _statisticsService
          .getHistoricalData(breaker['scbId'], period, metric: 'voltage');

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
        // Also update the general breakerData for backward compatibility
        breakerData[breakerName] = processedData;
      });
    } catch (e) {
      print('Error fetching breaker data: $e');
    }
  }

  Future<void> _fetchRealTimeData() async {
    try {
      final breaker = circuitBreakers.firstWhere(
        (b) => b['scbName'] == selectedBreaker,
        orElse: () => {'scbId': ''},
      );

      // Use the service method which now reads from the new data structure
      final data =
          await _statisticsService.getRealTimeData(breaker['scbId'], 'voltage');
      setState(() {
        realTimeValues = data;
      });
    } catch (e) {
      print('Error fetching real-time data: $e');
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
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
                          Padding(
                            padding: const EdgeInsets.only(top: 50, bottom: 30),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Voltage',
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
                                            items:
                                                breakerData.keys.map((breaker) {
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
                                              return breakerData.keys
                                                  .map((breaker) {
                                                return Center(
                                                  child: Text(
                                                    breaker,
                                                    style: const TextStyle(
                                                      color: Colors
                                                          .white, // selected value text color
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              }).toList();
                                            },

                                            onChanged: (value) {
                                              setState(
                                                () => selectedBreaker = value!,
                                              );
                                            },
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 50, bottom: 30),
                            child: // When tapping the icon to show the graph:
                                GestureDetector(
                              onTap: () async {
                                await _fetchRealTimeData();
                                // Pass the realTimeValues list directly
                                showLineGraphDialog(
                                    context,
                                    realTimeValues.isNotEmpty
                                        ? realTimeValues
                                        : []);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.show_chart_rounded,
                                    color: Color(0xFF2ECC71),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      VoltageDay(dailyData: dayData[selectedBreaker] ?? {}),
                      VoltageWeek(weeklyData: weekData[selectedBreaker] ?? {}),
                      VoltageMonth(
                          monthlyData: monthData[selectedBreaker] ?? {}),
                      VoltageYear(yearlyData: yearData[selectedBreaker] ?? {}),
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
                                    Icons.thermostat,
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
                                          currentReadings['voltage']
                                                  ?.toStringAsFixed(1) ??
                                              '0.0',
                                          style: TextStyle(
                                            color: Color(0xFF555555),
                                            fontSize: 25,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                  Text(
                                    ' V',
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

                        // Threshold Exceeded
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
                                    Icons.warning_rounded,
                                    size: 37,
                                    color: Color(0xFFFF5A53),
                                  ),
                                  SizedBox(width: 15),
                                  Text(
                                    'Threshold Exceeded:',
                                    style: TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              isLoading
                                  ? CircularProgressIndicator(
                                      color: Color(0xFF2ECC71),
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      thresholdExceededCount.toString(),
                                      style: TextStyle(
                                        color: Color(0xFF555555),
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                      ),
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
                                          highestReadings['voltage']
                                                  ?.toStringAsFixed(1) ??
                                              '0.0',
                                          style: TextStyle(
                                            color: Color(0xFF555555),
                                            fontSize: 25,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                  Text(
                                    ' V',
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
