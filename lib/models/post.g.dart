// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  id: _asInt(json['id']),
  title: _asString(json['title']),
  slug: _asString(json['slug']),
  excerpt: _asNullableString(json['excerpt']),
  content: _asNullableString(json['content']),
  status: _asString(json['status']),
  featuredImage: _asNullableString(json['featured_image']),
  featuredImageUrl: _asNullableString(json['featured_image_url']),
  authorId: _asNullableInt(json['author_id']),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => PostImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  publishedAt: _asNullableString(json['published_at']),
  createdAt: _asNullableString(json['created_at']),
  updatedAt: _asNullableString(json['updated_at']),
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
  id: _asInt(json['id']),
  imagePath: _asString(json['image_path']),
  sortOrder: _asNullableInt(json['sort_order']),
  isFeatured: _asBool(json['is_featured']),
);

Map<String, dynamic> _$PostImageToJson(PostImage instance) => <String, dynamic>{
  'id': instance.id,
  'image_path': instance.imagePath,
  'sort_order': instance.sortOrder,
  'is_featured': instance.isFeatured,
};

Category _$CategoryFromJson(Map<String, dynamic> json) =>
    Category(id: _asInt(json['id']), name: _asString(json['name']));

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

Tag _$TagFromJson(Map<String, dynamic> json) =>
    Tag(id: _asInt(json['id']), name: _asString(json['name']));

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
      currentPage: _asInt(json['current_page']),
      lastPage: _asInt(json['last_page']),
      perPage: _asInt(json['per_page']),
      total: _asInt(json['total']),
      from: _asInt(json['from']),
      to: _asInt(json['to']),
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
