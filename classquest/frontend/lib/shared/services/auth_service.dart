import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'user.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;

  AuthService() : _apiService = ApiService();

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post('/auth/login', body: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        await _apiService.setToken(token);

        final userResponse = await _apiService.get('/auth/me');
        if (userResponse.statusCode == 200) {
          _currentUser = User.fromJson(jsonDecode(userResponse.body));
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
          await prefs.setString('role', _currentUser!.role);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _apiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  String getRole() {
    return _currentUser?.role ?? '';
  }
}
