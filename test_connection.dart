
import 'dart:io';

void main() async {
  // Test connection to the backend
  final url = 'http://192.168.1.8:8000/api/v1/health';
  print('Testing connection to: $url');
  
  try {
    final client = HttpClient();
    client.connectionTimeout = Duration(seconds: 5);
    
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    
    print('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('✅ SUCCESS: Backend is reachable!');
    } else {
      print('❌ ERROR: Backend reachable but returned status ${response.statusCode}');
    }
  } catch (e) {
    print('❌ CONNECTION FAILED: $e');
    print('\nTroubleshooting tips:');
    print('1. Ensure your phone and PC are on the SAME Wi-Fi network.');
    print('2. Check if Windows Firewall is blocking Python/Uvicorn.');
    print('3. Verify the IP address 192.168.1.8 is correct.');
  }
}
