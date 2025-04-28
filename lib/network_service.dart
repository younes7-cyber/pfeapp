import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkService extends ChangeNotifier {
  bool _isConnected = true;
  Timer? _connectivityTimer;
  // Vérification plus fréquente pour une meilleure réactivité
  final Duration _checkInterval = const Duration(seconds: 5);
  final Duration _reconnectInterval = const Duration(seconds: 2);

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
          .timeout(const Duration(seconds: 3));

      _isConnected = response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      _isConnected = false;

      // Si nous venons de perdre la connexion, on programme des vérifications
      // plus fréquentes pour détecter rapidement le retour de la connexion
      if (previousState && !_isConnected) {
        _scheduleReconnectionCheck();
      }
    }

    // Notifier seulement si l'état a changé
    if (previousState != _isConnected) {
      notifyListeners();
    }
  }

  void _scheduleReconnectionCheck() {
    // Vérifier plus fréquemment lorsque la connexion est perdue
    Future.delayed(_reconnectInterval, () {
      if (!_isConnected) {
        checkConnectivity();
        // Continue à essayer en cas d'échec
        if (!_isConnected) {
          _scheduleReconnectionCheck();
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivityTimer?.cancel();
    super.dispose();
  }
}
