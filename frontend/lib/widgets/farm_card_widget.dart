import 'package:flutter/material.dart';
import '../models/farm_card.dart';

class FarmCardWidget extends StatelessWidget {
  final FarmCard? data;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;

  const FarmCardWidget({
    super.key,
    this.data,
    this.isLoading = false,
    this.error,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text("Daily Application",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else if (error != null)
              GestureDetector(
                onTap: onRefresh,
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              )
            else if (data == null)
              GestureDetector(
                onTap: onRefresh,
                child: const Text("Tap to load daily insights",
                    style: TextStyle(color: Colors.grey)),
              )
            else
              _buildContent(context, data!),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FarmCard card) {
    return Column(
      children: [
        _buildInfoRow(Icons.location_on, "${card.location} • ${card.date}"),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.wb_sunny, card.weatherSummary),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.attach_money, card.marketTrend),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Recommendation: ${card.topAction}",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey.shade800))),
      ],
    );
  }
}
