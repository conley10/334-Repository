import 'package:flutter/material.dart';
import '../../../models/admin/report_summary.dart';
import '../../../services/admin/reports_service.dart';
import '../widgets/admin_page_header.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final ReportsService _reportsService = ReportsService();
  ReportSummary? _summary;
  bool _isLoading = true;
  String? _error;

  String _selectedRange = 'Last 30 days';
  String _selectedReportType = 'Revenue';

  final List<String> _ranges = const ['Today', 'Last 7 days', 'Last 30 days', 'Last 90 days', 'This year'];
  final List<String> _reportTypes = const ['Revenue', 'Bookings', 'Occupancy', 'Violations'];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final summary = await _reportsService.getReportSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
                title: 'Reports & Analytics',
                subtitle: 'Generate and export operational reports.',
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _showExportSnack('CSV'),
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Export CSV'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A1D24),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _showExportSnack('PDF'),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Export PDF'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D2E9B),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildFilters(),
        const SizedBox(height: 24),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          _buildError()
        else ...[
          _buildKpiRow(),
          const SizedBox(height: 24),
          // TODO(backend): charts (Revenue Trend, Booking Distribution) still use mock data. Backend /admin/reports needs to expand ReportDto to include time-series data (matches the ReportData schema in api.yml).
          _buildChartsRow(),
          const SizedBox(height: 24),
          // TODO(backend): Top Performing Zones still uses mock data. Backend needs a new endpoint or expanded /admin/reports.
          _buildTopZones(),
        ],
      ],
    );
  }

  void _showExportSnack(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$format export started — you will receive an email when ready.')),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 40, color: Color(0xFFDC2626)),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _loadReport,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Retry'),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0D2E9B)),
        ),
      ]),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _FilterChip(
            icon: Icons.calendar_today_outlined,
            label: 'Date Range',
            value: _selectedRange,
            options: _ranges,
            onChanged: (v) => setState(() => _selectedRange = v),
          ),
          const SizedBox(width: 16),
          _FilterChip(
            icon: Icons.bar_chart_outlined,
            label: 'Report Type',
            value: _selectedReportType,
            options: _reportTypes,
            onChanged: (v) => setState(() => _selectedReportType = v),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedRange = 'Last 30 days';
                _selectedReportType = 'Revenue';
              });
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(child: _ReportKpi(title: 'TOTAL USERS', value: '${_summary?.totalUsers ?? 0}', change: 'Registered accounts', positive: true, icon: Icons.people_outline)),
        const SizedBox(width: 16),
        Expanded(child: _ReportKpi(title: 'TOTAL ZONES', value: '${_summary?.totalZones ?? 0}', change: 'Parking zones configured', positive: true, icon: Icons.location_on_outlined)),
        const SizedBox(width: 16),
        Expanded(child: _ReportKpi(title: 'TOTAL SPOTS', value: '${_summary?.totalSpots ?? 0}', change: 'Across all zones', positive: true, icon: Icons.local_parking_outlined)),
        const SizedBox(width: 16),
        Expanded(child: _ReportKpi(title: 'TOTAL VIOLATIONS', value: '${_summary?.totalViolations ?? 0}', change: 'Reported incidents', positive: false, icon: Icons.warning_amber_outlined)),
      ],
    );
  }

  Widget _buildChartsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: SizedBox(height: 320, child: _ChartCard(
          title: '$_selectedReportType Trend',
          subtitle: 'Daily totals for $_selectedRange',
          child: const _MockBarChart(),
        ))),
        const SizedBox(width: 16),
        Expanded(flex: 1, child: SizedBox(height: 320, child: _ChartCard(
          title: 'Booking Distribution',
          subtitle: 'By zone type',
          child: const _MockDonutLegend(),
        ))),
      ],
    );
  }

  Widget _buildTopZones() {
    final zones = const [
      _TopZoneData('North Campus Deck', '\$48,210', 92),
      _TopZoneData('South Deck Level 1', '\$32,180', 87),
      _TopZoneData('East Perimeter EV', '\$28,750', 81),
      _TopZoneData('Innovation Hub Visitor', '\$22,400', 74),
      _TopZoneData('Science West Underpass', '\$18,920', 68),
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(children: const [
            Text('Top Performing Zones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1D24))),
            Spacer(),
            Text('Sorted by revenue', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        for (int i = 0; i < zones.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(children: [
              SizedBox(
                width: 28,
                child: Text('${i + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
              ),
              Expanded(flex: 3, child: Text(zones[i].name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1D24)))),
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${zones[i].occupancyPercent}% avg occupancy', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: zones[i].occupancyPercent / 100,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D2E9B)),
                  ),
                ),
              ])),
              Expanded(flex: 1, child: Align(
                alignment: Alignment.centerRight,
                child: Text(zones[i].revenue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1D24))),
              )),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _TopZoneData {
  final String name;
  final String revenue;
  final int occupancyPercent;
  const _TopZoneData(this.name, this.revenue, this.occupancyPercent);
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.icon, required this.label, required this.value, required this.options, required this.onChanged});
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DB)), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(width: 6),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF6B7280)),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1D24)),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ),
      ]),
    );
  }
}

class _ReportKpi extends StatelessWidget {
  const _ReportKpi({required this.title, required this.value, required this.change, required this.positive, required this.icon});
  final String title;
  final String value;
  final String change;
  final bool positive;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), letterSpacing: 0.5))),
          Icon(icon, size: 18, color: const Color(0xFF0D2E9B)),
        ]),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A1D24))),
        const SizedBox(height: 6),
        Row(children: [
          Icon(positive ? Icons.trending_up : Icons.trending_down, size: 14, color: positive ? const Color(0xFF059669) : const Color(0xFFDC2626)),
          const SizedBox(width: 4),
          Expanded(child: Text(change, style: TextStyle(fontSize: 11, color: positive ? const Color(0xFF059669) : const Color(0xFFDC2626)))),
        ]),
      ]),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1D24))),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 24),
        SizedBox(height: 200, child: child),
      ]),
    );
  }
}

class _MockBarChart extends StatelessWidget {
  const _MockBarChart();

  @override
  Widget build(BuildContext context) {
    final heights = const [40.0, 65.0, 50.0, 80.0, 95.0, 70.0, 85.0, 110.0, 90.0, 130.0, 105.0, 145.0];
    final labels = const ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8', 'W9', 'W10', 'W11', 'W12'];
    return Column(children: [
      Expanded(
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (int i = 0; i < heights.length; i++) ...[
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: heights[i],
                decoration: BoxDecoration(
                  color: i == heights.length - 1 ? const Color(0xFF0D2E9B) : const Color(0xFF0D2E9B).withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ),
          ],
        ]),
      ),
      const SizedBox(height: 8),
      Row(children: [
        for (final l in labels) Expanded(child: Center(child: Text(l, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))))),
      ]),
    ]);
  }
}

class _MockDonutLegend extends StatelessWidget {
  const _MockDonutLegend();

  @override
  Widget build(BuildContext context) {
    final items = const [
      _LegendItem('Staff', 38, Color(0xFF0D2E9B)),
      _LegendItem('Student', 31, Color(0xFF3B82F6)),
      _LegendItem('Visitor', 18, Color(0xFF60A5FA)),
      _LegendItem('EV Charging', 9, Color(0xFF93C5FD)),
      _LegendItem('Accessible', 4, Color(0xFFBFDBFE)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final item in items) Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(child: Text(item.label, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1D24)))),
          Text('${item.percent}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))),
        ]),
      ),
    ]);
  }
}

class _LegendItem {
  final String label;
  final int percent;
  final Color color;
  const _LegendItem(this.label, this.percent, this.color);
}
