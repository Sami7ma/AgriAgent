class Diagnosis {
  final String crop;
  final String issue;
  final double confidence;
  final String severity;
  final List<String> actions;
  final String affectedArea;

  Diagnosis({
    required this.crop,
    required this.issue,
    required this.confidence,
    required this.severity,
    required this.actions,
    this.affectedArea = "",
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      crop: json['crop'] ?? 'Unknown',
      issue: json['issue'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0).toDouble(),
      severity: json['severity'] ?? 'Unknown',
      actions: List<String>.from(json['actions'] ?? []),
      affectedArea: json['affected_area'] ?? '',
    );
  }

  // Helper to check if healthy
  bool get isHealthy => issue.toLowerCase().contains('healthy');
}
