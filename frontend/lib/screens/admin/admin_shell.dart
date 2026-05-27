import 'package:flutter/material.dart';
import '../../widgets/responsive_guard.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_top_nav.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.activeTab,
    required this.activeSidebarItem,
    required this.onTabSelected,
    required this.onSidebarItemSelected,
    required this.child,
  });

  final AdminTopTab activeTab;
  final AdminSidebarItem activeSidebarItem;
  final ValueChanged<AdminTopTab> onTabSelected;
  final ValueChanged<AdminSidebarItem> onSidebarItemSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ResponsiveGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: Column(
          children: [
            AdminTopNav(
              activeTab: activeTab,
              onTabSelected: onTabSelected,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminSidebar(
                    activeItem: activeSidebarItem,
                    onItemSelected: onSidebarItemSelected,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
