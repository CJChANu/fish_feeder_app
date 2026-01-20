import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../notifications/notification_center.dart';
import '../../services/connectivity_service.dart';
import '../../services/rtdb_service.dart';

import '../dashboard/dashboard_screen.dart';
import '../control/control_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeShell extends StatefulWidget {
  final String deviceId;

  final ThemeMode themeMode;
  final Future<void> Function(ThemeMode mode) onChangeTheme;
  final Future<void> Function() onChangeDevice;
  final Future<void> Function() onResetApp;

  const HomeShell({
    super.key,
    required this.deviceId,
    required this.themeMode,
    required this.onChangeTheme,
    required this.onChangeDevice,
    required this.onResetApp,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _rtdb = RtdbService();
  final _conn = ConnectivityService();
  final _notices = NotificationCenter();

  int _index = 0;
  bool _online = true;

  StreamSubscription<DatabaseEvent>? _liveSub;
  StreamSubscription<DatabaseEvent>? _configSub;

  // alarm thresholds (match your ESP32)
  static const int TEMP_LOW = 20;
  static const int TEMP_HIGH = 30;
  static const int PH_LOW = 6;
  static const int PH_HIGH = 8;
  static const int TURB_HIGH = 70;

  // one-shot alarm flags (avoid spamming)
  bool _tempAlarm = false;
  bool _phAlarm = false;
  bool _turbAlarm = false;

  String _lastFeedSeen = ''; // to detect changes

  @override
  void initState() {
    super.initState();

    _conn.isOnlineStream.listen((v) {
      setState(() => _online = v);
    });

    _startMonitor();
  }

  @override
  void didUpdateWidget(covariant HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deviceId != widget.deviceId) {
      _stopMonitor();
      _resetAlarmState();
      _startMonitor();
    }
  }

  void _resetAlarmState() {
    _tempAlarm = false;
    _phAlarm = false;
    _turbAlarm = false;
    _lastFeedSeen = '';
  }

  void _startMonitor() {
    // Monitor LIVE (sensors)
    _liveSub = _rtdb.liveRef(widget.deviceId).onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is! Map) return;

      final temp = int.tryParse('${v['temp'] ?? 0}') ?? 0;
      final ph = int.tryParse('${v['ph'] ?? 0}') ?? 0;
      final turb = int.tryParse('${v['turbidity'] ?? 0}') ?? 0;

      final tempBad = (temp < TEMP_LOW || temp > TEMP_HIGH);
      final phBad = (ph < PH_LOW || ph > PH_HIGH);
      final turbBad = (turb > TURB_HIGH);

      // one-shot notifications: only when it turns from OK -> BAD
      if (tempBad && !_tempAlarm) {
        _pushNotice(
          type: AppNoticeType.sensor,
          title: 'Temperature Alert',
          message: 'Temp out of range: $temp°C (safe: $TEMP_LOW–$TEMP_HIGH)',
        );
      }
      if (phBad && !_phAlarm) {
        _pushNotice(
          type: AppNoticeType.sensor,
          title: 'pH Alert',
          message: 'pH out of range: $ph (safe: $PH_LOW–$PH_HIGH)',
        );
      }
      if (turbBad && !_turbAlarm) {
        _pushNotice(
          type: AppNoticeType.sensor,
          title: 'Turbidity Alert',
          message: 'Turbidity too high: $turb% (limit: $TURB_HIGH%)',
        );
      }

      _tempAlarm = tempBad;
      _phAlarm = phBad;
      _turbAlarm = turbBad;
    });

    // Monitor CONFIG (feeding events)
    _configSub = _rtdb.configRef(widget.deviceId).onValue.listen((event) {
      final v = event.snapshot.value;
      if (v is! Map) return;

      final last = '${v['last_feed_time'] ?? ''}'.trim();
      if (last.isEmpty) return;

      if (_lastFeedSeen.isEmpty) {
        _lastFeedSeen = last; // first load
        return;
      }

      if (last != _lastFeedSeen) {
        _lastFeedSeen = last;
        _pushNotice(
          type: AppNoticeType.feed,
          title: 'Feeding حدث (Feed)',
          message: 'Device fed at: $last',
        );
      }
    });
  }

  void _stopMonitor() {
    _liveSub?.cancel();
    _configSub?.cancel();
    _liveSub = null;
    _configSub = null;
  }

  void _pushNotice({
    required AppNoticeType type,
    required String title,
    required String message,
  }) {
    // Save in notification center
    _notices.add(
      AppNotice(
        time: DateTime.now(),
        type: type,
        title: title,
        message: message,
      ),
    );

    // Show snackbar (only if UI mounted)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title • $message'),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _stopMonitor();
    _conn.dispose();
    super.dispose();
  }

  void _openNotices() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NotificationsScreen(center: _notices)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        deviceId: widget.deviceId,
        rtdb: _rtdb,
        online: _online,
        center: _notices,
      ),
      ControlScreen(
        deviceId: widget.deviceId,
        rtdb: _rtdb,
        online: _online,
        center: _notices,
      ),
      HistoryScreen(deviceId: widget.deviceId, rtdb: _rtdb, online: _online),
      SettingsScreen(
        deviceId: widget.deviceId,
        themeMode: widget.themeMode,
        onChangeTheme: widget.onChangeTheme,
        onChangeDevice: widget.onChangeDevice,
        onResetApp: widget.onResetApp,
        center: _notices,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Device: ${widget.deviceId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _openNotices,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_online)
            MaterialBanner(
              content: const Text('Offline: showing last known data.'),
              actions: [
                TextButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          Expanded(child: screens[_index]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Control'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
