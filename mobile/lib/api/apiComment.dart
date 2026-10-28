import 'package:shared_preferences/shared_preferences.dart';

import 'services.dart';

class ApiComment {
  static Future<List<dynamic>> getComments(int postId) async {
    try {
      final response = await ApiService.get('/comments/post/$postId');
      return response['data'] ?? [];
    } catch (e) {
      print('Error getComments: $e');
      return [];
    }
  }

  static Future<bool> createComment(int postId, String content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return false;

      await ApiService.post('/comments', {
        'post_id': postId,
        'user_id': userId,
        'content': content,
      });

      return true;
    } catch (e) {
      print('Error createComment: $e');
      return false;
    }
  }
}
