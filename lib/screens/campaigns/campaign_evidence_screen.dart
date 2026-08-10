import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/clarity_campaign_report.dart';
import '../../services/clarity_campaign_service.dart';
import '../../widgets/state_views.dart';

class CampaignEvidenceScreen extends StatefulWidget {
  const CampaignEvidenceScreen({super.key});

  @override
  State<CampaignEvidenceScreen> createState() => _CampaignEvidenceScreenState();
}

class _CampaignEvidenceScreenState extends State<CampaignEvidenceScreen> {
  int _days = 3;
  int _page = 1;
  bool _isImporting = false;
  late Future<ClarityCampaignReport> _report;

  @override
  void initState() {
    super.initState();
    _report = clarityCampaignService.getReport(days: _days);
  }

  Future<void> _reload({int? page}) async {
    _page = page ?? _page;
    final report = clarityCampaignService.getReport(days: _days, page: _page);
    setState(() => _report = report);
    await report;
  }

  void _changeDays(int days) {
    if (days == _days) return;
    _days = days;
    _page = 1;
    setState(() {
      _report = clarityCampaignService.getReport(days: _days);
    });
  }

  Future<void> _importCsv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) {
      _message('The selected CSV could not be read.');
      return;
    }

    setState(() => _isImporting = true);
    try {
      final imported = await clarityCampaignService.importRecordings(
        bytes,
        file.name,
      );
      if (!mounted) return;
      _message('$imported Clarity recordings imported.');
      await _reload(page: 1);
    } catch (error) {
      if (mounted) _message(error.toString());
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ClarityCampaignReport>(
      future: _report,
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

        final report = snapshot.data!;
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Controls(
                days: _days,
                canImport: report.canImport,
                isImporting: _isImporting,
                onDaysChanged: _changeDays,
                onImport: _importCsv,
              ),
              const SizedBox(height: 12),
              const Text(
                'Evidence from campaign traffic: short sessions, low interaction, and direct links to Clarity recordings.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              if (report.campaignsError != null) ...[
                const SizedBox(height: 12),
                _WarningCard(message: report.campaignsError!),
              ],
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Recording evidence',
                count: report.recordingSummary.length,
              ),
              if (report.recordingSummary.isEmpty)
                const _EmptyCard(
                  message:
                      'Import the CSV downloaded from Clarity to calculate real duration and interaction by campaign.',
                )
              else
                ...report.recordingSummary.map(_CampaignSummaryCard.new),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Live campaign traffic (${report.days * 24} hours)',
                count: report.campaigns.length,
              ),
              if (report.campaigns.isEmpty)
                const _EmptyCard(
                  message: 'No automatic Clarity campaign data is available.',
                )
              else
                ...report.campaigns.map(_CampaignInsightCard.new),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Session recordings',
                count: report.totalRecordings,
              ),
              if (report.recordings.isEmpty)
                const _EmptyCard(message: 'No recordings have been imported.')
              else
                ...report.recordings.map(
                  (recording) => _RecordingCard(
                    recording: recording,
                    onOpen: () => _openRecording(recording.recordingUrl),
                  ),
                ),
              if (report.lastPage > 1)
                _Pagination(
                  currentPage: report.currentPage,
                  lastPage: report.lastPage,
                  onPage: (page) => _reload(page: page),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openRecording(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) _message('The Clarity recording could not be opened.');
    }
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.days,
    required this.canImport,
    required this.isImporting,
    required this.onDaysChanged,
    required this.onImport,
  });

  final int days;
  final bool canImport;
  final bool isImporting;
  final ValueChanged<int> onDaysChanged;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        DropdownButton<int>(
          value: days,
          items: const [
            DropdownMenuItem(value: 1, child: Text('Last 24 hours')),
            DropdownMenuItem(value: 2, child: Text('Last 48 hours')),
            DropdownMenuItem(value: 3, child: Text('Last 72 hours')),
          ],
          onChanged: (value) {
            if (value != null) onDaysChanged(value);
          },
        ),
        if (canImport)
          FilledButton.icon(
            onPressed: isImporting ? null : onImport,
            icon: isImporting
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_file),
            label: const Text('Import Clarity CSV'),
          ),
      ],
    );
  }
}

class _CampaignSummaryCard extends StatelessWidget {
  const _CampaignSummaryCard(this.summary);

  final ClarityCampaignSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fallback(summary.campaign, 'No campaign'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              [
                _fallback(summary.source, 'Direct'),
                summary.medium,
              ].where((value) => value.isNotEmpty).join(' / '),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            if (summary.entryUrl.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _shortUrl(summary.entryUrl),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip('${summary.sessionCount} sessions'),
                _MetricChip(
                  'Avg. ${_duration(summary.averageDurationSeconds)}',
                  alert: (summary.averageDurationSeconds ?? 999) < 10,
                ),
                _MetricChip(
                  '${_decimal(summary.averageClickCount)} avg. clicks',
                ),
                _MetricChip('${_decimal(summary.averagePageCount)} avg. pages'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignInsightCard extends StatelessWidget {
  const _CampaignInsightCard(this.insight);

  final ClarityCampaignInsight insight;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          _fallback(insight.campaign, 'No campaign'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${_fallback(insight.source, 'Direct')}\n${_shortUrl(insight.url)}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${insight.totalSessions ?? 0} sessions',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text('${_decimal(insight.pagesPerSession)} pages/session'),
          ],
        ),
      ),
    );
  }
}

class _RecordingCard extends StatelessWidget {
  const _RecordingCard({required this.recording, required this.onOpen});

  final ClarityRecording recording;
  final VoidCallback onOpen;

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
                    _fallback(recording.campaign, 'No campaign'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (recording.recordedAt != null)
                  Text(
                    DateFormat('MMM d, HH:mm').format(recording.recordedAt!),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            Text(
              _fallback(recording.source, 'Direct'),
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            if (recording.referrerUrl.isNotEmpty)
              Text('Referrer: ${_shortUrl(recording.referrerUrl)}'),
            if (recording.entryUrl.isNotEmpty)
              Text(
                'Journey: ${_shortUrl(recording.entryUrl)} → ${_shortUrl(recording.exitUrl)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  _duration(recording.durationSeconds),
                  alert: (recording.durationSeconds ?? 999) < 10,
                ),
                _MetricChip('${recording.clickCount ?? 0} clicks'),
                _MetricChip('${recording.pageCount ?? 0} pages'),
              ],
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Watch recording in Clarity'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip(this.label, {this.alert = false});

  final String label;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: alert ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: alert ? const Color(0xFF991B1B) : const Color(0xFF1E3A8A),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF7ED),
      child: Padding(padding: const EdgeInsets.all(12), child: Text(message)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.onPage,
  });

  final int currentPage;
  final int lastPage;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 1 ? () => onPage(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('$currentPage / $lastPage'),
        IconButton(
          onPressed: currentPage < lastPage
              ? () => onPage(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

String _fallback(String value, String fallback) =>
    value.trim().isEmpty ? fallback : value;

String _shortUrl(String value) {
  if (value.isEmpty) return 'Unknown URL';
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) return value;

  return '${uri.host}${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
}

String _duration(num? seconds) {
  if (seconds == null) return 'Unknown duration';
  final total = seconds.round();
  if (total < 60) return '${total}s';

  final minutes = total ~/ 60;
  final remaining = total % 60;
  return '${minutes}m ${remaining}s';
}

String _decimal(num? value) => value == null ? '0' : value.toStringAsFixed(1);
