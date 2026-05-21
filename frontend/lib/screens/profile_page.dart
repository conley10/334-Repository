import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'bookings_page.dart';
import 'payment_methods_page.dart';
import 'app_state.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle.dart';
import '../services/user_service.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final VehicleService _vehicleService = VehicleService();
  final UserService _userService = UserService();

  List<Vehicle> vehicles = [];
  User? currentUser;

  bool isLoadingVehicles = true;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    loadVehicles();
    loadUser();
  }

  Future<void> loadVehicles() async {
    final loadedVehicles = await _vehicleService.getVehicles();

    if (!mounted) return;

    setState(() {
      vehicles = loadedVehicles;
      isLoadingVehicles = false;
    });
  }

  Future<void> loadUser() async {
    final loadedUser = await _userService.getCurrentUser();

    if (!mounted) return;

    setState(() {
      currentUser = loadedUser;
      isLoadingUser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);

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
                      'Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 38,
                              color: primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: isLoadingUser
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUser?.name ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Student ID: S1234567',
                                        style:
                                            TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentUser?.email ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _InfoCard(
                      title: 'Account Information',
                      children: [
                        _InfoRow(
                          label: 'Role',
                          value: currentUser?.role ?? '',
                        ),
                        const _InfoRow(
                          label: 'Campus',
                          value: 'Main Campus',
                        ),
                        const _InfoRow(
                          label: 'Department',
                          value: 'Information Technology',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _InfoCard(
                      title: 'Registered Vehicles',
                      children: [
                        if (isLoadingVehicles)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),

                        if (!isLoadingVehicles && vehicles.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('No vehicles registered.'),
                          ),

                        ...vehicles.map(
                          (vehicle) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _InfoRow(
                              label: 'Plate',
                              value: vehicle.licensePlate,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Bookings',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...AppState.paidBookings.expand(
                      (booking) => [
                        _BookingCard(
                          zone: booking.zone,
                          date: booking.dateText,
                          time: booking.timeText,
                          price: booking.totalText,
                          status: 'Paid',
                          statusColor: const Color(0xFF18A957),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBlue,
                          side: const BorderSide(color: primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _BottomNavBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B8E99),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String zone;
  final String date;
  final String time;
  final String price;
  final String status;
  final Color statusColor;

  const _BookingCard({
    required this.zone,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE8ECFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_parking,
              color: Color(0xFF0D2E9B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF8B8E99),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF0D2E9B),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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

        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BookingsPage()),
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