import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'network_service.dart';
import 'no_connection_widget.dart';

class NetworkWrapper extends StatefulWidget {
  final Widget child;

  const NetworkWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NetworkWrapper> createState() => _NetworkWrapperState();
}

class _NetworkWrapperState extends State<NetworkWrapper> {
  bool _previousConnectionState = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, network, _) {
        // Si la connexion vient d'être rétablie, on peut
        // ajouter une logique supplémentaire ici
        if (!_previousConnectionState && network.isConnected) {
          // Utiliser un Future.delayed pour éviter les problèmes de build
          Future.delayed(Duration.zero, () {
            // Logique de rafraîchissement supplémentaire si nécessaire
            // Par exemple, vous pourriez rafraîchir les données
          });
        }

        // Mémoriser l'état actuel pour la prochaine construction
        _previousConnectionState = network.isConnected;

        if (network.isConnected) {
          return widget.child;
        } else {
          return Stack(
            children: [
              // Afficher l'écran en arrière-plan (optionnel)
              Opacity(
                opacity: 0.3,
                child: widget.child,
              ),
              // Afficher uniquement l'animation de non-connexion
              const NoConnectionWidget(),
            ],
          );
        }
      },
    );
  }
}
