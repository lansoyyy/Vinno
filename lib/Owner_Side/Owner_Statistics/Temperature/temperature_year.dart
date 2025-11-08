import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemperatureYear extends StatelessWidget {
  final Map<String, double> yearlyData; // 🔹 Data passed from parent

  const TemperatureYear({super.key, required this.yearlyData});

  @override
  Widget build(BuildContext context) {
    final barGroups = <BarChartGroupData>[];
    int index = 0;

    // Use all data instead of limiting
    final limitedData = yearlyData;

    final values = yearlyData.values.toList();
    final double minY = values.reduce((a, b) => a < b ? a : b);
    final double maxY = values.reduce((a, b) => a > b ? a : b);
    double adjustedMinY = (minY - 10).clamp(0, double.infinity).floorToDouble();
    ; // 5 units padding below
    double adjustedMaxY = (maxY * 1.25).ceil().toDouble();
    ; // 5 units padding above

    if (adjustedMinY == adjustedMaxY) adjustedMaxY = adjustedMinY + 10;

    // 🔁 Convert map entries into bar groups
    yearlyData.forEach((day, value) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              color: Color(0xff2ECC71),
              width: 30,
              borderRadius: BorderRadius.circular(30),
            ),
          ],
        ),
      );
      index++;
    });

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          child: const Text(
            'Temperature (°C )',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF176639),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.only(top: 100, bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF000000).withOpacity(0.25),
                offset: Offset(0, 4), // x, y offset
                blurRadius: 2,
                spreadRadius: 0,
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: adjustedMaxY,
              minY: adjustedMinY, // You can compute max dynamically too
              barTouchData: BarTouchData(enabled: true),
              gridData: FlGridData(
                drawHorizontalLine: true, // 🚫 hide horizontal lines
                drawVerticalLine: false, // ✅ keep vertical lines
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final day = limitedData.keys.elementAt(value.toInt());
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: SizedBox(
                          width: 40,
                          child: Text(
                            day,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }
}
