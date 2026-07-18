import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { isConnected, isDisconnected }

class ConnectivityService extends StateNotifier<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  ConnectivityService() : super(ConnectivityStatus.isConnected) {
    _init();
  }

  void _init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // If we have any connectivity type other than none, we are connected
    final hasConnection = results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);
    state = hasConnection
        ? ConnectivityStatus.isConnected
        : ConnectivityStatus.isDisconnected;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityService, ConnectivityStatus>((ref) {
  return ConnectivityService();
});
