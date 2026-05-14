// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
  excerpt: json['excerpt'] as String?,
  content: json['content'] as String?,
  status: json['status'] as String,
  featuredImage: json['featured_image'] as String?,
  featuredImageUrl: json['featured_image_url'] as String?,
  authorId: (json['author_id'] as num?)?.toInt(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => PostImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  publishedAt: json['published_at'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
  'excerpt': instance.excerpt,
  'content': instance.content,
  'status': instance.status,
  'featured_image': instance.featuredImage,
  'featured_image_url': instance.featuredImageUrl,
  'author_id': instance.authorId,
  'categories': instance.categories,
  'tags': instance.tags,
  'images': instance.images,
  'published_at': instance.publishedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

PostImage _$PostImageFromJson(Map<String, dynamic> json) => PostImage(
  id: (json['id'] as num).toInt(),
  imagePath: json['image_path'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
  isFeatured: json['is_featured'] as bool,
);

Map<String, dynamic> _$PostImageToJson(PostImage instance) => <String, dynamic>{
  'id': instance.id,
  'image_path': instance.imagePath,
  'sort_order': instance.sortOrder,
  'is_featured': instance.isFeatured,
};

Category _$CategoryFromJson(Map<String, dynamic> json) =>
    Category(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Tag _$TagFromJson(Map<String, dynamic> json) =>
    Tag(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

PaginatedPosts _$PaginatedPostsFromJson(Map<String, dynamic> json) =>
    PaginatedPosts(
      data: (json['data'] as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaginatedPostsToJson(PaginatedPosts instance) =>
    <String, dynamic>{'data': instance.data, 'meta': instance.meta};

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      currentPage: (json['current_page'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      from: (json['from'] as num).toInt(),
      to: (json['to'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
      'from': instance.from,
      'to': instance.to,
    };
