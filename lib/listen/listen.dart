import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class Listenpage extends StatefulWidget {
  const Listenpage({super.key});

  @override
  State<Listenpage> createState() => _ListenpageState();
}

class _ListenpageState extends State<Listenpage>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> pod = [
    {
      "img": "images/qq.png",
      "tit": "The Joe Rogen..JJJJJ",
      "cat": "music",
      "like": "100K",
      "view": "400k",
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

  bool isLiked = false;
  bool isUnliked = false;
  bool isSaved = false;
  bool _imagesPreCached = false;
  TextEditingController commentController = TextEditingController();
  TextEditingController replyController = TextEditingController();
  String? replyingTo;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPreCached) {
      _precacheImages();
      _imagesPreCached = true;
    }
  }

  void _precacheImages() {
    precacheImage(AssetImage("images/like.png"), context);
    precacheImage(AssetImage("images/like1.png"), context);
    precacheImage(AssetImage("images/unlike.png"), context);
    precacheImage(AssetImage("images/unlik.png"), context);
    precacheImage(AssetImage("images/sav.png"), context);
    precacheImage(AssetImage("images/save.png"), context);
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      if (isLiked) {
        isUnliked = false;
      }
    });
  }

  void _toggleUnlike() {
    setState(() {
      isUnliked = !isUnliked;
      if (isUnliked) {
        isLiked = false;
      }
    });
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });
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

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentTime = "0:00";
  String totalTime = "0:00";
  double currentPosition = 0.0; // Progress value

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      if (await Permission.storage.request().isGranted) {
        String filePath =
            "/storage/emulated/0/Telegram/Telegram Files/25 févr. à 19.21​.aac";

        if (await File(filePath).exists()) {
          await _audioPlayer.setFilePath(filePath);
          print("Audio file loaded successfully!");
        } else {
          print("File not found: $filePath");
        }
      } else {
        print("Storage permission denied.");
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
          child: ListView.builder(
            padding: EdgeInsets.all(c.width * 0.02),
            itemCount: pod.length,
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final item = pod[index];

              return Container(
                margin: EdgeInsets.all(c.width * 0.02),
                decoration: BoxDecoration(
                  color: isFirst ? Colors.black12 : Colors.transparent,
                  borderRadius: BorderRadius.circular(c.width * 0.04),
                  border: Border.all(color: Colors.black12),
                ),
                width: c.width * 0.95,
                height: c.width * 0.3,
                child: Row(
                  children: [
                    SizedBox(width: c.width * 0.02),
                    Image.asset("images/play1.png",
                        width: c.width * 0.07, height: c.width * 0.07),
                    SizedBox(width: c.width * 0.02),
                    Container(
                      height: c.width * 0.2,
                      width: c.width * 0.18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(c.width * 0.04),
                        image: DecorationImage(
                          image: AssetImage(item["img"]!),
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
                            item["tit"]!,
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
                            Image.asset("images/like.png",
                                width: c.width * 0.05, height: c.width * 0.05),
                            SizedBox(width: c.width * 0.01),
                            Text(item["like"]!),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset("images/view.png",
                                width: c.width * 0.05, height: c.width * 0.05),
                            SizedBox(width: c.width * 0.01),
                            Text(item["view"]!),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset("images/comment.png",
                                width: c.width * 0.05, height: c.width * 0.05),
                            SizedBox(width: c.width * 0.01),
                            Text(item["com"]!),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Builder(
              builder: (context) => Container(
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(children: [
                      SizedBox(
                          height: c.height * 0.2,
                          child: Stack(
                            children: [
                              Positioned(
                                top: c.height * 0.01,
                                left: c.width * 0.03,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/podly', (route) => false,
                                        arguments: {'selectedIndex': 0});
                                  },
                                  icon: Image.asset(
                                    "images/retour.png",
                                    width: c.width * 0.07,
                                    height: c.width * 0.07,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: c.height * 0.025,
                                right: c.width * 0.04,
                                child: GestureDetector(
                                  onTap: () =>
                                      Scaffold.of(context).openEndDrawer(),
                                  child: Image.asset("images/playlist.png",
                                      width: c.width * 0.06,
                                      height: c.width * 0.06),
                                ),
                              ),
                              Positioned(
                                  top: c.height * 0.04,
                                  left: c.width * 0.17,
                                  child: Container(
                                    width: c.width * 0.7,
                                    child: Text(
                                      "Collection Mr Beast 2024",
                                      style: TextStyle(
                                        fontSize: c.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
                                    ),
                                  )),
                            ],
                          )),
                      SizedBox(
                        width: c.width * 0.85,
                        height: c.width * 0.85,
                        child: Container(
                          height: c.width * 0.85,
                          width: c.width * 0.85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(c.width * 0.04),
                            image: DecorationImage(
                              image: AssetImage("images/his.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: c.height * 0.2,
                        child: Stack(
                          children: [
                            Positioned(
                              top: c.height * 0.02,
                              left: c.width * 0.05,
                              child: Column(
                                children: [
                                  Container(
                                    width: c.width * 0.9,
                                    child: Text(
                                      "Episode 1 |history Of Algeria",
                                      style: TextStyle(
                                        fontSize: c.width * 0.05,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 3,
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
                                            child: Image.asset(
                                              isLiked
                                                  ? "images/like.png"
                                                  : "images/like1.png",
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
                                            child: Image.asset(
                                              isUnliked
                                                  ? "images/unlik.png"
                                                  : "images/unlike.png",
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
                                            child: Image.asset(
                                              "images/comment.png",
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
                                            child: Image.asset(
                                              isSaved
                                                  ? "images/sav.png"
                                                  : "images/save.png",
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
                                            child: Image.asset(
                                              "images/par.png",
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
                                    onTap: _skipForward,
                                    child: Container(
                                      padding: EdgeInsets.all(c.width * 0.02),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            "images/prec.png",
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
                                    onTap: _skipForward,
                                    child: Container(
                                      padding: EdgeInsets.all(c.width * 0.02),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                            "images/suiv.png",
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
