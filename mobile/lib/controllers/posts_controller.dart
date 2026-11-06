import 'package:flutter/foundation.dart';

import '../api/api_post.dart';
import '../api/services.dart';
import '../models/post.dart';

class PostsController extends ChangeNotifier {
  final List<Post> _posts = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  bool _disposed = false;

  List<Post> get posts => List.unmodifiable(_posts);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  Future<void> refresh() async {
    if (_isRefreshing) return;

    final firstLoad = _posts.isEmpty;
    if (firstLoad) _isLoading = true;
    _isRefreshing = true;
    _error = null;
    _notify();

    try {
      final fetched = await ApiPost.getPosts();
      _posts
        ..clear()
        ..addAll(fetched);
      _error = null;
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Gagal memuat postingan. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      _notify();
    }
  }

  void clearLocalState() {
    _posts.clear();
    _error = null;
    _isLoading = false;
    _isRefreshing = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
