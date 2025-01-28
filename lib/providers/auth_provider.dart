import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;

  AuthProvider(this._apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> signUp(String email, String password, String? name) async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = await _apiService.signUp(email, password, name);
      await _apiService.signIn(email, password);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.signIn(email, password);
      // Add user profile fetch here if your API supports it
      // _user = await _apiService.getProfile();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _apiService.signOut();
      _user = null;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        // TODO: Fetch user profile
        notifyListeners();
      }
    } catch (e) {
      await signOut();
    }
  }
} 