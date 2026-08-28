import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/homepage_feed_response.dart';
import '../../models/persona_type.dart';
import '../../models/alert_model.dart';

class ApiClient {
  static const String defaultBaseUrl = 'http://localhost:8000';
  final String baseUrl;

  ApiClient({this.baseUrl = defaultBaseUrl});

  Future<HomepageFeedResponse> fetchHomepageFeed({
    required String userId,
    double lat = 28.6139,
    double lon = 77.2090,
    String locationName = 'New Delhi, India',
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/homepage-feed').replace(
      queryParameters: {
        'user_id': userId,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'location_name': locationName,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return HomepageFeedResponse.fromJson(jsonMap);
    } else {
      throw Exception('Failed to load homepage feed: ${response.statusCode}');
    }
  }

  Future<List<PersonaType>> fetchUserPersonas(String userId) async {
    final uri = Uri.parse('$baseUrl/api/v1/personas/$userId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((e) => PersonaTypeExtension.fromString(e.toString())).toList();
    }
    return [PersonaType.health, PersonaType.commute, PersonaType.fitness, PersonaType.family];
  }

  Future<bool> updateUserPersonas({
    required String userId,
    required List<PersonaType> personas,
    PersonaType? primaryPersona,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/personas');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'personas': personas.map((p) => p.value).toList(),
        'primary_persona': primaryPersona?.value,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateUserLayout({
    required String userId,
    required List<String> cardOrder,
    required List<String> hiddenCards,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/homepage-layout');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'card_order': cardOrder,
        'hidden_cards': hiddenCards,
      }),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> fetchUserLayout(String userId) async {
    final uri = Uri.parse('$baseUrl/api/v1/homepage-layout/$userId');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return {'card_order': [], 'hidden_cards': []};
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/auth/verify-otp');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'otp_code': otpCode,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Invalid OTP or authentication failure');
  }
}
