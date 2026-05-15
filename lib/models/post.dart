/// Post Model
///
/// Represents a blog post in the system
library;

import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return fallback;
    return int.tryParse(normalized) ??
        double.tryParse(normalized)?.toInt() ??
        fallback;
  }
  return fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return _asInt(value);
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString();
  return normalized.isEmpty ? null : normalized;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return fallback;
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

@JsonSerializable()
class Post {
  @JsonKey(fromJson: _asInt)
  final int id;
  @JsonKey(fromJson: _asString)
  final String title;
  @JsonKey(fromJson: _asString)
  final String slug;
  @JsonKey(fromJson: _asNullableString)
  final String? excerpt;
  @JsonKey(fromJson: _asNullableString)
  final String? content;
  @JsonKey(fromJson: _asString)
  final String status;
  @JsonKey(name: 'featured_image', fromJson: _asNullableString)
  final String? featuredImage;
  @JsonKey(name: 'featured_image_url', fromJson: _asNullableString)
  final String? featuredImageUrl;
  @JsonKey(name: 'author_id', fromJson: _asNullableInt)
  final int? authorId;
  final List<Category>? categories;
  final List<Tag>? tags;
  final List<PostImage>? images;
  @JsonKey(name: 'published_at', fromJson: _asNullableString)
  final String? publishedAt;
  @JsonKey(name: 'created_at', fromJson: _asNullableString)
  final String? createdAt;
  @JsonKey(name: 'updated_at', fromJson: _asNullableString)
  final String? updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.content,
    required this.status,
    this.featuredImage,
    this.featuredImageUrl,
    this.authorId,
    this.categories,
    this.tags,
    this.images,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  Post copyWith({
    int? id,
    String? title,
    String? slug,
    String? excerpt,
    String? content,
    String? status,
    String? featuredImage,
    String? featuredImageUrl,
    int? authorId,
    List<Category>? categories,
    List<Tag>? tags,
    List<PostImage>? images,
    String? publishedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      excerpt: excerpt ?? this.excerpt,
      content: content ?? this.content,
      status: status ?? this.status,
      featuredImage: featuredImage ?? this.featuredImage,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      authorId: authorId ?? this.authorId,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class PostImage {
  @JsonKey(fromJson: _asInt)
  final int id;
  @JsonKey(name: 'image_path', fromJson: _asString)
  final String imagePath;
  @JsonKey(name: 'sort_order', fromJson: _asNullableInt)
  final int? sortOrder;
  @JsonKey(name: 'is_featured', fromJson: _asBool)
  final bool isFeatured;

  PostImage({
    required this.id,
    required this.imagePath,
    this.sortOrder,
    required this.isFeatured,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) =>
      _$PostImageFromJson(json);

  Map<String, dynamic> toJson() => _$PostImageToJson(this);
}

@JsonSerializable()
class Category {
  @JsonKey(fromJson: _asInt)
  final int id;
  @JsonKey(fromJson: _asString)
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Tag {
  @JsonKey(fromJson: _asInt)
  final int id;
  @JsonKey(fromJson: _asString)
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable()
class PaginatedPosts {
  final List<Post> data;
  final PaginationMeta meta;

  PaginatedPosts({required this.data, required this.meta});

  factory PaginatedPosts.fromJson(Map<String, dynamic> json) =>
      _$PaginatedPostsFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedPostsToJson(this);
}

@JsonSerializable()
class PaginationMeta {
  @JsonKey(name: 'current_page', fromJson: _asInt)
  final int currentPage;
  @JsonKey(name: 'last_page', fromJson: _asInt)
  final int lastPage;
  @JsonKey(name: 'per_page', fromJson: _asInt)
  final int perPage;
  @JsonKey(fromJson: _asInt)
  final int total;
  @JsonKey(fromJson: _asInt)
  final int from;
  @JsonKey(fromJson: _asInt)
  final int to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);
}
