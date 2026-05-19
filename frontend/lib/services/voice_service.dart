import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  
  factory VoiceService() {
    return _instance;
  }
  
  VoiceService._internal();

  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = '';

  /// Initialize the voice service
  Future<void> initialize() async {
    _speechToText = stt.SpeechToText();
    final available = await _speechToText.initialize(
      onError: (error) => _handleError(error),
      onStatus: (status) => print('Speech status: $status'),
    );
    
    if (!available) {
      throw Exception('Speech recognition not available');
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Start listening for voice input
  Future<void> startListening({
    required Function(String) onResult,
    String languageCode = 'en_US',
  }) async {
    // Check permission first
    bool hasPermission = await hasMicrophonePermission();
    if (!hasPermission) {
      hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        throw Exception('Microphone permission denied');
      }
    }

    if (_isListening) {
      return;
    }

    _recognizedText = '';
    
    try {
      _speechToText.listen(
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          onResult(_recognizedText);
        },
        localeId: languageCode,
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onSoundLevelChange: (level) {
          // Can be used for waveform visualization
        },
      );
      
      _isListening = true;
    } catch (e) {
      throw Exception('Failed to start listening: $e');
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) {
      return;
    }
    
    try {
      await _speechToText.stop();
      _isListening = false;
    } catch (e) {
      throw Exception('Failed to stop listening: $e');
    }
  }

  /// Cancel recording without returning text
  Future<void> cancelListening() async {
    await stopListening();
    _recognizedText = '';
  }

  /// Get the last recognized text
  String getRecognizedText() {
    return _recognizedText;
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if speech to text is available
  bool get isAvailable => _speechToText.isAvailable;

  /// Handle speech recognition errors
  void _handleError(dynamic error) {
    print('Speech error: $error');
  }

  /// Dispose resources
  void dispose() {
    _speechToText.stop();
    _isListening = false;
  }
}
