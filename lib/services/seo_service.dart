import '../config/api_config.dart';
import '../models/seo_ranking.dart';
import 'base_service.dart';

class SeoService extends BaseService {
  Future<SeoRankingDashboard> getDashboard() async {
    final response = await get(
      ApiConfig.seoDashboard,
      headers: const {'X-Seo-Manager-Locale': 'en'},
    );

    return SeoRankingDashboard.fromJson(response);
  }

  Future<SeoRankingTimeline> getPerformanceTimeline(
    int pageId, {
    required int windowDays,
  }) async {
    final response = await get(
      ApiConfig.seoPerformanceTimeline(pageId),
      queryParameters: {'window': windowDays, 'comparison_window': 28},
      headers: const {'X-Seo-Manager-Locale': 'en'},
    );

    return SeoRankingTimeline.fromJson(response);
  }
}

final seoService = SeoService();
