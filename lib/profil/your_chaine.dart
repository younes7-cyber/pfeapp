import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:http/http.dart' as http;

class YourChainepage extends StatefulWidget {
  const YourChainepage({super.key});
  @override
  State<YourChainepage> createState() => _YourChainepageState();
}

class _YourChainepageState extends State<YourChainepage>
    with SingleTickerProviderStateMixin {
  late int your = 1;
  late int s = 0;
  bool hasError = false;
  List<Map<String, dynamic>> user = [];
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> playlist = [];
  bool isPressed = false;
  bool showWhiteContainer = false;
  late int r = 1;
  String formatLikes(num likes) {
    // Utiliser un pattern personnalisé avec exactement 2 décimales
    final formatter = NumberFormat('#,##0.00', 'fr');
    // Pour les nombres importants, appliquer une logique de compactage manuel
    if (likes >= 1000000000000000) {
      return formatter
              .format(likes / 1000000000000000)
              .replaceAll('\u202f', '') +
          'P';
    } else if (likes >= 1000000000000) {
      return formatter.format(likes / 1000000000000).replaceAll('\u202f', '') +
          'T';
    } else if (likes >= 1000000000) {
      return formatter.format(likes / 1000000000).replaceAll('\u202f', '') +
          'G';
    } else if (likes >= 1000000) {
      return formatter.format(likes / 1000000).replaceAll('\u202f', '') + 'M';
    } else if (likes >= 1000) {
      return formatter.format(likes / 1000).replaceAll('\u202f', '') + 'k';
    } else if (likes <= 999) {
      final formatter1 = NumberFormat('#0', 'fr');
      return formatter1.format(likes);
    }

    return formatter.format(likes).replaceAll('\u202f', '');
  }

  late int pp = 1;
  late int feat = 1;
  bool isLoading = true;
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await fetchChannels();
      await fetchpodcasts();
      await fetchplaylists();
      await fetchuser();
      setState(() => isLoading = false);
    });
  }

  final supabase = Supabase.instance.client;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _pickAndUploadImage() async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) {
      print("Utilisateur non connecté.");
      return;
    }

    if (await _requestStoragePermission()) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowCompression: true,
        );

        if (result != null && result.files.isNotEmpty) {
          File selectedImageFile = File(result.files.single.path!);

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', isEqualTo: userId)
              .get();

          if (querySnapshot.docs.isEmpty) {
            print("❌ Erreur : Aucun document trouvé pour cet utilisateur.");
            return;
          }

          DocumentSnapshot channelDoc = querySnapshot.docs.first;
          /*  String? currentPhotoUrl = channelDoc.get('photoUrl');
          if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty) {
            try {
              print("🔍 URL actuelle de la photo : $currentPhotoUrl");

              // Extraire le chemin du fichier
              String fileName = currentPhotoUrl.split('/').last;
              String filePath = 'channel/$fileName';

              print("📄 Chemin complet du fichier : $filePath");

              try {
                // Utiliser le SDK Supabase avec anon key ou service key
                // Ces clés doivent être configurées lors de l'initialisation de Supabase
                final response =
                    await supabase.storage.from('pfeapp').remove([filePath]);

                print("📊 Réponse Supabase: $response");
              } catch (e) {
                print("⚠️ Erreur Supabase : $e");

                // Tentative alternative : appel HTTP avec clé API Supabase
                try {
                  // Remplacer par votre clé anon ou service_role de Supabase
                  final supabaseApiKey =
                      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pZ3dicWJ0Znpzem9wdmhkenJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MjI3OTgsImV4cCI6MjA1NzQ5ODc5OH0.78NEfAWjrlWsjo_l9ZBLuKzNv13ikUWCBqE0DyCeZSA';

                  final response = await http.delete(
                    Uri.parse(
                        'https://migwbqbtfzszopvhdzre.supabase.co/storage/v1/object/pfeapp/$filePath'),
                    headers: {
                      'apikey': supabaseApiKey,
                      'Content-Type': 'application/json',
                    },
                  );

                  print("🔄 Status HTTP: ${response.statusCode}");
                  print("🔄 Corps HTTP: ${response.body}");
                } catch (httpError) {
                  print("❌ Erreur HTTP : $httpError");
                }
              }
            } catch (e) {
              print("❌ Erreur générale : $e");
            }
          }*/ // ⏳ **Étape 2 : Pause rapide pour éviter les conflits (optionnel)**
          await Future.delayed(Duration(milliseconds: 500));

          // 📤 **Étape 3 : Télécharger la nouvelle image**
          final filePath =
              'channel/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase.storage
              .from('pfeapp')
              .upload(filePath, selectedImageFile);

          // 🔗 **Étape 4 : Obtenir l'URL publique**
          final newPhotoUrl =
              supabase.storage.from('pfeapp').getPublicUrl(filePath);

          // 📝 **Étape 5 : Mettre à jour Firestore avec la nouvelle URL**
          await channelDoc.reference.update({'photoUrl': newPhotoUrl});

          print("✅ Nouvelle photo enregistrée : $newPhotoUrl");
        }
      } catch (e) {
        print("❌ Erreur lors de l'importation de l'image : $e");
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null) {
      if (arguments.containsKey('your')) {
        your = arguments['your'];
      }
    }
  }

  Future<void> fetchChannels() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de chaînes trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des chaînes : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        channels = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {
        hasError = true;
      });
    }
  }

  Future<void> fetchuser() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de chaînes trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des chaînes : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        user = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {
        hasError = true;
      });
    }
  }

  Future<void> fetchpodcasts() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy('dateCreation', descending: true)
          .where('idUser', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de podcast trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des podcast : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        podcast = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        s = podcast.fold(0, (sum, item) => sum + (item["likes"] ?? 0) as int);
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des podcast : $e');
      setState(() {
        hasError = true;
      });
    }
  }

  Future<void> fetchplaylists() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .orderBy('createdAt', descending: true)
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de playlist trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des playlist : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        playlist = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {
        hasError = true;
      });
    }
  }

  late TabController _tabController1;
  @override
  void dispose() {
    _tabController1.dispose();
    super.dispose();
  }

  late int q = 1;
  late int y = 1;
  late int o = 1;
  late int CH = 1;
  @override
  Widget build(BuildContext context) {
    final Size v = MediaQuery.of(context).size;

    if (hasError) {
      return const Scaffold(
        body: Center(
          child: Text('Une erreur est survenue.'),
        ),
      );
    }

    if (channels.isEmpty) {
      return isLoading
          ? Center(child: Text(""))
          : Scaffold(
              body: SafeArea(
                  child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      width:
                          double.infinity, // Added to provide width constraint
                      height:
                          double.infinity, // Added to provide height constraint

                      child: Column(children: [
                        SizedBox(
                          height: v.height * 0.15,
                          child: Stack(
                            children: [
                              Positioned(
                                top: v.height * 0.02,
                                left: v.width * 0.05,
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Image.network(
                                      s18,
                                      width: v.width * 0.07,
                                      height: v.width * 0.07,
                                    )),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                            height: v.height * 0.4,
                            width: v.width * 0.7,
                            child: Column(
                              children: [
                                Container(
                                  height: v.height * 0.3,
                                  width: v.width * 0.8,
                                  child: Image.network(
                                    s27,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Text(
                                  "There Is Not Channel Yet. You Must Create It",
                                  style: TextStyle(
                                      fontSize: v.width * 0.04,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                        SizedBox(
                          height: v.height * 0.1,
                        ),
                        SizedBox(
                          height: v.height * 0.075,
                          width: v.width * 0.6,
                          child: Container(
                            height: v.height * 0.075,
                            width: v.width * 0.6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF754CEF),
                              borderRadius:
                                  BorderRadius.circular(v.width * 0.05),
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/ch',
                                  arguments: 3,
                                );
                              },
                              child: Text(
                                "Create",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: v.width * 0.042),
                              ),
                            ),
                          ),
                        ),
                      ]))));
    }
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        width: double.infinity, // Added to provide width constraint
        height: double.infinity, // Added to provide height constraint

        child: isLoading
            ? Center(child: Text(""))
            : Column(
                children: [
                  SizedBox(
                    height: v.width * 0.2,
                    child: Stack(
                      children: [
                        Positioned(
                          top: v.height * 0.01,
                          left: v.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              if (your == 2) {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/podly', (route) => false,
                                    arguments: {'selectedIndex': 0});
                              }
                              if (your == 3) {
                                Navigator.pop(context);
                              }
                              if (your == 4) {
                                Navigator.pop(context);
                              }
                            },
                            icon: Image.network(
                              s18,
                              width: v.width * 0.07,
                              height: v.width * 0.07,
                            ),
                          ),
                        ),
                        Positioned(
                            top: v.height * 0.01,
                            right: v.width * 0.03,
                            child: PopupMenuButton(
                              icon: Image.network(
                                s34,
                                width: v.width * 0.06,
                                height: v.width * 0.06,
                              ),
                              color: Colors
                                  .white, // Définit la couleur de fond du menu popup
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  height: v.width * 0.12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Couleur de fond du container
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          s35,
                                          width: v.width * 0.05,
                                          height: v.width * 0.05,
                                        ),
                                        SizedBox(width: v.width * 0.02),
                                        Text(
                                          "Your Information",
                                          style: TextStyle(
                                            fontSize: v.width * 0.04,
                                            color: Colors
                                                .black, // Couleur du texte
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context, '/modif',
                                        arguments: {'q': 3});
                                  },
                                ),
                              ],
                            )),
                        Positioned(
                            top: v.height * 0.02,
                            left: v.width * 0.35,
                            child: Container(
                                width: v.width * 0.4,
                                height: v.height * 0.1,
                                // decoration: BoxDecoration(color: Colors.black),
                                child: Text(
                                  channels[0]["name"],
                                  style: TextStyle(
                                      fontSize: v.width * 0.06,
                                      fontWeight: FontWeight.bold),
                                ))),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: v.width,
                    height: v.width * 0.32,
                    child: Stack(
                      children: [
                        Positioned(
                            top: v.height * 0.03,
                            left: v.width * 0.38,
                            child: Container(
                              width: v.width * 0.25,
                              height: v.width * 0.25,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(v.width * 0.2)),
                              child: ClipOval(
                                child: Image.network(
                                  channels[0]["photoUrl"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                        Positioned(
                            top: v.height * 0.116,
                            left: v.width * 0.55,
                            child: Container(
                              width: v.width * 0.09,
                              height: v.width * 0.09,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(v.width * 0.2)),
                            )),
                        Positioned(
                            top: v.height * 0.121,
                            left: v.width * 0.56,
                            child: Container(
                                width: v.width * 0.07,
                                height: v.width * 0.07,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(v.width * 0.2)),
                                child: GestureDetector(
                                  onTap: _pickAndUploadImage,
                                  child: Image.network(s26),
                                ))),
                        Positioned(
                            top: v.height * 0.25,
                            left: v.width * 0.07,
                            right: v.width * 0.07,
                            child: Container(
                              width: v.width * 0.8,
                              height: v.height * 0.002, // Épaisseur de la ligne
                              color: Colors.grey[400],
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: v.width,
                    height: v.width * 0.02,
                  ),
                  SizedBox(
                      child: Stack(children: [
                    Positioned(
                      child: Text(
                        user[0]["email"],
                        style: TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.grey),
                      ),
                    ),
                  ])),
                  SizedBox(
                    width: v.width,
                    height: v.width * 0.05,
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        SizedBox(
                          width: v.width * 0.17,
                        ),
                        Column(
                          children: [
                            Text(
                              formatLikes(channels[0]["following"]),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: v.width * 0.04),
                            ),
                            Text(
                              "Following",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: v.width * 0.1,
                        ),
                        Column(
                          children: [
                            Text(
                              formatLikes(channels[0]["followers"]),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: v.width * 0.04),
                            ),
                            Text(
                              "Followers",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: v.width * 0.1,
                        ),
                        Column(
                          children: [
                            Text(
                              formatLikes(s),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: v.width * 0.04),
                            ),
                            Text(
                              "Likes",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: v.width * 0.05),
                  SizedBox(
                    height: v.height * 0.07,
                    width: v.width,
                    child: Row(
                      // Remplacer Stack et Positioned par une simple Row
                      children: [
                        // Premier élément (Upload Podcast)
                        Expanded(
                          // Utiliser Expanded pour partager l'espace disponible
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/po', arguments: 3);
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                    width: v.width * 0.08), // Marge à gauche

                                Image.network(s30,
                                    width: v.width * 0.06,
                                    height: v.width * 0.06),
                                SizedBox(
                                    width: v.width *
                                        0.03), // Espace entre l'image et le texte
                                Text("Upload Podcast"),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: v.width * 0.03),
                        // Deuxième élément (Create Playlist)
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/pl', arguments: 3);
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                    width: v.width * 0.04), // Marge à gauche
                                Image.network(s33,
                                    width: v.width * 0.06,
                                    height: v.width * 0.06),
                                SizedBox(
                                    width: v.width *
                                        0.03), // Espace entre l'image et le texte
                                Text("Create Playlist"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController1,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Podcast'),
                      Tab(text: 'Playlist'),
                    ],
                  ),

                  // Tab bar view - Fixed section
                  Expanded(
                    child: TabBarView(
                      controller: _tabController1,
                      children: [
                        Column(children: [
                          // See All header for Podcast
                          if (podcast.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: v.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "See All",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: v.width * 0.035,
                                            color: const Color(0xFF754CEF)),
                                      ),
                                      SizedBox(width: v.width * 0.01),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/seeall',
                                            arguments: {
                                              'r': 12
                                            }, // Passe la valeur de r comme argument
                                          );

                                          print(r);
                                        },
                                        icon: Image.network(
                                          s36,
                                          width: v.width * 0.04,
                                          height: v.width * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: podcast.length,
                                itemBuilder: (context, index) {
                                  final item = podcast[index];
                                  return Container(
                                    margin: EdgeInsets.all(v.width * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(v.width * 0.05),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    width: v.width * 0.95,
                                    height: v.width * 0.3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/podcast',
                                          arguments: {
                                            'idpod': item["id"],
                                            'feat': 3,
                                          }, // Envoie l'ID
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(width: v.width * 0.01),
                                          Container(
                                            height: v.width * 0.2,
                                            width: v.width * 0.2,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      v.width * 0.04),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    item["urlPhoto"]!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: v.width * 0.01),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: v.width * 0.35,
                                                child: Text(
                                                  item["name"]!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: v.width * 0.04,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: v.width * 0.015),
                                            ],
                                          ),
                                          SizedBox(
                                            width: v.width * 0.05,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  width: v.width *
                                                      0.21, // Constrain the width of the progress bar
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            child:
                                                                Image.network(
                                                                    s37),
                                                            width:
                                                                v.width * 0.05,
                                                            height:
                                                                v.width * 0.05,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                v.width * 0.01,
                                                          ),
                                                          Text(
                                                            formatLikes(
                                                                item["likes"]),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    v.width *
                                                                        0.035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: v.width * 0.02,
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            child:
                                                                Image.network(
                                                                    s14),
                                                            width:
                                                                v.width * 0.05,
                                                            height:
                                                                v.width * 0.05,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                v.width * 0.01,
                                                          ),
                                                          Text(
                                                            formatLikes(
                                                                item["vue"]),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    v.width *
                                                                        0.035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: v.width * 0.02,
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            child:
                                                                Image.network(
                                                                    s38),
                                                            width:
                                                                v.width * 0.05,
                                                            height:
                                                                v.width * 0.05,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                v.width * 0.01,
                                                          ),
                                                          Text(
                                                            formatLikes(item[
                                                                "comments"]),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    v.width *
                                                                        0.035,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/modif',
                                                  arguments: {
                                                    'id1': item["id"],
                                                    'q': 4
                                                  });
                                            },
                                            icon: Image.network(
                                              s34,
                                              width: v.width * 0.05,
                                              height: v.width * 0.05,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (podcast.isEmpty) ...[
                            Column(children: [
                              SizedBox(
                                height: v.height * 0.05,
                              ),
                              SizedBox(
                                width: v.width * 0.7,
                                height: v.height * 0.3,
                                child: Container(
                                  child: Image.network(s28),
                                ),
                              ),
                              Text("No Podcast Please Upload",
                                  style: TextStyle(
                                      fontSize: v.width * 0.04,
                                      fontWeight: FontWeight.bold)),
                            ])
                          ],
                        ]),
                        Column(children: [
                          // See All header for Podcast
                          if (playlist.isEmpty) ...[
                            Column(children: [
                              SizedBox(
                                height: v.height * 0.05,
                              ),
                              SizedBox(
                                width: v.width * 0.7,
                                height: v.height * 0.3,
                                child: Container(
                                  child: Image.network(s28),
                                ),
                              ),
                              Text("No Playlist Please Create",
                                  style: TextStyle(
                                      fontSize: v.width * 0.04,
                                      fontWeight: FontWeight.bold)),
                            ])
                          ],
                          if (playlist.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: v.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "See All",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: v.width * 0.035,
                                            color: const Color(0xFF754CEF)),
                                      ),
                                      SizedBox(width: v.width * 0.01),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/seeall',
                                            arguments: {
                                              'r': 13
                                            }, // Passe la valeur de r comme argument
                                          );

                                          print(r);
                                        },
                                        icon: Image.network(
                                          s36,
                                          width: v.width * 0.04,
                                          height: v.width * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: // Playlist tab
                                  ListView.builder(
                                itemCount: playlist.length,
                                itemBuilder: (context, index) {
                                  final item = playlist[index];
                                  return Container(
                                    margin: EdgeInsets.all(v.width * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(v.width * 0.05),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    width: v.width * 0.95,
                                    height: v.width * 0.3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/play',
                                            arguments: {
                                              'idplay': item["id"],
                                              'pp': 3
                                            });
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: v.width * 0.01,
                                          ),
                                          Container(
                                            height: v.width * 0.25,
                                            width: v.width * 0.25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      v.width * 0.04),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    item["photoUrl"]!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: v.width * 0.04),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: v.width * 0.02),
                                              SizedBox(
                                                width: v.width * 0.3,
                                                child: Text(
                                                  item["name"]!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: v.width * 0.04,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: v.width * 0.03,
                                          ),
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: v.width *
                                                        0.19, // Constrain the width of the progress bar
                                                    child: Column(children: [
                                                      SizedBox(
                                                        height: v.width * 0.02,
                                                      ),
                                                      Column(children: [
                                                        Text(
                                                          formatLikes(
                                                              item["podcast"]!),
                                                          style: TextStyle(
                                                            fontSize:
                                                                v.width * 0.035,
                                                          ),
                                                          maxLines: 4,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(
                                                          width: v.width * 0.03,
                                                        ),
                                                        Text(
                                                          "Podcast",
                                                          style: TextStyle(
                                                            fontSize:
                                                                v.width * 0.035,
                                                          ),
                                                          maxLines: 4,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ])
                                                    ]))
                                              ]),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/modif',
                                                arguments: {
                                                  'id2': item["id"],
                                                  'q': 5
                                                },
                                              );
                                            },
                                            icon: Image.network(
                                              s34,
                                              width: v.width * 0.05,
                                              height: v.width * 0.05,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    ));
  }
}
