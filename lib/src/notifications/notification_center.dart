import 'package:flutter/foundation.dart';

enum AppNoticeType { sensor, feed, system }

class AppNotice {
  final DateTime time;
  final AppNoticeType type;
  final String title;
  final String message;

  AppNotice({
    required this.time,
    required this.type,
    required this.title,
    required this.message,
  });
}

class NotificationCenter extends ChangeNotifier {
  final List<AppNotice> _items = [];

  List<AppNotice> get items => List.unmodifiable(_items);

  void add(AppNotice n) {
    _items.insert(0, n);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
