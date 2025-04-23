import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pfeapp/constants.dart';
import 'package:marquee/marquee.dart';
import 'package:intl/intl.dart';

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
  List<Map<String, dynamic>> playlist = [];
  List<Map<String, dynamic>> playinpod = [];
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> mesPodcasts12 = [];
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

  Future<void> nbrpodId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      final playinPodSnapshot = await FirebaseFirestore.instance
          .collection('myplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .get();

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
              .get();

          for (var doc in podSnapshot.docs) {
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
          Timestamp? dateA = a['dateCreation'];
          Timestamp? dateB = b['dateCreation'];
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA); // Tri décroissant
        });

        setState(() {
          mesPodcasts12 = allPodcasts;
        });
      } else {
        setState(() {
          mesPodcasts12 = [];
        });
        debugPrint("Aucun podcast trouvé dans la playlist.");
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des podcasts : $e");
      setState(() {
        mesPodcasts12 = [];
      });
    }
  }

  Future<void> fetchPlaylidtById12(String idplay1) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .where('id', isEqualTo: idplay1)
          .get();

      setState(() {
        playlist = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      debugPrint("Podcasts récupérés : ${playlist.length}");
    } catch (e) {
      debugPrint("Erreur lors du chargement des podcasts : $e");
    }
  }

  Future<void> fetchPlaylistsByPodcastId12(String idplay1) async {
    try {
      final playinPodSnapshot = await FirebaseFirestore.instance
          .collection('playinpod')
          .where('playlistId', isEqualTo: idplay1)
          .orderBy('date',
              descending: true) // ⬅️ Trie par date DESC de playinpod
          .get();

      // 🔁 Récupérer les podcasts avec leur date d'ajout
      List<Map<String, dynamic>> podInfos = [];

      for (var doc in playinPodSnapshot.docs) {
        final data = doc.data();
        final podcastId = data['podcastId'];
        final date = data['date'];

        // On garde l’ordre, donc on ne filtre pas les doublons ici
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
              .get();

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

        debugPrint(
            "🎧 Podcasts récupérés et triés par date (playinpod) : ${podcastPlaylists.length}");
      } else {
        setState(() {
          podcastPlaylists = [];
        });
        debugPrint("Aucun podcast trouvé pour cette playlist.");
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des podcasts : $e");
      setState(() {
        podcastPlaylists = [];
      });
    }
  }

  List<Map<String, dynamic>> podcastPlaylists = [];
  Future<void> fetchPodcastsById(String idpod) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .get();

      setState(() {
        podcast = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });

      debugPrint("Podcasts récupérés : ${podcast.length}");
    } catch (e) {
      debugPrint("Erreur lors du chargement des podcasts : $e");
    }
  }

  Future<void> fetchPlaylistsByPodcastId(String idpod) async {
    try {
      // 1️⃣ Récupérer les `playlistId` associés au `idpod`
      final playinPodSnapshot = await FirebaseFirestore.instance
          .collection('playinpod')
          .orderBy('date', descending: true)
          .where('podcastId', isEqualTo: idpod)
          .get();
      final List<Map<String, dynamic>> playinPodData = playinPodSnapshot.docs
          .map((doc) => {
                "podcastId": doc['podcastId'],
                "playlistId": doc['playlistId'],
                "date": doc['date'], // Conserver la date pour le tri ultérieur
              })
          .toList();
      final List<String> playlistIds =
          playinPodData.map((item) => item["playlistId"] as String).toList();
      debugPrint("Playlists trouvées dans playinpod : $playlistIds");

      if (playlistIds.isNotEmpty) {
        // 2️⃣ Récupérer les playlists correspondant aux `playlistId`
        final playlistSnapshot = await FirebaseFirestore.instance
            .collection('playlist')
            .where(FieldPath.documentId, whereIn: playlistIds)
            .get();

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
            .get();

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
        debugPrint("Podcasts liés aux playlists trouvés : $podcastIds");

        if (podcastIds.isNotEmpty) {
          // 4️⃣ Récupérer les podcasts avec `podcastIds`
          final podcastSnapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .where(FieldPath.documentId, whereIn: podcastIds)
              .get();

          List<Map<String, dynamic>> loadedPodcasts =
              podcastSnapshot.docs.map((doc) {
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

          setState(() {
            playlist = loadedPlaylists;
            playinpod = loadedPodcasts;
          });
          debugPrint("Podcasts finaux récupérés : ${playinpod.length}");
        }
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des playlists : $e");
    }
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
      setState(() => isLoading = true);

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
          await _initAudioPlayer();
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

      setState(() => isLoading = false);
    });
  }

  String? idplay1;
// First, let's add a specific function to debug a single user ID
  Future<void> _debugUserDocument(String userId) async {
    try {
      print("Debugging user document: $userId");

      // Approach 1: Direct document reference
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        print("✓ Direct reference: User exists: $userId");
        print("User data: ${userDoc.data()}");
      } else {
        print("✗ Direct reference: User does not exist: $userId");
      }

      // Approach 2: Query by ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print("✓ Query: User exists: $userId");
        print("User data: ${querySnapshot.docs.first.data()}");
      } else {
        print("✗ Query: User does not exist: $userId");
      }

      // Optional: Check exact user ID format
      print(
          "User ID hex representation: ${userId.codeUnits.map((u) => u.toRadixString(16).padLeft(2, '0')).join(' ')}");
      print("User ID length: ${userId.length}");
    } catch (e) {
      print("Error debugging user document: $e");
    }
  }

  late int nbc = 0;
  Future<List<Map<String, dynamic>>> _fetchComments() async {
    try {
      print("Fetching comments for podcast ID: $idpod");

      // 1️⃣ Récupérer tous les commentaires liés au podcast
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .orderBy('date', descending: true)
          .where('idpod', isEqualTo: idpod)
          .get();

      if (commentSnapshot.docs.isEmpty) return [];

      print("Found ${commentSnapshot.docs.length} comments");
      nbc = commentSnapshot.docs.length;
      List<Map<String, dynamic>> comments = [];
      Set<String> userIds = {}; // Pour stocker les userId uniques

      // 2️⃣ Extraction des userId des commentaires et des réponses
      for (var doc in commentSnapshot.docs) {
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
          Map<String, dynamic> replyData = reply.data() as Map<String, dynamic>;

          if (replyData.containsKey('userid') &&
              replyData['userid'] is String) {
            userIds.add(replyData['userid']);
          }
        }
      }

      print("Unique user IDs collected: ${userIds.length}");

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

        print("Found ${userSnapshot.docs.length} users for this chunk");

        for (var userDoc in userSnapshot.docs) {
          // Store using 'userId' as the key, not document ID
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          String userId = userData['userId'] as String;
          userMap[userId] = userData; // Store with userId as key for lookup

          print("Added user to map: $userId");
        }
      }

      print("Users found: ${userMap.length} / ${userIds.length}");

      // 4️⃣ Associer les utilisateurs aux commentaires et récupérer les réponses
      for (var doc in commentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        // Associer l'utilisateur du commentaire
        String? userId = data['userid'] as String?;
        print("Looking up user for comment userId: $userId");

        if (userId != null && userMap.containsKey(userId)) {
          print("User found for comment!");
          data['user'] = {
            'firstName': userMap[userId]?['firstName'] ?? 'Unknown',
            'lastName': userMap[userId]?['lastName'] ?? 'User',
            'photoUrl': userMap[userId]?['photoUrl']
          };
        } else {
          print("User NOT found for comment userId: $userId");
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
          Map<String, dynamic> replyData = reply.data() as Map<String, dynamic>;
          replyData['id'] = reply.id;

          String? replyUserId = replyData['userid'] as String?;
          print("Looking up user for reply userId: $replyUserId");

          if (replyUserId != null && userMap.containsKey(replyUserId)) {
            print("User found for reply!");
            replyData['user'] = {
              'firstName': userMap[replyUserId]?['firstName'] ?? 'Unknown',
              'lastName': userMap[replyUserId]?['lastName'] ?? 'User',
              'photoUrl': userMap[replyUserId]?['photoUrl']
            };
          } else {
            print("User NOT found for reply userId: $replyUserId");
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
        comments.add(data);
      }

      print("Returning ${comments.length} comments with user data");
      return comments;
    } catch (e, stackTrace) {
      print("Error in _fetchComments: $e");
      print("Stack trace: $stackTrace");
      return [];
    }
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
    setState(() {});
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
            return Padding(
              padding: EdgeInsets.only(
                  top: 16.0, bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(" "),
                    Text("Comments",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder(
                      future: _fetchComments(),
                      builder: (context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No comments yet"));
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final comment = snapshot.data![index];
                            final user = comment['user'];
                            final replies = comment['replies'] as List<dynamic>;
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
                                          user['photoUrl']!.trim().isNotEmpty
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user['photoUrl']))
                                      : CircleAvatar(child: Icon(Icons.person)),
                                  title: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: comment['user'] != null
                                              ? "${comment['user']['firstName']} ${comment['user']['lastName']}"
                                              : "Unknown User",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        if (isCreator)
                                          TextSpan(
                                            text: " Creator",
                                            style: const TextStyle(
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
                                      Text(comment['text'] ?? ""),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment['date'] != null
                                            ? DateFormat('MMM d, yyyy • h:mm a')
                                                .format(
                                                    comment['date'].toDate())
                                            : "",
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
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
                                            () => _deleteComment(comment['id']),
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
                                        icon: const Icon(Icons.reply, size: 16),
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
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: replies.length,
                                        itemBuilder: (context, replyIndex) {
                                          final reply = replies[replyIndex];
                                          final isCurrentUserReply =
                                              FirebaseAuth.instance.currentUser
                                                      ?.uid ==
                                                  reply['userid'];
                                          final isReplyCreator =
                                              reply['userid'] ==
                                                  podcast[0]['idUser'];

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 12),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                              reply['user']
                                                                  ['photoUrl'])
                                                          : null,
                                                      child: reply['user'] ==
                                                                  null ||
                                                              reply['user'][
                                                                      'photoUrl'] ==
                                                                  null
                                                          ? Icon(Icons.person,
                                                              size: 16)
                                                          : null,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        children: [
                                                                          TextSpan(
                                                                            text: reply['user'] != null
                                                                                ? "${reply['user']['firstName']} ${reply['user']['lastName']}"
                                                                                : "Unknown User",
                                                                          ),
                                                                          if (isReplyCreator)
                                                                            TextSpan(
                                                                              text: " Creator",
                                                                              style: const TextStyle(
                                                                                color: Color(0xFF754CEF),
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                          // Always display @username for all replies
                                                                          if (reply['replyToUsername'] != null &&
                                                                              reply['replyToUsername'].isNotEmpty)
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
                                                                    Text(reply[
                                                                            'text'] ??
                                                                        ""),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (isCurrentUserReply)
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size: 16,
                                                                      color: Colors
                                                                          .red),
                                                                  onPressed: () =>
                                                                      _showDeleteConfirmation(
                                                                    context,
                                                                    () => _deleteReply(
                                                                        comment[
                                                                            'id'],
                                                                        reply[
                                                                            'id']),
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
                                                                    .format(reply[
                                                                            'date']
                                                                        .toDate())
                                                                : "",
                                                            style:
                                                                const TextStyle(
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
                                                padding: const EdgeInsets.only(
                                                    left: 40, bottom: 8),
                                                child: TextButton.icon(
                                                  icon: const Icon(Icons.reply,
                                                      size: 14),
                                                  label: const Text("Reply",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                  onPressed: () {
                                                    String replyUsername = reply[
                                                                'user'] !=
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
                          icon:
                              const Icon(Icons.send, color: Color(0xFF754CEF)),
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
                onDeleteConfirmed();
              },
            ),
          ],
        );
      },
    );
  }

  void _showReplyInput(BuildContext context, String commentId,
      String? parentReplyId, String? replyToUsername) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            parentReplyId == null
                ? "Reply to comment"
                : "Reply to ${replyToUsername ?? 'reply'}",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: replyController,
          decoration: InputDecoration(
            hintText: 'Write your reply...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
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
            child: Text('Reply'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF754CEF),
            ),
          ),
        ],
      ),
    );
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('comments').add({
        'userid': FirebaseAuth.instance.currentUser?.uid,
        'idpod': idpod,
        'text': _commentController.text,
        'date': Timestamp.now(),
      });
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'comments': FieldValue.increment(1),
      });
      _commentController.clear();
      setState(() {});
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
        print("No user data found for user: ${user.uid}");
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

      _commentController.clear();
    } catch (e) {
      print('Error adding reply: $e');
    }
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
    setState(() {});
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

    setState(() {});
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

  bool isSaved = false;
  bool isLiked = false;
  bool isUnliked = false;
  String likeIcon = s37; // Icône de like par défaut
  String unlikeIcon = s41; // Icône d'unlike par défaut
  String saveIcon = s42; // Icône de like par défaut
  final currentUser = FirebaseAuth.instance.currentUser?.uid;
  Future<void> _fetchLikeStatus() async {
    final likeRef = FirebaseFirestore.instance.collection('like');
    final likeQuery = await likeRef
        .where('iduser', isEqualTo: currentUser)
        .where('idpod', isEqualTo: idpod)
        .get();

    setState(() {
      isLiked = likeQuery.docs.isNotEmpty;
      likeIcon = isLiked ? s39 : s37;
    });
  }

  Future<void> _fetchsaveStatus() async {
    final saveRef = FirebaseFirestore.instance.collection('myplaylist');
    final saveQuery = await saveRef
        .where('iduser', isEqualTo: currentUser)
        .where('idpod', isEqualTo: idpod)
        .get();

    setState(() {
      isSaved = saveQuery.docs.isNotEmpty;
      saveIcon = isSaved ? s43 : s42;
    });
  }

  Future<void> _fetchUnlikeStatus() async {
    final unlikeRef = FirebaseFirestore.instance.collection('unlike');
    final unlikeQuery = await unlikeRef
        .where('iduser', isEqualTo: currentUser)
        .where('idpod', isEqualTo: idpod)
        .get();

    setState(() {
      isUnliked = unlikeQuery.docs.isNotEmpty;
      unlikeIcon = isUnliked ? s40 : s41;
    });
  }

  void _toggleLike() async {
    final likeRef = FirebaseFirestore.instance.collection('like');
    final unlikeRef = FirebaseFirestore.instance.collection('unlike');

    if (!isLiked) {
      // Ajouter le like
      await likeRef.add({
        'iduser': currentUser,
        'idpod': idpod,
        'dateCreation': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'likes': FieldValue.increment(1),
      });
      setState(() {
        isLiked = true;
        likeIcon = s39;
      });

      // Supprimer l'unlike s'il existe
      if (isUnliked) {
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
          });
        }
        setState(() {
          isUnliked = false;
          unlikeIcon = s41;
        });
      }
    } else {
      // Supprimer le like
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
        });
      }
      setState(() {
        isLiked = false;
        likeIcon = s37;
      });
    }
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
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'save': FieldValue.increment(1),
      });
      setState(() {
        isSaved = true;
        saveIcon = s43;
      });
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
      setState(() {
        isSaved = false;
        saveIcon = s42;
      });
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
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'unlikes': FieldValue.increment(1),
      });
      setState(() {
        isUnliked = true;
        unlikeIcon = s40;
      });

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
        setState(() {
          isLiked = false;
          likeIcon = s37;
        });
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
      setState(() {
        isUnliked = false;
        unlikeIcon = s41;
      });
    }
  }

  bool hasViewed = false;
  Future<void> _initAudioPlayer() async {
    try {
      if (podcast.isNotEmpty && podcast[0]['urlFile'] != null) {
        String url = podcast[0]['urlFile'];
        debugPrint("URL du fichier audio : $url");
        await _audioPlayer.setUrl(url);
      }

      _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            totalTime = _formatDuration(duration);
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        final duration = _audioPlayer.duration;
        if (duration != null) {
          double percent = position.inMilliseconds / duration.inMilliseconds;
          setState(() {
            currentTime = _formatDuration(position);
            currentPosition = percent;
            audioProgressPercent = percent;
          });

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
        setState(() {
          isPlaying = state.playing;
        });
      });
    } catch (e) {
      print('Error loading audio file: $e');
    }
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

      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'vue': FieldValue.increment(1),
      });
    }
  }

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
    final position = _audioPlayer.position - Duration(seconds: 10);
    _audioPlayer.seek(position.isNegative ? Duration.zero : position);
  }

  void _skipForward() {
    final position = _audioPlayer.position + Duration(seconds: 10);
    _audioPlayer.seek(position);
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString();
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
      debugPrint("Aucun podcast disponible dans cette playlist");
      // Revenir au début du podcast actuel
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        podcastPlaylists.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      debugPrint("Podcast actuel non trouvé dans la playlist");
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    if (currentIndex > 0) {
      // Il y a un podcast précédent dans la playlist
      String previousPodcastId = podcastPlaylists[currentIndex - 1]["id"];
      debugPrint(
          "Navigation vers le podcast précédent: ${podcastPlaylists[currentIndex - 1]["title"]}");

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
      debugPrint("Premier podcast de la playlist, retour au début");
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    }
  }

// Fonction pour naviguer au podcast suivant dans la playlist actuelle
  void handleNextPodcast1() {
    if (podcastPlaylists.isEmpty) {
      debugPrint("Aucun podcast disponible dans cette playlist");
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        podcastPlaylists.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      debugPrint("Podcast actuel non trouvé dans la playlist");
      return;
    }

    if (currentIndex < podcastPlaylists.length - 1) {
      // Il y a un podcast suivant dans la playlist
      String nextPodcastId = podcastPlaylists[currentIndex + 1]["id"];
      debugPrint(
          "Navigation vers le podcast suivant: ${podcastPlaylists[currentIndex + 1]["title"]}");

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
      debugPrint("Dernier podcast de la playlist, aucune action");
    }
  }

  void handlePreviousPodcast2() {
    if (mesPodcasts12.isEmpty) {
      debugPrint("Aucun podcast disponible dans cette playlist");
      // Revenir au début du podcast actuel
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        mesPodcasts12.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      debugPrint("Podcast actuel non trouvé dans la playlist");
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
      debugPrint("Premier podcast de la playlist, retour au début");
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    }
  }

// Fonction pour naviguer au podcast suivant dans la playlist actuelle
  void handleNextPodcast2() {
    if (mesPodcasts12.isEmpty) {
      debugPrint("Aucun podcast disponible dans cette playlist");
      return;
    }

    // Trouver l'index du podcast actuel
    int currentIndex =
        mesPodcasts12.indexWhere((podcast) => podcast["id"] == idpod);

    if (currentIndex == -1) {
      debugPrint("Podcast actuel non trouvé dans la playlist");
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
      debugPrint("Dernier podcast de la playlist, aucune action");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Scaffold(
        endDrawer: Drawer(
          backgroundColor: Colors.white,
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
                          border: Border.all(color: Colors.black12),
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
                                      Image.network(s37,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        item["likes"].toString(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.network(s14,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        item["vue"].toString(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.network(s38,
                                          width: c.width * 0.05,
                                          height: c.width * 0.05),
                                      SizedBox(width: c.width * 0.01),
                                      Text(
                                        item["comments"].toString(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
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
                        border: Border.all(color: Colors.black12),
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
                                width: c.width * 0.07, height: c.width * 0.07),
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
                                    Image.network(s37,
                                        width: c.width * 0.05,
                                        height: c.width * 0.05),
                                    SizedBox(width: c.width * 0.01),
                                    Text(
                                      item["likes"].toString(),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.network(s14,
                                        width: c.width * 0.05,
                                        height: c.width * 0.05),
                                    SizedBox(width: c.width * 0.01),
                                    Text(
                                      item["vue"].toString(),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.network(s38,
                                        width: c.width * 0.05,
                                        height: c.width * 0.05),
                                    SizedBox(width: c.width * 0.01),
                                    Text(
                                      item["comments"].toString(),
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
                        border: Border.all(color: Colors.black12),
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
                                width: c.width * 0.07, height: c.width * 0.07),
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
                                    Image.network(s37,
                                        width: c.width * 0.05,
                                        height: c.width * 0.05),
                                    SizedBox(width: c.width * 0.01),
                                    Text(
                                      item["likes"].toString(),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.network(s14,
                                        width: c.width * 0.05,
                                        height: c.width * 0.05),
                                    SizedBox(width: c.width * 0.01),
                                    Text(
                                      item["vue"].toString(),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Image.network(s38,
                                        width: c.width * 0.05,
                                        height: c.width * 0.05),
                                    SizedBox(width: c.width * 0.01),
                                    Text(
                                      item["comments"].toString(),
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
        body: isLoading
            ? Center(child: Text(""))
            : SafeArea(
                child: Builder(
                    builder: (context) => Container(
                          decoration: BoxDecoration(color: Colors.white),
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
                                        s18,
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
                                        child: Image.network(s44,
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
                                                pauseAfterRound: Duration(
                                                    seconds:
                                                        1), // Pause après un tour
                                                startPadding:
                                                    10.0, // Espace initial
                                                accelerationDuration: Duration(
                                                    seconds:
                                                        1), // Accélération au démarrage
                                                accelerationCurve:
                                                    Curves.easeIn,
                                                decelerationDuration: Duration(
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
                                            child: Container(
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
                                                pauseAfterRound: Duration(
                                                    seconds:
                                                        1), // Pause après un tour
                                                startPadding:
                                                    10.0, // Espace initial
                                                accelerationDuration: Duration(
                                                    seconds:
                                                        1), // Accélération au démarrage
                                                accelerationCurve:
                                                    Curves.easeIn,
                                                decelerationDuration: Duration(
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
                                            child: Container(
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
                                                pauseAfterRound: Duration(
                                                    seconds:
                                                        1), // Pause après un tour
                                                startPadding:
                                                    10.0, // Espace initial
                                                accelerationDuration: Duration(
                                                    seconds:
                                                        1), // Accélération au démarrage
                                                accelerationCurve:
                                                    Curves.easeIn,
                                                decelerationDuration: Duration(
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
                                        Container(
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
                                                Duration(seconds: 1),
                                            startPadding: 10.0,
                                            accelerationDuration:
                                                Duration(seconds: 1),
                                            accelerationCurve: Curves.linear,
                                            decelerationDuration:
                                                Duration(seconds: 1),
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
                                                    likeIcon,
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
                                                    unlikeIcon,
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
                                                    s38,
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
                                                    saveIcon,
                                                    width: c.width * 0.05,
                                                    height: c.width * 0.05,
                                                    gaplessPlayback: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: c.width * 0.02),
                                            // Share button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                onTap: () {
                                                  // Action partage
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.all(
                                                      c.width * 0.02),
                                                  child: Image.network(
                                                    s45,
                                                    width: c.width * 0.05,
                                                    height: c.width * 0.05,
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
                                            activeTrackColor: Color(0xFF754CEF),
                                            inactiveTrackColor:
                                                Colors.grey[300],
                                            thumbColor: Color(0xFF754CEF),
                                            overlayColor: Color(0xFF754CEF)
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
                                                  color: Colors.black,
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
                                                  s46,
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
                                        color: Color(0xFF754CEF),
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
                                                  s47,
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
                                                  color: Colors.black,
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
