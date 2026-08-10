library;

import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/clarity_campaign_report.dart';
import 'base_service.dart';

class ClarityCampaignService extends BaseService {
  Future<ClarityCampaignReport> getReport({int days = 3, int page = 1}) async {
    final response = await get(
      ApiConfig.clarityCampaigns,
      queryParameters: {'days': days, 'page': page, 'per_page': 50},
    );

    return ClarityCampaignReport.fromJson(response);
  }

  Future<int> importRecordings(Uint8List bytes, String filename) async {
    final response = await post(
      ApiConfig.clarityImportRecordings,
      data: FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      }),
    );

    final data = Map<String, dynamic>.from(response['data'] as Map? ?? {});
    return (data['imported'] as num?)?.toInt() ?? 0;
  }
}

final clarityCampaignService = ClarityCampaignService();
