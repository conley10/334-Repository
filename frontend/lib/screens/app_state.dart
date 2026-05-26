import 'package:flutter/material.dart';

class AppState {
  static final List<Booking> paidBookings = [];
}

class Booking {
  final int? bookingID;
  final String zone;
  final String vehicle;
  final int hours;
  final double rate;
  final String paymentMethod;
  final DateTime paidAt;

  final DateTime? startTime;
  final DateTime? endTime;

  const Booking({
    this.bookingID,
    required this.zone,
    required this.vehicle,
    required this.hours,
    required this.rate,
    required this.paymentMethod,
    required this.paidAt,
    this.startTime,
    this.endTime,
  });

  double get total => hours * rate;

  String get totalText => '\$${total.toStringAsFixed(2)}';

  String get durationText => '$hours ${hours == 1 ? 'hour' : 'hours'}';

  DateTime get bookingStart => startTime ?? paidAt;

  DateTime get bookingEnd =>
      endTime ?? bookingStart.add(Duration(hours: hours));

  String get dateText {
    final now = DateTime.now();

    if (bookingStart.year == now.year &&
        bookingStart.month == now.month &&
        bookingStart.day == now.day) {
      return 'Today';
    }

    return '${bookingStart.day}/${bookingStart.month}/${bookingStart.year}';
  }

  String get timeText {
    final start = TimeOfDay.fromDateTime(bookingStart);
    final end = TimeOfDay.fromDateTime(bookingEnd);

    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }
}