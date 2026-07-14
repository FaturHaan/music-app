import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  bool get isOffline => _isOffline;
  bool get isOnline => !_isOffline;

  ConnectivityProvider() {
    _init();
  }

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    // If results only contain 'none', we are offline.
    final isCurrentlyOffline = results.every((result) => result == ConnectivityResult.none);
    
    if (_isOffline != isCurrentlyOffline) {
      _isOffline = isCurrentlyOffline;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
