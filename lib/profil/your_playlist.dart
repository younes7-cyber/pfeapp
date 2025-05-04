import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class Yourplaylistpage extends StatefulWidget {
  const Yourplaylistpage({super.key});
  @override
  State<Yourplaylistpage> createState() => _YourplaylistpageState();
}

class _YourplaylistpageState extends State<Yourplaylistpage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController1;

  final user = FirebaseAuth.instance.currentUser?.uid;
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

  late int nbr = 0;
  List<Map<String, dynamic>> mesPodcasts = [];

  // Streams
  Stream<QuerySnapshot>? myPlaylistStream;
  Stream<QuerySnapshot>? userStream;

  Future<void> nbrpodId() async {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    try {
      // Set up the playlist stream
      myPlaylistStream = FirebaseFirestore.instance
          .collection('myplaylist')
          .where('iduser', isEqualTo: currentUserId)
          .snapshots();

      // Subscribe to the stream
      myPlaylistStream?.listen((playinPodSnapshot) async {
        List<Map<String, dynamic>> myPlayInfos = [];

        for (var doc in playinPodSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
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

            // Get podcast data using snapshots
            final podSnapshot = await FirebaseFirestore.instance
                .collection('podcasts')
                .where('id', whereIn: batch)
                .get();

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
            Timestamp? dateA = a['dateCreation'];
            Timestamp? dateB = b['dateCreation'];
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            return dateB.compareTo(dateA); // Tri décroissant
          });

          if (mounted) {
            setState(() {
              mesPodcasts = allPodcasts;
              nbr = allPodcasts.length;
              isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              mesPodcasts = [];
              nbr = 0;
              isLoading = false;
            });
          }
        }
      }, onError: (e) {
        if (mounted) {
          setState(() {
            mesPodcasts = [];
            nbr = 0;
            isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          mesPodcasts = [];
          nbr = 0;
          isLoading = false;
        });
      }
    }
  }

  bool isLoading = true;
  List<Map<String, dynamic>> user1 = [];
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await fetchuser();
      await nbrpodId();
    });
  }

  @override
  void dispose() {
    _tabController1.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> fetchuser() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

      // Set up user stream
      userStream = FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUserId)
          .snapshots();

      // Subscribe to the stream
      userStream?.listen((querySnapshot) {
        // Ajout des logs pour déboguer

        if (mounted) {
          setState(() {
            user1 = querySnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          });
        }
      }, onError: (e) {});
      // ignore: empty_catches
    } catch (e) {}
  }

  // Méthode pour recharger les données
  Future<void> _onRefresh() async {
    setState(() => isLoading = true);

    try {
      // Réinitialiser les streams pour forcer la rafraîchissement
      await fetchuser();
      await nbrpodId();

      // Complete the refresh
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size w = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: Annimationwidjet())
            : Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
                return Container(
                  width: double.infinity, // Prend toute la largeur disponible
                  height: double.infinity, // Prend toute la hauteur disponible
                  decoration: BoxDecoration(
                    color:
                        themeProvider.isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: Stack(
                      fit: StackFit
                          .expand, // Force le Stack à prendre tout l'espace disponible
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            width: w.width,
                            height: w.height * 0.3,
                            child: user1.isNotEmpty
                                ? Image.network(user1[0]['photoUrl'],
                                    fit: BoxFit.cover)
                                : Container(color: Colors.grey[300]),
                          ),
                        ),
                        Positioned(
                          top: w.width * 0.55,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(w.width * 0.05),
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
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/podly', (route) => false,
                                      arguments: {'selectedIndex': 3});
                                },
                                icon: Image.network(
                                  s18,
                                  width: w.width * 0.07,
                                  height: w.width * 0.07,
                                ),
                              ),
                            )),
                        Positioned(
                          top: w.height * 0.27,
                          right: w.width * 0.03,
                          child: mesPodcasts.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/listen',
                                      arguments: {
                                        'idpod': mesPodcasts[0]["id"],
                                        'featl': 10,
                                      },
                                    );
                                  },
                                  icon: Image.network(
                                    s48,
                                    width: w.width * 0.14,
                                    height: w.width * 0.14,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(),
                        ),
                        Positioned(
                          top: w.height * 0.28,
                          child: SizedBox(
                            width: w.width * 0.7,
                            child: Column(children: [
                              Text(
                                "My Playlist",
                                style: TextStyle(
                                  fontSize: w.width * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                              ),
                            ]),
                          ),
                        ),
                        Positioned(
                          top: w.height * 0.37,
                          left: w.width * 0.05,
                          right: w.width *
                              0.05, // Ajouter une contrainte de droite
                          child: Wrap(
                            spacing: w.width *
                                0.05, // Espacement horizontal entre les éléments
                            runSpacing: w.width *
                                0.02, // Espacement vertical entre les lignes
                            children: [
                              // Quatrième élément (comments)
                              SizedBox(
                                width: w.width * 0.03,
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(
                                      themeProvider.isDarkMode ? s110 : s30,
                                      width: w.width * 0.05,
                                      height: w.width * 0.05),
                                  SizedBox(width: w.width * 0.01),
                                  Text(formatLikes(nbr),
                                      style: TextStyle(
                                        fontSize: w.width * 0.035,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: w.height * 0.45,
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
                                  controller: _tabController1,
                                  labelColor: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  labelStyle: TextStyle(
                                    fontSize: w.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontSize: w.width * 0.04,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  tabs: const [
                                    Tab(text: 'Podcasts'),
                                  ],
                                  indicatorSize: TabBarIndicatorSize.label,
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController1,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: w.width * 0.02),
                                      child: RefreshIndicator(
                                        onRefresh: _onRefresh,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        child: mesPodcasts.isEmpty
                                            ? ListView(
                                                children: [
                                                  SizedBox(
                                                      height: w.height * 0.05),
                                                  Center(
                                                    child: Column(children: [
                                                      SizedBox(
                                                        width: w.width * 0.7,
                                                        height: w.height * 0.3,
                                                        child: Image.network(
                                                            themeProvider
                                                                    .isDarkMode
                                                                ? s109
                                                                : s28),
                                                      ),
                                                      Text("Not Yet",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  w.width *
                                                                      0.04,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ]),
                                                  ),
                                                ],
                                              )
                                            : ListView.builder(
                                                itemCount: mesPodcasts.length,
                                                itemBuilder: (context, index) {
                                                  final item =
                                                      mesPodcasts[index];
                                                  return Container(
                                                    margin: EdgeInsets.all(
                                                        w.width * 0.02),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              w.width * 0.05),
                                                      border: Border.all(
                                                        color: themeProvider
                                                                .isDarkMode
                                                            ? Colors.white70
                                                            : Colors.black12,
                                                      ),
                                                    ),
                                                    width: w.width * 0.95,
                                                    height: w.width * 0.3,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/podcast',
                                                          arguments: {
                                                            'idpod': item["id"],
                                                            'feat': 3,
                                                          },
                                                        );
                                                      },
                                                      child: Row(
                                                        // Add this to prevent overflow
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          SizedBox(
                                                              width: w.width *
                                                                  0.01),
                                                          Image.network(
                                                            s48,
                                                            width: w.width *
                                                                0.07, // Slightly reduce size if needed
                                                            height:
                                                                w.width * 0.07,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          SizedBox(
                                                              width: w.width *
                                                                  0.02), // Reduce spacing slightly
                                                          Container(
                                                            height:
                                                                w.width * 0.2,
                                                            width: w.width *
                                                                0.18, // Adjust width to be slightly smaller
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          w.width *
                                                                              0.04),
                                                              image:
                                                                  DecorationImage(
                                                                image: NetworkImage(
                                                                    item[
                                                                        "urlPhoto"]!),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: w.width *
                                                                  0.02),
                                                          Expanded(
                                                            // Add Expanded to make text take available space
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                    height:
                                                                        w.width *
                                                                            0.0),
                                                                Text(
                                                                  item["name"]!,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: w
                                                                            .width *
                                                                        0.035, // Slightly smaller font
                                                                  ),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        w.width *
                                                                            0.01),
                                                              ],
                                                            ),
                                                          ),
                                                          // No fixed width SizedBox here - let the Expanded handle spacing
                                                          SizedBox(
                                                            width: w.width *
                                                                0.2, // Fixed width for the stats column
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min, // Make row take minimum space
                                                                  children: [
                                                                    Image
                                                                        .network(
                                                                      themeProvider
                                                                              .isDarkMode
                                                                          ? s111
                                                                          : s37,
                                                                      width: w.width *
                                                                          0.04,
                                                                      height:
                                                                          w.width *
                                                                              0.04,
                                                                    ),
                                                                    SizedBox(
                                                                        width: w.width *
                                                                            0.01),
                                                                    Text(
                                                                      formatLikes(
                                                                          item[
                                                                              "likes"]!),
                                                                      style: TextStyle(
                                                                          fontSize: w.width * 0.03, // Slightly smaller font
                                                                          fontWeight: FontWeight.bold),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min, // Make row take minimum space
                                                                  children: [
                                                                    Image
                                                                        .network(
                                                                      themeProvider
                                                                              .isDarkMode
                                                                          ? s108
                                                                          : s14,
                                                                      width: w.width *
                                                                          0.04,
                                                                      height:
                                                                          w.width *
                                                                              0.04,
                                                                    ),
                                                                    SizedBox(
                                                                        width: w.width *
                                                                            0.01),
                                                                    Text(
                                                                      formatLikes(
                                                                          item[
                                                                              "vue"]!),
                                                                      style: TextStyle(
                                                                          fontSize: w.width * 0.03, // Slightly smaller font
                                                                          fontWeight: FontWeight.bold),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min, // Make row take minimum space
                                                                  children: [
                                                                    Image
                                                                        .network(
                                                                      themeProvider
                                                                              .isDarkMode
                                                                          ? s112
                                                                          : s38,
                                                                      width: w.width *
                                                                          0.04,
                                                                      height:
                                                                          w.width *
                                                                              0.04,
                                                                    ),
                                                                    SizedBox(
                                                                        width: w.width *
                                                                            0.01),
                                                                    Text(
                                                                      formatLikes(
                                                                          item[
                                                                              "comments"]!),
                                                                      style: TextStyle(
                                                                          fontSize: w.width * 0.03, // Slightly smaller font
                                                                          fontWeight: FontWeight.bold),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                );
              }),
      ),
    );
  }
}

// RefreshController class pour gérer le pull-to-refresh
class RefreshController {
  VoidCallback? _onRefreshCompleteCallback;
  VoidCallback? _onRefreshFailCallback;

  // Méthode appelée lorsque le rafraîchissement est terminé avec succès
  void refreshCompleted() {
    if (_onRefreshCompleteCallback != null) {
      _onRefreshCompleteCallback!();
    }
  }

  // Méthode appelée lorsque le rafraîchissement échoue
  void refreshFailed() {
    if (_onRefreshFailCallback != null) {
      _onRefreshFailCallback!();
    }
  }

  // Méthode pour nettoyer les ressources
  void dispose() {
    _onRefreshCompleteCallback = null;
    _onRefreshFailCallback = null;
  }
}
