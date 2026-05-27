import 'package:flutter/material.dart';
import 'admin_shell.dart';
import 'pages/admin_command_center_page.dart';
import 'pages/admin_reports_page.dart';
import 'pages/admin_users_page.dart';
import 'pages/admin_zones_page.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_top_nav.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  AdminTopTab _activeTab = AdminTopTab.dashboard;
  AdminSidebarItem _activeSidebarItem = AdminSidebarItem.premise;

  void _onTabSelected(AdminTopTab tab) {
    setState(() {
      _activeTab = tab;
      if (tab == AdminTopTab.analytics) {
        _activeSidebarItem = AdminSidebarItem.reports;
      }
    });
  }

  void _onSidebarItemSelected(AdminSidebarItem item) {
    setState(() {
      _activeSidebarItem = item;
      if (item == AdminSidebarItem.reports) {
        _activeTab = AdminTopTab.analytics;
      } else if (_activeTab == AdminTopTab.analytics) {
        _activeTab = AdminTopTab.dashboard;
      }
    });
  }

  Widget _buildContent() {
    if (_activeTab == AdminTopTab.analytics ||
        _activeSidebarItem == AdminSidebarItem.reports) {
      return const AdminReportsPage();
    }
    switch (_activeSidebarItem) {
      case AdminSidebarItem.premise:
        if (_activeTab == AdminTopTab.dashboard) {
          return const AdminCommandCenterPage();
        }
        return const AdminZonesPage();
      case AdminSidebarItem.users:
        return const AdminUsersPage();
      case AdminSidebarItem.reports:
        return const AdminReportsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeTab: _activeTab,
      activeSidebarItem: _activeSidebarItem,
      onTabSelected: _onTabSelected,
      onSidebarItemSelected: _onSidebarItemSelected,
      child: _buildContent(),
    );
  }
}
