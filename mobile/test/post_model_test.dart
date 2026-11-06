import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/post.dart';

void main() {
  group('Post.fromJson', () {
    test('parses a complete post response', () {
      final post = Post.fromJson({
        'id': 7,
        'user_id': 3,
        'type': 'FOUND',
        'title': 'Dompet hitam',
        'description': 'Ditemukan di kantin',
        'location': 'Kantin gedung A',
        'image_url': 'https://example.com/foto.jpg',
        'author_name': 'Rina',
        'created_at': '2026-11-01T08:15:00.000Z',
      });

      expect(post.id, 7);
      expect(post.userId, 3);
      expect(post.type, PostType.found);
      expect(post.title, 'Dompet hitam');
      expect(post.description, 'Ditemukan di kantin');
      expect(post.location, 'Kantin gedung A');
      expect(post.imageUrl, 'https://example.com/foto.jpg');
      expect(post.authorName, 'Rina');
      expect(post.createdAt, DateTime.utc(2026, 11, 1, 8, 15));
    });

    test('handles missing nullable fields safely', () {
      final post = Post.fromJson({
        'id': '12',
        'user_id': '4',
        'type': 'LOST',
        'title': 'Kunci',
        'description': '',
        'location': 'Lab',
        'image_url': null,
        'author_name': null,
      });

      expect(post.id, 12);
      expect(post.userId, 4);
      expect(post.type, PostType.lost);
      expect(post.imageUrl, isNull);
      expect(post.authorLabel, 'Anonim');
      expect(post.createdAt, isNull);
    });

    test('falls back to LOST for unknown type', () {
      final post = Post.fromJson({'type': 'UNKNOWN'});
      expect(post.type, PostType.lost);
    });

    test('detects ownership', () {
      final post = Post.fromJson({'id': 1, 'user_id': 9});
      expect(post.isOwnedBy(9), isTrue);
      expect(post.isOwnedBy(10), isFalse);
      expect(post.isOwnedBy(null), isFalse);
    });
  });

  group('PostType', () {
    test('maps API values', () {
      expect(PostType.fromApi('LOST'), PostType.lost);
      expect(PostType.fromApi('FOUND'), PostType.found);
      expect(PostType.fromApi(null), PostType.lost);
      expect(PostType.found.apiValue, 'FOUND');
      expect(PostType.lost.label, 'Kehilangan');
    });
  });
}
