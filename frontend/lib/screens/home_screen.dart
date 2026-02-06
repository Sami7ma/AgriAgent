import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../models/diagnosis.dart';
import '../models/farm_card.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../widgets/farm_card_widget.dart';
import '../widgets/image_display_widget.dart';
import '../widgets/diagnosis_result_widget.dart';
import '../widgets/chat_widget.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final ImagePicker _picker = ImagePicker();

  // State
  File? _mediaFile;
  Diagnosis? _diagnosis;
  FarmCard? _farmCard;
  Position? _currentPosition;
  
  // Loading States
  bool _isAnalyzing = false;
  bool _isCardLoading = false;
  String? _analysisError;
  String? _cardError;

  @override
  void initState() {
    super.initState();
    _initialLoad();
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
      await _fetchDailyCard(position);
    } catch (e) {
      print("Location Error: $e");
      // Even if location fails, try to fetch card with defaults
      await _fetchDailyCard(null);
    }
  }

  Future<void> _fetchDailyCard(Position? pos) async {
    try {
      FarmCard? card = await _apiService.getDailyCard(
        lat: pos?.latitude,
        lon: pos?.longitude,
      );
      setState(() {
        _farmCard = card;
        _isCardLoading = false;
      });
    } catch (e) {
      setState(() {
        _cardError = "Failed to load daily insights.";
        _isCardLoading = false;
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

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ChatWidget(initialDiagnosis: _diagnosis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 24),
            SizedBox(width: 8),
            Text('AgriAgent'),
          ],
        ),
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
                FarmCardWidget(
                  data: _farmCard,
                  isLoading: _isCardLoading,
                  error: _cardError,
                  onRefresh: _determinePosition,
                ),
                const SizedBox(height: 24),
                ImageDisplayWidget(mediaFile: _mediaFile),
                const SizedBox(height: 24),
                _buildActionButtons(),
                const SizedBox(height: 24),
                if (_isAnalyzing)
                  const Center(child: CircularProgressIndicator())
                else if (_analysisError != null)
                  _buildErrorCard()
                else if (_diagnosis != null)
                  DiagnosisResultWidget(
                    diagnosis: _diagnosis!,
                    onChatPressed: _openChat,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                _isAnalyzing ? null : () => _pickMedia(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                _isAnalyzing ? null : () => _pickMedia(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
              child: Text(_analysisError!,
                  style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
  }
}
