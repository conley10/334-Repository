import 'package:flutter/material.dart';
import 'payment_page.dart';
import 'app_state.dart';

class PaymentMethodsPage extends StatefulWidget {
  final Booking booking;

  const PaymentMethodsPage({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String selectedMethod = 'Visa •••• 4242';

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        title: const Text(
          'Payment Method',
          style: TextStyle(fontWeight: FontWeight.w800, color: primaryBlue),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _PaymentCard(
                title: 'Visa •••• 4242',
                subtitle: 'Expires 08/28',
                icon: Icons.credit_card,
                selected: selectedMethod == 'Visa •••• 4242',
                onTap: () => setState(() => selectedMethod = 'Visa •••• 4242'),
              ),
              const SizedBox(height: 14),
              _PaymentCard(
                title: 'Mastercard •••• 8891',
                subtitle: 'Expires 11/27',
                icon: Icons.credit_card,
                selected: selectedMethod == 'Mastercard •••• 8891',
                onTap: () =>
                    setState(() => selectedMethod = 'Mastercard •••• 8891'),
              ),
              const SizedBox(height: 14),
              _PaymentCard(
                title: 'Campus Wallet',
                subtitle: 'Balance: \$18.20',
                icon: Icons.account_balance_wallet_outlined,
                selected: selectedMethod == 'Campus Wallet',
                onTap: () => setState(() => selectedMethod = 'Campus Wallet'),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add New Payment Method'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(
                          booking: Booking(
                            zone: widget.booking.zone,
                            vehicle: widget.booking.vehicle,
                            hours: widget.booking.hours,
                            rate: widget.booking.rate,
                            paymentMethod: selectedMethod,
                            paidAt: DateTime.now(),
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue to Payment',
                    style: TextStyle(fontWeight: FontWeight.w800),
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

class _PaymentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? primaryBlue : const Color(0xFFE6E8EF),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF8B8E99), fontSize: 13)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? primaryBlue : const Color(0xFFB0B3BD),
            ),
          ],
        ),
      ),
    );
  }
}