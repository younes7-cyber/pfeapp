import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/ZoomPhotoPage.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:pfeapp/main.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class Channelpage extends StatefulWidget {
  const Channelpage({super.key});
  @override
  State<Channelpage> createState() => _ChannelpageState();
}

class _ChannelpageState extends State<Channelpage>
    with SingleTickerProviderStateMixin {
  Future<void> checkAndAddReport(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final reportsRef = FirebaseFirestore.instance.collection('reports');

      // Obtenir le premier snapshot pour vérifier si le rapport existe
      final snapshot = await reportsRef
          .where('user', isEqualTo: user.uid)
          .where('chaine', isEqualTo: id)
          .snapshots()
          .first;

      if (snapshot.docs.isEmpty) {
        // Aucune déclaration trouvée : on ajoute
        await reportsRef.add({
          'user': user.uid,
          'chaine': id,
          'date': FieldValue.serverTimestamp(),
        });
        await FirebaseFirestore.instance.collection('channels').doc(id).update({
          'report': FieldValue.increment(1),
        }); // Add
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  String formatLikes(num likes) {
    // Utiliser un pattern personnalisé avec exactement 2 décimales
    final formatter = NumberFormat('#,##0.00', 'fr');
    // Pour les nombres importants, appliquer une logique de compactage manuel
    if (likes >= 1000000000000000) {
      return '${formatter.format(likes / 1000000000000000).replaceAll('\u202f', '')}P';
    } else if (likes >= 1000000000000) {
      return '${formatter.format(likes / 1000000000000).replaceAll('\u202f', '')}T';
    } else if (likes >= 1000000000) {
      return '${formatter.format(likes / 1000000000).replaceAll('\u202f', '')}G';
    } else if (likes >= 1000000) {
      return '${formatter.format(likes / 1000000).replaceAll('\u202f', '')}M';
    } else if (likes >= 1000) {
      return '${formatter.format(likes / 1000).replaceAll('\u202f', '')}k';
    } else if (likes <= 999) {
      final formatter1 = NumberFormat('#0', 'fr');
      return formatter1.format(likes);
    }

    return formatter.format(likes).replaceAll('\u202f', '');
  }

  bool isPressed = false;
  bool showWhiteContainer = false;
  late int r = 1;
  late int? chaine;
  String? id;
  List<Map<String, dynamic>> playlists = [];
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> podcasts = [];
  late int s = 0;
  bool isFollowing = false;
  bool isLoading = true;

  // Abonnements aux streams pour pouvoir les annuler dans dispose()
  StreamSubscription? _channelsSubscription;
  StreamSubscription? _podcastsSubscription;
  StreamSubscription? _playlistsSubscription;
  StreamSubscription? _followingSubscription;

  Future<void> listenToChannels(String id) async {
    // Annuler l'abonnement précédent s'il existe
    await _channelsSubscription?.cancel();

    _channelsSubscription = FirebaseFirestore.instance
        .collection('channels')
        .where('id', isEqualTo: id)
        .snapshots()
        .listen((querySnapshot) async {
      List<Map<String, dynamic>> tempChannels = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> channelData = doc.data();

        // Récupérer l'utilisateur lié à ce channel
        String? userId = channelData['userId'];
        if (userId != null) {
          // Utiliser .first pour obtenir un snapshot unique
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('userId', isEqualTo: userId)
              .snapshots()
              .first;

          if (userSnapshot.docs.isNotEmpty) {
            channelData['user'] = userSnapshot.docs.first.data();
          } else {
            channelData['user'] = null;
          }
        }

        tempChannels.add(channelData);
      }

      if (mounted) {
        setState(() {
          channels = tempChannels;
        });
      }
    }, onError: (e) {});
  }

  Future<void> listenToPodcasts(String id) async {
    await _podcastsSubscription?.cancel();

    // D'abord, obtenir l'userId du canal
    final channelSnapshot = await FirebaseFirestore.instance
        .collection('channels')
        .where('id', isEqualTo: id)
        .snapshots()
        .first;

    if (channelSnapshot.docs.isEmpty) {
      return;
    }

    final channelData = channelSnapshot.docs.first.data();
    final String userId = channelData['userId'];

    // Ensuite, écouter les podcasts de cet utilisateur
    _podcastsSubscription = FirebaseFirestore.instance
        .collection('podcasts')
        .where('idUser', isEqualTo: userId)
        .orderBy('dateCreation', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<Map<String, dynamic>> fetchedPodcasts = snapshot.docs
          // ignore: unnecessary_cast
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      int likes = fetchedPodcasts.fold(
          // ignore: avoid_types_as_parameter_names
          0,
          // ignore: avoid_types_as_parameter_names
          (sum, item) => sum + (item["likes"] ?? 0) as int);

      if (mounted) {
        setState(() {
          podcasts = fetchedPodcasts;
          s = likes;
        });
      }
    }, onError: (e) {});
  }

  Future<void> listenToPlaylists(String id) async {
    await _playlistsSubscription?.cancel();

    // D'abord, obtenir l'userId du canal
    final channelSnapshot = await FirebaseFirestore.instance
        .collection('channels')
        .where('id', isEqualTo: id)
        .snapshots()
        .first;

    if (channelSnapshot.docs.isEmpty) {
      return;
    }

    final channelData = channelSnapshot.docs.first.data();
    final String userId = channelData['userId'];

    // Ensuite, écouter les playlists de cet utilisateur
    _playlistsSubscription = FirebaseFirestore.instance
        .collection('playlist')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final List<Map<String, dynamic>> fetchedPlaylists = snapshot.docs
          // ignore: unnecessary_cast
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (mounted) {
        setState(() {
          playlists = fetchedPlaylists;
        });
      }
    }, onError: (e) {});
  }

  Future<void> listenToFollowStatus() async {
    await _followingSubscription?.cancel();

    final user = FirebaseAuth.instance.currentUser?.uid;
    if (user == null || id == null) return;

    // D'abord, obtenir l'userId du canal
    final channelSnapshot = await FirebaseFirestore.instance
        .collection('channels')
        .where('id', isEqualTo: id)
        .snapshots()
        .first;

    if (channelSnapshot.docs.isEmpty) {
      return;
    }

    final String? podcastUserId =
        channelSnapshot.docs.first.data()['userId'] as String?;
    if (podcastUserId == null) return;

    // Ensuite, écouter le statut de suivi
    _followingSubscription = FirebaseFirestore.instance
        .collection('follow')
        .where('idfollowers', isEqualTo: user)
        .where('idfollowing', isEqualTo: podcastUserId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          isFollowing = snapshot.docs.isNotEmpty;
        });
      }
    }, onError: (e) {});
  }

  Future<String?> getChannelUserId() async {
    if (id == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('id', isEqualTo: id)
          .snapshots()
          .first;

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['userId'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  final String user = FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<void> toggleFollow() async {
    // ignore: unnecessary_null_comparison
    if (user == null) return;

    try {
      // Obtenir l'userId du podcast
      final podcastUserId = await getChannelUserId();
      if (podcastUserId == null) return;

      // Sauvegarder l'état précédent pour pouvoir revenir en arrière en cas d'erreur
      final previousFollowingState = isFollowing;

      if (mounted) {
        setState(() {
          isFollowing = !isFollowing;
        });
      }

      if (isFollowing) {
        final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: user)
            .get();

        if (userSnapshot.docs.isEmpty) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User information not found')),
          );
          return;
        }

        // Extraire firstName et lastName
        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        final String firstName = userData['firstName'] ?? '';
        final String lastName = userData['lastName'] ?? '';
        final String fullName = '$firstName $lastName';
        // Ajouter à la collection follow
        await FirebaseFirestore.instance.collection('follow').add({
          'idfollowers': user,
          'idfollowing': podcastUserId,
          'dateCreation': Timestamp.now(),
        });
        await FirebaseFirestore.instance.collection('nofi').add({
          'user1': user,
          'user2': podcastUserId,
          'text': 'Subscribe You',
          'date': Timestamp.now(),
          'isviewed': false,
        });

        // Vérification du channel en cherchant où userId == podcastUserId
        final channelSnapshot = await FirebaseFirestore.instance
            .collection('channels')
            .where('userId', isEqualTo: podcastUserId)
            .snapshots()
            .first;

        // Vérifier si un document a été trouvé
        if (channelSnapshot.docs.isNotEmpty) {
          // Récupérer l'ID du document
          String channelId = channelSnapshot.docs.first.id;

          // Mettre à jour le champ followers avec l'ID récupéré
          await FirebaseFirestore.instance
              .collection('channels')
              .doc(channelId)
              .update({
            'followers': FieldValue.increment(1),
          });
        }

        // Vérifier si le document de l'utilisateur actuel existe
        final channelDocUserSnapshot = await FirebaseFirestore.instance
            .collection('channels')
            .where('userId', isEqualTo: user)
            .snapshots()
            .first;

        if (channelDocUserSnapshot.docs.isNotEmpty) {
          // Récupérer l'ID du document
          String channelIdd = channelDocUserSnapshot.docs.first.id;

          // Mettre à jour le champ followers avec l'ID récupéré
          await FirebaseFirestore.instance
              .collection('channels')
              .doc(channelIdd)
              .update({
            'following': FieldValue.increment(1),
          });
          try {
            await FCMService.sendNotification(
              topic: podcastUserId,
              title: 'New Subscriber',
              body: '$fullName has subscribed to you',
            );
            // ignore: empty_catches
          } catch (e) {}
        }
      } else {
        // Supprimer de la collection follow
        final followSnapshot = await FirebaseFirestore.instance
            .collection('follow')
            .where('idfollowers', isEqualTo: user)
            .where('idfollowing', isEqualTo: podcastUserId)
            .snapshots()
            .first;

        // Si aucun document n'est trouvé, c'est une erreur ou une incohérence
        if (followSnapshot.docs.isEmpty) {
          if (mounted) {
            setState(() {
              isFollowing = previousFollowingState;
            });
          }
          return;
        }

        // Pour chaque document trouvé
        for (var doc in followSnapshot.docs) {
          await doc.reference.delete();

          final channelQuerySnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', isEqualTo: podcastUserId)
              .snapshots()
              .first;

          // Vérifier si un document a été trouvé
          if (channelQuerySnapshot.docs.isNotEmpty) {
            // Récupérer l'ID du document
            String channelIddd = channelQuerySnapshot.docs.first.id;

            // Mettre à jour le champ followers avec l'ID récupéré
            await FirebaseFirestore.instance
                .collection('channels')
                .doc(channelIddd)
                .update({
              'followers': FieldValue.increment(-1),
            });
          }

          // Vérifier si le document de l'utilisateur actuel existe
          final channelDocUserSnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', isEqualTo: user)
              .snapshots()
              .first;

          if (channelDocUserSnapshot.docs.isNotEmpty) {
            // Récupérer l'ID du document
            String channelIdds = channelDocUserSnapshot.docs.first.id;

            // Mettre à jour le champ followers avec l'ID récupéré
            await FirebaseFirestore.instance
                .collection('channels')
                .doc(channelIdds)
                .update({
              'following': FieldValue.increment(-1),
            });
          }
        }
      }
    } catch (e) {
      // En cas d'erreur, revenir à l'état précédent
      if (mounted) {
        setState(() {
          isFollowing = !isFollowing;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => isLoading = true);
      }

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('id')) {
          id = arguments['id'];
        }

        if (arguments.containsKey('chaine')) {
          chaine = arguments['chaine'];
        }

        if (id != null) {
          // Configuration des écouteurs pour les streams
          await listenToChannels(id!);
          await listenToPodcasts(id!);
          await listenToPlaylists(id!);
          await listenToFollowStatus();
        }
      }
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  late TabController _tabController1;

  @override
  void dispose() {
    // Annuler tous les abonnements aux streams
    _channelsSubscription?.cancel();
    _podcastsSubscription?.cancel();
    _playlistsSubscription?.cancel();
    _followingSubscription?.cancel();

    _tabController1.dispose();
    super.dispose();
  }

  // Le reste de votre code (méthode build, etc.)...

  @override
  Widget build(BuildContext context) {
    final Size v = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: isLoading
          ? const Annimationwidjet()
          : Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
              return Container(
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                ),
                width: double.infinity, // Added to provide width constraint
                height: double.infinity, // Added to provide height constraint

                child: Column(
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
                                if (chaine == 2) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/podly', (route) => false,
                                      arguments: {'selectedIndex': 0});
                                }
                                if (chaine == 3) {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/podly', (route) => false,
                                      arguments: {'selectedIndex': 3});
                                }
                                if (chaine == 4) {
                                  Navigator.pop(context);
                                }
                                if (chaine == 5) {
                                  Navigator.pop(context);
                                }
                                if (chaine == 6) {
                                  Navigator.pop(context);
                                }
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
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
                                  themeProvider.isDarkMode ? s106 : s49,
                                  width: v.width * 0.06,
                                  height: v.width * 0.06,
                                ),
                                color: themeProvider.isDarkMode
                                    ? Colors.black
                                    : Colors
                                        .white, // Définit la couleur de fond du menu popup
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    height: v.width * 0.12,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: themeProvider.isDarkMode
                                            ? Colors.black
                                            : Colors
                                                .white, // Couleur de fond du container
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.network(
                                            themeProvider.isDarkMode
                                                ? s118
                                                : s50,
                                            width: v.width * 0.05,
                                            height: v.width * 0.05,
                                          ),
                                          SizedBox(width: v.width * 0.02),
                                          Text(
                                            "Report",
                                            style: TextStyle(
                                              fontSize: v.width * 0.04,
                                              // Couleur du texte
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () async {
                                      await checkAndAddReport(id!);
                                    },
                                  ),
                                ],
                              )),
                          Positioned(
                              top: v.height * 0.02,
                              left: v.width * 0.35,
                              child: SizedBox(
                                  width: v.width * 0.4,
                                  height: v.height * 0.1,
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
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierColor: themeProvider.isDarkMode
                                      // ignore: deprecated_member_use
                                      ? Colors.white.withOpacity(0.9)
                                      // ignore: deprecated_member_use
                                      : Colors.black.withOpacity(
                                          0.9), // fond sombre comme TikTok
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding:
                                          EdgeInsets.zero, // plein écran
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Image.network(
                                              channels[0]["photoUrl"],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Positioned(
                                            top: 40,
                                            right: 20,
                                            child: IconButton(
                                              icon: Icon(Icons.close,
                                                  color:
                                                      themeProvider.isDarkMode
                                                          ? Colors.black
                                                          : Colors.white,
                                                  size: 30),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Fermer l'overlay
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: v.width * 0.25,
                                height: v.width * 0.25,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF754CEF),
                                    width: v.width * 0.002,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(v.width * 0.2),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    channels[0]["photoUrl"],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: v.height * 0.03,
                            left: v.width * 0.38,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    transitionDuration:
                                        const Duration(milliseconds: 500),
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ZoomPhotoPage(
                                            imageUrl: channels[0]["photoUrl"]),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Hero(
                                tag:
                                    'photoZoomHero11', // Tag partagé pour animation Hero
                                child: Container(
                                  width: v.width * 0.25,
                                  height: v.width * 0.25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF754CEF),
                                      width: v.width * 0.002,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(v.width * 0.2),
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      channels[0]["photoUrl"],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                          channels[0]['user']['email'],
                          style: const TextStyle(
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
                                formatLikes(channels[0]['following']),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: v.width * 0.04),
                              ),
                              const Text(
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
                                formatLikes(channels[0]['followers']),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: v.width * 0.04),
                              ),
                              const Text(
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
                              const Text(
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
                      width: v.width * 0.75,
                      child: MaterialButton(
                        onPressed: toggleFollow,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 1),
                          height: v.height * 0.07,
                          width: v.width * 0.75,
                          decoration: BoxDecoration(
                            color: isFollowing
                                ? themeProvider.isDarkMode
                                    ? Colors.black
                                    : Colors.white
                                : const Color(0xFF754CEF),
                            borderRadius: BorderRadius.all(
                              Radius.circular(v.width * 0.05),
                            ),
                            border: isFollowing
                                ? Border.all(color: const Color(0xFF754CEF))
                                : null,
                          ),
                          child: Stack(
                            children: [
                              if (!isFollowing)
                                Positioned(
                                  top: v.height * 0.022,
                                  left: v.width * 0.23,
                                  child: Text(
                                    "Follow Now",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: v.width * 0.04,
                                    ),
                                  ),
                                ),
                              if (isFollowing)
                                Positioned(
                                  top: v.height * 0.015,
                                  left: v.width * 0.2,
                                  child: Row(
                                    children: [
                                      Image.network(
                                        themeProvider.isDarkMode ? s119 : s51,
                                        width: v.width * 0.06,
                                        height: v.width * 0.06,
                                      ),
                                      SizedBox(width: v.width * 0.02),
                                      Text(
                                        "Following",
                                        style: TextStyle(
                                          color: const Color(0xFF754CEF),
                                          fontSize: v.width * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TabBar(
                      controller: _tabController1,
                      labelColor: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
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
                          Column(
                            children: [
                              if (podcasts.isNotEmpty) ...[
                                // See All header for Podcast
                                Padding(
                                  padding: const EdgeInsets.symmetric(),
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
                                                  'id': channels[0]["id"],
                                                  'r': 14
                                                }, // Passe la valeur de r comme argument
                                              );
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
                                    itemCount: podcasts.length,
                                    itemBuilder: (context, index) {
                                      final item = podcasts[index];
                                      return Container(
                                        margin: EdgeInsets.all(v.width * 0.02),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              v.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          ),
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
                                                'feat':
                                                    12, // remplace "someValue" par ce que tu veux représenter
                                              },
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              SizedBox(width: v.width * 0.01),
                                              Image.network(
                                                s48,
                                                width: v.width * 0.09,
                                                height: v.width * 0.09,
                                                fit: BoxFit.cover,
                                              ),
                                              SizedBox(width: v.width * 0.03),
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
                                              SizedBox(width: v.width * 0.02),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                      height: v.width * 0.0),
                                                  SizedBox(
                                                    width: v.width * 0.35,
                                                    child: Text(
                                                      item["name"]!,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            v.width * 0.04,
                                                      ),
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: v.width * 0.01),
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
                                                          0.2, // Constrain the width of the progress bar
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: v.width *
                                                                    0.05,
                                                                height:
                                                                    v.width *
                                                                        0.05,
                                                                child: Image
                                                                    .network(
                                                                  themeProvider
                                                                          .isDarkMode
                                                                      ? s111
                                                                      : s37,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: v.width *
                                                                    0.01,
                                                              ),
                                                              Text(
                                                                formatLikes(item[
                                                                    "likes"]),
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
                                                            height:
                                                                v.width * 0.02,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: v.width *
                                                                    0.05,
                                                                height:
                                                                    v.width *
                                                                        0.05,
                                                                child: Image
                                                                    .network(
                                                                  themeProvider
                                                                          .isDarkMode
                                                                      ? s108
                                                                      : s14,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: v.width *
                                                                    0.01,
                                                              ),
                                                              Text(
                                                                formatLikes(
                                                                    item[
                                                                        "vue"]),
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
                                                            height:
                                                                v.width * 0.02,
                                                          ),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width: v.width *
                                                                    0.05,
                                                                height:
                                                                    v.width *
                                                                        0.05,
                                                                child: Image
                                                                    .network(
                                                                  themeProvider
                                                                          .isDarkMode
                                                                      ? s112
                                                                      : s38,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: v.width *
                                                                    0.01,
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
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              if (podcasts.isEmpty) ...[
                                Column(children: [
                                  SizedBox(
                                    height: v.height * 0.05,
                                  ),
                                  SizedBox(
                                    width: v.width * 0.7,
                                    height: v.height * 0.3,
                                    child: Image.network(
                                        themeProvider.isDarkMode ? s109 : s28),
                                  ),
                                  Text("Not Yet",
                                      style: TextStyle(
                                          fontSize: v.width * 0.04,
                                          fontWeight: FontWeight.bold)),
                                ])
                              ],
                            ],
                          ),
                          Column(
                            children: [
                              if (playlists.isEmpty) ...[
                                Column(children: [
                                  SizedBox(
                                    height: v.height * 0.05,
                                  ),
                                  SizedBox(
                                    width: v.width * 0.7,
                                    height: v.height * 0.3,
                                    child: Image.network(
                                        themeProvider.isDarkMode ? s109 : s28),
                                  ),
                                  Text("Not Yet",
                                      style: TextStyle(
                                          fontSize: v.width * 0.04,
                                          fontWeight: FontWeight.bold)),
                                ])
                              ],
                              if (playlists.isNotEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(),
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
                                                  'id': channels[0]["id"],
                                                  'r': 15
                                                }, // Passe la valeur de r comme argument
                                              );
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
                                    itemCount: playlists.length,
                                    itemBuilder: (context, index) {
                                      final item = playlists[index];
                                      return Container(
                                        margin: EdgeInsets.all(v.width * 0.02),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              v.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          ),
                                        ),
                                        width: v.width * 0.95,
                                        height: v.width * 0.3,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/play', arguments: {
                                              'idplay': item["id"],
                                              'pp': 5
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
                                                  SizedBox(
                                                      height: v.width * 0.02),
                                                  SizedBox(
                                                    width: v.width * 0.3,
                                                    child: Text(
                                                      item["name"]!,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            v.width * 0.04,
                                                      ),
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: v.width * 0.04,
                                              ),
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        width: v.width *
                                                            0.2, // Constrain the width of the progress bar
                                                        child:
                                                            Column(children: [
                                                          SizedBox(
                                                            height:
                                                                v.width * 0.02,
                                                          ),
                                                          Column(children: [
                                                            Text(
                                                              formatLikes(item[
                                                                  "podcast"]!),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    v.width *
                                                                        0.035,
                                                              ),
                                                              maxLines: 4,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(
                                                              width: v.width *
                                                                  0.03,
                                                            ),
                                                            Text(
                                                              "Podcast",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    v.width *
                                                                        0.035,
                                                              ),
                                                              maxLines: 4,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ])
                                                        ]))
                                                  ])
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
    ));
  }
}
