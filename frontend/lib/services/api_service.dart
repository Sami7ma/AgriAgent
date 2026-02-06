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
      return null;
    }
  }

  /// Sends a chat query to the agent
  Future<String> sendChatQuery(String query, String diagnosisContext) async {
    try {
      Response response = await _dio.post(
        "/agent/query",
        data: {
          "query": query,
          "context_data": {"diagnosis_context": diagnosisContext}
        },
      );
      return response.data['response_text'] ?? "No response received.";
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }
}
