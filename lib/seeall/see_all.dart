import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import for StreamSubscription

class SeeAllpage extends StatefulWidget {
  const SeeAllpage({super.key});

  @override
  State<SeeAllpage> createState() => _SeeAllpagepageState();
}

class _SeeAllpagepageState extends State<SeeAllpage>
    with SingleTickerProviderStateMixin {
  // List to track all active stream subscriptions
  final List<StreamSubscription> _streamSubscriptions = [];

  Future<void> fetchpodcasts() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy('dateCreation', descending: true)
          .where('idUser', isEqualTo: currentUserId)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        setState(() {
          podcast = querySnapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }, onError: (e) {
        setState(() {});
      });

      _streamSubscriptions.add(streamSubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  List<Map<String, dynamic>> podcast = [];
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

  List<Map<String, dynamic>> user = [];
  Future<void> fetchuser() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final streamSubscription = FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        setState(() {
          user = querySnapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }, onError: (e) {});

      _streamSubscriptions.add(streamSubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  List<Map<String, dynamic>> followcha = [];
  List<Map<String, dynamic>> playlist = [];
  Future<void> fetchplaylists() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final streamSubscription = FirebaseFirestore.instance
          .collection('playlist')
          .orderBy('createdAt', descending: true)
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .listen((querySnapshot) {
        // Ajout des logs pour déboguer

        setState(() {
          playlist = querySnapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }, onError: (e) {
        setState(() {});
      });

      _streamSubscriptions.add(streamSubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

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

          setState(() {
            followcha = enrichedChannels;
          });
        } else {
          setState(() {
            followcha = [];
          });
        }
      }, onError: (e) {
        setState(() {
          followcha = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        followcha = [];
      });
    }
  }

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
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
        setState(() {
          viewedPodcasts = tempViewedPodcasts;
          recommendedPodcasts = tempRecommendedPodcasts;
        });
      }, onError: (e) {
        setState(() {
          viewedPodcasts = [];
          recommendedPodcasts = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        viewedPodcasts = [];
        recommendedPodcasts = [];
      });
    }
  }

  List<Map<String, dynamic>> ress = [];
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
        setState(() {
          topl = enrichedPlaylists;
        });
      }, onError: (e) {
        setState(() {
          topl = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        topl = [];
      });
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

        setState(() {
          topcha = querySnapshot.docs
              // ignore: unnecessary_cast
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }, onError: (e) {
        setState(() {});
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {});
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
        setState(() {
          tops = enrichedPlaylists;
        });
      }, onError: (e) {
        setState(() {});
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {});
    }
  }

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
          Timestamp timevue = data['timevue'];
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

          setState(() {
            res = enrichedPlaylists;
          });
        } else {
          setState(() {
            res = [];
          });
        }
      }, onError: (e) {
        setState(() {
          res = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        res = [];
      });
    }
  }

  List<Map<String, dynamic>> res = [];
  List<Map<String, dynamic>> topl = [];
  List<Map<String, dynamic>> topcha = [];
  List<Map<String, dynamic>> tops = [];
  Future<void> fetchTrendingPodcasts() async {
    final DateTime sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7));
    final Timestamp timestampSevenDaysAgo = Timestamp.fromDate(sevenDaysAgo);

    try {
      // Création d'un stream à partir des vues récentes
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
          setState(() => ress = []);
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
        setState(() {
          ress = top10;
        });
      }, onError: (e) {
        setState(() => ress = []);
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() => ress = []);
    }
  }

  List<Map<String, dynamic>> pod = [];
  List<Map<String, dynamic>> podd = [];
  Future<void> fetchPodcastById(String ct) async {
    try {
      // Utilisation de snapshots() pour créer un stream
      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .where('category', isEqualTo: ct)
          .orderBy("dateCreation", descending: true)
          .snapshots()
          .listen((querySnapshot) async {
        // Convertir les documents en liste
        List<Map<String, dynamic>> podcasts = querySnapshot.docs
            // ignore: unnecessary_cast
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // Extraire tous les idUser uniques
        Set<String> channelIds = podcasts
            .map((pod) => pod['idUser'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toSet();

        // Récupérer les infos des channels par batchs
        Map<String, Map<String, dynamic>> channelsMap = {};
        List<String> idsList = channelIds.toList();

        for (int i = 0; i < idsList.length; i += 10) {
          int end = (i + 10 < idsList.length) ? i + 10 : idsList.length;
          List<String> batch = idsList.sublist(i, end);

          final channelsSnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batch)
              .get();

          for (var doc in channelsSnapshot.docs) {
            final data = doc.data();
            channelsMap[data['userId']] = data;
          }
        }

        // Associer chaque channel à son podcast
        for (var podcast in podcasts) {
          final idUser = podcast['idUser'];
          podcast['channel'] = channelsMap[idUser];
        }

        // Mettre à jour l'état
        setState(() {
          podd = podcasts;
        });
      }, onError: (e) {
        setState(() {
          podd = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        podd = [];
      });
    }
  }

  List<Map<String, dynamic>> craa = [];
  Future<void> fetchChannelsByPodcastCategory(String ct) async {
    try {
      // Créer un stream pour les podcasts de cette catégorie
      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .where('category', isEqualTo: ct)
          .snapshots()
          .listen((podcastSnapshot) async {
        // Extraire tous les idUser (chaînes), sans doublons
        Set<String> channelIds = podcastSnapshot.docs
            .map((doc) => doc.data()['idUser'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toSet();

        // Récupérer les channels correspondants (par batch si nécessaire)
        Map<String, Map<String, dynamic>> channelsMap = {};
        List<String> idsList = channelIds.toList();

        for (int i = 0; i < idsList.length; i += 10) {
          int end = (i + 10 < idsList.length) ? i + 10 : idsList.length;
          List<String> batch = idsList.sublist(i, end);

          final channelsSnapshot = await FirebaseFirestore.instance
              .collection('channels')
              .where('userId', whereIn: batch)
              .get();

          for (var doc in channelsSnapshot.docs) {
            final data = doc.data();
            channelsMap[data['userId']] = data;
          }
        }

        // Mettre à jour l'état avec les chaînes sans doublons
        setState(() {
          craa = channelsMap.values.toList();
        });
      }, onError: (e) {
        setState(() {
          craa = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        craa = [];
      });
    }
  }

  List<Map<String, dynamic>> play = [];
  Future<void> fetchPlaylistsByPodcastCategory(String ct) async {
    try {
      // Créer un stream pour les podcasts de cette catégorie
      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .where('category', isEqualTo: ct)
          .snapshots()
          .listen((podcastsSnapshot) async {
        List<String> podcastIds = podcastsSnapshot.docs
            .map((doc) => doc.data()['id'] as String?)
            .where((id) => id != null)
            .cast<String>()
            .toList();

        if (podcastIds.isEmpty) {
          setState(() {
            play = [];
          });

          return;
        }

        // Récupérer les playinpod avec podcastId in podcastIds (par batch)
        List<Map<String, dynamic>> playinpodDocs = [];

        for (int i = 0; i < podcastIds.length; i += 10) {
          int end = (i + 10 < podcastIds.length) ? i + 10 : podcastIds.length;
          List<String> batch = podcastIds.sublist(i, end);

          final playinpodSnapshot = await FirebaseFirestore.instance
              .collection('playinpod')
              .where('podcastId', whereIn: batch)
              .orderBy('date', descending: true)
              .get();

          playinpodDocs.addAll(playinpodSnapshot.docs.map((doc) => doc.data()));
        }

        // Extraire les playlistId sans doublons mais garder l'ordre
        List<String> orderedPlaylistIds = [];
        Set<String> seenIds = {};

        for (var item in playinpodDocs) {
          final pid = item['playlistId'] as String?;
          if (pid != null && !seenIds.contains(pid)) {
            seenIds.add(pid);
            orderedPlaylistIds.add(pid);
          }
        }

        if (orderedPlaylistIds.isEmpty) {
          setState(() {
            play = [];
          });

          return;
        }

        // Récupérer les documents playlists (par batch)
        Map<String, Map<String, dynamic>> playlistsMap = {};

        for (int i = 0; i < orderedPlaylistIds.length; i += 10) {
          int end = (i + 10 < orderedPlaylistIds.length)
              ? i + 10
              : orderedPlaylistIds.length;
          List<String> batch = orderedPlaylistIds.sublist(i, end);

          final playlistSnapshot = await FirebaseFirestore.instance
              .collection('playlist')
              .where('id', whereIn: batch)
              .get();

          for (var doc in playlistSnapshot.docs) {
            playlistsMap[doc.data()['id']] = doc.data();
          }
        }

        // Reconstituer la liste finale triée selon l'ordre de playinpod
        List<Map<String, dynamic>> finalPlaylists = orderedPlaylistIds
            .where((id) => playlistsMap.containsKey(id))
            .map((id) => playlistsMap[id]!)
            .toList();

        setState(() {
          play = finalPlaylists;
        });
      }, onError: (e) {
        setState(() {
          play = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        play = [];
      });
    }
  }

  List<Map<String, dynamic>> mesplaylist = [];
  Future<void> fetchmesPlaylistsId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('mesplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots()
          .listen((mesPlaylistSnapshot) async {
        List<Map<String, dynamic>> mesPlayInfos = [];
        for (var doc in mesPlaylistSnapshot.docs) {
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

          // Tri du plus récent au plus ancien
          allPlaylists.sort((a, b) {
            Timestamp? dateA = a['dateCreation'];
            Timestamp? dateB = b['dateCreation'];

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA);
          });

          setState(() {
            mesplaylist = allPlaylists;
          });
        } else {
          setState(() {
            mesplaylist = [];
          });
        }
      }, onError: (e) {
        setState(() {
          mesplaylist = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        mesplaylist = [];
      });
    }
  }

  late int nbr = 0;
  Future<void> nbrpodId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('myplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots()
          .listen((playinPodSnapshot) {
        // Réinitialiser le compteur à chaque mise à jour
        int tempNbr = 0;

        // Extraire la liste des playlistIds
        List<String> followIds = [];
        for (var doc in playinPodSnapshot.docs) {
          String followId = doc.data()['idpod'];
          if (!followIds.contains(followId)) {
            followIds.add(followId);
            tempNbr++;
          }
        }

        setState(() {
          nbr = tempNbr;
        });
      }, onError: (e) {
        setState(() {});
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {});
    }
  }

  List<Map<String, dynamic>> podcasts1 = [];
  List<Map<String, dynamic>> playlists1 = [];
  late int r = 1;
  String? ct;
  String? id;
  late int feat = 1;
  bool isLoading = true;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('ct')) {
          ct = arguments['ct'];
        }

        if (arguments.containsKey('r')) {
          r = arguments['r'];
        }
        if (arguments.containsKey('id')) {
          id = arguments['id'];
        }

        if (ct != null) {
          await fetchPodcastById(ct!);
          await fetchChannelsByPodcastCategory(ct!);
          await fetchPlaylistsByPodcastCategory(ct!);
        }
        if (id != null) {
          await fetchplaylists1(id!);
          await fetchPodcastsByChannelId(id!);
        }
        await fetchtopChannel();
        await fetchtopseen();
        await fetchtoppodcast();
        await fetchTrendingPodcasts();
        await fetchRecommendedPodcasts();
        await fetrecentId();
        await fetchfollowId();
        await fetchmesPlaylistsId();
        await nbrpodId();
        await fetchuser();
        await fetchpodcasts();
        await fetchplaylists();
      }
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isLoading = false);
    });
  }

  Future<void> fetchplaylists1(String id) async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('channels')
          .where('id', isEqualTo: id)
          .snapshots()
          .listen((channelSnapshot) async {
        if (channelSnapshot.docs.isEmpty) {
          setState(() {
            playlists1 = [];
          });
          return;
        }

        final channelData = channelSnapshot.docs.first.data();
        final String userId = channelData['userId'];

        // Créer un sous-stream pour les playlists
        final playlistStreamSubscription = FirebaseFirestore.instance
            .collection('playlist')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((podcastsSnapshot) {
          final List<Map<String, dynamic>> fetchedPodcasts =
              podcastsSnapshot.docs
                  // ignore: unnecessary_cast
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

          // Debug

          // Met à jour l'état
          setState(() {
            playlists1 = fetchedPodcasts;
          });
        }, onError: (e) {
          setState(() {
            playlists1 = [];
          });
        });

        _streamSubscriptions.add(playlistStreamSubscription);
      }, onError: (e) {
        setState(() {
          playlists1 = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        playlists1 = [];
      });
    }
  }

  Future<void> fetchPodcastsByChannelId(String id) async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('channels')
          .where('id', isEqualTo: id)
          .snapshots()
          .listen((channelSnapshot) async {
        if (channelSnapshot.docs.isEmpty) {
          setState(() {
            podcasts1 = [];
          });
          return;
        }

        final channelData = channelSnapshot.docs.first.data();
        final String userId = channelData['userId'];

        // Créer un sous-stream pour les podcasts
        final podcastStreamSubscription = FirebaseFirestore.instance
            .collection('podcasts')
            .where('idUser', isEqualTo: userId)
            .orderBy('dateCreation', descending: true)
            .snapshots()
            .listen((podcastsSnapshot) {
          final List<Map<String, dynamic>> fetchedPodcasts =
              podcastsSnapshot.docs
                  // ignore: unnecessary_cast
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();

          // Debug

          // Met à jour l'état
          setState(() {
            podcasts1 = fetchedPodcasts;
          });
        }, onError: (e) {
          setState(() {
            podcasts1 = [];
          });
        });

        _streamSubscriptions.add(podcastStreamSubscription);
      }, onError: (e) {
        setState(() {
          podcasts1 = [];
        });
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      setState(() {
        podcasts1 = [];
      });
    }
  }

  @override
  void dispose() {
    // Annuler tous les abonnements aux streams
    for (var subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();

    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size q = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
            child: isLoading
                ? const Annimationwidjet()
                : Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white,
                      ),
                      width:
                          double.infinity, // Added to provide width constraint
                      height:
                          double.infinity, // Added to provide height constraint

                      child: Column(children: [
                        SizedBox(
                          height: q.width * 0.15,
                          child: Stack(
                            children: [
                              Positioned(
                                top: q.height * 0.01,
                                left: q.width * 0.03,
                                child: IconButton(
                                  onPressed: () {
                                    if (r == 3 ||
                                        r == 4 ||
                                        r == 5 ||
                                        r == 6 ||
                                        r == 7 ||
                                        r == 8) {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/podly', (route) => false,
                                          arguments: {'selectedIndex': 0});
                                    }

                                    if (r == 9 || r == 10) {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/podly', (route) => false,
                                          arguments: {'selectedIndex': 3});
                                    }
// Ouvre dans Library
                                    if (r == 11) {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, '/podly', (route) => false,
                                          arguments: {'selectedIndex': 1});
                                    }
                                    if (r == 12) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/your',
                                        (route) => false,
                                      );
                                    }
                                    if (r == 13) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/your',
                                        (route) => false,
                                      );
                                    }
                                    if (r == 14) Navigator.pop(context);

                                    if (r == 15) Navigator.pop(context);
//vre dans Categories // Ouvre dans Categories
                                  },
                                  icon: Image.network(
                                    themeProvider.isDarkMode ? s97 : s18,
                                    width: q.width * 0.07,
                                    height: q.width * 0.07,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (r == 3)
                                  for (var item in res)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: q.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          )),
                                      width: q.width * 0.95,
                                      height: q.width * 0.3,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/podcast',
                                            arguments: {
                                              'idpod': item["id"],
                                              'feat':
                                                  4, // remplace "someValue" par ce que tu veux représenter
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: q.width * 0.01,
                                            ),
                                            Image.network(
                                              s48,
                                              width: q.width * 0.09,
                                              height: q.width * 0.09,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.03,
                                            ),
                                            Container(
                                              height: q.width * 0.2,
                                              width: q.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        q.width * 0.04),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      item["urlPhoto"]!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: q.width * 0.04),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    height: q.width * 0.06),
                                                SizedBox(
                                                  width: q.width * 0.25,
                                                  child: Text(
                                                    item["name"]!,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: q.width * 0.04,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: q.width * 0.01,
                                                ),
                                                Text(
                                                  item["channel"]["name"]!,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: q.width * 0.035,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: q.width * 0.05,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: q.width * 0.07,
                                                ),
                                                SizedBox(
                                                  width: q.width *
                                                      0.2, // Constrain the width of the progress bar
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: item[
                                                        "percent"], // 65% de progression
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                                Color>(
                                                            Color(0xFF754CEF)),
                                                    minHeight: 8,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${(item['percent'] * 100).toStringAsFixed(0)}%',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                if (r == 4)
                                  for (var item in recommendedPodcasts)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: q.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          )),
                                      width: q.width * 0.95,
                                      height: q.width * 0.3,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/podcast',
                                            arguments: {
                                              'idpod': item["id"],
                                              'feat':
                                                  5, // remplace "someValue" par ce que tu veux représenter
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: q.width * 0.01,
                                            ),
                                            Image.network(
                                              s48,
                                              width: q.width * 0.09,
                                              height: q.width * 0.09,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.03,
                                            ),
                                            Container(
                                              height: q.width * 0.2,
                                              width: q.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        q.width * 0.04),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      item["urlPhoto"]!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: q.width * 0.04),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    height: q.width * 0.06),
                                                SizedBox(
                                                  width: q.width * 0.25,
                                                  child: Text(
                                                    item["name"]!,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: q.width * 0.04,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: q.width * 0.01,
                                                ),
                                                Text(
                                                  item["channel"]["name"]!,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: q.width * 0.035,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: q.width * 0.05,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: q.width *
                                                        0.2, // Constrain the width of the progress bar
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "Category",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  q.width *
                                                                      0.035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          item["category"]!,
                                                          style: TextStyle(
                                                            fontSize:
                                                                q.width * 0.035,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                if (r == 5)
                                  for (var item in topcha)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: q.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          )),
                                      width: q.width * 0.95,
                                      height: q.width * 0.3,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (userId == item["userId"]) {
                                            Navigator.pushNamed(
                                                context, '/your',
                                                arguments: {'your': 2});
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
                                        child: Row(children: [
                                          SizedBox(
                                            width: q.width * 0.01,
                                          ),
                                          Container(
                                            height: q.width * 0.2,
                                            width: q.width * 0.2,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      q.width * 0.1),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    item["photoUrl"]!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: q.width * 0.04),
                                          SizedBox(height: q.width * 0.06),
                                          SizedBox(
                                            width: q.width * 0.45,
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
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  width: q.width *
                                                      0.2, // Constrain the width of the progress bar
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Followers",
                                                        style: TextStyle(
                                                            fontSize:
                                                                q.width * 0.035,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        formatLikes(
                                                            item["followers"]!),
                                                        style: TextStyle(
                                                          fontSize:
                                                              q.width * 0.035,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ]),
                                      ),
                                    ),
                                if (r == 6)
                                  for (var item in ress)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: q.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          )),
                                      width: q.width * 0.95,
                                      height: q.width * 0.3,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/podcast',
                                            arguments: {
                                              'idpod': item["id"],
                                              'feat':
                                                  6, // remplace "someValue" par ce que tu veux représenter
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: q.width * 0.01,
                                            ),
                                            Image.network(
                                              s48,
                                              width: q.width * 0.09,
                                              height: q.width * 0.09,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.03,
                                            ),
                                            Container(
                                              height: q.width * 0.2,
                                              width: q.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        q.width * 0.04),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      item["urlPhoto"]!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: q.width * 0.04),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    height: q.width * 0.06),
                                                SizedBox(
                                                  width: q.width * 0.25,
                                                  child: Text(
                                                    item["name"]!,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: q.width * 0.04,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: q.width * 0.01,
                                                ),
                                                Text(
                                                  item["channel"]["name"]!,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: q.width * 0.035,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: q.width * 0.09,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: q.width *
                                                        0.2, // Constrain the width of the progress bar
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.05,
                                                              height: q.width *
                                                                  0.05,
                                                              child:
                                                                  Image.network(
                                                                themeProvider
                                                                        .isDarkMode
                                                                    ? s111
                                                                    : s37,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.01,
                                                            ),
                                                            Text(
                                                              formatLikes(item[
                                                                  "likes"]!),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      q.width *
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
                                                              q.width * 0.02,
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.05,
                                                              height: q.width *
                                                                  0.05,
                                                              child:
                                                                  Image.network(
                                                                themeProvider
                                                                        .isDarkMode
                                                                    ? s108
                                                                    : s14,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.01,
                                                            ),
                                                            Text(
                                                              formatLikes(
                                                                  item["vue"]!),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      q.width *
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
                                    ),
                                if (r == 7)
                                  for (var item in topl)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: q.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          )),
                                      width: q.width * 0.95,
                                      height: q.width * 0.3,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/podcast',
                                            arguments: {
                                              'idpod': item["id"],
                                              'feat':
                                                  7, // remplace "someValue" par ce que tu veux représenter
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: q.width * 0.01,
                                            ),
                                            Image.network(
                                              s48,
                                              width: q.width * 0.09,
                                              height: q.width * 0.09,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.03,
                                            ),
                                            Container(
                                              height: q.width * 0.2,
                                              width: q.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        q.width * 0.04),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      item["urlPhoto"]!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: q.width * 0.04),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    height: q.width * 0.06),
                                                SizedBox(
                                                  width: q.width * 0.25,
                                                  child: Text(
                                                    item["name"]!,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: q.width * 0.04,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: q.width * 0.01,
                                                ),
                                                Text(
                                                  item["channel"]["name"]!,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: q.width * 0.035,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: q.width * 0.09,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: q.width *
                                                        0.2, // Constrain the width of the progress bar
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.05,
                                                              height: q.width *
                                                                  0.05,
                                                              child:
                                                                  Image.network(
                                                                themeProvider
                                                                        .isDarkMode
                                                                    ? s111
                                                                    : s37,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.01,
                                                            ),
                                                            Text(
                                                              formatLikes(item[
                                                                  "likes"]!),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      q.width *
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
                                    ),
                                if (r == 8)
                                  for (var item in tops)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: q.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          )),
                                      width: q.width * 0.95,
                                      height: q.width * 0.3,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/podcast',
                                            arguments: {
                                              'idpod': item["id"],
                                              'feat':
                                                  8, // remplace "someValue" par ce que tu veux représenter
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: q.width * 0.01,
                                            ),
                                            Image.network(
                                              s48,
                                              width: q.width * 0.09,
                                              height: q.width * 0.09,
                                              fit: BoxFit.cover,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.03,
                                            ),
                                            Container(
                                              height: q.width * 0.2,
                                              width: q.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        q.width * 0.04),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      item["urlPhoto"]!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: q.width * 0.04),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                    height: q.width * 0.06),
                                                SizedBox(
                                                  width: q.width * 0.25,
                                                  child: Text(
                                                    item["name"]!,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: q.width * 0.04,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: q.width * 0.01,
                                                ),
                                                Text(
                                                  item["channel"]["name"]!,
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: q.width * 0.035,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: q.width * 0.09,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: q.width *
                                                        0.2, // Constrain the width of the progress bar
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.05,
                                                              height: q.width *
                                                                  0.05,
                                                              child:
                                                                  Image.network(
                                                                themeProvider
                                                                        .isDarkMode
                                                                    ? s108
                                                                    : s14,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: q.width *
                                                                  0.01,
                                                            ),
                                                            Text(
                                                              formatLikes(
                                                                  item["vue"]!),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      q.width *
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
                                    ),
                                if (r == 9)
                                  for (var item in followcha)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: q.width * 0.02),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
                                          border: Border.all(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white70
                                                : Colors.black12,
                                          )),
                                      width: q.width * 0.95,
                                      height: q.width * 0.3,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/channel',
                                            arguments: {
                                              'id': item["id"],
                                              'chaine': 3,
                                            },
                                          );
                                        },
                                        child: Row(children: [
                                          SizedBox(
                                            width: q.width * 0.01,
                                          ),
                                          Container(
                                            height: q.width * 0.2,
                                            width: q.width * 0.2,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      q.width * 0.1),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    item["photoUrl"]!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: q.width * 0.04),
                                          SizedBox(height: q.width * 0.06),
                                          SizedBox(
                                            width: q.width * 0.45,
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
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  width: q.width *
                                                      0.2, // Constrain the width of the progress bar
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Followers",
                                                        style: TextStyle(
                                                            fontSize:
                                                                q.width * 0.035,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        formatLikes(
                                                            item["followers"]!),
                                                        style: TextStyle(
                                                          fontSize:
                                                              q.width * 0.035,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ]),
                                      ),
                                    ),
                                if (r == 10) ...[
                                  // En-tête Favorite Playlist
                                  SizedBox(
                                    height: q.height * 0.15,
                                    child: Container(
                                      margin: EdgeInsets.all(q.width * 0.02),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            q.width * 0.05),
                                        border: Border.all(
                                          color: themeProvider.isDarkMode
                                              ? Colors.white70
                                              : Colors.black12,
                                        ),
                                      ),
                                      width: q.width * 0.95,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/your1');
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(width: q.width * 0.01),
                                            Container(
                                              height: q.width * 0.2,
                                              width: q.width * 0.2,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        q.width * 0.04),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      user[0]["photoUrl"]!),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: q.width * 0.04),
                                            SizedBox(
                                              width: q.width * 0.4,
                                              child: Text(
                                                "My Playlist",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: q.width * 0.04,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: q.width * 0.01),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  formatLikes(nbr),
                                                  style: TextStyle(
                                                      fontSize:
                                                          q.width * 0.035),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  "Podcasts",
                                                  style: TextStyle(
                                                      fontSize:
                                                          q.width * 0.035),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Playlist tab (ListView.builder inside ScrollView)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: mesplaylist.length,
                                    itemBuilder: (context, index) {
                                      final item = mesplaylist[index];
                                      return Container(
                                        margin: EdgeInsets.all(q.width * 0.02),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              q.width * 0.05),
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
                                            Navigator.pushNamed(
                                              context,
                                              '/play',
                                              arguments: {
                                                'idplay': item["id"],
                                                'pp': 2,
                                              },
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              SizedBox(width: q.width * 0.01),
                                              Container(
                                                height: q.width * 0.25,
                                                width: q.width * 0.25,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          q.width * 0.04),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        item["photoUrl"]!),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: q.width * 0.04),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                      height: q.width * 0.02),
                                                  SizedBox(
                                                    width: q.width * 0.3,
                                                    child: Text(
                                                      item["name"]!,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            q.width * 0.04,
                                                      ),
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: q.width * 0.03),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: q.width * 0.19,
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          formatLikes(
                                                              item["podcast"]!),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  q.width *
                                                                      0.035),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          "Podcast",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  q.width *
                                                                      0.035),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                if (r == 11) ...[
                                  TabBar(
                                    controller: _tabController,
                                    labelColor: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    unselectedLabelColor: Colors.grey,
                                    indicatorColor: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    tabs: const [
                                      Tab(text: 'Podcast'),
                                      Tab(text: 'Channel'),
                                      Tab(text: 'Playlist'),
                                    ],
                                  ),
                                  // Remplacez Expanded par un SizedBox avec une hauteur fixe
                                  SizedBox(
                                    height: MediaQuery.of(context)
                                        .size
                                        .height, // Ajustez la hauteur selon vos besoins
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        // Contenu pour l'onglet Podcast
                                        if (podd.isNotEmpty) ...[
                                          ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: podd.length,
                                            itemBuilder: (context, index) {
                                              final item = podd[index];
                                              return Container(
                                                margin: EdgeInsets.all(
                                                    q.width * 0.02),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          q.width * 0.05),
                                                  border: Border.all(
                                                    color:
                                                        themeProvider.isDarkMode
                                                            ? Colors.white70
                                                            : Colors.black12,
                                                  ),
                                                ),
                                                width: q.width * 0.95,
                                                height: q.width * 0.3,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/podcast',
                                                      arguments: {
                                                        'idpod': item["id"],
                                                        'feat': 9,
                                                      },
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                          width:
                                                              q.width * 0.01),
                                                      Image.network(
                                                        s48,
                                                        width: q.width * 0.09,
                                                        height: q.width * 0.09,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              q.width * 0.03),
                                                      Container(
                                                        height: q.width * 0.2,
                                                        width: q.width * 0.2,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      q.width *
                                                                          0.04),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                item[
                                                                    "urlPhoto"]!),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              q.width * 0.04),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                              height: q.width *
                                                                  0.06),
                                                          SizedBox(
                                                            width:
                                                                q.width * 0.4,
                                                            child: Text(
                                                              item["name"]!,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    q.width *
                                                                        0.04,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              height: q.width *
                                                                  0.01),
                                                          Text(
                                                            item["channel"]
                                                                ["name"]!,
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize:
                                                                  q.width *
                                                                      0.035,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                        if (podd.isEmpty) ...[
                                          Column(children: [
                                            SizedBox(
                                              height: q.height * 0.1,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.8,
                                              height: q.height * 0.3,
                                              child: Image.network(
                                                  themeProvider.isDarkMode
                                                      ? s109
                                                      : s28),
                                            ),
                                            Text("Not Yet",
                                                style: TextStyle(
                                                    fontSize: q.width * 0.04,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ])
                                        ],
                                        if (craa.isNotEmpty) ...[
                                          ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: craa.length,
                                            itemBuilder: (context, index) {
                                              final item = craa[index];
                                              return Container(
                                                margin: EdgeInsets.all(
                                                    q.width * 0.02),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          q.width * 0.05),
                                                  border: Border.all(
                                                    color:
                                                        themeProvider.isDarkMode
                                                            ? Colors.white70
                                                            : Colors.black12,
                                                  ),
                                                ),
                                                width: q.width * 0.95,
                                                height: q.width * 0.3,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (userId ==
                                                        item["userId"]) {
                                                      Navigator.pushNamed(
                                                          context, '/your',
                                                          arguments: {
                                                            'your': 3
                                                          });
                                                    }
                                                    if (userId !=
                                                        item["userId"]) {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/channel',
                                                        arguments: {
                                                          'id': item["id"],
                                                          'chaine': 4,
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                          width:
                                                              q.width * 0.01),
                                                      Container(
                                                        height: q.width * 0.2,
                                                        width: q.width * 0.2,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      q.width *
                                                                          0.1),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                item[
                                                                    "photoUrl"]!),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              q.width * 0.04),
                                                      SizedBox(
                                                          height:
                                                              q.width * 0.06),
                                                      SizedBox(
                                                        width: q.width * 0.45,
                                                        child: Text(
                                                          item["name"]!,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                q.width * 0.04,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                q.width * 0.2,
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  "Followers",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        q.width *
                                                                            0.035,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  formatLikes(item[
                                                                      "followers"]!),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        q.width *
                                                                            0.035,
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                        if (craa.isEmpty) ...[
                                          Column(children: [
                                            SizedBox(
                                              height: q.height * 0.1,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.8,
                                              height: q.height * 0.3,
                                              child: Image.network(
                                                  themeProvider.isDarkMode
                                                      ? s109
                                                      : s28),
                                            ),
                                            Text("Not Yet",
                                                style: TextStyle(
                                                    fontSize: q.width * 0.04,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ])
                                        ],
                                        if (play.isNotEmpty) ...[
                                          ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            itemCount: play.length,
                                            itemBuilder: (context, index) {
                                              final item = play[index];
                                              return Container(
                                                margin: EdgeInsets.all(
                                                    q.width * 0.02),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            q.width * 0.05),
                                                    border: Border.all(
                                                      color: themeProvider
                                                              .isDarkMode
                                                          ? Colors.white70
                                                          : Colors.black12,
                                                    )),
                                                width: q.width * 0.95,
                                                height: q.width * 0.3,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context, '/play',
                                                        arguments: {
                                                          'idplay': item["id"],
                                                          'pp': 4
                                                        });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: q.width * 0.01,
                                                      ),
                                                      Container(
                                                        height: q.width * 0.25,
                                                        width: q.width * 0.25,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      q.width *
                                                                          0.04),
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                item[
                                                                    "photoUrl"]!),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              q.width * 0.04),
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                              height: q.width *
                                                                  0.02),
                                                          SizedBox(
                                                            width:
                                                                q.width * 0.3,
                                                            child: Text(
                                                              item["name"]!,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize:
                                                                    q.width *
                                                                        0.04,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: q.width * 0.04,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                              width: q.width *
                                                                  0.2, // Constrain the width of the progress bar
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height:
                                                                        q.width *
                                                                            0.02,
                                                                  ),
                                                                  Text(
                                                                    "Podcasts",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          q.width *
                                                                              0.035,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    formatLikes(
                                                                        item[
                                                                            "podcast"]!),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          q.width *
                                                                              0.035,
                                                                    ),
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                        ],
                                        if (play.isEmpty) ...[
                                          Column(children: [
                                            SizedBox(
                                              height: q.height * 0.1,
                                            ),
                                            SizedBox(
                                              width: q.width * 0.8,
                                              height: q.height * 0.3,
                                              child: Image.network(
                                                  themeProvider.isDarkMode
                                                      ? s109
                                                      : s28),
                                            ),
                                            Text("Not Yet",
                                                style: TextStyle(
                                                    fontSize: q.width * 0.04,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ])
                                        ],

                                        // Contenu pour l'onglet Channel
                                      ],
                                    ),
                                  ),
                                ],
                                if (r == 12) ...[
                                  SizedBox(
                                    height: q.height,
                                    child: ListView.builder(
                                      itemCount: podcast.length,
                                      itemBuilder: (context, index) {
                                        final item = podcast[index];
                                        return Container(
                                          margin:
                                              EdgeInsets.all(q.width * 0.02),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                q.width * 0.05),
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
                                                SizedBox(width: q.width * 0.01),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            q.width * 0.04),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          item["urlPhoto"]!),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: q.width * 0.02),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        height: q.width * 0.0),
                                                    SizedBox(
                                                      width: q.width * 0.35,
                                                      child: Text(
                                                        item["name"]!,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              q.width * 0.04,
                                                        ),
                                                        maxLines: 4,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: q.width * 0.01),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: q.width * 0.05,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        width: q.width *
                                                            0.2, // Constrain the width of the progress bar
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      q.width *
                                                                          0.05,
                                                                  height:
                                                                      q.width *
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
                                                                  width:
                                                                      q.width *
                                                                          0.01,
                                                                ),
                                                                Text(
                                                                  formatLikes(item[
                                                                      "likes"]!),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          q.width *
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
                                                              height: q.width *
                                                                  0.02,
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      q.width *
                                                                          0.05,
                                                                  height:
                                                                      q.width *
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
                                                                  width:
                                                                      q.width *
                                                                          0.01,
                                                                ),
                                                                Text(
                                                                  formatLikes(item[
                                                                      "vue"]!),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          q.width *
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
                                                              height: q.width *
                                                                  0.02,
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      q.width *
                                                                          0.05,
                                                                  height:
                                                                      q.width *
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
                                                                  width:
                                                                      q.width *
                                                                          0.01,
                                                                ),
                                                                Text(
                                                                  formatLikes(item[
                                                                      "comments"]!),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          q.width *
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
                                if (r == 13) ...[
                                  SizedBox(
                                    height: q.height,
                                    child: // Playlist tab
                                        ListView.builder(
                                      itemCount: playlist.length,
                                      itemBuilder: (context, index) {
                                        final item = playlist[index];
                                        return Container(
                                            margin:
                                                EdgeInsets.all(q.width * 0.02),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      q.width * 0.05),
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
                                                Navigator.pushNamed(
                                                    context, '/play',
                                                    arguments: {
                                                      'idplay': item["id"],
                                                      'pp': 3
                                                    });
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              q.width * 0.04),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            item["photoUrl"]!),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: q.width * 0.04),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                          height:
                                                              q.width * 0.02),
                                                      SizedBox(
                                                        width: q.width * 0.3,
                                                        child: Text(
                                                          item["name"]!,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                q.width * 0.04,
                                                          ),
                                                          maxLines: 4,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: q.width * 0.04,
                                                  ),
                                                  Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                            width: q.width *
                                                                0.2, // Constrain the width of the progress bar
                                                            child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height:
                                                                        q.width *
                                                                            0.02,
                                                                  ),
                                                                  Column(
                                                                      children: [
                                                                        Text(
                                                                          formatLikes(
                                                                              item["podcast"]!),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                q.width * 0.035,
                                                                          ),
                                                                          maxLines:
                                                                              4,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              q.width * 0.03,
                                                                        ),
                                                                        Text(
                                                                          "Podcast",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                q.width * 0.035,
                                                                          ),
                                                                          maxLines:
                                                                              4,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ])
                                                                ]))
                                                      ])
                                                ],
                                              ),
                                            ));
                                      },
                                    ),
                                  ),
                                ],
                                if (r == 14) ...[
                                  SizedBox(
                                    height: q.height,
                                    child: ListView.builder(
                                      itemCount: podcasts1.length,
                                      itemBuilder: (context, index) {
                                        final item = podcasts1[index];
                                        return Container(
                                          margin:
                                              EdgeInsets.all(q.width * 0.02),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                q.width * 0.05),
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
                                              Navigator.pushNamed(
                                                context,
                                                '/podcast',
                                                arguments: {
                                                  'idpod': item["id"],
                                                  'feat': 12,
                                                }, // Envoie l'ID
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(width: q.width * 0.01),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            q.width * 0.04),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          item["urlPhoto"]!),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: q.width * 0.02),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        height: q.width * 0.0),
                                                    SizedBox(
                                                      width: q.width * 0.35,
                                                      child: Text(
                                                        item["name"]!,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              q.width * 0.04,
                                                        ),
                                                        maxLines: 4,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: q.width * 0.01),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: q.width * 0.05,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                        width: q.width *
                                                            0.2, // Constrain the width of the progress bar
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      q.width *
                                                                          0.05,
                                                                  height:
                                                                      q.width *
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
                                                                  width:
                                                                      q.width *
                                                                          0.01,
                                                                ),
                                                                Text(
                                                                  formatLikes(item[
                                                                      "likes"]!),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          q.width *
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
                                                              height: q.width *
                                                                  0.02,
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      q.width *
                                                                          0.05,
                                                                  height:
                                                                      q.width *
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
                                                                  width:
                                                                      q.width *
                                                                          0.01,
                                                                ),
                                                                Text(
                                                                  formatLikes(item[
                                                                      "vue"]!),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          q.width *
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
                                                              height: q.width *
                                                                  0.02,
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      q.width *
                                                                          0.05,
                                                                  height:
                                                                      q.width *
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
                                                                  width:
                                                                      q.width *
                                                                          0.01,
                                                                ),
                                                                Text(
                                                                  formatLikes(item[
                                                                      "comments"]!),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          q.width *
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
                                if (r == 15) ...[
                                  SizedBox(
                                    height: q.height,
                                    child: // Playlist tab
                                        ListView.builder(
                                      itemCount: playlists1.length,
                                      itemBuilder: (context, index) {
                                        final item = playlists1[index];
                                        return Container(
                                            margin:
                                                EdgeInsets.all(q.width * 0.02),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      q.width * 0.05),
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
                                                Navigator.pushNamed(
                                                    context, '/play',
                                                    arguments: {
                                                      'idplay': item["id"],
                                                      'pp': 5
                                                    });
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
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              q.width * 0.04),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            item["photoUrl"]!),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: q.width * 0.04),
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                          height:
                                                              q.width * 0.02),
                                                      SizedBox(
                                                        width: q.width * 0.3,
                                                        child: Text(
                                                          item["name"]!,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                q.width * 0.04,
                                                          ),
                                                          maxLines: 4,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    width: q.width * 0.04,
                                                  ),
                                                  Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                            width: q.width *
                                                                0.2, // Constrain the width of the progress bar
                                                            child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height:
                                                                        q.width *
                                                                            0.02,
                                                                  ),
                                                                  Column(
                                                                      children: [
                                                                        Text(
                                                                          formatLikes(
                                                                              item["podcast"]!),
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                q.width * 0.035,
                                                                          ),
                                                                          maxLines:
                                                                              4,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              q.width * 0.03,
                                                                        ),
                                                                        Text(
                                                                          "Podcast",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                q.width * 0.035,
                                                                          ),
                                                                          maxLines:
                                                                              4,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ])
                                                                ]))
                                                      ])
                                                ],
                                              ),
                                            ));
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ]),
                    );
                  })));
  }
}
