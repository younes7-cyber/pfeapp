import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkService extends ChangeNotifier {
  bool _isConnected = true;
  Timer? _connectivityTimer;
  final Duration _checkInterval = const Duration(seconds: 10);

  // URL fiable pour tester la connectivité
  final String _testUrl = 'https://www.google.com';

  bool get isConnected => _isConnected;

  NetworkService() {
    checkConnectivity();
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    _connectivityTimer = Timer.periodic(_checkInterval, (_) {
      checkConnectivity();
    });
  }

  Future<void> checkConnectivity() async {
    bool previousState = _isConnected;

    try {
      final response = await http
          .get(Uri.parse(_testUrl))
          .timeout(const Duration(seconds: 5));

      _isConnected = response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      _isConnected = false;
      print('Erreur de connexion: $e');
    }

    // Notifier seulement si l'état a changé
    if (previousState != _isConnected) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }
}
