class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? parentId;
  final String body;
  final List<Comment> replies;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.parentId,
    required this.body,
    required this.replies,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        parentId: json['parent_id'] as String?,
        body: json['body'] as String,
        replies: (json['replies'] as List? ?? [])
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Comment copyWith({List<Comment>? replies}) => Comment(
        id: id,
        userId: userId,
        userName: userName,
        parentId: parentId,
        body: body,
        replies: replies ?? this.replies,
        createdAt: createdAt,
      );
}
