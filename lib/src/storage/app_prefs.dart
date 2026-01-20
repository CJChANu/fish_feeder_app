import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kDeviceId = 'device_id';
  static const _kTheme = 'theme_mode'; // system/light/dark

  Future<String?> getDeviceId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kDeviceId);
  }

  Future<void> setDeviceId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kDeviceId, id);
  }

  Future<ThemeMode> getThemeMode() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_kTheme) ?? 'system';
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final sp = await SharedPreferences.getInstance();
    final v = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await sp.setString(_kTheme, v);
  }

  Future<void> reset() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
  }
}
