import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import '../services/vehicle_service.dart';

class VehicleRegistrationPage extends StatefulWidget {
  const VehicleRegistrationPage({super.key});

  @override
  State<VehicleRegistrationPage> createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final _plateController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _vehicleService = VehicleService();

  String? selectedState = 'NSW';
  String? selectedVehicleType = 'Sedan';

  bool _isLoading = false;

  // Keep this false until backend URL/auth is ready.
  static const bool useRealApi = false;

  @override
  void dispose() {
    _plateController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    final plate = _plateController.text.trim();

    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a registration number.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (useRealApi) {
        await _vehicleService.registerVehicle(licensePlate: plate);
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            useRealApi
                ? 'Vehicle saved to backend.'
                : 'Demo vehicle saved.',
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save vehicle: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
    const cardBackground = Colors.white;
    const mutedText = Color(0xFF8B8E99);
    const borderColor = Color(0xFFE6E8EF);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vehicle Registration',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add your vehicle',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register your vehicle to manage parking sessions on campus.',
                  style: TextStyle(
                    fontSize: 14,
                    color: mutedText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                const _FieldLabel('Registration number'),
                const SizedBox(height: 8),
                TextField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: _inputDecoration(
                    hintText: 'Enter plate number',
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(height: 18),

                const _FieldLabel('State'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedState,
                  decoration: _inputDecoration(
                    hintText: 'Select state',
                    borderColor: borderColor,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'NSW', child: Text('NSW')),
                    DropdownMenuItem(value: 'VIC', child: Text('VIC')),
                    DropdownMenuItem(value: 'QLD', child: Text('QLD')),
                    DropdownMenuItem(value: 'SA', child: Text('SA')),
                    DropdownMenuItem(value: 'WA', child: Text('WA')),
                    DropdownMenuItem(value: 'ACT', child: Text('ACT')),
                    DropdownMenuItem(value: 'TAS', child: Text('TAS')),
                    DropdownMenuItem(value: 'NT', child: Text('NT')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedState = value);
                  },
                ),
                const SizedBox(height: 18),

                const _FieldLabel('Vehicle type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: _inputDecoration(
                    hintText: 'Select vehicle type',
                    borderColor: borderColor,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
                    DropdownMenuItem(value: 'SUV', child: Text('SUV')),
                    DropdownMenuItem(value: 'Hatchback', child: Text('Hatchback')),
                    DropdownMenuItem(value: 'Ute', child: Text('Ute')),
                    DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcycle')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedVehicleType = value);
                  },
                ),
                const SizedBox(height: 18),

                const _FieldLabel('Vehicle nickname'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nicknameController,
                  decoration: _inputDecoration(
                    hintText: 'Example: My Car',
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(height: 26),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFDDE4FF)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: primaryBlue, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You can edit or remove this vehicle later from your profile.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A4D57),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveVehicle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Vehicle',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String hintText,
  required Color borderColor,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFFB0B3BD)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: Color(0xFF0D2E9B), width: 1.4),
    ),
  );
}