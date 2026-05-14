/// Post Model
///
/// Represents a blog post in the system
library;

import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? content;
  final String status;
  @JsonKey(name: 'featured_image')
  final String? featuredImage;
  @JsonKey(name: 'featured_image_url')
  final String? featuredImageUrl;
  @JsonKey(name: 'author_id')
  final int? authorId;
  final List<Category>? categories;
  final List<Tag>? tags;
  final List<PostImage>? images;
  @JsonKey(name: 'published_at')
  final String? publishedAt;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
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
  final int id;
  @JsonKey(name: 'image_path')
  final String imagePath;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  PostImage({
    required this.id,
    required this.imagePath,
    required this.sortOrder,
    required this.isFeatured,
  });

  factory PostImage.fromJson(Map<String, dynamic> json) =>
      _$PostImageFromJson(json);

  Map<String, dynamic> toJson() => _$PostImageToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Tag {
  final int id;
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
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;
  final int from;
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
