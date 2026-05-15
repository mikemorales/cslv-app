// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: _asInt(json['id']),
  guestName: _asString(json['guest_name']),
  guestEmail: _asString(json['guest_email']),
  guestPhone: _asNullableString(json['guest_phone']),
  checkInDate: _asString(json['check_in_date']),
  checkOutDate: _asString(json['check_out_date']),
  totalNights: _asInt(json['total_nights']),
  guestCount: _asInt(json['guest_count']),
  totalAmount: _asDouble(json['total_amount']),
  specialRequests: _asNullableString(json['special_requests']),
  status: _asString(json['status']),
  paymentRule: _asString(json['payment_rule']),
  depositAmount: _asNullableDouble(json['deposit_amount']),
  balanceAmount: _asNullableDouble(json['balance_amount']),
  balanceDueDate: _asNullableString(json['balance_due_date']),
  balancePaidAt: _asNullableString(json['balance_paid_at']),
  balanceStatus: _asNullableString(json['balance_status']),
  createdAt: _asString(json['created_at']),
  expiresAt: _asString(json['expires_at']),
  authorizedAt: _asNullableString(json['authorized_at']),
  capturedAt: _asNullableString(json['captured_at']),
  cancelledAt: _asNullableString(json['cancelled_at']),
  paymentEnvironment: _asString(json['payment_environment']),
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
  id: _asInt(json['id']),
  title: _asString(json['title']),
  location: _asString(json['location']),
);

Map<String, dynamic> _$VillaToJson(Villa instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'location': instance.location,
};

PaymentStats _$PaymentStatsFromJson(Map<String, dynamic> json) => PaymentStats(
  pending: _asInt(json['pending']),
  confirmed: _asInt(json['confirmed']),
  expired: _asInt(json['expired']),
  cancelled: _asInt(json['cancelled']),
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
      total: _asInt(json['total']),
      perPage: _asInt(json['per_page']),
      currentPage: _asInt(json['current_page']),
    );

Map<String, dynamic> _$PaginatedBookingsToJson(PaginatedBookings instance) =>
    <String, dynamic>{
      'data': instance.data,
      'total': instance.total,
      'per_page': instance.perPage,
      'current_page': instance.currentPage,
    };
