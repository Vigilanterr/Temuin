import '../models/session.dart';
import 'services.dart';

class ApiComment {
  ApiComment._();

  static Future<List<Map<String, dynamic>>> getComments(int postId) async {
    final response = await ApiService.get('/comments/post/$postId');
    if (response is! Map || response['data'] is! List) {
      throw const ApiException('Data komentar tidak valid.');
    }
    return (response['data'] as List)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static Future<void> createComment(int postId, String content) async {
    final userId = Session.userId;
    if (userId == null) {
      throw const ApiException('Sesi tidak ditemukan. Silakan masuk kembali.');
    }

    await ApiService.post('/comments', {
      'post_id': postId,
      'user_id': userId,
      'content': content,
    });
  }
}
