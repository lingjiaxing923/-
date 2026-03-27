import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  String? _token;
  bool _isConnected = false;
  
  String? get token => _token;
  bool get isConnected => _isConnected;
  bool get isAuthenticated => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    notifyListeners();
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    notifyListeners();
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<http.Response> _request(String method, String endpoint, {Map<String, dynamic>? body}) async {
    try {
      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          );
          break;
        case 'POST':
          response = await http.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: headers,
          );
          break;
      }
      
      _isConnected = response.statusCode != null;
      notifyListeners();
      return response;
    } catch (e) {
      debugPrint('API Error: $e');
      _isConnected = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint) => _request('GET', endpoint);
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) => _request('POST', endpoint, body: body);
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) => _request('PUT', endpoint, body: body);
  Future<http.Response> delete(String endpoint) => _request('DELETE', endpoint);
}
