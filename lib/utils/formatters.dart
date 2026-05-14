library;

import 'package:intl/intl.dart';

class AppFormatters {
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
  );

  static String date(String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }

    try {
      return _dateFormat.format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  static String currency(num? value) {
    if (value == null) {
      return '-';
    }

    return _currencyFormat.format(value);
  }
}
