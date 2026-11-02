import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrFormatterDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(double amount, {bool showDecimals = false}) {
    if (showDecimals && amount % 1 != 0) {
      return _inrFormatterDecimals.format(amount);
    }
    return _inrFormatter.format(amount);
  }

  static String formatDiscount(int discountPercentage) {
    return '$discountPercentage% OFF';
  }
}

