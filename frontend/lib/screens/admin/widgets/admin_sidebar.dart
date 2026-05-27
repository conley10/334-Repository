import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.activeItem,
    required this.onItemSelected,
  });

  final AdminSidebarItem activeItem;
  final ValueChanged<AdminSidebarItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 4),
            child: Text(
              'Admin Console',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D24),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Text(
              'Management Suite',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          _SidebarItem(
            icon: Icons.business_outlined,
            label: 'Premise Management',
            isActive: activeItem == AdminSidebarItem.premise,
            onTap: () => onItemSelected(AdminSidebarItem.premise),
          ),
          _SidebarItem(
            icon: Icons.group_outlined,
            label: 'User Management',
            isActive: activeItem == AdminSidebarItem.users,
            onTap: () => onItemSelected(AdminSidebarItem.users),
          ),
          _SidebarItem(
            icon: Icons.assessment_outlined,
            label: 'Reports',
            isActive: activeItem == AdminSidebarItem.reports,
            onTap: () => onItemSelected(AdminSidebarItem.reports),
          ),
        ],
      ),
    );
  }
}

enum AdminSidebarItem { premise, users, reports }

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF0D2E9B).withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive
                    ? const Color(0xFF0D2E9B)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF0D2E9B)
                      : const Color(0xFF1A1D24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
