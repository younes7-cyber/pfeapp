import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/constants.dart';

class Channelpage extends StatefulWidget {
  const Channelpage({super.key});
  @override
  State<Channelpage> createState() => _ChannelpageState();
}

class _ChannelpageState extends State<Channelpage>
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

  final List<Map<String, String>> pod = [
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
  final List<Map<String, String>> play = [
    {"img": "images/k.png", "tit": "Need A Freind", "tite": "63 Podcast"},
    {"img": "images/k.png", "tit": "Need A Freind", "tite": "70 Podcast"},
    {"img": "images/xx.png", "tit": "Music", "tite": "15 Podcast"},
  ];
  bool isPressed = false;
  bool showWhiteContainer = false;
  late int r = 1;
  late int? chaine;
  String? id;
  List<Map<String, dynamic>> playlists = [];
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> podcasts = [];
  Future<void> fetchChannels(String id) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('id', isEqualTo: id)
          .get();

      debugPrint('Nombre de chaînes trouvées : ${querySnapshot.docs.length}');

      List<Map<String, dynamic>> tempChannels = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> channelData = doc.data();

        // Récupérer l'utilisateur lié à ce channel
        String? userId = channelData['userId'];
        if (userId != null) {
          final userQuery = await FirebaseFirestore.instance
              .collection('users')
              .where('userId', isEqualTo: userId)
              .get();

          if (userQuery.docs.isNotEmpty) {
            channelData['user'] = userQuery.docs.first.data();
          } else {
            debugPrint("Aucun utilisateur trouvé pour userId: $userId");
            channelData['user'] = null;
          }
        }

        tempChannels.add(channelData);
      }

      setState(() {
        channels = tempChannels;
      });

      debugPrint("Chaînes finales avec users : $channels");
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {
        channels = [];
      });
    }
  }

  late int s = 0;
  Future<void> fetchPodcastsByChannelId(String id) async {
    try {
      // Étape 1 : Récupérer le channel pour extraire userId
      final channelSnapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('id', isEqualTo: id)
          .get();

      if (channelSnapshot.docs.isEmpty) {
        return;
      }

      final channelData = channelSnapshot.docs.first.data();
      final String userId = channelData['userId'];

      // Étape 2 : Récupérer les podcasts liés à ce userId
      final podcastsSnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('idUser', isEqualTo: userId)
          .orderBy('dateCreation', descending: true)
          .get();

      final List<Map<String, dynamic>> fetchedPodcasts = podcastsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      s = fetchedPodcasts.fold(
          0, (sum, item) => sum + (item["likes"] ?? 0) as int);
      // Debug
      debugPrint("Podcasts trouvés : ${fetchedPodcasts.length}");

      // Met à jour l'état si besoin
      setState(() {
        podcasts = fetchedPodcasts;
      });
    } catch (e) {
      debugPrint("Erreur lors de la récupération des podcasts : $e");
      setState(() {
        podcasts = [];
      });
    }
  }

  bool isFollowing = false;
  Future<String?> getchannelUserId() async {
    try {
      final podcastDoc = await FirebaseFirestore.instance
          .collection('channels')
          .where('id', isEqualTo: id)
          .get();

      if (podcastDoc.docs.isNotEmpty) {
        return podcastDoc.docs.first.data()['userId'] as String?;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'userId du podcast: $e');
      return null;
    }
  }

  final String user = FirebaseAuth.instance.currentUser?.uid ?? "";
  Future<void> checkIfUserIsFollowing() async {
    try {
      // Obtenir l'userId du podcast
      final podcastUserId = await getchannelUserId();
      if (podcastUserId == null) return;

      // Vérifier si l'utilisateur suit déjà
      final followDoc = await FirebaseFirestore.instance
          .collection('follow')
          .where('idfollowers', isEqualTo: user)
          .where('idfollowing', isEqualTo: podcastUserId)
          .get();

      setState(() {
        isFollowing = followDoc.docs.isNotEmpty;
      });
    } catch (e) {
      print('Erreur lors de la vérification du suivi: $e');
    }
  }

  Future<void> toggleFollow() async {
    // ignore: unnecessary_null_comparison
    if (user == null) return;

    try {
      // Obtenir l'userId du podcast
      final podcastUserId = await getchannelUserId();
      if (podcastUserId == null) return;

      // Sauvegarder l'état précédent pour pouvoir revenir en arrière en cas d'erreur
      final previousFollowingState = isFollowing;

      setState(() {
        isFollowing = !isFollowing;
      });

      if (isFollowing) {
        // Ajouter à la collection follow
        await FirebaseFirestore.instance.collection('follow').add({
          'idfollowers': user,
          'idfollowing': podcastUserId,
          'dateCreation': Timestamp.now(),
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
      // En cas d'erreur, revenir à l'état précédent
      setState(() {
        isFollowing = !isFollowing;
      });
      print('Erreur lors du changement de suivi: $e');
    }
  }

  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        if (arguments.containsKey('id')) {
          id = arguments['id'];
        }

        if (arguments.containsKey('chaine')) {
          chaine = arguments['chaine'];
        }

        if (id != null) {
          await fetchChannels(id!);
          await fetchPodcastsByChannelId(id!);
          await fetchplaylists(id!);
          await checkIfUserIsFollowing();
        }
      }

      setState(() => isLoading = false);
    });
  }

  Future<void> fetchplaylists(String id) async {
    try {
      // Étape 1 : Récupérer le channel pour extraire userId
      final channelSnapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('id', isEqualTo: id)
          .get();

      if (channelSnapshot.docs.isEmpty) {
        return;
      }

      final channelData = channelSnapshot.docs.first.data();
      final String userId = channelData['userId'];

      // Étape 2 : Récupérer les podcasts liés à ce userId
      final podcastsSnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> fetchedPodcasts = podcastsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      // Debug
      debugPrint("Podcasts trouvés : ${fetchedPodcasts.length}");

      // Met à jour l'état si besoin
      setState(() {
        playlists = fetchedPodcasts;
      });
    } catch (e) {
      debugPrint("Erreur lors de la récupération des podcasts : $e");
      setState(() {
        playlists = [];
      });
    }
  }

  bool isLoading = true;
  late TabController _tabController1;
  @override
  void dispose() {
    _tabController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size v = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        width: double.infinity, // Added to provide width constraint
        height: double.infinity, // Added to provide height constraint

        child: isLoading
            ? const Center(child: Text(""))
            : Column(
                children: [
                  SizedBox(
                    height: v.width * 0.2,
                    child: Stack(
                      children: [
                        Positioned(
                          top: v.height * 0.01,
                          left: v.width * 0.03,
                          child: IconButton(
                            onPressed: () {
                              if (chaine == 2) {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/podly', (route) => false,
                                    arguments: {'selectedIndex': 0});
                              }
                              if (chaine == 3) {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/podly', (route) => false,
                                    arguments: {'selectedIndex': 3});
                              }
                              if (chaine == 4) {
                                Navigator.pop(context);
                              }
                              if (chaine == 5) {
                                Navigator.pop(context);
                              }
                            },
                            icon: Image.network(
                              s18,
                              width: v.width * 0.07,
                              height: v.width * 0.07,
                            ),
                          ),
                        ),
                        Positioned(
                            top: v.height * 0.01,
                            right: v.width * 0.03,
                            child: PopupMenuButton(
                              icon: Image.network(
                                s49,
                                width: v.width * 0.06,
                                height: v.width * 0.06,
                              ),
                              color: Colors
                                  .white, // Définit la couleur de fond du menu popup
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  height: v.width * 0.12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Couleur de fond du container
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Image.network(
                                          s50,
                                          width: v.width * 0.05,
                                          height: v.width * 0.05,
                                        ),
                                        SizedBox(width: v.width * 0.02),
                                        Text(
                                          "Report",
                                          style: TextStyle(
                                            fontSize: v.width * 0.04,
                                            color: Colors
                                                .black, // Couleur du texte
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    // Add your report functionality here
                                  },
                                ),
                              ],
                            )),
                        Positioned(
                            top: v.height * 0.02,
                            left: v.width * 0.35,
                            child: Container(
                                width: v.width * 0.4,
                                height: v.height * 0.1,
                                // decoration: BoxDecoration(color: Colors.black),
                                child: Text(
                                  channels[0]["name"],
                                  style: TextStyle(
                                      fontSize: v.width * 0.06,
                                      fontWeight: FontWeight.bold),
                                ))),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: v.width,
                    height: v.width * 0.32,
                    child: Stack(
                      children: [
                        Positioned(
                            top: v.height * 0.03,
                            left: v.width * 0.38,
                            child: Container(
                              width: v.width * 0.25,
                              height: v.width * 0.25,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(v.width * 0.2)),
                              child: ClipOval(
                                child: Image.network(
                                  channels[0]["photoUrl"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: v.width,
                    height: v.width * 0.02,
                  ),
                  SizedBox(
                      child: Stack(children: [
                    Positioned(
                      child: Text(
                        channels[0]['user']['email'],
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.grey),
                      ),
                    ),
                  ])),
                  SizedBox(
                    width: v.width,
                    height: v.width * 0.05,
                  ),
                  SizedBox(
                    child: Row(
                      children: [
                        SizedBox(
                          width: v.width * 0.17,
                        ),
                        Column(
                          children: [
                            Text(
                              formatLikes(channels[0]['following']),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: v.width * 0.04),
                            ),
                            const Text(
                              "Following",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: v.width * 0.1,
                        ),
                        Column(
                          children: [
                            Text(
                              formatLikes(channels[0]['followers']),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: v.width * 0.04),
                            ),
                            const Text(
                              "Followers",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: v.width * 0.1,
                        ),
                        Column(
                          children: [
                            Text(
                              formatLikes(s),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: v.width * 0.04),
                            ),
                            const Text(
                              "Likes",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: v.width * 0.05),
                  SizedBox(
                    height: v.height * 0.07,
                    width: v.width * 0.75,
                    child: MaterialButton(
                      onPressed: toggleFollow,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 1),
                        height: v.height * 0.07,
                        width: v.width * 0.75,
                        decoration: BoxDecoration(
                          color: isFollowing
                              ? Colors.white
                              : const Color(0xFF754CEF),
                          borderRadius: BorderRadius.all(
                            Radius.circular(v.width * 0.05),
                          ),
                          border: isFollowing
                              ? Border.all(color: const Color(0xFF754CEF))
                              : null,
                        ),
                        child: Stack(
                          children: [
                            if (!isFollowing)
                              Positioned(
                                top: v.height * 0.022,
                                left: v.width * 0.23,
                                child: Text(
                                  "Follow Now",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: v.width * 0.04,
                                  ),
                                ),
                              ),
                            if (isFollowing)
                              Positioned(
                                top: v.height * 0.015,
                                left: v.width * 0.2,
                                child: Row(
                                  children: [
                                    Image.network(
                                      s51,
                                      width: v.width * 0.06,
                                      height: v.width * 0.06,
                                    ),
                                    SizedBox(width: v.width * 0.02),
                                    Text(
                                      "Following",
                                      style: TextStyle(
                                        color: const Color(0xFF754CEF),
                                        fontSize: v.width * 0.04,
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
                  TabBar(
                    controller: _tabController1,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Podcast'),
                      Tab(text: 'Playlist'),
                    ],
                  ),

                  // Tab bar view - Fixed section
                  Expanded(
                    child: TabBarView(
                      controller: _tabController1,
                      children: [
                        Column(
                          children: [
                            // See All header for Podcast
                            Padding(
                              padding: const EdgeInsets.symmetric(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: v.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "See All",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: v.width * 0.035,
                                            color: const Color(0xFF754CEF)),
                                      ),
                                      SizedBox(width: v.width * 0.01),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/seeall',
                                            arguments:
                                                12, // Passe la valeur de r comme argument
                                          );

                                          print(r);
                                        },
                                        icon: Image.network(
                                          s36,
                                          width: v.width * 0.04,
                                          height: v.width * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: podcasts.length,
                                itemBuilder: (context, index) {
                                  final item = podcasts[index];
                                  return Container(
                                    margin: EdgeInsets.all(v.width * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(v.width * 0.05),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    width: v.width * 0.95,
                                    height: v.width * 0.3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/podcast');
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(width: v.width * 0.01),
                                          Container(
                                            child: Image.network(
                                              s48,
                                              width: v.width * 0.09,
                                              height: v.width * 0.09,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: v.width * 0.03),
                                          Container(
                                            height: v.width * 0.2,
                                            width: v.width * 0.2,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      v.width * 0.04),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    item["urlPhoto"]!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: v.width * 0.02),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: v.width * 0.0),
                                              SizedBox(
                                                width: v.width * 0.35,
                                                child: Text(
                                                  item["name"]!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: v.width * 0.04,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(height: v.width * 0.01),
                                            ],
                                          ),
                                          SizedBox(
                                            width: v.width * 0.05,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                  width: v.width *
                                                      0.2, // Constrain the width of the progress bar
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            child:
                                                                Image.network(
                                                                    s37),
                                                            width:
                                                                v.width * 0.05,
                                                            height:
                                                                v.width * 0.05,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                v.width * 0.01,
                                                          ),
                                                          Text(
                                                            formatLikes(
                                                                item["likes"]),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    v.width *
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
                                                        height: v.width * 0.02,
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            child:
                                                                Image.network(
                                                                    s14),
                                                            width:
                                                                v.width * 0.05,
                                                            height:
                                                                v.width * 0.05,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                v.width * 0.01,
                                                          ),
                                                          Text(
                                                            formatLikes(
                                                                item["vue"]),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    v.width *
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
                                                        height: v.width * 0.02,
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            child:
                                                                Image.network(
                                                                    s38),
                                                            width:
                                                                v.width * 0.05,
                                                            height:
                                                                v.width * 0.05,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                v.width * 0.01,
                                                          ),
                                                          Text(
                                                            formatLikes(item[
                                                                "comments"]),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    v.width *
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
                        ),
                        Column(
                          children: [
                            // See All header for Podcast
                            Padding(
                              padding: const EdgeInsets.symmetric(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "",
                                    style: TextStyle(
                                      fontSize: v.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "See All",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: v.width * 0.035,
                                            color: const Color(0xFF754CEF)),
                                      ),
                                      SizedBox(width: v.width * 0.01),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/seeall',
                                            arguments:
                                                13, // Passe la valeur de r comme argument
                                          );

                                          print(r);
                                        },
                                        icon: Image.network(
                                          s36,
                                          width: v.width * 0.04,
                                          height: v.width * 0.04,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: // Playlist tab
                                  ListView.builder(
                                itemCount: playlists.length,
                                itemBuilder: (context, index) {
                                  final item = playlists[index];
                                  return Container(
                                    margin: EdgeInsets.all(v.width * 0.02),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(v.width * 0.05),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    width: v.width * 0.95,
                                    height: v.width * 0.3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/play');
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: v.width * 0.01,
                                          ),
                                          Container(
                                            height: v.width * 0.25,
                                            width: v.width * 0.25,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      v.width * 0.04),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    item["photoUrl"]!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: v.width * 0.04),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: v.width * 0.02),
                                              SizedBox(
                                                width: v.width * 0.3,
                                                child: Text(
                                                  item["name"]!,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: v.width * 0.04,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: v.width * 0.04,
                                          ),
                                          Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                    width: v.width *
                                                        0.2, // Constrain the width of the progress bar
                                                    child: Column(children: [
                                                      SizedBox(
                                                        height: v.width * 0.02,
                                                      ),
                                                      Column(children: [
                                                        Text(
                                                          formatLikes(
                                                              item["podcast"]!),
                                                          style: TextStyle(
                                                            fontSize:
                                                                v.width * 0.035,
                                                          ),
                                                          maxLines: 4,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(
                                                          width: v.width * 0.03,
                                                        ),
                                                        Text(
                                                          "Podcast",
                                                          style: TextStyle(
                                                            fontSize:
                                                                v.width * 0.035,
                                                          ),
                                                          maxLines: 4,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ])
                                                    ]))
                                              ])
                                        ],
                                      ),
                                    ),
                                  );
                                },
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
    ));
  }
}
