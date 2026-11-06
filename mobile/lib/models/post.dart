enum PostType {
  lost,
  found;

  static PostType fromApi(Object? value) {
    return value?.toString().toUpperCase() == 'FOUND'
        ? PostType.found
        : PostType.lost;
  }

  String get apiValue => this == PostType.found ? 'FOUND' : 'LOST';

  String get label => this == PostType.found ? 'Ditemukan' : 'Kehilangan';
}

class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    this.imageUrl,
    this.authorName,
    this.createdAt,
  });

  final int id;
  final int? userId;
  final PostType type;
  final String title;
  final String description;
  final String location;
  final String? imageUrl;
  final String? authorName;
  final DateTime? createdAt;

  bool isOwnedBy(int? currentUserId) {
    return currentUserId != null && userId == currentUserId;
  }

  String get authorLabel {
    final name = authorName?.trim();
    return (name == null || name.isEmpty) ? 'Anonim' : name;
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['user_id']),
      type: PostType.fromApi(json['type']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      location: _asString(json['location']),
      imageUrl: _asNullableString(json['image_url']),
      authorName: _asNullableString(json['author_name']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _asString(Object? value) => value?.toString().trim() ?? '';

  static String? _asNullableString(Object? value) {
    final text = _asString(value);
    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
