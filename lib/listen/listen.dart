import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pfeapp/constants.dart';
import 'package:marquee/marquee.dart';

class Listenpage extends StatefulWidget {
  const Listenpage({super.key});

  @override
  State<Listenpage> createState() => _ListenpageState();
}

class _ListenpageState extends State<Listenpage>
    with SingleTickerProviderStateMixin {
  String? idpod;

  TextEditingController commentController = TextEditingController();
  TextEditingController replyController = TextEditingController();
  String? replyingTo;
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> playlist = [];
  List<Map<String, dynamic>> playinpod = [];

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

  final List<Comment> comments = [
    Comment(
      photo: 'images/person.jpg',
      username: 'dangingeoduc',
      content: 'A Dart template generator which helps teams',
      date: '15/02/2025',
      replies: [
        Comment(
          photo: 'images/person.jpg',
          username: 'dangingeoduc',
          content:
              'A Dart template generator which helps teams generator which helps teams generator which helps teams',
          date: '16/02/2025',
          replies: [
            Comment(
              photo: 'images/person.jpg',
              username: 'dangingeoduc',
              content: 'A Dart template generator which helps teams',
              date: '17/02/2025',
              replies: [
                Comment(
                  photo: 'images/person.jpg',
                  username: 'dangingeoduc',
                  content:
                      'A Dart template generator which helps teams generator which helps teams',
                  date: '18/02/2025',
                  replies: [],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    Comment(
      photo: 'images/person.jpg',
      username: 'flutteruser',
      content: 'Great podcast! Looking forward to more episodes',
      date: '20/02/2025',
      replies: [],
    ),
  ];

  void _addComment(String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      comments.add(Comment(
        photo: 'images/person.jpg',
        username: 'You',
        content: content,
        date: '26/02/2025', // Current date
        replies: [],
      ));
      commentController.clear();
    });
  }

  void _addReply(Comment parentComment, String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      parentComment.replies.add(
        Comment(
          photo: 'photo/person.jpg',
          username: 'You',
          content: content,
          date: '26/02/2025', // Current date
          replies: [],
        ),
      );
      replyController.clear();
      replyingTo = null;
    });
  }

  void _showCommentsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final Size c = MediaQuery.of(context).size;
        return StatefulBuilder(builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                padding: EdgeInsets.all(c.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: c.width * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: c.width * 0.06),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          ...comments.map((comment) => CommentTreeWidget(
                                comment: comment,
                                onReply: (Comment comment) {
                                  setState(() {
                                    replyingTo = comment.username;
                                  });
                                },
                                onAddReply: _addReply,
                                replyController: replyController,
                                isReplying: replyingTo == comment.username,
                              )),
                        ],
                      ),
                    ),
                    Divider(),
                    if (replyingTo != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: c.width * 0.02),
                        child: Row(
                          children: [
                            Text(
                              'Replying to $replyingTo',
                              style: TextStyle(
                                color: Color(0xFF754CEF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: c.width * 0.02),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  replyingTo = null;
                                });
                              },
                              child: Icon(Icons.close, size: c.width * 0.04),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: replyingTo != null
                                  ? 'Add a reply...'
                                  : 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(c.width * 0.05),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: c.width * 0.04,
                                vertical: c.width * 0.02,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: c.width * 0.02),
                        CircleAvatar(
                          radius: c.width * 0.06,
                          backgroundColor: Color(0xFF754CEF),
                          child: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                              size: c.width * 0.05,
                            ),
                            onPressed: () {
                              if (replyingTo != null) {
                                // Find the comment to reply to
                                for (var comment in comments) {
                                  if (comment.username == replyingTo) {
                                    _addReply(comment, commentController.text);
                                    break;
                                  }
                                }
                              } else {
                                _addComment(commentController.text);
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
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
        }
      }

      setState(() => isLoading = false);
    });

    _fetchLikeStatus();
    _fetchUnlikeStatus();
    _fetchsaveStatus();
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
        body: SafeArea(
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
                            if (playinpod.any((p) => p["id"] == idpod)) ...[
                              Positioned(
                                top: c.height * 0.025,
                                right: c.width * 0.04,
                                child: GestureDetector(
                                  onTap: () =>
                                      Scaffold.of(context).openEndDrawer(),
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

                                      child: isLoading
                                          ? Center(
                                              child: Text(
                                                  "")) // Affiche un loader pendant le chargement
                                          : Marquee(
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
                        child: isLoading
                            ? Center(child: Text(""))
                            : Container(
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
                                    child: isLoading
                                        ? Center(child: Text(""))
                                        : Marquee(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Like button
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          onTap: _toggleLike,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
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
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
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
                                          borderRadius: BorderRadius.circular(
                                              c.width * 0.075),
                                          onTap: _showCommentsModal,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
                                            child: Image.network(
                                              s38,
                                              width: c.width * 0.05,
                                              height: c.width * 0.05,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: c.width * 0.02), // Save button
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          onTap: _toggleSave,
                                          child: Padding(
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
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
                                            padding:
                                                EdgeInsets.all(c.width * 0.02),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: c.width * 0.05),
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
                                        enabledThumbRadius: c.width * 0.02,
                                      ),
                                      activeTrackColor: Color(0xFF754CEF),
                                      inactiveTrackColor: Colors.grey[300],
                                      thumbColor: Color(0xFF754CEF),
                                      overlayColor:
                                          Color(0xFF754CEF).withOpacity(0.2),
                                    ),
                                    child: Slider(
                                      value: currentPosition.clamp(0.0, 1.0),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Skip backward 30s
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: _skipBackward,
                                    child: Container(
                                      padding: EdgeInsets.all(c.width * 0.02),
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
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(c.width * 0.02),
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
                                  borderRadius: BorderRadius.circular(100),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(100),
                                    onTap: _togglePlayPause,
                                    child: Container(
                                      padding: EdgeInsets.all(c.width * 0.03),
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
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: () {},
                                    child: Container(
                                      padding: EdgeInsets.all(c.width * 0.02),
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
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: _skipForward,
                                    child: Container(
                                      padding: EdgeInsets.all(c.width * 0.02),
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
class CommentTreeWidget extends StatelessWidget {
  final Comment comment;
  final double indentation;
  final Function(Comment) onReply;
  final Function(Comment, String) onAddReply;
  final TextEditingController replyController;
  final bool isReplying;

  const CommentTreeWidget({
    Key? key,
    required this.comment,
    this.indentation = 0,
    required this.onReply,
    required this.onAddReply,
    required this.replyController,
    this.isReplying = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: indentation),
          child: Card(
            margin: EdgeInsets.symmetric(vertical: c.width * 0.01),
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(c.width * 0.03),
            ),
            child: Padding(
              padding: EdgeInsets.all(c.width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: c.width * 0.04,
                        backgroundColor: Color(0xFF754CEF).withOpacity(0.2),
                        backgroundImage: AssetImage(comment.photo),
                      ),
                      SizedBox(width: c.width * 0.02),
                      Text(
                        comment.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: c.width * 0.035,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: c.width * 0.02),
                  Text(
                    comment.content,
                    style: TextStyle(fontSize: c.width * 0.035),
                  ),
                  SizedBox(height: c.width * 0.02),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: c.width * 0.04, color: Colors.grey),
                      SizedBox(width: c.width * 0.01),
                      Text(comment.date,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: c.width * 0.03,
                          )),
                      SizedBox(width: c.width * 0.04),
                      GestureDetector(
                        onTap: () => onReply(comment),
                        child: Row(
                          children: [
                            Icon(
                              Icons.reply_outlined,
                              size: c.width * 0.04,
                              color: Color(0xFF754CEF),
                            ),
                            SizedBox(width: c.width * 0.01),
                            Text(
                              'Reply',
                              style: TextStyle(
                                color: Color(0xFF754CEF),
                                fontSize: c.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isReplying)
                    Padding(
                      padding: EdgeInsets.only(top: c.width * 0.03),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              decoration: InputDecoration(
                                hintText: 'Write your reply...',
                                hintStyle: TextStyle(fontSize: c.width * 0.035),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(c.width * 0.03),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: c.width * 0.03,
                                  vertical: c.width * 0.02,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: c.width * 0.02),
                          CircleAvatar(
                            radius: c.width * 0.05,
                            backgroundColor: Color(0xFF754CEF),
                            child: IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: c.width * 0.04,
                              ),
                              onPressed: () {
                                onAddReply(comment, replyController.text);
                              },
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
        if (comment.replies.isNotEmpty)
          ...comment.replies.map(
            (reply) => CommentTreeWidget(
              comment: reply,
              indentation: indentation + c.width * 0.06,
              onReply: onReply,
              onAddReply: onAddReply,
              replyController: replyController,
              isReplying: false,
            ),
          ),
      ],
    );
  }
}
