import 'package:shared_preferences/shared_preferences.dart';

import 'services.dart';

class ApiAuth {
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      await ApiService.saveToken(response['token']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', response['user']['id']);

      return {'success': true, 'message': response['message']};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      return {'success': true, 'message': response['message']};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  static Future<void> logout() async {
    await ApiService.logout();
  }
}
