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

  String? replyingTo;
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> playlist = [];
  List<Map<String, dynamic>> playinpod = [];
  TextEditingController _commentController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

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
              })
          .toList();

      final List<String> playlistIds =
          playinPodData.map((item) => item["playlistId"] as String).toList();

      debugPrint("Playlists trouvées dans playinpod : $playlistIds");

      if (playlistIds.isNotEmpty) {
        // 2️⃣ Récupérer les playlists correspondant aux `playlistId`
        final playlistSnapshot = await FirebaseFirestore.instance
            .collection('playlist')
            .orderBy('createdAt', descending: true)
            .where(FieldPath.documentId, whereIn: playlistIds)
            .get();

        List<Map<String, dynamic>> loadedPlaylists = playlistSnapshot.docs
            .map((doc) => {
                  "id": doc.id,
                  ...doc.data(),
                })
            .toList();

        // 3️⃣ Associer les podcasts aux playlists
        final playinPodSnapshot2 = await FirebaseFirestore.instance
            .collection('playinpod')
            .orderBy('date', descending: true)
            .where('playlistId', whereIn: playlistIds)
            .get();

        Map<String, List<String>> podcastToPlaylists = {};
        for (var doc in playinPodSnapshot2.docs) {
          String podcastId = doc['podcastId'];
          String playlistId = doc['playlistId'];

          if (!podcastToPlaylists.containsKey(podcastId)) {
            podcastToPlaylists[podcastId] = [];
          }
          podcastToPlaylists[podcastId]!.add(playlistId);
        }

        final List<String> podcastIds = podcastToPlaylists.keys.toList();
        debugPrint("Podcasts liés aux playlists trouvés : $podcastIds");

        if (podcastIds.isNotEmpty) {
          // 4️⃣ Récupérer les podcasts avec `podcastIds`
          final podcastSnapshot = await FirebaseFirestore.instance
              .collection('podcasts')
              .orderBy('dateCreation', descending: true)
              .where(FieldPath.documentId, whereIn: podcastIds)
              .get();

          List<Map<String, dynamic>> loadedPodcasts =
              podcastSnapshot.docs.map((doc) {
            final podcastData = doc.data() as Map<String, dynamic>;
            final podcastId = doc.id;
            return {
              "id": podcastId,
              "playlistIds": podcastToPlaylists[podcastId] ?? [],
              ...podcastData,
            };
          }).toList();

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

  bool isLoading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentTime = "0:00";
  String totalTime = "0:00";
  double currentPosition = 0.0; // Progress value

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null && arguments.containsKey('idpod')) {
        idpod = arguments['idpod'];

        if (idpod != null) {
          await fetchPodcastsById(idpod!);
          await fetchPlaylistsByPodcastId(idpod!);
          _initAudioPlayer();
          _fetchComments();
        }
      }

      setState(() => isLoading = false);
    });

    _fetchLikeStatus();
    _fetchUnlikeStatus();
    _fetchsaveStatus();
  }

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

// Modified method to show comment modal with nested replies support
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
                  const Text("Comments",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                              _deleteComment(comment['id']),
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
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  RichText(
                                                                    text:
                                                                        TextSpan(
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: reply['user'] != null
                                                                              ? "${reply['user']['firstName']} ${reply['user']['lastName']}"
                                                                              : "Unknown User",
                                                                        ),
                                                                        if (reply['replyToUsername'] !=
                                                                                null &&
                                                                            reply['replyToUsername'].isNotEmpty)
                                                                          TextSpan(
                                                                            text:
                                                                                " @ ${reply['replyToUsername']}",
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.blue,
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
                                                              Spacer(),
                                                              if (isCurrentUserReply)
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size: 16,
                                                                      color: Colors
                                                                          .red),
                                                                  onPressed: () =>
                                                                      _deleteReply(
                                                                          comment[
                                                                              'id'],
                                                                          reply[
                                                                              'id']),
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
                                                        replyUsername // Pass the username
                                                        );
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
                          icon: const Icon(Icons.send),
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

  void _showReplyInput(BuildContext context, String commentId,
      String? parentReplyId, String? replyToUsername) {
    final replyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  parentReplyId == null
                      ? "Reply to comment"
                      : "Reply to ${replyToUsername ?? 'reply'}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: replyController,
                decoration: const InputDecoration(
                  hintText: "Write your reply",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (replyController.text.isNotEmpty) {
                        if (parentReplyId == null) {
                          _addReply(commentId, replyController.text);
                        } else {
                          _addNestedReply(commentId, parentReplyId,
                              replyController.text, replyToUsername ?? '');
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Reply"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
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

  void _addReply(String commentId, String text) async {
    await FirebaseFirestore.instance
        .collection('comments')
        .doc(commentId)
        .collection('reply')
        .add({
      'userid': FirebaseAuth.instance.currentUser?.uid,
      'text': text,
      'date': Timestamp.now(),
    });
    await FirebaseFirestore.instance.collection('podcasts').doc(idpod).update({
      'comments': FieldValue.increment(1),
    });
    setState(() {});
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
          setState(() {
            currentTime = _formatDuration(position);
            currentPosition = position.inMilliseconds / duration.inMilliseconds;
          });
          if (currentPosition >= 0.2 && !hasViewed) {
            hasViewed = true;
            _registerView();
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

  Future _registerView() async {
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
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance
          .collection('podcasts')
          .doc(idpod)
          .update({
        'vue': FieldValue.increment(1),
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
        Navigator.pushReplacementNamed(
          context,
          '/listen',
          arguments: {'idpod': previousPodcastId},
        );
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
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': previousPodcastId},
          );
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
        Navigator.pushReplacementNamed(
          context,
          '/listen',
          arguments: {'idpod': nextPodcastId},
        );
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
          Navigator.pushReplacementNamed(
            context,
            '/listen',
            arguments: {'idpod': nextPodcastId},
          );
          return;
        }
        // If it's the last podcast in this playlist, continue to check other playlists
      }

      // Case e: If we get here, the podcast is the last in all playlists, let it play to the end
      // No action needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Scaffold(
        endDrawer: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.all(c.width * 0.02),
            children: playlist.map((playlistItem) {
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
                          idpod = item["id"];
                          Navigator.pushReplacementNamed(
                            context,
                            '/listen',
                            arguments: {'idpod': idpod},
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
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ),
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
                                        Navigator.pop(context);
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
                                        onTap: () => Scaffold.of(context)
                                            .openEndDrawer(),
                                        child: Image.network(s44,
                                            width: c.width * 0.06,
                                            height: c.width * 0.06),
                                      ),
                                    ),
                                    SizedBox(
                                      height: c.height * 0.2,
                                      child: Stack(children: [
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
                                              accelerationCurve: Curves.easeIn,
                                              decelerationDuration: Duration(
                                                  milliseconds:
                                                      500), // Décélération à la fin
                                              decelerationCurve: Curves.easeOut,
                                            ),
                                          ),
                                        ),
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
                                          onTap: handlePreviousPodcast,
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
                                          onTap: handleNextPodcast,
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
