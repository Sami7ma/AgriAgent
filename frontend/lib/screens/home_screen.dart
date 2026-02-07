
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/diagnosis.dart';
import '../models/farm_card.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/chat_service.dart'; // Import Service
import '../widgets/farm_card_widget.dart';
import '../widgets/image_display_widget.dart';
import '../widgets/diagnosis_result_widget.dart';
import '../widgets/market_chart.dart';
import 'chat_screen.dart'; 
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final WeatherService _weatherService = WeatherService();
  final ChatService _chatService = ChatService(); // Added missing service
  final ImagePicker _picker = ImagePicker();

  // State
  File? _mediaFile;
  Diagnosis? _diagnosis;
  FarmCard? _farmCard;
  Position? _currentPosition;
  Map<String, dynamic>? _weatherData;
  
  // Loading States
  bool _isAnalyzing = false;
  bool _isCardLoading = false;
  String? _analysisError;
  String? _cardError;

  // Chat History Management
  List<Map<String, String>> _chatSessions = [];
  
  // Market Data Selection
  String _selectedCrop = "Maize";
  final List<String> _crops = ["Maize", "Wheat", "Coffee", "Teff"];

  @override
  void initState() {
    super.initState();
    _initialLoad();
    _loadSessionsList();
  }
  
  Future<void> _loadSessionsList() async {
     // Verify persistence logic from ChatService
     List<Map<String, String>> sessions = await _chatService.getSessions();
     setState(() {
         _chatSessions = sessions;
     });
  }

  Future<void> _initialLoad() async {
    await _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isCardLoading = true;
      _cardError = null;
    });

    try {
      Position position = await _locationService.determinePosition();
      setState(() {
        _currentPosition = position;
      });
      
      // PARALLEL FETCH: Card + Real Weather
      await Future.wait([
          _fetchDailyCard(position),
          _fetchRealWeather(position),
      ]);

      setState(() {
        _isCardLoading = false;
      });

    } catch (e) {
      print("Location Error: $e");
      await _fetchDailyCard(null);
      setState(() { _isCardLoading = false; });
    }
  }

  Future<void> _fetchRealWeather(Position pos) async {
      final weather = await _weatherService.fetchCurrentWeather(pos.latitude, pos.longitude);
      setState(() {
          _weatherData = weather;
      });
  }

  Future<void> _fetchDailyCard(Position? pos) async {
    try {
      FarmCard? card = await _apiService.getDailyCard(
        lat: pos?.latitude,
        lon: pos?.longitude,
      );
      setState(() {
        _farmCard = card;
      });
    } catch (e) {
      setState(() {
         _cardError = "Network Error"; 
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _mediaFile = null;
      _diagnosis = null;
      _analysisError = null;
    });
    await _determinePosition();
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file != null) {
        setState(() {
          _mediaFile = File(file.path);
          _diagnosis = null;
          _analysisError = null;
        });
        _analyzeImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_mediaFile == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      Diagnosis result = await _apiService.analyzeCrop(_mediaFile!);
      setState(() {
        _diagnosis = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _analysisError = "Unable to analyze crop. Please check connection.";
        _isAnalyzing = false;
      });
    }
  }

  void _openChat(Diagnosis? diag, {String? sessionId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
            initialDiagnosis: diag,
            locationContext: _farmCard, 
            latitude: _currentPosition?.latitude,
            longitude: _currentPosition?.longitude,
            sessionId: sessionId,
        ),
      ),
    ).then((_) => _loadSessionsList()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 24, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('AgriAgent', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
            Builder(
            builder: (context) => IconButton(
                icon: const Icon(Icons.sort, size: 28, color: Colors.black87), // Modern Menu Icon
                onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
            ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: const Color(0xFFF1F8E9),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
              child: const Center(child: Text("Chat History", style: TextStyle(color: Colors.white, fontSize: 24))),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chatSessions.length,
                itemBuilder: (context, index) {
                   final session = _chatSessions[index];
                   return ListTile(
                     leading: const Icon(Icons.history),
                     title: Text(session['title'] ?? 'Chat ${index + 1}'),
                     subtitle: Text(session['date']?.substring(0, 10) ?? '', style: const TextStyle(fontSize: 10)),
                     onTap: () {
                        Navigator.pop(context); // Close Drawer
                        _openChat(null, sessionId: session['id']); // Load existing
                     },
                     trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
                        onPressed: () async {
                            await _chatService.deleteSession(session['id']!);
                            _loadSessionsList();
                        },
                     ),
                   );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openChat(_diagnosis),
        label: const Text("Chat AI"),
        icon: const Icon(Icons.chat),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. HEADER (Greeting & Location)
                Text(
                  "Hello, Farmer! 👋", 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey[900])
                ),
                const SizedBox(height: 20),

                // 2. MAIN INSIGHT CARD (Weather + Action)
                FarmCardWidget(
                  data: _farmCard,
                  weatherData: _weatherData, // NEW: Real Weather
                  isLoading: _isCardLoading,
                  error: _cardError,
                  onRefresh: _determinePosition,
                ),
                const SizedBox(height: 20),

                // 3. MARKET ANALYTICS
                const Text(
            "Market Trends 📈",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Crop Selector
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: _crops.map((crop) {
                    return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                            label: Text(crop),
                            selected: _selectedCrop == crop,
                            selectedColor: const Color(0xFF2E7D32),
                            labelStyle: TextStyle(color: _selectedCrop == crop ? Colors.white : Colors.black),
                            onSelected: (bool selected) {
                                if (selected) {
                                    setState(() {
                                        _selectedCrop = crop;
                                    });
                                }
                            },
                        ),
                    );
                }).toList(),
            ),
        ),
        const SizedBox(height: 10),
        SizedBox(
            height: 250,
            child: MarketChartWidget(cropName: _selectedCrop),
        ),
                const SizedBox(height: 24),

                // 4. DIAGNOSIS AREA (Action Buttons + Content)
                const Text("Crop Doctor 🩺", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildDiagnosticArea(),
                const SizedBox(height: 24),

                // 5. NEWS SECTION
                const Text("Agri News 📰", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildNewsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticArea() {
      // If no image, show "Upload" Card. If image, show Widget.
      if (_mediaFile == null) {
          return Container(
              height: 200,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                       Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.green.shade300),
                       const SizedBox(height: 10),
                       const Text("Upload a photo to detect diseases", style: TextStyle(color: Colors.grey)),
                       const SizedBox(height: 20),
                       Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                               ElevatedButton.icon(
                                   onPressed: _isAnalyzing ? null : () => _pickMedia(ImageSource.camera),
                                   icon: const Icon(Icons.camera_alt),
                                   label: const Text("Camera"),
                                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
                               ),
                               const SizedBox(width: 20),
                               OutlinedButton.icon(
                                   onPressed: _isAnalyzing ? null : () => _pickMedia(ImageSource.gallery),
                                   icon: const Icon(Icons.photo),
                                   label: const Text("Gallery"),
                               ),
                           ],
                       )
                  ],
              ),
          );
      }

      return Column(
          children: [
             ImageDisplayWidget(mediaFile: _mediaFile),
             const SizedBox(height: 16),
             if (_isAnalyzing)
                const LinearProgressIndicator(color: Color(0xFF2E7D32))
             else if (_analysisError != null)
                Text(_analysisError!, style: const TextStyle(color: Colors.red))
             else if (_diagnosis != null)
                DiagnosisResultWidget(
                  diagnosis: _diagnosis!,
                  onChatPressed: () => _openChat(_diagnosis),
                ),
          ],
      );
  }

  Widget _buildNewsList() {
      // Dynamic News based on context
      List<Map<String, String>> articles = [
          {"title": "Maize Prices Stable in ${_farmCard?.location ?? 'Region'}", "source": "AgriBiz Daily"},
      ];
      
      // Weather specific news
      if (_weatherData != null) {
          if (_weatherData!['condition'].toString().contains("Rain")) {
             articles.insert(0, {"title": "Heavy Rainfall Alerts: Preparing Drainage", "source": "Met Dept"});
          } else if (_weatherData!['condition'].toString().contains("Sunny")) {
             articles.insert(0, {"title": "Irrigation Tips for Dry Spells", "source": "Farmer's Weekly"});
          }
      } else {
         articles.add({"title": "General Crop Market Update", "source": "Ministry of Agriculture"});
      }
      
      articles.add({"title": "New Pest Alert: Fall Armyworm", "source": "KALRO"});

      return Column(
          children: articles.map((article) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListTile(
                  leading: Container(
                      width: 50, height: 50, 
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.article, color: Colors.green),
                  ),
                  title: Text(article['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(article['source']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ),
          )).toList(),
      );
  }
}
