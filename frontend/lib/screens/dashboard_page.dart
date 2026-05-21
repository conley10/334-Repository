import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../widgets/main_bottom_nav.dart';
import 'app_state.dart';
import '../services/auth_service.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle.dart';

=======
import 'bookings_page.dart';
import 'profile_page.dart';
import 'payment_methods_page.dart';
import 'app_state.dart';
import '../models/zone.dart';
import '../services/zone_service.dart';

>>>>>>> 2140271 (zones)
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
<<<<<<< HEAD
  final _authService = AuthService();
  final _vehicleService = VehicleService();
  String? _displayName;
  List<Vehicle> _vehicles = [];
=======
  final ZoneService _zoneService = ZoneService();

  late Future<List<Zone>> _zonesFuture;
>>>>>>> 2140271 (zones)

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await _authService.ensureMicrosoftProfile();
    final name = await _authService.getDisplayName();
    final vehicles = await _vehicleService.getVehicles();
    if (!mounted) return;
    setState(() {
      _displayName = name;
      _vehicles = vehicles;
    });
=======
    _zonesFuture = _zoneService.getZones();
>>>>>>> 2140271 (zones)
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
    const cardBackground = Colors.white;
    const mutedText = Color(0xFF8B8E99);

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
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFE8ECFF),
                          child: Icon(Icons.person, color: primaryBlue, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
<<<<<<< HEAD
                              const Text(
                                'Hello',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: mutedText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _displayName ?? 'there',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.notifications_none,
                          size: 28,
                          color: Colors.black87,
                        ),
=======
                              Text('Good morning', style: TextStyle(fontSize: 13, color: mutedText)),
                              SizedBox(height: 4),
                              Text('Conle', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: primaryBlue)),
                            ],
                          ),
                        ),
                        Icon(Icons.notifications_none, size: 28, color: Colors.black87),
>>>>>>> 2140271 (zones)
                      ],
                    ),

                    const SizedBox(height: 20),

                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search parking zones...',
                          hintStyle: TextStyle(color: mutedText),
                          prefixIcon: Icon(Icons.search, color: mutedText),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Find your nearest spot',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C4BC9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(Icons.map_outlined, color: Colors.white70, size: 60),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => context.go(AppRoutes.bookings),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryBlue,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('View Live Map', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Nearby Zones',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaryBlue),
                    ),
                    const SizedBox(height: 12),

                    FutureBuilder<List<Zone>>(
                      future: _zonesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Text('Error loading zones: ${snapshot.error}');
                        }

                        final zones = snapshot.data ?? [];

                        if (zones.isEmpty) {
                          return const Text('No parking zones available');
                        }

                        return Column(
                          children: zones.map((zone) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ZoneCard(
                                zoneName: zone.name,
                                distance: '${zone.maxDuration} hr max',
                                spots: '${zone.capacity} spots',
                                statusColor: Colors.green,
                                price: '\$${zone.pricePerHour.toStringAsFixed(2)}/hr',
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Quick Stats',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaryBlue),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
<<<<<<< HEAD
                        const Expanded(
                          child: _StatCard(
                            title: 'Active Session',
                            value: 'None',
                            icon: Icons.local_parking,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Saved Vehicle',
                            value: _vehicles.isEmpty
                                ? 'None'
                                : _vehicles.first.licensePlate,
                            icon: Icons.directions_car,
                          ),
                        ),
=======
                        Expanded(child: _StatCard(title: 'Active Session', value: 'None', icon: Icons.local_parking)),
                        SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Saved Vehicle', value: '1', icon: Icons.directions_car)),
>>>>>>> 2140271 (zones)
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(child: _StatCard(title: 'Campus Balance', value: '\$18.20', icon: Icons.account_balance_wallet_outlined)),
                        SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Bookings', value: '12', icon: Icons.receipt_long_outlined)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const MainBottomNav(),
          ],
        ),
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final String zoneName;
  final String distance;
  final String spots;
  final Color statusColor;
  final String price;

  const _ZoneCard({
    required this.zoneName,
    required this.distance,
    required this.spots,
    required this.statusColor,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFE8ECFF), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.local_parking, color: Color(0xFF0D2E9B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(zoneName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(distance, style: const TextStyle(color: Color(0xFF8B8E99), fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(spots, style: const TextStyle(fontSize: 13, color: Color(0xFF4A4D57))),
                  ],
                ),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0D2E9B))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0D2E9B)),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF8B8E99))),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0D2E9B))),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
class _MapPin extends StatelessWidget {
  final String label;

  const _MapPin({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0D2E9B),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
=======
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

        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Bookings'),
        NavigationDestination(icon: Icon(Icons.credit_card_outlined), selectedIcon: Icon(Icons.credit_card), label: 'Payments'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
>>>>>>> 2140271 (zones)
