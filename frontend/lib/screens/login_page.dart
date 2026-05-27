import 'package:flutter/material.dart';

import '../auth/microsoft_oauth_stub.dart'
    if (dart.library.html) '../auth/microsoft_oauth_web.dart';
import '../services/auth_service.dart';
import 'vehicle_registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool hasProcessedCode = false;

  @override
  void initState() {
    super.initState();
    _handleMicrosoftRedirect();
  }

  Future<void> _handleMicrosoftRedirect() async {
    if (hasProcessedCode) return;

    final code = MicrosoftOAuthWeb.getReturnedCode();

    if (code == null || code.isEmpty) {
      return;
    }

    hasProcessedCode = true;

    final verifier = MicrosoftOAuthWeb.getCodeVerifier();

    if (verifier == null || verifier.isEmpty) {
      _showError('Missing PKCE verifier.');
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.exchangeMicrosoftCode(
        code: code,
        codeVerifier: verifier,
        redirectUri: MicrosoftOAuthWeb.redirectUri,
      );

      MicrosoftOAuthWeb.clearCodeVerifier();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const VehicleRegistrationPage(),
        ),
      );
    } catch (error) {
      _showError('Microsoft login failed: $error');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startMicrosoftLogin() {
    MicrosoftOAuthWeb.startLogin();
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 28,
              ),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                    style:
                        Theme.of(context).textTheme.headlineSmall?.copyWith(
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

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed:
                          isLoading ? null : _startMicrosoftLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        isLoading
                            ? 'Signing in...'
                            : 'Continue with Microsoft',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Secure Microsoft Azure authentication enabled.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: mutedText,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Divider(),

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