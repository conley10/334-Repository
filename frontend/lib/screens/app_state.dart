class Booking {
  final String zone;
  final String vehicle;
  final int hours;
  final double rate;
  final String paymentMethod;
  final DateTime paidAt;

  const Booking({
    required this.zone,
    required this.vehicle,
    required this.hours,
    required this.rate,
    required this.paymentMethod,
    required this.paidAt,
  });

  double get total => hours * rate;

  String get totalText => '\$${total.toStringAsFixed(2)}';

  String get durationText => "$hours ${hours == 1 ? 'hour' : 'hours'}";

  String get dateText => 'Today';

  String get timeText {
    final end = paidAt.add(Duration(hours: hours));
    return '${_formatTime(paidAt)} - ${_formatTime(end)}';
  }

  static String _formatTime(DateTime value) {
    final hour12 = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $suffix';
  }
}

class AppState {
  static final List<Booking> paidBookings = <Booking>[
    Booking(
      zone: 'Zone A',
      vehicle: 'ABC 123',
      hours: 2,
      rate: 4.50,
      paymentMethod: 'Visa •••• 4242',
      paidAt: DateTime(2026, 4, 30, 9),
    ),
  ];

  static void addPaidBooking(Booking booking) {
    paidBookings.insert(0, booking);
  }
}
