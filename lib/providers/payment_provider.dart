library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/booking.dart';
import '../services/payment_service.dart';

class PaymentState {
  final bool isLoading;
  final String? errorMessage;
  final List<Booking> items;
  final PaymentStats stats;
  final int currentPage;
  final int total;
  final String status;

  const PaymentState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
    this.stats = const PaymentStats(
      pending: 0,
      confirmed: 0,
      expired: 0,
      cancelled: 0,
    ),
    this.currentPage = 1,
    this.total = 0,
    this.status = 'pending_payment',
  });

  PaymentState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Booking>? items,
    PaymentStats? stats,
    int? currentPage,
    int? total,
    String? status,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      stats: stats ?? this.stats,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  Timer? _timer;

  Future<void> load({int page = 1, String? status}) async {
    final selectedStatus = status ?? state.status;
    state = state.copyWith(
      isLoading: true,
      status: selectedStatus,
      clearError: true,
    );

    try {
      final (bookings, stats) = await paymentService.getPendingPayments(
        page: page,
        perPage: ApiConfig.paymentsPerPage,
        status: selectedStatus,
      );

      state = state.copyWith(
        isLoading: false,
        items: bookings.data,
        stats: stats,
        currentPage: bookings.currentPage,
        total: bookings.total,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: ApiConfig.paymentAutoRefreshInterval),
      (_) => load(page: state.currentPage, status: state.status),
    );
  }

  void stopAutoRefresh() {
    _timer?.cancel();
  }

  Future<void> capture(int bookingId) async {
    await paymentService.capturePayment(bookingId);
    await load(page: state.currentPage, status: state.status);
  }

  Future<void> cancel(int bookingId, String reason) async {
    await paymentService.cancelPayment(bookingId, reason: reason);
    await load(page: state.currentPage, status: state.status);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(),
);
