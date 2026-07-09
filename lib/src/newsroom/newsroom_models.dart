import '../core/json_value.dart';

enum NewsroomStatus {
  draft('draft'),
  scheduled('scheduled'),
  published('published');

  const NewsroomStatus(this.wire);
  final String wire;

  static NewsroomStatus? fromWire(String? value) {
    if (value == null) return null;
    for (final e in values) {
      if (e.wire == value) return e;
    }
    return null;
  }

  static NewsroomStatus parse(String value) =>
      fromWire(value) ?? (throw FormatException('Unknown status: $value'));
}

class NewsroomCategory {
  const NewsroomCategory({
    required this.id,
    this.slug,
    this.label,
    this.color,
    this.sortOrder,
    this.createdAt,
  });

  final String id;
  final String? slug;
  final String? label;
  final String? color;
  final int? sortOrder;
  final String? createdAt;

  factory NewsroomCategory.fromJson(Map<String, dynamic> json) {
    return NewsroomCategory(
      id: json['id'] as String,
      slug: json['slug'] as String?,
      label: json['label'] as String?,
      color: json['color'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );
  }
}

class NewsroomPost {
  const NewsroomPost({
    required this.id,
    required this.slug,
    required this.title,
    required this.categoryId,
    required this.status,
    this.tags,
    this.excerpt,
    this.body,
    this.heroImageUrl,
    this.createdBy,
    this.publishedAt,
    this.scheduledFor,
    this.createdAt,
    this.updatedAt,
    this.document,
  });

  final String id;
  final String slug;
  final String title;
  final String categoryId;
  final List<String>? tags;
  final String? excerpt;
  final String? body;
  final NewsroomStatus status;
  final String? heroImageUrl;
  final String? createdBy;
  final String? publishedAt;
  final String? scheduledFor;
  final String? createdAt;
  final String? updatedAt;
  final JsonValue? document;

  factory NewsroomPost.fromJson(Map<String, dynamic> json) {
    return NewsroomPost(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      categoryId: json['categoryId'] as String,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(growable: false),
      excerpt: json['excerpt'] as String?,
      body: json['body'] as String?,
      status: NewsroomStatus.parse(json['status'] as String),
      heroImageUrl: json['heroImageUrl'] as String?,
      createdBy: json['createdBy'] as String?,
      publishedAt: json['publishedAt'] as String?,
      scheduledFor: json['scheduledFor'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      document: json['document'] == null
          ? null
          : JsonValue.fromJson(json['document']),
    );
  }
}

class CreateNewsroomPostRequest {
  const CreateNewsroomPostRequest({
    required this.title,
    required this.categoryId,
    this.slug,
    this.body,
    this.excerpt,
    this.tags,
    this.heroImageUrl,
    this.status,
    this.scheduledFor,
  });

  final String title;
  final String categoryId;
  final String? slug;
  final String? body;
  final String? excerpt;
  final List<String>? tags;
  final String? heroImageUrl;
  final NewsroomStatus? status;
  final String? scheduledFor;

  Map<String, dynamic> toJson() => {
        'title': title,
        'categoryId': categoryId,
        if (slug != null) 'slug': slug,
        if (body != null) 'body': body,
        if (excerpt != null) 'excerpt': excerpt,
        if (tags != null) 'tags': tags,
        if (heroImageUrl != null) 'heroImageUrl': heroImageUrl,
        if (status != null) 'status': status!.wire,
        if (scheduledFor != null) 'scheduledFor': scheduledFor,
      };
}

class UpdateNewsroomPostRequest {
  const UpdateNewsroomPostRequest({
    this.title,
    this.categoryId,
    this.slug,
    this.body,
    this.excerpt,
    this.tags,
    this.heroImageUrl,
    this.status,
    this.scheduledFor,
  });

  final String? title;
  final String? categoryId;
  final String? slug;
  final String? body;
  final String? excerpt;
  final List<String>? tags;
  final String? heroImageUrl;
  final NewsroomStatus? status;
  final String? scheduledFor;

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (categoryId != null) 'categoryId': categoryId,
        if (slug != null) 'slug': slug,
        if (body != null) 'body': body,
        if (excerpt != null) 'excerpt': excerpt,
        if (tags != null) 'tags': tags,
        if (heroImageUrl != null) 'heroImageUrl': heroImageUrl,
        if (status != null) 'status': status!.wire,
        if (scheduledFor != null) 'scheduledFor': scheduledFor,
      };
}
