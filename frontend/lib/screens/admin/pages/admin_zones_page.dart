import 'package:flutter/material.dart';
import '../../../models/admin/parking_zone.dart';
import '../../../services/admin/zone_service.dart';
import '../widgets/admin_page_header.dart';

class AdminZonesPage extends StatefulWidget {
  const AdminZonesPage({super.key});

  @override
  State<AdminZonesPage> createState() => _AdminZonesPageState();
}

class _AdminZonesPageState extends State<AdminZonesPage> {
  final ZoneService _service = ZoneService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<ParkingZone> _zones = [];
  bool _loading = true;
  String _searchTerm = '';
  ZoneStatus? _statusFilter;

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
      final result = await _service.getZones();
      if (!mounted) return;
      setState(() { _zones = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load zones: $e')),
      );
    }
  }

  List<ParkingZone> get _filtered {
    return _zones.where((z) {
      final matchSearch = _searchTerm.isEmpty ||
          z.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          z.typeLabel.toLowerCase().contains(_searchTerm.toLowerCase());
      final matchStatus = _statusFilter == null || z.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
  }

  Future<void> _openZoneDialog({ParkingZone? existing}) async {
    final result = await showDialog<ParkingZone>(
      context: context,
      builder: (_) => _ZoneFormDialog(existing: existing),
    );
    if (result == null) return;
    try {
      if (existing == null) {
        await _service.createZone(result);
      } else {
        await _service.updateZone(result);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(existing == null ? 'Zone created' : 'Zone updated')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _confirmDelete(ParkingZone zone) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete zone?'),
        content: Text('Are you sure you want to delete "${zone.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || zone.zoneID == null) return;
    try {
      await _service.deleteZone(zone.zoneID!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zone deleted')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: AdminPageHeader(
                title: 'Premise Management',
                subtitle: 'Configure parking zones, spots, and EV charging stations.',
              ),
            ),
            FilledButton.icon(
              onPressed: () => _openZoneDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Zone'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D2E9B),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildToolbar(),
        const SizedBox(height: 16),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          )
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchTerm = v),
              decoration: const InputDecoration(
                hintText: 'Search by zone name or type...',
                prefixIcon: Icon(Icons.search, size: 20),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<ZoneStatus?>(
            value: _statusFilter,
            hint: const Text('All statuses'),
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<ZoneStatus?>(value: null, child: Text('All statuses')),
              ...ZoneStatus.values.map((s) => DropdownMenuItem(
                value: s,
                child: Text(_statusLabel(s)),
              )),
            ],
            onChanged: (v) => setState(() => _statusFilter = v),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  String _statusLabel(ZoneStatus s) {
    switch (s) {
      case ZoneStatus.active: return 'Active';
      case ZoneStatus.maintenance: return 'Maintenance';
      case ZoneStatus.closed: return 'Closed';
    }
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Color(0xFF9CA3AF)),
          SizedBox(height: 12),
          Text('No zones found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
          SizedBox(height: 4),
          Text('Try adjusting your search or filters.', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: _ColHeader('ZONE NAME')),
                Expanded(flex: 2, child: _ColHeader('TYPE')),
                Expanded(flex: 2, child: _ColHeader('OCCUPANCY')),
                Expanded(flex: 1, child: _ColHeader('RATE')),
                Expanded(flex: 2, child: _ColHeader('STATUS')),
                SizedBox(width: 100, child: _ColHeader('ACTIONS')),
              ],
            ),
          ),
          for (int i = 0; i < _filtered.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _ZoneRow(
              zone: _filtered[i],
              onEdit: () => _openZoneDialog(existing: _filtered[i]),
              onDelete: () => _confirmDelete(_filtered[i]),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Text(
                  'Showing ${_filtered.length} of ${_zones.length} zones',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({required this.zone, required this.onEdit, required this.onDelete});
  final ParkingZone zone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _statusBg() {
    switch (zone.status) {
      case ZoneStatus.active: return const Color(0xFFD1FAE5);
      case ZoneStatus.maintenance: return const Color(0xFFFEF3C7);
      case ZoneStatus.closed: return const Color(0xFFFEE2E2);
    }
  }

  Color _statusFg() {
    switch (zone.status) {
      case ZoneStatus.active: return const Color(0xFF065F46);
      case ZoneStatus.maintenance: return const Color(0xFF92400E);
      case ZoneStatus.closed: return const Color(0xFF991B1B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              zone.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D24)),
            ),
          ),
          Expanded(flex: 2, child: Text(zone.typeLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)))),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${zone.occupiedSpots} / ${zone.totalSpots} (${zone.occupancyPercent}%)',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D24)),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: zone.occupancyPercent / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D2E9B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text('\$${zone.hourlyRate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D24)))),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  zone.statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusFg()),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: const Color(0xFF6B7280),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: const Color(0xFFDC2626),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneFormDialog extends StatefulWidget {
  const _ZoneFormDialog({this.existing});
  final ParkingZone? existing;

  @override
  State<_ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends State<_ZoneFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _total;
  late TextEditingController _available;
  late TextEditingController _rate;
  late ZoneType _type;
  late ZoneStatus _status;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _total = TextEditingController(text: e?.totalSpots.toString() ?? '');
    _available = TextEditingController(text: e?.availableSpots.toString() ?? '');
    _rate = TextEditingController(text: e?.hourlyRate.toStringAsFixed(2) ?? '');
    _type = e?.type ?? ZoneType.staff;
    _status = e?.status ?? ZoneStatus.active;
  }

  @override
  void dispose() {
    _name.dispose();
    _total.dispose();
    _available.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ParkingZone(
        zoneID: widget.existing?.zoneID,
        name: _name.text.trim(),
        type: _type,
        totalSpots: int.parse(_total.text),
        availableSpots: int.parse(_available.text),
        hourlyRate: double.parse(_rate.text),
        status: _status,
      ),
    );
  }

  String _typeLabel(ZoneType t) {
    switch (t) {
      case ZoneType.staff: return 'Staff';
      case ZoneType.student: return 'Student';
      case ZoneType.visitor: return 'Visitor';
      case ZoneType.ev: return 'EV Charging';
      case ZoneType.accessible: return 'Accessible';
    }
  }

  String _statusLabel(ZoneStatus s) {
    switch (s) {
      case ZoneStatus.active: return 'Active';
      case ZoneStatus.maintenance: return 'Maintenance';
      case ZoneStatus.closed: return 'Closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEdit ? 'Edit Zone' : 'Add New Zone',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Zone Name', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ZoneType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: ZoneType.values.map((t) => DropdownMenuItem(value: t, child: Text(_typeLabel(t)))).toList(),
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _total,
                          decoration: const InputDecoration(labelText: 'Total Spots', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Number required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _available,
                          decoration: const InputDecoration(labelText: 'Available', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Number required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _rate,
                    decoration: const InputDecoration(labelText: 'Hourly Rate (\$)', border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Number required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ZoneStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                    items: ZoneStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(_statusLabel(s)))).toList(),
                    onChanged: (v) => setState(() => _status = v ?? _status),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0D2E9B)),
                        child: Text(isEdit ? 'Save' : 'Create'),
                      ),
                    ],
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
