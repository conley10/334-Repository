import 'package:flutter/material.dart';
import '../../../models/admin/admin_user.dart';
import '../../../services/admin/admin_user_service.dart';
import '../widgets/admin_page_header.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final AdminUserService _service = AdminUserService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<AdminUser> _users = [];
  bool _loading = true;
  String _searchTerm = '';
  UserRole? _roleFilter;
  UserStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await _service.getUsers();
      if (!mounted) return;
      setState(() { _users = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
    }
  }

  List<AdminUser> get _filtered {
    return _users.where((u) {
      final matchSearch = _searchTerm.isEmpty ||
          u.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          u.email.toLowerCase().contains(_searchTerm.toLowerCase());
      final matchRole = _roleFilter == null || u.role == _roleFilter;
      final matchStatus = _statusFilter == null || u.status == _statusFilter;
      return matchSearch && matchRole && matchStatus;
    }).toList();
  }

  Future<void> _toggleStatus(AdminUser user) async {
    final newStatus = user.status == UserStatus.active ? UserStatus.suspended : UserStatus.active;
    final action = newStatus == UserStatus.suspended ? 'suspend' : 'activate';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} user?'),
        content: Text('Are you sure you want to $action "${user.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: newStatus == UserStatus.suspended ? const Color(0xFFDC2626) : const Color(0xFF0D2E9B),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );
    if (ok != true || user.userID == null) return;
    try {
      await _service.updateUserStatus(user.userID!, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User ${action}d')));
      setState(() {
        final idx = _users.indexWhere((u) => u.userID == user.userID);
        if (idx != -1) _users[idx] = _users[idx].copyWith(status: newStatus);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showUserDetail(AdminUser user) {
    showDialog<bool>(
      context: context,
      builder: (_) => _UserDetailDialog(user: user, onToggleStatus: () { Navigator.pop(context); _toggleStatus(user); }),
    ).then((roleChanged) { if (roleChanged == true) _load(); });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminPageHeader(
          title: 'User Management',
          subtitle: 'View, search, and manage user accounts and permissions.',
        ),
        const SizedBox(height: 24),
        _buildToolbar(),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
        else if (_filtered.isEmpty)
          _buildEmpty()
        else
          _buildTable(),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchTerm = v),
              decoration: const InputDecoration(hintText: 'Search by name or email...', prefixIcon: Icon(Icons.search, size: 20), border: InputBorder.none, isDense: true),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<UserRole?>(
            value: _roleFilter,
            hint: const Text('All roles'),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<UserRole?>(value: null, child: Text('All roles')),
              ...UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(_roleLabel(r)))),
            ],
            onChanged: (v) => setState(() => _roleFilter = v),
          ),
          const SizedBox(width: 16),
          DropdownButton<UserStatus?>(
            value: _statusFilter,
            hint: const Text('All statuses'),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<UserStatus?>(value: null, child: Text('All statuses')),
              ...UserStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s)))),
            ],
            onChanged: (v) => setState(() => _statusFilter = v),
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh, size: 20), tooltip: 'Refresh'),
        ],
      ),
    );
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.student: return 'Student';
      case UserRole.staff: return 'Staff';
      case UserRole.faculty: return 'Faculty';
      case UserRole.admin: return 'Admin';
    }
  }

  String _statusLabel(UserStatus s) {
    switch (s) {
      case UserStatus.active: return 'Active';
      case UserStatus.suspended: return 'Suspended';
      case UserStatus.pending: return 'Pending';
    }
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: const Column(children: [
        Icon(Icons.person_off_outlined, size: 48, color: Color(0xFF9CA3AF)),
        SizedBox(height: 12),
        Text('No users found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        SizedBox(height: 4),
        Text('Try adjusting your search or filters.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
      ]),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(color: Color(0xFFF9FAFB), borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Row(children: const [
            Expanded(flex: 3, child: _ColHeader('USER')),
            Expanded(flex: 2, child: _ColHeader('ROLE')),
            Expanded(flex: 2, child: _ColHeader('STATUS')),
            Expanded(flex: 2, child: _ColHeader('BOOKINGS')),
            Expanded(flex: 2, child: _ColHeader('JOINED')),
            SizedBox(width: 100, child: _ColHeader('ACTIONS')),
          ]),
        ),
        for (int i = 0; i < _filtered.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _UserRow(
            user: _filtered[i],
            onView: () => _showUserDetail(_filtered[i]),
            onToggleStatus: () => _toggleStatus(_filtered[i]),
          ),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
          child: Text('Showing ${_filtered.length} of ${_users.length} users', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ),
      ]),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), letterSpacing: 0.5));
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onView, required this.onToggleStatus});
  final AdminUser user;
  final VoidCallback onView;
  final VoidCallback onToggleStatus;

  Color _statusBg() {
    switch (user.status) {
      case UserStatus.active: return const Color(0xFFD1FAE5);
      case UserStatus.suspended: return const Color(0xFFFEE2E2);
      case UserStatus.pending: return const Color(0xFFFEF3C7);
    }
  }

  Color _statusFg() {
    switch (user.status) {
      case UserStatus.active: return const Color(0xFF065F46);
      case UserStatus.suspended: return const Color(0xFF991B1B);
      case UserStatus.pending: return const Color(0xFF92400E);
    }
  }

  Color _roleBg() {
    switch (user.role) {
      case UserRole.admin: return const Color(0xFFEDE9FE);
      case UserRole.faculty: return const Color(0xFFDDEAFE);
      case UserRole.staff: return const Color(0xFFFEF3C7);
      case UserRole.student: return const Color(0xFFE5E7EB);
    }
  }

  Color _roleFg() {
    switch (user.role) {
      case UserRole.admin: return const Color(0xFF6D28D9);
      case UserRole.faculty: return const Color(0xFF1E40AF);
      case UserRole.staff: return const Color(0xFF92400E);
      case UserRole.student: return const Color(0xFF374151);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onView,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          Expanded(flex: 3, child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(color: Color(0xFF0D2E9B), shape: BoxShape.circle),
              child: Center(child: Text(user.initials, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D24))),
                const SizedBox(height: 2),
                Text(user.email, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), overflow: TextOverflow.ellipsis),
              ]),
            ),
          ])),
          Expanded(flex: 2, child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _roleBg(), borderRadius: BorderRadius.circular(12)),
              child: Text(user.roleLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _roleFg())),
            ),
          )),
          Expanded(flex: 2, child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _statusBg(), borderRadius: BorderRadius.circular(12)),
              child: Text(user.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusFg())),
            ),
          )),
          Expanded(flex: 2, child: Text('${user.totalBookings} bookings', style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D24)))),
          Expanded(flex: 2, child: Text(user.joinedText, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          SizedBox(
            width: 100,
            child: Row(children: [
              IconButton(onPressed: onView, icon: const Icon(Icons.visibility_outlined, size: 18), color: const Color(0xFF6B7280), tooltip: 'View'),
              IconButton(
                onPressed: onToggleStatus,
                icon: Icon(user.status == UserStatus.active ? Icons.block : Icons.check_circle_outline, size: 18),
                color: user.status == UserStatus.active ? const Color(0xFFDC2626) : const Color(0xFF059669),
                tooltip: user.status == UserStatus.active ? 'Suspend' : 'Activate',
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _UserDetailDialog extends StatefulWidget {
  const _UserDetailDialog({required this.user, required this.onToggleStatus});
  final AdminUser user;
  final VoidCallback onToggleStatus;

  @override
  State<_UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<_UserDetailDialog> {
  late UserRole _selectedRole;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  String _roleLabel(UserRole r) {
    switch (r) {
      case UserRole.student: return 'Student';
      case UserRole.staff:   return 'Staff';
      case UserRole.faculty: return 'Faculty';
      case UserRole.admin:   return 'Admin';
    }
  }

  Future<void> _saveRole(UserRole newRole) async {
    if (widget.user.userID == null) return;
    setState(() => _saving = true);
    try {
      await AdminUserService().updateUserRole(widget.user.userID!, newRole);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 56, height: 56,
                decoration: const BoxDecoration(color: Color(0xFF0D2E9B), shape: BoxShape.circle),
                child: Center(child: Text(widget.user.initials, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(widget.user.email, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ])),
            ]),
            const SizedBox(height: 24),
            _DetailRow(label: 'User ID', value: '#${widget.user.userID ?? '-'}'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                const SizedBox(width: 120, child: Text('Role', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
                DropdownButtonHideUnderline(
                  child: DropdownButton<UserRole>(
                    value: _selectedRole,
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1D24)),
                    items: UserRole.values.map((r) => DropdownMenuItem(value: r, child: Text(_roleLabel(r)))).toList(),
                    onChanged: _saving ? null : (v) {
                      if (v != null && v != _selectedRole) {
                        setState(() => _selectedRole = v);
                        _saveRole(v);
                      }
                    },
                  ),
                ),
                if (_saving) ...[
                  const SizedBox(width: 8),
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ]),
            ),
            _DetailRow(label: 'Status', value: widget.user.statusLabel),
            _DetailRow(label: 'Total Bookings', value: '${widget.user.totalBookings}'),
            _DetailRow(label: 'Joined', value: widget.user.joinedText),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: widget.onToggleStatus,
                icon: Icon(widget.user.status == UserStatus.active ? Icons.block : Icons.check_circle_outline, size: 18),
                label: Text(widget.user.status == UserStatus.active ? 'Suspend User' : 'Activate User'),
                style: FilledButton.styleFrom(backgroundColor: widget.user.status == UserStatus.active ? const Color(0xFFDC2626) : const Color(0xFF059669)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1D24)))),
      ]),
    );
  }
}
