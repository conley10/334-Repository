import 'package:flutter/material.dart';
import 'app_state.dart';
import 'profile_page.dart';
import '../services/payment_service.dart';
import '../services/api_client.dart';

class PaymentPage extends StatefulWidget {
  final Booking booking;

  const PaymentPage({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  static const Map<String, String> _methodMap = {
    'Credit Card': 'card',
    'Card': 'card',
    'Apple Pay': 'ApplePay',
    'Google Pay': 'GooglePay',
    'PayPal': 'PayPal',
  };

  String _mapMethod(String displayName) {
    return _methodMap[displayName] ?? 'card';
  }

  Future<void> _handlePayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      await _paymentService.processPayment(
        bookingID: widget.booking.bookingID,
        method: _mapMethod(widget.booking.paymentMethod),
        amount: widget.booking.total,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful. Booking added to profile.'),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.statusCode) {
        case 402:
          message = 'Payment declined. Please try a different method.';
          break;
        case 401:
          message = 'Session expired. Please log in again.';
          break;
        case 400:
          message = 'Invalid payment details: ${e.message}';
          break;
        default:
          message = 'Payment failed: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.w800, color: primaryBlue),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.local_parking, color: primaryBlue, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      '${booking.zone} Parking',
                      style: const TextStyle(
                        color: primaryBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Today • ${booking.durationText}',
                      style: const TextStyle(color: Color(0xFF8B8E99)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SummaryCard(booking: booking),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Pay ${booking.totalText}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Booking booking;

  const _SummaryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          _Row(label: 'Parking zone', value: booking.zone),
          _Row(label: 'Vehicle', value: booking.vehicle),
          _Row(label: 'Duration', value: booking.durationText),
          _Row(label: 'Rate', value: '\$${booking.rate.toStringAsFixed(2)}/hr'),
          _Row(label: 'Payment method', value: booking.paymentMethod),
          const Divider(height: 28),
          _Row(label: 'Total', value: booking.totalText, isTotal: true),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _Row({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.black : const Color(0xFF8B8E99),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFF0D2E9B) : Colors.black87,
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}