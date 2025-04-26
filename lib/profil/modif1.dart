import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:pfeapp/constants.dart';

class Modif1page extends StatefulWidget {
  const Modif1page({super.key});

  @override
  State<Modif1page> createState() => _Modif1pageState();
}

class _Modif1pageState extends State<Modif1page> {
  final _playlistController = TextEditingController();
  String? _selectedPlaylistId;
  List<SelectedListItem<PlaylistItem>> play = [];
  List<SelectedListItem<PlaylistItem>> play1 = [];
  List<SelectedListItem<PlaylistItem>> play2 = [];
  List<SelectedListItem<PlaylistItem>> play3 = [];
  late int n = 1;
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('n')) {
          n = arguments['n'];
        }
        if (arguments.containsKey('id1')) {
          idp = arguments['id1'];
        }
        if (arguments.containsKey('id2')) {
          idpp = arguments['id2'];
        }
        if (idp != null) {
          await _loadPlaylists(idp!);
          await _loadPlaylists1(idp!);
        }
        if (idpp != null) {
          await _loadPlaylist(idpp!);
          await _loadPlaylist1(idpp!);
        }
      }

      setState(() => isLoading = false);
    });
  }

  String? idp;
  String? idpp;
  Future<void> _loadPlaylists1(String idp) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      if (currentUser == null) return;

      // Étape 1 : Récupérer les playlistId déjà liés au podcast
      final playinpodSnapshot = await FirebaseFirestore.instance
          .collection('playinpod')
          .where('podcastId', isEqualTo: idp)
          .get();

      final List<String> existingPlaylistIds = playinpodSnapshot.docs
          .map((doc) => doc['playlistId'] as String)
          .toList();

      // Étape 2 : Récupérer les playlists de l'utilisateur
      final playlistSnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .where('userId', isEqualTo: currentUser)
          .get();

      // Étape 3 : Filtrer les playlists non déjà liées au podcast
      final List<SelectedListItem<PlaylistItem>> fetchedPlaylists =
          playlistSnapshot.docs
              .where((doc) => existingPlaylistIds.contains(doc.id))
              .map((doc) {
        final data = doc.data() as Map<String, dynamic>; // ✅ Cast nécessaire
        final name = data['name'] ?? 'Unknown Playlist';
        final id = doc.id;
        return SelectedListItem<PlaylistItem>(
          data: PlaylistItem(id: id, name: name),
        );
      }).toList();

      // Mettre à jour l'état
      setState(() {
        play1.addAll(fetchedPlaylists);
      });
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }

  Future<void> _loadPlaylists(String idp) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      if (currentUser == null) return;

      // Étape 1 : Récupérer les playlistId déjà liés au podcast
      final playinpodSnapshot = await FirebaseFirestore.instance
          .collection('playinpod')
          .where('podcastId', isEqualTo: idp)
          .get();

      final List<String> existingPlaylistIds = playinpodSnapshot.docs
          .map((doc) => doc['playlistId'] as String)
          .toList();

      // Étape 2 : Récupérer les playlists de l'utilisateur
      final playlistSnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .where('userId', isEqualTo: currentUser)
          .get();

      // Étape 3 : Filtrer les playlists non déjà liées au podcast
      final List<SelectedListItem<PlaylistItem>> fetchedPlaylists =
          playlistSnapshot.docs
              .where((doc) => !existingPlaylistIds.contains(doc.id))
              .map((doc) {
        final data = doc.data() as Map<String, dynamic>; // ✅ Cast nécessaire
        final name = data['name'] ?? 'Unknown Playlist';
        final id = doc.id;
        return SelectedListItem<PlaylistItem>(
          data: PlaylistItem(id: id, name: name),
        );
      }).toList();

      // Mettre à jour l'état
      setState(() {
        play.addAll(fetchedPlaylists);
      });
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }

  Future<void> _loadPlaylist1(String idpp) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      if (currentUser == null) return;

      // Étape 1 : Récupérer les playlistId déjà liés au podcast
      final playinpodSnapshot = await FirebaseFirestore.instance
          .collection('playinpod')
          .where('playlistId', isEqualTo: idpp)
          .get();
      print('playinpod documents trouvés : ${playinpodSnapshot.docs.length}');
      final List<String> existingPlaylistIds = playinpodSnapshot.docs
          .map((doc) => doc['podcastId'] as String)
          .toList();

      // Étape 2 : Récupérer les playlists de l'utilisateur
      final playlistSnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('idUser', isEqualTo: currentUser)
          .get();

      // Étape 3 : Filtrer les playlists non déjà liées au podcast
      final List<SelectedListItem<PlaylistItem>> fetchedPlaylists =
          playlistSnapshot.docs
              .where((doc) => existingPlaylistIds.contains(doc.id))
              .map((doc) {
        final data = doc.data() as Map<String, dynamic>; // ✅ Cast nécessaire
        final name = data['name'] ?? 'Unknown Playlist';
        final id = doc.id;
        return SelectedListItem<PlaylistItem>(
          data: PlaylistItem(id: id, name: name),
        );
      }).toList();

      // Mettre à jour l'état
      setState(() {
        play3.addAll(fetchedPlaylists);
      });
    } catch (e) {
      print('Error loading playlists: $e');
    }
  }

  Future<void> _loadPlaylist(String idpp) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser?.uid;
      if (currentUser == null) {
        print('Utilisateur non connecté.');
        return;
      }

      // Étape 1 : Récupérer les podcastId liés à cette playlist (inverse de l’autre logique)
      final playinpodSnapshot = await FirebaseFirestore.instance
          .collection('playinpod')
          .where('playlistId', isEqualTo: idpp)
          .get();

      print('playinpod documents trouvés : ${playinpodSnapshot.docs.length}');

      final List<String> existingPodcastIds = playinpodSnapshot.docs.map((doc) {
        final data = doc.data();
        print('playinpod doc: ${data}');
        return data['podcastId'] as String;
      }).toList();

      print('Liste des podcastId déjà liés : $existingPodcastIds');

      // Étape 2 : Récupérer les podcasts de l'utilisateur
      final podcastSnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('idUser', isEqualTo: currentUser)
          .get();

      print('Podcasts utilisateur trouvés : ${podcastSnapshot.docs.length}');

      // Étape 3 : Filtrer les podcasts non liés à la playlist
      final List<SelectedListItem<PlaylistItem>> fetchedPlaylists =
          podcastSnapshot.docs
              .where((doc) => !existingPodcastIds.contains(doc.id))
              .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Unknown Playlist';
        final id = doc.id;
        print('Podcast retenu : $id - $name');
        return SelectedListItem<PlaylistItem>(
          data: PlaylistItem(id: id, name: name),
        );
      }).toList();

      print(
          'Nombre de podcasts filtrés ajoutés à play2 : ${fetchedPlaylists.length}');

      // Mettre à jour l'état
      setState(() {
        play2.addAll(fetchedPlaylists);
      });
    } catch (e) {
      print('Erreur lors du chargement : $e');
    }
  }

  final emailController = TextEditingController();
  bool isLoading = true;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController channel = TextEditingController();
  final TextEditingController pass = TextEditingController();
  bool _obscureText2 = true;
  @override
  Widget build(BuildContext context) {
    final Size i = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: isLoading
            ? Center(child: Text(""))
            : Stack(
                children: [
                  if (n == 2) ...[
                    Positioned(
                      top: i.height * 0.01,
                      left: i.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.network(
                          s18,
                          width: i.width * 0.07,
                          height: i.width * 0.07,
                        ),
                      ),
                    ),
                    Positioned(
                        top: i.height * 0.02,
                        left: i.width * 0.15,
                        child: Text(
                          "Change Name",
                          style: TextStyle(
                              fontSize: i.width * 0.06,
                              fontWeight: FontWeight.bold),
                        )),
                    Positioned(
                        top: i.height * 0.1,
                        left: i.width * 0.05,
                        child: Container(
                          width: i.width,
                          child: Text(
                            "You Can Change Your Username And Use The Real Name For Esasy Utilisation ",
                            style: TextStyle(color: Colors.grey),
                            maxLines: 2,
                          ),
                        )),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "FirstName",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.2525,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: SizedBox(
                        width: i.width - 60,
                        child: TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),

                            hintText: "Enter New FirstName",
                            hintStyle: const TextStyle(color: Colors.grey),
                            // Utilisation d'une image depuis les assets comme prefixIcon
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(i.width *
                                  0.028), // Ajustez le padding selon vos besoins
                              child: Image.network(
                                s22, // Remplacez par le chemin de votre icône
                                width: i.width *
                                    0.05, // Ajustez la taille selon vos besoins
                                height: i.width * 0.05,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide: const BorderSide(
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.36,
                      left: i.width * 0.1,
                      child: const Text(
                        "LastName",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.3925,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: SizedBox(
                        width: i.width - 60,
                        child: TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),

                            hintText: "Enter New LastName",
                            hintStyle: const TextStyle(color: Colors.grey),
                            // Utilisation d'une image depuis les assets comme prefixIcon
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(i.width *
                                  0.028), // Ajustez le padding selon vos besoins
                              child: Image.network(
                                s22, // Remplacez par le chemin de votre icône
                                width: i.width *
                                    0.05, // Ajustez la taille selon vos besoins
                                height: i.width * 0.05,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide: const BorderSide(
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.52,
                      left: i.width * 0.18,
                      child: Container(
                        height: i.height * 0.075,
                        width: i.width * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF754CEF),
                          borderRadius: BorderRadius.circular(i.width * 0.05),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            String firstName = firstNameController.text.trim();
                            String lastName = lastNameController.text.trim();
                            final uid = FirebaseAuth.instance.currentUser?.uid;

                            if (firstName.isEmpty || lastName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Fields must not be empty')),
                              );
                              return;
                            }

                            if (uid == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User not logged in')),
                              );
                              return;
                            }

                            try {
                              final querySnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .where('userId', isEqualTo: uid)
                                  .limit(
                                      1) // On suppose qu’il y a un seul document par user
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                final docRef =
                                    querySnapshot.docs.first.reference;

                                await docRef.update({
                                  'firstName': firstName,
                                  'lastName': lastName,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Profile updated successfully')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('User document not found')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update: $e')),
                              );
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white, fontSize: i.width * 0.042),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (n == 4) ...[
                    Positioned(
                      top: i.height * 0.01,
                      left: i.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.network(
                          s18,
                          width: i.width * 0.07,
                          height: i.width * 0.07,
                        ),
                      ),
                    ),
                    Positioned(
                        top: i.height * 0.02,
                        left: i.width * 0.15,
                        child: Text(
                          "Change Motpass",
                          style: TextStyle(
                              fontSize: i.width * 0.06,
                              fontWeight: FontWeight.bold),
                        )),
                    Positioned(
                        top: i.height * 0.1,
                        left: i.width * 0.05,
                        child: Container(
                          width: i.width,
                          child: Text(
                            "You Can Change Your Motpass If You Don't Remeber Or Your Corrently Motpass Is Easy To Know ",
                            style: TextStyle(color: Colors.grey),
                            maxLines: 2,
                          ),
                        )),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "Motpass",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.2525,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: SizedBox(
                        width: i.width - 60,
                        child: TextField(
                          controller: pass,
                          obscureText: _obscureText2,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),
                            hintText: "Enter New Password",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(i.width * 0.028),
                              child: Image.network(
                                s13,
                                width: i.width * 0.05,
                                height: 0.05,
                              ),
                            ),
                            // Correction de la syntaxe du suffixIcon
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText2 = !_obscureText2;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(i.width * 0.028),
                                child: Image.network(
                                  s14,
                                  width: i.width * 0.05,
                                  height: i.width * 0.05,
                                ),
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide: const BorderSide(
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.36,
                      left: i.width * 0.18,
                      child: Container(
                        height: i.height * 0.075,
                        width: i.width * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF754CEF),
                          borderRadius: BorderRadius.circular(i.width * 0.05),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser
                                ?.uid; // Vérifier d'abord dans Firestore si l'utilisateur utilise la méthode Google
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .where('userId', isEqualTo: user)
                                .where('methode', isEqualTo: 'google')
                                .get();

                            // Si l'utilisateur utilise la méthode Google, bloquer la modification de l'email
                            if (userDoc.docs.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Impossible de modifier l'email pour un compte Google."),
                                ),
                              );
                              return;
                            }
                            if (pass.text.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Le mot de passe doit contenir au moins 6 caractères'),
                                ),
                              );
                              return;
                            }

                            // Afficher un indicateur de chargement
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Mise à jour du mot de passe en cours...'),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            try {
                              // Mettre à jour le mot de passe
                              await FirebaseAuth.instance.currentUser
                                  ?.updatePassword(pass.text);

                              // Effacer les champs après mise à jour réussie
                              pass.clear();

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Mot de passe mis à jour avec succès'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } catch (error) {
                              // Gérer les erreurs potentielles
                              String errorMessage =
                                  'Erreur lors de la mise à jour du mot de passe';

                              // Traiter les erreurs spécifiques de Firebase Auth
                              if (error is FirebaseAuthException) {
                                if (error.code == 'requires-recent-login') {
                                  errorMessage =
                                      'Veuillez vous reconnecter avant de modifier votre mot de passe';
                                } else {
                                  errorMessage = error.message ?? errorMessage;
                                }
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white, fontSize: i.width * 0.042),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (n == 5) ...[
                    Positioned(
                      top: i.height * 0.01,
                      left: i.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.network(
                          s18,
                          width: i.width * 0.07,
                          height: i.width * 0.07,
                        ),
                      ),
                    ),
                    Positioned(
                        top: i.height * 0.02,
                        left: i.width * 0.15,
                        child: Text(
                          "Change Name Channel",
                          style: TextStyle(
                              fontSize: i.width * 0.06,
                              fontWeight: FontWeight.bold),
                        )),
                    Positioned(
                        top: i.height * 0.1,
                        left: i.width * 0.05,
                        child: Container(
                          width: i.width,
                          child: Text(
                            "You Can Change Your Name Channel And Use The Real Name For Esasy Utilisation ",
                            style: TextStyle(color: Colors.grey),
                            maxLines: 2,
                          ),
                        )),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "Name Channel",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.2525,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: SizedBox(
                        width: i.width - 60,
                        child: TextField(
                          controller: channel,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFD9D9D9),

                            hintText: "Enter New Nam Channel",
                            hintStyle: const TextStyle(color: Colors.grey),
                            // Utilisation d'une image depuis les assets comme prefixIcon
                            prefixIcon: Padding(
                              padding: EdgeInsets.all(i.width *
                                  0.028), // Ajustez le padding selon vos besoins
                              child: Image.network(
                                s29, // Remplacez par le chemin de votre icône
                                width: i.width *
                                    0.05, // Ajustez la taille selon vos besoins
                                height: i.width * 0.05,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD9D9D9)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(i.width * 0.05)),
                              borderSide: const BorderSide(
                                color: Color(0xFFD9D9D9),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.36,
                      left: i.width * 0.18,
                      child: Container(
                        height: i.height * 0.075,
                        width: i.width * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF754CEF),
                          borderRadius: BorderRadius.circular(i.width * 0.05),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            String cha = channel.text.trim();
                            final uid = FirebaseAuth.instance.currentUser?.uid;

                            if (cha.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Field must not be empty')),
                              );
                              return;
                            }

                            if (uid == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User not logged in')),
                              );
                              return;
                            }

                            try {
                              final querySnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('channels')
                                  .where('userId', isEqualTo: uid)
                                  .limit(
                                      1) // On suppose qu’il y a un seul document par user
                                  .get();

                              if (querySnapshot.docs.isNotEmpty) {
                                final docRef =
                                    querySnapshot.docs.first.reference;

                                await docRef.update({
                                  'name': cha,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Profile updated successfully')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('User document not found')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to update: $e')),
                              );
                            }
                          }, // Implement login logic

                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white, fontSize: i.width * 0.042),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (n == 6) ...[
                    Positioned(
                      top: i.height * 0.01,
                      left: i.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.network(
                          s18,
                          width: i.width * 0.07,
                          height: i.width * 0.07,
                        ),
                      ),
                    ),
                    Positioned(
                        top: i.height * 0.02,
                        left: i.width * 0.15,
                        child: Text(
                          "Add To A playlist",
                          style: TextStyle(
                              fontSize: i.width * 0.06,
                              fontWeight: FontWeight.bold),
                        )),
                    Positioned(
                        top: i.height * 0.1,
                        left: i.width * 0.05,
                        child: Container(
                          width: i.width,
                          child: Text(
                            "You Can  Add More Podcast To A Playlist For The Esealy Receivit ",
                            style: TextStyle(color: Colors.grey),
                            maxLines: 2,
                          ),
                        )),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "Name Playlist ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.2525,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: _buildDropDownField1(
                        controller: _playlistController,
                        hint: "Select Playlist",
                        items: play,
                        title: "Playlist",
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.36,
                      left: i.width * 0.18,
                      child: Container(
                        height: i.height * 0.075,
                        width: i.width * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF754CEF),
                          borderRadius: BorderRadius.circular(i.width * 0.05),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            if (_selectedPlaylistId != null &&
                                _selectedPlaylistId!.isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('playinpod')
                                  .add({
                                'podcastId': idp,
                                'playlistId':
                                    _selectedPlaylistId, // Utilisation directe de la variable
                                'date': FieldValue.serverTimestamp(),
                              });
                              await FirebaseFirestore.instance
                                  .collection('playlist')
                                  .doc(_selectedPlaylistId)
                                  .update({
                                'podcast': FieldValue.increment(1),
                              });
                            }
                          },
                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white, fontSize: i.width * 0.042),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (n == 7) ...[
                    Positioned(
                      top: i.height * 0.01,
                      left: i.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.network(
                          s18,
                          width: i.width * 0.07,
                          height: i.width * 0.07,
                        ),
                      ),
                    ),
                    Positioned(
                        top: i.height * 0.02,
                        left: i.width * 0.15,
                        child: Text(
                          "Add To A playlist",
                          style: TextStyle(
                              fontSize: i.width * 0.06,
                              fontWeight: FontWeight.bold),
                        )),
                    Positioned(
                        top: i.height * 0.1,
                        left: i.width * 0.05,
                        child: Container(
                          width: i.width,
                          child: Text(
                            "You Can  Add More Podcast To A Playlist For The Esealy Receivit ",
                            style: TextStyle(color: Colors.grey),
                            maxLines: 2,
                          ),
                        )),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "Name Podcast ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.2525,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: _buildDropDownField1(
                        controller: _playlistController,
                        hint: "Select Podcast",
                        items: play2,
                        title: "Podcast",
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.36,
                      left: i.width * 0.18,
                      child: Container(
                        height: i.height * 0.075,
                        width: i.width * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF754CEF),
                          borderRadius: BorderRadius.circular(i.width * 0.05),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            if (_selectedPlaylistId != null &&
                                _selectedPlaylistId!.isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('playinpod')
                                  .add({
                                'playlistId': idpp,
                                'podcastId':
                                    _selectedPlaylistId, // Utilisation directe de la variable
                                'date': FieldValue.serverTimestamp(),
                              });
                              await FirebaseFirestore.instance
                                  .collection('playlist')
                                  .doc(idpp)
                                  .update({
                                'podcast': FieldValue.increment(1),
                              });
                            }
                          }, // Implement login logic

                          child: Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white, fontSize: i.width * 0.042),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (n == 8) ...[
                    Positioned(
                      top: i.height * 0.01,
                      left: i.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.network(
                          s18,
                          width: i.width * 0.07,
                          height: i.width * 0.07,
                        ),
                      ),
                    ),
                    Positioned(
                        top: i.height * 0.02,
                        left: i.width * 0.15,
                        child: Text(
                          "Delete From playlist",
                          style: TextStyle(
                              fontSize: i.width * 0.06,
                              fontWeight: FontWeight.bold),
                        )),
                    Positioned(
                        top: i.height * 0.1,
                        left: i.width * 0.05,
                        child: Container(
                          width: i.width,
                          child: Text(
                            "You Can  Delete More Podcast From Playlist For The Esealy Receivit ",
                            style: TextStyle(color: Colors.grey),
                            maxLines: 2,
                          ),
                        )),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "Name Podcast ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.2525,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: _buildDropDownField1(
                        controller: _playlistController,
                        hint: "Select Podcast",
                        items: play3,
                        title: "Podcast",
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.36,
                      left: i.width * 0.18,
                      child: Container(
                        height: i.height * 0.075,
                        width: i.width * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF754CEF),
                          borderRadius: BorderRadius.circular(i.width * 0.05),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            if (_selectedPlaylistId != null &&
                                _selectedPlaylistId!.isNotEmpty) {
                              try {
                                // 1. Rechercher les documents à supprimer dans playinpod
                                final snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('playinpod')
                                    .where('podcastId',
                                        isEqualTo: _selectedPlaylistId)
                                    .where('playlistId', isEqualTo: idpp)
                                    .get();

                                // 2. Supprimer chaque document trouvé
                                for (var doc in snapshot.docs) {
                                  await doc.reference.delete();
                                }

                                // 3. Décrémenter le champ 'podcast' de la playlist
                                await FirebaseFirestore.instance
                                    .collection('playlist')
                                    .doc(idpp)
                                    .update({
                                  'podcast': FieldValue.increment(-1),
                                });
                              } catch (e) {
                                print(
                                    'Error deleting from playinpod or updating playlist: $e');
                              }
                            }
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Colors.white, fontSize: i.width * 0.042),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (n == 9) ...[
                    Positioned(
                      top: i.height * 0.01,
                      left: i.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Image.network(
                          s18,
                          width: i.width * 0.07,
                          height: i.width * 0.07,
                        ),
                      ),
                    ),
                    Positioned(
                        top: i.height * 0.02,
                        left: i.width * 0.15,
                        child: Text(
                          "Delete From A playlist",
                          style: TextStyle(
                              fontSize: i.width * 0.06,
                              fontWeight: FontWeight.bold),
                        )),
                    Positioned(
                        top: i.height * 0.1,
                        left: i.width * 0.05,
                        child: Container(
                          width: i.width,
                          child: Text(
                            "You Can  Delete More Podcast From A Playlist For The Esealy Receivit ",
                            style: TextStyle(color: Colors.grey),
                            maxLines: 2,
                          ),
                        )),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.22,
                      left: i.width * 0.1,
                      child: const Text(
                        "Name Playlist ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.2525,
                      left: i.width * 0.07,
                      right: i.width * 0.07,
                      child: _buildDropDownField1(
                        controller: _playlistController,
                        hint: "Select Playlist",
                        items: play1,
                        title: "Playlist",
                      ),
                    ),
                    Positioned(
                      top: i.height * 0.36,
                      left: i.width * 0.18,
                      child: Container(
                        height: i.height * 0.075,
                        width: i.width * 0.65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF754CEF),
                          borderRadius: BorderRadius.circular(i.width * 0.05),
                        ),
                        child: MaterialButton(
                          onPressed: () async {
                            if (_selectedPlaylistId != null &&
                                _selectedPlaylistId!.isNotEmpty) {
                              try {
                                // 1. Rechercher les documents à supprimer dans playinpod
                                final snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('playinpod')
                                    .where('playlistId',
                                        isEqualTo: _selectedPlaylistId)
                                    .where('podcastId', isEqualTo: idp)
                                    .get();

                                // 2. Supprimer chaque document trouvé
                                for (var doc in snapshot.docs) {
                                  await doc.reference.delete();
                                }

                                // 3. Décrémenter le champ 'podcast' de la playlist
                                await FirebaseFirestore.instance
                                    .collection('playlist')
                                    .doc(_selectedPlaylistId)
                                    .update({
                                  'podcast': FieldValue.increment(-1),
                                });
                              } catch (e) {
                                print(
                                    'Error deleting from playinpod or updating playlist: $e');
                              }
                            }
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Colors.white, fontSize: i.width * 0.042),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      )),
    );
  }

  Widget _buildDropDownField1({
    required TextEditingController controller,
    required String hint,
    required List<SelectedListItem<PlaylistItem>> items,
    required String title,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 60,
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.028),
            child: Image.network(s33,
                width: MediaQuery.of(context).size.width * 0.05,
                height: MediaQuery.of(context).size.width * 0.05),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.05)),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.05)),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width * 0.05)),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
          ),
        ),
        onTap: () {
          DropDownState(
            dropDown: DropDown(
              dropDownBackgroundColor: Colors.white,
              isDismissible: true,
              bottomSheetTitle: Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              data: items,
              onSelected: (List<dynamic> selectedItems) {
                if (selectedItems.isNotEmpty) {
                  final selectedItem =
                      selectedItems.first as SelectedListItem<PlaylistItem>;
                  final playlistItem = selectedItem.data;

                  setState(() {
                    _selectedPlaylistId = playlistItem.id; // Stocke l'ID
                    _playlistController.text =
                        playlistItem.name; // Affiche le nom
                  });

                  print('Selected Playlist ID: ${playlistItem.id}');
                  print('Selected Playlist Name: ${playlistItem.name}');
                }
              },
              enableMultipleSelection: false,
            ),
          ).showModal(context);
        },
      ),
    );
  }
}

class PlaylistItem {
  final String id;
  final String name;

  PlaylistItem({required this.id, required this.name});
  @override
  String toString() => name; // Retourne le nom de la playlist
}
