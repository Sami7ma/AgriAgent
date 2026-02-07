
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Open-Meteo is free and requires no API key.
  static const String _baseUrl = "https://api.open-meteo.com/v1/forecast";

  Future<Map<String, dynamic>> fetchCurrentWeather(double lat, double lon) async {
    try {
      final url = Uri.parse(
          "$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m");
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        
        return {
          "temp": current['temperature_2m'],
          "humidity": current['relative_humidity_2m'],
          "wind": current['wind_speed_10m'],
          "condition": _decodeWeatherCode(current['weather_code']),
        };
      } else {
        throw Exception("Failed to load weather data");
      }
    } catch (e) {
      print("Weather Fetch Error: $e");
      // Fallback
      return {
        "temp": 25.0,
        "humidity": 60,
        "wind": 5.0,
        "condition": "Sunny (Unavailable)",
      };
    }
  }

  String _decodeWeatherCode(int code) {
    if (code == 0) return "Clear Sky";
    if (code >= 1 && code <= 3) return "Partly Cloudy";
    if (code >= 45 && code <= 48) return "Foggy";
    if (code >= 51 && code <= 67) return "Rainy";
    if (code >= 71 && code <= 77) return "Snowy";
    if (code >= 80 && code <= 82) return "Showers";
    if (code >= 95) return "Thunderstorm";
    return "Unknown";
  }
}
