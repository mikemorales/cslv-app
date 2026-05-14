library;

import '../config/api_config.dart';
import '../models/administrator.dart';
import 'base_service.dart';

class AdministratorService extends BaseService {
  Future<PaginatedAdministrators> getAdministrators({
    int page = 1,
    int perPage = 15,
    String search = '',
  }) async {
    final response = await get(
      ApiConfig.administrators,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search.isNotEmpty) 'search': search,
      },
    );

    return PaginatedAdministrators.fromJson(response);
  }

  Future<Administrator> getAdministrator(int id) async {
    final response = await get(ApiConfig.administratorById(id));
    return Administrator.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<Administrator> createAdministrator(Map<String, dynamic> data) async {
    final response = await post(ApiConfig.administrators, data: data);
    return Administrator.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<Administrator> updateAdministrator(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await put(ApiConfig.administratorById(id), data: data);
    return Administrator.fromJson(
      Map<String, dynamic>.from(response['data']['entity'] as Map),
    );
  }

  Future<void> deleteAdministrator(int id) async {
    await delete(ApiConfig.administratorById(id));
  }
}

final administratorService = AdministratorService();
