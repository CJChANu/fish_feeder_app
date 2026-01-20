import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../notifications/notification_center.dart';
import '../../services/rtdb_service.dart';
import '../components/app_card.dart';
import '../components/metric_tile.dart';
import '../components/section_header.dart';

class DashboardScreen extends StatelessWidget {
  final String deviceId;
  final RtdbService rtdb;
  final bool online;
  final NotificationCenter center;

  const DashboardScreen({
    super.key,
    required this.deviceId,
    required this.rtdb,
    required this.online,
    required this.center,
  });

  DateTime? _parseIso(String s) {
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveStream = rtdb.liveRef(deviceId).onValue;
    final configStream = rtdb.configRef(deviceId).onValue;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                icon: Icons.sensors,
                title: 'Live Sensors',
                subtitle: 'Realtime readings from your tank',
              ),
              const SizedBox(height: 14),
              StreamBuilder<DatabaseEvent>(
                stream: liveStream,
                builder: (context, snap) {
                  final data = snap.data?.snapshot.value;
                  int temp = 0, ph = 0, turb = 0;
                  String updated = 'NO_TIME';

                  if (data is Map) {
                    temp = int.tryParse('${data['temp'] ?? 0}') ?? 0;
                    ph = int.tryParse('${data['ph'] ?? 0}') ?? 0;
                    turb = int.tryParse('${data['turbidity'] ?? 0}') ?? 0;
                    updated = '${data['timestamp'] ?? 'NO_TIME'}';
                  }

                  return Column(
                    children: [
                      MetricTile(
                        icon: Icons.thermostat,
                        label: 'Temperature',
                        value: temp.toString(),
                        unit: '°C',
                      ),
                      const SizedBox(height: 10),
                      MetricTile(
                        icon: Icons.science,
                        label: 'pH',
                        value: ph.toString(),
                      ),
                      const SizedBox(height: 10),
                      MetricTile(
                        icon: Icons.water_drop,
                        label: 'Turbidity',
                        value: turb.toString(),
                        unit: '%',
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.update, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Updated: $updated')),
                          if (!online)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Offline',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                icon: Icons.restaurant,
                title: 'Feeding',
                subtitle: 'Last feeding time from config',
              ),
              const SizedBox(height: 14),
              StreamBuilder<DatabaseEvent>(
                stream: configStream,
                builder: (context, snap) {
                  final data = snap.data?.snapshot.value;
                  String lastFeed = 'NO FEED';

                  if (data is Map) {
                    lastFeed = '${data['last_feed_time'] ?? 'NO FEED'}';
                  }

                  final dt = _parseIso(lastFeed);
                  final pretty = dt == null
                      ? lastFeed
                      : DateFormat('yyyy-MM-dd HH:mm').format(dt);

                  return MetricTile(
                    icon: Icons.access_time,
                    label: 'Last feed time',
                    value: pretty,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
