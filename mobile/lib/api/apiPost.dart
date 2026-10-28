import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'services.dart';

class ApiPost {
  static Future<List<dynamic>> getPosts() async {
    try {
      final response = await ApiService.get('/posts');
      return response['data'] ?? [];
    } catch (e) {
      print('Error getPosts: $e');
      return [];
    }
  }

  static Future<String?> uploadImage(File image) async {
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload'));
      request.fields['upload_preset'] = 'YOUR_UPLOAD_PRESET';
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = Uri.decodeFull(res.body); // Placeholder for JSON parsing logic
        // ponytal: JSON parsing needed. Use standard library `jsonDecode`.
        return 'https://cloudinary.com/image.jpg'; 
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> createPost(
    String type,
    String title,
    String description,
    String location,
    String? imageUrl,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return false;

      await ApiService.post('/posts', {
        'user_id': userId,
        'type': type,
        'title': title,
        'description': description,
        'location': location,
        'image_url': imageUrl,
      });

      return true;
    } catch (e) {
      print('Error createPost: $e');
      return false;
    }
  }

  static Future<bool> deletePost(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) return false;

      await ApiService.delete('/posts/$postId', data: {'user_id': userId});
      return true;
    } catch (e) {
      print('Error deletePost: $e');
      return false;
    }
  }
}
