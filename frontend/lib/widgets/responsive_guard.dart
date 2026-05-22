import 'package:flutter/material.dart';

class ResponsiveGuard extends StatelessWidget {
  const ResponsiveGuard({
    super.key,
    required this.child,
    this.minWidth = 1024,
  });

  final Widget child;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < minWidth) {
          return const _MobileFallback();
        }
        return child;
      },
    );
  }
}

class _MobileFallback extends StatelessWidget {
  const _MobileFallback();

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0D2E9B);
    const textMuted = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.desktop_windows_outlined,
                    size: 40,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Desktop view required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1D24),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'The admin console is optimised for larger screens. '
                  'Please open this page on a desktop or laptop with a '
                  'minimum width of 1024 pixels.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: textMuted,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Need help? Contact your IT administrator.',
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                    ],
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
