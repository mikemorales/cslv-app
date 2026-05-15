/// Villa Model
///
/// Represents a villa/property in the system
library;

import 'package:json_annotation/json_annotation.dart';

part 'villa.g.dart';

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

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return fallback;
    return double.tryParse(normalized) ?? fallback;
  }
  return fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return _asDouble(value);
}

@JsonSerializable()
class Villa {
  @JsonKey(fromJson: _asInt)
  final int id;
  final String title;
  final String slug;
  @JsonKey(name: 'link')
  final String? permalink;
  final String? content;
  final String? excerpt;
  final String status;
  @JsonKey(name: 'featured_image')
  final String? featuredImage;
  @JsonKey(name: 'featured_image_url')
  final String? featuredImageUrl;
  @JsonKey(fromJson: _asDouble)
  final double price;
  @JsonKey(fromJson: _asInt)
  final int bathrooms;
  @JsonKey(fromJson: _asInt)
  final int bedrooms;
  @JsonKey(fromJson: _asInt)
  final int sleeps;
  @JsonKey(fromJson: _asNullableDouble)
  final double? sqft;
  final String? view;
  @JsonKey(fromJson: _asNullableDouble)
  final double? longitude;
  @JsonKey(fromJson: _asNullableDouble)
  final double? latitude;
  @JsonKey(name: 'ical_url')
  final String? icalUrl;
  @JsonKey(name: 'taxes_and_fees', fromJson: _asNullableDouble)
  final double? taxesAndFees;
  @JsonKey(name: 'damage_waiver', fromJson: _asNullableDouble)
  final double? damageWaiver;
  @JsonKey(name: 'accommodation_taxes_fees', fromJson: _asNullableDouble)
  final double? accommodationTaxesFees;
  @JsonKey(name: 'hoa_fee', fromJson: _asNullableDouble)
  final double? hoaFee;
  @JsonKey(name: 'category_id', fromJson: _asInt)
  final int categoryId;
  final Category? category;
  final List<Tag>? tags;
  final List<VillaImage>? images;
  @JsonKey(name: 'rate_status')
  final String? rateStatus;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  Villa({
    required this.id,
    required this.title,
    required this.slug,
    this.permalink,
    this.content,
    this.excerpt,
    required this.status,
    this.featuredImage,
    this.featuredImageUrl,
    required this.price,
    required this.bathrooms,
    required this.bedrooms,
    required this.sleeps,
    this.sqft,
    this.view,
    this.longitude,
    this.latitude,
    this.icalUrl,
    this.taxesAndFees,
    this.damageWaiver,
    this.accommodationTaxesFees,
    this.hoaFee,
    required this.categoryId,
    this.category,
    this.tags,
    this.images,
    this.rateStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory Villa.fromJson(Map<String, dynamic> json) => _$VillaFromJson(json);

  Map<String, dynamic> toJson() => _$VillaToJson(this);

  /// Create a copy of Villa with modifications
  Villa copyWith({
    int? id,
    String? title,
    String? slug,
    String? permalink,
    String? content,
    String? excerpt,
    String? status,
    String? featuredImage,
    String? featuredImageUrl,
    double? price,
    int? bathrooms,
    int? bedrooms,
    int? sleeps,
    double? sqft,
    String? view,
    double? longitude,
    double? latitude,
    String? icalUrl,
    double? taxesAndFees,
    double? damageWaiver,
    double? accommodationTaxesFees,
    double? hoaFee,
    int? categoryId,
    Category? category,
    List<Tag>? tags,
    List<VillaImage>? images,
    String? rateStatus,
    String? createdAt,
    String? updatedAt,
  }) {
    return Villa(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      permalink: permalink ?? this.permalink,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      status: status ?? this.status,
      featuredImage: featuredImage ?? this.featuredImage,
      featuredImageUrl: featuredImageUrl ?? this.featuredImageUrl,
      price: price ?? this.price,
      bathrooms: bathrooms ?? this.bathrooms,
      bedrooms: bedrooms ?? this.bedrooms,
      sleeps: sleeps ?? this.sleeps,
      sqft: sqft ?? this.sqft,
      view: view ?? this.view,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      icalUrl: icalUrl ?? this.icalUrl,
      taxesAndFees: taxesAndFees ?? this.taxesAndFees,
      damageWaiver: damageWaiver ?? this.damageWaiver,
      accommodationTaxesFees:
          accommodationTaxesFees ?? this.accommodationTaxesFees,
      hoaFee: hoaFee ?? this.hoaFee,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      rateStatus: rateStatus ?? this.rateStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class VillaImage {
  @JsonKey(fromJson: _asInt)
  final int id;
  @JsonKey(name: 'dropbox_url_image')
  final String? dropboxUrlImage;
  @JsonKey(name: 'sort_order', fromJson: _asNullableInt)
  final int? sortOrder;
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;

  VillaImage({
    required this.id,
    this.dropboxUrlImage,
    this.sortOrder,
    this.isFeatured,
  });

  factory VillaImage.fromJson(Map<String, dynamic> json) =>
      _$VillaImageFromJson(json);

  Map<String, dynamic> toJson() => _$VillaImageToJson(this);
}

@JsonSerializable()
class Category {
  @JsonKey(fromJson: _asInt)
  final int id;
  final String name;
  @JsonKey(name: 'full_path')
  final String? fullPath;

  Category({required this.id, required this.name, this.fullPath});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Tag {
  @JsonKey(fromJson: _asInt)
  final int id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}

@JsonSerializable()
class SeasonalRate {
  @JsonKey(fromJson: _asNullableInt)
  final int? id;
  final String season;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  @JsonKey(fromJson: _asDouble)
  final double rate;
  @JsonKey(name: 'weekend_rate', fromJson: _asNullableDouble)
  final double? weekendRate;

  SeasonalRate({
    this.id,
    required this.season,
    required this.startDate,
    required this.endDate,
    required this.rate,
    this.weekendRate,
  });

  factory SeasonalRate.fromJson(Map<String, dynamic> json) =>
      _$SeasonalRateFromJson(json);

  Map<String, dynamic> toJson() => _$SeasonalRateToJson(this);
}

@JsonSerializable()
class PaginatedVillas {
  final List<Villa> data;
  final PaginationMeta meta;

  PaginatedVillas({required this.data, required this.meta});

  factory PaginatedVillas.fromJson(Map<String, dynamic> json) =>
      _$PaginatedVillasFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedVillasToJson(this);
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
