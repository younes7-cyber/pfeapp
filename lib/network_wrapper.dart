import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'network_service.dart';
import 'no_connection_widget.dart';

class NetworkWrapper extends StatelessWidget {
  final Widget child;

  const NetworkWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkService>(
      builder: (context, network, _) {
        if (network.isConnected) {
          return child;
        } else {
          return Stack(
            children: [
              // Afficher l'écran en arrière-plan (optionnel)
              Opacity(
                opacity: 0.3,
                child: child,
              ),
              // Afficher le widget de non-connexion avec un bouton pour réessayer
              NoConnectionWidget(
                onRetry: () => network.checkConnectivity(),
              ),
            ],
          );
        }
      },
    );
  }
}
