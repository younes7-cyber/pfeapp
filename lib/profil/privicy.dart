import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout pour Firestore

class Privipage extends StatefulWidget {
  const Privipage({super.key});

  @override
  State<Privipage> createState() => _PrivipageState();
}

class _PrivipageState extends State<Privipage> {
  late int n = 1;
  Future<void> _delete1() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;
      // 1. Rechercher les documents à supprimer dans playinpod
      final snapshot = await FirebaseFirestore.instance
          .collection('search')
          .where('userId', isEqualTo: user)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting from playinpod or updating playlist: $e');
    }
  }

  Future<void> _delete2() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;
      // 1. Rechercher les documents à supprimer dans playinpod
      final snapshot = await FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: user)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting from playinpod or updating playlist: $e');
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this?"),
          actions: [
            TextButton(
              child: const Text("No", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text("Yes", style: TextStyle(color: Color(0xFF754CEF))),
              onPressed: () {
                Navigator.of(context).pop();
                _delete1();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog1() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this?"),
          actions: [
            TextButton(
              child: const Text("No", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text("Yes", style: TextStyle(color: Color(0xFF754CEF))),
              onPressed: () {
                Navigator.of(context).pop();
                _delete2();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size e = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              top: e.height * 0.01,
              left: e.width * 0.03,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Image.network(
                  s18,
                  width: e.width * 0.07,
                  height: e.width * 0.07,
                ),
              ),
            ),
            Positioned(
                top: e.height * 0.1,
                left: e.width * 0.07,
                child: Text(
                  "Information Personal",
                  style: TextStyle(
                      fontSize: e.width * 0.05, fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: e.height * 0.185,
                left: e.width * 0.07,
                child: Text(
                  "Motpass",
                  style: TextStyle(
                      fontSize: e.width * 0.04,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                )),
            Positioned(
                top: e.height * 0.15,
                left: e.width * 0.3,
                child: Text(
                  "........",
                  style: TextStyle(
                    fontSize: e.width * 0.1,
                  ),
                )),
            Positioned(
              top: e.height * 0.17,
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
                        fontSize: e.width * 0.06, color: Colors.black),
                  )),
            ),
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
                  "Activity",
                  style: TextStyle(
                      fontSize: e.width * 0.05, fontWeight: FontWeight.bold),
                )),
            Positioned(
              top: e.height * 0.37,
              left: e.width * 0.07,
              child: Container(
                  child: GestureDetector(
                      onTap: () {
                        _showDialog();
                      },
                      child: Row(children: [
                        Image.network(
                          s89,
                          width: e.width * 0.05,
                          height: e.height * 0.05,
                        ),
                        SizedBox(
                          width: e.width * 0.03,
                        ),
                        Text(
                          "Delete All Recently Search",
                          style: TextStyle(
                              fontSize: e.width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                      ]))),
            ),
            Positioned(
              top: e.height * 0.44,
              left: e.width * 0.07,
              child: Container(
                  child: GestureDetector(
                      onTap: () {
                        _showDialog1();
                      },
                      child: Row(children: [
                        Image.network(
                          s14,
                          width: e.width * 0.05,
                          height: e.height * 0.05,
                        ),
                        SizedBox(
                          width: e.width * 0.03,
                        ),
                        Text(
                          "Delete All Podcast Viewed",
                          style: TextStyle(
                              fontSize: e.width * 0.04,
                              fontWeight: FontWeight.bold),
                        ),
                      ]))),
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
              top: e.height * 0.63,
              left: e.width * 0.04,
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    // Afficher une boîte de dialogue de confirmation
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Supprimer le compte"),
                          content: const Text(
                            "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront perdues.",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context)
                                    .pop(); // Fermer la boîte de dialogue

                                // Afficher un indicateur de chargement
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 16),
                                          Text(
                                              "Suppression du compte en cours..."),
                                        ],
                                      ),
                                    );
                                  },
                                );

                                try {
                                  // Récupérer l'utilisateur actuel et son ID
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  final currentUserId = currentUser?.uid;

                                  if (currentUserId == null) {
                                    throw Exception(
                                        "Aucun utilisateur connecté");
                                  }

                                  // Firestore instance
                                  final firestore = FirebaseFirestore.instance;

                                  // 1. Supprimer l'utilisateur de la collection users
                                  await firestore
                                      .collection('users')
                                      .where('userId', isEqualTo: currentUserId)
                                      .get()
                                      .then((snapshot) {
                                    for (DocumentSnapshot ds in snapshot.docs) {
                                      ds.reference.delete();
                                    }
                                  });

                                  // 2. Supprimer les channels créés par l'utilisateur
                                  final channelsToDelete = await firestore
                                      .collection('channels')
                                      .where('userId', isEqualTo: currentUserId)
                                      .get();

                                  for (var doc in channelsToDelete.docs) {
                                    await doc.reference.delete();
                                  }

                                  final followsAsFollower = await firestore
                                      .collection('follow')
                                      .where('idfollowers',
                                          isEqualTo: currentUserId)
                                      .get();

// Pour chaque personne suivie, décrémenter son compteur de followers dans channels
                                  for (var doc in followsAsFollower.docs) {
                                    // Récupérer l'ID de l'utilisateur suivi
                                    final idFollowing =
                                        doc.data()['idfollowing'];

                                    // Rechercher le document channel correspondant
                                    final channelQuery = await firestore
                                        .collection('channels')
                                        .where('userId', isEqualTo: idFollowing)
                                        .get();

                                    // Mettre à jour le compteur de followers pour chaque channel trouvé
                                    for (var channelDoc in channelQuery.docs) {
                                      // Récupérer le compteur actuel de followers
                                      final currentFollowers =
                                          channelDoc.data()['followers'] ?? 0;

                                      // Décrémenter le compteur (en s'assurant qu'il ne devient pas négatif)
                                      final newFollowers = currentFollowers > 0
                                          ? currentFollowers - 1
                                          : 0;

                                      // Mettre à jour le document
                                      await channelDoc.reference
                                          .update({'followers': newFollowers});
                                    }

                                    // Supprimer la relation follow
                                    await doc.reference.delete();
                                  }
                                  final followsAsAsFollowing = await firestore
                                      .collection('follow')
                                      .where('idfollowing',
                                          isEqualTo: currentUserId)
                                      .get();

// Pour chaque personne suivie, décrémenter son compteur de followers dans channels
                                  for (var doc in followsAsAsFollowing.docs) {
                                    // Récupérer l'ID de l'utilisateur suivi
                                    final idFollowing =
                                        doc.data()['idfollowers'];

                                    // Rechercher le document channel correspondant
                                    final channelQuery = await firestore
                                        .collection('channels')
                                        .where('userId', isEqualTo: idFollowing)
                                        .get();

                                    // Mettre à jour le compteur de followers pour chaque channel trouvé
                                    for (var channelDoc in channelQuery.docs) {
                                      // Récupérer le compteur actuel de followers
                                      final currentFollowers =
                                          channelDoc.data()['following'] ?? 0;

                                      // Décrémenter le compteur (en s'assurant qu'il ne devient pas négatif)
                                      final newFollowers = currentFollowers > 0
                                          ? currentFollowers - 1
                                          : 0;

                                      // Mettre à jour le document
                                      await channelDoc.reference
                                          .update({'following': newFollowers});
                                    }

                                    // Supprimer la relation follow
                                    await doc.reference.delete();
                                  }
                                  // 3. Gérer les podcasts et références associées
                                  final podcastsToDelete = await firestore
                                      .collection('podcasts')
                                      .where('idUser', isEqualTo: currentUserId)
                                      .get();

                                  for (var podcastDoc
                                      in podcastsToDelete.docs) {
                                    final podcastId = podcastDoc.id;

                                    // Récupérer les références dans playinpod
                                    final playInPodRefs = await firestore
                                        .collection('playinpod')
                                        .where('podcastId',
                                            isEqualTo: podcastId)
                                        .get();

                                    // Pour chaque référence, récupérer et mettre à jour la playlist correspondante
                                    for (var doc in playInPodRefs.docs) {
                                      // Récupérer l'ID de la playlist
                                      final playlistId =
                                          doc.data()['playlistId'];

                                      if (playlistId != null) {
                                        // Récupérer la playlist
                                        final playlistDoc = await firestore
                                            .collection('playlist')
                                            .doc(playlistId)
                                            .get();

                                        if (playlistDoc.exists) {
                                          // Récupérer le compteur actuel de podcasts
                                          final currentPodcastCount =
                                              playlistDoc.data()?['podcast'] ??
                                                  0;

                                          // Décrémenter le compteur (en s'assurant qu'il ne devient pas négatif)
                                          final newPodcastCount =
                                              currentPodcastCount > 0
                                                  ? currentPodcastCount - 1
                                                  : 0;

                                          // Mettre à jour le document
                                          await playlistDoc.reference.update(
                                              {'podcast': newPodcastCount});
                                        }
                                      }

                                      // Supprimer la référence dans playinpod
                                      await doc.reference.delete();
                                    }

                                    // Supprimer le podcast lui-même
                                    await podcastDoc.reference.delete();
                                  }
                                  // Supprimer les références dans myplaylist pour cet utilisateur
                                  final myPlaylistRefs = await firestore
                                      .collection('myplaylist')
                                      .where('iduser', isEqualTo: currentUserId)
                                      .get();

                                  for (var doc in myPlaylistRefs.docs) {
                                    await doc.reference.delete();
                                  }

                                  // 4. Gérer les playlists et références associées
                                  // 3. Gérer les podcasts et références associées
                                  final playlistToDelete = await firestore
                                      .collection('playlist')
                                      .where('userId', isEqualTo: currentUserId)
                                      .get();

                                  for (var podcastDoc
                                      in playlistToDelete.docs) {
                                    final podcastId = podcastDoc.id;

                                    // Récupérer les références dans playinpod
                                    final playInPodRefs = await firestore
                                        .collection('playinpod')
                                        .where('playlistId',
                                            isEqualTo: podcastId)
                                        .get();

                                    // Pour chaque référence, récupérer et mettre à jour la playlist correspondante
                                    for (var doc in playInPodRefs.docs) {
                                      // Supprimer la référence dans playinpod
                                      await doc.reference.delete();
                                    }

                                    // Supprimer le podcast lui-même
                                    await podcastDoc.reference.delete();
                                  }

                                  // Supprimer les références dans mesplaylist pour cet utilisateur
                                  final mesPlaylistRefs = await firestore
                                      .collection('mesplaylist')
                                      .where('iduser', isEqualTo: currentUserId)
                                      .get();

                                  for (var doc in mesPlaylistRefs.docs) {
                                    await doc.reference.delete();
                                  }

                                  // Enfin, supprimer le compte utilisateur de Firebase Auth
                                  await currentUser?.delete();

                                  // Fermer la boîte de dialogue de chargement
                                  Navigator.of(context).pop();

                                  // Rediriger vers l'écran de connexion après la suppression réussie
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/login', (route) => false);

                                  // Afficher un message de confirmation
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Votre compte a été supprimé avec succès"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  // Fermer la boîte de dialogue de chargement
                                  Navigator.of(context).pop();

                                  // Afficher un message d'erreur
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Erreur lors de la suppression du compte: ${e.toString()}"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );

                                  print("Erreur de suppression du compte: $e");
                                }
                              },
                              child: const Text(
                                "Supprimer",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Image.network(
                        s91,
                        width: e.width * 0.06,
                        height: e.width * 0.06,
                      ),
                      Text(
                        "Delete User",
                        style: TextStyle(
                          fontSize: e.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
