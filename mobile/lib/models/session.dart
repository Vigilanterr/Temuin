import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the authenticated session in memory and persists it locally.
class Session {
  Session._();

  static const _tokenKey = 'token';
  static const _userIdKey = 'user_id';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_name';
  static const _avatarKey = 'user_avatar';
  static const _registeredEmailKey = 'registered_email';
  static const _registeredNameKey = 'registered_name';

  static String? token;
  static int? userId;
  static String? email;
  static String? name;
  static String? avatarBase64;
  static bool _loaded = false;

  /// Notifies screens when locally stored profile data changes.
  static final ValueNotifier<int> profileChanges = ValueNotifier<int>(0);

  static bool get isAuthenticated {
    return userId != null && token != null && isTokenValid(token);
  }

  static String get displayName {
    final saved = name?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    final accountEmail = email?.trim();
    if (accountEmail != null && accountEmail.isNotEmpty) {
      final prefix = accountEmail.split('@').first;
      if (prefix.isEmpty) return 'Pengguna';
      return prefix[0].toUpperCase() + prefix.substring(1);
    }
    return 'Pengguna';
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    userId = prefs.getInt(_userIdKey);
    email = prefs.getString(_emailKey);
    name = prefs.getString(_nameKey);
    avatarBase64 = prefs.getString(_avatarKey);
    _loaded = true;
  }

  static Future<void> saveLogin({
    required String newToken,
    required int newUserId,
    required String newEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (email != null && email != newEmail) {
      // Avoid showing profile data from a different account on this device.
      name = null;
      avatarBase64 = null;
      await prefs.remove(_nameKey);
      await prefs.remove(_avatarKey);
    }

    if (name == null) {
      final registeredEmail = prefs.getString(_registeredEmailKey);
      final registeredName = prefs.getString(_registeredNameKey);
      if (registeredEmail == newEmail && registeredName != null) {
        name = registeredName;
        await prefs.setString(_nameKey, registeredName);
      }
    }

    token = newToken;
    userId = newUserId;
    email = newEmail;

    await prefs.setString(_tokenKey, newToken);
    await prefs.setInt(_userIdKey, newUserId);
    await prefs.setString(_emailKey, newEmail);
    _loaded = true;
  }

  /// Keeps the name entered during registration so it can be shown after login.
  static Future<void> rememberRegisteredAccount({
    required String accountEmail,
    required String accountName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registeredEmailKey, accountEmail);
    await prefs.setString(_registeredNameKey, accountName);
  }

  static Future<void> updateProfile({
    String? newName,
    String? newAvatarBase64,
    bool clearAvatar = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (newName != null) {
      name = newName.trim();
      await prefs.setString(_nameKey, name!);
    }
    if (clearAvatar) {
      avatarBase64 = null;
      await prefs.remove(_avatarKey);
    } else if (newAvatarBase64 != null) {
      avatarBase64 = newAvatarBase64;
      await prefs.setString(_avatarKey, newAvatarBase64);
    }
    profileChanges.value++;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      _tokenKey,
      _userIdKey,
      _emailKey,
      _nameKey,
      _avatarKey,
    ]) {
      await prefs.remove(key);
    }
    token = null;
    userId = null;
    email = null;
    name = null;
    avatarBase64 = null;
  }

  /// Decodes the JWT payload and checks its expiry locally.
  static bool isTokenValid(String? jwt) {
    if (jwt == null || jwt.isEmpty) return false;
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return false;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map || payload['exp'] is! num) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        (payload['exp'] as num).toInt() * 1000,
      );
      return expiry.isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  static bool get isLoaded => _loaded;
}
