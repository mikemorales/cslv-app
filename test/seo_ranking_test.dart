import 'package:cslv_app/models/seo_ranking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard parses cluster and villa ranking tables', () {
    final dashboard = SeoRankingDashboard.fromJson({
      'data': {
        'strategy': {
          'browse_by_clusters': [
            {
              'label': 'Browse by Area',
              'urls': [
                {
                  'id': 1,
                  'title': 'Palmilla',
                  'url': 'https://cabosanlucasvillas.net/palmilla',
                  'position': 8.4,
                  'impressions': 100,
                  'clicks': 5,
                },
              ],
            },
          ],
          'villa_pages': [
            {
              'id': 2,
              'title': 'Villa Pacifica',
              'url': 'https://cabosanlucasvillas.net/villa-pacifica',
              'position': 12.2,
              'impressions': 50,
              'clicks': 2,
            },
          ],
        },
      },
    });

    expect(dashboard.clusterPages.single.group, 'Browse by Area');
    expect(dashboard.clusterPages.single.position, 8.4);
    expect(dashboard.villaPages.single.title, 'Villa Pacifica');
    expect(dashboard.villaPages.single.group, 'Villas');
  });

  test('timeline parses positions and SEO change markers', () {
    final timeline = SeoRankingTimeline.fromJson({
      'data': {
        'comparison_window_days': 28,
        'series': [
          {'date': '2026-08-01', 'position': 10.5},
        ],
        'seo_changes': [
          {
            'version_number': 2,
            'applied_at': '2026-08-01T12:00:00Z',
            'target_keyword': 'luxury villas cabo',
            'secondary_keywords': ['cabo villa rentals'],
            'changed_fields': ['title', 'target_keyword'],
          },
        ],
        'summary': {
          'current': {'position': 10.5, 'clicks': 4, 'impressions': 80},
          'previous': {'position': 12.0, 'clicks': 2, 'impressions': 60},
        },
      },
    });

    expect(timeline.points.single.position, 10.5);
    expect(timeline.changes.single.version, 2);
    expect(timeline.changes.single.changedFields, ['title', 'target_keyword']);
    expect(timeline.current.impressions, 80);
  });
}
