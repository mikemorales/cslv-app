library;

import '../config/api_config.dart';
import '../models/booking.dart';
import 'base_service.dart';

class PaymentService extends BaseService {
  Future<(PaginatedBookings, PaymentStats)> getPendingPayments({
    int page = 1,
    int perPage = 20,
    String status = 'pending_payment',
  }) async {
    final response = await get(
      ApiConfig.pendingPayments,
      queryParameters: {'page': page, 'per_page': perPage, 'status': status},
    );

    final bookings = PaginatedBookings.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
    final stats = response['stats'] != null
        ? PaymentStats.fromJson(
            Map<String, dynamic>.from(response['stats'] as Map),
          )
        : PaymentStats(pending: 0, confirmed: 0, expired: 0, cancelled: 0);

    return (bookings, stats);
  }

  Future<Booking> capturePayment(int bookingId) async {
    final response = await post(ApiConfig.capturePayment(bookingId));
    return Booking.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<Booking> cancelPayment(int bookingId, {required String reason}) async {
    final response = await post(
      ApiConfig.cancelPayment(bookingId),
      data: {'reason': reason},
    );
    return Booking.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }

  Future<Booking> recapturePayment(int bookingId) async {
    final response = await post(ApiConfig.recapturePayment(bookingId));
    return Booking.fromJson(Map<String, dynamic>.from(response['data'] as Map));
  }
}

final paymentService = PaymentService();
