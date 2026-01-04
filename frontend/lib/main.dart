import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

// CENTRALIZED API CONFIGURATION
// For Android Emulator: http://10.0.2.2:8000/api/v1
// For Physical Device (requires `adb reverse tcp:8000 tcp:8000`): http://127.0.0.1:8000/api/v1
const String kBaseUrl = "http://127.0.0.1:8000/api/v1";

void main() {
  runApp(const AgriAgentApp());
}

class AgriAgentApp extends StatelessWidget {
  const AgriAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriAgent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest Green
          secondary: const Color(0xFF81C784),
          surface: const Color(0xFFF1F8E9),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        // cardTheme removed to avoid type mismatch on bleeding-edge Flutter versions
        // cardTheme: CardTheme(
        //   elevation: 3,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //   color: Colors.white,
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const DiagnosisScreen(),
    );
  }
}

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}



class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  Map<String, dynamic>? _diagnosisData;
  String? _errorMessage;
  bool _isLoading = false;
  Position? _currentPosition;

  Future<Map<String, dynamic>?>? _farmCardFuture;

  @override
  void initState() {
    super.initState();
    _farmCardFuture = _fetchCard();
    _determinePosition();
  }
  
  // Update _determinePosition to call:
  // setState(() { _farmCardFuture = _fetchCard(); }); 
  
  // ... inside _determinePosition replaced block above ...


  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, 
        timeLimit: const Duration(seconds: 10)
      );
      setState(() {
        _currentPosition = position;
      });
      _showSuccessSnackBar("Location found: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}");
      
      // Force refresh of farm card with new location
      await _refreshFarmCard();
    } catch (e) {
      print("Error getting location: $e");
      _showErrorSnackBar("Could not get GPS location. Ensure Mobile Data/WiFi is ON.");
    }
  }

  // New method to fetch and update card state manually
  Future<void> _refreshFarmCard() async {
    final data = await _fetchCard();
    if (data != null && mounted) {
      setState(() {
        // We need to store this data or trigger the FutureBuilder to reload.
        // Better yet, let's just make `_farmCardFuture` a state variable.
      });
    }
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file != null) {
        setState(() {
          _mediaFile = File(file.path);
          _diagnosisData = null;
          _errorMessage = null;
        });
        _uploadAndAnalyze();
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file: $e');
    }
  }

  Future<void> _uploadAndAnalyze() async {
    if (_mediaFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String fileName = _mediaFile!.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(_mediaFile!.path, filename: fileName),
      });

      Dio dio = Dio();
      Response response = await dio.post(
        "$kBaseUrl/analyze/diagnose",
        data: formData,
      );

      setState(() {
        _diagnosisData = response.data;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Unable to analyze crop. Please check connection.";
        _isLoading = false;
      });
      print("Analysis Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8, // 80% height
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ChatWidget(initialContext: _diagnosisData, baseUrl: kBaseUrl),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFarmCardSection(),
              const SizedBox(height: 24),
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 24),
              if (_isLoading) 
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                _buildErrorCard()
              else if (_diagnosisData != null)
                Column(
                  children: [
                    _buildDiagnosisResult(),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _openChat,
                      icon: const Icon(Icons.chat),
                      label: const Text("Ask AgriAgent about this"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmCardSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Text("Daily Application", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.my_location, size: 20),
                  onPressed: _determinePosition,
                  tooltip: "Accurate Location",
                ),
              ],
            ),
            const Divider(height: 20),
            // Re-fetch only when we have location or just once
            FutureBuilder(
              future: _farmCardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _currentPosition == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                   return const Text("Tap to refresh daily insights", style: TextStyle(color: Colors.grey));
                }
               
                final data = snapshot.data as Map<String, dynamic>;
                return Column(
                  children: [
                    _buildInfoRow(Icons.location_on, "${data['location']} • ${data['date']}"),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.wb_sunny, data['weather_summary']),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.attach_money, data['market_trend']),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Recommendation: ${data['top_action']}", 
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade800))),
      ],
    );
  }

  // ... _buildImageSection, _buildActionButtons, _buildDiagnosisResult remain similar

  Widget _buildImageSection() {
     return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          image: _mediaFile != null 
            ? DecorationImage(image: FileImage(_mediaFile!), fit: BoxFit.cover)
            : null,
        ),
        child: _mediaFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text("No image selected", style: TextStyle(color: Colors.grey.shade500)),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _pickMedia(ImageSource.camera),
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
            onPressed: _isLoading ? null : () => _pickMedia(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
               padding: const EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisResult() {
    final data = _diagnosisData!;
    final bool isHealthy = (data['issue'] as String? ?? '').toLowerCase().contains('healthy');
    final Color statusColor = isHealthy ? Colors.green : Colors.orange;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Diagnosis Result",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${data['confidence']}% Confident",
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            Text(
              "${data['crop']} - ${data['issue']}",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor),
            ),
            const SizedBox(height: 8),
            Text(
              "Severity: ${data['severity']}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            const Text("Recommendations:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...((data['actions'] as List?) ?? []).map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text(action.toString(), style: const TextStyle(fontSize: 15))),
                ],
              ),
            )),
          ],
        ),
      ),
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
          Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700))),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchCard() async {
    try {
      Dio dio = Dio();
      String url = "$kBaseUrl/artifacts/daily-card";
      if (_currentPosition != null) {
        url += "?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}";
      }
      var resp = await dio.get(url);
      return resp.data;
    } catch (e) {
      return null;
    }
  }
}

// Simple Chat Widget
class ChatWidget extends StatefulWidget {
  final Map<String, dynamic>? initialContext;
  final String baseUrl;

  const ChatWidget({super.key, this.initialContext, required this.baseUrl});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Add initial message if context exists
    if (widget.initialContext != null) {
      _messages.add({
        "role": "system",
        "text": "Asking about: ${widget.initialContext!['crop']} - ${widget.initialContext!['issue']}"
      });
    }
    _messages.add({"role": "bot", "text": "Hello! Ask me anything about your crop."});
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isSending = true;
      _controller.clear();
    });

    try {
      Dio dio = Dio();
      // Construct context string
      String contextStr = "";
      if (widget.initialContext != null) {
        contextStr = "Diagnosis: ${widget.initialContext!['crop']} with ${widget.initialContext!['issue']}. Severity: ${widget.initialContext!['severity']}.";
      }

      var resp = await dio.post(
        "${widget.baseUrl}/agent/query",
        data: {
          "query": text,
          "context_data": {"diagnosis_context": contextStr}
        },
      );
      
      setState(() {
         _messages.add({"role": "bot", "text": resp.data['response_text']});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "error", "text": "Failed to get response."});
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          height: 4, width: 40, 
          decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))
        ),
        const SizedBox(height: 10),
        const Text("AgriAgent Chat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == "user";
              final isSystem = msg['role'] == "system";
              
              if (isSystem) {
                return Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(msg['text']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ));
              }

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.green.shade600 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isSending) const Padding(padding: EdgeInsets.all(8), child: LinearProgressIndicator()),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Ask a question...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendMessage, 
                icon: const Icon(Icons.send),
              )
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom), // Keyboard spacer
      ],
    );
  }
}
