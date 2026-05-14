// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'villa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Villa _$VillaFromJson(Map<String, dynamic> json) => Villa(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  slug: json['slug'] as String,
  permalink: json['link'] as String?,
  content: json['content'] as String?,
  excerpt: json['excerpt'] as String?,
  status: json['status'] as String,
  featuredImage: json['featured_image'] as String?,
  featuredImageUrl: json['featured_image_url'] as String?,
  price: (json['price'] as num).toDouble(),
  bathrooms: (json['bathrooms'] as num).toInt(),
  bedrooms: (json['bedrooms'] as num).toInt(),
  sleeps: (json['sleeps'] as num).toInt(),
  sqft: (json['sqft'] as num?)?.toDouble(),
  view: json['view'] as String?,
  longitude: (json['longitude'] as num?)?.toDouble(),
  latitude: (json['latitude'] as num?)?.toDouble(),
  icalUrl: json['ical_url'] as String?,
  taxesAndFees: (json['taxes_and_fees'] as num?)?.toDouble(),
  damageWaiver: (json['damage_waiver'] as num?)?.toDouble(),
  accommodationTaxesFees: (json['accommodation_taxes_fees'] as num?)
      ?.toDouble(),
  hoaFee: (json['hoa_fee'] as num?)?.toDouble(),
  categoryId: (json['category_id'] as num).toInt(),
  category: json['category'] == null
      ? null
      : Category.fromJson(json['category'] as Map<String, dynamic>),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => VillaImage.fromJson(e as Map<String, dynamic>))
      .toList(),
  rateStatus: json['rate_status'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$VillaToJson(Villa instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
  'link': instance.permalink,
  'content': instance.content,
  'excerpt': instance.excerpt,
  'status': instance.status,
  'featured_image': instance.featuredImage,
  'featured_image_url': instance.featuredImageUrl,
  'price': instance.price,
  'bathrooms': instance.bathrooms,
  'bedrooms': instance.bedrooms,
  'sleeps': instance.sleeps,
  'sqft': instance.sqft,
  'view': instance.view,
  'longitude': instance.longitude,
  'latitude': instance.latitude,
  'ical_url': instance.icalUrl,
  'taxes_and_fees': instance.taxesAndFees,
  'damage_waiver': instance.damageWaiver,
  'accommodation_taxes_fees': instance.accommodationTaxesFees,
  'hoa_fee': instance.hoaFee,
  'category_id': instance.categoryId,
  'category': instance.category,
  'tags': instance.tags,
  'images': instance.images,
  'rate_status': instance.rateStatus,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};

VillaImage _$VillaImageFromJson(Map<String, dynamic> json) => VillaImage(
  id: (json['id'] as num).toInt(),
  dropboxUrlImage: json['dropbox_url_image'] as String?,
  sortOrder: (json['sort_order'] as num?)?.toInt(),
  isFeatured: json['is_featured'] as bool?,
);

Map<String, dynamic> _$VillaImageToJson(VillaImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dropbox_url_image': instance.dropboxUrlImage,
      'sort_order': instance.sortOrder,
      'is_featured': instance.isFeatured,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  fullPath: json['full_path'] as String?,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'full_path': instance.fullPath,
};

Tag _$TagFromJson(Map<String, dynamic> json) =>
    Tag(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

SeasonalRate _$SeasonalRateFromJson(Map<String, dynamic> json) => SeasonalRate(
  id: (json['id'] as num?)?.toInt(),
  season: json['season'] as String,
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  rate: (json['rate'] as num).toDouble(),
  weekendRate: (json['weekend_rate'] as num?)?.toDouble(),
);

Map<String, dynamic> _$SeasonalRateToJson(SeasonalRate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'season': instance.season,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'rate': instance.rate,
      'weekend_rate': instance.weekendRate,
    };

PaginatedVillas _$PaginatedVillasFromJson(Map<String, dynamic> json) =>
    PaginatedVillas(
      data: (json['data'] as List<dynamic>)
          .map((e) => Villa.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaginatedVillasToJson(PaginatedVillas instance) =>
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
