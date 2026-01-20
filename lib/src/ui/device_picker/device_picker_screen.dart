import 'package:flutter/material.dart';
import '../../services/rtdb_service.dart';

class DevicePickerScreen extends StatefulWidget {
  final Future<void> Function(String deviceId) onPicked;

  const DevicePickerScreen({super.key, required this.onPicked});

  @override
  State<DevicePickerScreen> createState() => _DevicePickerScreenState();
}

class _DevicePickerScreenState extends State<DevicePickerScreen> {
  final _rtdb = RtdbService();
  final _controller = TextEditingController();
  List<String> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _loading = true);
    final list = await _rtdb.listDevices();
    setState(() {
      _devices = list;
      _loading = false;
    });
  }

  Future<void> _pick(String id) async {
    final deviceId = id.trim();
    if (deviceId.isEmpty) return;
    await widget.onPicked(deviceId);
    if (mounted) Navigator.of(context).pop(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Device')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter device ID (example: fish_feeder_001)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _pick(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Available devices'),
                const Spacer(),
                IconButton(
                  onPressed: _loadDevices,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _devices.isEmpty
                  ? const Center(child: Text('No devices found in RTDB root.'))
                  : ListView.separated(
                      itemCount: _devices.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final id = _devices[i];
                        return ListTile(
                          title: Text(id),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => _pick(id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
