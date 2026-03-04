import 'package:intl/intl.dart';

class Formatters {
  /// Format price in Indian Rupees: ₹45.00
  static String price(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Short price: ₹45
  static String priceShort(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  /// Format price with per-unit: ₹45.00/kg
  static String pricePerKg(double amount) {
    return '₹${amount.toStringAsFixed(2)}/kg';
  }

  /// Format percentage: +5.2% or -3.1%
  static String percentage(double value, {bool showSign = true}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  /// Format date as "Mar 4, 2026"
  static String date(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  /// Format date as "04 Mar"
  static String dateShort(DateTime dateTime) {
    return DateFormat('dd MMM').format(dateTime);
  }

  /// Format date as "Mon"
  static String dayOfWeek(DateTime dateTime) {
    return DateFormat('E').format(dateTime);
  }

  /// Format distance: "12.5 km"
  static String distance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  /// Format weight: "100 kg"
  static String weight(double kg) {
    if (kg >= 1000) {
      return '${(kg / 1000).toStringAsFixed(1)} tonnes';
    }
    return '${kg.toStringAsFixed(0)} kg';
  }

  /// Format confidence: "85.0%"
  static String confidence(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  /// Phone number formatting: +91 98765 43210
  static String phoneNumber(String phone) {
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }
}
