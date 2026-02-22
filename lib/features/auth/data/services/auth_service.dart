import 'dart:convert';
import 'package:arsys/core/config/api_config.dart';
import 'package:arsys/core/utils/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = getBaseUrl();
  String? _token;
  Map<String, dynamic>? _user;
  List<dynamic>? _roles;

  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  List<dynamic>? get roles => _roles;

  Future<bool> tryAutoLogin() async {
    final authData = await SecureStorage.getAuthData();
    if (authData['token'] == null) {
      return false;
    }
    _token = authData['token'];
    _user = jsonDecode(authData['user']!);
    _roles = jsonDecode(authData['roles']!);
    return true;
  }

  Future<String?> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = jsonEncode(<String, String>{'email': email, 'password': password});

    debugPrint('--- Attempting Login ---');
    debugPrint('URL: $url');
    debugPrint('Request Body: $body');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8', // Perbaikan: UTF-T -> UTF-8
          'Accept': 'application/json',
        },
        body: body,
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data.containsKey('access_token')) {
          _token = data['access_token'];
          _user = data['user'];
          _roles = data['roles'];
          await SecureStorage.saveAuthData(
            _token!,
            jsonEncode(_user!),
            jsonEncode(_roles!),
          );
          debugPrint('Login Successful. Token stored.');
          debugPrint('------------------------');
          return null;
        } else {
          debugPrint('Login Failed: "access_token" key not found.');
          debugPrint('------------------------');
          return 'Login failed: Key "access_token" not found in response.';
        }
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Server error: ${response.statusCode}';
        debugPrint('Login Failed: $errorMessage');
        debugPrint('------------------------');
        return errorMessage;
      }
    } catch (e) {
      debugPrint('An exception occurred: ${e.toString()}');
      debugPrint('------------------------');
      return 'An unexpected error occurred. Please check your connection.';
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      final url = Uri.parse('$_baseUrl/logout');
      try {
        await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $_token',
          },
        );
      } catch (e) {
        // Logout request failed, but we'll still clear local data.
      }
    }
    _token = null;
    _user = null;
    _roles = null;
    await SecureStorage.deleteAll();
  }

  Future<http.Response> get(String url) async {
    if (_token == null) throw Exception('Authentication token not found.');
    return http.get(
      Uri.parse('$_baseUrl$url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    ).timeout(const Duration(seconds: 15));
  }

  Future<http.Response> post(String url, Map<String, dynamic> body) async {
    if (_token == null) throw Exception('Authentication token not found.');
    return http.post(
      Uri.parse('$_baseUrl$url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));
  }
}
