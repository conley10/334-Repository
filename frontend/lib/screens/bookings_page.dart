import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'payment_methods_page.dart';
import 'profile_page.dart';
import 'app_state.dart';
import '../services/booking_service.dart';
import '../models/booking.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String selectedZone = 'Zone A';
  String selectedVehicle = 'ABC 123';
  int selectedHours = 2;

  final BookingService _bookingService = BookingService();

  List<BookingModel> bookings = [];
  bool isLoadingBookings = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final loadedBookings = await _bookingService.getBookings();

    if (!mounted) return;

    setState(() {
      bookings = loadedBookings;
      isLoadingBookings = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
    const mutedText = Color(0xFF8B8E99);

    const hourlyRate = 4.50;
    final totalPrice = selectedHours * hourlyRate;

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book Parking',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Reserve a campus parking spot before you arrive.',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _SectionCard(
                      title: 'Parking Zone',
                      child: DropdownButtonFormField<String>(
                        value: selectedZone,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Zone A',
                            child: Text('Zone A - Main Campus'),
                          ),
                          DropdownMenuItem(
                            value: 'Zone B',
                            child: Text('Zone B - Library'),
                          ),
                          DropdownMenuItem(
                            value: 'Zone C',
                            child: Text('Zone C - Sports Centre'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedZone = value!);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Vehicle',
                      child: DropdownButtonFormField<String>(
                        value: selectedVehicle,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'ABC 123',
                            child: Text('ABC 123 - My Car'),
                          ),
                          DropdownMenuItem(
                            value: 'XYZ 789',
                            child: Text('XYZ 789 - Family Car'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedVehicle = value!);
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Duration',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _HourButton(
                                label: '-',
                                onTap: () {
                                  if (selectedHours > 1) {
                                    setState(() => selectedHours--);
                                  }
                                },
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    '$selectedHours hours',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                              _HourButton(
                                label: '+',
                                onTap: () {
                                  setState(() => selectedHours++);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '\$4.50 per hour',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Booking Summary',
                      child: Column(
                        children: [
                          _SummaryRow(label: 'Zone', value: selectedZone),
                          _SummaryRow(label: 'Vehicle', value: selectedVehicle),
                          _SummaryRow(
                            label: 'Duration',
                            value: '$selectedHours hours',
                          ),
                          const Divider(height: 28),
                          _SummaryRow(
                            label: 'Total',
                            value: '\$${totalPrice.toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodsPage(
                                booking: Booking(
                                  zone: selectedZone,
                                  vehicle: selectedVehicle,
                                  hours: selectedHours,
                                  rate: hourlyRate,
                                  paymentMethod: '',
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
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Previous Bookings',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (isLoadingBookings)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    if (!isLoadingBookings && bookings.isEmpty)
                      const _SectionCard(
                        title: 'No bookings yet',
                        child: Text(
                          'Your bookings will appear here once you make one.',
                        ),
                      ),

                    if (!isLoadingBookings)
                      ...bookings.map(
                        (booking) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SectionCard(
                            title: booking.zone,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vehicle: ${booking.vehicle}'),
                                const SizedBox(height: 6),
                                Text('Duration: ${booking.hours} hours'),
                                const SizedBox(height: 6),
                                Text(
                                  'Total: \$${booking.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const _BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0D2E9B),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _HourButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HourButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8ECFF),
          foregroundColor: const Color(0xFF0D2E9B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
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
              color: isTotal ? Colors.black87 : const Color(0xFF8B8E99),
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? const Color(0xFF0D2E9B) : Colors.black87,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration() {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF7F7FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const _BottomNavBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE8ECFF),
      onDestinationSelected: (index) {
        if (index == currentIndex) return;

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }

        if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentMethodsPage(
                booking: Booking(
                  zone: 'Zone A',
                  vehicle: 'ABC 123',
                  hours: 2,
                  rate: 4.50,
                  paymentMethod: '',
                  paidAt: DateTime.now(),
                ),
              ),
            ),
          );
        }

        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.credit_card_outlined),
          selectedIcon: Icon(Icons.credit_card),
          label: 'Payments',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}