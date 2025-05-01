import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:pfeapp/profil/privicy.dart';
import 'package:pfeapp/profil/your_playlist.dart';
import 'package:pfeapp/succes.dart';
import 'package:pfeapp/succes2.dart';
import 'package:pfeapp/succes3.dart';
import 'package:pfeapp/sucess1.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'network_service.dart'; // Nouvelle importation
import 'network_wrapper.dart'; // Nouvelle importation
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pfeapp/homepage/homepage.dart';

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) => NetworkService()), // Remplacé par NetworkService
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const Homepage();

  @override
  void initState() {
    super.initState();
    firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((firebase_auth.User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });

    checkAutoLogin();
  }

  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedEmail = prefs.getString('email');

    if (savedEmail != null) {
      setState(() {
        _initialScreen = const Podlypage(); // Redirection automatique
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // On applique le wrapper de connectivité réseau à tous les écrans
            return NetworkWrapper(
                child: child!); // Utilisation de NetworkWrapper
          },
          home: _initialScreen,
          theme: ThemeData(
            // Thème clair
            brightness: Brightness.light,
            primaryColor: const Color(0xFF754CEF),
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
              // Ajoutez d'autres styles de texte selon vos besoins
            ),
            // Personnaliser d'autres éléments du thème selon vos besoins
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
              // Ajoutez d'autres styles de texte selon vos besoins
            ),
            // Personnaliser d'autres éléments du thème sombre
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
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
