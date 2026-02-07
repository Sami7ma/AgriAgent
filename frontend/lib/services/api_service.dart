import 'dart:io';
import 'package:dio/dio.dart';
import '../models/diagnosis.dart';
import '../models/farm_card.dart';
import '../utils/constants.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Optional: Add interceptors or default configs here
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  /// Uploads an image for crop diagnosis
  Future<Diagnosis> analyzeCrop(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      Response response = await _dio.post(
        "/analyze/diagnose",
        data: formData,
      );

      return Diagnosis.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to analyze crop: $e");
    }
  }

  /// Fetches the Daily Farm Card
  Future<FarmCard?> getDailyCard({double? lat, double? lon}) async {
    try {
      String url = "/artifacts/daily-card";
      if (lat != null && lon != null) {
        url += "?lat=$lat&lon=$lon";
      }

      Response response = await _dio.get(url);
      return FarmCard.fromJson(response.data);
    } catch (e) {
      print("Error fetching daily card: $e");
      throw Exception("Failed to load: $e");
    }
  }

  Future<String> sendChatQuery(String query, String diagnosisContext, {List<dynamic>? history, FarmCard? location, double? lat, double? lon}) async {
    try {
      // Format history for backend
      List<Map<String, String>> formattedHistory = [];
      if (history != null) {
        for (var msg in history) {
            formattedHistory.add({
                "role": msg.role,
                "text": msg.text
            });
        }
      }

      // Format location context
      Map<String, dynamic>? locationContext;
      if (location != null) {
          // Heuristic to split "City, Country"
          final parts = location.location.split(',');
          String city = parts.isNotEmpty ? parts[0].trim() : "Unknown";
          String country = parts.length > 1 ? parts.last.trim() : "";
          
          locationContext = {
              "city": city,
              "country": country,
              "lat": lat,
              "lon": lon
          };
      }

      Response response = await _dio.post(
        "/agent/query",
        data: {
          "query": query,
          "context_data": {"diagnosis_context": diagnosisContext},
          "chat_history": formattedHistory,
          "location_context": locationContext
        },
      );
      return response.data['response_text'] ?? "No response received.";
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }
}
