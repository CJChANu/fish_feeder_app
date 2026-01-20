import 'package:flutter/material.dart';

import 'storage/app_prefs.dart';
import 'ui/device_picker/device_picker_screen.dart';
import 'ui/home/home_shell.dart';

class FishFeederApp extends StatefulWidget {
  const FishFeederApp({super.key});

  @override
  State<FishFeederApp> createState() => _FishFeederAppState();
}

class _FishFeederAppState extends State<FishFeederApp> {
  final _prefs = AppPrefs();

  ThemeMode _themeMode = ThemeMode.system;
  String? _deviceId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final theme = await _prefs.getThemeMode();
    final device = await _prefs.getDeviceId();
    setState(() {
      _themeMode = theme;
      _deviceId = device;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    setState(() => _themeMode = mode);
  }

  Future<void> _setDeviceId(String id) async {
    await _prefs.setDeviceId(id);
    setState(() => _deviceId = id);
  }

  Future<void> _resetApp() async {
    await _prefs.reset();
    setState(() {
      _themeMode = ThemeMode.system;
      _deviceId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Feeder',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: _deviceId == null
          ? DevicePickerScreen(onPicked: _setDeviceId)
          : HomeShell(
              deviceId: _deviceId!,
              themeMode: _themeMode,
              onChangeTheme: _setThemeMode,
              onChangeDevice: () async {
                // open picker
                final picked = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => DevicePickerScreen(onPicked: (id) async {})),
                );
                if (picked != null && picked.trim().isNotEmpty) {
                  await _setDeviceId(picked.trim());
                }
              },
              onResetApp: _resetApp,
            ),
    );
  }
}
