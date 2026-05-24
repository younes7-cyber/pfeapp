import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for rootBundle
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'dart:async';

// Import des pages existantes
import 'package:pfeapp/profil/privicy.dart';
import 'package:pfeapp/profil/your_playlist.dart';
import 'package:pfeapp/succes.dart';
import 'package:pfeapp/succes2.dart';
import 'package:pfeapp/succes3.dart';
import 'package:pfeapp/sucess1.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'network_service.dart';
import 'network_wrapper.dart';
import 'signuppage/sign_up_page.dart';
import 'signuppage/verif.dart';
import 'loginpage/log_in_page.dart';
import 'forgotpass/passpage.dart';
import 'podly/podly.dart';
import 'nofication/nofi.dart';
import 'seeall/see_all.dart';
import 'podcast/podcast.dart';
import 'listen/listen.dart';
import 'package:pfeapp/channel/channel.dart';
import 'package:pfeapp/channel/create_channel.dart';
import 'package:pfeapp/completeprofiile/complete.dart';
import 'package:pfeapp/playlist/create_playlist.dart';
import 'package:pfeapp/playlist/playlist.dart';
import 'package:pfeapp/podcast/create_podcast.dart';
import 'package:pfeapp/profil/about.dart';
import 'package:pfeapp/profil/modif.dart';
import 'package:pfeapp/profil/modif1.dart';
import 'package:pfeapp/profil/stat.dart';
import 'package:pfeapp/profil/your_chaine.dart';
import 'package:pfeapp/forgotpass/reset.dart';
import 'package:pfeapp/homepage/homepage.dart';

// Gérer les notifications en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Vous pouvez ajouter une logique supplémentaire ici si nécessaire
}

// Canal de notification Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

// Plugin de notifications locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp();

  // Initialisation de Supabase
  await Supabase.initialize(
    url: 'https://migwbqbtfzszopvhdzre.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pZ3dicWJ0Znpzem9wdmhkenJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MjI3OTgsImV4cCI6MjA1NzQ5ODc5OH0.78NEfAWjrlWsjo_l9ZBLuKzNv13ikUWCBqE0DyCeZSA',
  );

  // Configurer le gestionnaire de messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Créer le canal de notification pour Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Configurer les paramètres d'initialisation pour iOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NetworkService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const Homepage();

  @override
  void initState() {
    super.initState();

    // Surveiller l'état d'authentification
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((
      firebase_auth.User? user,
    ) {
      if (user == null) {
      } else {
        // L'utilisateur est connecté, nous pouvons configurer ses sujets FCM
        _setupMessaging();
      }
    });

    checkAutoLogin();

    // Initialiser le plugin de notifications locales
    _initializeNotifications();

    // Configurer la gestion des notifications
    _setupNotificationHandlers();
  }

  // Initialiser les notifications locales
  Future<void> _initializeNotifications() async {
    // Dans _initializeNotifications()
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    // Utiliser votre nouvelle icône

    // Correction ici - nous utilisons la nouvelle façon de configurer iOS
    final DarwinInitializationSettings
    initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification n'est plus nécessaire dans les versions récentes
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Configurer la gestion des notifications
  Future<void> _setupNotificationHandlers() async {
    // Gérer les notifications lorsque l'application est en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Dans la méthode _setupNotificationHandlers()
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon:
                  '@drawable/notification_icon', // Utilisez l'icône spécifique aux notifications
            ),
          ),
          payload: message.data['route'],
        );
      }
    });

    // Gérer les notifications lorsque l'application est ouverte à partir d'une notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Naviguer vers la page de notifications
      if (message.data['route'] == '/nofi') {
        Navigator.pushNamed(navigatorKey.currentContext!, '/nofi');
      }
    });
  }

  // Configurer la messagerie pour l'utilisateur connecté
  Future<void> _setupMessaging() async {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Demander l'autorisation pour les notifications
      // ignore: unused_local_variable
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);

      // S'abonner au sujet correspondant à l'ID de l'utilisateur
      await FirebaseMessaging.instance.subscribeToTopic(currentUser.uid);
    }
  }

  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedEmail = prefs.getString('email');

    if (savedEmail != null) {
      if (mounted) {
        setState(() {
          _initialScreen = const Podlypage(); // Redirection automatique
        });
      }
    }
  }

  // Clé de navigation globale pour accéder au contexte
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey:
              navigatorKey, // Utilisé pour la navigation depuis les notifications
          builder: (context, child) {
            // On applique le wrapper de connectivité réseau à tous les écrans
            return NetworkWrapper(child: child!);
          },
          home: _initialScreen,
          theme: ThemeData(
            // Thème clair
            brightness: Brightness.light,
            primaryColor: const Color(0xFF754CEF),
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF754CEF),
              unselectedItemColor: Colors.grey,
            ),
          ),
          darkTheme: ThemeData(
            // Thème sombre
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF754CEF),
            scaffoldBackgroundColor: Colors.black,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              selectedItemColor: Color(0xFF754CEF),
              unselectedItemColor: Colors.grey,
            ),
          ),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          routes: {
            '/home': (context) => const Homepage(),
            '/SignUp': (context) => const SignUppage(),
            '/LogIn': (context) => const LoginPage(),
            '/complete': (context) => const Completepage(),
            '/pass': (context) => const Passpage(),
            '/podly': (context) => const Podlypage(),
            '/nofi': (context) => const NotificationPage(),
            '/seeall': (context) => const SeeAllpage(),
            '/channel': (context) => const Channelpage(),
            '/play': (context) => const Playlistpage(),
            '/podcast': (context) => const Podcastpage(),
            '/listen': (context) => const Listenpage(),
            '/ch': (context) => const CreateChannelPage(),
            '/po': (context) => const Createpodcastpage(),
            '/pl': (context) => const Createplaylistpage(),
            '/modif': (context) => const Modifpage(),
            '/modif1': (context) => const Modif1page(),
            '/your': (context) => const YourChainepage(),
            '/stat': (context) => const Statpage(),
            '/about': (context) => const Aboutpage(),
            '/verif': (context) => const Verifpage(),
            '/reset': (context) => const Resetpage(),
            '/your1': (context) => const Yourplaylistpage(),
            '/pryv': (context) => const Privipage(),
            '/succes': (context) => const Succespage(),
            '/sucess1': (context) => const Succes1page(),
            '/succes2': (context) => const Succes2page(),
            '/succes3': (context) => const Succes3page(),
          },
        );
      },
    );
  }
}

// Service FCM pour l'envoi de notifications avec le bon chemin (assests)
class FCMService {
  static Future<String> _getAccessToken() async {
    try {
      // Utilisation du chemin correct avec "assests" comme vous l'avez créé
      final serviceAccountJson = await rootBundle.loadString(
        'assests/noficationkeys/fir-317ff-bddc4e40627e.json',
      );

      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(serviceAccountJson),
      );
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      final client = await clientViaServiceAccount(credentials, scopes);
      return client.credentials.accessToken.data;
    } catch (e) {
      if (e.toString().contains('FileSystemException')) {
      } else if (e.toString().contains('FormatException')) {}
      rethrow;
    }
  }

  static Future<bool> sendNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      if (accessToken.isEmpty) {
        return false;
      }

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/fir-317ff/messages:send',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'topic': topic,
            'notification': {'title': title, 'body': body},
            'data': data ?? {'route': '/nofi'},
            'android': {
              'notification': {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'channel_id': 'high_importance_channel',
                'icon': '@drawable/notification_icon',
              },
            },
            'apns': {
              'payload': {
                'aps': {'category': 'NEW_MESSAGE_CATEGORY'},
              },
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
