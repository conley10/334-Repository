import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'payment_methods_page.dart';
import 'profile_page.dart';
import 'app_state.dart';

import '../models/booking.dart';
import '../models/zone.dart';
import '../models/vehicle.dart';
import '../models/parking_spot.dart';

import '../services/booking_service.dart';
import '../services/zone_service.dart';
import '../services/vehicle_service.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final BookingService _bookingService = BookingService();
  final ZoneService _zoneService = ZoneService();
  final VehicleService _vehicleService = VehicleService();

  List<BookingModel> bookings = [];
  List<Zone> zones = [];
  List<Vehicle> vehicles = [];
  List<ParkingSpot> spots = [];

  int? selectedZoneId;
  int? selectedVehicleId;
  int? selectedSpotId;

  int selectedHours = 2;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();

  bool isLoadingBookings = true;
  bool isLoadingFormData = true;
  bool isLoadingSpots = false;
  bool isCreatingBooking = false;

  Zone? get selectedZone {
    for (final zone in zones) {
      if (zone.zoneID == selectedZoneId) return zone;
    }
    return null;
  }

  Vehicle? get selectedVehicle {
    for (final vehicle in vehicles) {
      if (vehicle.vehicleID == selectedVehicleId) return vehicle;
    }
    return null;
  }

  ParkingSpot? get selectedSpot {
    for (final spot in spots) {
      if (spot.spotID == selectedSpotId) return spot;
    }
    return null;
  }

  DateTime get selectedStartDateTime {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );
  }

  double get hourlyRate => selectedZone?.pricePerHour ?? 4.50;
  double get totalPrice => selectedHours * hourlyRate;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    await Future.wait([
      loadBookings(),
      loadFormData(),
    ]);
  }

  Future<void> loadBookings() async {
    try {
      final loadedBookings = await _bookingService.getBookings();

      if (!mounted) return;

      setState(() {
        bookings = loadedBookings;
        isLoadingBookings = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => isLoadingBookings = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookings: $error')),
      );
    }
  }

  Future<void> loadFormData() async {
    try {
      final loadedZones = await _zoneService.getZones();
      final loadedVehicles = await _vehicleService.getVehicles();

      if (!mounted) return;

      setState(() {
        zones = loadedZones;
        vehicles = loadedVehicles;

        if (zones.isNotEmpty) {
          selectedZoneId = zones.first.zoneID;
        }

        if (vehicles.isNotEmpty) {
          selectedVehicleId = vehicles.first.vehicleID;
        }

        isLoadingFormData = false;
      });

      if (selectedZoneId != null) {
        await loadSpotsForZone(selectedZoneId!);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() => isLoadingFormData = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load booking options: $error')),
      );
    }
  }

  Future<void> loadSpotsForZone(int zoneId) async {
    setState(() {
      isLoadingSpots = true;
      selectedSpotId = null;
      spots = [];
    });

    try {
      final loadedSpots = await _zoneService.getSpotsForZone(zoneId);

      if (!mounted) return;

      setState(() {
        spots = loadedSpots;
        if (spots.isNotEmpty) {
          selectedSpotId = spots.first.spotID;
        }
        isLoadingSpots = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => isLoadingSpots = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load spots: $error')),
      );
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );

    if (pickedTime != null) {
      setState(() => selectedStartTime = pickedTime);
    }
  }

  Future<void> _confirmBooking() async {
    if (selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a parking zone.')),
      );
      return;
    }

    if (selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle.')),
      );
      return;
    }

    if (selectedSpotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available spot.')),
      );
      return;
    }

    final startTime = selectedStartDateTime;

    if (startTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a future start time.')),
      );
      return;
    }

    setState(() => isCreatingBooking = true);

    try {
      final utcStartTime = startTime.toUtc();
      final utcEndTime = utcStartTime.add(Duration(hours: selectedHours));

      final createdBooking = await _bookingService.createBooking(
        startTime: utcStartTime,
        endTime: utcEndTime,
        userID: 2,
        spotId: selectedSpotId!,
        vehicleId: selectedVehicleId!,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodsPage(
            booking: Booking(
              bookingID: createdBooking.bookingID,
              zone: selectedZone?.name ?? 'Parking Zone',
              vehicle: selectedVehicle?.licensePlate ?? 'Vehicle',
              hours: selectedHours,
              rate: hourlyRate,
              paymentMethod: '',
              paidAt: DateTime.now(),
              startTime: selectedStartDateTime,
              endTime: selectedStartDateTime.add(Duration(hours: selectedHours)),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create booking: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => isCreatingBooking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
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
                      style: TextStyle(color: mutedText, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    if (isLoadingFormData)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else ...[
                      _SectionCard(
                        title: 'Parking Zone',
                        child: DropdownButtonFormField<int>(
                          value: selectedZoneId,
                          decoration: _inputDecoration(),
                          items: zones.map((zone) {
                            return DropdownMenuItem<int>(
                              value: zone.zoneID,
                              child: Text(
                                '${zone.name} - \$${zone.pricePerHour.toStringAsFixed(2)}/hr',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            if (value != null) {
                              setState(() => selectedZoneId = value);
                              await loadSpotsForZone(value);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      _SectionCard(
                        title: 'Available Spot',
                        child: isLoadingSpots
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : DropdownButtonFormField<int>(
                                value: selectedSpotId,
                                decoration: _inputDecoration(),
                                items: spots.map((spot) {
                                  return DropdownMenuItem<int>(
                                    value: spot.spotID,
                                    child: Text('${spot.spotNumber} (${spot.status})'),
                                  );
                                }).toList(),
                                onChanged: spots.isEmpty
                                    ? null
                                    : (value) {
                                        if (value != null) {
                                          setState(() => selectedSpotId = value);
                                        }
                                      },
                              ),
                      ),

                      const SizedBox(height: 16),

                      _SectionCard(
                        title: 'Vehicle',
                        child: DropdownButtonFormField<int>(
                          value: selectedVehicleId,
                          decoration: _inputDecoration(),
                          items: vehicles.map((vehicle) {
                            return DropdownMenuItem<int>(
                              value: vehicle.vehicleID,
                              child: Text(vehicle.licensePlate),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedVehicleId = value);
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      _SectionCard(
                        title: 'Start Date & Time',
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.calendar_today,
                                color: primaryBlue,
                              ),
                              title: Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _pickDate,
                            ),
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.access_time,
                                color: primaryBlue,
                              ),
                              title: Text(
                                selectedStartTime.format(context),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: _pickTime,
                            ),
                          ],
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
                                    final maxDuration = selectedZone?.maxDuration ?? 10;
                                    if (selectedHours < maxDuration) {
                                      setState(() => selectedHours++);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '\$${hourlyRate.toStringAsFixed(2)} per hour',
                              style: const TextStyle(
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
                            _SummaryRow(
                              label: 'Zone',
                              value: selectedZone?.name ?? 'Not selected',
                            ),
                            _SummaryRow(
                              label: 'Spot',
                              value: selectedSpot?.spotNumber ?? 'Not selected',
                            ),
                            _SummaryRow(
                              label: 'Vehicle',
                              value: selectedVehicle?.licensePlate ?? 'Not selected',
                            ),
                            _SummaryRow(
                              label: 'Start',
                              value:
                                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedStartTime.format(context)}',
                            ),
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
                          onPressed: isCreatingBooking ? null : _confirmBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isCreatingBooking
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Confirm Booking',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],

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
                            title: 'Booking #${booking.bookingID}',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Vehicle ID: ${booking.vehicleID}'),
                                const SizedBox(height: 6),
                                Text('Spot ID: ${booking.spotID}'),
                                const SizedBox(height: 6),
                                Text('Status: ${booking.status}'),
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isTotal ? const Color(0xFF0D2E9B) : Colors.black87,
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
              ),
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
                  bookingID: 1,
                  zone: 'Zone A',
                  vehicle: 'ABC-123',
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