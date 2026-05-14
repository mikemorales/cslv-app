// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: (json['id'] as num).toInt(),
  guestName: json['guest_name'] as String,
  guestEmail: json['guest_email'] as String,
  guestPhone: json['guest_phone'] as String?,
  checkInDate: json['check_in_date'] as String,
  checkOutDate: json['check_out_date'] as String,
  totalNights: (json['total_nights'] as num).toInt(),
  guestCount: (json['guest_count'] as num).toInt(),
  totalAmount: (json['total_amount'] as num).toDouble(),
  specialRequests: json['special_requests'] as String?,
  status: json['status'] as String,
  paymentRule: json['payment_rule'] as String,
  depositAmount: (json['deposit_amount'] as num?)?.toDouble(),
  balanceAmount: (json['balance_amount'] as num?)?.toDouble(),
  balanceDueDate: json['balance_due_date'] as String?,
  balancePaidAt: json['balance_paid_at'] as String?,
  balanceStatus: json['balance_status'] as String?,
  createdAt: json['created_at'] as String,
  expiresAt: json['expires_at'] as String,
  authorizedAt: json['authorized_at'] as String?,
  capturedAt: json['captured_at'] as String?,
  cancelledAt: json['cancelled_at'] as String?,
  paymentEnvironment: json['payment_environment'] as String,
  villa: Villa.fromJson(json['villa'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'guest_name': instance.guestName,
  'guest_email': instance.guestEmail,
  'guest_phone': instance.guestPhone,
  'check_in_date': instance.checkInDate,
  'check_out_date': instance.checkOutDate,
  'total_nights': instance.totalNights,
  'guest_count': instance.guestCount,
  'total_amount': instance.totalAmount,
  'special_requests': instance.specialRequests,
  'status': instance.status,
  'payment_rule': instance.paymentRule,
  'deposit_amount': instance.depositAmount,
  'balance_amount': instance.balanceAmount,
  'balance_due_date': instance.balanceDueDate,
  'balance_paid_at': instance.balancePaidAt,
  'balance_status': instance.balanceStatus,
  'created_at': instance.createdAt,
  'expires_at': instance.expiresAt,
  'authorized_at': instance.authorizedAt,
  'captured_at': instance.capturedAt,
  'cancelled_at': instance.cancelledAt,
  'payment_environment': instance.paymentEnvironment,
  'villa': instance.villa,
};

Villa _$VillaFromJson(Map<String, dynamic> json) => Villa(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  location: json['location'] as String,
);

Map<String, dynamic> _$VillaToJson(Villa instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'location': instance.location,
};

PaymentStats _$PaymentStatsFromJson(Map<String, dynamic> json) => PaymentStats(
  pending: (json['pending'] as num).toInt(),
  confirmed: (json['confirmed'] as num).toInt(),
  expired: (json['expired'] as num).toInt(),
  cancelled: (json['cancelled'] as num).toInt(),
);

Map<String, dynamic> _$PaymentStatsToJson(PaymentStats instance) =>
    <String, dynamic>{
      'pending': instance.pending,
      'confirmed': instance.confirmed,
      'expired': instance.expired,
      'cancelled': instance.cancelled,
    };

PaginatedBookings _$PaginatedBookingsFromJson(Map<String, dynamic> json) =>
    PaginatedBookings(
      data: (json['data'] as List<dynamic>)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      currentPage: (json['current_page'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedBookingsToJson(PaginatedBookings instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'per_page': instance.perPage,
      'current_page': instance.currentPage,
    };
