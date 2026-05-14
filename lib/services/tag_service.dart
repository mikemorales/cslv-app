library;

import '../config/api_config.dart';
import 'base_service.dart';

class TagService extends BaseService {
  Future<List<Map<String, dynamic>>> getTags() async {
    final response = await get(
      ApiConfig.tags,
      queryParameters: {'per_page': 100},
    );

    final data = (response['data'] as List?) ?? const [];
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }
}

final tagService = TagService();
