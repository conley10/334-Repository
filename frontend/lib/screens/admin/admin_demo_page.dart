import 'package:flutter/material.dart';
import 'admin_shell.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_top_nav.dart';

class AdminDemoPage extends StatefulWidget {
  const AdminDemoPage({super.key});

  @override
  State<AdminDemoPage> createState() => _AdminDemoPageState();
}

class _AdminDemoPageState extends State<AdminDemoPage> {
  AdminTopTab _activeTab = AdminTopTab.dashboard;
  AdminSidebarItem _activeSidebarItem = AdminSidebarItem.premise;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      activeTab: _activeTab,
      activeSidebarItem: _activeSidebarItem,
      onTabSelected: (tab) => setState(() => _activeTab = tab),
      onSidebarItemSelected: (item) => setState(() => _activeSidebarItem = item),
      child: _DemoContent(
        activeTab: _activeTab,
        activeSidebarItem: _activeSidebarItem,
      ),
    );
  }
}

class _DemoContent extends StatelessWidget {
  const _DemoContent({
    required this.activeTab,
    required this.activeSidebarItem,
  });

  final AdminTopTab activeTab;
  final AdminSidebarItem activeSidebarItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin Shell Demo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1D24),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Click any top tab or sidebar item to verify the shell reacts.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 32),
        _InfoCard(
          title: 'Active Top Tab',
          value: activeTab.name,
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Active Sidebar Item',
          value: activeSidebarItem.name,
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D2E9B),
            ),
          ),
        ],
      ),
    );
  }
}
