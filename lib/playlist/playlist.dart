import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:pfeapp/constants.dart';
import 'dart:async';

class Playlistpage extends StatefulWidget {
  const Playlistpage({super.key});
  @override
  State<Playlistpage> createState() => _PlaylistpageState();
}

class _PlaylistpageState extends State<Playlistpage>
    with SingleTickerProviderStateMixin {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  late TabController _tabController1;
  String? idplay;
  late int? pp = 1;
  bool isFollowing = false;
  List<Map<String, dynamic>> podcastPlaylists = [];
  List<Map<String, dynamic>> playlist = [];
  List<Map<String, dynamic>> channel = [];
  List<Map<String, dynamic>> userPodcasts = [];
  final List<StreamSubscription> _subscriptions = [];

  List<Map<String, dynamic>> mesplaylist = [];
  Future<void> fetchmesPlaylistsId(String idplay) async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      StreamSubscription subscription = FirebaseFirestore.instance
          .collection('mesplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots()
          .listen((playinPodSnapshot) {
        List<Map<String, dynamic>> mesPlayInfos = [];
        for (var doc in playinPodSnapshot.docs) {
          final data = doc.data();
          if (data.containsKey('idplay') && data.containsKey('dateCreation')) {
            mesPlayInfos.add({
              'idplay': data['idplay'],
              'dateCreation': data['dateCreation'],
            });
          }
        }

        if (mesPlayInfos.isNotEmpty) {
          _processMesPlayInfos(mesPlayInfos, idplay);
        } else {
          setState(() {
            mesplaylist = [];
          });
        }
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(subscription);
    } catch (e) {
      setState(() {
        mesplaylist = [];
      });
    }
  }

  void _processMesPlayInfos(
      List<Map<String, dynamic>> mesPlayInfos, String idplay) async {
    List<Map<String, dynamic>> allPlaylists = [];
    List<String> playlistIds =
        mesPlayInfos.map((e) => e['idplay'] as String).toList();

    for (int i = 0; i < playlistIds.length; i += 10) {
      int end = (i + 10 < playlistIds.length) ? i + 10 : playlistIds.length;
      List<String> batch = playlistIds.sublist(i, end);

      StreamSubscription batchSubscription = FirebaseFirestore.instance
          .collection('playlist')
          .where('id', whereIn: batch)
          .snapshots()
          .listen((playlistsSnapshot) {
        List<Map<String, dynamic>> batchPlaylists = [];
        for (var doc in playlistsSnapshot.docs) {
          // ignore: unnecessary_cast
          final playlistData = doc.data() as Map<String, dynamic>;
          final matchingMes = mesPlayInfos.firstWhere(
              (element) => element['idplay'] == playlistData['id'],
              orElse: () => {});

          if (matchingMes.isNotEmpty) {
            playlistData['dateCreation'] = matchingMes['dateCreation'];
          }

          batchPlaylists.add(playlistData);
        }

        // Merge batch results with main list
        allPlaylists.addAll(batchPlaylists);

        // Sort and update UI after adding batch
        _finalizeMesPlaylistsProcessing(allPlaylists, idplay);
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(batchSubscription);
    }
  }

  Future<void> fetchPodcastsByUserId(String idplay) async {
    try {
      StreamSubscription querySubscription = FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: idplay)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String idUser = querySnapshot.docs.first.data()['userId'];

          StreamSubscription podcastsSubscription = FirebaseFirestore.instance
              .collection('playlist')
              .orderBy('createdAt', descending: true)
              .where('userId', isEqualTo: idUser)
              .snapshots()
              .listen((podcastsSnapshot) {
            if (podcastsSnapshot.docs.isNotEmpty) {
              List<Map<String, dynamic>> podcasts = podcastsSnapshot.docs
                  // ignore: unnecessary_cast
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

              // Remove the podcast with the same id as idplay
              podcasts.removeWhere((podcast) => podcast['id'] == idplay);

              setState(() {
                userPodcasts = podcasts;
              });
            }
          });

          // Ajouter l'abonnement à la liste
          _subscriptions.add(podcastsSubscription);
        }
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(querySubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> fetchPlaylistsByPodcastId(String idplay) async {
    try {
      StreamSubscription subscription = FirebaseFirestore.instance
          .collection('playinpod')
          .where('playlistId', isEqualTo: idplay)
          .orderBy('date', descending: true)
          .snapshots()
          .listen((playinPodSnapshot) {
        // Get podcasts with their dates
        List<Map<String, dynamic>> podInfos = [];

        for (var doc in playinPodSnapshot.docs) {
          final data = doc.data();
          final podcastId = data['podcastId'];
          final date = data['date'];

          podInfos.add({
            'podcastId': podcastId,
            'date': date,
          });
        }

        if (podInfos.isNotEmpty) {
          _processPodInfos(podInfos);
        } else {
          setState(() {
            podcastPlaylists = [];
          });
        }
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(subscription);
    } catch (e) {
      setState(() {
        podcastPlaylists = [];
      });
    }
  }

  void _processPodInfos(List<Map<String, dynamic>> podInfos) async {
    for (int i = 0; i < podInfos.length; i += 10) {
      int end = (i + 10 < podInfos.length) ? i + 10 : podInfos.length;
      List<String> batch = podInfos
          .sublist(i, end)
          .map((e) => e['podcastId'] as String)
          .toList();

      StreamSubscription batchSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', whereIn: batch)
          .snapshots()
          .listen((podcastsSnapshot) {
        List<Map<String, dynamic>> batchPodcasts = [];
        for (var doc in podcastsSnapshot.docs) {
          final data = doc.data();
          batchPodcasts.add(data);
        }

        // Process this batch
        _processAndSortPodcasts(batchPodcasts, podInfos);
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(batchSubscription);
    }
  }

  void _processAndSortPodcasts(List<Map<String, dynamic>> allPodcasts,
      List<Map<String, dynamic>> podInfos) {
    // Associate playinpod dates for sorting
    List<Map<String, dynamic>> sortedPods = [];

    for (var info in podInfos) {
      final match = allPodcasts.firstWhere(
        (pod) => pod['id'] == info['podcastId'],
        orElse: () => {},
      );

      if (match.isNotEmpty) {
        match['playinpodDate'] = info['date'];
        sortedPods.add(match);
      }
    }

    // Sort by playinpod date (descending)
    sortedPods.sort((a, b) {
      Timestamp? dateA = a['playinpodDate'];
      Timestamp? dateB = b['playinpodDate'];
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    setState(() {
      podcastPlaylists = sortedPods;
    });
  }

  void _finalizeMesPlaylistsProcessing(
      List<Map<String, dynamic>> allPlaylists, String idplay) {
    // Sort by date (most recent first)
    allPlaylists.sort((a, b) {
      Timestamp? dateA = a['dateCreation'];
      Timestamp? dateB = b['dateCreation'];

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    // Remove the playlist with the same ID as idplay
    allPlaylists.removeWhere((playlist) => playlist['id'] == idplay);

    setState(() {
      mesplaylist = allPlaylists;
    });
  }

  Future<void> fetchPlaylidtById(String idplay) async {
    try {
      StreamSubscription subscription = FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: idplay)
          .snapshots()
          .listen((querySnapshot) {
        setState(() {
          playlist = querySnapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(subscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  final user = FirebaseAuth.instance.currentUser?.uid;
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

  bool isLoading = true;
  bool isYourPlaylist = false;
  Future<void> fetchChannelByPlaylistId(String idplay) async {
    try {
      StreamSubscription querySubscription = FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: idplay)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String idUser = querySnapshot.docs.first.data()['userId'];

          StreamSubscription channelSubscription = FirebaseFirestore.instance
              .collection('channels')
              .where('userId', isEqualTo: idUser)
              .snapshots()
              .listen((channelSnapshot) {
            if (channelSnapshot.docs.isNotEmpty) {
              setState(() {
                channel = channelSnapshot.docs
                    // ignore: unnecessary_cast
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
              });
            }
          });

          // Ajouter l'abonnement à la liste
          _subscriptions.add(channelSubscription);
        }
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(querySubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('idplay')) {
          idplay = arguments['idplay'];
        }
        if (arguments.containsKey('pp')) {
          pp = arguments['pp'];
        }

        if (idplay != null) {
          await fetchPlaylidtById(idplay!);
          await checkIfCurrentUserOwnsPlaylist(idplay!);
          await fetchChannelByPlaylistId(idplay!);
          await checkIfUserIsFollowing();
          await fetchPlaylistsByPodcastId(idplay!);
          await fetchPodcastsByUserId(idplay!);
          await _fetchsaveStatus();
          await fetchmesPlaylistsId(idplay!);
        }
      }
      await Future.delayed(const Duration(seconds: 3));
      setState(() => isLoading = false);
    });
  }

  Future<String?> getPlaylistUserId() async {
    try {
      final playDoc = await FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: idplay)
          .get();

      if (playDoc.docs.isNotEmpty) {
        return playDoc.docs.first.data()['userId'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

// Fonction pour vérifier si l'utilisateur suit déjà
  Future<void> checkIfUserIsFollowing() async {
    if (user == null) return;

    try {
      // Get the playlist user ID
      final playUserId = await getPlaylistUserId();
      if (playUserId == null) return;

      // Check if the user is already following
      StreamSubscription subscription = FirebaseFirestore.instance
          .collection('follow')
          .where('idfollowers', isEqualTo: user)
          .where('idfollowing', isEqualTo: playUserId)
          .snapshots()
          .listen((followDoc) {
        setState(() {
          isFollowing = followDoc.docs.isNotEmpty;
        });
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(subscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> toggleFollow() async {
    if (user == null) return;

    try {
      // Obtenir l'userId du podcast
      final playUserId = await getPlaylistUserId();
      if (playUserId == null) return;

      // Sauvegarder l'état précédent pour pouvoir revenir en arrière en cas d'erreur
      final previousFollowingState = isFollowing;

      setState(() {
        isFollowing = !isFollowing;
      });

      if (isFollowing) {
        // Ajouter à la collection follow
        await FirebaseFirestore.instance.collection('follow').add({
          'idfollowers': user,
          'idfollowing': playUserId,
          'dateCreation': Timestamp.now(),
        });
        await FirebaseFirestore.instance.collection('nofi').add({
          'user1': user,
          'user2': playUserId,
          'text': 'Subscribe You',
          'date': Timestamp.now(),
          'isviewed': false,
        });

        // Vérification du channel en cherchant où userId == podcastUserId
        final QuerySnapshot channelQuery = await FirebaseFirestore.instance
            .collection('channels')
            .where('userId', isEqualTo: playUserId)
            .get();

// Vérifier si un document a été trouvé
        if (channelQuery.docs.isNotEmpty) {
          // Récupérer l'ID du document
          String channelId = channelQuery.docs.first.id;

          // Mettre à jour le champ followers avec l'ID récupéré
          await FirebaseFirestore.instance
              .collection('channels')
              .doc(channelId)
              .update({
            'followers': FieldValue.increment(1),
          });
        }

        // Vérifier si le document de l'utilisateur actuel existe
        final channelDocUser = await FirebaseFirestore.instance
            .collection('channels')
            .where('userId', isEqualTo: user)
            .get();

        if (channelDocUser.docs.isNotEmpty) {
          // Récupérer l'ID du document
          String channelIdd = channelDocUser.docs.first.id;

          // Mettre à jour le champ followers avec l'ID récupéré
          await FirebaseFirestore.instance
              .collection('channels')
              .doc(channelIdd)
              .update({
            'following': FieldValue.increment(1),
          });
        }
      } else {
        // Supprimer de la collection follow
        final followDocs = await FirebaseFirestore.instance
            .collection('follow')
            .where('idfollowers', isEqualTo: user)
            .where('idfollowing', isEqualTo: playUserId)
            .get();

        // Si aucun document n'est trouvé, c'est une erreur ou une incohérence
        if (followDocs.docs.isEmpty) {
          setState(() {
            isFollowing = previousFollowingState;
          });
          return;
        }

        // Pour chaque document trouvé
        for (var doc in followDocs.docs) {
          await doc.reference.delete();
          final QuerySnapshot channelQueryy = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', isEqualTo: playUserId)
              .get();

// Vérifier si un document a été trouvé
          if (channelQueryy.docs.isNotEmpty) {
            // Récupérer l'ID du document
            String channelIddd = channelQueryy.docs.first.id;

            // Mettre à jour le champ followers avec l'ID récupéré
            await FirebaseFirestore.instance
                .collection('channels')
                .doc(channelIddd)
                .update({
              'followers': FieldValue.increment(-1),
            });
          }

          // Vérifier si le document de l'utilisateur actuel existe
          final channelDocUserr = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', isEqualTo: user)
              .get();

          if (channelDocUserr.docs.isNotEmpty) {
            // Récupérer l'ID du document
            String channelIdds = channelDocUserr.docs.first.id;

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
      setState(() {
        isFollowing = !isFollowing;
      });
    }
  }

  Future<void> checkIfCurrentUserOwnsPlaylist(String idplay) async {
    try {
      StreamSubscription subscription = FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: idplay)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          String idUser = querySnapshot.docs.first.data()['userId'];
          String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

          setState(() {
            isYourPlaylist = (currentUserId == idUser);
          });
        }
      });

      // Ajouter l'abonnement à la liste
      _subscriptions.add(subscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  String getSaveIcon(ThemeProvider themeProvider) {
    if (isSaved) {
      return themeProvider.isDarkMode ? s121 : s43;
    } else {
      return themeProvider.isDarkMode ? s120 : s42;
    }
  }

  bool isSaved = false;
  Future<void> _fetchsaveStatus() async {
    StreamSubscription subscription = FirebaseFirestore.instance
        .collection('mesplaylist')
        .where('iduser', isEqualTo: user)
        .where('idplay', isEqualTo: idplay)
        .snapshots()
        .listen((saveQuery) {
      setState(() {
        isSaved = saveQuery.docs.isNotEmpty;
      });
    });

    // Ajouter l'abonnement à la liste
    _subscriptions.add(subscription);
  }

  void _toggleSave() async {
    final saveRef = FirebaseFirestore.instance.collection('mesplaylist');

    if (!isSaved) {
      // Ajouter le like
      await saveRef.add({
        'iduser': user,
        'idplay': idplay,
        'dateCreation': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('nofi').add({
        'user1': FirebaseAuth.instance.currentUser?.uid,
        'user2': playlist[0]["userId"],
        'text': ' Save Your Playlist',
        'date': Timestamp.now(),
        'isviewed': false,
      });
      await FirebaseFirestore.instance
          .collection('playlist')
          .doc(idplay)
          .update({
        'save': FieldValue.increment(1),
      });
      setState(() {
        isSaved = true;
      });
    } else {
      // Supprimer le like
      final saveQuery = await saveRef
          .where('iduser', isEqualTo: user)
          .where('idplay', isEqualTo: idplay)
          .get();
      for (var doc in saveQuery.docs) {
        await doc.reference.delete();
        await FirebaseFirestore.instance
            .collection('playlist')
            .doc(idplay)
            .update({
          'save': FieldValue.increment(-1),
        });
      }
      setState(() {
        isSaved = false;
      });
    }
  }

  @override
  void dispose() {
    // Annuler tous les abonnements
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // Nettoyer le contrôleur d'onglets
    _tabController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size w = MediaQuery.of(context).size;
    final themeProvider1 = Provider.of<ThemeProvider>(context);

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

                child: Stack(
                  fit: StackFit
                      .expand, // Force le Stack à prendre tout l'espace disponible
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        width: w.width,
                        height: w.height * 0.3,
                        child: Image.network(playlist[0]['photoUrl'],
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: w.width * 0.55,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(w.width * 0.05),
                        ),
                        width: w.width,
                        height: w.height * 0.1,
                      ),
                    ),

                    if (pp == 2) ...[
                      Positioned(
                          top: w.height * 0.01,
                          left: w.width * 0.03,
                          child: Container(
                            width: w.width * 0.1,
                            height: w.width * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius:
                                    BorderRadius.circular(w.width * 0.05)),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/podly', (route) => false,
                                    arguments: {'selectedIndex': 3});
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
                                width: w.width * 0.07,
                                height: w.width * 0.07,
                              ),
                            ),
                          )),
                      if (podcastPlaylists.isNotEmpty) ...[
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': podcastPlaylists[0]["id"],
                                  'featl': 11,
                                  'idplay1': playlist[0][
                                      'id'] // remplace "someValue" par ce que tu veux représenter
                                },
                              );
                            },
                            icon: Image.network(
                              s48,
                              width: w.width * 0.14,
                              height: w.width * 0.14,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ]
                    ],
                    if (pp == 3) ...[
                      Positioned(
                          top: w.height * 0.01,
                          left: w.width * 0.03,
                          child: Container(
                            width: w.width * 0.1,
                            height: w.width * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius:
                                    BorderRadius.circular(w.width * 0.05)),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
                                width: w.width * 0.07,
                                height: w.width * 0.07,
                              ),
                            ),
                          )),
                      if (podcastPlaylists.isNotEmpty) ...[
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/podcast',
                                arguments: {
                                  'idpod': podcastPlaylists[0]["id"],
                                  'feat':
                                      3, // remplace "someValue" par ce que tu veux représenter
                                },
                              );
                            },
                            icon: Image.network(
                              s48,
                              width: w.width * 0.14,
                              height: w.width * 0.14,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ]
                    ],
                    if (pp == 4) ...[
                      Positioned(
                          top: w.height * 0.01,
                          left: w.width * 0.03,
                          child: Container(
                            width: w.width * 0.1,
                            height: w.width * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius:
                                    BorderRadius.circular(w.width * 0.05)),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
                                width: w.width * 0.07,
                                height: w.width * 0.07,
                              ),
                            ),
                          )),
                      if (podcastPlaylists.isNotEmpty) ...[
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/podcast',
                                arguments: {
                                  'idpod': podcastPlaylists[0]["id"],
                                  'feat':
                                      3, // remplace "someValue" par ce que tu veux représenter
                                },
                              );
                            },
                            icon: Image.network(
                              s48,
                              width: w.width * 0.14,
                              height: w.width * 0.14,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ]
                    ],
                    if (pp == 5) ...[
                      Positioned(
                          top: w.height * 0.01,
                          left: w.width * 0.03,
                          child: Container(
                            width: w.width * 0.1,
                            height: w.width * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius:
                                    BorderRadius.circular(w.width * 0.05)),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
                                width: w.width * 0.07,
                                height: w.width * 0.07,
                              ),
                            ),
                          )),
                      if (podcastPlaylists.isNotEmpty) ...[
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/podcast',
                                arguments: {
                                  'idpod': podcastPlaylists[0]["id"],
                                  'feat':
                                      3, // remplace "someValue" par ce que tu veux représenter
                                },
                              );
                            },
                            icon: Image.network(
                              s48,
                              width: w.width * 0.14,
                              height: w.width * 0.14,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ]
                    ],
                    if (pp == 6) ...[
                      Positioned(
                          top: w.height * 0.01,
                          left: w.width * 0.03,
                          child: Container(
                            width: w.width * 0.1,
                            height: w.width * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius:
                                    BorderRadius.circular(w.width * 0.05)),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s97 : s18,
                                width: w.width * 0.07,
                                height: w.width * 0.07,
                              ),
                            ),
                          )),
                      if (podcastPlaylists.isNotEmpty) ...[
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/podcast',
                                arguments: {
                                  'idpod': podcastPlaylists[0]["id"],
                                  'feat':
                                      3, // remplace "someValue" par ce que tu veux représenter
                                },
                              );
                            },
                            icon: Image.network(
                              s48,
                              width: w.width * 0.14,
                              height: w.width * 0.14,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ]
                    ],
                    Positioned(
                      top: w.height * 0.28,
                      child: SizedBox(
                        width: w.width * 0.7,
                        child: Column(children: [
                          Text(
                            playlist[0]['name'],
                            style: TextStyle(
                              fontSize: w.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 3,
                          ),
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a')
                                .format(playlist[0]["createdAt"].toDate()),
                            //podcast[0]["dateCreation"],
                            style: TextStyle(
                              fontSize: w.width * 0.04,
                            ),
                            maxLines: 3,
                          ),
                        ]),
                      ),
                    ),
                    Positioned(
                      top: w.height * 0.37,
                      left: w.width * 0.05,
                      right: w.width * 0.05, // Ajouter une contrainte de droite
                      child: Wrap(
                        spacing: w.width *
                            0.02, // Espacement horizontal entre les éléments
                        runSpacing: w.width *
                            0.02, // Espacement vertical entre les lignes
                        children: [
                          // Quatrième élément (comments)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: w.width * 0.01,
                              ),
                              Image.network(
                                  themeProvider.isDarkMode ? s120 : s42,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(playlist[0]["save"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                  )),
                            ],
                          ),
                          SizedBox(
                            width: w.width * 0.03,
                          ),
                          // Cinquième élément (shares)

                          SizedBox(
                            width: w.width * 0.03,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                  themeProvider.isDarkMode ? s110 : s30,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(playlist[0]["podcast"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: w.height * 0.41,
                      left: w.width * 0.05,
                      child: Text(
                        "Description", // Fixed spelling
                        style: TextStyle(
                            fontSize: w.width * 0.04,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

// Fix the second ReadMoreText (at w.height * 0.5)
                    Positioned(
                      top: w.height * 0.44,
                      left: w.width * 0.05, // Add left positioning
                      child: SizedBox(
                        width: w.width * 0.9, // Add width constraint
                        child: ReadMoreText(
                          playlist[0]["description"],
                          trimMode: TrimMode.Line,
                          trimLines: 2,
                          trimCollapsedText: 'Show more',
                          trimExpandedText: 'Show less',
                          moreStyle: TextStyle(
                              fontSize: w.width * 0.03,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF754CEF)),
                          lessStyle: TextStyle(
                              fontSize: w.width * 0.03,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF754CEF)),
                        ),
                      ),
                    ),

                    Positioned(
                      top: w.height * 0.57,
                      left: w.width * 0.02,
                      // ignore: avoid_unnecessary_containers
                      child: Container(
                        child: GestureDetector(
                          onTap: () {
                            if (userId == channel[0]["userId"]) {
                              Navigator.pushNamed(context, '/your',
                                  arguments: {'your': 4});
                            }
                            if (userId != channel[0]["userId"]) {
                              Navigator.pushNamed(
                                context,
                                '/channel',
                                arguments: {
                                  'id': channel[0]["id"],
                                  'chaine': 5,
                                },
                              );
                            }
                          },
                          child: Row(children: [
                            Container(
                              width: w.width * 0.2,
                              height: w.width * 0.2,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(w.width * 0.2)),
                              child: ClipOval(
                                child: Image.network(
                                  channel[0]["photoUrl"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: w.width * 0.01,
                            ),
                            Column(
                              children: [
                                Text(
                                  channel[0]["name"],
                                  style: TextStyle(
                                      fontSize: w.width * 0.045,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(formatLikes(channel[0]["followers"]),
                                        style: TextStyle(
                                          fontSize: w.width * 0.035,

                                          //   fontWeight: FontWeight.bold),
                                        )),
                                    const Text(" "),
                                    Text("Followers",
                                        style: TextStyle(
                                          fontSize: w.width * 0.035,

                                          //   fontWeight: FontWeight.bold),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              width: w.width * 0.01,
                            ),
                            if (isYourPlaylist == false) ...[
                              Positioned(
                                top: w.height * 0.68,
                                right: w.width * 0.01,
                                child: SizedBox(
                                  height: w.height * 0.05,
                                  width: w.width * 0.32,
                                  child: MaterialButton(
                                    onPressed:
                                        toggleFollow, // Utiliser la fonction toggleFollow
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      height: w.height * 0.05,
                                      width: w.width * 0.3,
                                      decoration: BoxDecoration(
                                        color: isFollowing
                                            ? themeProvider.isDarkMode
                                                ? Colors.black
                                                : Colors.white
                                            : const Color(0xFF754CEF),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(w.width * 0.05),
                                        ),
                                        border: isFollowing
                                            ? Border.all(
                                                color: const Color(0xFF754CEF))
                                            : null,
                                      ),
                                      child: Stack(
                                        children: [
                                          if (!isFollowing)
                                            Positioned(
                                              top: w.height * 0.014,
                                              left: w.width *
                                                  0.03, // Centrer un peu plus
                                              child: Text(
                                                "Follow Now",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: w.width * 0.035,
                                                ),
                                              ),
                                            ),
                                          if (isFollowing)
                                            Positioned(
                                              top: w.height * 0.014,
                                              left: w.width * 0.012,
                                              child: Row(
                                                children: [
                                                  Image.network(
                                                    themeProvider.isDarkMode
                                                        ? s119
                                                        : s51,
                                                    width: w.width * 0.05,
                                                    height: w.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                      width: w.width * 0.01),
                                                  Text(
                                                    "Following",
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF754CEF),
                                                      fontSize: w.width * 0.03,
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
                              )
                            ],
                          ]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: w.height * 0.67,
                      left: w.width * 0.3,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _toggleSave,
                          child: Padding(
                              padding: EdgeInsets.all(w.width * 0.02),
                              child: Row(children: [
                                Image.network(
                                  getSaveIcon(themeProvider1),
                                  width: w.width * 0.05,
                                  height: w.width * 0.05,
                                  gaplessPlayback: true,
                                ),
                                SizedBox(
                                  width: w.width * 0.02,
                                ),
                                Text(
                                  "Save",
                                  style: TextStyle(
                                      fontSize: w.width * 0.035,
                                      fontWeight: FontWeight.bold),
                                ),
                              ])),
                        ),
                      ),
                    ),

                    Positioned(
                      top: w.height * 0.71,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: w.width * 0.03),
                            child: TabBar(
                              controller: _tabController1,
                              labelColor: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              labelStyle: TextStyle(
                                fontSize: w.width * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: w.width * 0.04,
                                fontWeight: FontWeight.normal,
                              ),
                              tabs: const [
                                Tab(text: 'Podcasts'),
                                Tab(text: 'More Playlists'),
                              ],
                              indicatorSize: TabBarIndicatorSize.label,
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController1,
                              children: [
                                if (podcastPlaylists.isNotEmpty) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: w.width * 0.02),
                                    child: ListView.builder(
                                      itemCount: podcastPlaylists.length,
                                      itemBuilder: (context, index) {
                                        final item = podcastPlaylists[index];
                                        return Container(
                                            margin:
                                                EdgeInsets.all(w.width * 0.02),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      w.width * 0.05),
                                              border: Border.all(
                                                color: themeProvider.isDarkMode
                                                    ? Colors.white70
                                                    : Colors.black12,
                                              ),
                                            ),
                                            width: w.width * 0.95,
                                            height: w.width * 0.3,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (pp == 2) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': item["id"],
                                                      'feat':
                                                          3, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }
                                                if (pp == 3) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': item["id"],
                                                      'feat':
                                                          3, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }
                                                if (pp == 4) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': item["id"],
                                                      'feat':
                                                          3, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }
                                                if (pp == 5) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': item["id"],
                                                      'feat':
                                                          3, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }
                                                if (pp == 6) {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': item["id"],
                                                      'feat':
                                                          3, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }
                                              },
                                              child: Row(
                                                // Add this to prevent overflow
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  SizedBox(
                                                      width: w.width * 0.01),
                                                  Image.network(
                                                    s48,
                                                    width: w.width *
                                                        0.07, // Slightly reduce size if needed
                                                    height: w.width * 0.07,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  SizedBox(
                                                      width: w.width *
                                                          0.02), // Reduce spacing slightly
                                                  Container(
                                                    height: w.width * 0.2,
                                                    width: w.width *
                                                        0.18, // Adjust width to be slightly smaller
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              w.width * 0.04),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            item["urlPhoto"]!),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: w.width * 0.02),
                                                  Expanded(
                                                    // Add Expanded to make text take available space
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                            height:
                                                                w.width * 0.0),
                                                        Text(
                                                          item["name"]!,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: w.width *
                                                                0.035, // Slightly smaller font
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                w.width * 0.01),
                                                      ],
                                                    ),
                                                  ),
                                                  // No fixed width SizedBox here - let the Expanded handle spacing
                                                  SizedBox(
                                                    width: w.width *
                                                        0.2, // Fixed width for the stats column
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisSize: MainAxisSize
                                                              .min, // Make row take minimum space
                                                          children: [
                                                            Image.network(
                                                              themeProvider
                                                                      .isDarkMode
                                                                  ? s111
                                                                  : s37,
                                                              width: w.width *
                                                                  0.04,
                                                              height: w.width *
                                                                  0.04,
                                                            ),
                                                            SizedBox(
                                                                width: w.width *
                                                                    0.01),
                                                            Text(
                                                              formatLikes(item[
                                                                  "likes"]!),
                                                              style: TextStyle(
                                                                  fontSize: w
                                                                          .width *
                                                                      0.03, // Slightly smaller font
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisSize: MainAxisSize
                                                              .min, // Make row take minimum space
                                                          children: [
                                                            Image.network(
                                                              themeProvider
                                                                      .isDarkMode
                                                                  ? s108
                                                                  : s14,
                                                              width: w.width *
                                                                  0.04,
                                                              height: w.width *
                                                                  0.04,
                                                            ),
                                                            SizedBox(
                                                                width: w.width *
                                                                    0.01),
                                                            Text(
                                                              formatLikes(
                                                                  item["vue"]!),
                                                              style: TextStyle(
                                                                  fontSize: w
                                                                          .width *
                                                                      0.03, // Slightly smaller font
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisSize: MainAxisSize
                                                              .min, // Make row take minimum space
                                                          children: [
                                                            Image.network(
                                                              themeProvider
                                                                      .isDarkMode
                                                                  ? s112
                                                                  : s38,
                                                              width: w.width *
                                                                  0.04,
                                                              height: w.width *
                                                                  0.04,
                                                            ),
                                                            SizedBox(
                                                                width: w.width *
                                                                    0.01),
                                                            Text(
                                                              formatLikes(item[
                                                                  "comments"]!),
                                                              style: TextStyle(
                                                                  fontSize: w
                                                                          .width *
                                                                      0.03, // Slightly smaller font
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ));
                                      },
                                    ),
                                  ),
                                ],
                                if (podcastPlaylists.isEmpty) ...[
                                  Column(children: [
                                    SizedBox(
                                      height: w.height * 0.01,
                                    ),
                                    SizedBox(
                                      width: w.width * 0.7,
                                      height: w.height * 0.15,
                                      child: Image.network(
                                          themeProvider.isDarkMode
                                              ? s109
                                              : s28),
                                    ),
                                    Text("Not Yet",
                                        style: TextStyle(
                                            fontSize: w.width * 0.04,
                                            fontWeight: FontWeight.bold)),
                                  ])
                                ],
                                if (userPodcasts.isNotEmpty) ...[
                                  if (pp == 3 ||
                                      pp == 4 ||
                                      pp == 5 ||
                                      pp == 6) ...[
                                    SizedBox(
                                      height: w.height * 0.23,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: userPodcasts.length,
                                        itemBuilder: (context, index) {
                                          final playItem = userPodcasts[index];
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: w.width * 0.02),
                                            width: w.width * 0.2,
                                            height: w.width *
                                                0.35, // Increased height to accommodate content
                                            child: GestureDetector(
                                              onTap: () {
                                                if (pp == 3) {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, '/play',
                                                          arguments: {
                                                        'idplay':
                                                            playItem["id"],
                                                        'pp': 3
                                                      });
                                                }
                                                if (pp == 4) {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, '/play',
                                                          arguments: {
                                                        'idplay':
                                                            playItem["id"],
                                                        'pp': 4
                                                      });
                                                }
                                                if (pp == 5) {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, '/play',
                                                          arguments: {
                                                        'idplay':
                                                            playItem["id"],
                                                        'pp': 5
                                                      });
                                                }
                                                if (pp == 6) {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                          context, '/play',
                                                          arguments: {
                                                        'idplay':
                                                            playItem["id"],
                                                        'pp': 6
                                                      });
                                                }
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Add this
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: w.width * 0.2,
                                                    width: w.width * 0.2,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              w.width * 0.04),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            playItem[
                                                                'photoUrl']),
                                                        fit: BoxFit.cover,
                                                        onError: (exception,
                                                            stackTrace) {},
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: w.width * 0.01),
                                                  Flexible(
                                                      child: Text(
                                                    playItem['name'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: w.width * 0.04,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  if (pp == 2) ...[
                                    SizedBox(
                                      height: w.height * 0.23,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: userPodcasts.length,
                                        itemBuilder: (context, index) {
                                          final playItem = userPodcasts[index];
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: w.width * 0.02,
                                                vertical: w.height * 0.01),
                                            width: w.width * 0.2,
                                            height: w.width *
                                                0.35, // Increased height to accommodate content
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushReplacementNamed(
                                                    context, '/play',
                                                    arguments: {
                                                      'idplay': playItem["id"],
                                                      'pp': 2
                                                    });
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize
                                                    .min, // Add this
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: w.width * 0.2,
                                                    width: w.width * 0.2,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              w.width * 0.04),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            playItem[
                                                                'photoUrl']),
                                                        fit: BoxFit.cover,
                                                        onError: (exception,
                                                            stackTrace) {},
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: w.width * 0.01),
                                                  Flexible(
                                                      child: Text(
                                                    playItem['name'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: w.width * 0.04,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                                if (userPodcasts.isEmpty) ...[
                                  Column(children: [
                                    SizedBox(
                                      height: w.height * 0.001,
                                    ),
                                    SizedBox(
                                      width: w.width * 0.7,
                                      height: w.height * 0.15,
                                      child: Image.network(
                                          themeProvider.isDarkMode
                                              ? s109
                                              : s28),
                                    ),
                                    Text("Not Yet",
                                        style: TextStyle(
                                            fontSize: w.width * 0.04,
                                            fontWeight: FontWeight.bold)),
                                  ])
                                ]
                              ],
                            ),
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
