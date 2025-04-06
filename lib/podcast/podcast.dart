import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
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
  // Récupération de l'ID
  String? idpod;
  bool isFollowing = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final user = FirebaseAuth.instance.currentUser?.uid;

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

  bool isLoading = true;
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> channel = [];
  List<Map<String, dynamic>> userPodcasts = [];
  bool isYourPodcast = false;
  List<Map<String, dynamic>> podcastPlaylists = [];
  Future<void> fetchPodcastById(String idpod) async {
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

// 1️⃣ Récupérer la chaîne associée à un podcast via idUser
  Future<void> fetchChannelByPodcastId(String idpod) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String idUser = querySnapshot.docs.first.data()['idUser'];

        final channelSnapshot = await FirebaseFirestore.instance
            .collection('channels')
            .where('userId', isEqualTo: idUser)
            .get();

        if (channelSnapshot.docs.isNotEmpty) {
          setState(() {
            channel = channelSnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });

          debugPrint(
              "Chaîne récupérée pour idUser $idUser : ${channel.length}");
        }
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération de la chaîne : $e");
    }
  }

// 2️⃣ Récupérer tous les podcasts d'un utilisateur via idUser
  Future<void> fetchPodcastsByUserId(String idpod) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String idUser = querySnapshot.docs.first.data()['idUser'];

        final podcastsSnapshot = await FirebaseFirestore.instance
            .collection('podcasts')
            .orderBy('dateCreation', descending: true)
            .where('idUser', isEqualTo: idUser)
            .get();

        if (podcastsSnapshot.docs.isNotEmpty) {
          setState(() {
            userPodcasts = podcastsSnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();

            // Supprimer le podcast avec le même idpod que l'argument
            userPodcasts.removeWhere((podcast) => podcast['id'] == idpod);
          });

          debugPrint(
              "Podcasts récupérés pour idUser $idUser : ${userPodcasts.length}");
        }
      }
    } catch (e) {
      debugPrint(
          "Erreur lors de la récupération des podcasts de l'utilisateur : $e");
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
        // Note: Firestore ne permet pas d'utiliser 'where in' avec plus de 10 éléments
        // Donc nous divisons en groupes si nécessaire
        List<Map<String, dynamic>> allPlaylists = [];

        // Traiter par groupes de 10 maximum
        for (int i = 0; i < playlistIds.length; i += 10) {
          int end = (i + 10 < playlistIds.length) ? i + 10 : playlistIds.length;
          List<String> batch = playlistIds.sublist(i, end);

          final playlistsSnapshot = await FirebaseFirestore.instance
              .collection('playlist')
              .orderBy('createdAt', descending: true)
              .where('id', whereIn: batch)
              .get();

          for (var doc in playlistsSnapshot.docs) {
            allPlaylists.add(doc.data() as Map<String, dynamic>);
          }
        }

        setState(() {
          // Stocker les playlists récupérées
          podcastPlaylists = allPlaylists;
        });

        debugPrint("Playlists récupérées: ${podcastPlaylists.length}");
      } else {
        setState(() {
          podcastPlaylists = [];
        });
        debugPrint("Aucune playlist trouvée pour ce podcast");
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération des playlists: $e");
      setState(() {
        podcastPlaylists = [];
      });
    }
  }

  Future<void> checkIfCurrentUserOwnsPodcast(String idpod) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String idUser = querySnapshot.docs.first.data()['idUser'];

        String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

        setState(() {
          isYourPodcast = (currentUserId == idUser);
        });

        debugPrint("Votre podcast ? $isYourPodcast");
      }
    } catch (e) {
      debugPrint(
          "Erreur lors de la vérification du propriétaire du podcast : $e");
    }
  }

  late TabController _tabController1;
  late TabController _tabController2;

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);
    _tabController2 = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);

      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null && arguments.containsKey('idpod')) {
        idpod = arguments['idpod'];

        if (idpod != null) {
          await fetchPodcastById(idpod!);
          await fetchChannelByPodcastId(idpod!);
          await fetchPodcastsByUserId(idpod!);
          await checkIfCurrentUserOwnsPodcast(idpod!);
          await checkIfUserIsFollowing();
          fetchPlaylistsByPodcastId(idpod!);
        }
      }

      setState(() => isLoading = false);
    });
  }

  Future<String?> getPodcastUserId() async {
    try {
      final podcastDoc = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('id', isEqualTo: idpod)
          .get();

      if (podcastDoc.docs.isNotEmpty) {
        return podcastDoc.docs.first.data()['idUser'] as String?;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'userId du podcast: $e');
      return null;
    }
  }

// Fonction pour vérifier si l'utilisateur suit déjà
  Future<void> checkIfUserIsFollowing() async {
    if (user == null) return;

    try {
      // Obtenir l'userId du podcast
      final podcastUserId = await getPodcastUserId();
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
    if (user == null) return;

    try {
      // Obtenir l'userId du podcast
      final podcastUserId = await getPodcastUserId();
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

  @override
  void dispose() {
    _tabController1.dispose();
    _tabController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size w = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading
          ? Center(child: Text(""))
          : SafeArea(
              child: Container(
                width: double.infinity, // Prend toute la largeur disponible
                height: double.infinity, // Prend toute la hauteur disponible
                decoration: const BoxDecoration(color: Colors.white),
                child: Stack(
                  fit: StackFit
                      .expand, // Force le Stack à prendre tout l'espace disponible
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(w.width * 0.05),
                        ),
                        width: w.width,
                        height: w.height * 0.1,
                      ),
                    ),
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
                              s18,
                              width: w.width * 0.07,
                              height: w.width * 0.07,
                            ),
                          ),
                        )),
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
                                  s49,
                                  width: w.width * 0.06,
                                  height: w.width * 0.06,
                                ),
                                color: Colors
                                    .white, // Définit la couleur de fond du menu popup
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    height: w.width * 0.12,
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
                                            width: w.width * 0.05,
                                            height: w.width * 0.05,
                                          ),
                                          SizedBox(width: w.width * 0.02),
                                          Text(
                                            "Report",
                                            style: TextStyle(
                                              fontSize: w.width * 0.04,
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
                              ))),
                    ],
                    Positioned(
                      top: w.height * 0.27,
                      right: w.width * 0.03,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/listen',
                            arguments: {'idpod': idpod},
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
                    Positioned(
                      top: w.height * 0.28,
                      child: Container(
                        width: w.width * 0.7,
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
                      top: w.height * 0.37,
                      left: w.width * 0.05,
                      right: w.width * 0.05, // Ajouter une contrainte de droite
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
                              Image.network(s37,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(podcast[0]["likes"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                    color: Colors.black,
                                  )),
                            ],
                          ),

                          // Deuxième élément (unlikes)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(s41,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(podcast[0]["unlikes"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                    color: Colors.black,
                                  )),
                            ],
                          ),

                          // Troisième élément (vue)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(s14,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(podcast[0]["vue"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                    color: Colors.black,
                                  )),
                            ],
                          ),

                          // Quatrième élément (comments)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(s38,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(podcast[0]["comments"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                    color: Colors.black,
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(s38,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(podcast[0]["save"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                    color: Colors.black,
                                  )),
                            ],
                          ),
                          // Cinquième élément (shares)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(s45,
                                  width: w.width * 0.05,
                                  height: w.width * 0.05),
                              SizedBox(width: w.width * 0.01),
                              Text(formatLikes(podcast[0]["shares"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                    color: Colors.black,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: w.height * 0.43,
                      left: w.width * 0.05,
                      right: w.width * 0.05,
                      child: Container(
                        height: w.height *
                            0.4, // Hauteur suffisante pour contenir TabBar et TabBarView
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TabBar
                            TabBar(
                              controller: _tabController1,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.black,
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
                                    padding: EdgeInsets.only(top: 10),
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
                                          color: Color(0xFF754CEF)),
                                      lessStyle: TextStyle(
                                          fontSize: w.width * 0.03,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF754CEF)),
                                    ),
                                  ),
                                  // Deuxième onglet - Category
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
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
                                          color: Color(0xFF754CEF)),
                                      lessStyle: TextStyle(
                                          fontSize: w.width * 0.05,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF754CEF)),
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
                              TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    channel[0]["name"],
                                    style: TextStyle(
                                        fontSize: w.width * 0.045,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Text(formatLikes(channel[0]["followers"]),
                                  style: TextStyle(
                                    fontSize: w.width * 0.035,
                                    color: Colors.black,
                                    //   fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                          SizedBox(
                            width: w.width * 0.01,
                          ),
                          //     if (isYourPodcast == false) ...[
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
                                  duration: const Duration(milliseconds: 300),
                                  height: w.height * 0.05,
                                  width: w.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: isFollowing
                                        ? Colors.white
                                        : const Color(0xFF754CEF),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(w.width * 0.05),
                                    ),
                                    border: isFollowing
                                        ? Border.all(
                                            color: const Color(0xFF754CEF))
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
                                                s51,
                                                width: w.width * 0.05,
                                                height: w.width * 0.05,
                                              ),
                                              SizedBox(width: w.width * 0.01),
                                              Text(
                                                "Following",
                                                style: TextStyle(
                                                  color:
                                                      const Color(0xFF754CEF),
                                                  fontSize: w.width * 0.03,
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
                          // ],
                        ])),
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
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.black,
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
                                SizedBox(
                                  height: w.height * 0.23,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: userPodcasts.length,
                                    itemBuilder: (context, index) {
                                      final podItem = userPodcasts[index];
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: w.width * 0.02),
                                        width: w.width * 0.2,
                                        height: w.width *
                                            0.35, // Increased height to accommodate content
                                        child: Column(
                                          mainAxisSize:
                                              MainAxisSize.min, // Add this
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
                                                      podItem["urlPhoto"]),
                                                  fit: BoxFit.cover,
                                                  onError:
                                                      (exception, stackTrace) {
                                                    print(
                                                        'Error loading image: $exception');
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: w.width * 0.01),
                                            Flexible(
                                                child: Text(
                                              podItem["name"],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: w.width * 0.04,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: w.height * 0.23,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: podcastPlaylists.length,
                                    itemBuilder: (context, index) {
                                      final playItem = podcastPlaylists[index];
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: w.width * 0.02),
                                        width: w.width * 0.2,
                                        height: w.width *
                                            0.35, // Increased height to accommodate content
                                        child: Column(
                                          mainAxisSize:
                                              MainAxisSize.min, // Add this
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
                                                      playItem['photoUrl']),
                                                  fit: BoxFit.cover,
                                                  onError:
                                                      (exception, stackTrace) {
                                                    print(
                                                        'Error loading image: $exception');
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: w.width * 0.01),
                                            Flexible(
                                                child: Text(
                                              playItem['name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: w.width * 0.04,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
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
                        s52,
                        width: w.width * 0.06,
                        height: w.width * 0.06,
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
