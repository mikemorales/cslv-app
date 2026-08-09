class SeoRankingPage {
  const SeoRankingPage({
    required this.id,
    required this.title,
    required this.url,
    required this.group,
    required this.targetKeyword,
    required this.clicks,
    required this.impressions,
    required this.position,
    required this.lastSeoChangeAt,
  });

  final int id;
  final String title;
  final String url;
  final String group;
  final String? targetKeyword;
  final int clicks;
  final int impressions;
  final double? position;
  final DateTime? lastSeoChangeAt;

  factory SeoRankingPage.fromJson(
    Map<String, dynamic> json, {
    required String group,
  }) {
    return SeoRankingPage(
      id: _asInt(json['id']),
      title: json['title']?.toString() ?? json['url']?.toString() ?? 'Untitled',
      url: json['url']?.toString() ?? '',
      group: group,
      targetKeyword: _nullableString(json['target_keyword']),
      clicks: _asInt(json['clicks']),
      impressions: _asInt(json['impressions']),
      position: _asDouble(json['position']),
      lastSeoChangeAt: DateTime.tryParse(
        json['last_seo_change_at']?.toString() ?? '',
      ),
    );
  }
}

class SeoRankingDashboard {
  const SeoRankingDashboard({
    required this.clusterPages,
    required this.villaPages,
  });

  final List<SeoRankingPage> clusterPages;
  final List<SeoRankingPage> villaPages;

  factory SeoRankingDashboard.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final strategy = _asMap(data['strategy']);
    final clusters = (strategy['browse_by_clusters'] as List?) ?? const [];
    final clusterPages = <SeoRankingPage>[];

    for (final rawCluster in clusters) {
      final cluster = _asMap(rawCluster);
      final label = cluster['label']?.toString() ?? 'Cluster';
      final urls = (cluster['urls'] as List?) ?? const [];
      clusterPages.addAll(
        urls.map((item) => SeoRankingPage.fromJson(_asMap(item), group: label)),
      );
    }

    final villas = (strategy['villa_pages'] as List?) ?? const [];

    return SeoRankingDashboard(
      clusterPages: clusterPages,
      villaPages: villas
          .map((item) => SeoRankingPage.fromJson(_asMap(item), group: 'Villas'))
          .toList(),
    );
  }
}

class SeoTimelinePoint {
  const SeoTimelinePoint({required this.date, required this.position});

  final DateTime date;
  final double? position;

  factory SeoTimelinePoint.fromJson(Map<String, dynamic> json) {
    return SeoTimelinePoint(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime(1970),
      position: _asDouble(json['position']),
    );
  }
}

class SeoTimelineChange {
  const SeoTimelineChange({
    required this.version,
    required this.appliedAt,
    required this.targetKeyword,
    required this.secondaryKeywords,
    required this.changedFields,
    required this.title,
    required this.h1,
  });

  final int version;
  final DateTime appliedAt;
  final String? targetKeyword;
  final List<String> secondaryKeywords;
  final List<String> changedFields;
  final String? title;
  final String? h1;

  factory SeoTimelineChange.fromJson(Map<String, dynamic> json) {
    return SeoTimelineChange(
      version: _asInt(json['version_number']),
      appliedAt:
          DateTime.tryParse(json['applied_at']?.toString() ?? '') ??
          DateTime(1970),
      targetKeyword: _nullableString(json['target_keyword']),
      secondaryKeywords: _stringList(json['secondary_keywords']),
      changedFields: _stringList(json['changed_fields']),
      title: _nullableString(json['title']),
      h1: _nullableString(json['h1']),
    );
  }
}

class SeoTimelineSummary {
  const SeoTimelineSummary({
    required this.position,
    required this.clicks,
    required this.impressions,
  });

  final double? position;
  final int clicks;
  final int impressions;

  factory SeoTimelineSummary.fromJson(Map<String, dynamic> json) {
    return SeoTimelineSummary(
      position: _asDouble(json['position']),
      clicks: _asInt(json['clicks']),
      impressions: _asInt(json['impressions']),
    );
  }
}

class SeoRankingTimeline {
  const SeoRankingTimeline({
    required this.comparisonWindowDays,
    required this.points,
    required this.changes,
    required this.current,
    required this.previous,
  });

  final int comparisonWindowDays;
  final List<SeoTimelinePoint> points;
  final List<SeoTimelineChange> changes;
  final SeoTimelineSummary current;
  final SeoTimelineSummary previous;

  factory SeoRankingTimeline.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final summary = _asMap(data['summary']);

    return SeoRankingTimeline(
      comparisonWindowDays: _asInt(data['comparison_window_days']),
      points: ((data['series'] as List?) ?? const [])
          .map((item) => SeoTimelinePoint.fromJson(_asMap(item)))
          .toList(),
      changes: ((data['seo_changes'] as List?) ?? const [])
          .map((item) => SeoTimelineChange.fromJson(_asMap(item)))
          .toList(),
      current: SeoTimelineSummary.fromJson(_asMap(summary['current'])),
      previous: SeoTimelineSummary.fromJson(_asMap(summary['previous'])),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? _nullableString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

List<String> _stringList(dynamic value) {
  return value is List
      ? value
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList()
      : const [];
}
