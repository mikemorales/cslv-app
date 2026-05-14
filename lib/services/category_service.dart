library;

import '../config/api_config.dart';
import 'base_service.dart';

class CategoryService extends BaseService {
  Future<List<Map<String, dynamic>>> getFlatHierarchy({
    String type = 'villa',
  }) async {
    final response = await get(
      ApiConfig.categoriesFlatHierarchy,
      queryParameters: {'type': type},
    );

    final data = (response['data'] as List?) ?? const [];
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }
}

final categoryService = CategoryService();
