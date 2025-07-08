import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_profile.dart';

class UserProfileStorage {
  static const String _key = 'user_profile';

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toMap());
    await prefs.setString(_key, jsonString);
  }

  static Future<UserProfile> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) {
      return UserProfile.empty();
    }
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserProfile.fromMap(map);
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
} 