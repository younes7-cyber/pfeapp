import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const LoginPage();
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _initialScreen,
      routes: {
        '/SignUp': (context) => const SignUppage(),
        '/LogIn': (context) => const LoginPage(),
        '/complete': (context) => const Completepage(),
        '/pass': (context) => const Passpage(),
        '/podly': (context) => const Podlypage(),
        '/nofi': (context) => const Nofipage(),
        '/seeall': (context) => const SeeAllpage(),
        '/channel': (context) => const Channelpage(),
        '/play': (context) => const Playlistpage(),
        '/podcast': (context) => const Podcastpage(),
        '/listen': (context) => const Listenpage(),
        '/ch': (context) => const CreateChannelpage(),
        '/po': (context) => const Createpodcastpage(),
        '/pl': (context) => const Createplaylistpage(),
        '/modif': (context) => const Modifpage(),
        '/modif1': (context) => const Modif1page(),
        '/your': (context) => const YourChainepage(),
        '/stat': (context) => const Statpage(),
        '/about': (context) => const Aboutpage(),
        '/verif': (context) => const Verifpage(),
        '/reset': (context) => const Resetpage(),
      },
    );
  }
}
