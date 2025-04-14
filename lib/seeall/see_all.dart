import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/constants.dart';

class SeeAllpage extends StatefulWidget {
  const SeeAllpage({super.key});

  @override
  State<SeeAllpage> createState() => _SeeAllpagepageState();
}

class _SeeAllpagepageState extends State<SeeAllpage>
    with SingleTickerProviderStateMixin {
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

  List<Map<String, dynamic>> followcha = [];
  Future<void> fetchfollowId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // 1️⃣ Récupérer les follow triés par dateCreation DESC
      final followSnapshot = await FirebaseFirestore.instance
          .collection('follow')
          .where('idfollowers', isEqualTo: currentUserId)
          .orderBy('dateCreation', descending: true)
          .get();

      // 2️⃣ Construire une liste ordonnée de followings avec dateCreation
      List<Map<String, dynamic>> followList = [];
      for (var doc in followSnapshot.docs) {
        final data = doc.data();
        String idFollowing = data['idfollowing'];
        Timestamp dateCreation = data['dateCreation'];

        if (!followList.any((f) => f['idfollowing'] == idFollowing)) {
          followList
              .add({'idfollowing': idFollowing, 'dateCreation': dateCreation});
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
          channel['dateCreationFollow'] = match['dateCreation']; // important !
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

        debugPrint("Channels suivis récupérés : ${followcha.length}");
      } else {
        setState(() {
          followcha = [];
        });
        debugPrint("Aucun channel suivi.");
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des channels suivis: $e");
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
      final viewedPodsSnapshot = await FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // 2. Extraire les IDs des podcasts vus
      List<String> viewedPodcastIds = viewedPodsSnapshot.docs
          .map((doc) => doc.data()['idpod'] as String)
          .toList();

      debugPrint(
          "🔎 Podcasts vus (${viewedPodcastIds.length}) : $viewedPodcastIds");

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

      debugPrint(
          "📁 Catégories extraites (${categories.length}) : $categories");

      if (categories.isEmpty) {
        setState(() {
          viewedPodcasts = [];
          recommendedPodcasts = [];
        });
        debugPrint("Aucune catégorie trouvée pour les podcasts vus.");
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

      debugPrint(
          "✅ Détails des podcasts vus récupérés : ${tempViewedPodcasts.length}");

      // 5. Récupérer les podcasts recommandés
      List<Map<String, dynamic>> tempRecommendedPodcasts = [];

      for (String category in categories) {
        final recommendedSnapshot = await FirebaseFirestore.instance
            .collection('podcasts')
            .where('category', isEqualTo: category)
            .orderBy('dateCreation', descending: true)
            .limit(10)
            .get();

        debugPrint(
            "📦 Candidats dans '$category' : ${recommendedSnapshot.docs.length}");

        for (var doc in recommendedSnapshot.docs) {
          final data = doc.data();
          final id = data['id']?.toString();
          if (id == null) {
            debugPrint("⚠️ Podcast sans ID → ignoré");
            continue;
          }

          if (!viewedPodcastIds.contains(id)) {
            debugPrint("✅ Ajouté aux recommandations: $id");
            tempRecommendedPodcasts.add(data);
          } else {
            debugPrint("⛔ Déjà vu, ignoré: $id");
          }
        }
      }

      debugPrint(
          "✨ Podcasts recommandés retenus : ${tempRecommendedPodcasts.length}");

      // 6. Récupérer les infos des channels
      Set<String> allChannelIds = {};

      for (var podcast in [...tempViewedPodcasts, ...tempRecommendedPodcasts]) {
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

      debugPrint(
          "🎯 Podcasts vus: ${viewedPodcasts.length}, recommandations: ${recommendedPodcasts.length}");
    } catch (e) {
      debugPrint("❌ Erreur fetchRecommendedPodcasts: $e");
      setState(() {
        viewedPodcasts = [];
        recommendedPodcasts = [];
      });
    }
  }

  List<Map<String, dynamic>> ress = [];
  Future<void> fetchtoppodcast() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy("likes", descending: true)
          .limit(10)
          .get();

// Étape 1 : Extraire les données des podcasts
      final allPlaylists = querySnapshot.docs
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
    } catch (e) {
      debugPrint("Erreur lors de la récupération des playlists: $e");
      setState(() {
        topl = [];
      });
    }
  }

  Future<void> fetchtopChannel() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('channels')
          .orderBy("followers", descending: true)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de chaînes trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des chaînes : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        topcha = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {});
    }
  }

  Future<void> fetchtopseen() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .orderBy("vue", descending: true)
          .limit(10)
          .get();

// Étape 1 : Extraire les données des podcasts
      final allPlaylists = querySnapshot.docs
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
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {});
    }
  }

  Future<void> fetrecentId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // 🔁 Étape 1 : Récupérer les vues triées par timevue ASC
      final playinPodSnapshot = await FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('timevue', descending: false)
          .get();

      // 🔁 Étape 2 : Liste ordonnée d’idpod avec timevue + percent
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

        debugPrint("Playlists enrichies: ${res.length}");
      } else {
        setState(() {
          res = [];
        });
        debugPrint("Aucune playlist trouvée pour ce podcast");
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des playlists: $e");
      setState(() {
        res = [];
      });
    }
  }

  List<Map<String, dynamic>> res = [];
  List<Map<String, dynamic>> topl = [];
  List<Map<String, dynamic>> topcha = [];
  List<Map<String, dynamic>> tops = [];
  final List<Map<String, String>> poda = [
    {
      "img": "images/qq.png",
      "tit": "The Joe Rogen..JJJJJ",
      "cat": "music",
      "like": "100K",
      "view": "4k",
      "com": "400",
    },
    {
      "img": "images/ss.png",
      "tit": "Needs A Freinds",
      "cat": "music",
      "like": "900",
      "view": "3.8k",
      "com": "400",
    },
    {
      "img": "images/dd.png",
      "tit": "Follow Your Dream",
      "cat": "music",
      "like": "700",
      "view": "3.2k",
      "com": "400",
    },
    {
      "img": "images/a.png",
      "tit": "The Joe Rogen...",
      "cat": "music",
      "like": "500",
      "view": "2.8k",
      "com": "400",
    },
    {
      "img": "images/b.png",
      "tit": "The Joe Rogen...",
      "cat": "music",
      "like": "200",
      "view": "1k",
      "com": "400",
    },
  ];
  Future<void> fetchTrendingPodcasts() async {
    final DateTime sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
    final Timestamp timestampSevenDaysAgo = Timestamp.fromDate(sevenDaysAgo);

    try {
      // 1️⃣ Récupérer les vues des 7 derniers jours
      final recentViewsSnapshot = await FirebaseFirestore.instance
          .collection('vues')
          .where('timevue', isGreaterThan: timestampSevenDaysAgo)
          .get();

      // 2️⃣ Récupérer tous les idpod uniques
      Set<String> recentIdPods = recentViewsSnapshot.docs
          .map((doc) => doc.data()['idpod'] as String)
          .toSet();

      if (recentIdPods.isEmpty) {
        debugPrint("❌ Aucun podcast vu récemment.");
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
      matchingPodcasts.sort((a, b) => (b['vue'] ?? 0).compareTo(a['vue'] ?? 0));

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

      // 🔁 Mettre à jour l’état
      setState(() {
        ress = top10;
      });

      debugPrint("🔥 Trending podcasts récupérés: ${top10.length}");
    } catch (e) {
      debugPrint("❌ Erreur fetchTrendingPodcasts: $e");
      setState(() => ress = []);
    }
  }

  List<Map<String, dynamic>> pod = [];
  List<Map<String, dynamic>> podd = [];
  Future<void> fetchPodcastById(String ct) async {
    try {
      // 1. Récupérer les podcasts par catégorie
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('category', isEqualTo: ct)
          .orderBy("dateCreation", descending: true)
          .get();

      // 2. Convertir les documents en liste
      List<Map<String, dynamic>> podcasts = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      debugPrint("📦 Podcasts récupérés : ${podcasts.length}");

      // 3. Extraire tous les idUser uniques
      Set<String> channelIds = podcasts
          .map((pod) => pod['idUser'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      debugPrint("👤 Channels à récupérer : ${channelIds.length}");

      // 4. Récupérer les infos des channels par batchs (si trop nombreux)
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

      // 5. Associer chaque channel à son podcast
      for (var podcast in podcasts) {
        final idUser = podcast['idUser'];
        podcast['channel'] = channelsMap[idUser];
      }

      // 6. Mettre à jour l'état
      setState(() {
        podd = podcasts;
      });

      debugPrint("✅ Podcasts enrichis avec channels : ${podd.length}");
    } catch (e) {
      debugPrint("❌ Erreur lors du chargement des podcasts : $e");
    }
  }

  final List<Map<String, String>> cra = [
    {
      "img": "images/d.png",
      "tite": "Younes cccccccccccc",
      "fol": "275K",
    },
    {
      "img": "images/e.png",
      "tite": "ALi",
      "fol": "150k",
    },
    {
      "img": "images/f.png",
      "tite": "Abderahmne",
      "fol": "100K",
    },
    {"img": "images/g.png", "tite": "Mohammed", "fol": "37K"},
    {"img": "images/h.png", "tite": "Amine", "fol": "22K"},
  ];
  List<Map<String, dynamic>> craa = [];
  Future<void> fetchChannelsByPodcastCategory(String ct) async {
    try {
      // 1. Récupérer tous les podcasts de cette catégorie
      final podcastSnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('category', isEqualTo: ct)
          .get();

      // 2. Extraire tous les idUser (chaînes), sans doublons
      Set<String> channelIds = podcastSnapshot.docs
          .map((doc) => doc.data()['idUser'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet();

      debugPrint(
          "🔎 Channels trouvés dans la catégorie '$ct' : ${channelIds.length}");

      // 3. Récupérer les channels correspondants (par batch si nécessaire)
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

      // 4. Mettre à jour ton état avec les chaînes sans doublons
      setState(() {
        craa = channelsMap.values
            .toList(); // <-- contient une seule fois chaque chaîne
      });

      debugPrint(
          "✅ Chaînes uniques avec au moins un podcast dans '$ct' : ${craa.length}");
    } catch (e) {
      debugPrint("❌ Erreur fetchChannelsByPodcastCategory : $e");
    }
  }

  List<Map<String, dynamic>> play = [];
  Future<void> fetchPlaylistsByPodcastCategory(String ct) async {
    try {
      // 1. Récupérer les podcasts avec catégorie = ct
      final podcastsSnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('category', isEqualTo: ct)
          .get();

      List<String> podcastIds = podcastsSnapshot.docs
          .map((doc) => doc.data()['id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      debugPrint("🎧 Podcasts de la catégorie '$ct' : ${podcastIds.length}");

      if (podcastIds.isEmpty) {
        setState(() {
          play = [];
        });
        debugPrint("⚠️ Aucun podcast trouvé pour la catégorie '$ct'");
        return;
      }

      // 2. Récupérer les playinpod avec podcastId in podcastIds (par batch)
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

      debugPrint("🔗 Liens playlist-podcast trouvés : ${playinpodDocs.length}");

      // 3. Extraire les playlistId sans doublons mais garder l'ordre
      List<String> orderedPlaylistIds = [];
      Set<String> seenIds = {};

      for (var item in playinpodDocs) {
        final pid = item['playlistId'] as String?;
        if (pid != null && !seenIds.contains(pid)) {
          seenIds.add(pid);
          orderedPlaylistIds.add(pid);
        }
      }

      debugPrint(
          "📚 Playlists uniques extraites : ${orderedPlaylistIds.length}");

      if (orderedPlaylistIds.isEmpty) {
        setState(() {
          play = [];
        });
        debugPrint("⚠️ Aucune playlist associée trouvée.");
        return;
      }

      // 4. Récupérer les documents playlists (par batch)
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

      // 5. Reconstituer la liste finale triée selon l’ordre de playinpod
      List<Map<String, dynamic>> finalPlaylists = orderedPlaylistIds
          .where((id) => playlistsMap.containsKey(id))
          .map((id) => playlistsMap[id]!)
          .toList();

      setState(() {
        play = finalPlaylists;
      });

      debugPrint("✅ Playlists finales affichées : ${play.length}");
    } catch (e) {
      debugPrint("❌ Erreur fetchPlaylistsByPodcastCategory : $e");
      setState(() {
        play = [];
      });
    }
  }

  final List<Map<String, String>> cre = [
    {"img": "images/w.png", "tite": "Younes", "fol": "100K"},
    {"img": "images/x.png", "tite": "ALi", "fol": "100K"},
    {"img": "images/v.png", "tite": "Abderahmne", "fol": "100K"},
    {"img": "images/n.png", "tite": "Mohammed", "fol": "100K"},
    {"img": "images/l.png", "tite": "Amine", "fol": "100K"},
  ];
  List<Map<String, String>> combinedList = [];

  late int r = 1;
  String? ct;
  late int feat = 1;
  bool isLoading = true;
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

        if (ct != null) {
          await fetchPodcastById(ct!);
          await fetchChannelsByPodcastCategory(ct!);
          await fetchPlaylistsByPodcastCategory(ct!);
        }
        await fetchtopChannel();
        await fetchtopseen();
        await fetchtoppodcast();
        await fetchTrendingPodcasts();
        await fetchRecommendedPodcasts();
        await fetrecentId();
        await fetchfollowId();
      }

      setState(() => isLoading = false);
    });
  }

  late TabController _tabController;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size q = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
            child: Container(
      width: double.infinity, // Added to provide width constraint
      height: double.infinity, // Added to provide height constraint
      decoration: const BoxDecoration(color: Colors.white),
      child: isLoading
          ? Center(child: Text(""))
          : Column(children: [
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
                              r == 8)
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/podly', (route) => false,
                                arguments: {'selectedIndex': 0});

                          if (r == 9 || r == 10)
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/podly', (route) => false,
                                arguments: {'selectedIndex': 3});
// Ouvre dans Library
                          if (r == 11)
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/podly', (route) => false,
                                arguments: {'selectedIndex': 1});
                          if (r == 12)
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/channel',
                              (route) => false,
                            );
                          if (r == 13)
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/channel',
                              (route) => false,
                            );
//vre dans Categories // Ouvre dans Categories
                        },
                        icon: Image.network(
                          s18,
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
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
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
                                          BorderRadius.circular(q.width * 0.04),
                                      image: DecorationImage(
                                        image: NetworkImage(item["urlPhoto"]!),
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
                                      SizedBox(height: q.width * 0.06),
                                      SizedBox(
                                        width: q.width * 0.25,
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: q.width * 0.05,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: q.width * 0.07,
                                      ),
                                      SizedBox(
                                        width: q.width *
                                            0.2, // Constrain the width of the progress bar
                                        child: LinearProgressIndicator(
                                          value: item[
                                              "percent"], // 65% de progression
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF754CEF)),
                                          minHeight: 8,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${(item['percent'] * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(fontSize: 16),
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
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
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
                                          BorderRadius.circular(q.width * 0.04),
                                      image: DecorationImage(
                                        image: NetworkImage(item["urlPhoto"]!),
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
                                      SizedBox(height: q.width * 0.06),
                                      SizedBox(
                                        width: q.width * 0.25,
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: q.width * 0.05,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: q.width *
                                              0.2, // Constrain the width of the progress bar
                                          child: Column(
                                            children: [
                                              Text(
                                                "Category",
                                                style: TextStyle(
                                                    fontSize: q.width * 0.035,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                item["category"]!,
                                                style: TextStyle(
                                                  fontSize: q.width * 0.035,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
                            width: q.width * 0.95,
                            height: q.width * 0.3,
                            child: GestureDetector(
                              onTap: () {
                                if (userId == item["userId"]) {
                                  Navigator.pushNamed(context, '/your',
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
                                        BorderRadius.circular(q.width * 0.1),
                                    image: DecorationImage(
                                      image: NetworkImage(item["photoUrl"]!),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: q.width *
                                            0.2, // Constrain the width of the progress bar
                                        child: Column(
                                          children: [
                                            Text(
                                              "Followers",
                                              style: TextStyle(
                                                  fontSize: q.width * 0.035,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formatLikes(item["followers"]!),
                                              style: TextStyle(
                                                fontSize: q.width * 0.035,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
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
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
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
                                          BorderRadius.circular(q.width * 0.04),
                                      image: DecorationImage(
                                        image: NetworkImage(item["urlPhoto"]!),
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
                                      SizedBox(height: q.width * 0.06),
                                      SizedBox(
                                        width: q.width * 0.25,
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: q.width * 0.09,
                                  ),
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
                                                    child: Image.network(s37),
                                                    width: q.width * 0.05,
                                                    height: q.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: q.width * 0.01,
                                                  ),
                                                  Text(
                                                    formatLikes(item["likes"]!),
                                                    style: TextStyle(
                                                        fontSize:
                                                            q.width * 0.035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: q.width * 0.02,
                                              ),
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    child: Image.network(s14),
                                                    width: q.width * 0.05,
                                                    height: q.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: q.width * 0.01,
                                                  ),
                                                  Text(
                                                    formatLikes(item["vue"]!),
                                                    style: TextStyle(
                                                        fontSize:
                                                            q.width * 0.035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
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
                                          BorderRadius.circular(q.width * 0.04),
                                      image: DecorationImage(
                                        image: NetworkImage(item["urlPhoto"]!),
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
                                      SizedBox(height: q.width * 0.06),
                                      SizedBox(
                                        width: q.width * 0.25,
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: q.width * 0.09,
                                  ),
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
                                                    child: Image.network(s37),
                                                    width: q.width * 0.05,
                                                    height: q.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: q.width * 0.01,
                                                  ),
                                                  Text(
                                                    formatLikes(item["likes"]!),
                                                    style: TextStyle(
                                                        fontSize:
                                                            q.width * 0.035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
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
                                          BorderRadius.circular(q.width * 0.04),
                                      image: DecorationImage(
                                        image: NetworkImage(item["urlPhoto"]!),
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
                                      SizedBox(height: q.width * 0.06),
                                      SizedBox(
                                        width: q.width * 0.25,
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: q.width * 0.09,
                                  ),
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
                                                    child: Image.network(s14),
                                                    width: q.width * 0.05,
                                                    height: q.width * 0.05,
                                                  ),
                                                  SizedBox(
                                                    width: q.width * 0.01,
                                                  ),
                                                  Text(
                                                    formatLikes(item["vue"]!),
                                                    style: TextStyle(
                                                        fontSize:
                                                            q.width * 0.035,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
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
                                        BorderRadius.circular(q.width * 0.1),
                                    image: DecorationImage(
                                      image: NetworkImage(item["photoUrl"]!),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: q.width *
                                            0.2, // Constrain the width of the progress bar
                                        child: Column(
                                          children: [
                                            Text(
                                              "Followers",
                                              style: TextStyle(
                                                  fontSize: q.width * 0.035,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formatLikes(item["followers"]!),
                                              style: TextStyle(
                                                fontSize: q.width * 0.035,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                      if (r == 10)
                        for (var item in play)
                          Container(
                            margin: EdgeInsets.only(bottom: q.width * 0.02),
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12)),
                            width: q.width * 0.95,
                            height: q.width * 0.3,
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
                                        BorderRadius.circular(q.width * 0.04),
                                    image: DecorationImage(
                                      image: AssetImage(item["img"]!),
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
                                        item["tit"]!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: q.width * 0.04,
                                        ),
                                        maxLines: 2,
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
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: q.width * 0.02,
                                            ),
                                            Text(
                                              item["tite"]!,
                                              style: TextStyle(
                                                fontSize: q.width * 0.035,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      if (r == 11) ...[
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.black,
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
                              ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: podd.length,
                                itemBuilder: (context, index) {
                                  final item = podd[index];
                                  return Container(
                                    margin: EdgeInsets.all(q.width * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(q.width * 0.05),
                                      border: Border.all(color: Colors.black12),
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
                                          SizedBox(width: q.width * 0.04),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: q.width * 0.06),
                                              SizedBox(
                                                width: q.width * 0.4,
                                                child: Text(
                                                  item["name"]!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: q.width * 0.04,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: q.width * 0.01),
                                              Text(
                                                item["channel"]["name"]!,
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: q.width * 0.035,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Contenu pour l'onglet Channel
                              ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: craa.length,
                                itemBuilder: (context, index) {
                                  final item = craa[index];
                                  return Container(
                                    margin: EdgeInsets.all(q.width * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(q.width * 0.05),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    width: q.width * 0.95,
                                    height: q.width * 0.3,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (userId == item["userId"]) {
                                          Navigator.pushNamed(context, '/your',
                                              arguments: {'your': 3});
                                        }
                                        if (userId != item["userId"]) {
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
                                          SizedBox(width: q.width * 0.01),
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
                                                width: q.width * 0.2,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "Followers",
                                                      style: TextStyle(
                                                        fontSize:
                                                            q.width * 0.035,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      formatLikes(
                                                          item["followers"]!),
                                                      style: TextStyle(
                                                        fontSize:
                                                            q.width * 0.035,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                              ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: play.length,
                                itemBuilder: (context, index) {
                                  final item = play[index];
                                  return Container(
                                    margin: EdgeInsets.all(q.width * 0.02),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            q.width * 0.05),
                                        border:
                                            Border.all(color: Colors.black12)),
                                    width: q.width * 0.95,
                                    height: q.width * 0.3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/play',
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
                                              SizedBox(height: q.width * 0.02),
                                              SizedBox(
                                                width: q.width * 0.3,
                                                child: Text(
                                                  item["name"]!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: q.width * 0.04,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: q.width * 0.04,
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
                                                      SizedBox(
                                                        height: q.width * 0.02,
                                                      ),
                                                      Text(
                                                        "Podcasts",
                                                        style: TextStyle(
                                                          fontSize:
                                                              q.width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        formatLikes(
                                                            item["podcast"]!),
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
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (r == 12) ...[
                        SizedBox(
                          height: q.height,
                          child: ListView.builder(
                            itemCount: poda.length,
                            itemBuilder: (context, index) {
                              final item = poda[index];
                              return Container(
                                margin: EdgeInsets.all(q.width * 0.02),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(q.width * 0.05),
                                  border: Border.all(color: Colors.black12),
                                ),
                                width: q.width * 0.95,
                                height: q.width * 0.3,
                                child: Row(
                                  children: [
                                    SizedBox(width: q.width * 0.01),
                                    Image.asset(
                                      "images/play1.png",
                                      width: q.width * 0.09,
                                      height: q.width * 0.09,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(width: q.width * 0.03),
                                    Container(
                                      height: q.width * 0.2,
                                      width: q.width * 0.2,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            q.width * 0.04),
                                        image: DecorationImage(
                                          image: AssetImage(item["img"]!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: q.width * 0.02),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: q.width * 0.0),
                                        SizedBox(
                                          width: q.width * 0.35,
                                          child: Text(
                                            item["tit"]!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: q.width * 0.04,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: q.width * 0.01),
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
                                                      child: Image.asset(
                                                          "images/like.png"),
                                                      width: q.width * 0.05,
                                                      height: q.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: q.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["like"]!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              q.width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: q.width * 0.02,
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      child: Image.asset(
                                                          "images/view.png"),
                                                      width: q.width * 0.05,
                                                      height: q.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: q.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["view"]!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              q.width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: q.width * 0.02,
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      child: Image.asset(
                                                          "images/comment.png"),
                                                      width: q.width * 0.05,
                                                      height: q.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: q.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["com"]!,
                                                      style: TextStyle(
                                                          fontSize:
                                                              q.width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ],
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
                            itemCount: play.length,
                            itemBuilder: (context, index) {
                              final item = play[index];
                              return Container(
                                margin: EdgeInsets.all(q.width * 0.02),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(q.width * 0.05),
                                  border: Border.all(color: Colors.black12),
                                ),
                                width: q.width * 0.95,
                                height: q.width * 0.3,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: q.width * 0.01,
                                    ),
                                    Container(
                                      height: q.width * 0.25,
                                      width: q.width * 0.25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            q.width * 0.04),
                                        image: DecorationImage(
                                          image: AssetImage(item["img"]!),
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
                                        SizedBox(height: q.width * 0.02),
                                        SizedBox(
                                          width: q.width * 0.3,
                                          child: Text(
                                            item["tit"]!,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              width: q.width *
                                                  0.2, // Constrain the width of the progress bar
                                              child: Column(children: [
                                                SizedBox(
                                                  height: q.width * 0.02,
                                                ),
                                                Text(
                                                  item["tite"]!,
                                                  style: TextStyle(
                                                    fontSize: q.width * 0.035,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ]))
                                        ])
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ]),
    )));
  }
}
