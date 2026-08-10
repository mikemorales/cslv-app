library;

class ClarityCampaignReport {
  const ClarityCampaignReport({
    required this.days,
    required this.campaigns,
    required this.recordingSummary,
    required this.recordings,
    required this.currentPage,
    required this.lastPage,
    required this.totalRecordings,
    required this.canImport,
    this.generatedAt,
    this.campaignsError,
  });

  final int days;
  final DateTime? generatedAt;
  final List<ClarityCampaignInsight> campaigns;
  final String? campaignsError;
  final List<ClarityCampaignSummary> recordingSummary;
  final List<ClarityRecording> recordings;
  final int currentPage;
  final int lastPage;
  final int totalRecordings;
  final bool canImport;

  factory ClarityCampaignReport.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? {});
    final pagination = Map<String, dynamic>.from(
      data['pagination'] as Map? ?? {},
    );

    return ClarityCampaignReport(
      days: _integer(data['days']) ?? 3,
      generatedAt: DateTime.tryParse(data['generated_at']?.toString() ?? ''),
      campaigns: _maps(
        data['campaigns'],
      ).map(ClarityCampaignInsight.fromJson).toList(),
      campaignsError: data['campaigns_error']?.toString(),
      recordingSummary: _maps(
        data['recording_summary'],
      ).map(ClarityCampaignSummary.fromJson).toList(),
      recordings: _maps(
        data['recordings'],
      ).map(ClarityRecording.fromJson).toList(),
      currentPage: _integer(pagination['current_page']) ?? 1,
      lastPage: _integer(pagination['last_page']) ?? 1,
      totalRecordings: _integer(pagination['total']) ?? 0,
      canImport: data['can_import'] == true,
    );
  }
}

class ClarityCampaignInsight {
  const ClarityCampaignInsight({
    required this.campaign,
    required this.source,
    required this.url,
    this.totalSessions,
    this.botSessions,
    this.distinctUsers,
    this.pagesPerSession,
  });

  final String campaign;
  final String source;
  final String url;
  final num? totalSessions;
  final num? botSessions;
  final num? distinctUsers;
  final num? pagesPerSession;

  factory ClarityCampaignInsight.fromJson(Map<String, dynamic> json) {
    return ClarityCampaignInsight(
      campaign: json['campaign']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      totalSessions: json['total_sessions'] as num?,
      botSessions: json['bot_sessions'] as num?,
      distinctUsers: json['distinct_users'] as num?,
      pagesPerSession: json['pages_per_session'] as num?,
    );
  }
}

class ClarityCampaignSummary {
  const ClarityCampaignSummary({
    required this.campaign,
    required this.source,
    required this.medium,
    required this.entryUrl,
    required this.sessionCount,
    this.averageDurationSeconds,
    this.averageClickCount,
    this.averagePageCount,
  });

  final String campaign;
  final String source;
  final String medium;
  final String entryUrl;
  final int sessionCount;
  final num? averageDurationSeconds;
  final num? averageClickCount;
  final num? averagePageCount;

  factory ClarityCampaignSummary.fromJson(Map<String, dynamic> json) {
    return ClarityCampaignSummary(
      campaign: json['campaign']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      medium: json['medium']?.toString() ?? '',
      entryUrl: json['entry_url']?.toString() ?? '',
      sessionCount: _integer(json['session_count']) ?? 0,
      averageDurationSeconds: json['average_duration_seconds'] as num?,
      averageClickCount: json['average_click_count'] as num?,
      averagePageCount: json['average_page_count'] as num?,
    );
  }
}

class ClarityRecording {
  const ClarityRecording({
    required this.id,
    required this.recordingUrl,
    required this.campaign,
    required this.source,
    required this.medium,
    required this.referrerUrl,
    required this.entryUrl,
    required this.exitUrl,
    this.sessionId,
    this.durationSeconds,
    this.clickCount,
    this.pageCount,
    this.recordedAt,
  });

  final int id;
  final String recordingUrl;
  final String? sessionId;
  final String campaign;
  final String source;
  final String medium;
  final String referrerUrl;
  final String entryUrl;
  final String exitUrl;
  final int? durationSeconds;
  final int? clickCount;
  final int? pageCount;
  final DateTime? recordedAt;

  factory ClarityRecording.fromJson(Map<String, dynamic> json) {
    return ClarityRecording(
      id: _integer(json['id']) ?? 0,
      recordingUrl: json['recording_url']?.toString() ?? '',
      sessionId: json['session_id']?.toString(),
      campaign: json['campaign']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      medium: json['medium']?.toString() ?? '',
      referrerUrl: json['referrer_url']?.toString() ?? '',
      entryUrl: json['entry_url']?.toString() ?? '',
      exitUrl: json['exit_url']?.toString() ?? '',
      durationSeconds: _integer(json['duration_seconds']),
      clickCount: _integer(json['click_count']),
      pageCount: _integer(json['page_count']),
      recordedAt: DateTime.tryParse(json['recorded_at']?.toString() ?? ''),
    );
  }
}

List<Map<String, dynamic>> _maps(dynamic value) {
  if (value is! List) return const [];

  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

int? _integer(dynamic value) {
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '');
}
