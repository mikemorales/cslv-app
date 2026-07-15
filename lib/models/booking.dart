/// Booking/Payment Model
///
/// Represents a booking with payment information
library;

import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return fallback;
    return int.tryParse(normalized) ??
        double.tryParse(normalized)?.toInt() ??
        fallback;
  }
  return fallback;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return fallback;
    return double.tryParse(normalized) ?? fallback;
  }
  return fallback;
}

double _asCurrencyFromCents(dynamic value) {
  if (value == null) return 0;

  if (value is int) {
    return value / 100;
  }

  if (value is double) {
    return value;
  }

  if (value is num) {
    final normalized = value.toDouble();
    if (normalized % 1 != 0) {
      return normalized;
    }

    return normalized / 100;
  }

  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return 0;

    if (normalized.contains('.')) {
      return double.tryParse(normalized) ?? 0;
    }

    final parsedInt = int.tryParse(normalized);
    if (parsedInt != null) {
      return parsedInt / 100;
    }

    return double.tryParse(normalized) ?? 0;
  }

  return 0;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return _asDouble(value);
}

double? _asNullableCurrencyFromCents(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  return _asCurrencyFromCents(value);
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final normalized = value.toString();
  return normalized.isEmpty ? null : normalized;
}

@JsonSerializable()
class Booking {
  @JsonKey(fromJson: _asInt)
  final int id;
  @JsonKey(name: 'guest_name', fromJson: _asString)
  final String guestName;
  @JsonKey(name: 'guest_email', fromJson: _asString)
  final String guestEmail;
  @JsonKey(name: 'guest_phone', fromJson: _asNullableString)
  final String? guestPhone;
  @JsonKey(name: 'check_in_date', fromJson: _asString)
  final String checkInDate;
  @JsonKey(name: 'check_out_date', fromJson: _asString)
  final String checkOutDate;
  @JsonKey(name: 'total_nights', fromJson: _asInt)
  final int totalNights;
  @JsonKey(name: 'guest_count', fromJson: _asInt)
  final int guestCount;
  @JsonKey(name: 'total_amount', fromJson: _asCurrencyFromCents)
  final double totalAmount;
  @JsonKey(name: 'special_requests', fromJson: _asNullableString)
  final String? specialRequests;
  @JsonKey(fromJson: _asString)
  final String status;

  // Payment schedule fields
  @JsonKey(name: 'payment_rule', fromJson: _asString)
  final String paymentRule;
  @JsonKey(name: 'deposit_amount', fromJson: _asNullableCurrencyFromCents)
  final double? depositAmount;
  @JsonKey(name: 'balance_amount', fromJson: _asNullableCurrencyFromCents)
  final double? balanceAmount;
  @JsonKey(name: 'balance_due_date', fromJson: _asNullableString)
  final String? balanceDueDate;
  @JsonKey(name: 'balance_paid_at', fromJson: _asNullableString)
  final String? balancePaidAt;
  @JsonKey(name: 'balance_status', fromJson: _asNullableString)
  final String? balanceStatus;

  // Timestamps
  @JsonKey(name: 'created_at', fromJson: _asString)
  final String createdAt;
  @JsonKey(name: 'expires_at', fromJson: _asString)
  final String expiresAt;
  @JsonKey(name: 'authorized_at', fromJson: _asNullableString)
  final String? authorizedAt;
  @JsonKey(name: 'captured_at', fromJson: _asNullableString)
  final String? capturedAt;
  @JsonKey(name: 'cancelled_at', fromJson: _asNullableString)
  final String? cancelledAt;

  @JsonKey(name: 'payment_environment', fromJson: _asString)
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
  @JsonKey(fromJson: _asInt)
  final int id;
  @JsonKey(fromJson: _asString)
  final String title;
  @JsonKey(fromJson: _asString)
  final String location;

  Villa({required this.id, required this.title, required this.location});

  factory Villa.fromJson(Map<String, dynamic> json) => _$VillaFromJson(json);

  Map<String, dynamic> toJson() => _$VillaToJson(this);
}

@JsonSerializable()
class PaymentStats {
  @JsonKey(fromJson: _asInt)
  final int pending;
  @JsonKey(fromJson: _asInt)
  final int confirmed;
  @JsonKey(fromJson: _asInt)
  final int expired;
  @JsonKey(fromJson: _asInt)
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
  @JsonKey(fromJson: _asInt)
  final int total;
  @JsonKey(name: 'per_page', fromJson: _asInt)
  final int perPage;
  @JsonKey(name: 'current_page', fromJson: _asInt)
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
