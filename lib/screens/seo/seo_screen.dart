import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../models/seo_ranking.dart';
import '../../services/seo_service.dart';
import '../../widgets/state_views.dart';

class SeoScreen extends StatefulWidget {
  const SeoScreen({super.key});

  @override
  State<SeoScreen> createState() => _SeoScreenState();
}

class _SeoScreenState extends State<SeoScreen> {
  late Future<SeoRankingDashboard> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = seoService.getDashboard();
  }

  Future<void> _reload() async {
    final dashboard = seoService.getDashboard();
    setState(() => _dashboard = dashboard);
    await dashboard;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SeoRankingDashboard>(
      future: _dashboard,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const ListSkeletonView();
        }

        if (snapshot.hasError && !snapshot.hasData) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: _reload,
          );
        }

        final dashboard = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Tap any row to open its ranking history and logged SEO changes.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              _RankingTable(
                title: 'Ranking History & SEO Changes CLUSTERS',
                pages: dashboard.clusterPages,
                emptyMessage: 'No tracked cluster URLs are available yet.',
              ),
              const SizedBox(height: 16),
              _RankingTable(
                title: 'Ranking History & SEO Changes VILLAS',
                pages: dashboard.villaPages,
                emptyMessage: 'No tracked villa URLs are available yet.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RankingTable extends StatelessWidget {
  const _RankingTable({
    required this.title,
    required this.pages,
    required this.emptyMessage,
  });

  final String title;
  final List<SeoRankingPage> pages;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${pages.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          if (pages.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(emptyMessage),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF1F5F9),
                ),
                columns: const [
                  DataColumn(label: Text('Route')),
                  DataColumn(label: Text('Group')),
                  DataColumn(label: Text('Target keyword')),
                  DataColumn(label: Text('Avg. position'), numeric: true),
                  DataColumn(label: Text('Visibility'), numeric: true),
                  DataColumn(label: Text('Last SEO change')),
                ],
                rows: pages
                    .map(
                      (page) => DataRow(
                        onSelectChanged: (_) => _openTimeline(context, page),
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 210,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    page.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _pathFromUrl(page.url),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(page.group)),
                          DataCell(
                            SizedBox(
                              width: 180,
                              child: Text(
                                page.targetKeyword ?? 'No target keyword',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(_position(page.position))),
                          DataCell(
                            Text(
                              '${page.impressions} imp.\n${page.clicks} clicks',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          DataCell(
                            Text(
                              page.lastSeoChangeAt == null
                                  ? 'No change logged'
                                  : _date(page.lastSeoChangeAt!),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _openTimeline(BuildContext context, SeoRankingPage page) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _TimelineSheet(page: page),
    );
  }
}

class _TimelineSheet extends StatefulWidget {
  const _TimelineSheet({required this.page});

  final SeoRankingPage page;

  @override
  State<_TimelineSheet> createState() => _TimelineSheetState();
}

class _TimelineSheetState extends State<_TimelineSheet> {
  int _windowDays = 90;
  late Future<SeoRankingTimeline> _timeline;

  @override
  void initState() {
    super.initState();
    _timeline = _load();
  }

  Future<SeoRankingTimeline> _load() {
    return seoService.getPerformanceTimeline(
      widget.page.id,
      windowDays: _windowDays,
    );
  }

  void _changeWindow(int days) {
    if (_windowDays == days) return;
    setState(() {
      _windowDays = days;
      _timeline = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.page.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _pathFromUrl(widget.page.url),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final days in const [90, 180, 365])
                    ChoiceChip(
                      label: Text(
                        days == 365 ? '12 months' : '${days ~/ 30} months',
                      ),
                      selected: _windowDays == days,
                      onSelected: (_) => _changeWindow(days),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<SeoRankingTimeline>(
              future: _timeline,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return ErrorView(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() => _timeline = _load()),
                  );
                }

                return _TimelineContent(timeline: snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({required this.timeline});

  final SeoRankingTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final currentPosition = timeline.current.position;
    final previousPosition = timeline.previous.position;
    final movement = currentPosition != null && previousPosition != null
        ? previousPosition - currentPosition
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryCard(
                label: 'Current avg. position',
                value: _position(currentPosition),
              ),
              _SummaryCard(
                label: 'Vs. previous 28 days',
                value: _movement(movement),
              ),
              _SummaryCard(
                label: 'Visibility',
                value:
                    '${timeline.current.impressions} imp. / ${timeline.current.clicks} clicks',
              ),
              _SummaryCard(
                label: 'SEO changes',
                value: timeline.changes.length.toString(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Average Google position',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Position 1 is at the top. Orange markers indicate logged SEO changes.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            height: 250,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _RankingChart(
              points: timeline.points,
              changes: timeline.changes,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'SEO changes marked on the chart',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Markers show timing around an SEO edit; they do not prove that the edit alone caused the ranking movement.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (timeline.changes.isEmpty)
            const Text('No SEO changes were logged during this period.')
          else
            for (final change in timeline.changes)
              _SeoChangeCard(change: change),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SeoChangeCard extends StatelessWidget {
  const _SeoChangeCard({required this.change});

  final SeoTimelineChange change;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'SEO version ${change.version}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(_date(change.appliedAt)),
              ],
            ),
            const SizedBox(height: 10),
            _ChangeField(
              label: 'Target keyword',
              value: change.targetKeyword ?? 'N/A',
            ),
            _ChangeField(
              label: 'Secondary keywords',
              value: change.secondaryKeywords.isEmpty
                  ? 'N/A'
                  : change.secondaryKeywords.join(', '),
            ),
            _ChangeField(
              label: 'Changed fields',
              value: change.changedFields.isEmpty
                  ? 'N/A'
                  : change.changedFields.join(', '),
            ),
            _ChangeField(
              label: 'Title / H1',
              value:
                  [
                    if (change.title != null) change.title!,
                    if (change.h1 != null) change.h1!,
                  ].join(' · ').isEmpty
                  ? 'N/A'
                  : [
                      if (change.title != null) change.title!,
                      if (change.h1 != null) change.h1!,
                    ].join(' · '),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangeField extends StatelessWidget {
  const _ChangeField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class _RankingChart extends StatelessWidget {
  const _RankingChart({required this.points, required this.changes});

  final List<SeoTimelinePoint> points;
  final List<SeoTimelineChange> changes;

  @override
  Widget build(BuildContext context) {
    final rankedPoints = points
        .where((point) => point.position != null)
        .toList();

    if (rankedPoints.isEmpty) {
      return const Center(
        child: Text('No ranking data is available for this period yet.'),
      );
    }

    return CustomPaint(
      painter: _RankingChartPainter(points: rankedPoints, changes: changes),
      child: const SizedBox.expand(),
    );
  }
}

class _RankingChartPainter extends CustomPainter {
  const _RankingChartPainter({required this.points, required this.changes});

  final List<SeoTimelinePoint> points;
  final List<SeoTimelineChange> changes;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0;
    const top = 12.0;
    const right = 8.0;
    const bottom = 28.0;
    final plotWidth = size.width - left - right;
    final plotHeight = size.height - top - bottom;
    final positions = points.map((point) => point.position!).toList();
    final minPosition = math.max(1, positions.reduce(math.min).floor() - 1);
    final maxPosition = math.max(
      minPosition + 1,
      positions.reduce(math.max).ceil() + 1,
    );
    final firstDate = points.first.date.millisecondsSinceEpoch;
    final lastDate = points.last.date.millisecondsSinceEpoch;
    final dateSpan = math.max(1, lastDate - firstDate);
    final positionSpan = maxPosition - minPosition;
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final markerPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 2;

    double xFor(DateTime date) {
      return left +
          ((date.millisecondsSinceEpoch - firstDate) / dateSpan) * plotWidth;
    }

    double yFor(double position) {
      return top + ((position - minPosition) / positionSpan) * plotHeight;
    }

    for (var index = 0; index < 5; index++) {
      final position = minPosition + (positionSpan * index / 4);
      final y = yFor(position);
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
      _paintLabel(canvas, position.toStringAsFixed(1), Offset(0, y - 7));
    }

    for (final change in changes) {
      final millis = change.appliedAt.millisecondsSinceEpoch;
      if (millis < firstDate || millis > lastDate) continue;
      final x = xFor(change.appliedAt);
      canvas.drawLine(Offset(x, top), Offset(x, top + plotHeight), markerPaint);
      canvas.drawCircle(Offset(x, top + 5), 4, markerPaint);
    }

    final path = Path();
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final offset = Offset(xFor(point.date), yFor(point.position!));
      if (index == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    canvas.drawPath(path, linePaint);

    _paintLabel(
      canvas,
      intl.DateFormat('MMM d').format(points.first.date),
      Offset(left, size.height - 18),
    );
    final lastLabel = intl.DateFormat('MMM d').format(points.last.date);
    _paintLabel(
      canvas,
      lastLabel,
      Offset(size.width - right, size.height - 18),
      alignRight: true,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset offset, {
    bool alignRight = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(alignRight ? offset.dx - painter.width : offset.dx, offset.dy),
    );
  }

  @override
  bool shouldRepaint(covariant _RankingChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.changes != changes;
  }
}

String _position(double? value) => value?.toStringAsFixed(2) ?? 'N/A';

String _movement(double? value) {
  if (value == null) return 'N/A';
  if (value.abs() < 0.01) return 'No meaningful change';
  return value > 0
      ? '${value.toStringAsFixed(2)} positions better'
      : '${value.abs().toStringAsFixed(2)} positions worse';
}

String _date(DateTime value) =>
    intl.DateFormat('yyyy-MM-dd').format(value.toLocal());

String _pathFromUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri?.path.isNotEmpty == true ? uri!.path : url;
}
