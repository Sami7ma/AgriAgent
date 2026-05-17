import 'dart:io';
import 'package:dio/dio.dart';
import '../models/diagnosis.dart';
import '../models/farm_card.dart';
import '../utils/constants.dart';

/// Main API service for backend communication
/// Includes error handling and retry logic
class ApiService {
  final Dio _dio = Dio();
  static const maxRetries = 3;

  ApiService() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: AppConstants.connectionTimeoutMs);
    _dio.options.receiveTimeout = Duration(milliseconds: AppConstants.receiveTimeoutMs);
    
    // Add error interceptor for consistent error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        // Log errors only in debug mode
        if (AppConstants.enableDebugMode) {
          print('API Error: ${e.type} - ${e.message}');
          if (e.response != null) {
            print('Response: ${e.response?.statusCode}');
          }
        }
        handler.next(e);
      },
    ));
  }

  /// Uploads an image for crop diagnosis with validation
  /// Returns Diagnosis object with crop, issue, and recommendations
  Future<Diagnosis> analyzeCrop(File imageFile) async {
    try {
      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception("File does not exist");
      }

      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      Response response = await _dio.post(
        "/analyze/diagnose",
        data: formData,
      );

      return Diagnosis.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to analyze crop");
    } catch (e) {
      throw Exception("Failed to analyze crop: $e");
    }
  }

  /// Fetches the Daily Farm Card with weather and insights
  /// Uses location coordinates for personalized data
  Future<FarmCard?> getDailyCard({double? lat, double? lon}) async {
    try {
      String url = "/artifacts/daily-card";
      if (lat != null && lon != null) {
        url += "?lat=$lat&lon=$lon";
      }

      Response response = await _dio.get(url);
      return FarmCard.fromJson(response.data);
    } on DioException catch (e) {
      // Log but don't throw for optional data
      if (AppConstants.enableDebugMode) {
        print("Error fetching daily card: ${e.message}");
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sends a chat query to the AI agent with retry logic
  /// Includes conversation history and location context for better responses
  Future<String> sendChatQuery(
    String query, 
    String diagnosisContext, {
    List<dynamic>? history, 
    FarmCard? location, 
    double? lat, 
    double? lon
  }) async {
    try {
      // Validate query length
      if (query.length > AppConstants.maxQueryLength) {
        query = query.substring(0, AppConstants.maxQueryLength);
      }
      
      // Format history for backend
      List<Map<String, String>> formattedHistory = [];
      if (history != null) {
        // Limit history to prevent payload bloat
        final recentHistory = history.length > AppConstants.maxChatHistoryDisplay 
            ? history.sublist(history.length - AppConstants.maxChatHistoryDisplay) 
            : history;
            
        for (var msg in recentHistory) {
          formattedHistory.add({
            "role": msg.role,
            "text": msg.text
          });
        }
      }

      // Format location context
      Map<String, dynamic>? locationContext;
      if (location != null) {
        // Parse "City, Country" format
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
      
    } on DioException catch (e) {
      throw _handleDioError(e, "Failed to send message");
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }
  
  /// Converts Dio errors to user-friendly messages
  Exception _handleDioError(DioException e, String context) {
    String message;
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "Connection timed out. Please check your internet and try again.";
        break;
      case DioExceptionType.connectionError:
        message = "Could not connect to server. Tap to retry.";
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) {
          message = "Too many requests. Please wait a moment.";
        } else if (statusCode == 500) {
          message = "Server error. Please try again later.";
        } else if (statusCode == 401 || statusCode == 403) {
          message = "Authentication failed. Please check your configuration.";
        } else {
          message = "Server returned error: $statusCode";
        }
        break;
      default:
        message = "$context: ${e.message}";
    }
    
    return Exception(message);
  }
}
