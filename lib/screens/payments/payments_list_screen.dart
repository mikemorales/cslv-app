import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/payment_provider.dart';
import '../../utils/app_feedback.dart';
import '../../utils/formatters.dart';
import '../../widgets/pagination_bar.dart';
import '../../widgets/state_views.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(paymentProvider.notifier).load();
      ref.read(paymentProvider.notifier).startAutoRefresh();
    });
  }

  @override
  void dispose() {
    ref.read(paymentProvider.notifier).stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                label: 'Pending',
                value: state.stats.pending.toString(),
              ),
              _StatChip(
                label: 'Confirmed',
                value: state.stats.confirmed.toString(),
              ),
              _StatChip(
                label: 'Expired',
                value: state.stats.expired.toString(),
              ),
              _StatChip(
                label: 'Cancelled',
                value: state.stats.cancelled.toString(),
              ),
            ],
          ),
        ),
        Expanded(child: _buildContent(state)),
      ],
    );
  }

  Widget _buildContent(PaymentState state) {
    final lastPage = ((state.total / 20).ceil()).clamp(1, 999999).toInt();

    if (state.isLoading && state.items.isEmpty) {
      return const ListSkeletonView();
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return ErrorView(
        message: state.errorMessage!,
        onRetry: () => ref.read(paymentProvider.notifier).load(),
      );
    }

    if (state.items.isEmpty) {
      return const EmptyView(message: 'No pending payments found.');
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final booking = state.items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.guestName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('${booking.guestEmail} • ${booking.villa.title}'),
                      const SizedBox(height: 8),
                      Text(
                        '${AppFormatters.currency(booking.totalAmount)} • ${AppFormatters.date(booking.checkInDate)} - ${AppFormatters.date(booking.checkOutDate)}',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => _openDetails(booking),
                            child: const Text('Details'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => _capture(booking.id),
                            child: const Text('Capture'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _cancel(booking.id),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        PaginationBar(
          currentPage: state.currentPage,
          lastPage: lastPage,
          total: state.total,
          onPageChanged: (page) {
            ref
                .read(paymentProvider.notifier)
                .load(page: page, status: state.status);
          },
        ),
      ],
    );
  }

  Future<void> _capture(int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Capture payment'),
          content: const Text('Do you want to capture this payment now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(paymentProvider.notifier).capture(bookingId);
      if (mounted) {
        AppFeedback.success(context, 'Payment captured successfully.');
      }
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    }
  }

  Future<void> _cancel(int bookingId) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel booking'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (reason == null || reason.isEmpty) {
      return;
    }

    try {
      await ref.read(paymentProvider.notifier).cancel(bookingId, reason);
      if (mounted) {
        AppFeedback.success(context, 'Booking cancelled successfully.');
      }
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (isError) {
      AppFeedback.error(context, message);
      return;
    }

    AppFeedback.info(context, message);
  }

  Future<void> _openDetails(dynamic booking) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    booking.guestName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'Email', value: booking.guestEmail),
                  _DetailRow(label: 'Phone', value: booking.guestPhone ?? '-'),
                  _DetailRow(label: 'Villa', value: booking.villa.title),
                  _DetailRow(
                    label: 'Dates',
                    value:
                        '${AppFormatters.date(booking.checkInDate)} - ${AppFormatters.date(booking.checkOutDate)}',
                  ),
                  _DetailRow(
                    label: 'Amount',
                    value: AppFormatters.currency(booking.totalAmount),
                  ),
                  _DetailRow(label: 'Status', value: booking.status),
                  _DetailRow(
                    label: 'Environment',
                    value: booking.paymentEnvironment,
                  ),
                  _DetailRow(
                    label: 'Authorized At',
                    value: AppFormatters.date(booking.authorizedAt),
                  ),
                  _DetailRow(
                    label: 'Expires At',
                    value: AppFormatters.date(booking.expiresAt),
                  ),
                  _DetailRow(
                    label: 'Special Requests',
                    value: booking.specialRequests ?? '-',
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
