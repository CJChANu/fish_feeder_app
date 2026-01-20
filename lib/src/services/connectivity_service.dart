import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get isOnlineStream => _controller.stream;

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    final initial = await _connectivity.checkConnectivity();
    _controller.add(initial != ConnectivityResult.none);

    _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(result != ConnectivityResult.none);
    });
  }

  void dispose() {
    _controller.close();
  }
}
