import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../services/rtdb_service.dart';
import '../components/app_card.dart';
import '../components/section_header.dart';

enum HistoryRange { h1, h6, h24 }

class HistoryScreen extends StatefulWidget {
  final String deviceId;
  final RtdbService rtdb;
  final bool online;

  const HistoryScreen({
    super.key,
    required this.deviceId,
    required this.rtdb,
    required this.online,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryRange _range = HistoryRange.h6;
  bool _loading = true;

  List<_Sample> _temp = [];
  List<_Sample> _ph = [];
  List<_Sample> _turb = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Duration get _dur => switch (_range) {
    HistoryRange.h1 => const Duration(hours: 1),
    HistoryRange.h6 => const Duration(hours: 6),
    HistoryRange.h24 => const Duration(hours: 24),
  };

  DateTime? _parseIso(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    try {
      return DateTime.parse(t);
    } catch (_) {
      return null;
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final items = await widget.rtdb.getHistoryLastN(
      widget.deviceId,
      limit: 1200,
    );
    final cutoff = DateTime.now().subtract(_dur);

    final temp = <_Sample>[];
    final ph = <_Sample>[];
    final turb = <_Sample>[];

    for (final m in items) {
      final dt = _parseIso((m['timestamp'] ?? '').toString());
      if (dt == null) continue;
      if (dt.isBefore(cutoff)) continue;

      final t = int.tryParse('${m['temp'] ?? 0}') ?? 0;
      final p = int.tryParse('${m['ph'] ?? 0}') ?? 0;
      final b = int.tryParse('${m['turbidity'] ?? 0}') ?? 0;

      temp.add(_Sample(dt, t.toDouble()));
      ph.add(_Sample(dt, p.toDouble()));
      turb.add(_Sample(dt, b.toDouble()));
    }

    setState(() {
      _temp = temp;
      _ph = ph;
      _turb = turb;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chips = [
      _RangeChip(label: '1h', value: HistoryRange.h1),
      _RangeChip(label: '6h', value: HistoryRange.h6),
      _RangeChip(label: '24h', value: HistoryRange.h24),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.bar_chart,
                title: 'History',
                subtitle: widget.online
                    ? 'Showing last ${_rangeLabel(_range)}'
                    : 'Offline: showing last loaded history',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Wrap(
                    spacing: 8,
                    children: chips.map((c) {
                      final selected = _range == c.value;
                      return ChoiceChip(
                        label: Text(c.label),
                        selected: selected,
                        onSelected: (_) async {
                          setState(() => _range = c.value);
                          await _load();
                        },
                      );
                    }).toList(),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        _MetricBarCard(
          title: 'Temperature (°C)',
          icon: Icons.thermostat,
          maxY: 50,
          data: _temp,
          loading: _loading,
        ),
        const SizedBox(height: 12),

        _MetricBarCard(
          title: 'pH',
          icon: Icons.science,
          maxY: 14,
          data: _ph,
          loading: _loading,
        ),
        const SizedBox(height: 12),

        _MetricBarCard(
          title: 'Turbidity (%)',
          icon: Icons.water_drop,
          maxY: 100,
          data: _turb,
          loading: _loading,
          rightAxisPercent: true, // like your screenshot
        ),
      ],
    );
  }

  String _rangeLabel(HistoryRange r) => switch (r) {
    HistoryRange.h1 => '1 hour',
    HistoryRange.h6 => '6 hours',
    HistoryRange.h24 => '24 hours',
  };
}

class _RangeChip {
  final String label;
  final HistoryRange value;
  _RangeChip({required this.label, required this.value});
}

class _Sample {
  final DateTime time;
  final double value;
  _Sample(this.time, this.value);
}

class _MetricBarCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double maxY;
  final List<_Sample> data;
  final bool loading;
  final bool rightAxisPercent;

  const _MetricBarCard({
    required this.title,
    required this.icon,
    required this.maxY,
    required this.data,
    required this.loading,
    this.rightAxisPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppCard(
      child: SizedBox(
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(icon: icon, title: title),
            const SizedBox(height: 14),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : data.isEmpty
                  ? const Center(child: Text('No data for selected range'))
                  : BarChart(
                      BarChartData(
                        maxY: maxY,
                        alignment: BarChartAlignment.spaceBetween,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxY / 4,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: rightAxisPercent
                              ? AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 44,
                                    interval: 50,
                                    getTitlesWidget: (v, meta) => Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text('${v.toInt()}%'),
                                    ),
                                  ),
                                )
                              : const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                        ),
                        borderData: FlBorderData(show: false),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, gi, rod, ri) {
                              final i = group.x.toInt();
                              if (i < 0 || i >= data.length) return null;
                              final dt = data[i].time;
                              final hh = dt.hour.toString().padLeft(2, '0');
                              final mm = dt.minute.toString().padLeft(2, '0');
                              return BarTooltipItem(
                                '$hh:$mm\n${rod.toY.toStringAsFixed(0)}',
                                TextStyle(color: cs.onSurface),
                              );
                            },
                          ),
                        ),
                        barGroups: _buildBars(context, data),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBars(BuildContext context, List<_Sample> data) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.primary;

    // Limit bars to keep it readable (like your screenshot)
    final trimmed = data.length > 80 ? data.sublist(data.length - 80) : data;

    return List.generate(trimmed.length, (i) {
      final v = trimmed[i].value.clamp(0, maxY).toDouble();
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: v,
            width: 5,
            borderRadius: BorderRadius.circular(6),
            color: color,
          ),
        ],
      );
    });
  }
}
