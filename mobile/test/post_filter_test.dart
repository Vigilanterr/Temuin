import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/post.dart';
import 'package:mobile/utils/post_filter.dart';

Post makePost({
  int id = 1,
  int? userId = 1,
  PostType type = PostType.lost,
  String title = 'Dompet',
  String description = 'Dompet hitam',
  String location = 'Kantin',
}) {
  return Post(
    id: id,
    userId: userId,
    type: type,
    title: title,
    description: description,
    location: location,
  );
}

void main() {
  group('filterPosts', () {
    test('returns all posts by default', () {
      final posts = [
        makePost(id: 1, type: PostType.lost, title: 'Sepeda'),
        makePost(id: 2, type: PostType.found, title: 'Dompet'),
      ];
      expect(filterPosts(posts), hasLength(2));
    });

    test('filters by type', () {
      final posts = [
        makePost(id: 1, type: PostType.lost, title: 'Sepeda'),
        makePost(id: 2, type: PostType.found, title: 'Dompet'),
      ];
      expect(filterPosts(posts, filter: PostFilter.lost), hasLength(1));
      expect(
        filterPosts(posts, filter: PostFilter.lost).single.title,
        'Sepeda',
      );
      expect(filterPosts(posts, filter: PostFilter.found), hasLength(1));
    });

    test('filters by query across title, description, and location', () {
      final posts = [
        makePost(title: 'Sepeda', description: 'merah', location: 'Halaman'),
        makePost(title: 'Dompet', description: 'biru', location: 'Kantin'),
      ];
      expect(filterPosts(posts, query: 'merah'), hasLength(1));
      expect(filterPosts(posts, query: 'merah').single.title, 'Sepeda');
      expect(filterPosts(posts, query: 'kantin'), hasLength(1));
      expect(filterPosts(posts, query: 'kantin').single.title, 'Dompet');
      expect(filterPosts(posts, query: 'sepeda'), hasLength(1));
      expect(filterPosts(posts, query: 'nope'), isEmpty);
    });

    test('filters by ownerId', () {
      final posts = [
        makePost(id: 1, userId: 1, title: 'A'),
        makePost(id: 2, userId: 2, title: 'B'),
      ];
      expect(filterPosts(posts, ownerId: 1), hasLength(1));
      expect(filterPosts(posts, ownerId: 1).single.title, 'A');
    });

    test('combines all filters', () {
      final posts = [
        makePost(
          id: 1,
          userId: 1,
          type: PostType.lost,
          title: 'Sepeda',
          location: 'Halaman',
        ),
        makePost(
          id: 2,
          userId: 2,
          type: PostType.found,
          title: 'Dompet',
          location: 'Kantin',
        ),
      ];
      expect(
        filterPosts(
          posts,
          query: 'sepeda',
          filter: PostFilter.lost,
          ownerId: 1,
        ),
        hasLength(1),
      );
      expect(
        filterPosts(
          posts,
          query: 'sepeda',
          filter: PostFilter.lost,
          ownerId: 2,
        ),
        isEmpty,
      );
    });
  });

  group('countPosts', () {
    test('counts by type', () {
      final posts = [
        makePost(id: 1, type: PostType.lost),
        makePost(id: 2, type: PostType.lost),
        makePost(id: 3, type: PostType.found),
      ];
      expect(countPosts(posts, PostFilter.all), 3);
      expect(countPosts(posts, PostFilter.lost), 2);
      expect(countPosts(posts, PostFilter.found), 1);
    });
  });
}
