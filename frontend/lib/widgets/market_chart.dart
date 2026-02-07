import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MarketChartWidget extends StatelessWidget {
  final String cropName;

  const MarketChartWidget({super.key, this.cropName = "Maize"});

  @override
  Widget build(BuildContext context) {
    // Generate Mock Data based on crop
    final List<FlSpot> spots = _getSpotsForCrop(cropName);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$cropName Price Trends",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30, // Space for labels
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          if (value.toInt() >= 0 && value.toInt() < months.length) {
                             return Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: Text(months[value.toInt()], style: const TextStyle(fontSize: 10)),
                             );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: const Color(0xFF2E7D32),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                      ),
                    ),
                  ],
                  // Dynamic Min/Max based on spots
                  minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 10,
                  maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpotsForCrop(String crop) {
      // Mock Data Generators
      switch (crop) {
          case "Wheat":
             return const [
                 FlSpot(0, 4500), FlSpot(1, 4600), FlSpot(2, 4550), FlSpot(3, 4700), FlSpot(4, 4800), FlSpot(5, 4900)
             ];
          case "Coffee":
             return const [
                 FlSpot(0, 12000), FlSpot(1, 12500), FlSpot(2, 11800), FlSpot(3, 13000), FlSpot(4, 13500), FlSpot(5, 14000)
             ];
          case "Teff":
             return const [
                 FlSpot(0, 8000), FlSpot(1, 8200), FlSpot(2, 8500), FlSpot(3, 8400), FlSpot(4, 8700), FlSpot(5, 9000)
             ];
          case "Maize":
          default:
             return const [
                FlSpot(0, 450), FlSpot(1, 470), FlSpot(2, 460), FlSpot(3, 480), FlSpot(4, 500), FlSpot(5, 520),
             ];
      }
  }
}
