import 'package:cslv_app/models/clarity_campaign_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('campaign report parses summaries and recording links', () {
    final report = ClarityCampaignReport.fromJson({
      'data': {
        'days': 3,
        'campaigns': [
          {
            'campaign': 'summer-villas',
            'source': 'facebook',
            'url': 'https://cabosanlucasvillas.net/villas',
            'total_sessions': 12,
            'pages_per_session': 1.2,
          },
        ],
        'recording_summary': [
          {
            'campaign': 'summer-villas',
            'source': 'facebook',
            'medium': 'cpc',
            'entry_url': 'https://cabosanlucasvillas.net/villas',
            'session_count': 2,
            'average_duration_seconds': 1.5,
            'average_click_count': 0,
            'average_page_count': 1,
          },
        ],
        'recordings': [
          {
            'id': 1,
            'recording_url': 'https://clarity.microsoft.com/session/123',
            'campaign': 'summer-villas',
            'source': 'facebook',
            'medium': 'cpc',
            'referrer_url': 'https://facebook.com',
            'entry_url': 'https://cabosanlucasvillas.net/villas',
            'exit_url': 'https://cabosanlucasvillas.net/villas',
            'duration_seconds': 1,
            'click_count': 0,
            'page_count': 1,
          },
        ],
        'pagination': {'current_page': 1, 'last_page': 1, 'total': 1},
        'can_import': true,
      },
    });

    expect(report.days, 3);
    expect(report.campaigns.single.totalSessions, 12);
    expect(report.recordingSummary.single.averageDurationSeconds, 1.5);
    expect(
      report.recordings.single.recordingUrl,
      'https://clarity.microsoft.com/session/123',
    );
    expect(report.canImport, isTrue);
  });
}
