import 'package:flutter/material.dart';
import '../models/diagnosis.dart';

class DiagnosisResultWidget extends StatelessWidget {
  final Diagnosis diagnosis;
  final VoidCallback onChatPressed;

  const DiagnosisResultWidget({
    super.key,
    required this.diagnosis,
    required this.onChatPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHealthy = diagnosis.issue.toLowerCase().contains('healthy');
    final Color statusColor = isHealthy ? Colors.green : Colors.orange;

    return Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Diagnosis Result",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${diagnosis.confidence}% Confident",
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Text(
                  "${diagnosis.crop} - ${diagnosis.issue}",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: statusColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Severity: ${diagnosis.severity}",
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                const Text("Recommendations:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...diagnosis.actions.map((action) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 20, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(action,
                                  style: const TextStyle(fontSize: 15))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onChatPressed,
          icon: const Icon(Icons.chat),
          label: const Text("Ask AgriAgent about this"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        )
      ],
    );
  }
}
