import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doan_hoi_app/src/core/constants/app_constants.dart';
import 'package:doan_hoi_app/src/data/models/user_model.dart';
import 'package:doan_hoi_app/src/data/models/notification_model.dart';

class SharedPreferencesManager {
  static SharedPreferences? _preferences;

  static Future<SharedPreferences> get preferences async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences!;
  }

  // Auth methods
  Future<void> saveAccessToken(String token) async {
    final prefs = await preferences;
    await prefs.setString(AppConstants.keyAccessToken, token);
  }

  Future<String?> getAccessToken() async {
    final prefs = await preferences;
    return prefs.getString(AppConstants.keyAccessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await preferences;
    await prefs.setString(AppConstants.keyRefreshToken, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await preferences;
    return prefs.getString(AppConstants.keyRefreshToken);
  }

  Future<void> clearAuthData() async {
    final prefs = await preferences;
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyRefreshToken);
    await prefs.remove(AppConstants.keyUserData);
  }

  // User data methods
  Future<void> saveUserData(UserModel user) async {
    final prefs = await preferences;
    await prefs.setString(AppConstants.keyUserData, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUserData() async {
    final prefs = await preferences;
    final userData = prefs.getString(AppConstants.keyUserData);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Notifications cache methods
  Future<void> cacheNotifications(List<NotificationModel> notifications) async {
    final prefs = await preferences;
    final notificationsJson = notifications.map((e) => e.toJson()).toList();
    await prefs.setString(
      AppConstants.keyNotificationsCache,
      jsonEncode({
        'notifications': notificationsJson,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<List<NotificationModel>?> getCachedNotifications() async {
    final prefs = await preferences;
    final cachedData = prefs.getString(AppConstants.keyNotificationsCache);

    if (cachedData != null) {
      final data = jsonDecode(cachedData);
      final timestamp = DateTime.parse(data['timestamp']);
      final now = DateTime.now();

      // Check if cache is still valid (less than 1 hour old)
      if (now.difference(timestamp).inSeconds < AppConstants.maxCacheAge) {
        final notificationsJson = data['notifications'] as List;
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    }
    return null;
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await preferences;
    await prefs.clear();
  }
}
