/// Booking/Payment Model
///
/// Represents a booking with payment information
library;

import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  final int id;
  @JsonKey(name: 'guest_name')
  final String guestName;
  @JsonKey(name: 'guest_email')
  final String guestEmail;
  @JsonKey(name: 'guest_phone')
  final String? guestPhone;
  @JsonKey(name: 'check_in_date')
  final String checkInDate;
  @JsonKey(name: 'check_out_date')
  final String checkOutDate;
  @JsonKey(name: 'total_nights')
  final int totalNights;
  @JsonKey(name: 'guest_count')
  final int guestCount;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'special_requests')
  final String? specialRequests;
  final String status;

  // Payment schedule fields
  @JsonKey(name: 'payment_rule')
  final String paymentRule;
  @JsonKey(name: 'deposit_amount')
  final double? depositAmount;
  @JsonKey(name: 'balance_amount')
  final double? balanceAmount;
  @JsonKey(name: 'balance_due_date')
  final String? balanceDueDate;
  @JsonKey(name: 'balance_paid_at')
  final String? balancePaidAt;
  @JsonKey(name: 'balance_status')
  final String? balanceStatus;

  // Timestamps
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'expires_at')
  final String expiresAt;
  @JsonKey(name: 'authorized_at')
  final String? authorizedAt;
  @JsonKey(name: 'captured_at')
  final String? capturedAt;
  @JsonKey(name: 'cancelled_at')
  final String? cancelledAt;

  @JsonKey(name: 'payment_environment')
  final String paymentEnvironment;

  // Relation
  final Villa villa;

  Booking({
    required this.id,
    required this.guestName,
    required this.guestEmail,
    this.guestPhone,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalNights,
    required this.guestCount,
    required this.totalAmount,
    this.specialRequests,
    required this.status,
    required this.paymentRule,
    this.depositAmount,
    this.balanceAmount,
    this.balanceDueDate,
    this.balancePaidAt,
    this.balanceStatus,
    required this.createdAt,
    required this.expiresAt,
    this.authorizedAt,
    this.capturedAt,
    this.cancelledAt,
    required this.paymentEnvironment,
    required this.villa,
  });

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);

  Booking copyWith({
    int? id,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? checkInDate,
    String? checkOutDate,
    int? totalNights,
    int? guestCount,
    double? totalAmount,
    String? specialRequests,
    String? status,
    String? paymentRule,
    double? depositAmount,
    double? balanceAmount,
    String? balanceDueDate,
    String? balancePaidAt,
    String? balanceStatus,
    String? createdAt,
    String? expiresAt,
    String? authorizedAt,
    String? capturedAt,
    String? cancelledAt,
    String? paymentEnvironment,
    Villa? villa,
  }) {
    return Booking(
      id: id ?? this.id,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      totalNights: totalNights ?? this.totalNights,
      guestCount: guestCount ?? this.guestCount,
      totalAmount: totalAmount ?? this.totalAmount,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      paymentRule: paymentRule ?? this.paymentRule,
      depositAmount: depositAmount ?? this.depositAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      balanceDueDate: balanceDueDate ?? this.balanceDueDate,
      balancePaidAt: balancePaidAt ?? this.balancePaidAt,
      balanceStatus: balanceStatus ?? this.balanceStatus,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      authorizedAt: authorizedAt ?? this.authorizedAt,
      capturedAt: capturedAt ?? this.capturedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      paymentEnvironment: paymentEnvironment ?? this.paymentEnvironment,
      villa: villa ?? this.villa,
    );
  }

  /// Check if booking has 50/50 payment scheme
  bool is50_50() => paymentRule == '50_50';

  /// Check if booking payment is pending
  bool isPending() => status == 'pending_payment';

  /// Check if booking is confirmed
  bool isConfirmed() => status == 'confirmed';

  /// Check if booking is expired
  bool isExpired() => status == 'expired';

  /// Check if balance payment is due soon (within 3 days)
  bool isBalanceDueSoon() {
    if (balanceDueDate == null) return false;
    final dueDate = DateTime.parse(balanceDueDate!);
    final now = DateTime.now();
    return dueDate.difference(now).inDays <= 3 && dueDate.isAfter(now);
  }
}

@JsonSerializable()
class Villa {
  final int id;
  final String title;
  final String location;

  Villa({required this.id, required this.title, required this.location});

  factory Villa.fromJson(Map<String, dynamic> json) => _$VillaFromJson(json);

  Map<String, dynamic> toJson() => _$VillaToJson(this);
}

@JsonSerializable()
class PaymentStats {
  final int pending;
  final int confirmed;
  final int expired;
  final int cancelled;

  const PaymentStats({
    required this.pending,
    required this.confirmed,
    required this.expired,
    required this.cancelled,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) =>
      _$PaymentStatsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentStatsToJson(this);
}

@JsonSerializable()
class PaginatedBookings {
  final List<Booking> data;
  final int total;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'current_page')
  final int currentPage;

  PaginatedBookings({
    required this.data,
    required this.total,
    required this.perPage,
    required this.currentPage,
  });

  factory PaginatedBookings.fromJson(Map<String, dynamic> json) =>
      _$PaginatedBookingsFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedBookingsToJson(this);
}
