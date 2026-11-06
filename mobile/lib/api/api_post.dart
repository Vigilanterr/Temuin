import '../models/post.dart';
import 'services.dart';

class ApiPost {
  ApiPost._();

  static Future<List<Post>> getPosts() async {
    final response = await ApiService.get('/posts');
    if (response is! Map || response['data'] is! List) {
      throw const ApiException('Data postingan tidak valid.');
    }

    final raw = response['data'] as List;
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .where((post) => post.id > 0)
        .toList();
  }

  static Future<Post> createPost({
    required int userId,
    required PostType type,
    required String title,
    required String description,
    required String location,
    String? imageUrl,
  }) async {
    final response = await ApiService.post('/posts', {
      'user_id': userId,
      'type': type.apiValue,
      'title': title,
      'description': description,
      'location': location,
      'image_url': imageUrl,
    });

    if (response is! Map || response['post'] is! Map<String, dynamic>) {
      throw const ApiException(
        'Postingan berhasil dikirim, tetapi respons server tidak valid.',
      );
    }

    return Post.fromJson(response['post'] as Map<String, dynamic>);
  }

  static Future<void> deletePost({
    required int postId,
    required int userId,
  }) async {
    await ApiService.delete('/posts/$postId', data: {'user_id': userId});
  }
}
