import 'package:flutter/material.dart';
import '../../notifications/notification_center.dart';

class NotificationsScreen extends StatefulWidget {
  final NotificationCenter center;

  const NotificationsScreen({super.key, required this.center});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    widget.center.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.center.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = widget.center.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () {
              widget.center.clear();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final n = items[i];
                return ListTile(
                  title: Text(n.title),
                  subtitle: Text('${n.message}\n${n.time}'),
                  isThreeLine: true,
                  leading: Icon(
                    n.type == AppNoticeType.feed
                        ? Icons.restaurant
                        : n.type == AppNoticeType.sensor
                        ? Icons.warning
                        : Icons.info,
                  ),
                );
              },
            ),
    );
  }
}
