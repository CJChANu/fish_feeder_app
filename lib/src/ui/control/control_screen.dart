import 'package:flutter/material.dart';

import '../../notifications/notification_center.dart';
import '../../services/rtdb_service.dart';
import '../components/app_card.dart';
import '../components/section_header.dart';

class ControlScreen extends StatefulWidget {
  final String deviceId;
  final RtdbService rtdb;
  final bool online;
  final NotificationCenter center;

  const ControlScreen({
    super.key,
    required this.deviceId,
    required this.rtdb,
    required this.online,
    required this.center,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  int _interval = 0;
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.rtdb.configRef(widget.deviceId).onValue.listen((e) {
      final v = e.snapshot.value;
      if (v is Map && v['feed_interval_hours'] != null) {
        final n = int.tryParse('${v['feed_interval_hours']}') ?? 0;
        setState(() {
          _interval = n.clamp(0, 24);
          _text.text = _interval.toString();
        });
      }
    });
  }

  Future<void> _manualFeed() async {
    if (!widget.online) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual Feed'),
        content: const Text('Are you sure you want to feed now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.restaurant),
            label: const Text('Feed'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await widget.rtdb.triggerManualFeed(widget.deviceId);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Manual feed requested')));

    widget.center.add(
      AppNotice(
        time: DateTime.now(),
        type: AppNoticeType.feed,
        title: 'Manual feed',
        message: 'Manual feed requested for ${widget.deviceId}',
      ),
    );
  }

  Future<void> _saveInterval(int hours) async {
    if (!widget.online) return;
    final v = hours.clamp(0, 24);
    await widget.rtdb.setFeedIntervalHours(widget.deviceId, v);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Feed interval saved: $v hours')));
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.online;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                icon: Icons.restaurant_menu,
                title: 'Manual Feed',
                subtitle: 'Trigger feeding immediately',
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: disabled ? null : _manualFeed,
                icon: const Icon(Icons.restaurant),
                label: const Text('Feed Now'),
              ),
              if (disabled) ...[
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.wifi_off, size: 18),
                    SizedBox(width: 8),
                    Text('Offline: Manual feed disabled'),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                icon: Icons.schedule,
                title: 'Feed Interval',
                subtitle: 'Set auto-feeding interval in hours',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_interval hours',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: disabled ? null : () => _saveInterval(_interval),
                    icon: const Icon(Icons.save),
                    tooltip: 'Save',
                  ),
                ],
              ),
              Slider(
                value: _interval.toDouble(),
                min: 0,
                max: 24,
                divisions: 24,
                label: _interval.toString(),
                onChanged: disabled
                    ? null
                    : (v) {
                        setState(() {
                          _interval = v.round();
                          _text.text = _interval.toString();
                        });
                      },
                onChangeEnd: disabled ? null : (v) => _saveInterval(v.round()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      enabled: !disabled,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (val) {
                        final n = int.tryParse(val) ?? 0;
                        setState(() => _interval = n.clamp(0, 24));
                        _saveInterval(_interval);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: disabled
                        ? null
                        : () {
                            final n = int.tryParse(_text.text) ?? 0;
                            setState(() => _interval = n.clamp(0, 24));
                            _saveInterval(_interval);
                          },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
