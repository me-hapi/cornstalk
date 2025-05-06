import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  Map<String, int> diseaseCountByMonth = {};
  double totalDiseases = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  Stream<List<Map<String, dynamic>>> _fetchDiseasesData() {
    final uid = Supabase.instance.client.auth.currentUser!.id;

    return Supabase.instance.client.from('Disease').stream(primaryKey: ['id']);
  }

  // Calculate distance between two coordinates
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Earth's radius in km
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLng = (lng2 - lng1) * (pi / 180);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            (sin(dLng / 2) * sin(dLng / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FF90), // Light yellow background
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchDiseasesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching data: ${snapshot.error}',
                    style: const TextStyle(color: Color(0xFF055212))));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No data found.',
                    style: TextStyle(color: Color(0xFF055212))));
          }

          // Extract disease data and count diseases by month
          List<Map<String, dynamic>> diseasesData = snapshot.data!;
          Map<String, int> diseaseCountByMonth = {};
          DateTime sixMonthsAgo =
              DateTime.now().subtract(const Duration(days: 180));

          for (var disease in diseasesData) {
            // Ensure that all necessary fields are not null
            if (disease['classification'] != null &&
                disease['scanned_at'] != null) {
              DateTime scannedAt = DateTime.parse(disease['scanned_at']);
              if (scannedAt.isAfter(sixMonthsAgo)) {
                String month = "${scannedAt.month}-${scannedAt.year}";
                if (diseaseCountByMonth.containsKey(month)) {
                  diseaseCountByMonth[month] = diseaseCountByMonth[month]! + 1;
                } else {
                  diseaseCountByMonth[month] = 1;
                }
              }
            }
          }

          double totalDiseases = diseasesData.length.toDouble();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Disease Distribution (Within 100km)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF055212), // Dark green
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: showingSections(diseasesData, totalDiseases),
                      centerSpaceColor:
                          const Color(0xFFF3FF90), // Light yellow background
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -90,
                      pieTouchData:
                          PieTouchData(touchCallback: (event, response) {
                        if (response != null &&
                            response.touchedSection != null) {
                          setState(() {
                            // Handle touch event
                          });
                        }
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Disease Trends (Past 6 Months)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF055212), // Dark green
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      MockLineChart(diseaseCountByMonth: diseaseCountByMonth),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      List<Map<String, dynamic>> diseasesData, double totalDiseases) {
    final Map<String, double> classificationPercentage = {};
    for (var disease in diseasesData) {
      String classification = disease['classification'] ?? 'Unknown';
      if (classificationPercentage.containsKey(classification)) {
        classificationPercentage[classification] =
            classificationPercentage[classification]! + 1;
      } else {
        classificationPercentage[classification] = 1;
      }
    }

    return classificationPercentage.entries.map((entry) {
      double percentage = (entry.value / totalDiseases) * 100;
      return PieChartSectionData(
        value: percentage,
        title: '${entry.key}: ${percentage.toStringAsFixed(1)}%',
        color: Colors.green, // Green for sections
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white, // White text color
          fontFamily: 'Montserrat',
        ),
        radius: 80,
      );
    }).toList();
  }
}

class MockLineChart extends StatelessWidget {
  final Map<String, int> diseaseCountByMonth;

  const MockLineChart({required this.diseaseCountByMonth});

  @override
  Widget build(BuildContext context) {
    List<String> monthLabels = diseaseCountByMonth.keys.toList();
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 5,
            isStrokeCapRound: true,
            color: const Color(0xFF055212), // Dark green line color
            dotData: FlDotData(
              show: true,
              getDotPainter: (FlSpot spot, double xPercentage,
                  LineChartBarData bar, int index) {
                return FlDotCirclePainter(
                  radius: 6, // Adjust the dot size as needed
                  color: const Color(0xFF055212), // Dark green color for the dots
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),

            belowBarData: BarAreaData(
                show: true, color: const Color(0xFF055212).withOpacity(0.3)),
            spots: List.generate(monthLabels.length, (index) {
              return FlSpot(
                index.toDouble(), // X-axis: index of the month
                diseaseCountByMonth[monthLabels[index]]!
                    .toDouble(), // Y-axis: Count of diseases
              );
            }),
          ),
        ],
        minX: 0,
        maxX: diseaseCountByMonth.length.toDouble() - 1,
        minY: 0,
        gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey[300]!, strokeWidth: 1)),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, // Keep labels on the left side
              reservedSize: 32,
              interval: 1, // Interval for y-axis
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Color(0xFF055212), // Dark green text color for y-axis
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false, // Removed labels on the right side
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false, // Removed labels on the top side
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= monthLabels.length)
                  return const SizedBox.shrink();
                return Text(
                  monthLabels[index], // Display month-year as X-axis labels
                  style: const TextStyle(
                    color: Color(0xFF055212), // Dark green text color for x-axis
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                );
              },
              reservedSize: 32,
            ),
          ),
        ),
      ),
    );
  }
}
