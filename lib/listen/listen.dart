import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:marquee/marquee.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/main.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import for StreamSubscription

class Listenpage extends StatefulWidget {
  const Listenpage({super.key});

  @override
  State<Listenpage> createState() => _ListenpageState();
}

class _ListenpageState extends State<Listenpage>
    with SingleTickerProviderStateMixin {
  String? idpod;
  late int featl = 1;
  String? replyingTo;
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> playlist = [];
  List<Map<String, dynamic>> playinpod = [];
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> mesPodcasts12 = [];
  // List to manage all stream subscriptions
  final List<StreamSubscription> _streamSubscriptions = [];

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

  Future<void> nbrpodId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('myplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots()
          .listen((playinPodSnapshot) async {
        List<Map<String, dynamic>> myPlayInfos = [];

        for (var doc in playinPodSnapshot.docs) {
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

            final podSnapshot = await FirebaseFirestore.instance
                .collection('podcasts')
                .where('id', whereIn: batch)
                .get(); // Keep get() for batched whereIn queries

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
          if (mounted) {
            setState(() {
              mesPodcasts12 = allPodcasts;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              mesPodcasts12 = [];
            });
          }
        }
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          mesPodcasts12 = [];
        });
      }
    }
  }

  Future<void> fetchPlaylidtById12(String idplay1) async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: idplay1)
          .snapshots()
          .listen((querySnapshot) {
        if (mounted) {
          setState(() {
            playlist = querySnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      });

      _streamSubscriptions.add(streamSubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> fetchPlaylistsByPodcastId12(String idplay1) async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('playinpod')
          .where('playlistId', isEqualTo: idplay1)
          .orderBy('date', descending: true)
          .snapshots()
          .listen((playinPodSnapshot) async {
        // 🔁 Récupérer les podcasts avec leur date d'ajout
        List<Map<String, dynamic>> podInfos = [];

        for (var doc in playinPodSnapshot.docs) {
          final data = doc.data();
          final podcastId = data['podcastId'];
          final date = data['date'];

          // On garde l'ordre, donc on ne filtre pas les doublons ici
          podInfos.add({
            'podcastId': podcastId,
            'date': date,
          });
        }

        if (podInfos.isNotEmpty) {
          List<Map<String, dynamic>> allPodcasts = [];

          // Regrouper par lot de 10 les IDs de podcasts
          for (int i = 0; i < podInfos.length; i += 10) {
            int end = (i + 10 < podInfos.length) ? i + 10 : podInfos.length;
            List<String> batch = podInfos
                .sublist(i, end)
                .map((e) => e['podcastId'] as String)
                .toList();

            final podcastsSnapshot = await FirebaseFirestore.instance
                .collection('podcasts')
                .where('id', whereIn: batch)
                .get(); // Keep get() for batched whereIn queries

            for (var doc in podcastsSnapshot.docs) {
              final data = doc.data();
              allPodcasts.add(data);
            }
          }

          // Réassocier la date de playinpod pour trier
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

          // 🔁 Tri décroissant par la date de `playinpod`
          sortedPods.sort((a, b) {
            Timestamp? dateA = a['playinpodDate'] as Timestamp?;
            Timestamp? dateB = b['playinpodDate'] as Timestamp?;
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA);
          });

          if (mounted) {
            if (mounted) {
              setState(() {
                podcastPlaylists = sortedPods;
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              podcastPlaylists = [];
            });
          }
        }
      });

      _streamSubscriptions.add(streamSubscription);
    } catch (e) {
      if (mounted) {
        setState(() {
          podcastPlaylists = [];
        });
      }
    }
  }

  List<Map<String, dynamic>> podcastPlaylists = [];
  Future<void> fetchPodcastsById(String idpod) async {
    try {
      final streamSubscription = FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .snapshots()
          .listen((querySnapshot) {
        if (mounted) {
          setState(() {
            podcast = querySnapshot.docs
                // ignore: unnecessary_cast
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }

        // Initialize audio player if podcast data is available
        if (podcast.isNotEmpty && podcast[0]['urlFile'] != null) {
          _initAudioPlayer();
        }
      });

      _streamSubscriptions.add(streamSubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> fetchPlaylistsByPodcastId(String idpod) async {
    try {
      // 1️⃣ Récupérer les `playlistId` associés au `idpod`
      final streamSubscription = FirebaseFirestore.instance
          .collection('playinpod')
          .orderBy('date', descending: true)
          .where('podcastId', isEqualTo: idpod)
          .snapshots()
          .listen((playinPodSnapshot) async {
        final List<Map<String, dynamic>> playinPodData = playinPodSnapshot.docs
            .map((doc) => {
                  "podcastId": doc['podcastId'],
                  "playlistId": doc['playlistId'],
                  "date":
                      doc['date'], // Conserver la date pour le tri ultérieur
                })
            .toList();
        final List<String> playlistIds =
            playinPodData.map((item) => item["playlistId"] as String).toList();

        if (playlistIds.isNotEmpty) {
          // 2️⃣ Récupérer les playlists correspondant aux `playlistId`
          final playlistSnapshot = await FirebaseFirestore.instance
              .collection('playlist')
              .where(FieldPath.documentId, whereIn: playlistIds)
              .get(); // Keep get() for batched whereIn queries

          // Créer un Map pour faciliter la récupération des dates de playinpod
          Map<String, dynamic> playlistDates = {};
          for (var item in playinPodData) {
            playlistDates[item["playlistId"]] = item["date"];
          }

          List<Map<String, dynamic>> loadedPlaylists = playlistSnapshot.docs
              .map((doc) => {
                    "id": doc.id,
                    "playinpodDate":
                        playlistDates[doc.id], // Ajouter la date de playinpod
                    ...doc.data(),
                  })
              .toList();

          // Trier les playlists par la date de playinpod
          loadedPlaylists.sort((a, b) {
            var dateA = a["playinpodDate"];
            var dateB = b["playinpodDate"];
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA); // Ordre décroissant
          });

          // 3️⃣ Associer les podcasts aux playlists
          final playinPodSnapshot2 = await FirebaseFirestore.instance
              .collection('playinpod')
              .orderBy('date', descending: true)
              .where('playlistId', whereIn: playlistIds)
              .get(); // Keep get() for batched whereIn queries

          Map<String, List<String>> podcastToPlaylists = {};
          Map<String, dynamic> podcastDates =
              {}; // Pour stocker la date la plus récente pour chaque podcast

          for (var doc in playinPodSnapshot2.docs) {
            String podcastId = doc['podcastId'];
            String playlistId = doc['playlistId'];
            var date = doc['date'];

            if (!podcastToPlaylists.containsKey(podcastId)) {
              podcastToPlaylists[podcastId] = [];
              podcastDates[podcastId] = date;
            } else if (date != null &&
                (podcastDates[podcastId] == null ||
                    date.compareTo(podcastDates[podcastId]) > 0)) {
              podcastDates[podcastId] =
                  date; // Mettre à jour avec la date la plus récente
            }

            podcastToPlaylists[podcastId]!.add(playlistId);
          }

          final List<String> podcastIds = podcastToPlaylists.keys.toList();

          if (podcastIds.isNotEmpty) {
            // 4️⃣ Récupérer les podcasts avec `podcastIds`
            final podcastSnapshot = await FirebaseFirestore.instance
                .collection('podcasts')
                .where(FieldPath.documentId, whereIn: podcastIds)
                .get(); // Keep get() for batched whereIn queries

            List<Map<String, dynamic>> loadedPodcasts =
                podcastSnapshot.docs.map((doc) {
              // ignore: unnecessary_cast
              final podcastData = doc.data() as Map<String, dynamic>;
              final podcastId = doc.id;
              return {
                "id": podcastId,
                "playlistIds": podcastToPlaylists[podcastId] ?? [],
                "playinpodDate":
                    podcastDates[podcastId], // Ajouter la date de playinpod
                ...podcastData,
              };
            }).toList();

            // Trier les podcasts par date de playinpod
            loadedPodcasts.sort((a, b) {
              var dateA = a["playinpodDate"];
              var dateB = b["playinpodDate"];
              if (dateA == null) return 1;
              if (dateB == null) return -1;
              return dateB.compareTo(dateA); // Ordre décroissant
            });

            if (mounted) {
              setState(() {
                playlist = loadedPlaylists;
                playinpod = loadedPodcasts;
              });
            }
          }
        }
      });

      _streamSubscriptions.add(streamSubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  /* Map<String, List<Map<String, dynamic>>> podcastsByPlaylist = {};
  List<Map<String, dynamic>> allPodcasts = [];
 */
  bool isLoading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentTime = "0:00";
  String totalTime = "0:00";
  double currentPosition = 0.0; // Progress value
  double audioProgressPercent = 0.0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => isLoading = true);
      }

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('idpod')) {
          idpod = arguments['idpod'];
        }

        if (arguments.containsKey('featl')) {
          featl = arguments['featl'];
        }
        if (arguments.containsKey('idplay1')) {
          idplay1 = arguments['idplay1'];
        }
        if (idpod != null) {
          await fetchPodcastsById(idpod!);
          await fetchPlaylistsByPodcastId(idpod!);
          await _fetchComments();
          await _fetchLikeStatus();
          await _fetchUnlikeStatus();
          await _fetchsaveStatus();
          await nbrpodId();
        }
        if (idplay1 != null) {
          await fetchPlaylidtById12(idplay1!);
          await fetchPlaylistsByPodcastId12(idplay1!);
        }
      }
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  String? idplay1;
// First, let's add a specific function to debug a single user ID
  // ignore: unused_element
  Future<void> _debugUserDocument(String userId) async {
    try {
      // Approach 1: Direct document reference
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
      } else {}

      // Approach 2: Query by ID
      final streamSubscription = FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isEqualTo: userId)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
        } else {}

        // Optional: Check exact user ID format
      });

      _streamSubscriptions.add(streamSubscription);
      // ignore: empty_catches
    } catch (e) {}
  }

  String getlikeIcon(ThemeProvider themeProvider) {
    if (isLiked) {
      return themeProvider.isDarkMode ? s135 : s39;
    } else {
      return themeProvider.isDarkMode ? s111 : s37;
    }
  }

  String getunlikeIcon(ThemeProvider themeProvider) {
    if (isUnliked) {
      return themeProvider.isDarkMode ? s136 : s40;
    } else {
      return themeProvider.isDarkMode ? s122 : s41;
    }
  }

  String getSaveIcon(ThemeProvider themeProvider) {
    if (isSaved) {
      return themeProvider.isDarkMode ? s121 : s43;
    } else {
      return themeProvider.isDarkMode ? s120 : s42;
    }
  }

  bool isSaved = false;
  bool isLiked = false;
  bool isUnliked = false;
  final currentUser = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _fetchLikeStatus() async {
    final streamSubscription = FirebaseFirestore.instance
        .collection('like')
        .where('iduser', isEqualTo: currentUser)
        .where('idpod', isEqualTo: idpod)
        .snapshots()
        .listen((likeQuery) {
      if (mounted) {
        setState(() {
          isLiked = likeQuery.docs.isNotEmpty;
        });
      }
    });

    _streamSubscriptions.add(streamSubscription);
  }

  Future<void> _fetchsaveStatus() async {
    final streamSubscription = FirebaseFirestore.instance
        .collection('myplaylist')
        .where('iduser', isEqualTo: currentUser)
        .where('idpod', isEqualTo: idpod)
        .snapshots()
        .listen((saveQuery) {
      if (mounted) {
        setState(() {
          isSaved = saveQuery.docs.isNotEmpty;
        });
      }
    });

    _streamSubscriptions.add(streamSubscription);
  }

  Future<void> _fetchUnlikeStatus() async {
    final streamSubscription = FirebaseFirestore.instance
        .collection('unlike')
        .where('iduser', isEqualTo: currentUser)
        .where('idpod', isEqualTo: idpod)
        .snapshots()
        .listen((unlikeQuery) {
      if (mounted) {
        setState(() {
          isUnliked = unlikeQuery.docs.isNotEmpty;
        });
      }
    });

    _streamSubscriptions.add(streamSubscription);
  }

  bool hasViewed = false;
  Future<void> _initAudioPlayer() async {
    try {
      if (podcast.isNotEmpty && podcast[0]['urlFile'] != null) {
        String url = podcast[0]['urlFile'];

        await _audioPlayer.setUrl(url);
      }

      _audioPlayer.durationStream.listen((duration) {
        if (duration != null && mounted) {
          setState(() {
            totalTime = _formatDuration(duration);
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (!mounted) return;
        final duration = _audioPlayer.duration;
        if (duration != null) {
          double percent = position.inMilliseconds / duration.inMilliseconds;
          if (mounted) {
            setState(() {
              currentTime = _formatDuration(position);
              currentPosition = percent;
              audioProgressPercent = percent;
            });
          }

          // Enregistrement de la vue si > 20%
          if (percent >= 0.2 && !hasViewed) {
            hasViewed = true;
            _registerView(percent);
          }

          // Mise à jour de la vue si déjà vue
          if (percent >= 0.2 && hasViewed) {
            View(percent);
          }
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            isPlaying = state.playing;
          });
        }
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  late int nbc = 0;
  Future<void> _fetchComments() async {
    try {
      // Utiliser snapshots() pour obtenir un stream au lieu de get()
      final streamSubscription = FirebaseFirestore.instance
          .collection('comments')
          .orderBy('date', descending: true)
          .where('idpod', isEqualTo: idpod)
          .snapshots()
          .listen((commentSnapshot) async {
        if (commentSnapshot.docs.isEmpty) {
          if (mounted) {
            setState(() {
              comments = [];
              nbc = 0;
            });
          }
          return;
        }

        nbc = commentSnapshot.docs.length;
        List<Map<String, dynamic>> fetchedComments = [];
        Set<String> userIds = {}; // Pour stocker les userId uniques

        // 2️⃣ Extraction des userId des commentaires et des réponses
        for (var doc in commentSnapshot.docs) {
          // ignore: unnecessary_cast
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          // Ajout de l'auteur du commentaire
          if (data.containsKey('userid') && data['userid'] is String) {
            userIds.add(data['userid']);
          }

          // Récupération des réponses
          QuerySnapshot replySnapshot = await doc.reference
              .collection('reply')
              .orderBy('date', descending: true)
              .get();
          for (var reply in replySnapshot.docs) {
            Map<String, dynamic> replyData =
                reply.data() as Map<String, dynamic>;

            if (replyData.containsKey('userid') &&
                replyData['userid'] is String) {
              userIds.add(replyData['userid']);
            }
          }
        }

        // 3️⃣ Récupération des données des utilisateurs en batch (10 max par requête Firestore)
        Map<String, Map<String, dynamic>> userMap = {};
        List<String> userIdsList = userIds.toList();

        for (int i = 0; i < userIdsList.length; i += 10) {
          List<String> chunk = userIdsList.sublist(
              i, i + 10 > userIdsList.length ? userIdsList.length : i + 10);

          // CORRECTION: Query by 'userId' field, not documentId
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('userId',
                  whereIn:
                      chunk) // Use 'userId' field to match with comment's 'userid'
              .get();

          for (var userDoc in userSnapshot.docs) {
            // Store using 'userId' as the key, not document ID
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            String userId = userData['userId'] as String;
            userMap[userId] = userData; // Store with userId as key for lookup
          }
        }

        // 4️⃣ Associer les utilisateurs aux commentaires et récupérer les réponses
        for (var doc in commentSnapshot.docs) {
          // ignore: unnecessary_cast
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;

          // Associer l'utilisateur du commentaire
          String? userId = data['userid'] as String?;

          if (userId != null && userMap.containsKey(userId)) {
            data['user'] = {
              'firstName': userMap[userId]?['firstName'] ?? 'Unknown',
              'lastName': userMap[userId]?['lastName'] ?? 'User',
              'photoUrl': userMap[userId]?['photoUrl']
            };
          } else {
            data['user'] = {
              'firstName': 'Unknown',
              'lastName': 'User',
              'photoUrl': null
            };
          }

          // Récupération des réponses avec leur utilisateur
          List<Map<String, dynamic>> replies = [];
          QuerySnapshot replySnapshot = await doc.reference
              .collection('reply')
              .orderBy('date', descending: true)
              .get();

          for (var reply in replySnapshot.docs) {
            Map<String, dynamic> replyData =
                reply.data() as Map<String, dynamic>;
            replyData['id'] = reply.id;

            String? replyUserId = replyData['userid'] as String?;

            if (replyUserId != null && userMap.containsKey(replyUserId)) {
              replyData['user'] = {
                'firstName': userMap[replyUserId]?['firstName'] ?? 'Unknown',
                'lastName': userMap[replyUserId]?['lastName'] ?? 'User',
                'photoUrl': userMap[replyUserId]?['photoUrl']
              };
            } else {
              replyData['user'] = {
                'firstName': 'Unknown',
                'lastName': 'User',
                'photoUrl': null
              };
            }

            // Add empty list for nested replies
            replyData['replies'] = [];
            replies.add(replyData);
          }

          data['replies'] = replies;
          fetchedComments.add(data);
        }

        if (mounted) {
          setState(() {
            comments = fetchedComments;
          });
        }
      });

      _streamSubscriptions.add(streamSubscription);
      // ignore: unused_catch_stack
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          comments = [];
        });
      }
    }
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor, // Utilise la couleur de fond selon le thème
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
              return Padding(
                padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(formatLikes(podcast[0]["comments"]),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          )),
                      const Text(" "),
                      Text("Comments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          )),
                    ]),
                    const SizedBox(height: 10),
                    Expanded(
                      child: comments.isEmpty
                          ? Center(
                              child: Text("Not Yet",
                                  style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  )))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                final user = comment['user'];
                                final replies =
                                    comment['replies'] as List<dynamic>;
                                final isCurrentUserComment =
                                    FirebaseAuth.instance.currentUser?.uid ==
                                        comment['userid'];
                                final isCreator =
                                    comment['userid'] == podcast[0]['idUser'];

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      leading: user != null &&
                                              user.containsKey('photoUrl') &&
                                              user['photoUrl'] is String &&
                                              user['photoUrl']!
                                                  .trim()
                                                  .isNotEmpty
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  user['photoUrl']))
                                          : const CircleAvatar(
                                              child: Icon(Icons.person)),
                                      title: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: comment['user'] != null
                                                  ? "${comment['user']['firstName']} ${comment['user']['lastName']}"
                                                  : "Unknown User",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: themeProvider.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                            if (isCreator)
                                              const TextSpan(
                                                text: " Creator",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF754CEF),
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            comment['text'] ?? "",
                                            style: TextStyle(
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            comment['date'] != null
                                                ? DateFormat(
                                                        'MMM d, yyyy • h:mm a')
                                                    .format(comment['date']
                                                        .toDate())
                                                : "",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      trailing: isCurrentUserComment
                                          ? IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _showDeleteConfirmation(
                                                context,
                                                () => _deleteComment(
                                                    comment['id']),
                                              ),
                                            )
                                          : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 72, bottom: 8),
                                      child: Row(
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.reply,
                                                size: 16),
                                            label: const Text("Reply"),
                                            onPressed: () {
                                              // Show reply input field with the comment author's name
                                              String commentUsername = comment[
                                                          'user'] !=
                                                      null
                                                  ? "${comment['user']['firstName']} ${comment['user']['lastName']}"
                                                  : "Unknown User";
                                              _showReplyInput(
                                                  context,
                                                  comment['id'],
                                                  null,
                                                  commentUsername);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Display replies
                                    if (replies.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 72, right: 16),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: themeProvider.isDarkMode
                                                ? Colors.black
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: replies.length,
                                            itemBuilder: (context, replyIndex) {
                                              final reply = replies[replyIndex];
                                              final isCurrentUserReply =
                                                  FirebaseAuth.instance
                                                          .currentUser?.uid ==
                                                      reply['userid'];
                                              final isReplyCreator =
                                                  reply['userid'] ==
                                                      podcast[0]['idUser'];

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 12),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 16,
                                                          backgroundImage: reply[
                                                                          'user'] !=
                                                                      null &&
                                                                  reply['user'][
                                                                          'photoUrl'] !=
                                                                      null
                                                              ? NetworkImage(
                                                                  reply['user'][
                                                                      'photoUrl'])
                                                              : null,
                                                          child: reply['user'] ==
                                                                      null ||
                                                                  reply['user'][
                                                                          'photoUrl'] ==
                                                                      null
                                                              ? const Icon(
                                                                  Icons.person,
                                                                  size: 16)
                                                              : null,
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            style:
                                                                                TextStyle(
                                                                              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                            children: [
                                                                              TextSpan(
                                                                                  text: reply['user'] != null ? "${reply['user']['firstName']} ${reply['user']['lastName']}" : "Unknown User",
                                                                                  style: TextStyle(
                                                                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                                                                                  )),
                                                                              if (isReplyCreator)
                                                                                const TextSpan(
                                                                                  text: " Creator",
                                                                                  style: TextStyle(
                                                                                    color: Color(0xFF754CEF),
                                                                                    fontSize: 12,
                                                                                  ),
                                                                                ),
                                                                              // Always display @username for all replies
                                                                              if (reply['replyToUsername'] != null && reply['replyToUsername'].isNotEmpty)
                                                                                TextSpan(
                                                                                  text: " @ ${reply['replyToUsername']}",
                                                                                  style: const TextStyle(
                                                                                    color: Color(0xFF754CEF),
                                                                                  ),
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                        // Display the actual reply text separately
                                                                        Text(
                                                                          reply['text'] ??
                                                                              "",
                                                                          style:
                                                                              TextStyle(
                                                                            color: themeProvider.isDarkMode
                                                                                ? Colors.white
                                                                                : Colors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  if (isCurrentUserReply)
                                                                    IconButton(
                                                                      icon: const Icon(
                                                                          Icons
                                                                              .delete,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              Colors.red),
                                                                      onPressed:
                                                                          () =>
                                                                              _showDeleteConfirmation(
                                                                        context,
                                                                        () => _deleteReply(
                                                                            comment['id'],
                                                                            reply['id']),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                reply['date'] !=
                                                                        null
                                                                    ? DateFormat(
                                                                            'MMM d, yyyy • h:mm a')
                                                                        .format(
                                                                            reply['date'].toDate())
                                                                    : "",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Reply to reply button
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 40,
                                                            bottom: 8),
                                                    child: TextButton.icon(
                                                      icon: const Icon(
                                                          Icons.reply,
                                                          size: 14),
                                                      label: const Text("Reply",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                      onPressed: () {
                                                        String replyUsername =
                                                            reply['user'] !=
                                                                    null
                                                                ? "${reply['user']['firstName']} ${reply['user']['lastName']}"
                                                                : "Unknown User";
                                                        _showReplyInput(
                                                            context,
                                                            comment['id'],
                                                            reply['id'],
                                                            replyUsername);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    const Divider(),
                                  ],
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: "Write a comment",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send,
                                color: Color(0xFF754CEF)),
                            onPressed: () {
                              _addComment();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        );
      },
    );
  }

  // Fonction pour afficher le dialogue de confirmation de suppression
  void _showDeleteConfirmation(
      BuildContext context, Function onDeleteConfirmed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return AlertDialog(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.white,
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
                child: const Text("Yes",
                    style: TextStyle(color: Color(0xFF754CEF))),
                onPressed: () {
                  Navigator.of(context).pop();
                  onDeleteConfirmed();
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showReplyInput(BuildContext context, String commentId,
      String? parentReplyId, String? replyToUsername) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
            return AlertDialog(
              backgroundColor: Theme.of(context)
                  .scaffoldBackgroundColor, // Utilise la couleur de fond selon le thème
              title: Text(
                  parentReplyId == null
                      ? "Reply to comment"
                      : "Reply to ${replyToUsername ?? 'reply'}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  )),
              content: TextField(
                controller: replyController,
                decoration: const InputDecoration(
                  hintText: 'Write your reply...',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (replyController.text.isNotEmpty) {
                      if (parentReplyId == null) {
                        // Fix: Pass parentReplyId instead of undefined replyId
                        _addReply(commentId, null, replyController.text,
                            replyToUsername ?? '');
                      } else {
                        _addNestedReply(commentId, parentReplyId,
                            replyController.text, replyToUsername ?? '');
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF754CEF),
                  ),
                  child: const Text('Reply'),
                ),
              ],
            );
          });
        });
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions
    for (var subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear(); // Clear the list

    // Dispose the audio player
    _audioPlayer.dispose();

    // Dispose the comment controller
    _commentController.dispose();

    super.dispose();
  }

  void _addNestedReply(String commentId, String parentReplyId, String text,
      String replyToUsername) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .collection('reply')
        .add({
      'userid': FirebaseAuth.instance.currentUser?.uid,
      'text': text,
      'date': Timestamp.now(),
      'parentReplyId': parentReplyId, // Add reference to parent reply
      'replyToUsername': replyToUsername, // Add the username being replied to
    });
    await FirebaseFirestore.instance.collection('podcasts').doc(idpod).update({
      'comments': FieldValue.increment(1),
    });
    await FirebaseFirestore.instance.collection('nofi').add({
      'user1': FirebaseAuth.instance.currentUser?.uid,
      'user2': podcast[0]["idUser"],
      'text': ' replyed Comment',
      'date': Timestamp.now(),
      'isviewed': false,
    });
    final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userId', isEqualTo: currentUser)
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
    try {
      await FCMService.sendNotification(
        topic: podcast[0]["idUser"],
        title: 'New Comment',
        body: '$fullName has  Replyed to your podcast',
      );
      // ignore: empty_catches
    } catch (e) {}
    if (mounted) {
      setState(() {});
    }
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('comments').add({
        'userid': FirebaseAuth.instance.currentUser?.uid,
        'idpod': idpod,
        'text': _commentController.text,
        'date': Timestamp.now(),
      });
      await FirebaseFirestore.instance.collection('nofi').add({
        'user1': FirebaseAuth.instance.currentUser?.uid,
        'user2': podcast[0]["idUser"],
        'text': 'Comment For Your Podcast',
        'date': Timestamp.now(),
        'isviewed': false,
      });
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'comments': FieldValue.increment(1),
      });
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUser)
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
      try {
        await FCMService.sendNotification(
          topic: podcast[0]["idUser"],
          title: 'New Comment',
          body: '$fullName has commented to your podcast',
        );
        // ignore: empty_catches
      } catch (e) {}
      _commentController.clear();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _addReply(String commentId, String? replyToId, String replyText,
      String replyToUsername) async {
    if (replyText.trim().isEmpty) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDataQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (userDataQuery.docs.isEmpty) {
        return;
      }

      final userData = userDataQuery.docs.first.data();

      final replyId =
          replyToId ?? DateTime.now().millisecondsSinceEpoch.toString();

      final replyData = {
        'id': replyId,
        'text': replyText,
        'userid': user.uid,
        'date': FieldValue.serverTimestamp(),
        'user': userData,
        'replyToUsername': replyToUsername,
      };
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .collection('reply')
          .add(replyData);
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'comments': FieldValue.increment(1),
      });
      await FirebaseFirestore.instance.collection('nofi').add({
        'user1': FirebaseAuth.instance.currentUser?.uid,
        'user2': podcast[0]["idUser"],
        'text': ' replyed Comment',
        'date': Timestamp.now(),
        'isviewed': false,
      });
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUser)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User information not found')),
        );
        return;
      }

      // Extraire firstName et lastName
      final userData1 = userSnapshot.docs.first.data() as Map<String, dynamic>;
      final String firstName = userData1['firstName'] ?? '';
      final String lastName = userData1['lastName'] ?? '';
      final String fullName = '$firstName $lastName';
      try {
        await FCMService.sendNotification(
          topic: podcast[0]["idUser"],
          title: 'New Comment',
          body: '$fullName has  Replyed to your podcast',
        );
        // ignore: empty_catches
      } catch (e) {}
      _commentController.clear();
      // ignore: empty_catches
    } catch (e) {}
  }

  void _deleteComment(String commentId) async {
    // First delete all replies
    QuerySnapshot replySnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .collection('reply')
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var reply in replySnapshot.docs) {
      batch.delete(reply.reference);
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'comments': FieldValue.increment(-1),
      });
    }

    // Then delete the comment itself
    batch.delete(
        FirebaseFirestore.instance.collection('comments').doc(commentId));

    await batch.commit();
    await FirebaseFirestore.instance.collection('podcasts').doc(idpod).update({
      'comments': FieldValue.increment(-1),
    });
    if (mounted) {
      setState(() {});
    }
  }

  void _deleteReply(String commentId, String replyId) async {
    // First, find and delete all replies to this reply
    QuerySnapshot nestedRepliesSnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .collection('reply')
        .where('parentReplyId', isEqualTo: replyId)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();
    int deletedCount = 0;

    // Delete all nested replies first
    for (var nestedReply in nestedRepliesSnapshot.docs) {
      // Recursively delete replies to this reply as well (if any)
      await _deleteNestedReplies(commentId, nestedReply.id);
      batch.delete(nestedReply.reference);
      deletedCount++;
    }

    // Then delete the reply itself
    batch.delete(FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .collection('reply')
        .doc(replyId));
    deletedCount++;

    await batch.commit();

    // Update the comment count
    await FirebaseFirestore.instance.collection('podcasts').doc(idpod).update({
      'comments': FieldValue.increment(-deletedCount),
    });

    if (mounted) {
      setState(() {});
    }
  }

// Helper method to recursively delete nested replies
  Future<int> _deleteNestedReplies(String commentId, String replyId) async {
    int deletedCount = 0;

    QuerySnapshot nestedRepliesSnapshot = await FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .collection('reply')
        .where('parentReplyId', isEqualTo: replyId)
        .get();

    WriteBatch batch = FirebaseFirestore.instance.batch();

    for (var nestedReply in nestedRepliesSnapshot.docs) {
      // Recursively delete any replies to this nested reply
      deletedCount += await _deleteNestedReplies(commentId, nestedReply.id);
      batch.delete(nestedReply.reference);
      deletedCount++;
    }

    if (nestedRepliesSnapshot.docs.isNotEmpty) {
      await batch.commit();
    }

    return deletedCount;
  }

  void _toggleLike() async {
    final likeRef = FirebaseFirestore.instance.collection('like');
    final unlikeRef = FirebaseFirestore.instance.collection('unlike');

    try {
      if (!isLiked) {
        try {
          await likeRef.add({
            'iduser': currentUser,
            'idpod': idpod,
            'dateCreation': FieldValue.serverTimestamp(),
          });
          // ignore: empty_catches
        } catch (e) {}

        try {
          await FirebaseFirestore.instance.collection('nofi').add({
            'user1': currentUser,
            'user2': podcast[0]["idUser"],
            'text': 'Liked Your Podcast',
            'date': Timestamp.now(),
            'isviewed': false,
          });
          // ignore: empty_catches
        } catch (e) {}

        try {
          await FirebaseFirestore.instance
              .collection('podcasts')
              .doc(idpod)
              .update({'likes': FieldValue.increment(1)});
          // ignore: empty_catches
        } catch (e) {}

        final QuerySnapshot userSnapshot;
        try {
          userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('userId', isEqualTo: currentUser)
              .get();
        } catch (e) {
          return;
        }

        if (userSnapshot.docs.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User information not found')),
            );
          }
          return;
        }

        final userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
        final String firstName = userData['firstName'] ?? '';
        final String lastName = userData['lastName'] ?? '';
        final String fullName = '$firstName $lastName';

        try {
          await FCMService.sendNotification(
            topic: podcast[0]["idUser"],
            title: 'New Like',
            body: '$fullName has Liked your podcast',
          );
          // ignore: empty_catches
        } catch (e) {}

        if (mounted) {
          setState(() {
            isLiked = true;
          });
        }

        if (isUnliked) {
          try {
            final unlikeQuery = await unlikeRef
                .where('iduser', isEqualTo: currentUser)
                .where('idpod', isEqualTo: idpod)
                .get();

            for (var doc in unlikeQuery.docs) {
              await doc.reference.delete();
              await FirebaseFirestore.instance
                  .collection('podcasts')
                  .doc(idpod)
                  .update({'unlikes': FieldValue.increment(-1)});
            }

            if (mounted) {
              setState(() {
                isUnliked = false;
              });
            }
            // ignore: empty_catches
          } catch (e) {}
        }
      } else {
        // Supprimer le like
        try {
          final likeQuery = await likeRef
              .where('iduser', isEqualTo: currentUser)
              .where('idpod', isEqualTo: idpod)
              .get();

          for (var doc in likeQuery.docs) {
            await doc.reference.delete();
            await FirebaseFirestore.instance
                .collection('podcasts')
                .doc(idpod)
                .update({'likes': FieldValue.increment(-1)});
          }

          if (mounted) {
            setState(() {
              isLiked = false;
            });
          }
          // ignore: empty_catches
        } catch (e) {}
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  void _toggleSave() async {
    final saveRef = FirebaseFirestore.instance.collection('myplaylist');

    if (!isSaved) {
      // Ajouter le like
      await saveRef.add({
        'iduser': currentUser,
        'idpod': idpod,
        'dateCreation': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('nofi').add({
        'user1': FirebaseAuth.instance.currentUser?.uid,
        'user2': podcast[0]["idUser"],
        'text': ' Save Your Podcast',
        'date': Timestamp.now(),
        'isviewed': false,
      });
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'save': FieldValue.increment(1),
      });
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUser)
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
      try {
        await FCMService.sendNotification(
          topic: podcast[0]["idUser"],
          title: 'New Save',
          body: '$fullName has Saved to your podcast',
        );
        // ignore: empty_catches
      } catch (e) {}
      if (mounted) {
        setState(() {
          isSaved = true;
        });
      }
    } else {
      // Supprimer le like
      final saveQuery = await saveRef
          .where('iduser', isEqualTo: currentUser)
          .where('idpod', isEqualTo: idpod)
          .get();
      for (var doc in saveQuery.docs) {
        await doc.reference.delete();
        await FirebaseFirestore.instance
            .collection('podcasts')
            .doc(idpod)
            .update({
          'save': FieldValue.increment(-1),
        });
      }
      if (mounted) {
        setState(() {
          isSaved = false;
        });
      }
    }
  }

  void _toggleUnlike() async {
    final likeRef = FirebaseFirestore.instance.collection('like');
    final unlikeRef = FirebaseFirestore.instance.collection('unlike');

    if (!isUnliked) {
      // Ajouter l'unlike
      await unlikeRef.add({
        'iduser': currentUser,
        'idpod': idpod,
        'dateCreation': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('nofi').add({
        'user1': currentUser,
        'user2': podcast[0]["idUser"],
        'text': 'inliked Your Podcast',
        'date': Timestamp.now(),
        'isviewed': false,
      });
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'unlikes': FieldValue.increment(1),
      });
      if (mounted) {
        setState(() {
          isUnliked = true;
        });
      }

      // Supprimer le like s'il existe
      if (isLiked) {
        final likeQuery = await likeRef
            .where('iduser', isEqualTo: currentUser)
            .where('idpod', isEqualTo: idpod)
            .get();
        for (var doc in likeQuery.docs) {
          await doc.reference.delete();
          await FirebaseFirestore.instance
              .collection('podcasts')
              .doc(idpod)
              .update({
            'likes': FieldValue.increment(-1),
            'dateCreation': FieldValue.serverTimestamp(),
          });
        }
        if (mounted) {
          setState(() {
            isLiked = false;
          });
        }
      }
    } else {
      // Supprimer l'unlike
      final unlikeQuery = await unlikeRef
          .where('iduser', isEqualTo: currentUser)
          .where('idpod', isEqualTo: idpod)
          .get();
      for (var doc in unlikeQuery.docs) {
        await doc.reference.delete();
        await FirebaseFirestore.instance
            .collection('podcasts')
            .doc(idpod)
            .update({
          'unlikes': FieldValue.increment(-1),
          'dateCreation': FieldValue.serverTimestamp(),
        });
      }
      if (mounted) {
        setState(() {
          isUnliked = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString();
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _registerView(double percent) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || idpod == null) return;

    final vuesCollection = FirebaseFirestore.instance.collection('vues');
    final querySnapshot = await vuesCollection
        .where('userId', isEqualTo: userId)
        .where('idpod', isEqualTo: idpod)
        .get();

    if (querySnapshot.docs.isEmpty) {
      await vuesCollection.add({
        'userId': userId,
        'idpod': idpod,
        'timevue': FieldValue.serverTimestamp(),
        'percent': percent, // ✅ Ajout ici
      });
      await FirebaseFirestore.instance.collection('nofi').add({
        'user1': FirebaseAuth.instance.currentUser?.uid,
        'user2': podcast[0]["idUser"],
        'text': ' See Your Podcast',
        'date': Timestamp.now(),
        'isviewed': false,
      });
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'vue': FieldValue.increment(1),
      });
      final QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUser)
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
      try {
        await FCMService.sendNotification(
          topic: podcast[0]["idUser"],
          title: 'New Vue',
          body: '$fullName has viewed to your podcast',
        );
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> View(double percent) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || idpod == null) return;

    final vuesCollection = FirebaseFirestore.instance.collection('vues');
    final querySnapshot = await vuesCollection
        .where('userId', isEqualTo: userId)
        .where('idpod', isEqualTo: idpod)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;

      await vuesCollection.doc(docId).update({
        'timevue': FieldValue.serverTimestamp(),
        'percent': percent, // ✅ Met à jour le pourcentage écouté
      });
    }
  }

  void _updatePosition(double value) {
    final duration = _audioPlayer.duration;
    if (duration != null) {
      final position = duration * value;
      _audioPlayer.seek(position);
    }
  }

  void _skipBackward() {
    final position = _audioPlayer.position - const Duration(seconds: 10);
    _audioPlayer.seek(position.isNegative ? Duration.zero : position);
  }

  void _skipForward() {
    final position = _audioPlayer.position + const Duration(seconds: 10);
    _audioPlayer.seek(position);
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void handlePreviousPodcast() async {
    if (playlist.isEmpty) {
      // Case a: Podcast doesn't belong to any playlist, replay current podcast
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    // Get all playlists that contain the current podcast
    List<String> containingPlaylistIds = [];
    for (var playlistItem in playlist) {
      String playlistId = playlistItem["id"];
      bool containsPodcast = playinpod.any((podcast) =>
          podcast["id"] == idpod &&
          (podcast["playlistIds"] as List).contains(playlistId));

      if (containsPodcast) {
        containingPlaylistIds.add(playlistId);
      }
    }

    if (containingPlaylistIds.isEmpty) {
      // Should not happen, but if it does, replay current podcast
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    if (containingPlaylistIds.length == 1) {
      // Case b & c: Podcast belongs to only one playlist
      String playlistId = containingPlaylistIds[0];

      // Get all podcasts in this playlist in order
      List<Map<String, dynamic>> podcastsInPlaylist = playinpod
          .where((podcast) =>
              (podcast["playlistIds"] as List).contains(playlistId))
          .toList();

      // Sort podcasts by their order in the playlist (you might need to implement this)
      // For now assuming they're already in order from the query

      // Find current podcast index
      int currentIndex =
          podcastsInPlaylist.indexWhere((podcast) => podcast["id"] == idpod);

      if (currentIndex <= 0) {
        // Case c: Current podcast is the first in playlist, replay it
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
      } else {
        // Case b: Open previous podcast
        String previousPodcastId = podcastsInPlaylist[currentIndex - 1]["id"];
        if (featl == 2) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 2},
          );
        }
        if (featl == 3) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 3},
          );
        }
        if (featl == 4) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 4},
          );
        }
        if (featl == 5) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 5},
          );
        }
        if (featl == 6) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 6},
          );
        }
        if (featl == 7) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 7},
          );
        }
        if (featl == 8) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 8},
          );
        }
        if (featl == 9) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 9},
          );
        }
        if (featl == 12) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 12},
          );
        }
        if (featl == 13) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId, 'featl': 13},
          );
        }
      }
    } else {
      // Cases d & e: Podcast belongs to multiple playlists
      // Start from the last playlist
      containingPlaylistIds = containingPlaylistIds.reversed.toList();

      for (String playlistId in containingPlaylistIds) {
        // Get all podcasts in this playlist
        List<Map<String, dynamic>> podcastsInPlaylist = playinpod
            .where((podcast) =>
                (podcast["playlistIds"] as List).contains(playlistId))
            .toList();

        // Find current podcast index
        int currentIndex =
            podcastsInPlaylist.indexWhere((podcast) => podcast["id"] == idpod);

        if (currentIndex > 0) {
          // Found a playlist where this podcast isn't the first, navigate to previous
          String previousPodcastId = podcastsInPlaylist[currentIndex - 1]["id"];
          if (featl == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 2},
            );
          }
          if (featl == 3) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 3},
            );
          }
          if (featl == 4) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 4},
            );
          }
          if (featl == 5) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 5},
            );
          }
          if (featl == 6) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 6},
            );
          }
          if (featl == 7) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 7},
            );
          }
          if (featl == 8) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 8},
            );
          }
          if (featl == 9) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 9},
            );
          }
          if (featl == 12) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 12},
            );
          }
          if (featl == 13) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': previousPodcastId, 'featl': 13},
            );
          }
          return;
        }
        // If it's the first podcast in this playlist, continue to check other playlists
      }

      // Case e: If we get here, the podcast is the first in all playlists, replay it
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    }
  }

// Implementation for s47 (next podcast) button
  void handleNextPodcast() async {
    if (playlist.isEmpty) {
      // Case a: Podcast doesn't belong to any playlist, let it play to the end
      // No action needed, the player will naturally reach the end
      return;
    }

    // Get all playlists that contain the current podcast
    List<String> containingPlaylistIds = [];
    for (var playlistItem in playlist) {
      String playlistId = playlistItem["id"];
      bool containsPodcast = playinpod.any((podcast) =>
          podcast["id"] == idpod &&
          (podcast["playlistIds"] as List).contains(playlistId));

      if (containsPodcast) {
        containingPlaylistIds.add(playlistId);
      }
    }

    if (containingPlaylistIds.isEmpty) {
      // Should not happen, but if it does, let it play to the end
      return;
    }

    if (containingPlaylistIds.length == 1) {
      // Case b & c: Podcast belongs to only one playlist
      String playlistId = containingPlaylistIds[0];

      // Get all podcasts in this playlist in order
      List<Map<String, dynamic>> podcastsInPlaylist = playinpod
          .where((podcast) =>
              (podcast["playlistIds"] as List).contains(playlistId))
          .toList();

      // Find current podcast index
      int currentIndex =
          podcastsInPlaylist.indexWhere((podcast) => podcast["id"] == idpod);

      if (currentIndex >= podcastsInPlaylist.length - 1) {
        // Case c: Current podcast is the last in playlist, let it play to the end
        // No action needed
      } else {
        // Case b: Open next podcast
        String nextPodcastId = podcastsInPlaylist[currentIndex + 1]["id"];
        if (featl == 2) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 2},
          );
        }
        if (featl == 3) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 3},
          );
        }
        if (featl == 4) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 4},
          );
        }
        if (featl == 5) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 5},
          );
        }
        if (featl == 6) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 6},
          );
        }
        if (featl == 7) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 7},
          );
        }
        if (featl == 8) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 8},
          );
        }
        if (featl == 9) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 9},
          );
        }
        if (featl == 12) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 12},
          );
        }
        if (featl == 13) {
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId, 'featl': 13},
          );
        }
      }
    } else {
      // Cases d & e: Podcast belongs to multiple playlists
      // Start from the first playlist (not reversed like in previous function)

      for (String playlistId in containingPlaylistIds) {
        // Get all podcasts in this playlist
        List<Map<String, dynamic>> podcastsInPlaylist = playinpod
            .where((podcast) =>
                (podcast["playlistIds"] as List).contains(playlistId))
            .toList();

        // Find current podcast index
        int currentIndex =
            podcastsInPlaylist.indexWhere((podcast) => podcast["id"] == idpod);

        if (currentIndex < podcastsInPlaylist.length - 1) {
          // Found a playlist where this podcast isn't the last, navigate to next
          String nextPodcastId = podcastsInPlaylist[currentIndex + 1]["id"];
          if (featl == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 2},
            );
          }
          if (featl == 3) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 3},
            );
          }
          if (featl == 4) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 4},
            );
          }
          if (featl == 5) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 5},
            );
          }
          if (featl == 6) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 6},
            );
          }
          if (featl == 7) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 7},
            );
          }
          if (featl == 8) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 8},
            );
          }
          if (featl == 9) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 9},
            );
          }
          if (featl == 12) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 12},
            );
          }
          if (featl == 13) {
            Navigator.pushReplacementNamed(
              context,
              '/listen',
              arguments: {'idpod': nextPodcastId, 'featl': 13},
            );
          }
          return;
        }
        // If it's the last podcast in this playlist, continue to check other playlists
      }

      // Case e: If we get here, the podcast is the last in all playlists, let it play to the end
      // No action needed
    }
  }

  void handlePreviousPodcast1() {
    if (podcastPlaylists.isEmpty) {
      // Revenir au début du podcast actuel
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        podcastPlaylists.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    if (currentIndex > 0) {
      // Il y a un podcast précédent dans la playlist
      String previousPodcastId = podcastPlaylists[currentIndex - 1]["id"];

      Navigator.pushReplacementNamed(
        context,
        '/listen',
        arguments: {
          'idpod': previousPodcastId,
          'featl': 11,
          'idplay1': playlist[0]['id']
        },
      );
    } else {
      // C'est le premier podcast de la playlist, revenir au début

      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    }
  }

// Fonction pour naviguer au podcast suivant dans la playlist actuelle
  void handleNextPodcast1() {
    if (podcastPlaylists.isEmpty) {
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        podcastPlaylists.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      return;
    }

    if (currentIndex < podcastPlaylists.length - 1) {
      // Il y a un podcast suivant dans la playlist
      String nextPodcastId = podcastPlaylists[currentIndex + 1]["id"];

      Navigator.pushReplacementNamed(
        context,
        '/listen',
        arguments: {
          'idpod': nextPodcastId,
          'featl': 11,
          'idplay1': playlist[0]['id']
        },
      );
    } else {
      // C'est le dernier podcast de la playlist, laisser se terminer naturellement
    }
  }

  void handlePreviousPodcast2() {
    if (mesPodcasts12.isEmpty) {
      // Revenir au début du podcast actuel
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        mesPodcasts12.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    if (currentIndex > 0) {
      // Il y a un podcast précédent dans la playlist
      String previousPodcastId = mesPodcasts12[currentIndex - 1]["id"];

      Navigator.pushReplacementNamed(
        context,
        '/listen',
        arguments: {
          'idpod': previousPodcastId,
          'featl': 10,
        },
      );
    } else {
      // C'est le premier podcast de la playlist, revenir au début

      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    }
  }

// Fonction pour naviguer au podcast suivant dans la playlist actuelle
  void handleNextPodcast2() {
    if (mesPodcasts12.isEmpty) {
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        mesPodcasts12.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      return;
    }

    if (currentIndex < mesPodcasts12.length - 1) {
      // Il y a un podcast suivant dans la playlist
      String nextPodcastId = mesPodcasts12[currentIndex + 1]["id"];

      Navigator.pushReplacementNamed(
        context,
        '/listen',
        arguments: {
          'idpod': nextPodcastId,
          'featl': 10,
        },
      );
    } else {
      // C'est le dernier podcast de la playlist, laisser se terminer naturellement
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    final themeProvider1 = Provider.of<ThemeProvider>(context);
    final themeProvider2 = Provider.of<ThemeProvider>(context);
    final themeProvider3 = Provider.of<ThemeProvider>(context);
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Scaffold(
          endDrawer: Drawer(
            backgroundColor:
                themeProvider.isDarkMode ? Colors.black : Colors.white,
            child: ListView(padding: EdgeInsets.all(c.width * 0.02), children: [
              if ([2, 3, 4, 5, 6, 7, 8, 9, 12, 13].contains(featl))
                ...playlist.map((playlistItem) {
                  final playlistName = playlistItem["name"];
                  final playlistId = playlistItem["id"];

                  final associatedPodcasts = playinpod
                      .where((podcast) =>
                          (podcast["playlistIds"] as List).contains(playlistId))
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: c.width * 0.02),
                        child: Text(
                          playlistName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: c.width * 0.05,
                          ),
                        ),
                      ),
                      ...associatedPodcasts.map((item) {
                        return Container(
                          margin: EdgeInsets.all(c.width * 0.02),
                          decoration: BoxDecoration(
                            //  color: isFirst ? Colors.black12 : Colors.transparent,
                            color: item["id"] == idpod
                                ? Colors.black12
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(c.width * 0.04),
                            border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black12,
                            ),
                          ),
                          width: c.width * 0.95,
                          height: c.width * 0.3,
                          child: GestureDetector(
                            onTap: () {
                              if (featl == 2) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 2},
                                );
                              }
                              if (featl == 3) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 3},
                                );
                              }
                              if (featl == 4) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 4},
                                );
                              }
                              if (featl == 5) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 5},
                                );
                              }
                              if (featl == 6) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 6},
                                );
                              }
                              if (featl == 7) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 7},
                                );
                              }
                              if (featl == 8) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 8},
                                );
                              }
                              if (featl == 9) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 9},
                                );
                              }
                              if (featl == 12) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 12},
                                );
                              }
                              if (featl == 13) {
                                idpod = item["id"];
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/listen',
                                  arguments: {'idpod': idpod, 'featl': 13},
                                );
                              }
                            },
                            child: Row(
                              children: [
                                SizedBox(width: c.width * 0.02),
                                Image.network(s48,
                                    width: c.width * 0.07,
                                    height: c.width * 0.07),
                                SizedBox(width: c.width * 0.02),
                                Container(
                                  height: c.width * 0.2,
                                  width: c.width * 0.18,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(c.width * 0.04),
                                    image: DecorationImage(
                                      image: NetworkImage(item["urlPhoto"]!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: c.width * 0.02),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["name"]!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: c.width * 0.035,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                            themeProvider.isDarkMode
                                                ? s111
                                                : s37,
                                            width: c.width * 0.05,
                                            height: c.width * 0.05),
                                        SizedBox(width: c.width * 0.01),
                                        Text(
                                          formatLikes(item["likes"]),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.network(
                                            themeProvider.isDarkMode
                                                ? s108
                                                : s14,
                                            width: c.width * 0.05,
                                            height: c.width * 0.05),
                                        SizedBox(width: c.width * 0.01),
                                        Text(
                                          formatLikes(item["vue"]),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.network(
                                            themeProvider.isDarkMode
                                                ? s112
                                                : s38,
                                            width: c.width * 0.05,
                                            height: c.width * 0.05),
                                        SizedBox(width: c.width * 0.01),
                                        Text(
                                          formatLikes(item["comments"]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                        // ignore: unnecessary_to_list_in_spreads
                      }).toList(),
                    ],
                  );
                  // ignore: unnecessary_to_list_in_spreads
                }).toList(),
              if (featl == 11) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: c.width * 0.02),
                    ),
                    for (var item in podcastPlaylists)
                      Container(
                        margin: EdgeInsets.all(c.width * 0.02),
                        decoration: BoxDecoration(
                          //  color: isFirst ? Colors.black12 : Colors.transparent,
                          color: item["id"] == idpod
                              ? Colors.black12
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(c.width * 0.04),
                          border: Border.all(
                            color: themeProvider.isDarkMode
                                ? Colors.white70
                                : Colors.black12,
                          ),
                        ),
                        width: c.width * 0.95,
                        height: c.width * 0.3,
                        child: GestureDetector(
                          onTap: () {
                            idpod = item["id"];
                            Navigator.pushReplacementNamed(
                              context,
                              '/listen',
                              arguments: {
                                'idpod': idpod,
                                'featl': 11,
                                'idplay1': playlist[0][
                                    'id'] // remplace "someValue" par ce que tu veux représenter
                              },
                            );
                          },
                          child: Row(
                            children: [
                              SizedBox(width: c.width * 0.02),
                              Image.network(s48,
                                  width: c.width * 0.07,
                                  height: c.width * 0.07),
                              SizedBox(width: c.width * 0.02),
                              Container(
                                height: c.width * 0.2,
                                width: c.width * 0.18,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(c.width * 0.04),
                                  image: DecorationImage(
                                    image: NetworkImage(item["urlPhoto"]!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: c.width * 0.02),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"]!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: c.width * 0.035,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Image.network(
                                          themeProvider.isDarkMode ? s111 : s37,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        formatLikes(item["likes"]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.network(
                                          themeProvider.isDarkMode ? s108 : s14,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        formatLikes(item["vue"]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.network(
                                          themeProvider.isDarkMode ? s112 : s38,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        formatLikes(item["comments"]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (featl == 10) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: c.width * 0.02),
                    ),
                    for (var item in mesPodcasts12)
                      Container(
                        margin: EdgeInsets.all(c.width * 0.02),
                        decoration: BoxDecoration(
                          //  color: isFirst ? Colors.black12 : Colors.transparent,
                          color: item["id"] == idpod
                              ? Colors.black12
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(c.width * 0.04),
                          border: Border.all(
                              color: themeProvider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black12),
                        ),
                        width: c.width * 0.95,
                        height: c.width * 0.3,
                        child: GestureDetector(
                          onTap: () {
                            idpod = item["id"];
                            Navigator.pushReplacementNamed(
                              context,
                              '/listen',
                              arguments: {
                                'idpod': idpod,
                                'featl':
                                    10, // remplace "someValue" par ce que tu veux représenter
                              },
                            );
                          },
                          child: Row(
                            children: [
                              SizedBox(width: c.width * 0.02),
                              Image.network(s48,
                                  width: c.width * 0.07,
                                  height: c.width * 0.07),
                              SizedBox(width: c.width * 0.02),
                              Container(
                                height: c.width * 0.2,
                                width: c.width * 0.18,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(c.width * 0.04),
                                  image: DecorationImage(
                                    image: NetworkImage(item["urlPhoto"]!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: c.width * 0.02),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["name"]!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: c.width * 0.035,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Image.network(
                                          themeProvider.isDarkMode ? s111 : s37,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        formatLikes(item["likes"]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.network(
                                          themeProvider.isDarkMode ? s108 : s14,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        formatLikes(item["vue"]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.network(
                                          themeProvider.isDarkMode ? s112 : s38,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        formatLikes(item["comments"]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ]),
          ),
          body: SafeArea(
            child: isLoading
                ? const Annimationwidjet()
                : Builder(
                    builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? Colors.black
                                : Colors.white,
                          ),
                          child: Column(children: [
                            SizedBox(
                                height: c.height * 0.15,
                                child: Stack(children: [
                                  Positioned(
                                    top: c.height * 0.01,
                                    left: c.width * 0.03,
                                    child: IconButton(
                                      onPressed: () {
                                        if (featl == 2 ||
                                            featl == 3 ||
                                            featl == 4 ||
                                            featl == 5 ||
                                            featl == 6 ||
                                            featl == 7 ||
                                            featl == 8 ||
                                            featl == 9 ||
                                            featl == 12 ||
                                            featl == 11 ||
                                            featl == 10 ||
                                            featl == 13) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      icon: Image.network(
                                        themeProvider.isDarkMode ? s97 : s18,
                                        width: c.width * 0.07,
                                        height: c.width * 0.07,
                                      ),
                                    ),
                                  ),
                                  if (playinpod
                                      .any((p) => p["id"] == idpod)) ...[
                                    Positioned(
                                      top: c.height * 0.025,
                                      right: c.width * 0.04,
                                      child: GestureDetector(
                                        onTap: () {
                                          Scaffold.of(context).openEndDrawer();
                                        },
                                        child: Image.network(
                                            themeProvider.isDarkMode
                                                ? s137
                                                : s44,
                                            width: c.width * 0.06,
                                            height: c.width * 0.06),
                                      ),
                                    ),
                                    SizedBox(
                                      height: c.height * 0.2,
                                      child: Stack(children: [
                                        if (featl == 2 ||
                                            featl == 3 ||
                                            featl == 4 ||
                                            featl == 5 ||
                                            featl == 6 ||
                                            featl == 7 ||
                                            featl == 8 ||
                                            featl == 9 ||
                                            featl == 12 ||
                                            featl == 13) ...[
                                          Positioned(
                                            top: c.height * 0.04,
                                            left: c.width * 0.17,
                                            // ignore: sized_box_for_whitespace
                                            child: Container(
                                              width: c.width * 0.7,
                                              height: c.width *
                                                  0.06, // Définit une hauteur pour éviter les bugs d'affichage

                                              child: // Affiche un loader pendant le chargement
                                                  Marquee(
                                                text: playinpod
                                                    .firstWhere(
                                                        (p) => p["id"] == idpod,
                                                        orElse: () => {
                                                              "playlistIds": []
                                                            })["playlistIds"]
                                                    .map((pid) =>
                                                        playlist.firstWhere(
                                                            (pl) =>
                                                                pl["id"] == pid,
                                                            orElse: () => {
                                                                  "name":
                                                                      "Inconnue"
                                                                })["name"])
                                                    .join(
                                                        "     •     "), // Séparer par un symbole
                                                style: TextStyle(
                                                  fontSize: c.width * 0.05,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                scrollAxis: Axis
                                                    .horizontal, // Faire défiler horizontalement
                                                blankSpace:
                                                    50.0, // Espacement avant la répétition
                                                velocity:
                                                    30.0, // Vitesse du défilement
                                                pauseAfterRound: const Duration(
                                                    seconds:
                                                        1), // Pause après un tour
                                                startPadding:
                                                    10.0, // Espace initial
                                                accelerationDuration:
                                                    const Duration(
                                                        seconds:
                                                            1), // Accélération au démarrage
                                                accelerationCurve:
                                                    Curves.easeIn,
                                                decelerationDuration:
                                                    const Duration(
                                                        milliseconds:
                                                            500), // Décélération à la fin
                                                decelerationCurve:
                                                    Curves.easeOut,
                                              ),
                                            ),
                                          )
                                        ],
                                        if (featl == 11) ...[
                                          Positioned(
                                            top: c.height * 0.04,
                                            left: c.width * 0.17,
                                            child: SizedBox(
                                              width: c.width * 0.7,
                                              height: c.width *
                                                  0.06, // Définit une hauteur pour éviter les bugs d'affichage

                                              child: // Affiche un loader pendant le chargement
                                                  Marquee(
                                                text: playlist[0][
                                                    "name"], // Séparer par un symbole
                                                style: TextStyle(
                                                  fontSize: c.width * 0.05,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                scrollAxis: Axis
                                                    .horizontal, // Faire défiler horizontalement
                                                blankSpace:
                                                    50.0, // Espacement avant la répétition
                                                velocity:
                                                    30.0, // Vitesse du défilement
                                                pauseAfterRound: const Duration(
                                                    seconds:
                                                        1), // Pause après un tour
                                                startPadding:
                                                    10.0, // Espace initial
                                                accelerationDuration:
                                                    const Duration(
                                                        seconds:
                                                            1), // Accélération au démarrage
                                                accelerationCurve:
                                                    Curves.easeIn,
                                                decelerationDuration:
                                                    const Duration(
                                                        milliseconds:
                                                            500), // Décélération à la fin
                                                decelerationCurve:
                                                    Curves.easeOut,
                                              ),
                                            ),
                                          )
                                        ],
                                        if (featl == 10) ...[
                                          Positioned(
                                            top: c.height * 0.04,
                                            left: c.width * 0.17,
                                            child: SizedBox(
                                              width: c.width * 0.7,
                                              height: c.width *
                                                  0.06, // Définit une hauteur pour éviter les bugs d'affichage

                                              child: // Affiche un loader pendant le chargement
                                                  Marquee(
                                                text:
                                                    "My Playlist", // Séparer par un symbole
                                                style: TextStyle(
                                                  fontSize: c.width * 0.05,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                scrollAxis: Axis
                                                    .horizontal, // Faire défiler horizontalement
                                                blankSpace:
                                                    50.0, // Espacement avant la répétition
                                                velocity:
                                                    30.0, // Vitesse du défilement
                                                pauseAfterRound: const Duration(
                                                    seconds:
                                                        1), // Pause après un tour
                                                startPadding:
                                                    10.0, // Espace initial
                                                accelerationDuration:
                                                    const Duration(
                                                        seconds:
                                                            1), // Accélération au démarrage
                                                accelerationCurve:
                                                    Curves.easeIn,
                                                decelerationDuration:
                                                    const Duration(
                                                        milliseconds:
                                                            500), // Décélération à la fin
                                                decelerationCurve:
                                                    Curves.easeOut,
                                              ),
                                            ),
                                          )
                                        ],
                                      ]),
                                    ),
                                  ]
                                ])),
                            SizedBox(
                              width: c.width * 0.85,
                              height: c.width * 0.85,
                              child: Container(
                                height: c.width * 0.85,
                                width: c.width * 0.85,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(c.width * 0.04),
                                  image: DecorationImage(
                                    image: NetworkImage(podcast[0]["urlPhoto"]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: c.height * 0.15,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: c.height * 0.02,
                                    left: c.width * 0.05,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: c.width * 0.9,
                                          height: c.height * 0.05,
                                          child: Marquee(
                                            text: podcast[0]["name"],
                                            style: TextStyle(
                                              fontSize: c.width * 0.05,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            scrollAxis: Axis.horizontal,
                                            blankSpace: 20.0,
                                            velocity: 30.0,
                                            pauseAfterRound:
                                                const Duration(seconds: 1),
                                            startPadding: 10.0,
                                            accelerationDuration:
                                                const Duration(seconds: 1),
                                            accelerationCurve: Curves.linear,
                                            decelerationDuration:
                                                const Duration(seconds: 1),
                                            decelerationCurve: Curves.easeOut,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // Like button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                onTap: _toggleLike,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      c.width * 0.02),
                                                  child: Image.network(
                                                    getlikeIcon(themeProvider1),
                                                    width: c.width * 0.05,
                                                    height: c.width * 0.05,
                                                    // Désactiver le caching pour forcer le rechargement
                                                    gaplessPlayback: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: c.width * 0.02),
                                            // Unlike button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                onTap: _toggleUnlike,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      c.width * 0.02),
                                                  child: Image.network(
                                                    getunlikeIcon(
                                                        themeProvider2),
                                                    width: c.width * 0.05,
                                                    height: c.width * 0.05,
                                                    gaplessPlayback: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: c.width * 0.02),
                                            // Comment button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        c.width * 0.075),
                                                onTap: _showCommentsModal,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      c.width * 0.02),
                                                  child: Image.network(
                                                    themeProvider.isDarkMode
                                                        ? s112
                                                        : s38,
                                                    width: c.width * 0.05,
                                                    height: c.width * 0.05,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                width: c.width *
                                                    0.02), // Save button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                onTap: _toggleSave,
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      c.width * 0.02),
                                                  child: Image.network(
                                                    getSaveIcon(themeProvider3),
                                                    width: c.width * 0.05,
                                                    height: c.width * 0.05,
                                                    gaplessPlayback: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: c.width * 0.05),
                              child: Column(
                                children: [
                                  // Progress bar with times
                                  Row(
                                    children: [
                                      // Current time
                                      Text(
                                        currentTime,
                                        style: TextStyle(
                                          fontSize: c.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      // Progress slider
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: c.width * 0.01,
                                            thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius:
                                                  c.width * 0.02,
                                            ),
                                            activeTrackColor:
                                                const Color(0xFF754CEF),
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                            thumbColor: const Color(0xFF754CEF),
                                            overlayColor:
                                                const Color(0xFF754CEF)
                                                    .withOpacity(0.2),
                                          ),
                                          child: Slider(
                                            value:
                                                currentPosition.clamp(0.0, 1.0),
                                            onChanged: _updatePosition,
                                          ),
                                        ),
                                      ),

                                      // Total time
                                      Text(
                                        totalTime,
                                        style: TextStyle(
                                          fontSize: c.width * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: c.height * 0.01),

                                  // Playback controls
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // Skip backward 30s
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          onTap: _skipBackward,
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  Icons.replay_10,
                                                  size: c.width * 0.08,
                                                  color:
                                                      themeProvider.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          onTap: () {
                                            if (featl == 2 ||
                                                featl == 3 ||
                                                featl == 4 ||
                                                featl == 5 ||
                                                featl == 6 ||
                                                featl == 7 ||
                                                featl == 8 ||
                                                featl == 9 ||
                                                featl == 12 ||
                                                featl == 11 ||
                                                featl == 10 ||
                                                featl == 13) {
                                              handlePreviousPodcast();
                                            }
                                            if (featl == 11) {
                                              handlePreviousPodcast1();
                                            }
                                            if (featl == 10) {
                                              handlePreviousPodcast2();
                                            }
                                          },
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image.network(
                                                  themeProvider.isDarkMode
                                                      ? s138
                                                      : s46,
                                                  width: c.width *
                                                      0.08, // Adjust size using width/height
                                                  height: c.width * 0.08,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Play/Pause button
                                      Material(
                                        color: const Color(0xFF754CEF),
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: _togglePlayPause,
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(c.width * 0.03),
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              size: c.width * 0.08,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          onTap: () {
                                            if (featl == 2 ||
                                                featl == 3 ||
                                                featl == 4 ||
                                                featl == 5 ||
                                                featl == 6 ||
                                                featl == 7 ||
                                                featl == 8 ||
                                                featl == 9 ||
                                                featl == 12 ||
                                                featl == 11 ||
                                                featl == 10 ||
                                                featl == 13) {
                                              handleNextPodcast();
                                            }
                                            if (featl == 11) {
                                              handleNextPodcast1();
                                            }
                                            if (featl == 10) {
                                              handleNextPodcast2();
                                            }
                                          },
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Image.network(
                                                  themeProvider.isDarkMode
                                                      ? s139
                                                      : s47,
                                                  width: c.width *
                                                      0.08, // Adjust size using width/height
                                                  height: c.width * 0.08,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Skip forward 30s
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          onTap: _skipForward,
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  Icons.forward_10,
                                                  size: c.width * 0.08,
                                                  color:
                                                      themeProvider.isDarkMode
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        )),
          ));
    });
  }
}

class Comment {
  final String photo;
  final String username;
  final String content;
  final String date;
  final List<Comment> replies;

  Comment({
    required this.photo,
    required this.username,
    required this.content,
    required this.date,
    required this.replies,
  });
}

// Comment Tree Widget
