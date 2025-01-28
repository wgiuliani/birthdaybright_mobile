import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/birthday.dart';
import '../models/gift_suggestion.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': token,
    };
  }

  // Auth endpoints
  Future<User> signUp(String email, String password, String? name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
        if (name != null) 'name': name,
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<void> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mobile/auth'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 302) {
      // Check headers first
      String? token = response.headers['authorization'] ?? 
                     response.headers['Authorization'];
      
      // If not in headers, check response body
      if (token == null && response.body.isNotEmpty) {
        try {
          final bodyJson = jsonDecode(response.body);
          token = bodyJson['token'] ?? bodyJson['access_token'];
        } catch (e) {
          // Handle parse error
        }
      }

      if (token != null) {
        // Add 'Bearer ' prefix if it's not already there
        if (!token.startsWith('Bearer ')) {
          token = 'Bearer $token';
        }
        await setToken(token);
      } else {
        throw Exception('No token received');
      }
    } else {
      final error = response.body.isNotEmpty ? 
        jsonDecode(response.body)['error'] : 
        'Authentication failed';
      throw Exception(error);
    }
  }

  Future<void> signOut() async {
    await clearToken();
  }

  // Birthday endpoints
  Future<List<Birthday>> getBirthdays() async {
    final headers = await _getHeaders();
    print("Authorization Headers: $headers"); // Add this line to log headers
    final response = await http.get(
      Uri.parse('$baseUrl/mobile/birthdays'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Birthday.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<Birthday> createBirthday(Map<String, dynamic> birthdayData) async {

  final response = await http.post(
    Uri.parse('$baseUrl/mobile/birthdays'),
    headers: await _getHeaders(),
    body: jsonEncode(birthdayData),
  );

  if (response.statusCode == 201) {
    return Birthday.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(jsonDecode(response.body)['error']);
  }
}

  Future<Birthday> updateBirthday(String id, Map<String, dynamic> birthdayData) async { // Add this line to log the data

    final response = await http.put(
      Uri.parse('$baseUrl/mobile/birthdays'),
      headers: await _getHeaders(),
      body: jsonEncode(birthdayData),
    );

    if (response.statusCode == 200) {
      return Birthday.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<void> deleteBirthday(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/mobile/birthdays'),
      headers: await _getHeaders(),
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 204) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  // Gift suggestion endpoints
  Future<List<GiftSuggestion>> getGiftSuggestions(String birthdayId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mobile/suggestions?birthdayId=$birthdayId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      print("Response body: ${response.body}");
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => GiftSuggestion.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  Future<List<GiftSuggestion>> generateGiftSuggestions(String birthdayId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mobile/suggestions'),
      headers: await _getHeaders(),
      body: jsonEncode({'birthdayId': birthdayId}),
    );

    if (response.statusCode == 201) {
      print("Response body: ${response.body}"); 
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => GiftSuggestion.fromJson(json)).toList();
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
} 