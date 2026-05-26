import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'bookings_page.dart';
import 'payment_methods_page.dart';
import 'profile_page.dart';
import 'app_state.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final loaded = await _notificationService.getNotifications();

    if (!mounted) return;

    setState(() {
      notifications = loaded;
      isLoading = false;
    });
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'booking_confirmation':
        return Icons.check_circle_outline;
      case 'expiry_warning':
        return Icons.access_time;
      case 'violation_alert':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'booking_confirmation':
        return const Color(0xFF2E7D32);
      case 'expiry_warning':
        return const Color(0xFFF57C00);
      case 'violation_alert':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF0D2E9B);
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
                      'Notifications',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Stay updated on your bookings and parking sessions.',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    if (!isLoading && notifications.isEmpty)
                      const _SectionCard(
                        title: 'No notifications yet',
                        child: Text(
                          'You will see updates about your bookings here.',
                        ),
                      ),

                    if (!isLoading)
                      ...notifications.map(
                        (notif) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SectionCard(
                            title: notif.typeLabel,
                            titleColor: _colorFor(notif.type),
                            titleIcon: _iconFor(notif.type),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif.message),
                                const SizedBox(height: 8),
                                Text(
                                  '${notif.timeText} • via ${notif.channel}',
                                  style: const TextStyle(
                                    color: mutedText,
                                    fontSize: 12,
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
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? titleColor;
  final IconData? titleIcon;

  const _SectionCard({
    required this.title,
    required this.child,
    this.titleColor,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color = titleColor ?? const Color(0xFF0D2E9B);

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
          Row(
            children: [
              if (titleIcon != null) ...[
                Icon(titleIcon, color: color, size: 22),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}