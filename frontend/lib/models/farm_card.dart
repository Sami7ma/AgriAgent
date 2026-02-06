class FarmCard {
  final String date;
  final String location;
  final String weatherSummary;
  final String weatherIcon;
  final String marketTrend;
  final String topAction;
  final int cropHealthScore;

  FarmCard({
    required this.date,
    required this.location,
    required this.weatherSummary,
    required this.weatherIcon,
    required this.marketTrend,
    required this.topAction,
    required this.cropHealthScore,
  });

  factory FarmCard.fromJson(Map<String, dynamic> json) {
    return FarmCard(
      date: json['date'] ?? '',
      location: json['location'] ?? 'Unknown',
      weatherSummary: json['weather_summary'] ?? '',
      weatherIcon: json['weather_icon'] ?? '',
      marketTrend: json['market_trend'] ?? '',
      topAction: json['top_action'] ?? '',
      cropHealthScore: json['crop_health_score'] ?? 0,
    );
  }
}
