import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pfeapp/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Modifpage extends StatefulWidget {
  const Modifpage({super.key});

  @override
  State<Modifpage> createState() => _ModifpageState();
}

class _ModifpageState extends State<Modifpage> {
  late int n = 1;
  late int? q;
  final supabase1 = Supabase.instance.client;
  final FirebaseFirestore firestore1 = FirebaseFirestore.instance;
  Future<bool> _requestStoragePermission1() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _pickAndUploadImage1() async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) {
      print("Utilisateur non connecté.");
      return;
    }

    if (await _requestStoragePermission1()) {
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
          await Future.delayed(Duration(milliseconds: 500));

          // 📤 **Étape 3 : Télécharger la nouvelle image**
          final filePath =
              'channel/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase1.storage
              .from('pfeapp')
              .upload(filePath, selectedImageFile);

          // 🔗 **Étape 4 : Obtenir l'URL publique**
          final newPhotoUrl =
              supabase1.storage.from('pfeapp').getPublicUrl(filePath);

          // 📝 **Étape 5 : Mettre à jour Firestore avec la nouvelle URL**
          await channelDoc.reference.update({'photoUrl': newPhotoUrl});

          print("✅ Nouvelle photo enregistrée : $newPhotoUrl");
        }
      } catch (e) {
        print("❌ Erreur lors de l'importation de l'image : $e");
      }
    }
  }

  final supabase3 = Supabase.instance.client;
  final FirebaseFirestore firestore3 = FirebaseFirestore.instance;
  Future<bool> _requestStoragePermission3() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _pickAndUploadImage3(String id2) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) {
      print("Utilisateur non connecté.");
      return;
    }

    if (await _requestStoragePermission3()) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowCompression: true,
        );

        if (result != null && result.files.isNotEmpty) {
          File selectedImageFile = File(result.files.single.path!);

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('playlist')
              .where('id', isEqualTo: id2)
              .get();

          if (querySnapshot.docs.isEmpty) {
            print("❌ Erreur : Aucun document trouvé pour cet utilisateur.");
            return;
          }

          DocumentSnapshot channelDoc = querySnapshot.docs.first;
          await Future.delayed(Duration(milliseconds: 500));

          // 📤 **Étape 3 : Télécharger la nouvelle image**
          final filePath =
              'playlist/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase3.storage
              .from('pfeapp')
              .upload(filePath, selectedImageFile);

          // 🔗 **Étape 4 : Obtenir l'URL publique**
          final newPhotoUrl =
              supabase3.storage.from('pfeapp').getPublicUrl(filePath);

          // 📝 **Étape 5 : Mettre à jour Firestore avec la nouvelle URL**
          await channelDoc.reference.update({'photoUrl': newPhotoUrl});

          print("✅ Nouvelle photo enregistrée : $newPhotoUrl");
        }
      } catch (e) {
        print("❌ Erreur lors de l'importation de l'image : $e");
      }
    }
  }

  final supabase2 = Supabase.instance.client;
  final FirebaseFirestore firestore2 = FirebaseFirestore.instance;
  Future<bool> _requestStoragePermission2() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<void> _pickAndUploadImage2(String id1) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (userId.isEmpty) {
      print("Utilisateur non connecté.");
      return;
    }

    if (await _requestStoragePermission2()) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowCompression: true,
        );

        if (result != null && result.files.isNotEmpty) {
          File selectedImageFile = File(result.files.single.path!);

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .where('id', isEqualTo: id1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            print("❌ Erreur : Aucun document trouvé pour cet utilisateur.");
            return;
          }

          DocumentSnapshot channelDoc = querySnapshot.docs.first;
          await Future.delayed(Duration(milliseconds: 500));

          // 📤 **Étape 3 : Télécharger la nouvelle image**
          final filePath =
              'podcast/photo/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
          await supabase2.storage
              .from('pfeapp')
              .upload(filePath, selectedImageFile);

          // 🔗 **Étape 4 : Obtenir l'URL publique**
          final newPhotoUrl =
              supabase2.storage.from('pfeapp').getPublicUrl(filePath);

          // 📝 **Étape 5 : Mettre à jour Firestore avec la nouvelle URL**
          await channelDoc.reference.update({'urlPhoto': newPhotoUrl});
        }
      } catch (e) {
        print("❌ Erreur lors de l'importation de l'image : $e");
      }
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
      setState(() {});
    }
  }

  Future<void> fetchPlaylidtById(String id2) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: id2)
          .get();

      setState(() {
        playlistt = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      debugPrint("Podcasts récupérés : ${playlistt.length}");
    } catch (e) {
      debugPrint("Erreur lors du chargement des podcasts : $e");
    }
  }

  List<Map<String, dynamic>> playlistt = [];
  List<Map<String, dynamic>> user = [];
  List<Map<String, dynamic>> channels = [];
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
      setState(() {});
    }
  }

  Future<void> fetchPlaylistsByPodcastId(String id1) async {
    try {
      final playinPodSnapshot = await FirebaseFirestore.instance
          .collection('playinpod')
          .orderBy('date', descending: true)
          .where('podcastId', isEqualTo: id1)
          .get();

      final List<Map<String, dynamic>> playinPodData = playinPodSnapshot.docs
          .map((doc) => {
                "podcastId": doc['podcastId'],
                "playlistId": doc['playlistId'],
              })
          .toList();

      final List<String> playlistIds =
          playinPodData.map((item) => item["playlistId"] as String).toList();

      debugPrint("Playlists trouvées dans playinpod : $playlistIds");

      if (playlistIds.isNotEmpty) {
        // 2️⃣ Récupérer les playlists correspondant aux `playlistId`
        final playlistSnapshot = await FirebaseFirestore.instance
            .collection('playlist')
            .orderBy('createdAt', descending: true)
            .where(FieldPath.documentId, whereIn: playlistIds)
            .get();

        List<Map<String, dynamic>> loadedPlaylists = playlistSnapshot.docs
            .map((doc) => {
                  "id": doc.id,
                  ...doc.data(),
                })
            .toList();

        // 3️⃣ Associer les podcasts aux playlists
        final playinPodSnapshot2 = await FirebaseFirestore.instance
            .collection('playinpod')
            .orderBy('date', descending: true)
            .where('playlistId', whereIn: playlistIds)
            .get();

        Map<String, List<String>> podcastToPlaylists = {};
        for (var doc in playinPodSnapshot2.docs) {
          String podcastId = doc['podcastId'];
          String playlistId = doc['playlistId'];

          if (!podcastToPlaylists.containsKey(podcastId)) {
            podcastToPlaylists[podcastId] = [];
          }
          podcastToPlaylists[podcastId]!.add(playlistId);
        }

        final List<String> podcastIds = podcastToPlaylists.keys.toList();
        debugPrint("Podcasts liés aux playlists trouvés : $podcastIds");

        if (podcastIds.isNotEmpty) {
          // 4️⃣ Récupérer les podcasts avec `podcastIds`
          final podcastSnapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .orderBy('dateCreation', descending: true)
              .where(FieldPath.documentId, whereIn: podcastIds)
              .get();

          List<Map<String, dynamic>> loadedPodcasts =
              podcastSnapshot.docs.map((doc) {
            final podcastData = doc.data() as Map<String, dynamic>;
            final podcastId = doc.id;
            return {
              "id": podcastId,
              "playlistIds": podcastToPlaylists[podcastId] ?? [],
              ...podcastData,
            };
          }).toList();

          setState(() {
            playlist = loadedPlaylists;
            playinpod = loadedPodcasts;
          });

          debugPrint("Podcasts finaux récupérés : ${playinpod.length}");
        }
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des playlists : $e");
    }
  }

  List<Map<String, dynamic>> playlist = [];
  List<Map<String, dynamic>> playinpod = [];
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
              .collection('users')
              .where('userId', isEqualTo: userId)
              .get();

          if (querySnapshot.docs.isEmpty) {
            print("❌ Erreur : Aucun document trouvé pour cet utilisateur.");
            return;
          }

          DocumentSnapshot channelDoc = querySnapshot.docs.first;
          await Future.delayed(Duration(milliseconds: 500));

          // 📤 **Étape 3 : Télécharger la nouvelle image**
          final filePath =
              'profile/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('q')) {
          q = arguments['q'];
        }
        if (arguments.containsKey('id1')) {
          id1 = arguments['id1'];
        }
        if (arguments.containsKey('id2')) {
          id2 = arguments['id2'];
        }
        if (id1 != null) {
          await fetchPodcastById(id1!);
          await fetchPlaylistsByPodcastId(id1!);
        }
        if (id2 != null) {
          await fetchPlaylidtById(id2!);
        }

        await fetchuser();
        await fetchChannels();
      }

      setState(() => isLoading = false);
    });
  }

  List<Map<String, dynamic>> podcast = [];
  Future<void> fetchPodcastById(String id1) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: id1)
          .get();

      setState(() {
        podcast = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      debugPrint("Podcasts récupérés : ${podcast.length}");
    } catch (e) {
      debugPrint("Erreur lors du chargement des podcasts : $e");
    }
  }

  String? id1;
  String? id2;
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    final Size e = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: isLoading
              ? Center(child: Text(""))
              : Stack(
                  children: [
                    if (q == 2) ...[
                      Positioned(
                        top: e.height * 0.01,
                        left: e.width * 0.03,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/podly', (route) => false,
                                arguments: {'selectedIndex': 4});
                          },
                          icon: Image.network(
                            s18,
                            width: e.width * 0.07,
                            height: e.width * 0.07,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.02,
                          left: e.width * 0.15,
                          child: Text(
                            "Profile",
                            style: TextStyle(
                                fontSize: e.width * 0.06,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.08,
                          left: e.width * 0.38,
                          child: Container(
                            width: e.width * 0.25,
                            height: e.width * 0.25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(e.width * 0.2)),
                            child: ClipOval(
                              child: Image.network(
                                user[0]["photoUrl"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
                      Positioned(
                          top: e.height * 0.166,
                          left: e.width * 0.55,
                          child: Container(
                            width: e.width * 0.09,
                            height: e.width * 0.09,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(e.width * 0.2)),
                          )),
                      Positioned(
                          top: e.height * 0.171,
                          left: e.width * 0.56,
                          child: Container(
                              width: e.width * 0.07,
                              height: e.width * 0.07,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(e.width * 0.2)),
                              child: GestureDetector(
                                onTap: _pickAndUploadImage,
                                child: Image.network(s26),
                              ))),
                      Positioned(
                          top: e.height * 0.25,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                          top: e.height * 0.3,
                          left: e.width * 0.07,
                          child: Text(
                            "Profile Information",
                            style: TextStyle(
                                fontSize: e.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.37,
                          left: e.width * 0.07,
                          child: Text(
                            "Username",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.37,
                        left: e.width * 0.3,
                        child: Container(
                          width: e.width * 0.55,
                          height: e.height * 0.1,
                          child: Text(
                            "${user[0]["firstName"]} ${user[0]["lastName"]}",
                            style: TextStyle(
                              fontSize: e.width * 0.04,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Positioned(
                        top: e.height * 0.355,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/modif1',
                                arguments: {
                                  'n': 2
                                }, // Passe la valeur de r comme argument
                              );
                            },
                            child: Text(
                              ">",
                              style: TextStyle(
                                  fontSize: e.width * 0.06,
                                  color: Colors.black),
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.45,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                          top: e.height * 0.47,
                          left: e.width * 0.07,
                          child: Text(
                            "Personal Information",
                            style: TextStyle(
                                fontSize: e.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.54,
                          left: e.width * 0.07,
                          child: Text(
                            "User Id",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.54,
                          left: e.width * 0.3,
                          child: Container(
                              width: e.width * 0.55,
                              height: e.height * 0.1,
                              child: Text(
                                user[0]["userId"],
                                style: TextStyle(
                                  fontSize: e.width * 0.04,
                                ),
                                maxLines: 2,
                              ))),
                      Positioned(
                        top: e.height * 0.52,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "images/copier.png",
                              width: e.width * 0.05,
                              height: e.height * 0.05,
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.6,
                          left: e.width * 0.07,
                          child: Text(
                            "Email",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.6,
                          left: e.width * 0.3,
                          child: Container(
                              width: e.width * 0.55,
                              height: e.height * 0.1,
                              child: Text(
                                user[0]["email"],
                                style: TextStyle(
                                  fontSize: e.width * 0.04,
                                ),
                                maxLines: 2,
                              ))),
                      Positioned(
                        top: e.height * 0.585,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/modif1',
                                arguments: {
                                  'n': 3
                                }, // Passe la valeur de r comme argument
                              );
                            },
                            child: Text(
                              ">",
                              style: TextStyle(
                                  fontSize: e.width * 0.06,
                                  color: Colors.black),
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.66,
                          left: e.width * 0.07,
                          child: Text(
                            "Motpass",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.625,
                          left: e.width * 0.3,
                          child: Text(
                            "........",
                            style: TextStyle(
                              fontSize: e.width * 0.1,
                            ),
                          )),
                      Positioned(
                        top: e.height * 0.645,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/modif1',
                                arguments: {'n': 4},
                              );
                            },
                            child: Text(
                              ">",
                              style: TextStyle(
                                  fontSize: e.width * 0.06,
                                  color: Colors.black),
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.72,
                          left: e.width * 0.07,
                          child: Text(
                            "Country",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.72,
                          left: e.width * 0.3,
                          child: Container(
                              width: e.width * 0.55,
                              height: e.height * 0.1,
                              child: Text(
                                user[0]["country"],
                                style: TextStyle(
                                  fontSize: e.width * 0.04,
                                ),
                                maxLines: 2,
                              ))),
                      Positioned(
                          top: e.height * 0.78,
                          left: e.width * 0.07,
                          child: Text(
                            "Age",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.78,
                          left: e.width * 0.3,
                          child: Container(
                              width: e.width * 0.55,
                              height: e.height * 0.1,
                              child: Text(
                                user[0]["age"].toString(),
                                style: TextStyle(
                                  fontSize: e.width * 0.04,
                                ),
                                maxLines: 2,
                              ))),
                      Positioned(
                          top: e.height * 0.83,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                        top: e.height * 0.86,
                        left: e.width * 0.04,
                        child: Image.asset(
                          "images/delete.png",
                          width: e.width * 0.06,
                          height: e.width * 0.06,
                        ),
                      ),
                      Positioned(
                        top: e.height * 0.86,
                        left: e.width * 0.15,
                        child: Text(
                          "Delete User",
                          style: TextStyle(
                              fontSize: e.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    ],
                    if (q == 3) ...[
                      Positioned(
                        top: e.height * 0.01,
                        left: e.width * 0.03,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/your',
                              (route) => false,
                            );
                          },
                          icon: Image.network(
                            s18,
                            width: e.width * 0.07,
                            height: e.width * 0.07,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.02,
                          left: e.width * 0.15,
                          child: Text(
                            "Channel",
                            style: TextStyle(
                                fontSize: e.width * 0.06,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.08,
                          left: e.width * 0.38,
                          child: Container(
                            width: e.width * 0.25,
                            height: e.width * 0.25,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(e.width * 0.2)),
                            child: ClipOval(
                              child: Image.network(
                                channels[0]["photoUrl"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          )),
                      Positioned(
                          top: e.height * 0.166,
                          left: e.width * 0.55,
                          child: Container(
                            width: e.width * 0.09,
                            height: e.width * 0.09,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(e.width * 0.2)),
                          )),
                      Positioned(
                          top: e.height * 0.171,
                          left: e.width * 0.56,
                          child: Container(
                              width: e.width * 0.07,
                              height: e.width * 0.07,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(e.width * 0.2)),
                              child: GestureDetector(
                                onTap: _pickAndUploadImage1,
                                child: Image.network(s26),
                              ))),
                      Positioned(
                          top: e.height * 0.25,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                          top: e.height * 0.3,
                          left: e.width * 0.07,
                          child: Text(
                            "Channel Information",
                            style: TextStyle(
                                fontSize: e.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.37,
                          left: e.width * 0.07,
                          child: Text(
                            "Namechannel",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.37,
                          left: e.width * 0.35,
                          child: Container(
                              width: e.width * 0.5,
                              height: e.height * 0.1,
                              child: Text(
                                channels[0]["name"],
                                style: TextStyle(
                                  fontSize: e.width * 0.04,
                                ),
                                maxLines: 2,
                              ))),
                      Positioned(
                        top: e.height * 0.355,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/modif1',
                                arguments: {
                                  'n': 5
                                }, // Passe la valeur de r comme argument
                              );
                            },
                            child: Text(
                              ">",
                              style: TextStyle(
                                  fontSize: e.width * 0.06,
                                  color: Colors.black),
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.45,
                          left: e.width * 0.07,
                          child: Text(
                            "Channel Id",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.45,
                          left: e.width * 0.35,
                          child: Container(
                              width: e.width * 0.55,
                              height: e.height * 0.1,
                              child: Text(
                                channels[0]["id"],
                                style: TextStyle(
                                  fontSize: e.width * 0.04,
                                ),
                                maxLines: 2,
                              ))),
                      Positioned(
                        top: e.height * 0.43,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "images/copier.png",
                              width: e.width * 0.05,
                              height: e.height * 0.05,
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.55,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                        top: e.height * 0.6,
                        left: e.width * 0.04,
                        child: Image.asset(
                          "images/delete.png",
                          width: e.width * 0.06,
                          height: e.width * 0.06,
                        ),
                      ),
                      Positioned(
                        top: e.height * 0.6,
                        left: e.width * 0.15,
                        child: Text(
                          "Delete Channel",
                          style: TextStyle(
                              fontSize: e.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    ],
                    if (q == 4) ...[
                      Positioned(
                        top: e.height * 0.01,
                        left: e.width * 0.03,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/your',
                              (route) => false,
                            );
                          },
                          icon: Image.network(
                            s18,
                            width: e.width * 0.07,
                            height: e.width * 0.07,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.02,
                          left: e.width * 0.15,
                          child: Text(
                            "Podcast",
                            style: TextStyle(
                                fontSize: e.width * 0.06,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.08,
                          left: e.width * 0.38,
                          child: Container(
                            width: e.width * 0.25,
                            height: e.width * 0.25,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(e.width * 0.04),
                              image: DecorationImage(
                                image: NetworkImage(podcast[0]["urlPhoto"]),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  // Gérer l'erreur si l'image ne se charge pas
                                  print('Erreur de chargement de l\'image');
                                },
                              ),
                              color: Colors.grey[
                                  300], // Couleur de secours si l'image ne charge pas
                            ),
                          )),
                      Positioned(
                          top: e.height * 0.166,
                          left: e.width * 0.55,
                          child: Container(
                            width: e.width * 0.09,
                            height: e.width * 0.09,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(e.width * 0.2)),
                          )),
                      Positioned(
                          top: e.height * 0.171,
                          left: e.width * 0.56,
                          child: Container(
                              width: e.width * 0.07,
                              height: e.width * 0.07,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(e.width * 0.2)),
                              child: GestureDetector(
                                onTap: () {
                                  _pickAndUploadImage2(id1!);
                                },
                                child: Image.network(s26),
                              ))),
                      Positioned(
                          top: e.height * 0.25,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                          top: e.height * 0.3,
                          left: e.width * 0.07,
                          child: Text(
                            "Podcast Information",
                            style: TextStyle(
                                fontSize: e.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.37,
                          left: e.width * 0.07,
                          child: Text(
                            "Namepodcast",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.37,
                        left: e.width * 0.35,
                        child: Container(
                          height: e.height * 0.1,
                          width: e.width * 0.5,
                          child: Text(
                            podcast[0]["name"],
                            style: TextStyle(
                              fontSize: e.width * 0.04,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.43,
                          left: e.width * 0.07,
                          child: Text(
                            "Podcast Id",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.43,
                        left: e.width * 0.35,
                        child: Container(
                          height: e.height * 0.1,
                          width: e.width * 0.5,
                          child: Text(
                            podcast[0]["id"],
                            style: TextStyle(
                              fontSize: e.width * 0.04,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Positioned(
                        top: e.height * 0.41,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "images/copier.png",
                              width: e.width * 0.05,
                              height: e.height * 0.05,
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.49,
                          left: e.width * 0.07,
                          child: Text(
                            "Description",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.49,
                        left: e.width * 0.35,
                        child: Container(
                          height: e.height * 0.1,
                          width: e.width * 0.5,
                          child: Text(
                            podcast[0]["description"],
                            style: TextStyle(
                              fontSize: e.width * 0.04,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.55,
                          left: e.width * 0.07,
                          child: Text(
                            "Category",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.55,
                        left: e.width * 0.35,
                        child: Container(
                          height: e.height * 0.1,
                          width: e.width * 0.5,
                          child: Text(
                            podcast[0]["category"],
                            style: TextStyle(
                              fontSize: e.width * 0.04,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.61,
                          left: e.width * 0.07,
                          child: Text(
                            "Playlist",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      /*                                          child: Container(
                                            width: c.width * 0.7,
                                            height: c.width *
                                                0.06, // Définit une hauteur pour éviter les bugs d'affichage

                                            
                                          ),
 */
                      Positioned(
                        top: e.height * 0.61,
                        left: e.width * 0.35,
                        child: Container(
                          height: e.height * 0.1,
                          width: e.width * 0.5,
                          child: // Affiche un loader pendant le chargement
                              Text(
                            playinpod
                                .firstWhere((p) => p["id"] == id1,
                                    orElse: () =>
                                        {"playlistIds": []})["playlistIds"]
                                .map((pid) => playlist.firstWhere(
                                    (pl) => pl["id"] == pid,
                                    orElse: () => {"name": "Inconnue"})["name"])
                                .join("   •   "), // Séparer par un symbole
                            style: TextStyle(
                              fontSize: e.width * 0.04,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.68,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                          top: e.height * 0.675,
                          left: e.width * 0.04,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/modif1',
                                    arguments: {
                                      'n': 6,
                                      'id1': podcast[0]["id"]
                                    });
                              },
                              child: Text(
                                "Add To A Playlist",
                                style: TextStyle(
                                    fontSize: e.width * 0.04,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))),
                      Positioned(
                          top: e.height * 0.75,
                          left: e.width * 0.07,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/modif1',
                                    arguments: {
                                      'n': 9,
                                      'id1': podcast[0]["id"]
                                    });
                              },
                              child: Text(
                                "Delete From A Playlist",
                                style: TextStyle(
                                    fontSize: e.width * 0.04,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ))),
                      Positioned(
                        top: e.height * 0.81,
                        left: e.width * 0.04,
                        child: Image.asset(
                          "images/delete.png",
                          width: e.width * 0.06,
                          height: e.width * 0.06,
                        ),
                      ),
                      Positioned(
                        top: e.height * 0.81,
                        left: e.width * 0.15,
                        child: Text(
                          "Delete Podcast",
                          style: TextStyle(
                              fontSize: e.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.86,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                    ],
                    if (q == 5) ...[
                      Positioned(
                        top: e.height * 0.01,
                        left: e.width * 0.03,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/your',
                              (route) => false,
                            );
                          },
                          icon: Image.network(
                            s18,
                            width: e.width * 0.07,
                            height: e.width * 0.07,
                          ),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.02,
                          left: e.width * 0.15,
                          child: Text(
                            "Playlist",
                            style: TextStyle(
                                fontSize: e.width * 0.06,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.08,
                          left: e.width * 0.38,
                          child: Container(
                            width: e.width * 0.25,
                            height: e.width * 0.25,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(e.width * 0.04),
                              image: DecorationImage(
                                image: NetworkImage(playlistt[0]["photoUrl"]),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  // Gérer l'erreur si l'image ne se charge pas
                                  print('Erreur de chargement de l\'image');
                                },
                              ),
                              color: Colors.grey[
                                  300], // Couleur de secours si l'image ne charge pas
                            ),
                          )),
                      Positioned(
                          top: e.height * 0.166,
                          left: e.width * 0.55,
                          child: Container(
                            width: e.width * 0.09,
                            height: e.width * 0.09,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(e.width * 0.2)),
                          )),
                      Positioned(
                          top: e.height * 0.171,
                          left: e.width * 0.56,
                          child: Container(
                              width: e.width * 0.07,
                              height: e.width * 0.07,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(e.width * 0.2)),
                              child: GestureDetector(
                                onTap: () {
                                  _pickAndUploadImage3(id2!);
                                },
                                child: Image.network(s26),
                              ))),
                      Positioned(
                          top: e.height * 0.25,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                          top: e.height * 0.3,
                          left: e.width * 0.07,
                          child: Text(
                            "Playlist Information",
                            style: TextStyle(
                                fontSize: e.width * 0.05,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.37,
                          left: e.width * 0.07,
                          child: Text(
                            "Nameplaylist",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.37,
                        left: e.width * 0.35,
                        child: Container(
                            width: e.width * 0.5,
                            height: e.height * 0.1,
                            child: Text(
                              playlistt[0]["name"],
                              style: TextStyle(
                                fontSize: e.width * 0.04,
                              ),
                              maxLines: 2,
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.43,
                          left: e.width * 0.07,
                          child: Text(
                            "Playlist Id",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.43,
                        left: e.width * 0.35,
                        child: Container(
                            width: e.width * 0.5,
                            height: e.height * 0.1,
                            child: Text(
                              playlistt[0]["id"],
                              style: TextStyle(
                                fontSize: e.width * 0.04,
                              ),
                              maxLines: 2,
                            )),
                      ),
                      Positioned(
                        top: e.height * 0.41,
                        right: e.width * 0.01,
                        child: TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "images/copier.png",
                              width: e.width * 0.05,
                              height: e.height * 0.05,
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.49,
                          left: e.width * 0.07,
                          child: Text(
                            "Description",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                        top: e.height * 0.49,
                        left: e.width * 0.35,
                        child: Container(
                            width: e.width * 0.5,
                            height: e.height * 0.1,
                            child: Text(
                              playlistt[0]["description"],
                              style: TextStyle(
                                fontSize: e.width * 0.04,
                              ),
                              maxLines: 2,
                            )),
                      ),
                      Positioned(
                          top: e.height * 0.55,
                          left: e.width * 0.07,
                          child: Text(
                            "Nbrpodcast",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )),
                      Positioned(
                          top: e.height * 0.55,
                          left: e.width * 0.35,
                          child: Container(
                              width: e.width * 0.5,
                              height: e.height * 0.1,
                              child: Text(
                                formatLikes(playlistt[0]["podcast"]),
                                style: TextStyle(
                                  fontSize: e.width * 0.04,
                                ),
                                maxLines: 2,
                              ))),
                      Positioned(
                          top: e.height * 0.62,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                      Positioned(
                          top: e.height * 0.64,
                          left: e.width * 0.04,
                          child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/modif1',
                                    arguments: {
                                      'n': 7,
                                      'id1': playlistt[0]["id"]
                                    });
                              },
                              child: Text(
                                "Add More Podcast",
                                style: TextStyle(
                                    fontSize: e.width * 0.04,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))),
                      Positioned(
                        top: e.height * 0.69,
                        left: e.width * 0.04,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/modif1',
                                arguments: {'n': 8, 'id2': playlistt[0]["id"]});
                          },
                          child: Text(
                            "Delete From Podcast ",
                            style: TextStyle(
                                fontSize: e.width * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ),
                      ),
                      Positioned(
                        top: e.height * 0.77,
                        left: e.width * 0.04,
                        child: Image.asset(
                          "images/delete.png",
                          width: e.width * 0.06,
                          height: e.width * 0.06,
                        ),
                      ),
                      Positioned(
                        top: e.height * 0.77,
                        left: e.width * 0.15,
                        child: Text(
                          "Delete Playlist",
                          style: TextStyle(
                              fontSize: e.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                      Positioned(
                          top: e.height * 0.83,
                          left: e.width * 0.07,
                          right: e.width * 0.07,
                          child: Container(
                            width: e.width * 0.8,
                            height: e.height * 0.002, // Épaisseur de la ligne
                            color: Colors.grey[400],
                          )),
                    ],
                  ],
                )),
    ));
  }
}
