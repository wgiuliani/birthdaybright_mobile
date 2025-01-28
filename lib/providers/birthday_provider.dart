import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/birthday.dart';
import '../models/gift_suggestion.dart';

class BirthdayProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Birthday> _birthdays = [];
  final Map<String, List<GiftSuggestion>> _suggestions = {};
  bool _isLoading = false;
  String? _error;
  final Map<String, List<GiftSuggestion>> _giftSuggestions = {};

  BirthdayProvider(this._apiService);

  List<Birthday> get birthdays => _birthdays;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<GiftSuggestion>> get giftSuggestions => _giftSuggestions;

  List<GiftSuggestion>? getSuggestionsForBirthday(String birthdayId) {
    return _suggestions[birthdayId];
  }

  Future<void> fetchBirthdays() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _birthdays = await _apiService.getBirthdays();
      _birthdays.sort((a, b) => a.daysUntilBirthday.compareTo(b.daysUntilBirthday));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addBirthday(Map<String, dynamic> birthdayData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final birthday = await _apiService.createBirthday(birthdayData);
      _birthdays.add(birthday);
      _birthdays.sort((a, b) => a.daysUntilBirthday.compareTo(b.daysUntilBirthday));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBirthday(String id, Map<String, dynamic> birthdayData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedBirthday = await _apiService.updateBirthday(id, birthdayData);
      final index = _birthdays.indexWhere((b) => b.id == id);
      if (index != -1) {
        _birthdays[index] = updatedBirthday;
        _birthdays.sort((a, b) => a.daysUntilBirthday.compareTo(b.daysUntilBirthday));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBirthday(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.deleteBirthday(id);
      _birthdays.removeWhere((b) => b.id == id);
      _suggestions.remove(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchGiftSuggestions(String birthdayId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final suggestions = await _apiService.getGiftSuggestions(birthdayId);
      print("---- Suggestions-----: ${suggestions}");
      _giftSuggestions[birthdayId] = suggestions;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> generateGiftSuggestions(String birthdayId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final suggestions = await _apiService.generateGiftSuggestions(birthdayId);
      _giftSuggestions[birthdayId] = suggestions;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
} 