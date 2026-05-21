import 'package:flutter/material.dart';
import 'vehicle_registration_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void _goToDemoApp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VehicleRegistrationPage(),
      ),
    );
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),

                  Text(
                    'Welcome to\nCampusPark',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: primaryBlue,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Access university parking services with your academic credentials.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _SocialButton(
                    label: 'Demo Login - Continue',
                    backgroundColor: primaryBlue,
                    textColor: Colors.white,
                    borderColor: primaryBlue,
                    icon: const Icon(Icons.login, color: Colors.white),
                    onTap: () => _goToDemoApp(context),
                  ),

                  const SizedBox(height: 12),

                  _SocialButton(
                    label: 'Continue with Google',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: borderColor,
                    icon: const Icon(Icons.g_mobiledata, color: Colors.black),
                    onTap: () => _goToDemoApp(context),
                  ),

                  const SizedBox(height: 12),

                  _SocialButton(
                    label: 'Continue with Microsoft',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: borderColor,
                    icon: const Icon(Icons.window, color: Colors.black),
                    onTap: () => _goToDemoApp(context),
                  ),

                  const SizedBox(height: 12),

                  _SocialButton(
                    label: 'Continue with Apple',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    borderColor: Colors.black,
                    icon: const Icon(Icons.apple, color: Colors.white),
                    onTap: () => _goToDemoApp(context),
                  ),

                  const SizedBox(height: 26),

                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 12,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: 'Trouble logging in? Please contact the\n'),
                        TextSpan(
                          text: 'IT Service Desk',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Divider(color: borderColor, height: 1),

                  const SizedBox(height: 18),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'TERMS OF SERVICE',
                        style: TextStyle(
                          fontSize: 10,
                          color: mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'PRIVACY POLICY',
                        style: TextStyle(
                          fontSize: 10,
                          color: mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    '© 2024 CampusPark Systems.',
                    style: TextStyle(
                      fontSize: 10,
                      color: mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Widget icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: Center(child: icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}