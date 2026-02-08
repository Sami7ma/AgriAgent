
import 'package:flutter/material.dart';
import '../models/farm_card.dart';

class FarmCardWidget extends StatelessWidget {
  final FarmCard? data;
  final Map<String, dynamic>? weatherData; // NEW: Real weather data
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  const FarmCardWidget({
    super.key,
    this.data,
    this.weatherData,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text("Daily Insights", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              if (isLoading) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ],
          ),
          // NEW: Location row
          if (data?.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  data!.location,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          
          if (error != null)
             Text("Error: $error", style: TextStyle(color: Colors.red.shade100))
          else 
             _buildWeatherRow(),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
               children: [
                 const Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 24),
                 const SizedBox(width: 12),
                 Expanded(
                    child: Text(
                      // Show a clear fallback when there's no card data
                      (data != null && (data!.topAction).isNotEmpty)
                          ? data!.topAction
                          : (isLoading ? "Loading recommendation..." : "No recommendation available. Pull to refresh."),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                 )
               ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWeatherRow() {
    // Use Real Weather if available, else Mock/Backend
    final double temp = weatherData?['temp'] ?? 24.0;
    final String condition = weatherData?['condition'] ?? data?.weatherSummary ?? "Calm";
    final int humidity = weatherData?['humidity'] ?? 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text("${temp.toStringAsFixed(1)}°C", style: const TextStyle(fontSize: 42, color: Colors.white, fontWeight: FontWeight.bold)),
                Text(condition, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
        ),
        Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                _buildMetDetail(Icons.water_drop, "$humidity%", "Humidity"),
                const SizedBox(height: 8),
                _buildMetDetail(Icons.air, "${weatherData?['wind'] ?? 5} km/h", "Wind"),
            ],
        )
      ],
    );
  }

  Widget _buildMetDetail(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}
