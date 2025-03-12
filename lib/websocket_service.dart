import 'package:socket_io_client/socket_io_client.dart' as IO;

const String socketUrl =
    "https://pfeapp-qsx6.onrender.com"; // Remplace par ton API Render

class WebSocketService {
  late IO.Socket socket;

  // Fonction pour connecter au WebSocket
  void connect() {
    socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Utiliser WebSockets
            .disableAutoConnect() // Ne pas auto-connecter, on le fait manuellement
            .build());

    // Événement de connexion réussie
    socket.onConnect((_) {
      print(" Connecté au serveur WebSockets !");
    });

    // Événement de réception d'un nouveau message
    socket.on("newMessage", (data) {
      print(" Nouveau message reçu : $data");
    });

    // Événement de déconnexion
    socket.onDisconnect((_) {
      print(" Déconnecté du serveur WebSockets.");
    });

    socket.connect(); // Connexion au serveur
  }

  // Fonction pour se déconnecter proprement
  void disconnect() {
    socket.disconnect();
  }
}
