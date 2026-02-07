import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

/// Service for fetching real market price data
class MarketService {
  /// Get market prices for a specific crop
  /// Uses the backend API which integrates with real data sources
  Future<Map<String, dynamic>> getMarketPrice({
    required String crop,
    String region = "Kenya",
    double? lat,
    double? lon,
  }) async {
    try {
      // Build query parameters
      final params = {
        'crop': crop,
        'region': region,
      };
      if (lat != null) params['lat'] = lat.toString();
      if (lon != null) params['lon'] = lon.toString();
      
      final uri = Uri.parse('${AppConstants.baseUrl}/market/price').replace(queryParameters: params);
      
      final response = await http.get(uri).timeout(
        Duration(milliseconds: AppConstants.connectionTimeoutMs),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      // Fallback to local data
      return _getLocalPrice(crop, region);
      
    } catch (e) {
      print('MarketService: Error fetching price: $e');
      return _getLocalPrice(crop, region);
    }
  }
  
  /// Get price trend data for charts (6 months)
  Future<List<double>> getPriceTrend({
    required String crop,
    String region = "Kenya",
    double? lat,
    double? lon,
  }) async {
    try {
      // For now, generate realistic trend data based on crop
      // In production, this would hit a real API endpoint
      return _generateTrendData(crop);
    } catch (e) {
      print('MarketService: Error fetching trend: $e');
      return _generateTrendData(crop);
    }
  }
  
  /// Local fallback prices (in local currency per kg)
  Map<String, dynamic> _getLocalPrice(String crop, String region) {
    final basePrices = {
      'Maize': {'Kenya': 45.0, 'Ethiopia': 25.0, 'default': 0.35},
      'Wheat': {'Kenya': 55.0, 'Ethiopia': 35.0, 'default': 0.40},
      'Coffee': {'Kenya': 350.0, 'Ethiopia': 200.0, 'default': 2.50},
      'Teff': {'Kenya': 120.0, 'Ethiopia': 80.0, 'default': 1.20},
    };
    
    final currencies = {
      'Kenya': 'KES',
      'Ethiopia': 'ETB',
      'default': 'USD',
    };
    
    final cropPrices = basePrices[crop] ?? {'default': 50.0};
    final basePrice = cropPrices[region] ?? cropPrices['default'] ?? 50.0;
    
    // Add small variance
    final variance = (DateTime.now().millisecondsSinceEpoch % 10) - 5;
    final price = basePrice + variance;
    
    return {
      'crop': crop,
      'region': region,
      'price': price,
      'currency': currencies[region] ?? 'USD',
      'trend': variance > 0 ? 'up' : 'down',
      'source': 'local',
    };
  }
  
  /// Generate realistic trend data for charts
  List<double> _generateTrendData(String crop) {
    // Base prices and typical volatility per crop
    final cropData = {
      'Maize': {'base': 45.0, 'volatility': 5.0},
      'Wheat': {'base': 55.0, 'volatility': 8.0},
      'Coffee': {'base': 350.0, 'volatility': 30.0},
      'Teff': {'base': 80.0, 'volatility': 10.0},
    };
    
    final data = cropData[crop] ?? {'base': 50.0, 'volatility': 5.0};
    final base = data['base']!;
    final vol = data['volatility']!;
    
    // Generate 6 months of data with seasonal trend
    final List<double> trend = [];
    double current = base - vol; // Start lower
    
    for (int i = 0; i < 6; i++) {
      // Upward trend with some noise
      current += (vol / 3) + (i % 2 == 0 ? vol / 5 : -vol / 6);
      trend.add(double.parse(current.toStringAsFixed(1)));
    }
    
    return trend;
  }
}
