import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/ZoomPhotoPage.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:pfeapp/theme_provider.dart';
import 'dart:async'; // Import for StreamSubscription

class Podlypage extends StatefulWidget {
  const Podlypage({super.key});

  @override
  State<Podlypage> createState() => _PodlypageState();
}

class _PodlypageState extends State<Podlypage> {
  // List to manage all stream subscriptions
  final List<StreamSubscription> _subscriptions = [];
  final List<Map<String, String>> cat = [
    {"tite": "Education", "img": s65},
    {"tite": "History", "img": s66},
    {"tite": "Comedie", "img": s67},
    {"tite": "Tv&Films", "img": s68},
    {"tite": "Music", "img": s69},
    {"tite": "Books", "img": s70},
    {"tite": "Culture", "img": s71},
    {"tite": "Self", "img": s72},
    {"tite": "Marketing", "img": s73},
    {"tite": "Sport", "img": s74},
    {"tite": "Gaming", "img": s75},
    {"tite": "Food", "img": s76},
    {"tite": "Travel", "img": s77},
    {"tite": "Religion", "img": s78},
    {"tite": "Art", "img": s79},
    {"tite": "Sciences", "img": s80},
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => isLoading = true);
      }
      await fetchuser();
      await fetchfollowId();
      await nbrpodId();
      await fetchmesPlaylistsId();
      await fetchtopseen();
      await fetchtoppodcast();
      await fetchtopChannel();
      await fetrecentId();
      await fetchfeuteredppodcast();
      await fetchRecommendedPodcasts();
      await fetchTrendingPodcasts();
      await noficat();
      await report();
      await fetchchain();
      // Ajouter un listener pour détecter les changements de scroll
      _pageController.addListener(() {
        int next = _pageController.page!.round();
        if (_currentIndex != next) {
          if (mounted) {
            setState(() {
              _currentIndex = next;
            });
          }
        }
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  Future<void> logout() async {
    // ignore: await_only_futures
    final currentUser = await FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Désabonner du topic avant la déconnexion
      await FirebaseMessaging.instance.unsubscribeFromTopic(currentUser.uid);
    }
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email'); // Supprime l'utilisateur sauvegardé
  }

  late int your = 1;
  late int pp = 1;
  late int chaine = 1;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  List<Map<String, dynamic>> mesplaylist = [];
  List<Map<String, dynamic>> nof = [];
  List<Map<String, dynamic>> repor = [];
  List<Map<String, dynamic>> channel111 = [];

  Future<void> fetchmesPlaylistsId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('mesplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots()
          .listen((playinPodSnapshot) async {
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
          List<Map<String, dynamic>> allPlaylists = [];

          List<String> playlistIds =
              mesPlayInfos.map((e) => e['idplay'] as String).toList();

          for (int i = 0; i < playlistIds.length; i += 10) {
            int end =
                (i + 10 < playlistIds.length) ? i + 10 : playlistIds.length;
            List<String> batch = playlistIds.sublist(i, end);

            final playlistsSnapshot = await FirebaseFirestore.instance
                .collection('playlist')
                .where('id', whereIn: batch)
                .get();

            for (var doc in playlistsSnapshot.docs) {
              // ignore: unnecessary_cast
              final playlistData = doc.data() as Map<String, dynamic>;
              final matchingMes = mesPlayInfos.firstWhere(
                  (element) => element['idplay'] == playlistData['id'],
                  orElse: () => {});

              if (matchingMes.isNotEmpty) {
                playlistData['dateCreation'] = matchingMes['dateCreation'];
              }

              allPlaylists.add(playlistData);
            }
          }

          // ⬇️ Tri du plus récent au plus ancien
          allPlaylists.sort((a, b) {
            Timestamp? dateA = a['dateCreation'];
            Timestamp? dateB = b['dateCreation'];

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA); // ⬅️ tri décroissant ici
          });

          if (mounted) {
            setState(() {
              mesplaylist = allPlaylists;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              mesplaylist = [];
            });
          }
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          mesplaylist = [];
        });
      }
    }
  }

  List<Map<String, dynamic>> recommendedPodcasts = [];
  List<Map<String, dynamic>> viewedPodcasts = [];

  Future<void> fetchRecommendedPodcasts() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // 1. Récupérer les documents 'vues' de l'utilisateur
      final streamSubscription = FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .listen((viewedPodsSnapshot) async {
        // 2. Extraire les IDs des podcasts vus
        List<String> viewedPodcastIds = viewedPodsSnapshot.docs
            .map((doc) => doc.data()['idpod'] as String)
            .toList();

        // 3. Récupérer les catégories à partir des podcasts vus
        Set<String> categories = {};

        for (int i = 0; i < viewedPodcastIds.length; i += 10) {
          int end = (i + 10 < viewedPodcastIds.length)
              ? i + 10
              : viewedPodcastIds.length;
          List<String> batchIds = viewedPodcastIds.sublist(i, end);

          final snapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .where('id', whereIn: batchIds)
              .get();

          for (var doc in snapshot.docs) {
            final category = doc.data()['category'];
            if (category != null) {
              categories.add(category);
            }
          }
        }

        if (categories.isEmpty) {
          if (mounted) {
            setState(() {
              viewedPodcasts = [];
              recommendedPodcasts = [];
            });
          }

          return;
        }

        // 4. Récupérer les détails des podcasts vus
        List<Map<String, dynamic>> tempViewedPodcasts = [];

        for (int i = 0; i < viewedPodcastIds.length; i += 10) {
          int end = (i + 10 < viewedPodcastIds.length)
              ? i + 10
              : viewedPodcastIds.length;
          List<String> batchIds = viewedPodcastIds.sublist(i, end);

          final snapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .where('id', whereIn: batchIds)
              .get();

          for (var doc in snapshot.docs) {
            tempViewedPodcasts.add(doc.data());
          }
        }

        // 5. Récupérer les podcasts recommandés
        List<Map<String, dynamic>> tempRecommendedPodcasts = [];

        for (String category in categories) {
          final recommendedSnapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .where('category', isEqualTo: category)
              .orderBy('dateCreation', descending: true)
              .limit(10)
              .get();

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
          int end =
              (i + 10 < channelIdsList.length) ? i + 10 : channelIdsList.length;
          List<String> batchIds = channelIdsList.sublist(i, end);

          final channelsSnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batchIds)
              .get();

          for (var doc in channelsSnapshot.docs) {
            final data = doc.data();
            channelsMap[data['userId']] = data;
          }
        }

        // 7. Associer les channels aux podcasts
        for (var podcast in tempViewedPodcasts) {
          podcast['channel'] = channelsMap[podcast['idUser']];
        }

        for (var podcast in tempRecommendedPodcasts) {
          podcast['channel'] = channelsMap[podcast['idUser']];
        }

        // 8. Mettre à jour l'état
        if (mounted) {
          setState(() {
            viewedPodcasts = tempViewedPodcasts;
            recommendedPodcasts = tempRecommendedPodcasts;
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          viewedPodcasts = [];
          recommendedPodcasts = [];
        });
      }
    }
  }

  List<Map<String, dynamic>> ress = [];

  Future<void> fetchTrendingPodcasts() async {
    final DateTime sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7));
    final Timestamp timestampSevenDaysAgo = Timestamp.fromDate(sevenDaysAgo);

    try {
      // 1️⃣ Récupérer les vues des 7 derniers jours
      final streamSubscription = FirebaseFirestore.instance
          .collection('vues')
          .where('timevue', isGreaterThan: timestampSevenDaysAgo)
          .snapshots()
          .listen((recentViewsSnapshot) async {
        // 2️⃣ Récupérer tous les idpod uniques
        Set<String> recentIdPods = recentViewsSnapshot.docs
            .map((doc) => doc.data()['idpod'] as String)
            .toSet();

        if (recentIdPods.isEmpty) {
          if (mounted) {
            setState(() => ress = []);
          }
          return;
        }

        // 3️⃣ Récupérer les documents podcasts correspondants
        List<Map<String, dynamic>> matchingPodcasts = [];

        List<String> idList = recentIdPods.toList();
        for (int i = 0; i < idList.length; i += 10) {
          int end = (i + 10 < idList.length) ? i + 10 : idList.length;
          List<String> batch = idList.sublist(i, end);

          final podcastSnapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .where('id', whereIn: batch)
              .get();

          for (var doc in podcastSnapshot.docs) {
            matchingPodcasts.add(doc.data());
          }
        }

        // 4️⃣ Trier localement les podcasts par le champ `vue` (desc)
        matchingPodcasts
            .sort((a, b) => (b['vue'] ?? 0).compareTo(a['vue'] ?? 0));

        // 5️⃣ Prendre les 10 premiers
        List<Map<String, dynamic>> top10 = matchingPodcasts.take(10).toList();

        // 6️⃣ Ajouter les infos des chaînes
        Set<String> userIds = top10.map((p) => p['idUser'] as String).toSet();
        Map<String, Map<String, dynamic>> channelsMap = {};

        for (int i = 0; i < userIds.length; i += 10) {
          int end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
          List<String> batch = userIds.toList().sublist(i, end);

          final channelsSnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batch)
              .get();

          for (var doc in channelsSnapshot.docs) {
            channelsMap[doc.data()['userId']] = doc.data();
          }
        }

        // 7️⃣ Associer les chaînes
        for (var podcast in top10) {
          podcast['channel'] = channelsMap[podcast['idUser']];
        }

        // 🔁 Mettre à jour l'état
        if (mounted) {
          setState(() {
            ress = top10;
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() => ress = []);
      }
    }
  }

  List<Map<String, dynamic>> user = [];
  List<Map<String, dynamic>> res = [];
  List<Map<String, dynamic>> topcha = [];
  List<Map<String, dynamic>> topl = [];
  List<Map<String, dynamic>> tops = [];
  Future<void> fetrecentId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // 🔁 Étape 1 : Récupérer les vues triées par timevue ASC
      final streamSubscription = FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timevue', descending: false)
          .snapshots()
          .listen((playinPodSnapshot) async {
        // 🔁 Étape 2 : Liste ordonnée d'idpod avec timevue + percent
        List<Map<String, dynamic>> orderedIdpods = [];
        for (var doc in playinPodSnapshot.docs) {
          final data = doc.data();
          String idpod = data['idpod'];
         Timestamp timevue = data['timevue'] ?? Timestamp.fromMillisecondsSinceEpoch(0);
          double percent = (data['percent'] ?? 0).toDouble();

          // Évite les doublons (garde le premier car trié)
          if (!orderedIdpods.any((e) => e['idpod'] == idpod)) {
            orderedIdpods
                .add({'idpod': idpod, 'timevue': timevue, 'percent': percent});
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

            final playlistsSnapshot = await FirebaseFirestore.instance
                .collection('podcasts')
                .where('id', whereIn: batch)
                .get();

            for (var doc in playlistsSnapshot.docs) {
              // ignore: unnecessary_cast
              final data = doc.data() as Map<String, dynamic>;
              allPlaylists.add(data);
            }
          }

          // Associer timevue et percent à chaque podcast
          allPlaylists = allPlaylists.map((podcast) {
            final match =
                orderedIdpods.firstWhere((e) => e['idpod'] == podcast['id']);
            podcast['timevue'] = match['timevue'];
            podcast['percent'] = match['percent']; // ⬅️ ICI on ajoute percent
            return podcast;
          }).toList();

          // Trier par timevue DESC
          allPlaylists.sort((a, b) {
            final aTime = a['timevue'] as Timestamp;
            final bTime = b['timevue'] as Timestamp;
            return bTime.compareTo(aTime);
          });

          // 🔁 Étape 3 : Ajouter les infos du channel
          final Set<String> userIds =
              allPlaylists.map((p) => p['idUser'] as String).toSet();
          Map<String, Map<String, dynamic>> channelsMap = {};

          for (int i = 0; i < userIds.length; i += 10) {
            int end = (i + 10 < userIds.length) ? i + 10 : userIds.length;
            List<String> batchUserIds = userIds.toList().sublist(i, end);

            final channelSnap = await FirebaseFirestore.instance
                .collection('channels')
                .where('userId', whereIn: batchUserIds)
                .get();

            for (var doc in channelSnap.docs) {
              final data = doc.data();
              channelsMap[data['userId']] = data;
            }
          }

          // Ajouter channel à chaque podcast
          final enrichedPlaylists = allPlaylists.map((podcast) {
            final String idUser = podcast['idUser'];
            final channel = channelsMap[idUser];
            podcast['channel'] = channel;
            return podcast;
          }).toList();

          if (mounted) {
            setState(() {
              res = enrichedPlaylists;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              res = [];
            });
          }
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          res = [];
        });
      }
    }
  }

  Future<void> fetchtopChannel() async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('channels')
          .orderBy("followers", descending: true)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        if (mounted) {
          setState(() {
            topcha = querySnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> fetchfeuteredppodcast() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .where('dateCreation',
              isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('dateCreation', descending: true)
          .snapshots()
          .listen((recentPodcasts) {
        if (mounted) {
          setState(() {
            fea = recentPodcasts.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> fetchtoppodcast() async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy("likes", descending: true)
          .limit(10)
          .snapshots()
          .listen((querySnapshot) async {
        // Étape 1 : Extraire les données des podcasts
        final allPlaylists = querySnapshot.docs
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

          final channelsSnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batchUserIds)
              .get();

          for (var doc in channelsSnapshot.docs) {
            final data = doc.data();
            channelsMap[data['userId']] = data;
          }
        }

        // Étape 4 : Associer chaque podcast à son channel
        final enrichedPlaylists = allPlaylists.map((podcast) {
          final String idUser = podcast['idUser'];
          podcast['channel'] = channelsMap[idUser];
          return podcast;
        }).toList();

        // (Optionnel) Mettre à jour l'état si tu es dans un widget Stateful
        if (mounted) {
          setState(() {
            topl = enrichedPlaylists;
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          topl = [];
        });
      }
    }
  }

  Future<void> fetchtopseen() async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy("vue", descending: true)
          .limit(10)
          .snapshots()
          .listen((querySnapshot) async {
        // Étape 1 : Extraire les données des podcasts
        final allPlaylists = querySnapshot.docs
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

          final channelsSnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batchUserIds)
              .get();

          for (var doc in channelsSnapshot.docs) {
            final data = doc.data();
            channelsMap[data['userId']] = data;
          }
        }

        // Étape 4 : Associer chaque podcast à son channel
        final enrichedPlaylists = allPlaylists.map((podcast) {
          final String idUser = podcast['idUser'];
          podcast['channel'] = channelsMap[idUser];
          return podcast;
        }).toList();

        // (Optionnel) Mettre à jour l'état si tu es dans un widget Stateful
        if (mounted) {
          setState(() {
            tops = enrichedPlaylists;
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
    }
  }

  late int nbr = 0;
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

  List<Map<String, dynamic>> followcha = [];
  List<Map<String, dynamic>> fea = [];
  Future<void> fetchfollowId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // 1️⃣ Récupérer les follow triés par dateCreation DESC
      final streamSubscription = FirebaseFirestore.instance
          .collection('follow')
          .where('idfollowers', isEqualTo: currentUserId)
          .orderBy('dateCreation', descending: true)
          .snapshots()
          .listen((followSnapshot) async {
        // 2️⃣ Construire une liste ordonnée de followings avec dateCreation
        List<Map<String, dynamic>> followList = [];
        for (var doc in followSnapshot.docs) {
          final data = doc.data();
          String idFollowing = data['idfollowing'];
          Timestamp dateCreation = data['dateCreation'];

          if (!followList.any((f) => f['idfollowing'] == idFollowing)) {
            followList.add(
                {'idfollowing': idFollowing, 'dateCreation': dateCreation});
          }
        }

        if (followList.isNotEmpty) {
          List<Map<String, dynamic>> allChannels = [];

          // 3️⃣ Récupérer les channels associés
          for (int i = 0; i < followList.length; i += 10) {
            int end = (i + 10 < followList.length) ? i + 10 : followList.length;
            List<String> batch = followList
                .sublist(i, end)
                .map((e) => e['idfollowing'] as String)
                .toList();

            final channelsSnapshot = await FirebaseFirestore.instance
                .collection('channels')
                .where('userId', whereIn: batch)
                .get();

            for (var doc in channelsSnapshot.docs) {
              final channelData = doc.data();
              allChannels.add(channelData);
            }
          }

          // 4️⃣ Associer chaque channel à sa dateCreation (de follow)
          final enrichedChannels = allChannels.map((channel) {
            final match = followList
                .firstWhere((f) => f['idfollowing'] == channel['userId']);
            channel['dateCreationFollow'] =
                match['dateCreation']; // important !
            return channel;
          }).toList();

          // 5️⃣ Trier localement par dateCreationFollow DESC
          enrichedChannels.sort((a, b) {
            final aTime = a['dateCreationFollow'] as Timestamp;
            final bTime = b['dateCreationFollow'] as Timestamp;
            return bTime.compareTo(aTime);
          });

          if (mounted) {
            setState(() {
              followcha = enrichedChannels;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              followcha = [];
            });
          }
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          followcha = [];
        });
      }
    }
  }

  Future<void> fetchuser() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final streamSubscription = FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        if (mounted) {
          setState(() {
            user = querySnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          user = [];
        });
      }
    }
  }

  Future<void> fetchchain() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final streamSubscription = FirebaseFirestore.instance
          .collection('channels')
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        if (mounted) {
          setState(() {
            channel111 = querySnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          channel111 = [];
        });
      }
    }
  }

  Future<void> noficat() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final streamSubscription = FirebaseFirestore.instance
          .collection('nofi')
          .where('user2', isEqualTo: currentUserId)
          .where('isviewed', isEqualTo: false)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        if (mounted) {
          setState(() {
            nof = querySnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          nof = [];
        });
      }
    }
  }

  Future<void> report() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final streamSubscription = FirebaseFirestore.instance
          .collection('reports')
          .where('userId', isEqualTo: currentUserId)
          .where('isviewed', isEqualTo: false)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        if (mounted) {
          setState(() {
            repor = querySnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          repor = [];
        });
      }
    }
  }

  Future<void> nbrpodId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('myplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots()
          .listen((playinPodSnapshot) {
        // Extraire la liste des playlistIds
        Set<String> uniquePodIds = playinPodSnapshot.docs
            .map((doc) => doc.data()['idpod'] as String)
            .toSet();

        if (mounted) {
          setState(() {
            nbr = uniquePodIds.length;
          });
        }
      });

      _subscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          nbr = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    // Annuler tous les abonnements aux streams
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _pageController.dispose();
    super.dispose();
  }

  bool val = false;
  bool val1 = true;
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _selectedIndex = 0;
  late int r = 1;
  late int q = 1;
  late int feat = 1;
  bool isLoading = true;
  void _onItemTapped(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
    if (index == 2) {
      _showBottomSheet();
    }
  }

  late int y = 1;
  late int o = 1;
  late int ch = 1;
  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Utilise la couleur de fond selon le thème
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              decoration: BoxDecoration(
                color:
                    themeProvider.isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Image.network(
                      themeProvider.isDarkMode ? s140 : s29,
                      width: 25,
                      height: 25,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    title: Text(
                      "Create Channel",
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      if (channel111.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You Have Alredy')),
                        );
                      }
                      if (channel111.isEmpty) {
                        Navigator.pushNamed(context, '/ch', arguments: 2);
                      }
                    },
                  ),
                  ListTile(
                    leading: Image.network(
                      themeProvider.isDarkMode ? s110 : s30,
                      width: 25,
                      height: 25,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    title: Text(
                      "Upload Podcast",
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      if (channel111.isNotEmpty) {
                        Navigator.pushNamed(context, '/po', arguments: 2);
                      }
                      if (channel111.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You Must Create Channel')));
                      }
                    },
                  ),
                  ListTile(
                    leading: Image.network(
                      themeProvider.isDarkMode ? s115 : s33,
                      width: 25,
                      height: 25,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                    title: Text(
                      "Create Playlist",
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    onTap: () {
                      if (channel111.isNotEmpty) {
                        Navigator.pushNamed(context, '/pl', arguments: 2);
                      }
                      if (channel111.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('You Must Create Channel')));
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('selectedIndex')) {
      if (mounted) {
        setState(() {
          _selectedIndex = args['selectedIndex'];
        });
      }
    }
  }

  Widget _buildBody(BuildContext context) {
    final Size x = MediaQuery.of(context).size;

    switch (_selectedIndex) {
      case 0:
        r = 1;
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return Column(
            children: [
              SizedBox(
                height: x.height * 0.15,
                child: Stack(
                  children: [
                    if (nof.isNotEmpty || repor.isNotEmpty) ...[
                      Positioned(
                          top: x.height * 0.033,
                          left: x.width * 0.887,
                          child: Container(
                              height: x.width * 0.03,
                              width: x.width * 0.03,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                              ))),
                    ],
                    Positioned(
                      top: x.height * 0.005,
                      left: x.width * 0.005,
                      child: Row(
                        children: [
                          SizedBox(
                            width: x.width * 0.15,
                            height: x.width * 0.15,
                            child: Image.network(
                              themeProvider.isDarkMode ? s132 : s61,
                              width: x.width * 0.15,
                              height: x.width * 0.15,
                            ),
                          ),
                          Text(
                            "Podly",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.05),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: x.height * 0.027,
                      right: x.width * 0.07,
                      child: Row(
                        children: [
                          SizedBox(
                            width: x.width * 0.09, // Added width
                            height: x.width * 0.09, // Added height
                            child: IconButton(
                              onPressed: () {
                                showSearch(
                                    context: context, delegate: Search());
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s133 : s60,
                                width: x.width * 0.09,
                                height: x.width * 0.09,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: x.width * 0.01, // Added width
                            height: x.width * 0.01, // Added height
                          ),
                          SizedBox(
                            width: x.width * 0.09, // Added width
                            height: x.width * 0.09, // Added height
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/nofi');
                              },
                              icon: Image.network(
                                themeProvider.isDarkMode ? s134 : s59,
                                width: x.width * 0.09,
                                height: x.width * 0.09,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: x.height * 0.08,
                        left: x.width * 0.08,
                        child: Wrap(
                          children: [
                            Row(children: [
                              Text(
                                "Hello",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: x.width * 0.065),
                              ),
                              const Text(" "),
                              Row(
                                children: [
                                  Text(
                                    user[0]["firstName"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: x.width * 0.065),
                                  ),
                                  const Text(" "),
                                  Text(
                                    user[0]["lastName"],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: x.width * 0.065),
                                  ),
                                ],
                              )
                            ])
                          ],
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: x.height * 0.03,
                child: Stack(
                  children: [
                    Positioned(
                        left: x.width * 0.05,
                        child: Text(
                          "Featured",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: x.height * 0.22,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: fea.length,
                        itemBuilder: (context, index) {
                          final feaItem = fea[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: x.width * 0.05),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.05),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/podcast',
                                  arguments: {
                                    'idpod': feaItem["id"],
                                    'feat':
                                        2, // remplace "someValue" par ce que tu veux représenter
                                  },
                                );
                              },
                              child: Image.network(
                                feaItem["urlPhoto"],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Indicateurs de points
                    SizedBox(height: x.width * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        fea.length,
                        (index) => Container(
                          width: x.width * 0.015,
                          height: x.width * 0.015,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == index
                                ? const Color(0xFF754CEF)
                                : const Color(0xFFD9D9D9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                    height: x.height * 0.05,
                    child: Stack(children: [
                      Positioned(
                          left: x.width * 0.08,
                          child: Text(
                            "Recently Played",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.05),
                          )),
                      Positioned(
                          top: x.height * 0.01,
                          left: x.width * 0.03,
                          child: SizedBox(
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                            child: Image.network(s55),
                          )),
                      if (res.isNotEmpty) ...[
                        Positioned(
                            top: x.height * 0.007,
                            right: x.width * 0.12,
                            child: Text(
                              "See All",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: x.width * 0.035,
                                  color: const Color(0xFF754CEF)),
                            )),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 3
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ])),
                if (res.isNotEmpty) ...[
                  SizedBox(
                    height: x.height * 0.23,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: res.length,
                      itemBuilder: (context, index) {
                        final podItem = res[index];
                        final channel = podItem['channel'];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: x.width * 0.02),
                          width: x.width * 0.2,
                          height: x.width *
                              0.35, // Increased height to accommodate content
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
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
                              mainAxisSize: MainAxisSize.min, // Add this
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: x.width * 0.2,
                                  width: x.width * 0.2,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(x.width * 0.04),
                                    image: DecorationImage(
                                      image: NetworkImage(podItem["urlPhoto"]),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {},
                                    ),
                                  ),
                                ),
                                SizedBox(height: x.width * 0.01),
                                Flexible(
                                    child: Text(
                                  podItem["name"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: x.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                SizedBox(
                                  height: x.width * 0.01,
                                ),
                                Flexible(
                                    child: Text(
                                  channel["name"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: x.width * 0.035,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                SizedBox(
                                  height: x.height * 0.01,
                                ),
                                SizedBox(
                                  width: x.width *
                                      0.35, // Constrain the width of the progress bar
                                  child: LinearProgressIndicator(
                                    value: podItem[
                                        "percent"], // 65% de progression
                                    backgroundColor: Colors.grey[300],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF754CEF)),
                                    minHeight: 8,
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
                if (res.isEmpty) ...[
                  Column(children: [
                    SizedBox(
                      width: x.width * 0.7,
                      height: x.height * 0.15,
                      child:
                          Image.network(themeProvider.isDarkMode ? s109 : s28),
                    ),
                    Text("Not Yet",
                        style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold)),
                  ])
                ],
                SizedBox(
                    height: x.height * 0.05,
                    child: Stack(children: [
                      Positioned(
                          left: x.width * 0.08,
                          child: Text(
                            "Recommended For you",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.05),
                          )),
                      Positioned(
                          top: x.height * 0.01,
                          left: x.width * 0.03,
                          child: SizedBox(
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                            child: Image.network(s62),
                          )),
                      if (recommendedPodcasts.isNotEmpty) ...[
                        Positioned(
                            top: x.height * 0.007,
                            right: x.width * 0.12,
                            child: Text(
                              "See All",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: x.width * 0.035,
                                  color: const Color(0xFF754CEF)),
                            )),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 4
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ])),
                if (recommendedPodcasts.isNotEmpty) ...[
                  SizedBox(
                    height: x.height * 0.23,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedPodcasts.length,
                      itemBuilder: (context, index) {
                        final podItem = recommendedPodcasts[index];
                        final reco = podItem["channel"];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: x.width * 0.02),
                          width: x.width * 0.2,
                          height: x.width *
                              0.35, // Increased height to accommodate content
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
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
                              mainAxisSize: MainAxisSize.min, // Add this
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: x.width * 0.2,
                                  width: x.width * 0.2,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(x.width * 0.04),
                                    image: DecorationImage(
                                      image: NetworkImage(podItem["urlPhoto"]),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {},
                                    ),
                                  ),
                                ),
                                SizedBox(height: x.width * 0.01),
                                Flexible(
                                    child: Text(
                                  podItem["name"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: x.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                SizedBox(
                                  height: x.width * 0.01,
                                ),
                                Flexible(
                                    child: Text(
                                  reco["name"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: x.width * 0.035,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                      width: x.width * 0.7,
                      height: x.height * 0.15,
                      child:
                          Image.network(themeProvider.isDarkMode ? s109 : s28),
                    ),
                    Text("Not Yet",
                        style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold)),
                  ])
                ],
                SizedBox(
                    height: x.height * 0.05,
                    child: Stack(children: [
                      Positioned(
                          left: x.width * 0.08,
                          child: Text(
                            "Top Creator",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.05),
                          )),
                      Positioned(
                          top: x.height * 0.01,
                          left: x.width * 0.03,
                          child: SizedBox(
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                            child: Image.network(s56),
                          )),
                      if (topcha.isNotEmpty) ...[
                        Positioned(
                            top: x.height * 0.007,
                            right: x.width * 0.12,
                            child: Text(
                              "See All",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: x.width * 0.035,
                                  color: const Color(0xFF754CEF)),
                            )),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 5
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ])),
                if (topcha.isNotEmpty) ...[
                  SizedBox(
                    height: x.height * 0.23,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topcha.length,
                      itemBuilder: (context, index) {
                        final craItem = topcha[index];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: x.width * 0.02),
                          width: x.width * 0.2,
                          child: GestureDetector(
                            onTap: () {
                              if (userId == craItem["userId"]) {
                                Navigator.pushNamed(context, '/your',
                                    arguments: {'your': 2});
                              }
                              if (userId != craItem["userId"]) {
                                Navigator.pushNamed(
                                  context,
                                  '/channel',
                                  arguments: {
                                    'id': craItem["id"],
                                    'chaine': 2,
                                  },
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: x.width * 0.2,
                                  width: x.width * 0.2,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(x.width * 0.1),
                                    image: DecorationImage(
                                      image: NetworkImage(craItem["photoUrl"]),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {},
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: x.width * 0.01,
                                ),
                                Text(
                                  craItem["name"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: x.width * 0.03,
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
                if (topcha.isEmpty) ...[
                  Column(children: [
                    SizedBox(
                      width: x.width * 0.7,
                      height: x.height * 0.15,
                      child:
                          Image.network(themeProvider.isDarkMode ? s109 : s28),
                    ),
                    Text("Not Yet",
                        style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold)),
                  ])
                ],
                SizedBox(
                    height: x.height * 0.05,
                    child: Stack(children: [
                      Positioned(
                          left: x.width * 0.08,
                          child: Text(
                            "Trending Podcast",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.05),
                          )),
                      Positioned(
                          top: x.height * 0.01,
                          left: x.width * 0.03,
                          child: SizedBox(
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                            child: Image.network(s63),
                          )),
                      if (ress.isNotEmpty) ...[
                        Positioned(
                            top: x.height * 0.007,
                            right: x.width * 0.12,
                            child: Text(
                              "See All",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: x.width * 0.035,
                                  color: const Color(0xFF754CEF)),
                            )),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 6
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ])),
                if (ress.isNotEmpty) ...[
                  SizedBox(
                    height: x.height * 0.23,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ress.length,
                      itemBuilder: (context, index) {
                        final podItem = ress[index];
                        final chann = podItem["channel"];
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: x.width * 0.02),
                          width: x.width * 0.2,
                          height: x.width *
                              0.35, // Increased height to accommodate content
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/podcast',
                                arguments: {
                                  'idpod': podItem["id"],
                                  'feat':
                                      6, // remplace "someValue" par ce que tu veux représenter
                                },
                              );
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // Add this
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: x.width * 0.2,
                                  width: x.width * 0.2,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(x.width * 0.04),
                                    image: DecorationImage(
                                      image: NetworkImage(podItem["urlPhoto"]),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) {},
                                    ),
                                  ),
                                ),
                                SizedBox(height: x.width * 0.01),
                                Flexible(
                                    child: Text(
                                  podItem["name"],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: x.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                SizedBox(
                                  height: x.width * 0.01,
                                ),
                                Flexible(
                                    child: Text(
                                  chann["name"],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: x.width * 0.035,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                      width: x.width * 0.7,
                      height: x.height * 0.15,
                      child:
                          Image.network(themeProvider.isDarkMode ? s109 : s28),
                    ),
                    Text("Not Yet",
                        style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold)),
                  ])
                ],
                SizedBox(
                    height: x.height * 0.05,
                    child: Stack(children: [
                      Positioned(
                          left: x.width * 0.08,
                          child: Text(
                            "Top Liked",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.05),
                          )),
                      Positioned(
                          top: x.height * 0.01,
                          left: x.width * 0.03,
                          child: SizedBox(
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                            child: Image.network(s57),
                          )),
                      if (topl.isNotEmpty) ...[
                        Positioned(
                            top: x.height * 0.007,
                            right: x.width * 0.12,
                            child: Text(
                              "See All",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: x.width * 0.035,
                                  color: const Color(0xFF754CEF)),
                            )),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 7
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ])),
                if (topl.isNotEmpty) ...[
                  SizedBox(
                    height: x.height * 0.23,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topl.length,
                      itemBuilder: (context, index) {
                        final podItem = topl[index];
                        final re = podItem["channel"];
                        return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: x.width * 0.02),
                            width: x.width * 0.2,
                            height: x.width *
                                0.35, // Increased height to accommodate content
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/podcast',
                                  arguments: {
                                    'idpod': podItem["id"],
                                    'feat':
                                        7, // remplace "someValue" par ce que tu veux représenter
                                  },
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Add this
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: x.width * 0.2,
                                    width: x.width * 0.2,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(x.width * 0.04),
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(podItem["urlPhoto"]),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {},
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: x.width * 0.01),
                                  Flexible(
                                      child: Text(
                                    podItem["name"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: x.width * 0.04,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  SizedBox(
                                    height: x.width * 0.01,
                                  ),
                                  Flexible(
                                      child: Text(
                                    re["name"],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: x.width * 0.035,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ],
                if (topl.isEmpty) ...[
                  Column(children: [
                    SizedBox(
                      width: x.width * 0.7,
                      height: x.height * 0.15,
                      child:
                          Image.network(themeProvider.isDarkMode ? s109 : s28),
                    ),
                    Text("Not Yet",
                        style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold)),
                  ])
                ],
                SizedBox(
                    height: x.height * 0.05,
                    child: Stack(children: [
                      Positioned(
                          left: x.width * 0.08,
                          child: Text(
                            "Top Seen ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.05),
                          )),
                      Positioned(
                          top: x.height * 0.01,
                          left: x.width * 0.03,
                          child: SizedBox(
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                            child: Image.network(s58),
                          )),
                      if (tops.isNotEmpty) ...[
                        Positioned(
                            top: x.height * 0.007,
                            right: x.width * 0.12,
                            child: Text(
                              "See All",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: x.width * 0.035,
                                  color: const Color(0xFF754CEF)),
                            )),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 8
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ])),
                if (tops.isNotEmpty) ...[
                  SizedBox(
                    height: x.height * 0.23,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tops.length,
                      itemBuilder: (context, index) {
                        final podItem = tops[index];
                        return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: x.width * 0.02),
                            width: x.width * 0.2,
                            height: x.width *
                                0.35, // Increased height to accommodate content
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/podcast',
                                  arguments: {
                                    'idpod': podItem["id"],
                                    'feat':
                                        8, // remplace "someValue" par ce que tu veux représenter
                                  },
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Add this
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: x.width * 0.2,
                                    width: x.width * 0.2,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(x.width * 0.04),
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(podItem["urlPhoto"]),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {},
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: x.width * 0.01),
                                  Flexible(
                                      child: Text(
                                    podItem["name"],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: x.width * 0.04,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  SizedBox(
                                    height: x.width * 0.01,
                                  ),
                                  Flexible(
                                      child: Text(
                                    podItem["channel"]["name"] ?? "Unknown",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: x.width * 0.035,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ],
                if (tops.isEmpty) ...[
                  Column(children: [
                    SizedBox(
                      width: x.width * 0.7,
                      height: x.height * 0.15,
                      child:
                          Image.network(themeProvider.isDarkMode ? s109 : s28),
                    ),
                    Text("Not Yet",
                        style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold)),
                  ])
                ],
              ]))),
            ],
          );
        });

      case 1:
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: x.width * 0.1),
              SizedBox(
                height: x.height * 0.8,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: x.width * 0.05),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: x.width * 0.1,
                    mainAxisSpacing: x.width * 0.1,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: cat.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Text(
                          cat[index]["tite"] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: x.width * 0.07,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments: {'r': 11, 'ct': cat[index]["tite"]},
                              // Passe la valeur de r comme argument
                            );
                          },
                          child: Container(
                            height: x.width * 0.25,
                            width: x.width * 0.4,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.04),
                              color: Colors.grey[200], // Add a background color
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.04),
                              child: Image.network(
                                cat[index]["img"] ?? "images/placeholder.png",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );

      case 3:
        r = 2;
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: x.height * 0.05),
                // En-tête Followed Creator
                SizedBox(
                  height: x.height * 0.05,
                  child: Stack(
                    children: [
                      Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Followed Creator",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: x.width * 0.05,
                          ),
                        ),
                      ),
                      Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: SizedBox(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.network(s53),
                        ),
                      ),
                      if (followcha.isNotEmpty) ...[
                        Positioned(
                          top: x.height * 0.007,
                          right: x.width * 0.12,
                          child: Text(
                            "See All",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: const Color(0xFF754CEF),
                            ),
                          ),
                        ),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 9
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
                // Liste des créateurs
                if (followcha.isNotEmpty) ...[
                  SizedBox(
                    height: x.height * 0.23,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: followcha.length,
                      itemBuilder: (context, index) {
                        final creItem = followcha[index];
                        return Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: x.width * 0.02),
                            width: x.width * 0.2,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/channel',
                                  arguments: {
                                    'id': creItem["id"],
                                    'chaine': 3,
                                  },
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            x.width * 0.1),
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(creItem["photoUrl"]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: x.width * 0.01),
                                  Flexible(
                                    child: Text(
                                      creItem["name"],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: x.width * 0.03,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ],
                if (followcha.isEmpty) ...[
                  Column(children: [
                    SizedBox(
                      width: x.width * 0.7,
                      height: x.height * 0.15,
                      child:
                          Image.network(themeProvider.isDarkMode ? s109 : s28),
                    ),
                    Text("Not Yet",
                        style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold)),
                  ])
                ],
                // En-tête Favorite Playlist
                SizedBox(
                  height: x.height * 0.05,
                  child: Stack(
                    children: [
                      Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Favorit Playlist",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: x.width * 0.05,
                          ),
                        ),
                      ),
                      Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: SizedBox(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.network(s54),
                        ),
                      ),
                      if (mesplaylist.isNotEmpty) ...[
                        Positioned(
                          top: x.height * 0.007,
                          right: x.width * 0.12,
                          child: Text(
                            "See All",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: const Color(0xFF754CEF),
                            ),
                          ),
                        ),
                        Positioned(
                            top: x.height * -0.01,
                            right: x.width * 0.01,
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/seeall',
                                  arguments: {
                                    'r': 10
                                  }, // Passe la valeur de r comme argument
                                );
                              },
                              icon: Image.network(
                                s36,
                                width: x.width * 0.04,
                                height: x.width * 0.04,
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
                // Liste des playlists
                SizedBox(
                  height: x.height * 0.4,
                  child: Row(
                    children: [
                      SizedBox(
                          width: x.width * 0.36,
                          child: Stack(
                            children: [
                              Positioned(
                                top: x.height * 0.00,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: x.width * 0.02),
                                  width: x.width * 0.32,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/your1');
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      x.width * 0.04),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    user[0]["photoUrl"]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: x.width * 0.03),
                                        Flexible(
                                          child: Text(
                                            "My Playlist",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: x.width * 0.04,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: x.width * 0.01),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                formatLikes(nbr),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: x.width * 0.035,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Text(" "),
                                            Text(
                                              "Podcasts",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: x.width * 0.035,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )), // Correction ici: "height" changé en "width"
                      Expanded(
                        // Ajout d'un Expanded pour que le ListView prenne l'espace disponible
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: mesplaylist.length,
                          itemBuilder: (context, index) {
                            final playItem = mesplaylist[index];
                            return Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: x.width * 0.02),
                                width: x.width * 0.32,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/play',
                                        arguments: {
                                          'idplay': playItem["id"],
                                          'pp': 2
                                        });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                x.width * 0.04),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  playItem["photoUrl"]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: x.width * 0.03),
                                      Flexible(
                                        child: Text(
                                          playItem["name"],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: x.width * 0.04,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: x.width * 0.01),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              formatLikes(playItem["podcast"]),
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: x.width * 0.035,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Text(" "),
                                          Text(
                                            "Podcasts",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: x.width * 0.035,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ));
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
      case 4:
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return Stack(
              fit: StackFit
                  .expand, // Force le Stack à prendre tout l'espace disponible
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: x.width,
                    height: x.height * 0.25,
                    decoration: const BoxDecoration(color: Color(0xFF754CEF)),
                  ),
                ),
                Positioned(
                  top: x.height * 0.02,
                  left: x.width * 0.05,
                  child: Text(
                    "Account",
                    style: TextStyle(
                        fontSize: x.width * 0.06,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Positioned(
                  top: x.height * 0.09,
                  left: x.width * 0.03,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false,
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return FadeTransition(
                              opacity: animation,
                              child:
                                  ZoomPhotoPage(imageUrl: user[0]["photoUrl"]),
                            );
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'zoomImageHero5',
                      child: Container(
                        width: x.width * 0.17,
                        height: x.width * 0.17,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          image: DecorationImage(
                            image: NetworkImage(user.isNotEmpty
                                ? user[0]["photoUrl"] ?? ''
                                : 'https://migwbqbtfzszopvhdzre.supabase.co/storage/v1/object/public/pfeapp/profile/output-onlinejpgtools%20(2).jpg'),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          ),
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: x.height * 0.11,
                  left: x.width * 0.25,
                  child: SizedBox(
                    width: x.width * 0.5,
                    height: x.height * 0.1,
                    child: Column(
                      children: [
                        Text(
                          user.isNotEmpty
                              ? "${user[0]["firstName"]} ${user[0]["lastName"]}"
                              : "",
                          style: TextStyle(
                            fontSize: x.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                        ),
                        Text(
                          user.isNotEmpty ? user[0]["email"] ?? '' : '',
                          style: TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.03),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    top: x.height * 0.14,
                    left: x.width * 0.25,
                    child: const Text("")),
                Positioned(
                    top: x.height * 0.11,
                    right: x.width * 0.05,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/modif',
                            arguments: {'q': 2});
                      },
                      icon: Image.network(
                        s81,
                        width: x.width * 0.05,
                        height: x.width * 0.05,
                        //   color:Colors.white,
                      ),
                    )),
                Positioned(
                  top: x.width * 0.4,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white,
                      borderRadius: BorderRadius.circular(x.width * 0.05),
                    ),
                    width: x.width,
                    height: x.height * 0.08,
                  ),
                ),
                Positioned(
                  top: x.height * 0.22,
                  left: x.width * 0.03,
                  child: Text(
                    "Account Settings",
                    style: TextStyle(
                      fontSize: x.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: x.height * 0.31,
                  left: x.width * 0.03,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/your',
                          arguments: {'your': 6});
                    },
                    child: Image.network(
                      themeProvider.isDarkMode ? s126 : s85,
                      width: x.width * 0.07,
                      height: x.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: x.height * 0.3,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/your',
                              arguments: {'your': 6});
                        },
                        child: Text(
                          "Your Channel",
                          style: TextStyle(
                            fontSize: x.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                Positioned(
                    top: x.height * 0.33,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/your',
                                arguments: {'your': 6});
                          },
                          child: Text(
                            "You Can Visit Your Channel And See Your Information ",
                            style: TextStyle(
                                fontSize: x.width * 0.025, color: Colors.grey),
                          )),
                    )),
                Positioned(
                  top: x.height * 0.38,
                  left: x.width * 0.03,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/stat');
                    },
                    child: Image.network(
                      themeProvider.isDarkMode ? s127 : s86,
                      width: x.width * 0.07,
                      height: x.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: x.height * 0.37,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/stat');
                        },
                        child: Text(
                          "Stat",
                          style: TextStyle(
                              fontSize: x.width * 0.045,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
                Positioned(
                    top: x.height * 0.4,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/stat');
                          },
                          child: Text(
                            "Find All Your Result Of The Week ",
                            style: TextStyle(
                                fontSize: x.width * 0.025, color: Colors.grey),
                          )),
                    )),
                Positioned(
                  top: x.height * 0.52,
                  left: x.width * 0.03,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                    child: Image.network(
                      s87,
                      width: x.width * 0.07,
                      height: x.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: x.height * 0.51,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                        child: Text(
                          "About Us",
                          style: TextStyle(
                              fontSize: x.width * 0.045,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
                Positioned(
                    top: x.height * 0.54,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/about');
                          },
                          child: Text(
                            "You Can Send The Messang Or Follow Us In Another App",
                            style: TextStyle(
                                fontSize: x.width * 0.025, color: Colors.grey),
                          )),
                    )),
                Positioned(
                  top: x.height * 0.45,
                  left: x.width * 0.03,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/pryv');
                    },
                    child: Image.network(
                      themeProvider.isDarkMode ? s128 : s88,
                      width: x.width * 0.07,
                      height: x.width * 0.07,
                    ),
                  ),
                ),
                Positioned(
                    top: x.height * 0.44,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/pryv');
                        },
                        child: Text(
                          "Account Privicy",
                          style: TextStyle(
                              fontSize: x.width * 0.045,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
                Positioned(
                    top: x.height * 0.47,
                    left: x.width * 0.15,
                    child: SizedBox(
                      width: x.width,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/pryv');
                          },
                          child: Text(
                            "You Can Manage Your Account",
                            style: TextStyle(
                                fontSize: x.width * 0.025, color: Colors.grey),
                          )),
                    )),
                Positioned(
                  top: x.height * 0.6,
                  left: x.width * 0.03,
                  child: Text(
                    "App Settings",
                    style: TextStyle(
                      fontSize: x.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: x.height * 0.665,
                  right: x.width * 0.1,
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Switch(
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[350],
                        activeTrackColor: const Color(0xFF754CEF),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  top: x.height * 0.68,
                  left: x.width * 0.03,
                  child: Image.network(
                    themeProvider.isDarkMode ? s129 : s92,
                    width: x.width * 0.07,
                    height: x.width * 0.07,
                  ),
                ),
                Positioned(
                  top: x.height * 0.67,
                  left: x.width * 0.15,
                  child: Text(
                    "Dark Mode",
                    style: TextStyle(
                        fontSize: x.width * 0.045, fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                    top: x.height * 0.7,
                    left: x.width * 0.15,
                    child: Text(
                      "Change Your Mode Dark Or Ligth",
                      style: TextStyle(
                          fontSize: x.width * 0.025, color: Colors.grey),
                    )),
                Positioned(
                  top: x.height * 0.77,
                  left: x.width * 0.04,
                  child: Image.network(
                    s90,
                    width: x.width * 0.06,
                    height: x.width * 0.06,
                  ),
                ),
                Positioned(
                  top: x.height * 0.77,
                  left: x.width * 0.15,
                  child: GestureDetector(
                    onTap: () async {
                      await logout();
                      Navigator.pushNamedAndRemoveUntil(
                          // ignore: use_build_context_synchronously
                          context,
                          '/LogIn',
                          (route) => false);
                    },
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                          fontSize: x.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                ),
              ]);
        });
      default:
        return const Center(child: Text(''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size x = MediaQuery.of(context).size;
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        body: SafeArea(
          child: isLoading
              ? const Annimationwidjet()
              : Container(
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode ? Colors.black : Colors.white,
                  ),
                  width: double.infinity, // Added to provide width constraint
                  height: double.infinity, // Added to provide height constraint

                  child: _buildBody(context),
                ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.white,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF754CEF),
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.network(
                s124,
                width: x.width * 0.05,
                height: x.width * 0.05,
                color: _selectedIndex == 1
                    ? const Color(0xFF754CEF)
                    : themeProvider.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[800],
              ),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                // Déplace l'icône vers le bas
                width: x.width * 0.085,
                height: x.width * 0.085,
                child: Image.network(
                  s26,
                  color: _selectedIndex == 2
                      ? const Color(0xFF754CEF)
                      : Colors.grey[600],
                ),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Image.network(
                s125,
                width: x.width * 0.05,
                height: x.width * 0.05,
                color: _selectedIndex == 3
                    ? const Color(0xFF754CEF)
                    : themeProvider.isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[800],
              ),
              label: 'Librairy',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}

class Search extends SearchDelegate<String> {
  List<String> suggestions = [];
  List<Map<String, dynamic>> searchResults = [];

  Future<void> fetchRecentsearch() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('search')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        recentSearches = querySnapshot.docs
            .map(
                // ignore: unnecessary_cast
                (doc) =>
                    // ignore: unnecessary_cast
                    (doc.data() as Map<String, dynamic>)['text'] as String)
            .toList();
      });

      // ignore: empty_catches
    } catch (e) {
      // Add logging for debugging
    }
  }

  Future<void> fetchFeaturedPodcasts() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final recentPodcasts = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('dateCreation',
              isGreaterThan: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('dateCreation', descending: true)
          .get();

      setState(() {
        feae = recentPodcasts.docs
            // ignore: unnecessary_cast
            .map((doc) {
          // ignore: unnecessary_cast
          final data = doc.data() as Map<String, dynamic>;
          // Add the document ID to each item
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      // Add logging for debugging

      setState(() {
        // Initialize as empty list instead of null
        feae = [];
      });
    }
  }

  Future<void> deleteRecentSearch(String query) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (currentUserId.isEmpty) {
        return;
      }

      final searchCollection = FirebaseFirestore.instance.collection('search');

      final matchingDocs = await searchCollection
          .where('userId', isEqualTo: currentUserId)
          .where('text', isEqualTo: query)
          .get();

      for (var doc in matchingDocs.docs) {
        await doc.reference.delete();
      }

      // Rafraîchir les recherches récentes
      await fetchRecentsearch();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> saveSearchQuery(String query) async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      if (currentUserId.isEmpty) {
        return;
      }

      final searchCollection = FirebaseFirestore.instance.collection('search');

      // Vérifier si une recherche identique existe déjà pour ce user
      final existingQuery = await searchCollection
          .where('userId', isEqualTo: currentUserId)
          .where('text', isEqualTo: query)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return;
      }

      // Ajouter la nouvelle recherche
      await searchCollection.add({
        'userId': currentUserId,
        'text': query,
        'timestamp': Timestamp.now()
      });

      // Rafraîchir les recherches récentes
      await fetchRecentsearch();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> searchContent(String searchQuery) async {
    if (searchQuery.isEmpty) {
      searchResults = [];
      suggestions = [];
      return;
    }

    try {
      final String lowercaseQuery = searchQuery.toLowerCase();
      List<Map<String, dynamic>> results = [];

      // Recherche dans les podcasts
      final podcastsSnapshot =
          await FirebaseFirestore.instance.collection('podcasts').get();

      // Liste pour stocker les podcasts trouvés pour traitement ultérieur
      List<Map<String, dynamic>> foundPodcasts = [];

      for (var doc in podcastsSnapshot.docs) {
        var data = doc.data();
        String name = (data['name'] as String? ?? '').toLowerCase();
        if (name.contains(lowercaseQuery)) {
          data['type'] = 'podcast';
          data['id'] = doc.id;
          results.add(data);
          foundPodcasts.add({...data, 'docId': doc.id});
        }
      }

      // Recherche dans les chaînes
      final channelsSnapshot =
          await FirebaseFirestore.instance.collection('channels').get();

      // Liste pour stocker les channels trouvés pour traitement ultérieur
      List<Map<String, dynamic>> foundChannels = [];

      for (var doc in channelsSnapshot.docs) {
        var data = doc.data();
        String name = (data['name'] as String? ?? '').toLowerCase();
        if (name.contains(lowercaseQuery)) {
          data['type'] = 'channel';
          data['id'] = doc.id;
          results.add(data);
          foundChannels.add({...data, 'docId': doc.id});
        }
      }

      // Recherche dans les playlists
      final playlistsSnapshot =
          await FirebaseFirestore.instance.collection('playlist').get();

      // Liste pour stocker les playlists trouvées pour traitement ultérieur
      List<Map<String, dynamic>> foundPlaylists = [];

      for (var doc in playlistsSnapshot.docs) {
        var data = doc.data();
        String name = (data['name'] as String? ?? '').toLowerCase();
        if (name.contains(lowercaseQuery)) {
          data['type'] = 'playlist';
          data['id'] = doc.id;
          results.add(data);
          foundPlaylists.add({...data, 'docId': doc.id});
        }
      }

      // 1. Si on a trouvé des podcasts, chercher les channels associés et playlists
      if (foundPodcasts.isNotEmpty) {
        // Pour chaque podcast trouvé, récupérer son channel
        for (var podcast in foundPodcasts) {
          String podcastUserId = podcast['idUser'] ?? '';
          String podcastId = podcast['docId'] ?? '';

          if (podcastUserId.isNotEmpty) {
            // Récupérer le channel associé au userId du podcast
            final channelQuery = await FirebaseFirestore.instance
                .collection('channels')
                .where('userId', isEqualTo: podcastUserId)
                .get();

            for (var doc in channelQuery.docs) {
              var data = doc.data();
              // Vérifier si ce channel n'est pas déjà dans les résultats
              bool alreadyExists = results.any(
                  (item) => item['type'] == 'channel' && item['id'] == doc.id);

              if (!alreadyExists) {
                data['type'] = 'channel';
                data['id'] = doc.id;
                data['relatedTo'] = 'podcast:${podcast['name']}';
                results.add(data);
              }
            }
          }

          if (podcastId.isNotEmpty) {
            // Récupérer les playlists qui contiennent ce podcast
            final playlistsForPodcast = await FirebaseFirestore.instance
                .collection('playinpod')
                .where('podcastId', isEqualTo: podcastId)
                .get();

            // Ensemble pour éviter les doublons de playlistId
            Set<String> playlistIds = {};

            for (var doc in playlistsForPodcast.docs) {
              String playlistId = doc.data()['playlistId'] ?? '';
              if (playlistId.isNotEmpty) {
                playlistIds.add(playlistId);
              }
            }

            // Récupérer les détails de chaque playlist
            for (String playlistId in playlistIds) {
              final playlistDoc = await FirebaseFirestore.instance
                  .collection('playlist')
                  .doc(playlistId)
                  .get();

              if (playlistDoc.exists) {
                var data = playlistDoc.data() as Map<String, dynamic>;
                // Vérifier si cette playlist n'est pas déjà dans les résultats
                bool alreadyExists = results.any((item) =>
                    item['type'] == 'playlist' && item['id'] == playlistId);

                if (!alreadyExists) {
                  data['type'] = 'playlist';
                  data['id'] = playlistId;
                  data['relatedTo'] = 'podcast:${podcast['name']}';
                  results.add(data);
                }
              }
            }
          }
        }
      }

      // 2. Si on a trouvé des channels, chercher leurs podcasts et playlists récents
      if (foundChannels.isNotEmpty) {
        for (var channel in foundChannels) {
          String channelUserId = channel['userId'] ?? '';

          if (channelUserId.isNotEmpty) {
            // Récupérer les 10 podcasts les plus récents de ce channel
            final recentPodcasts = await FirebaseFirestore.instance
                .collection('podcasts')
                .where('idUser', isEqualTo: channelUserId)
                .orderBy('dateCreation', descending: true)
                .limit(10)
                .get();

            for (var doc in recentPodcasts.docs) {
              var data = doc.data();
              // Vérifier si ce podcast n'est pas déjà dans les résultats
              bool alreadyExists = results.any(
                  (item) => item['type'] == 'podcast' && item['id'] == doc.id);

              if (!alreadyExists) {
                data['type'] = 'podcast';
                data['id'] = doc.id;
                data['relatedTo'] = 'channel:${channel['name']}';
                results.add(data);
              }
            }

            // Récupérer les playlists créées par ce channel (userId)
            final channelPlaylists = await FirebaseFirestore.instance
                .collection('playlist')
                .where('userId', isEqualTo: channelUserId)
                .get();

            for (var doc in channelPlaylists.docs) {
              var data = doc.data();
              // Vérifier si cette playlist n'est pas déjà dans les résultats
              bool alreadyExists = results.any(
                  (item) => item['type'] == 'playlist' && item['id'] == doc.id);

              if (!alreadyExists) {
                data['type'] = 'playlist';
                data['id'] = doc.id;
                data['relatedTo'] = 'channel:${channel['name']}';
                results.add(data);
              }
            }
          }
        }
      }

      // 3. Si on a trouvé des playlists, chercher leurs channels et podcasts associés
      if (foundPlaylists.isNotEmpty) {
        for (var playlist in foundPlaylists) {
          String playlistId = playlist['docId'] ?? '';
          String playlistUserId = playlist['userId'] ?? '';

          // Récupérer le channel associé à cette playlist via userId
          if (playlistUserId.isNotEmpty) {
            final channelQuery = await FirebaseFirestore.instance
                .collection('channels')
                .where('userId', isEqualTo: playlistUserId)
                .get();

            for (var doc in channelQuery.docs) {
              var data = doc.data();
              // Vérifier si ce channel n'est pas déjà dans les résultats
              bool alreadyExists = results.any(
                  (item) => item['type'] == 'channel' && item['id'] == doc.id);

              if (!alreadyExists) {
                data['type'] = 'channel';
                data['id'] = doc.id;
                data['relatedTo'] = 'playlist:${playlist['name']}';
                results.add(data);
              }
            }
          }

          // Récupérer les podcasts associés à cette playlist
          if (playlistId.isNotEmpty) {
            final podcastsInPlaylist = await FirebaseFirestore.instance
                .collection('playinpod')
                .where('playlistId', isEqualTo: playlistId)
                .get();

            // Ensemble pour éviter les doublons de podcastId
            Set<String> podcastIds = {};

            for (var doc in podcastsInPlaylist.docs) {
              String podcastId = doc.data()['podcastId'] ?? '';
              if (podcastId.isNotEmpty) {
                podcastIds.add(podcastId);
              }
            }

            // Récupérer les détails de chaque podcast
            for (String podcastId in podcastIds) {
              final podcastDoc = await FirebaseFirestore.instance
                  .collection('podcasts')
                  .doc(podcastId)
                  .get();

              if (podcastDoc.exists) {
                var data = podcastDoc.data() as Map<String, dynamic>;
                // Vérifier si ce podcast n'est pas déjà dans les résultats
                bool alreadyExists = results.any((item) =>
                    item['type'] == 'podcast' && item['id'] == podcastId);

                if (!alreadyExists) {
                  data['type'] = 'podcast';
                  data['id'] = podcastId;
                  data['relatedTo'] = 'playlist:${playlist['name']}';
                  results.add(data);
                }
              }
            }
          }
        }
      }

      setState(() {
        searchResults = results;
        suggestions = results
            .map((result) => result['name'] as String? ?? 'Sans nom')
            .toList();
      });

      // ignore: empty_catches
    } catch (e) {}
  }

  List<Map<String, dynamic>> feae = [];
  List<String> recentSearches = [];

  void setState(Function() fn) {
    fn();
  }

  Search() {
    _initializeData();
  }
  Future<void> _initializeData() async {
    await fetchRecentsearch();
    await fetchFeaturedPodcasts();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    const double fontSize = 16.0;

    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: isDarkMode ? Colors.white : Colors.black,
        selectionColor: isDarkMode ? Colors.white54 : Colors.black12,
        selectionHandleColor: isDarkMode ? Colors.white : Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        floatingLabelStyle:
            TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.02,
          vertical: MediaQuery.of(context).size.width * 0.025,
        ),
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey,
          fontSize: fontSize,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : const Color(0xFFD9D9D9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
              color: isDarkMode ? Colors.grey[700]! : const Color(0xFFD9D9D9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
              color: isDarkMode ? Colors.grey[700]! : const Color(0xFFD9D9D9)),
        ),
      ),
      textTheme: Theme.of(context).textTheme.copyWith(
            titleLarge: TextStyle(
              fontSize: fontSize,
              height: 1.2,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return [
      IconButton(
        icon: Icon(
          Icons.refresh,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return IconButton(
      icon: Image.network(
        themeProvider.isDarkMode ? s97 : s18,
        width: MediaQuery.of(context).size.width * 0.06,
        height: MediaQuery.of(context).size.width * 0.06,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Perform search and save query
    if (query.isNotEmpty) {
      // Save the query first
      saveSearchQuery(query);

      // Show loading animation while searching
      return const Center(
        child: Annimationwidjet(),
      );
    }

    // Show loading indicator while waiting
    return const Center(
      child: Annimationwidjet(),
    );
  }

  // FIXED: Removed _searchAndNavigate method and integrated its functionality directly in buildResults

  @override
  void showResults(BuildContext context) {
    // Override showResults to execute our search and navigation
    if (query.isNotEmpty) {
      // First, perform the database query
      searchContent(query).then((_) {
        // Make a copy of the results to prevent any issues with state management
        final String searchQuery = query;
        final List<Map<String, dynamic>> results = List.from(searchResults);

        // Close the search delegate properly first
        // ignore: use_build_context_synchronously
        close(context, searchQuery);

        // Then navigate to results page after the search delegate is closed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SearchResultsPage(
                query: searchQuery,
                results: results,
              ),
            ),
          );
        });
      });
    } else {
      super.showResults(context);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    // Show search results if query is not empty and we have results
    if (query.isNotEmpty) {
      // Recherche en direct pendant que l'utilisateur tape
      searchContent(query);

      // Afficher les résultats de recherche avec l'icône de recherche
      return Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            final item = searchResults[index];
            final itemName = item['name'] as String? ?? 'Sans nom';

            return ListTile(
              leading: Icon(Icons.search,
                  color: isDarkMode ? Colors.white : Colors.black),
              title: Text(
                itemName,
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              onTap: () {
                query = itemName;
                showResults(context);
              },
            );
          },
        ),
      );
    }

    // Display either recent searches or featured podcasts
    List<dynamic> displayList = [];
    bool showingRecentSearches = true;

    if (recentSearches.isNotEmpty) {
      displayList = recentSearches;
      showingRecentSearches = true;
    }
    if (recentSearches.isEmpty) {
      displayList = feae;
      showingRecentSearches = false;
    }

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      child: ListView.builder(
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final item = displayList[index];

          // For recent searches (strings)
          if (showingRecentSearches) {
            final searchText = item as String;
            return ListTile(
              leading: Icon(Icons.history,
                  color: isDarkMode ? Colors.white : Colors.black),
              title: Text(
                searchText,
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              trailing: IconButton(
                icon: Icon(Icons.clear,
                    color: isDarkMode ? Colors.white : Colors.black),
                onPressed: () async {
                  await deleteRecentSearch(searchText);
                },
              ),
              onTap: () async {
                query = searchText;
                showResults(context);
              },
            );
          }
          // For featured podcasts (maps)
          else {
            final podcast = item as Map<String, dynamic>;
            final podcastName =
                podcast['name'] as String? ?? 'Podcast sans nom';

            return ListTile(
              leading: Icon(Icons.arrow_forward,
                  color: isDarkMode ? Colors.white : Colors.black),
              title: Text(
                podcastName,
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              onTap: () {
                query = podcastName;
                showResults(context);
              },
            );
          }
        },
      ),
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  final String query;
  final List<Map<String, dynamic>> results;

  // ignore: use_super_parameters
  const SearchResultsPage({
    Key? key,
    required this.query,
    required this.results,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Variables pour stocker l'état des filtres appliqués
  Map<String, String> activeFilters = {};
  List<Map<String, dynamic>> filteredResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialiser les résultats filtrés avec tous les résultats
    filteredResults = List.from(widget.results);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = MediaQuery.of(context).size;

    // Filtrer les résultats selon le type pour chaque onglet
    final podcasts =
        filteredResults.where((item) => item['type'] == 'podcast').toList();
    final channels =
        filteredResults.where((item) => item['type'] == 'channel').toList();
    final playlists =
        filteredResults.where((item) => item['type'] == 'playlist').toList();

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor:
              themeProvider.isDarkMode ? Colors.black : Colors.white,
          leading: IconButton(
            icon: Image.network(
              themeProvider.isDarkMode ? s97 : s18,
              width: q.width * 0.06,
              height: q.width * 0.06,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: GestureDetector(
            onTap: () {
              // Ouvrir le SearchDelegate existant
              showSearch(
                context: context,
                delegate: Search(),
              );
            },
            child: Container(
              height: q.height * 0.045,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(q.width * 0.05),
              ),
              child: Row(
                children: [
                  SizedBox(width: q.width * 0.03),
                  Icon(Icons.search, color: Colors.grey, size: q.width * 0.05),
                  SizedBox(width: q.width * 0.02),
                  Expanded(
                    child: Text(
                      widget.query,
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black87,
                        fontSize: q.width * 0.04,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: activeFilters.isNotEmpty
                        ? const Color(0xFF754CEF)
                        : themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                    size: q.width * 0.06,
                  ),
                  onPressed: () {
                    _showFilterOptions(context);
                  },
                ),
                if (activeFilters.isNotEmpty)
                  Positioned(
                    top: q.height * 0.01,
                    right: q.width * 0.02,
                    child: Container(
                      padding: EdgeInsets.all(q.width * 0.01),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        activeFilters.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: q.width * 0.025,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          elevation: 1,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(q.height * 0.06),
            child: Container(
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor:
                    themeProvider.isDarkMode ? Colors.white : Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor:
                    themeProvider.isDarkMode ? Colors.white : Colors.black,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: 'Podcast(${formatLikes(podcasts.length)})'),
                  Tab(text: 'Channel(${formatLikes(channels.length)})'),
                  Tab(text: 'Playlist(${formatLikes(playlists.length)})'),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          color: themeProvider.isDarkMode ? Colors.black : Colors.white,
          child: filteredResults.isEmpty
              ? Center(
                  child: Text(
                    'Aucun résultat trouvé pour "${widget.query}"',
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black54,
                      fontSize: q.width * 0.04,
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Podcasts
                    buildListView(podcasts),
                    // Channels
                    buildListView(channels),
                    // Playlists
                    buildListView(playlists),
                  ],
                ),
        ),
      );
    });
  }

  Widget buildListView(List<Map<String, dynamic>> items) {
    final q = MediaQuery.of(context).size;

    if (items.isEmpty) {
      return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return Center(
          child: Text(
            'Aucun résultat pour cette catégorie',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black54,
              fontSize: q.width * 0.04,
            ),
          ),
        );
      });
    }

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: q.width * 0.02),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Déterminer l'icône en fonction du type

          switch (item['type']) {
            case 'podcast':
              return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: q.width * 0.03,
                    vertical: q.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(q.width * 0.05),
                    border: Border.all(
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black12),
                  ),
                  width: q.width * 0.94,
                  height: q.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/podcast',
                        arguments: {
                          'idpod': item["id"],
                          'feat':
                              13, // remplace "someValue" par ce que tu veux représenter
                        },
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(width: q.width * 0.03),
                        Image.network(
                          s48,
                          width: q.width * 0.09,
                          height: q.width * 0.09,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: q.width * 0.03),
                        Container(
                          height: q.width * 0.2,
                          width: q.width * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(q.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(item["urlPhoto"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: q.width * 0.04),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: q.width * 0.04,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: q.width * 0.01),
                            ],
                          ),
                        ),
                        SizedBox(width: q.width * 0.02),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: q.width *
                                    0.2, // Constrain the width of the progress bar
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: q.width * 0.05,
                                          height: q.width * 0.05,
                                          child: Image.network(
                                            themeProvider.isDarkMode
                                                ? s111
                                                : s37,
                                          ),
                                        ),
                                        SizedBox(
                                          width: q.width * 0.01,
                                        ),
                                        Text(
                                          formatLikes(item["likes"]!),
                                          style: TextStyle(
                                              fontSize: q.width * 0.035,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: q.width * 0.02,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: q.width * 0.05,
                                          height: q.width * 0.05,
                                          child: Image.network(
                                              themeProvider.isDarkMode
                                                  ? s108
                                                  : s14),
                                        ),
                                        SizedBox(
                                          width: q.width * 0.01,
                                        ),
                                        Text(
                                          formatLikes(item["vue"]!),
                                          style: TextStyle(
                                              fontSize: q.width * 0.035,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: q.width * 0.02,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: q.width * 0.05,
                                          height: q.width * 0.05,
                                          child: Image.network(
                                              themeProvider.isDarkMode
                                                  ? s112
                                                  : s38),
                                        ),
                                        SizedBox(
                                          width: q.width * 0.01,
                                        ),
                                        Text(
                                          formatLikes(item["comments"]!),
                                          style: TextStyle(
                                              fontSize: q.width * 0.035,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                  ));

            case 'channel':
              return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: q.width * 0.03,
                    vertical: q.width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(q.width * 0.05),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black12,
                    ),
                  ),
                  width: q.width * 0.94,
                  height: q.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      if (userId == item["userId"]) {
                        Navigator.pushNamed(context, '/your',
                            arguments: {'your': 5});
                      }
                      if (userId != item["userId"]) {
                        Navigator.pushNamed(
                          context,
                          '/channel',
                          arguments: {
                            'id': item["id"],
                            'chaine': 2,
                          },
                        );
                      }
                    },
                    child: Row(
                      children: [
                        SizedBox(width: q.width * 0.03),
                        Container(
                          height: q.width * 0.2,
                          width: q.width * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(q.width * 0.1),
                            image: DecorationImage(
                              image: NetworkImage(item["photoUrl"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: q.width * 0.04),
                        Expanded(
                          child: Text(
                            item["name"]!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: q.width * 0.04,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: q.width * 0.02),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Followers",
                              style: TextStyle(
                                fontSize: q.width * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatLikes(item["followers"]!),
                              style: TextStyle(
                                fontSize: q.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: q.width * 0.03),
                      ],
                    ),
                  ));

            case 'playlist':
              return Container(
                  margin: EdgeInsets.all(q.width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(q.width * 0.05),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? Colors.white70
                          : Colors.black12,
                    ),
                  ),
                  width: q.width * 0.95,
                  height: q.width * 0.3,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/play',
                          arguments: {'idplay': item["id"], 'pp': 5});
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: q.width * 0.01,
                        ),
                        Container(
                          height: q.width * 0.25,
                          width: q.width * 0.25,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(q.width * 0.04),
                            image: DecorationImage(
                              image: NetworkImage(item["photoUrl"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: q.width * 0.04),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: q.width * 0.02),
                            SizedBox(
                              width: q.width * 0.3,
                              child: Text(
                                item["name"]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: q.width * 0.04,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: q.width * 0.04,
                        ),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: q.width *
                                      0.2, // Constrain the width of the progress bar
                                  child: Column(children: [
                                    SizedBox(
                                      height: q.width * 0.02,
                                    ),
                                    Column(children: [
                                      Text(
                                        formatLikes(item["podcast"]!),
                                        style: TextStyle(
                                          fontSize: q.width * 0.035,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        width: q.width * 0.03,
                                      ),
                                      Text(
                                        "Podcast",
                                        style: TextStyle(
                                          fontSize: q.width * 0.035,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ])
                                  ]))
                            ])
                      ],
                    ),
                  ));
          }
          return null;
        },
      );
    });
  }

  void _showFilterOptions(BuildContext context) {
    final q = MediaQuery.of(context).size;

    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(q.width * 0.04),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: q.height * 0.025,
                  horizontal: q.width * 0.04,
                ),
                // Utiliser une hauteur relative pour le bottom sheet
                height: q.height * 0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: q.width * 0.1,
                        height: q.height * 0.005,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.black
                              : Colors.white,
                          borderRadius: BorderRadius.circular(q.width * 0.005),
                        ),
                        margin: EdgeInsets.only(bottom: q.height * 0.02),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Results',
                          style: TextStyle(
                            fontSize: q.width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        if (activeFilters.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _resetFilters();
                            },
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                color: const Color(0xFF754CEF),
                                fontSize: q.width * 0.035,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: q.height * 0.02),

                    // Filtres par durée
                    Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: q.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    SizedBox(height: q.height * 0.012),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            '< 10 min',
                            () {
                              if (mounted) {
                                setStateModal(() {
                                  _toggleFilter('duration', 'less10');
                                });
                              }
                            },
                            isActive: activeFilters['duration'] == 'less10',
                          ),
                          SizedBox(width: q.width * 0.02),
                          _buildFilterChip(
                            '10-20 min',
                            () {
                              if (mounted) {
                                setStateModal(() {
                                  _toggleFilter('duration', '10to20');
                                });
                              }
                            },
                            isActive: activeFilters['duration'] == '10to20',
                          ),
                          SizedBox(width: q.width * 0.02),
                          _buildFilterChip(
                            '> 20 min',
                            () {
                              if (mounted) {
                                setStateModal(() {
                                  _toggleFilter('duration', 'more20');
                                });
                              }
                            },
                            isActive: activeFilters['duration'] == 'more20',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: q.height * 0.025),

                    // Tri par date
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: q.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    SizedBox(height: q.height * 0.012),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Most Recent',
                            () {
                              if (mounted) {
                                setStateModal(() {
                                  _toggleFilter('sort', 'recent');
                                });
                              }
                            },
                            isActive: activeFilters['sort'] == 'recent',
                          ),
                          SizedBox(width: q.width * 0.02),
                          _buildFilterChip(
                            'Older',
                            () {
                              if (mounted) {
                                setStateModal(() {
                                  _toggleFilter('sort', 'oldest');
                                });
                              }
                            },
                            isActive: activeFilters['sort'] == 'oldest',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: q.height * 0.025),

                    // Tri par popularité
                    Text(
                      'Popularity',
                      style: TextStyle(
                        fontSize: q.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    SizedBox(height: q.height * 0.012),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Most Viewed',
                            () {
                              if (mounted) {
                                setStateModal(() {
                                  _toggleFilter('popularity', 'views');
                                });
                              }
                            },
                            isActive: activeFilters['popularity'] == 'views',
                          ),
                          SizedBox(width: q.width * 0.02),
                          _buildFilterChip(
                            'Most Liked',
                            () {
                              if (mounted) {
                                setStateModal(() {
                                  _toggleFilter('popularity', 'likes');
                                });
                              }
                            },
                            isActive: activeFilters['popularity'] == 'likes',
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Bouton pour appliquer les filtres
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _applyFilters();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF754CEF),
                          foregroundColor: Colors.white,
                          minimumSize: Size(q.width * 0.8, q.height * 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(q.width * 0.05),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: q.width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: q.height * 0.02),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap,
      {bool isActive = false}) {
    final q = MediaQuery.of(context).size;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: q.width * 0.04,
          vertical: q.height * 0.01,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF754CEF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(q.width * 0.05),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontSize: q.width * 0.035,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _toggleFilter(String filterType, String value) {
    // Si le filtre est déjà actif avec la même valeur, le supprimer
    if (activeFilters[filterType] == value) {
      activeFilters.remove(filterType);
    } else {
      // Sinon, définir/remplacer le filtre
      activeFilters[filterType] = value;
    }
  }

  void _applyFilters() {
    if (activeFilters.isEmpty) {
      // Si aucun filtre n'est actif, restaurer tous les résultats
      if (mounted) {
        setState(() {
          filteredResults = List.from(widget.results);
        });
      }
      return;
    }

    // Commencer avec tous les résultats
    List<Map<String, dynamic>> results = List.from(widget.results);
    List<Map<String, dynamic>> podcastResults =
        results.where((item) => item['type'] == 'podcast').toList();

    // Appliquer les filtres uniquement sur les podcasts
    List<Map<String, dynamic>> filteredPodcasts = [];

    for (var podcast in podcastResults) {
      bool matchesFilters = true;

      // Filtre de durée
      if (activeFilters.containsKey('duration')) {
        String durationSeconds = podcast['duration'] ?? '0:00';
        List<String> parts = durationSeconds.split(':');
        int durationMinutes = int.tryParse(parts[0]) ?? 0;
        switch (activeFilters['duration']) {
          case 'less10':
            if (durationMinutes >= 10) matchesFilters = false;
            break;
          case '10to20':
            if (durationMinutes < 10 || durationMinutes > 20) {
              matchesFilters = false;
            }
            break;
          case 'more20':
            if (durationMinutes <= 20) matchesFilters = false;
            break;
        }
      }

      // Si le podcast correspond aux critères de durée, l'ajouter
      if (matchesFilters) {
        filteredPodcasts.add(podcast);
      }
    }

    // Trier les podcasts filtrés si nécessaire
    if (activeFilters.containsKey('sort')) {
      filteredPodcasts.sort((a, b) {
        if (activeFilters['sort'] == 'recent') {
          // Tri par date (plus récent d'abord)
          Timestamp dateA =
              a['dateCreation'] ?? Timestamp.fromDate(DateTime(2000));
          Timestamp dateB =
              b['dateCreation'] ?? Timestamp.fromDate(DateTime(2000));
          return dateB.compareTo(dateA);
        } else if (activeFilters['sort'] == 'oldest') {
          // Tri par date (plus ancien d'abord)
          Timestamp dateA =
              a['dateCreation'] ?? Timestamp.fromDate(DateTime(2000));
          Timestamp dateB =
              b['dateCreation'] ?? Timestamp.fromDate(DateTime(2000));
          return dateA.compareTo(dateB);
        }
        return 0;
      });
    }

    // Trier par popularité si nécessaire
    if (activeFilters.containsKey('popularity')) {
      filteredPodcasts.sort((a, b) {
        if (activeFilters['popularity'] == 'views') {
          // Tri par nombre de vues (décroissant)
          int viewsA = a['vue'] ?? 0;
          int viewsB = b['vue'] ?? 0;
          return viewsB.compareTo(viewsA);
        } else if (activeFilters['popularity'] == 'likes') {
          // Tri par nombre de likes (décroissant)
          int likesA = a['likes'] ?? 0;
          int likesB = b['likes'] ?? 0;
          return likesB.compareTo(likesA);
        }
        return 0;
      });
    }

    // Remplacer les podcasts dans les résultats
    List<Map<String, dynamic>> nonPodcastResults =
        results.where((item) => item['type'] != 'podcast').toList();

    if (mounted) {
      setState(() {
        filteredResults = [...filteredPodcasts, ...nonPodcastResults];
      });
    }
  }

  void _resetFilters() {
    if (mounted) {
      setState(() {
        activeFilters.clear();
        filteredResults = List.from(widget.results);
      });
    }
  }

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
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
}
