import '../models/post.dart';

enum PostFilter {
  all,
  lost,
  found;

  String get label {
    return switch (this) {
      PostFilter.all => 'Semua',
      PostFilter.lost => 'Kehilangan',
      PostFilter.found => 'Ditemukan',
    };
  }
}

List<Post> filterPosts(
  Iterable<Post> posts, {
  String query = '',
  PostFilter filter = PostFilter.all,
  int? ownerId,
}) {
  final needle = query.trim().toLowerCase();

  return posts.where((post) {
    if (ownerId != null && post.userId != ownerId) return false;
    if (filter == PostFilter.lost && post.type != PostType.lost) return false;
    if (filter == PostFilter.found && post.type != PostType.found) return false;
    if (needle.isEmpty) return true;

    return post.title.toLowerCase().contains(needle) ||
        post.description.toLowerCase().contains(needle) ||
        post.location.toLowerCase().contains(needle);
  }).toList();
}

int countPosts(Iterable<Post> posts, PostFilter filter, {int? ownerId}) {
  return filterPosts(posts, filter: filter, ownerId: ownerId).length;
}
