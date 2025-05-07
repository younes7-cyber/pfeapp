import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class Privipage extends StatefulWidget {
  const Privipage({super.key});

  @override
  State<Privipage> createState() => _PrivipageState();
}

class _PrivipageState extends State<Privipage> {
  late int n = 1;
  bool _isDeleting = false; // Flag to track deletion process
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await Future.delayed(const Duration(seconds: 3));
      setState(() => isLoading = false);
    });
  }

  bool isLoading = true;
  Future<void> _delete1() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;
      // 1. Rechercher les documents à supprimer dans search
      final snapshot = await FirebaseFirestore.instance
          .collection('search')
          .where('userId', isEqualTo: user)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Only show success message if the widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Search history deleted successfully"),
            backgroundColor: Color(0xFF754CEF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting search history: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _delete2() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;
      // 1. Rechercher les documents à supprimer dans vues
      final snapshot = await FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: user)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Only show success message if the widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Podcast views deleted successfully"),
            backgroundColor: Color(0xFF754CEF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting podcast views: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _delete3() async {
    try {
      final user = FirebaseAuth.instance.currentUser?.uid;
      // 1. Rechercher les documents à supprimer dans vues
      final snapshot = await FirebaseFirestore.instance
          .collection('nofi')
          .where('user2', isEqualTo: user)
          .where('isviewed', isEqualTo: true)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      final snapshot1 = await FirebaseFirestore.instance
          .collection('reports')
          .where('userId', isEqualTo: user)
          .where('isviewed', isEqualTo: true)
          .get();

      // 2. Supprimer chaque document trouvé
      for (var doc in snapshot1.docs) {
        await doc.reference.delete();
      }
      // Only show success message if the widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Podcast views deleted successfully"),
            backgroundColor: Color(0xFF754CEF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error deleting podcast views: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.white,
            title: const Text("Confirm Deletion"),
            content: const Text(
                "Are you sure you want to delete your search history?"),
            actions: [
              TextButton(
                child: const Text("No", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Yes",
                    style: TextStyle(color: Color(0xFF754CEF))),
                onPressed: () {
                  Navigator.of(context).pop();
                  _delete1();
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showDialog1() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.white,
            title: const Text("Confirm Deletion"),
            content: const Text(
                "Are you sure you want to delete your podcast viewing history?"),
            actions: [
              TextButton(
                child: const Text("No", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Yes",
                    style: TextStyle(color: Color(0xFF754CEF))),
                onPressed: () {
                  Navigator.of(context).pop();
                  _delete2();
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showDialog3() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.white,
            title: const Text("Confirm Deletion"),
            content: const Text(
                "Are you sure you want to delete your Read Nofication?"),
            actions: [
              TextButton(
                child: const Text("No", style: TextStyle(color: Colors.grey)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Yes",
                    style: TextStyle(color: Color(0xFF754CEF))),
                onPressed: () {
                  Navigator.of(context).pop();
                  _delete3();
                },
              ),
            ],
          );
        });
      },
    );
  }

  // Handle account deletion safely
  Future<void> _deleteAccount(BuildContext contextFromDialog) async {
    // Close the confirmation dialog first
    Navigator.of(contextFromDialog).pop();

    // Set deletion flag
    setState(() {
      _isDeleting = true;
    });

    // Show loading dialog - save the context
    final BuildContext loadingDialogContext = context;
    showDialog(
      context: loadingDialogContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.white,
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Annimationwidjet(),
                SizedBox(height: 16),
                Text("Account deletion in progress..."),
              ],
            ),
          );
        });
      },
    );

    try {
      // Récupérer l'utilisateur actuel et son ID
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;

      if (currentUserId == null) {
        throw Exception("Aucun utilisateur connecté");
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

      // 3. Gérer les follows où l'utilisateur est un follower
      final followsAsFollower = await firestore
          .collection('follow')
          .where('idfollowers', isEqualTo: currentUserId)
          .get();

      // Pour chaque personne suivie, décrémenter son compteur de followers dans channels
      for (var doc in followsAsFollower.docs) {
        // Récupérer l'ID de l'utilisateur suivi
        final idFollowing = doc.data()['idfollowing'];

        // Rechercher le document channel correspondant
        final channelQuery = await firestore
            .collection('channels')
            .where('userId', isEqualTo: idFollowing)
            .get();

        // Mettre à jour le compteur de followers pour chaque channel trouvé
        for (var channelDoc in channelQuery.docs) {
          // Récupérer le compteur actuel de followers
          final currentFollowers = channelDoc.data()['followers'] ?? 0;

          // Décrémenter le compteur (en s'assurant qu'il ne devient pas négatif)
          final newFollowers = currentFollowers > 0 ? currentFollowers - 1 : 0;

          // Mettre à jour le document
          await channelDoc.reference.update({'followers': newFollowers});
        }

        // Supprimer la relation follow
        await doc.reference.delete();
      }

      // 4. Gérer les follows où l'utilisateur est suivi
      final followsAsFollowing = await firestore
          .collection('follow')
          .where('idfollowing', isEqualTo: currentUserId)
          .get();

      for (var doc in followsAsFollowing.docs) {
        // Récupérer l'ID du follower
        final idFollower = doc.data()['idfollowers'];

        // Rechercher le document channel correspondant
        final channelQuery = await firestore
            .collection('channels')
            .where('userId', isEqualTo: idFollower)
            .get();

        // Mettre à jour le compteur de following pour chaque channel trouvé
        for (var channelDoc in channelQuery.docs) {
          // Récupérer le compteur actuel de following
          final currentFollowing = channelDoc.data()['following'] ?? 0;

          // Décrémenter le compteur (en s'assurant qu'il ne devient pas négatif)
          final newFollowing = currentFollowing > 0 ? currentFollowing - 1 : 0;

          // Mettre à jour le document
          await channelDoc.reference.update({'following': newFollowing});
        }

        // Supprimer la relation follow
        await doc.reference.delete();
      }

      // 5. Gérer les podcasts et références associées
      final podcastsToDelete = await firestore
          .collection('podcasts')
          .where('idUser', isEqualTo: currentUserId)
          .get();

      for (var podcastDoc in podcastsToDelete.docs) {
        final podcastId = podcastDoc.id;

        // Récupérer les références dans playinpod
        final playInPodRefs = await firestore
            .collection('playinpod')
            .where('podcastId', isEqualTo: podcastId)
            .get();

        // Pour chaque référence, récupérer et mettre à jour la playlist correspondante
        for (var doc in playInPodRefs.docs) {
          // Récupérer l'ID de la playlist
          final playlistId = doc.data()['playlistId'];

          if (playlistId != null) {
            // Récupérer la playlist
            final playlistDoc =
                await firestore.collection('playlist').doc(playlistId).get();

            if (playlistDoc.exists) {
              // Récupérer le compteur actuel de podcasts
              final currentPodcastCount = playlistDoc.data()?['podcast'] ?? 0;

              // Décrémenter le compteur (en s'assurant qu'il ne devient pas négatif)
              final newPodcastCount =
                  currentPodcastCount > 0 ? currentPodcastCount - 1 : 0;

              // Mettre à jour le document
              await playlistDoc.reference.update({'podcast': newPodcastCount});
            }
          }

          // Supprimer la référence dans playinpod
          await doc.reference.delete();
        }

        // Supprimer le podcast lui-même
        await podcastDoc.reference.delete();
      }

      // 6. Supprimer les références dans myplaylist pour cet utilisateur
      final myPlaylistRefs = await firestore
          .collection('myplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .get();

      for (var doc in myPlaylistRefs.docs) {
        await doc.reference.delete();
      }

      // 7. Gérer les playlists et références associées
      final playlistToDelete = await firestore
          .collection('playlist')
          .where('userId', isEqualTo: currentUserId)
          .get();

      for (var playlistDoc in playlistToDelete.docs) {
        final playlistId = playlistDoc.id;

        // Récupérer les références dans playinpod
        final playInPodRefs = await firestore
            .collection('playinpod')
            .where('playlistId', isEqualTo: playlistId)
            .get();

        // Supprimer toutes les références playinpod
        for (var doc in playInPodRefs.docs) {
          await doc.reference.delete();
        }

        // Supprimer la playlist elle-même
        await playlistDoc.reference.delete();
      }

      // 8. Supprimer les références dans mesplaylist pour cet utilisateur
      final mesPlaylistRefs = await firestore
          .collection('mesplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .get();

      for (var doc in mesPlaylistRefs.docs) {
        await doc.reference.delete();
      }

      // 9. Enfin, supprimer le compte utilisateur de Firebase Auth
      await currentUser?.delete();

      // Check if widget is still mounted before proceeding with navigation
      if (mounted) {
        // Fermer la boîte de dialogue de chargement
        // Using the saved context from earlier to avoid using a potentially destroyed context
        // ignore: use_build_context_synchronously
        Navigator.of(loadingDialogContext).pop();

        // Rediriger vers l'écran de connexion après la suppression réussie
        Navigator.pushNamedAndRemoveUntil(context, '/LogIn', (route) => false);

        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Succesfull deleting account"),
            backgroundColor: Color(0xFF754CEF),
          ),
        );
      }
    } catch (e) {
      // Check if widget is still mounted before showing error
      if (mounted) {
        // Fermer la boîte de dialogue de chargement
        // ignore: use_build_context_synchronously
        Navigator.of(loadingDialogContext).pop();

        Navigator.pushNamedAndRemoveUntil(context, '/LogIn', (route) => false);
        // Afficher un message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Succesfull deleting account"),
            backgroundColor: Color(0xFF754CEF),
          ),
        );
      }
    } finally {
      // Reset deletion flag if we're still mounted
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size e = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
          child: _isDeleting || isLoading
              ? const Annimationwidjet() // Show loading spinner if deleting
              : Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white,
                    ),
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
                              themeProvider.isDarkMode ? s97 : s18,
                              width: e.width * 0.07,
                              height: e.width * 0.07,
                            ),
                          ),
                        ),
                        Positioned(
                            top: e.height * 0.02,
                            left: e.width * 0.15,
                            child: Text(
                              "Account Privacy",
                              style: TextStyle(
                                  fontSize: e.width * 0.06,
                                  fontWeight: FontWeight.bold),
                            )),
                        Positioned(
                            top: e.height * 0.1,
                            left: e.width * 0.07,
                            child: Text(
                              "Information Personal",
                              style: TextStyle(
                                  fontSize: e.width * 0.05,
                                  fontWeight: FontWeight.bold),
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
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
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
                                  fontSize: e.width * 0.06,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
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
                                  fontSize: e.width * 0.05,
                                  fontWeight: FontWeight.bold),
                            )),
                        Positioned(
                          top: e.height * 0.37,
                          left: e.width * 0.07,
                          child: GestureDetector(
                              onTap: () {
                                _showDialog();
                              },
                              child: Row(children: [
                                Image.network(
                                  themeProvider.isDarkMode ? s107 : s89,
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
                              ])),
                        ),
                        Positioned(
                          top: e.height * 0.44,
                          left: e.width * 0.07,
                          child: GestureDetector(
                              onTap: () {
                                _showDialog1();
                              },
                              child: Row(children: [
                                Image.network(
                                  themeProvider.isDarkMode ? s108 : s14,
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
                              ])),
                        ),
                        Positioned(
                          top: e.height * 0.51,
                          left: e.width * 0.07,
                          child: GestureDetector(
                              onTap: () {
                                _showDialog3();
                              },
                              child: Row(children: [
                                Image.network(
                                  themeProvider.isDarkMode ? s134 : s59,
                                  width: e.width * 0.05,
                                  height: e.height * 0.05,
                                ),
                                SizedBox(
                                  width: e.width * 0.03,
                                ),
                                Text(
                                  "Delete All Read Nofication",
                                  style: TextStyle(
                                      fontSize: e.width * 0.04,
                                      fontWeight: FontWeight.bold),
                                ),
                              ])),
                        ),
                        Positioned(
                            top: e.height * 0.61,
                            left: e.width * 0.07,
                            right: e.width * 0.07,
                            child: Container(
                              width: e.width * 0.8,
                              height: e.height * 0.002, // Épaisseur de la ligne
                              color: Colors.grey[400],
                            )),
                        Positioned(
                          top: e.height * 0.69,
                          left: e.width * 0.04,
                          child: GestureDetector(
                            onTap: () {
                              // Capture the current context for the dialog
                              final BuildContext currentContext = context;

                              // Afficher une boîte de dialogue de confirmation
                              showDialog(
                                context: currentContext,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    backgroundColor: themeProvider.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    title: const Text("Delete account"),
                                    content: const Text(
                                      "Are you sure you want to delete your account? This action is irreversible and all your data will be lost.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(); // Just close the dialog
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      TextButton(
                                        // Pass the dialog context to the delete function
                                        onPressed: () =>
                                            _deleteAccount(dialogContext),
                                        child: const Text(
                                          "Delete",
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
                      ],
                    ),
                  );
                })),
    );
  }
}
