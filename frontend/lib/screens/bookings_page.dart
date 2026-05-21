import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/parking_session.dart';
import '../router/app_router.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/vehicle_service.dart';
import '../utils/sydney_time.dart';
import '../widgets/main_bottom_nav.dart';
import 'app_state.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final _bookingService = BookingService();
  final _authService = AuthService();
  final _vehicleService = VehicleService();

  int _tabIndex = 0;
  String? _zoneFilter;
  String _driverName = '';
  String _vehiclePlate = '';
  List<ParkingSession> _sessions = [];
  bool _loading = true;

  static const _tabs = ['All Sessions', 'Active', 'Upcoming', 'History'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    await _authService.ensureMicrosoftProfile();
    final name = await _authService.getFullName() ?? '';
    final vehicles = await _vehicleService.getVehicles();
    final plate = vehicles.isNotEmpty ? vehicles.first.licensePlate : '';

    await _bookingService.seedDemoSessions(
      driverName: name.isNotEmpty ? name : 'Student',
      vehiclePlate: plate,
    );

    final sessions = await _bookingService.getSessions();

    if (!mounted) return;
    setState(() {
      _driverName = name;
      _vehiclePlate = plate;
      _sessions = sessions;
      _loading = false;
    });
  }

  List<ParkingSession> get _filteredSessions {
    var list = _sessions;

    if (_zoneFilter != null && _zoneFilter!.isNotEmpty) {
      list = list.where((s) => s.zoneTitle.startsWith(_zoneFilter!)).toList();
    }

    switch (_tabIndex) {
      case 1:
        return list.where((s) => s.effectiveStatus == SessionStatus.active).toList();
      case 2:
        return list.where((s) => s.effectiveStatus == SessionStatus.upcoming).toList();
      case 3:
        return list.where((s) => s.effectiveStatus == SessionStatus.history).toList();
      default:
        return list;
    }
  }

  Future<void> _pickZoneFilter() async {
    const zones = ['All zones', 'Zone A', 'Zone B', 'Zone C', 'Library Deck'];
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: zones
              .map(
                (z) => ListTile(
                  title: Text(z),
                  onTap: () => Navigator.pop(ctx, z),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (!mounted || picked == null) return;
    setState(() {
      _zoneFilter = picked == 'All zones' ? null : picked;
    });
  }

  Future<void> _cancelSession(ParkingSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel booking?'),
        content: Text('Cancel parking at ${session.zoneTitle}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel booking')),
        ],
      ),
    );

    if (confirm != true) return;
    await _bookingService.cancelSession(session.id);
    await _load();
  }

  Future<void> _rescheduleSession(ParkingSession session) async {
    final sydney = SydneyTime.fromUtc(session.startTime.toUtc());
    final newStartLocal = DateTime(sydney.year, sydney.month, sydney.day + 1, sydney.hour, sydney.minute);
    final newStart = SydneyTime.toUtc(newStartLocal);
    final newEnd = newStart.add(Duration(hours: session.hours));
    await _bookingService.rescheduleSession(
      session.id,
      startTime: newStart,
      endTime: newEnd,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking rescheduled to ${SydneyTime.formatDayLabel(newStart)} (Sydney).',
        ),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
    const mutedText = Color(0xFF8B8E99);

    return Scaffold(
      backgroundColor: lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.bookingNew);
          await _load();
        },
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sessions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: primaryBlue,
                    ),
<<<<<<< HEAD
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _driverName.isNotEmpty && _vehiclePlate.isNotEmpty
                        ? '$_driverName · $_vehiclePlate · Sydney (${SydneyTime.timezoneAbbreviation()})'
                        : _driverName.isNotEmpty
                            ? _driverName
                            : _vehiclePlate.isNotEmpty
                                ? 'Vehicle: $_vehiclePlate'
                                : 'Sign in and register a vehicle',
                    style: const TextStyle(color: mutedText, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _pickZoneFilter,
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: Text(_zoneFilter ?? 'Zone filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBlue,
                        side: const BorderSide(color: Color(0xFFDDE4FF)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
=======
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
                        initialValue: selectedZone,
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
                        initialValue: selectedVehicle,
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
>>>>>>> 2140271 (zones)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final selected = _tabIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _tabs[index],
                          style: TextStyle(
                            color: selected ? primaryBlue : mutedText,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          width: selected ? 72 : 0,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSessions.isEmpty
                      ? Center(
                          child: Text(
                            'No sessions in this view.',
                            style: TextStyle(color: mutedText),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                          itemCount: _filteredSessions.length,
                          itemBuilder: (context, index) {
                            final session = _filteredSessions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _SessionCard(
                                session: session,
                                onCancel: () => _cancelSession(session),
                                onReschedule: () => _rescheduleSession(session),
                                onEdit: () => _rescheduleSession(session),
                              ),
                            );
                          },
                        ),
            ),
            const MainBottomNav(),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onCancel,
    required this.onReschedule,
    required this.onEdit,
  });

  final ParkingSession session;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const mutedText = Color(0xFF8B8E99);

    final isActive = session.effectiveStatus == SessionStatus.active;
    final isUpcoming = session.effectiveStatus == SessionStatus.upcoming;
    final badgeColor = isActive ? primaryBlue : mutedText;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: badgeColor),
                    const SizedBox(width: 6),
                    Text(
                      session.statusLabel,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: mutedText, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            session.zoneTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'DATE & TIME',
            value: session.dateTimeLine,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.directions_car_outlined,
            label: 'VEHICLE',
            value: session.vehiclePlate,
          ),
          if (session.driverName.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'DRIVER',
              value: session.driverName,
            ),
          ],
          const SizedBox(height: 16),
          if (isUpcoming)
            Row(
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: onReschedule,
                  child: const Text(
                    'Reschedule',
                    style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          if (isActive)
            Center(
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Campus map coming soon.')),
                  );
                },
                child: const Text(
                  'View Map',
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const mutedText = Color(0xFF8B8E99);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryBlue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: mutedText,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
