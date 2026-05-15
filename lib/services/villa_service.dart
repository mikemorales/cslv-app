library;

import '../config/api_config.dart';
import '../models/villa.dart';
import 'base_service.dart';

class VillaService extends BaseService {
  Future<PaginatedVillas> getVillas({
    int page = 1,
    int perPage = 15,
    String search = '',
  }) async {
    final response = await get(
      ApiConfig.villas,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search.isNotEmpty) 'search': search,
      },
    );

    return PaginatedVillas.fromJson(response);
  }

  Future<Villa> getVilla(int id) async {
    final response = await get(ApiConfig.villaById(id));
    return Villa.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<Villa> createVilla(Map<String, dynamic> data) async {
    final response = await post(ApiConfig.villas, data: data);
    return Villa.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<Villa> updateVilla(int id, Map<String, dynamic> data) async {
    final response = await put(ApiConfig.villaById(id), data: data);
    return Villa.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<void> deleteVilla(int id) async {
    await delete(ApiConfig.villaById(id));
  }

  Future<Map<String, dynamic>> generatePermalink({
    required String title,
    required int categoryId,
    int? villaId,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'category_id': categoryId,
    };
    if (villaId != null) {
      payload['villa_id'] = villaId;
    }

    return post(ApiConfig.villaGeneratePermalink, data: payload);
  }

  Future<bool> checkPermalink(String permalink, {int? villaId}) async {
    final payload = <String, dynamic>{'permalink': permalink};
    if (villaId != null) {
      payload['villa_id'] = villaId;
    }

    final response = await post(ApiConfig.villaCheckPermalink, data: payload);

    return response['available'] == true || response['unique'] == true;
  }

  Future<List<dynamic>> getDropboxGallery(int villaId) async {
    final response = await get(ApiConfig.villaDropboxGallery(villaId));
    if (response['data'] is List) {
      return (response['data'] as List?) ?? const [];
    }

    if (response['data'] is Map) {
      return [Map<String, dynamic>.from(response['data'] as Map)];
    }

    return const [];
  }

  Future<void> saveDropboxGallery(int villaId, List<String> imageIds) async {
    await post(
      ApiConfig.villaDropboxGallery(villaId),
      data: {'villa_id': villaId, 'images': imageIds},
    );
  }

  Future<List<SeasonalRate>> getSeasonalRates(int villaId) async {
    final response = await get(ApiConfig.villaSeasonalRates(villaId));
    final list = (response['data'] as List?) ?? const [];

    return list
        .map((item) => SeasonalRate.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveSeasonalRates(int villaId, List<SeasonalRate> rates) async {
    await post(
      ApiConfig.villaSeasonalRates(villaId),
      data: {'rates': rates.map((rate) => rate.toJson()).toList()},
    );
  }

  Future<void> setFeaturedImage(int villaId, int imageId) async {
    await post(
      ApiConfig.villaSetFeaturedImage(villaId),
      data: {'image_id': imageId},
    );
  }

  Future<List<Map<String, dynamic>>> getSeasonalRatesRaw(int villaId) async {
    final response = await get(ApiConfig.villaSeasonalRates(villaId));
    final list = (response['data'] as List?) ?? const [];

    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<void> saveSeasonalRatesRaw(
    int villaId,
    List<Map<String, dynamic>> rates,
  ) async {
    await post(ApiConfig.villaSeasonalRates(villaId), data: {'rates': rates});
  }

  Future<String?> getDropboxGalleryUrl(int villaId) async {
    final response = await get(ApiConfig.villaDropboxGallery(villaId));
    if (response['data'] is Map) {
      return response['data']['url_gallery']?.toString();
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> fetchDropboxImages(
    String dropboxUrl,
  ) async {
    final response = await post(
      ApiConfig.dropboxFetchImages,
      data: {'dropbox_url': dropboxUrl},
    );

    final images = (response['images'] as List?) ?? const [];
    return images
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> saveDropboxGalleryData(
    int villaId, {
    required String dropboxUrl,
    required List<Map<String, dynamic>> images,
    String? featuredImage,
  }) async {
    await post(
      ApiConfig.villaDropboxGallery(villaId),
      data: {
        'dropbox_url': dropboxUrl,
        'images': images,
        if (featuredImage != null && featuredImage.isNotEmpty)
          'featured_image': featuredImage,
      },
    );
  }
}

final villaService = VillaService();
