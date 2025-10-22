import 'package:flutter/material.dart';
import 'package:smart_cb_1/Owner_Side/Owner_LandingPage/circuit_breaker_list.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Navigation/navigation_page.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Consumption/consumption_main.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Current/current_main.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Power/power_main.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Temperature/temperature_main.dart';
import 'package:smart_cb_1/Owner_Side/Owner_Statistics/Voltage/voltage_main.dart';
import 'package:smart_cb_1/services/statistics_service.dart';

class StatisticsMenu extends StatefulWidget {
  const StatisticsMenu({super.key});

  @override
  State<StatisticsMenu> createState() => _StatisticsMenuState();
}

class _StatisticsMenuState extends State<StatisticsMenu> {
  final StatisticsService _statisticsService = StatisticsService();
  Map<String, double> currentReadings = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentReadings();
  }

  void _fetchCurrentReadings() {
    _statisticsService.getCurrentReadings().listen((readings) {
      setState(() {
        currentReadings = readings;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CircuitBreakerList(),
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
                        padding: const EdgeInsets.only(
                          left: 30,
                          top: 50,
                          right: 30,
                          bottom: 30,
                        ),
                        child: Center(
                          child: Text(
                            'Statistics',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        // Consumption
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F9F9),
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Consumption',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  isLoading
                                      ? CircularProgressIndicator(
                                          color: Color(0xFF2ECC71),
                                          strokeWidth: 2,
                                        )
                                      : Text(
                                          '${currentReadings['energy']?.toStringAsFixed(1) ?? '0.0'}kWh',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 38,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    child: Text(
                                      'Shows total energy used in kWh.',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                        EdgeInsets.zero,
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Colors.white,
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        Color(0xFF2ECC71),
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                      ),
                                      child: Text(
                                        'View',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ConsumptionMain(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Voltage
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9),
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
                              child: Container(
                                height: 150,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Voltage',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.power,
                                              size: 30,
                                              color: Color(0xFFFA600C),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Monitor your home’s voltage level.',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.zero),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(0xFF2ECC71),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                        ),
                                        child: Text(
                                          'View',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VoltageMain(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Current
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9),
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
                              child: Container(
                                height: 150,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Current',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.flash_on,
                                              size: 30,
                                              color: Color(0xFFFFAC33),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Check total current usage (A).',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.zero),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(0xFF2ECC71),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                        ),
                                        child: Text(
                                          'View',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CurrentMain(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Voltage
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9),
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
                              child: Container(
                                height: 150,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Power',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.battery_charging_full,
                                              size: 30,
                                              color: Color(0xFF20A8FF),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'View total power consumption.',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.zero),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(0xFF2ECC71),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                        ),
                                        child: Text(
                                          'View',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PowerMain(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Current
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFFF9F9F9),
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
                              child: Container(
                                height: 150,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Temp',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              Icons.device_thermostat,
                                              size: 30,
                                              color: Color(0xFFF16056),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Track temperature (°C ).',
                                          textAlign: TextAlign.justify,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                        padding: MaterialStateProperty.all<
                                            EdgeInsets>(EdgeInsets.zero),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors.white,
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Color(0xFF2ECC71),
                                        ),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                        ),
                                        child: Text(
                                          'View',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TemperatureMain(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
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

              // NAVIGATION ---------------------------------------------------------------------------------------------
              NavigationPage(),
            ],
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
