import 'package:flutter/material.dart';

class AdminTopNav extends StatelessWidget {
  const AdminTopNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  final AdminTopTab activeTab;
  final ValueChanged<AdminTopTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'CampusPark',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D2E9B),
            ),
          ),
          const SizedBox(width: 48),
          _TopTabButton(
            label: 'Dashboard',
            isActive: activeTab == AdminTopTab.dashboard,
            onTap: () => onTabSelected(AdminTopTab.dashboard),
          ),
          const SizedBox(width: 24),
          _TopTabButton(
            label: 'Bookings',
            isActive: activeTab == AdminTopTab.bookings,
            onTap: () => onTabSelected(AdminTopTab.bookings),
          ),
          const SizedBox(width: 24),
          _TopTabButton(
            label: 'Analytics',
            isActive: activeTab == AdminTopTab.analytics,
            onTap: () => onTabSelected(AdminTopTab.analytics),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            color: const Color(0xFF6B7280),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            color: const Color(0xFF6B7280),
            tooltip: 'Settings',
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0D2E9B),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AdminTopTab { dashboard, bookings, analytics }

class _TopTabButton extends StatelessWidget {
  const _TopTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF0D2E9B) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? const Color(0xFF0D2E9B)
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
