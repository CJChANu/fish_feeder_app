import 'package:firebase_database/firebase_database.dart';

class RtdbService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DatabaseReference configRef(String deviceId) => _db.ref('$deviceId/config');
  DatabaseReference liveRef(String deviceId) => _db.ref('$deviceId/live');
  DatabaseReference historyRef(String deviceId) => _db.ref('$deviceId/history');
  DatabaseReference feedLogRef(String deviceId) =>
      _db.ref('$deviceId/feed_log');

  Future<List<String>> listDevices() async {
    final snap = await _db.ref('/').get();
    if (!snap.exists) return [];
    final v = snap.value;
    if (v is Map) {
      return v.keys.map((e) => e.toString()).toList()..sort();
    }
    return [];
  }

  Future<void> triggerManualFeed(String deviceId) async {
    await configRef(deviceId).update({'manual_feed': true});
  }

  Future<void> setFeedIntervalHours(String deviceId, int hours) async {
    await configRef(deviceId).update({'feed_interval_hours': hours});
  }

  /// Pull last N history records then filter client-side by time string.
  Future<List<Map<String, dynamic>>> getHistoryLastN(
    String deviceId, {
    int limit = 500,
  }) async {
    final snap = await historyRef(deviceId).limitToLast(limit).get();
    if (!snap.exists) return [];

    final v = snap.value;
    if (v is! Map) return [];

    final list = <Map<String, dynamic>>[];
    v.forEach((key, value) {
      if (value is Map) {
        list.add(value.map((k, val) => MapEntry(k.toString(), val)));
      }
    });

    // Sort by timestamp string if present
    list.sort(
      (a, b) => (a['timestamp'] ?? '').toString().compareTo(
        (b['timestamp'] ?? '').toString(),
      ),
    );
    return list;
  }
}
