class Comment {
  const Comment({
    required this.id,
    this.postId,
    this.userId,
    required this.content,
    this.authorName,
    this.createdAt,
  });

  final int id;
  final int? postId;
  final int? userId;
  final String content;
  final String? authorName;
  final DateTime? createdAt;

  String get authorLabel {
    final name = authorName?.trim();
    return (name == null || name.isEmpty) ? 'Anonim' : name;
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: _asInt(json['id']) ?? 0,
      postId: _asInt(json['post_id']),
      userId: _asInt(json['user_id']),
      content: json['content']?.toString().trim() ?? '',
      authorName: _asString(json['author_name']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
