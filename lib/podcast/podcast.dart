// ignore_for_file: empty_catches

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:pfeapp/main.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Podcastpage extends StatefulWidget {
  const Podcastpage({super.key});
  @override
  State<Podcastpage> createState() => _PodcastpageState();
}

class _PodcastpageState extends State<Podcastpage>
    with TickerProviderStateMixin {
  // Streams
  StreamSubscription<QuerySnapshot>? podcastSubscription;
  StreamSubscription<QuerySnapshot>? channelSubscription;
  StreamSubscription<QuerySnapshot>? userPodcastsSubscription;
  StreamSubscription<QuerySnapshot>? podcastPlaylistsSubscription;
  StreamSubscription<QuerySnapshot>? podvueSubscription;
  StreamSubscription<QuerySnapshot>? recentIdSubscription;
  StreamSubscription<QuerySnapshot>? relatedPodcastsSubscription;
  StreamSubscription<QuerySnapshot>? myPlaylistSubscription;
  StreamSubscription<QuerySnapshot>? followSubscription;
  List<StreamSubscription<QuerySnapshot>>? batchStreamSubscriptions = [];

  // Récupération de l'ID
  Future<void> checkAndAddReport(String idpod) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final reportsRef = FirebaseFirestore.instance.collection('reports');

      // Utilisation de snapshots() au lieu de get()
      final reportsStream = reportsRef
          .where('user', isEqualTo: userId)
          .where('pod', isEqualTo: idpod)
          .snapshots();

      await reportsStream.first.then((snapshot) async {
        if (snapshot.docs.isEmpty) {
          // Aucune déclaration trouvée : on ajoute
          await reportsRef.add({
            'user': userId,
            'pod': idpod,
            'date': FieldValue.serverTimestamp(),
          });
          await FirebaseFirestore.instance
              .collection('podcasts')
              .doc(idpod)
              .update({
            'report': FieldValue.increment(1),
          }); // Add
        } else {}
      });
      // ignore: duplicate_ignore
      // ignore: empty_catches
    } catch (e) {}
  }

  String? idpod;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  late int? feat;
  late int your = 1;
  late int feal = 1;
  bool isFollowing = false;

  Future<void> fetchRelatedPodcastsById(String idpod) async {
    try {
      // 1. Récupérer le podcast en question
      final podcastStream = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .snapshots();

      relatedPodcastsSubscription = podcastStream.listen((snapshot) async {
        if (snapshot.docs.isEmpty) {
          setState(() {
            relatedPodcasts = [];
          });
          return;
        }

        final podcastData = snapshot.docs.first.data();
        final String category = (podcastData['category'] ?? '').toString();

        // 2. Rechercher tous les autres podcasts de cette catégorie
        final relatedStream = FirebaseFirestore.instance
            .collection('podcasts')
            .where('category', isEqualTo: category)
            .orderBy('dateCreation', descending: true)
            .snapshots();

        final relatedSubscription = relatedStream.listen((relatedSnapshot) {
          final related = relatedSnapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          String idpodASupprimer = idpod;

          related.removeWhere((podcast) => podcast['id'] == idpodASupprimer);
          setState(() {
            relatedPodcasts = related;
          });
        });

        batchStreamSubscriptions?.add(relatedSubscription);
      });
    } catch (e) {
      setState(() {
        relatedPodcasts = [];
      });
    }
  }

  Future<void> fetchfeuteredppodcast(String idpod) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final recentPodcastsStream = FirebaseFirestore.instance
          .collection('podcasts')
          .where('dateCreation',
              isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('dateCreation', descending: true)
          .snapshots();

      final String idToExclude = idpod;

      final featuredSubscription = recentPodcastsStream.listen((snapshot) {
        final allPodcasts = snapshot.docs
            .where((doc) => doc.id != idToExclude) // on filtre ici par doc ID
            // ignore: unnecessary_cast
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {
          fea = allPodcasts;
        });
      });

      batchStreamSubscriptions?.add(featuredSubscription);
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> fetchTrendingPodcasts(String idpod) async {
    final DateTime sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7));
    final Timestamp timestampSevenDaysAgo = Timestamp.fromDate(sevenDaysAgo);

    try {
      // 1️⃣ Récupérer les vues des 7 derniers jours
      final recentViewsStream = FirebaseFirestore.instance
          .collection('vues')
          .where('timevue', isGreaterThan: timestampSevenDaysAgo)
          .snapshots();

      final trendingSubscription = recentViewsStream.listen((snapshot) async {
        // 2️⃣ Récupérer tous les idpod uniques
        Set<String> recentIdPods =
            snapshot.docs.map((doc) => doc.data()['idpod'] as String).toSet();

        if (recentIdPods.isEmpty) {
          setState(() => ress = []);
          return;
        }

        // 3️⃣ Récupérer les documents podcasts correspondants
        List<Map<String, dynamic>> matchingPodcasts = [];

        List<String> idList = recentIdPods.toList();
        for (int i = 0; i < idList.length; i += 10) {
          int end = (i + 10 < idList.length) ? i + 10 : idList.length;
          List<String> batch = idList.sublist(i, end);

          final podcastStream = FirebaseFirestore.instance
              .collection('podcasts')
              .where('id', whereIn: batch)
              .snapshots();

          final podcastSubscription = podcastStream.listen((podcastSnapshot) {
            for (var doc in podcastSnapshot.docs) {
              matchingPodcasts.add(doc.data());
            }

            // 4️⃣ Trier localement les podcasts par le champ `vue` (desc)
            matchingPodcasts
                .sort((a, b) => (b['vue'] ?? 0).compareTo(a['vue'] ?? 0));

            // 5️⃣ Prendre les 10 premiers
            List<Map<String, dynamic>> top10 =
                matchingPodcasts.take(10).toList();

            // 6️⃣ Ajouter les infos des chaînes
            Set<String> userIds =
                top10.map((p) => p['idUser'] as String).toSet();
            Map<String, Map<String, dynamic>> channelsMap = {};

            for (int i = 0; i < userIds.length; i += 10) {
              int end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
              List<String> batch = userIds.toList().sublist(i, end);

              FirebaseFirestore.instance
                  .collection('channels')
                  .where('userId', whereIn: batch)
                  .snapshots()
                  .listen((channelsSnapshot) {
                for (var doc in channelsSnapshot.docs) {
                  final data = doc.data();
                  channelsMap[data['userId']] = data;
                }

                // 7️⃣ Associer les chaînes
                for (var podcast in top10) {
                  podcast['channel'] = channelsMap[podcast['idUser']];
                }
                String idpodASupprimer = idpod;

                top10
                    .removeWhere((podcast) => podcast['id'] == idpodASupprimer);
                // 🔁 Mettre à jour l'état
                setState(() {
                  ress = top10;
                });
              });
            }
          });

          batchStreamSubscriptions?.add(podcastSubscription);
        }
      });

      batchStreamSubscriptions?.add(trendingSubscription);
    } catch (e) {
      setState(() => ress = []);
    }
  }

  List<Map<String, dynamic>> ress = [];
  List<Map<String, dynamic>> recommendedPodcasts = [];
  List<Map<String, dynamic>> viewedPodcasts = [];

  Future<void> fetchRecommendedPodcasts(String idpod) async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // 1. Récupérer les documents 'vues' de l'utilisateur
      final viewedPodsStream = FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: currentUserId)
          .snapshots();

      final recommendedSubscription = viewedPodsStream.listen((snapshot) async {
        // 2. Extraire les IDs des podcasts vus
        List<String> viewedPodcastIds =
            snapshot.docs.map((doc) => doc.data()['idpod'] as String).toList();

        // 3. Récupérer les catégories à partir des podcasts vus
        Set<String> categories = {};

        for (int i = 0; i < viewedPodcastIds.length; i += 10) {
          int end = (i + 10 < viewedPodcastIds.length)
              ? i + 10
              : viewedPodcastIds.length;
          List<String> batchIds = viewedPodcastIds.sublist(i, end);

          final podcastStream = FirebaseFirestore.instance
              .collection('podcasts')
              .where('id', whereIn: batchIds)
              .snapshots();

          final categorySubscription = podcastStream.listen((podcastSnapshot) {
            for (var doc in podcastSnapshot.docs) {
              final category = doc.data()['category'];
              if (category != null) {
                categories.add(category);
              }
            }

            if (categories.isEmpty) {
              setState(() {
                viewedPodcasts = [];
                recommendedPodcasts = [];
              });

              return;
            }

            // 4. Récupérer les détails des podcasts vus
            List<Map<String, dynamic>> tempViewedPodcasts = [];

            for (int i = 0; i < viewedPodcastIds.length; i += 10) {
              int end = (i + 10 < viewedPodcastIds.length)
                  ? i + 10
                  : viewedPodcastIds.length;
              List<String> batchIds = viewedPodcastIds.sublist(i, end);

              FirebaseFirestore.instance
                  .collection('podcasts')
                  .where('id', whereIn: batchIds)
                  .snapshots()
                  .listen((snapshot) {
                for (var doc in snapshot.docs) {
                  tempViewedPodcasts.add(doc.data());
                }

                // 5. Récupérer les podcasts recommandés
                List<Map<String, dynamic>> tempRecommendedPodcasts = [];

                for (String category in categories) {
                  FirebaseFirestore.instance
                      .collection('podcasts')
                      .where('category', isEqualTo: category)
                      .orderBy('dateCreation', descending: true)
                      .limit(10)
                      .snapshots()
                      .listen((recommendedSnapshot) {
                    for (var doc in recommendedSnapshot.docs) {
                      final data = doc.data();
                      final id = data['id']?.toString();
                      if (id == null) {
                        continue;
                      }

                      if (!viewedPodcastIds.contains(id)) {
                        tempRecommendedPodcasts.add(data);
                      } else {}
                    }

                    // 6. Récupérer les infos des channels
                    Set<String> allChannelIds = {};

                    for (var podcast in [
                      ...tempViewedPodcasts,
                      ...tempRecommendedPodcasts
                    ]) {
                      if (podcast.containsKey('idUser')) {
                        allChannelIds.add(podcast['idUser']);
                      }
                    }

                    Map<String, Map<String, dynamic>> channelsMap = {};
                    List<String> channelIdsList = allChannelIds.toList();

                    for (int i = 0; i < channelIdsList.length; i += 10) {
                      int end = (i + 10 < channelIdsList.length)
                          ? i + 10
                          : channelIdsList.length;
                      List<String> batchIds = channelIdsList.sublist(i, end);

                      FirebaseFirestore.instance
                          .collection('channels')
                          .where('userId', whereIn: batchIds)
                          .snapshots()
                          .listen((channelsSnapshot) {
                        for (var doc in channelsSnapshot.docs) {
                          final data = doc.data();
                          channelsMap[data['userId']] = data;
                        }

                        // 7. Associer les channels aux podcasts
                        for (var podcast in tempViewedPodcasts) {
                          podcast['channel'] = channelsMap[podcast['idUser']];
                        }

                        for (var podcast in tempRecommendedPodcasts) {
                          podcast['channel'] = channelsMap[podcast['idUser']];
                        }
                        String idpodASupprimer = idpod;

                        tempRecommendedPodcasts.removeWhere(
                            (podcast) => podcast['id'] == idpodASupprimer);
                        // 8. Mettre à jour l'état
                        setState(() {
                          viewedPodcasts = tempViewedPodcasts;
                          recommendedPodcasts = tempRecommendedPodcasts;
                        });
                      });
                    }
                  });
                }
              });
            }
          });

          batchStreamSubscriptions?.add(categorySubscription);
        }
      });

      batchStreamSubscriptions?.add(recommendedSubscription);
    } catch (e) {
      setState(() {
        viewedPodcasts = [];
        recommendedPodcasts = [];
      });
    }
  }

  List<Map<String, dynamic>> relatedPodcasts = [];
  final user = FirebaseAuth.instance.currentUser?.uid;

  Future<void> fetrecentId(String idpod) async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // 🔁 Étape 1 : Récupérer les vues triées par timevue DESC
      final playinPodStream = FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timevue', descending: false) // ⬅️ Trie ici
          .snapshots();

      final recentIdSubscription = playinPodStream.listen((snapshot) async {
        // 🔁 Étape 2 : Construire une liste ordonnée d'idpod avec leur timevue
        List<Map<String, dynamic>> orderedIdpods = [];
        for (var doc in snapshot.docs) {
          String playlistId = doc.data()['idpod'];
          Timestamp? timevue = doc.data()['timevue'] as Timestamp?;

          // Évite les doublons (garde le premier car déjà trié)
          if (!orderedIdpods.any((e) => e['idpod'] == playlistId)) {
            orderedIdpods.add({'idpod': playlistId, 'timevue': timevue});
          }
        }

        if (orderedIdpods.isNotEmpty) {
          List<Map<String, dynamic>> allPlaylists = [];

          for (int i = 0; i < orderedIdpods.length; i += 10) {
            int end =
                (i + 10 < orderedIdpods.length) ? i + 10 : orderedIdpods.length;
            List<String> batch = orderedIdpods
                .sublist(i, end)
                .map((e) => e['idpod'] as String)
                .toList();

            final playlistsStream = FirebaseFirestore.instance
                .collection('podcasts')
                .where('id', whereIn: batch)
                .snapshots();

            final playlistSubscription =
                playlistsStream.listen((playlistsSnapshot) {
              for (var doc in playlistsSnapshot.docs) {
                // ignore: unnecessary_cast
                final data = doc.data() as Map<String, dynamic>;
                allPlaylists.add(data);
              }

              // Associer chaque podcast avec son timevue et le remettre dans l'ordre
              allPlaylists.sort((a, b) {
                final aTime = orderedIdpods.firstWhere(
                    (e) => e['idpod'] == a['id'])['timevue'] as Timestamp;
                final bTime = orderedIdpods.firstWhere(
                    (e) => e['idpod'] == b['id'])['timevue'] as Timestamp;
                return bTime.compareTo(aTime);
              });

              // 🔁 Étape 3 : Ajouter les infos du channel
              final Set<String> userIds =
                  allPlaylists.map((p) => p['idUser'] as String).toSet();
              Map<String, Map<String, dynamic>> channelsMap = {};

              for (int i = 0; i < userIds.length; i += 10) {
                int end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
                List<String> batchUserIds = userIds.toList().sublist(i, end);

                FirebaseFirestore.instance
                    .collection('channels')
                    .where('userId', whereIn: batchUserIds)
                    .snapshots()
                    .listen((channelSnap) {
                  for (var doc in channelSnap.docs) {
                    final data = doc.data();
                    channelsMap[data['userId']] = data;
                  }

                  final enrichedPlaylists = allPlaylists.map((podcast) {
                    final String idUser = podcast['idUser'];
                    final channel = channelsMap[idUser];
                    podcast['channel'] = channel;
                    return podcast;
                  }).toList();
                  // 🔥 Supprimer l'élément avec idpod spécifique
                  String idpodASupprimer = idpod;
                  enrichedPlaylists.removeWhere(
                      (podcast) => podcast['id'] == idpodASupprimer);

                  setState(() {
                    res = enrichedPlaylists;
                  });
                });
              }
            });

            batchStreamSubscriptions?.add(playlistSubscription);
          }
        } else {
          setState(() {
            res = [];
          });
        }
      });

      batchStreamSubscriptions?.add(recentIdSubscription);
    } catch (e) {
      setState(() {
        res = [];
      });
    }
  }

  late int nbr = 0;
  List<Map<String, dynamic>> mesPodcasts = [];

  Future<void> nbrpodId(String idpod) async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      final playinPodStream = FirebaseFirestore.instance
          .collection('myplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots();

      myPlaylistSubscription = playinPodStream.listen((snapshot) async {
        List<Map<String, dynamic>> myPlayInfos = [];

        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data.containsKey('idpod') && data.containsKey('dateCreation')) {
            myPlayInfos.add({
              'idpod': data['idpod'],
              'dateCreation': data['dateCreation'],
            });
          }
        }

        if (myPlayInfos.isNotEmpty) {
          List<Map<String, dynamic>> allPodcasts = [];

          List<String> podcastIds =
              myPlayInfos.map((e) => e['idpod'] as String).toList();

          for (int i = 0; i < podcastIds.length; i += 10) {
            int end = (i + 10 < podcastIds.length) ? i + 10 : podcastIds.length;
            List<String> batch = podcastIds.sublist(i, end);

            final podStream = FirebaseFirestore.instance
                .collection('podcasts')
                .where('id', whereIn: batch)
                .snapshots();

            final podSubscription = podStream.listen((podSnapshot) {
              for (var doc in podSnapshot.docs) {
                // ignore: unnecessary_cast
                final podcastData = doc.data() as Map<String, dynamic>;
                final match = myPlayInfos.firstWhere(
                    (e) => e['idpod'] == podcastData['id'],
                    orElse: () => {});

                if (match.isNotEmpty) {
                  podcastData['dateCreation'] = match['dateCreation'];
                }

                allPodcasts.add(podcastData);
              }

              // ⬇️ Tri décroissant sur `dateCreation`
              allPodcasts.sort((a, b) {
                Timestamp? dateA = a['dateCreation'] as Timestamp?;
                Timestamp? dateB = b['dateCreation'] as Timestamp?;
                if (dateA == null && dateB == null) return 0;
                if (dateA == null) return 1;
                if (dateB == null) return -1;
                return dateB.compareTo(dateA); // Tri décroissant
              });
              String idpodASupprimer = idpod;

              allPodcasts
                  .removeWhere((podcast) => podcast['id'] == idpodASupprimer);
              setState(() {
                mesPodcasts = allPodcasts;
                nbr = allPodcasts.length;
              });
            });

            batchStreamSubscriptions?.add(podSubscription);
          }
        } else {
          setState(() {
            mesPodcasts = [];
            nbr = 0;
          });
        }
      });
    } catch (e) {
      setState(() {
        mesPodcasts = [];
        nbr = 0;
      });
    }
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

  bool isLoading = true;
  List<Map<String, dynamic>> podvue = [];
  List<Map<String, dynamic>> res = [];
  List<Map<String, dynamic>> topl = [];
  List<Map<String, dynamic>> tops = [];
  List<Map<String, dynamic>> fea = [];
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> channel = [];
  List<Map<String, dynamic>> userPodcasts = [];
  bool isYourPodcast = false;

  List<Map<String, dynamic>> podcastPlaylists = [];
  Future<void> fetchPodcastById(String idpod) async {
    try {
      final queryStream = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .snapshots();

      podcastSubscription = queryStream.listen((snapshot) {
        setState(() {
          podcast = snapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      });
    } catch (e) {}
  }

  Future<void> fetchPodcastvue(String idpod) async {
    try {
      final queryStream = FirebaseFirestore.instance
          .collection('vues')
          .where('idpod', isEqualTo: idpod)
          .snapshots();

      podvueSubscription = queryStream.listen((snapshot) {
        setState(() {
          podvue = snapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      });
    } catch (e) {}
  }

  late TabController _tabController1;
  late TabController _tabController2;
  @override
  void dispose() {
    _tabController1.dispose();
    _tabController2.dispose();

    // Cancel all subscriptions to avoid memory leaks
    podcastSubscription?.cancel();
    channelSubscription?.cancel();
    userPodcastsSubscription?.cancel();
    podcastPlaylistsSubscription?.cancel();
    podvueSubscription?.cancel();
    recentIdSubscription?.cancel();
    relatedPodcastsSubscription?.cancel();
    myPlaylistSubscription?.cancel();
    followSubscription?.cancel();

    // Cancel batch subscriptions
    if (batchStreamSubscriptions != null) {
      for (var subscription in batchStreamSubscriptions!) {
        subscription.cancel();
      }
    }

    super.dispose();
  }

  Future<void> fetchChannelByPodcastId(String idpod) async {
    try {
      final podcastStream = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .snapshots();

      podcastSubscription = podcastStream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String idUser = snapshot.docs.first.data()['idUser'];

          final channelStream = FirebaseFirestore.instance
              .collection('channels')
              .where('userId', isEqualTo: idUser)
              .snapshots();

          channelSubscription = channelStream.listen((channelSnapshot) {
            setState(() {
              channel = channelSnapshot.docs
                  // ignore: unnecessary_cast
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
            });
          });
        }
      });
    } catch (e) {}
  }

  Future<void> fetchPodcastsByUserId(String idpod) async {
    try {
      final podcastStream = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .snapshots();

      podcastSubscription = podcastStream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String idUser = snapshot.docs.first.data()['idUser'];

          final userPodcastsStream = FirebaseFirestore.instance
              .collection('podcasts')
              .orderBy('dateCreation', descending: true)
              .where('idUser', isEqualTo: idUser)
              .snapshots();

          userPodcastsSubscription =
              userPodcastsStream.listen((podcastsSnapshot) {
            final podcasts = podcastsSnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            // Supprimer le podcast avec le même idpod que l'argument
            podcasts.removeWhere((podcast) => podcast['id'] == idpod);

            setState(() {
              userPodcasts = podcasts;
            });
          });
        }
      });
    } catch (e) {}
  }

  Future<void> fetchPlaylistsByPodcastId(String idpod) async {
    try {
      // 1️⃣ Récupérer les `playlistId` associés au `idpod`
      final playinPodStream = FirebaseFirestore.instance
          .collection('playinpod')
          .orderBy('date', descending: true)
          .where('podcastId', isEqualTo: idpod)
          .snapshots();

      podcastPlaylistsSubscription =
          playinPodStream.listen((playinPodSnapshot) {
        // Extraire la liste des playlistIds
        List<String> playlistIds = [];
        for (var doc in playinPodSnapshot.docs) {
          String playlistId = doc.data()['playlistId'];
          if (!playlistIds.contains(playlistId)) {
            playlistIds.add(playlistId);
          }
        }

        if (playlistIds.isNotEmpty) {
          // 2️⃣ Récupérer les playlists correspondant aux playlistIds
          // Traiter par groupes de 10 maximum
          List<Map<String, dynamic>> allPlaylists = [];

          for (int i = 0; i < playlistIds.length; i += 10) {
            int end =
                (i + 10 < playlistIds.length) ? i + 10 : playlistIds.length;
            List<String> batch = playlistIds.sublist(i, end);

            final playlistsStream = FirebaseFirestore.instance
                .collection('playlist')
                .orderBy('createdAt', descending: true)
                .where('id', whereIn: batch)
                .snapshots();

            final playlistSubscription =
                playlistsStream.listen((playlistsSnapshot) {
              for (var doc in playlistsSnapshot.docs) {
                // ignore: unnecessary_cast
                final playlist = doc.data() as Map<String, dynamic>;

                // Vérifier si le playlist existe déjà dans notre liste
                final existingIndex =
                    allPlaylists.indexWhere((p) => p['id'] == playlist['id']);

                if (existingIndex >= 0) {
                  allPlaylists[existingIndex] = playlist;
                } else {
                  allPlaylists.add(playlist);
                }
              }

              setState(() {
                podcastPlaylists = allPlaylists;
              });
            });

            batchStreamSubscriptions?.add(playlistSubscription);
          }
        } else {
          setState(() {
            podcastPlaylists = [];
          });
        }
      });
    } catch (e) {
      setState(() {
        podcastPlaylists = [];
      });
    }
  }

  Future<void> checkIfCurrentUserOwnsPodcast(String idpod) async {
    try {
      final podcastStream = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .snapshots();

      podcastSubscription = podcastStream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String idUser = snapshot.docs.first.data()['idUser'];
          String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

          setState(() {
            isYourPodcast = (currentUserId == idUser);
          });
        }
      });
    } catch (e) {}
  }

  Future<void> fetchtoppodcast(String idpod) async {
    try {
      final podcastStream = FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy("likes", descending: true)
          .limit(10)
          .snapshots();

      final topPodcastSubscription = podcastStream.listen((snapshot) async {
        // Étape 1 : Extraire les données des podcasts
        final allPlaylists = snapshot.docs
            // ignore: unnecessary_cast
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Étape 2 : Récupérer les idUser (auteurs) uniques des podcasts
        final Set<String> userIds = allPlaylists
            .map((p) => p['idUser'] as String)
            // ignore: unnecessary_null_comparison
            .where((id) => id != null)
            .toSet();

        // Étape 3 : Récupérer les channels associés à ces userIds
        Map<String, Map<String, dynamic>> channelsMap = {};

        for (int i = 0; i < userIds.length; i += 10) {
          int end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
          List<String> batchUserIds = userIds.toList().sublist(i, end);

          final channelsStream = FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batchUserIds)
              .snapshots();

          final channelSubscription = channelsStream.listen((channelsSnapshot) {
            for (var doc in channelsSnapshot.docs) {
              final data = doc.data();
              channelsMap[data['userId']] = data;
            }

            // Étape 4 : Associer chaque podcast à son channel
            final enrichedPlaylists = allPlaylists.map((podcast) {
              final String idUser = podcast['idUser'];
              podcast['channel'] = channelsMap[idUser];
              return podcast;
            }).toList();

            String idpodASupprimer = idpod;
            enrichedPlaylists
                .removeWhere((podcast) => podcast['id'] == idpodASupprimer);

            setState(() {
              topl = enrichedPlaylists;
            });
          });

          batchStreamSubscriptions?.add(channelSubscription);
        }
      });

      batchStreamSubscriptions?.add(topPodcastSubscription);
    } catch (e) {
      setState(() {
        topl = [];
      });
    }
  }

  Future<void> fetchtopseen(String idpod) async {
    try {
      final podcastStream = FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy("vue", descending: true)
          .limit(10)
          .snapshots();

      final topSeenSubscription = podcastStream.listen((snapshot) async {
        // Étape 1 : Extraire les données des podcasts
        final allPlaylists = snapshot.docs
            // ignore: unnecessary_cast
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Étape 2 : Récupérer les idUser (auteurs) uniques des podcasts
        final Set<String> userIds = allPlaylists
            .map((p) => p['idUser'] as String)
            // ignore: unnecessary_null_comparison
            .where((id) => id != null)
            .toSet();

        // Étape 3 : Récupérer les channels associés à ces userIds
        Map<String, Map<String, dynamic>> channelsMap = {};

        for (int i = 0; i < userIds.length; i += 10) {
          int end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
          List<String> batchUserIds = userIds.toList().sublist(i, end);

          final channelsStream = FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batchUserIds)
              .snapshots();

          final channelSubscription = channelsStream.listen((channelsSnapshot) {
            for (var doc in channelsSnapshot.docs) {
              final data = doc.data();
              channelsMap[data['userId']] = data;
            }

            // Étape 4 : Associer chaque podcast à son channel
            final enrichedPlaylists = allPlaylists.map((podcast) {
              final String idUser = podcast['idUser'];
              podcast['channel'] = channelsMap[idUser];
              return podcast;
            }).toList();

            String idpodASupprimer = idpod;
            enrichedPlaylists
                .removeWhere((podcast) => podcast['id'] == idpodASupprimer);

            setState(() {
              tops = enrichedPlaylists;
            });
          });

          batchStreamSubscriptions?.add(channelSubscription);
        }
      });

      batchStreamSubscriptions?.add(topSeenSubscription);
    } catch (e) {
      setState(() {});
    }
  }

  Future<String?> getPodcastUserId() async {
    try {
      final podcastStream = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .snapshots();

      return await podcastStream.first.then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.first.data()['idUser'] as String?;
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<void> checkIfUserIsFollowing() async {
    if (user == null) return;

    try {
      // Obtenir l'userId du podcast
      final podcastUserId = await getPodcastUserId();
      if (podcastUserId == null) return;

      // Vérifier si l'utilisateur suit déjà
      final followStream = FirebaseFirestore.instance
          .collection('follow')
          .where('idfollowers', isEqualTo: user)
          .where('idfollowing', isEqualTo: podcastUserId)
          .snapshots();

      followSubscription = followStream.listen((snapshot) {
        setState(() {
          isFollowing = snapshot.docs.isNotEmpty;
        });
      });
    } catch (e) {}
  }

  Future<void> toggleFollow() async {
    if (user == null) return;

    try {
      // Obtenir l'userId du podcast
      final podcastUserId = await getPodcastUserId();
      if (podcastUserId == null) return;

      // Sauvegarder l'état précédent pour pouvoir revenir en arrière en cas d'erreur
      final previousFollowingState = isFollowing;
      if (mounted) {
        // Check if widget is still mounted
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
        final QuerySnapshot channelQuery = await FirebaseFirestore.instance
            .collection('channels')
            .where('userId', isEqualTo: podcastUserId)
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
          // Envoyer une notification push (facultatif - nécessite d'utiliser FCMService du main.dart)
          try {
            print(
                'Attempting to send FCM notification to topic: $podcastUserId');
            await FCMService.sendNotification(
              topic: podcastUserId,
              title: 'New Subscriber',
              body: '$fullName has subscribed to you',
            );
            print('FCM notification sent successfully');
          } catch (e) {
            print('Error sending FCM notification: $e');
          }
        }
      } else {
        // Supprimer de la collection follow
        final followDocs = await FirebaseFirestore.instance
            .collection('follow')
            .where('idfollowers', isEqualTo: user)
            .where('idfollowing', isEqualTo: podcastUserId)
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
              .where('userId', isEqualTo: podcastUserId)
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
      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          isFollowing = !isFollowing; // Revert on error
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);
    _tabController2 = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('idpod')) {
          idpod = arguments['idpod'];
        }

        if (arguments.containsKey('feat')) {
          feat = arguments['feat'];
        }

        if (idpod != null) {
          await fetchPodcastById(idpod!);
          await fetchChannelByPodcastId(idpod!);
          await fetchPodcastsByUserId(idpod!);
          await checkIfCurrentUserOwnsPodcast(idpod!);
          await checkIfUserIsFollowing();
          await fetchPlaylistsByPodcastId(idpod!);
          await fetchPodcastvue(idpod!);
          await fetrecentId(idpod!);
          await fetchRecommendedPodcasts(idpod!);
          await fetchfeuteredppodcast(idpod!);
          await fetchTrendingPodcasts(idpod!);
          await fetchtopseen(idpod!);
          await fetchtoppodcast(idpod!);
          await fetchRelatedPodcastsById(idpod!);
          await nbrpodId(idpod!);
        }
      }
      await Future.delayed(const Duration(seconds: 3));
      setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size w = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Annimationwidjet()
            : Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode ? Colors.black : Colors.white,
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
                          child: Image.network(podcast[0]["urlPhoto"],
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
                      if (isYourPodcast == false) ...[
                        Positioned(
                            top: w.height * 0.01,
                            right: w.width * 0.03,
                            child: Container(
                                width: w.width * 0.09,
                                height: w.width * 0.09,
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius:
                                        BorderRadius.circular(w.width * 0.05)),
                                child: PopupMenuButton(
                                  icon: Image.network(
                                    themeProvider.isDarkMode ? s106 : s49,
                                    width: w.width * 0.06,
                                    height: w.width * 0.06,
                                  ),
                                  color: themeProvider.isDarkMode
                                      ? Colors.black
                                      : Colors
                                          .white, // Définit la couleur de fond du menu popup
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                      height: w.width * 0.12,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: themeProvider.isDarkMode
                                              ? Colors.black
                                              : Colors
                                                  .white, // Couleur de fond du container
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.network(
                                              themeProvider.isDarkMode
                                                  ? s118
                                                  : s50,
                                              width: w.width * 0.05,
                                              height: w.width * 0.05,
                                            ),
                                            SizedBox(width: w.width * 0.02),
                                            Text(
                                              "Report",
                                              style: TextStyle(
                                                fontSize: w.width * 0.04,

                                                // Couleur du texte
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        await checkAndAddReport(idpod!);
                                      },
                                    ),
                                  ],
                                ))),
                      ],
                      if (feat == 2) ...[
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
                                      context, '/podly', (route) => false);
                                },
                                icon: Image.network(
                                  themeProvider.isDarkMode ? s97 : s18,
                                  width: w.width * 0.07,
                                  height: w.width * 0.07,
                                ),
                              ),
                            )),
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 2,
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
                      ],

                      if (feat == 3) ...[
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
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 3,
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
                      ],
                      if (feat == 4) ...[
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
                                      context, '/podly', (route) => false);
                                },
                                icon: Image.network(
                                  themeProvider.isDarkMode ? s97 : s18,
                                  width: w.width * 0.07,
                                  height: w.width * 0.07,
                                ),
                              ),
                            )),
                        Positioned(
                          top: w.height * 0.29,
                          left: w.width * 0.63,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: w.width *
                                    0.15, // Constrain the width of the progress bar
                                child: LinearProgressIndicator(
                                  value: podvue[0]
                                      ['percent'], // 65% de progression
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF754CEF)),
                                  minHeight: 8,
                                ),
                              ),
                              SizedBox(
                                width: w.height * 0.02,
                              ),
                              Text(
                                '${(podvue[0]['percent'] * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: w.width * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 4,
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
                      ],
                      if (feat == 5) ...[
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
                                      context, '/podly', (route) => false);
                                },
                                icon: Image.network(
                                  themeProvider.isDarkMode ? s97 : s18,
                                  width: w.width * 0.07,
                                  height: w.width * 0.07,
                                ),
                              ),
                            )),
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 5,
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
                      ],
                      if (feat == 6) ...[
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
                                      context, '/podly', (route) => false);
                                },
                                icon: Image.network(
                                  themeProvider.isDarkMode ? s97 : s18,
                                  width: w.width * 0.07,
                                  height: w.width * 0.07,
                                ),
                              ),
                            )),
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 6,
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
                      ],
                      if (feat == 7) ...[
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
                                      context, '/podly', (route) => false);
                                },
                                icon: Image.network(
                                  themeProvider.isDarkMode ? s97 : s18,
                                  width: w.width * 0.07,
                                  height: w.width * 0.07,
                                ),
                              ),
                            )),
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 7,
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
                      ],
                      if (feat == 8) ...[
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
                                      context, '/podly', (route) => false);
                                },
                                icon: Image.network(
                                  themeProvider.isDarkMode ? s97 : s18,
                                  width: w.width * 0.07,
                                  height: w.width * 0.07,
                                ),
                              ),
                            )),
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 8,
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
                      ],
                      if (feat == 9) ...[
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
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 9,
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
                      ],
                      if (feat == 12) ...[
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
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 12,
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
                      ],
                      if (feat == 13) ...[
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
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/listen',
                                arguments: {
                                  'idpod': idpod,
                                  'featl': 13,
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
                      ],
                      Positioned(
                        top: w.height * 0.28,
                        child: SizedBox(
                          width: w.width * 0.6,
                          height: w.height * 0.1,
                          child: Column(children: [
                            Text(
                              podcast[0]["name"],
                              style: TextStyle(
                                fontSize: w.width * 0.05,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 3,
                            ),
                            Text(
                              DateFormat('MMM d, yyyy • h:mm a')
                                  .format(podcast[0]["dateCreation"].toDate()),
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
                        top: w.height * 0.38,
                        left: w.width * 0.05,
                        right:
                            w.width * 0.05, // Ajouter une contrainte de droite
                        child: Wrap(
                          spacing: w.width *
                              0.05, // Espacement horizontal entre les éléments
                          runSpacing: w.width *
                              0.02, // Espacement vertical entre les lignes
                          children: [
                            // Premier élément (likes)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                    themeProvider.isDarkMode ? s111 : s37,
                                    width: w.width * 0.05,
                                    height: w.width * 0.05),
                                SizedBox(width: w.width * 0.01),
                                Text(formatLikes(podcast[0]["likes"]),
                                    style: TextStyle(
                                      fontSize: w.width * 0.035,
                                    )),
                              ],
                            ),

                            // Deuxième élément (unlikes)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                    themeProvider.isDarkMode ? s122 : s41,
                                    width: w.width * 0.05,
                                    height: w.width * 0.05),
                                SizedBox(width: w.width * 0.01),
                                Text(formatLikes(podcast[0]["unlikes"]),
                                    style: TextStyle(
                                      fontSize: w.width * 0.035,
                                    )),
                              ],
                            ),

                            // Troisième élément (vue)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                    themeProvider.isDarkMode ? s108 : s14,
                                    width: w.width * 0.05,
                                    height: w.width * 0.05),
                                SizedBox(width: w.width * 0.01),
                                Text(formatLikes(podcast[0]["vue"]),
                                    style: TextStyle(
                                      fontSize: w.width * 0.035,
                                    )),
                              ],
                            ),

                            // Quatrième élément (comments)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                    themeProvider.isDarkMode ? s112 : s38,
                                    width: w.width * 0.05,
                                    height: w.width * 0.05),
                                SizedBox(width: w.width * 0.01),
                                Text(formatLikes(podcast[0]["comments"]),
                                    style: TextStyle(
                                      fontSize: w.width * 0.035,
                                    )),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                    themeProvider.isDarkMode ? s120 : s42,
                                    width: w.width * 0.05,
                                    height: w.width * 0.05),
                                SizedBox(width: w.width * 0.01),
                                Text(formatLikes(podcast[0]["save"]),
                                    style: TextStyle(
                                      fontSize: w.width * 0.035,
                                    )),
                              ],
                            ),
                            // Cinquième élément (shares)
                          ],
                        ),
                      ),
                      Positioned(
                        top: w.height * 0.43,
                        left: w.width * 0.05,
                        right: w.width * 0.05,
                        child: SizedBox(
                          height: w.height *
                              0.4, // Hauteur suffisante pour contenir TabBar et TabBarView
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // TabBar
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
                                  Tab(text: 'Description'),
                                  Tab(text: 'Category'),
                                ],
                              ),
                              // TabBarView
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController1,
                                  children: [
                                    // Premier onglet - Description
                                    Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      width: w.width * 0.9,
                                      child: ReadMoreText(
                                        podcast[0]["description"],
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
                                    // Deuxième onglet - Category
                                    Container(
                                      padding: const EdgeInsets.only(top: 10),
                                      width: w.width * 0.9,
                                      child: ReadMoreText(
                                        podcast[0]["category"],
                                        trimMode: TrimMode.Line,
                                        trimLines: 2,
                                        trimCollapsedText: 'Show more',
                                        trimExpandedText: 'Show less',
                                        moreStyle: TextStyle(
                                            fontSize: w.width * 0.03,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF754CEF)),
                                        lessStyle: TextStyle(
                                            fontSize: w.width * 0.05,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF754CEF)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

// Fix the second ReadMoreText (at w.height * 0.5)

                      Positioned(
                        top: w.height * 0.61,
                        left: w.width * 0.02,
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                          child: GestureDetector(
                            onTap: () {
                              if (userId == channel[0]["userId"]) {
                                Navigator.pushNamed(context, '/your',
                                    arguments: {'your': 3});
                              }
                              if (userId != channel[0]["userId"]) {
                                Navigator.pushNamed(
                                  context,
                                  '/channel',
                                  arguments: {
                                    'id': channel[0]["id"],
                                    'chaine': 4,
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
                              if (isYourPodcast == false) ...[
                                Positioned(
                                  top: w.height * 0.62,
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
                                                  color:
                                                      const Color(0xFF754CEF))
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
                                                        fontSize:
                                                            w.width * 0.03,
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
                                controller: _tabController2,
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
                                  Tab(text: 'More Podcasts'),
                                  Tab(text: 'Playlists'),
                                ],
                                indicatorSize: TabBarIndicatorSize.label,
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController2,
                                children: [
                                  if (feat == 3 ||
                                      feat == 12 ||
                                      feat == 13) ...[
                                    if (userPodcasts.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: userPodcasts.length,
                                          itemBuilder: (context, index) {
                                            final podItem = userPodcasts[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width *
                                                  0.35, // Increased height to accommodate content
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (feat == 3) {
                                                    Navigator
                                                        .pushReplacementNamed(
                                                      context,
                                                      '/podcast',
                                                      arguments: {
                                                        'idpod': podItem["id"],
                                                        'feat':
                                                            3, // remplace "someValue" par ce que tu veux représenter
                                                      },
                                                    );
                                                  }
                                                  if (feat == 12) {
                                                    Navigator
                                                        .pushReplacementNamed(
                                                      context,
                                                      '/podcast',
                                                      arguments: {
                                                        'idpod': podItem["id"],
                                                        'feat':
                                                            12, // remplace "someValue" par ce que tu veux représenter
                                                      },
                                                    );
                                                  }
                                                  if (feat == 13) {
                                                    Navigator
                                                        .pushReplacementNamed(
                                                      context,
                                                      '/podcast',
                                                      arguments: {
                                                        'idpod': podItem["id"],
                                                        'feat':
                                                            13, // remplace "someValue" par ce que tu veux représenter
                                                      },
                                                    );
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (userPodcasts.isEmpty) ...[
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
                                  ],
                                  if (feat == 4) ...[
                                    if (res.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: res.length,
                                          itemBuilder: (context, index) {
                                            final podItem = res[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width *
                                                  0.35, // Increased height to accommodate content
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': podItem["id"],
                                                      'feat':
                                                          4, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (res.isEmpty) ...[
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
                                  ],
                                  if (feat == 2) ...[
                                    if (fea.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: fea.length,
                                          itemBuilder: (context, index) {
                                            final podItem = fea[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width *
                                                  0.35, // Increased height to accommodate content
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': podItem["id"],
                                                      'feat':
                                                          2, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (fea.isEmpty) ...[
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
                                  ],
                                  if (feat == 5) ...[
                                    if (recommendedPodcasts.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: recommendedPodcasts.length,
                                          itemBuilder: (context, index) {
                                            final podItem =
                                                recommendedPodcasts[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width *
                                                  0.35, // Increased height to accommodate content
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': podItem["id"],
                                                      'feat':
                                                          5, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (recommendedPodcasts.isEmpty) ...[
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
                                  ],
                                  if (feat == 6) ...[
                                    if (ress.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: ress.length,
                                          itemBuilder: (context, index) {
                                            final podItem = ress[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width * 0.35,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': podItem["id"],
                                                      'feat':
                                                          6, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }, // Increased height to accommodate content
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (ress.isEmpty) ...[
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
                                  ],
                                  if (feat == 7) ...[
                                    if (topl.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: topl.length,
                                          itemBuilder: (context, index) {
                                            final podItem = topl[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width * 0.35,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': podItem["id"],
                                                      'feat':
                                                          7, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }, // Increased height to accommodate content
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (topl.isEmpty) ...[
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
                                  ],
                                  if (feat == 8) ...[
                                    if (tops.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: tops.length,
                                          itemBuilder: (context, index) {
                                            final podItem = tops[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width * 0.35,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': podItem["id"],
                                                      'feat':
                                                          8, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
                                                }, // Increased height to accommodate content
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (tops.isEmpty) ...[
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
                                  ],
                                  if (feat == 9) ...[
                                    if (relatedPodcasts.isNotEmpty) ...[
                                      SizedBox(
                                        height: w.height * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: relatedPodcasts.length,
                                          itemBuilder: (context, index) {
                                            final podItem =
                                                relatedPodcasts[index];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: w.width * 0.02,
                                                  vertical: w.height * 0.01),
                                              width: w.width * 0.2,
                                              height: w.width *
                                                  0.35, // Increased height to accommodate content
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    '/podcast',
                                                    arguments: {
                                                      'idpod': podItem["id"],
                                                      'feat':
                                                          9, // remplace "someValue" par ce que tu veux représenter
                                                    },
                                                  );
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
                                                            BorderRadius
                                                                .circular(
                                                                    w.width *
                                                                        0.04),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              podItem[
                                                                  "urlPhoto"]),
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
                                                      podItem["name"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            w.width * 0.04,
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
                                    if (relatedPodcasts.isEmpty) ...[
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
                                  ],
                                  if (podcastPlaylists.isNotEmpty) ...[
                                    SizedBox(
                                      height: w.height * 0.23,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: podcastPlaylists.length,
                                        itemBuilder: (context, index) {
                                          final playItem =
                                              podcastPlaylists[index];
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: w.width * 0.02,
                                                vertical: w.height * 0.01),
                                            width: w.width * 0.2,
                                            height: w.width *
                                                0.35, // Increased height to accommodate content
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/play',
                                                    arguments: {
                                                      'idplay': playItem["id"],
                                                      'pp': 4
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: w.height * 0.73,
                        left: w.width * 0.03,
                        child: Image.network(
                          themeProvider.isDarkMode ? s123 : s52,
                          width: w.width * 0.06,
                          height: w.width * 0.06,
                        ),
                      )
                    ],
                  ),
                );
              }),
      ),
    );
  }
}
