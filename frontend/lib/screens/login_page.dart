import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_keys.dart';
import '../auth/microsoft_oauth.dart';
import '../auth/microsoft_oauth_config.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import 'vehicle_registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  String? _loadingProvider;
  bool _bootstrappingOAuth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapOAuthReturn());
  }

  String _authErrorMessage(ApiException e) {
    if (e.statusCode == 503) {
      return '${e.message} Rebuild the API: cd backend && docker compose up --build -d';
    }
    if (e.statusCode == 0) return e.message;
    return e.message;
  }

  void _notifyUser(String text, {Duration duration = const Duration(seconds: 8)}) {
    appScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        backgroundColor: const Color(0xFF1a1a2e),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  /// If [dotenv] failed to load, [dotenv.get] can throw — treat as empty.
  String _readDotenv(String key) {
    try {
      return dotenv.get(key, fallback: '').trim();
    } catch (_) {
      return '';
    }
  }

  /// If the user landed here after Microsoft redirected back with ?code=&state=, finish sign-in.
  Future<void> _bootstrapOAuthReturn() async {
    if (!kIsWeb) {
      if (mounted) setState(() => _bootstrappingOAuth = false);
      return;
    }

    final handled = await tryHandleMicrosoftOAuthReturn(
      onSuccess: (code, verifier, redirectUri) async {
        setState(() => _loadingProvider = 'microsoft');
        try {
          await _authService.exchangeToken(
            provider: 'microsoft',
            code: code,
            codeVerifier: verifier,
            redirectUri: redirectUri,
          );
          if (!mounted) return;
          await _goToHome();
        } on ApiException catch (e) {
          if (!mounted) return;
          _notifyUser(_authErrorMessage(e));
        } catch (e) {
          if (!mounted) return;
          _notifyUser('Sign-in failed: $e');
        } finally {
          if (mounted) setState(() => _loadingProvider = null);
        }
      },
      onError: (message) {
        if (!mounted) return;
        _notifyUser(message);
      },
    );

    if (handled && mounted) {
      // Navigation may have occurred; still clear bootstrap flag.
      setState(() => _bootstrappingOAuth = false);
      return;
    }

    if (mounted) setState(() => _bootstrappingOAuth = false);
  }

  String _microsoftTenantId() {
    const fromDefine = String.fromEnvironment('MICROSOFT_TENANT_ID', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _readDotenv('MICROSOFT_TENANT_ID');
  }

  String _microsoftClientId() {
    const fromDefine = String.fromEnvironment('MICROSOFT_CLIENT_ID', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    return _readDotenv('MICROSOFT_CLIENT_ID');
  }

  String _microsoftRedirectUri() {
    const fromDefine = String.fromEnvironment('MICROSOFT_REDIRECT_URI', defaultValue: '');
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromDot = _readDotenv('MICROSOFT_REDIRECT_URI');
    if (fromDot.isNotEmpty) return fromDot;
    final origin = Uri.base.origin;
    return origin.endsWith('/') ? origin : '$origin/';
  }

  Future<void> _goToHome() {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const VehicleRegistrationPage()),
    );
  }

  Future<void> _continueWithMicrosoft() async {
    if (!kIsWeb) {
      if (!mounted) return;
      _notifyUser('Microsoft sign-in runs in the web app. Use: flutter run -d edge --web-port=8080');
      return;
    }

    setState(() => _loadingProvider = 'microsoft');
    try {
      if (await _authService.tryRestoreSession()) {
        if (!mounted) return;
        await _authService.ensureDisplayName();
        if (!mounted) return;
        await _goToHome();
        return;
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _notifyUser(_authErrorMessage(e));
      return;
    } catch (e) {
      if (!mounted) return;
      _notifyUser('Sign-in failed: $e');
      return;
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }

    final msConfig = MicrosoftOAuthConfig.parse(
      rawTenantId: _microsoftTenantId(),
      rawClientId: _microsoftClientId(),
    );
    if (msConfig == null) {
      if (!mounted) return;
      _notifyUser(
        'Missing MICROSOFT_TENANT_ID or MICROSOFT_CLIENT_ID. '
        'Fill frontend/.env then stop and run flutter again (hot reload does not reload .env).',
      );
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Microsoft sign-in not configured'),
          content: const Text(
            'Add your Azure values to frontend/.env:\n\n'
            'MICROSOFT_TENANT_ID=<Directory tenant ID GUID>\n'
            'MICROSOFT_CLIENT_ID=<Application client ID GUID>\n\n'
            'Azure Portal → Microsoft Entra ID → Overview → Tenant ID\n'
            'Azure Portal → App registrations → your app → Application (client) ID\n\n'
            'Then fully restart: flutter run -d edge --web-port=8080',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final configError = msConfig.validate();
    if (configError != null) {
      if (!mounted) return;
      _notifyUser(configError);
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid Microsoft configuration'),
          content: Text(configError),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    setState(() => _loadingProvider = 'microsoft');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        startMicrosoftSignIn(
          tenantId: msConfig.tenantId,
          clientId: msConfig.clientId,
          redirectUri: _microsoftRedirectUri(),
        );
      } on UnsupportedError catch (e) {
        if (!mounted) return;
        setState(() => _loadingProvider = null);
        _notifyUser(e.message ?? 'Not supported');
      } catch (e, st) {
        debugPrint('$e\n$st');
        if (!mounted) return;
        setState(() => _loadingProvider = null);
        _notifyUser('Could not start Microsoft sign-in: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const lightBackground = Color(0xFFF7F7FA);
    const cardBackground = Colors.white;
    const mutedText = Color(0xFF8B8E99);
    const borderColor = Color(0xFFE6E8EF);

    if (_bootstrappingOAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    style: TextStyle(color: mutedText, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  _SocialButton(
                    label: 'Continue with Microsoft',
                    isLoading: _loadingProvider == 'microsoft',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: borderColor,
                    icon: _BrandBox(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        'assets/images/microsoft.svg',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    onTap: _continueWithMicrosoft,
                  ),
                  const SizedBox(height: 26),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: mutedText, fontSize: 12, height: 1.5),
                      children: [
                        TextSpan(text: 'Trouble logging in? Please contact the\n'),
                        TextSpan(
                          text: 'IT Service Desk',
                          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w700),
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
                      Text('TERMS OF SERVICE', style: TextStyle(fontSize: 10, color: mutedText, fontWeight: FontWeight.w600)),
                      SizedBox(width: 16),
                      Text('PRIVACY POLICY', style: TextStyle(fontSize: 10, color: mutedText, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('© 2024 CampusPark Systems.', style: TextStyle(fontSize: 10, color: mutedText)),
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
  final bool isLoading;

  const _SocialButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          children: [
            if (isLoading)
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
              )
            else
              icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isLoading ? 'Signing in...' : label,
                style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

class _BrandBox extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const _BrandBox({required this.child, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(6)),
      alignment: Alignment.center,
      child: child,
    );
  }
}
