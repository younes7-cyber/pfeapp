import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfeapp/constants.dart';

class YourChainepage extends StatefulWidget {
  const YourChainepage({super.key});
  @override
  State<YourChainepage> createState() => _YourChainepageState();
}

class _YourChainepageState extends State<YourChainepage>
    with SingleTickerProviderStateMixin {
  bool hasError = false;
  List<Map<String, dynamic>> channels = [];
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> playlist = [];
  bool isPressed = false;
  bool showWhiteContainer = false;
  late int r = 1;
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);
    fetchChannels();
    fetchpodcasts();
    fetchplaylists();
  }

  Future<void> fetchChannels() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('channels')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de chaînes trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des chaînes : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        channels = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {
        hasError = true;
      });
    }
  }

  Future<void> fetchpodcasts() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('podcasts')
          .where('idUser', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de podcast trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des podcast : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        podcast = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {
        hasError = true;
      });
    }
  }

  Future<void> fetchplaylists() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlist')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de playlist trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des playlist : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        playlist = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
      setState(() {
        hasError = true;
      });
    }
  }

  late TabController _tabController1;
  @override
  void dispose() {
    _tabController1.dispose();
    super.dispose();
  }

  late int q = 1;
  late int y = 1;
  late int o = 1;
  @override
  Widget build(BuildContext context) {
    final Size v = MediaQuery.of(context).size;

    if (hasError) {
      return const Scaffold(
        body: Center(
          child: Text('Une erreur est survenue.'),
        ),
      );
    }

    if (channels.isEmpty) {
      return Scaffold(
          body: SafeArea(
              child: Container(
                  decoration: BoxDecoration(color: Colors.white),
                  width: double.infinity, // Added to provide width constraint
                  height: double.infinity, // Added to provide height constraint

                  child: Column(children: [
                    SizedBox(
                      height: v.height * 0.15,
                    ),
                    SizedBox(
                      height: v.height * 0.3,
                      width: v.width * 0.7,
                      child: Container(
                        child: Image.network(
                          s27,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: v.height * 0.1,
                    ),
                    Container(
                      height: v.height * 0.075,
                      width: v.width * 0.6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF754CEF),
                        borderRadius: BorderRadius.circular(v.width * 0.05),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/ch',
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Create",
                          style: TextStyle(
                              color: Colors.white, fontSize: v.width * 0.042),
                        ),
                      ),
                    ),
                  ]))));
    }
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        width: double.infinity, // Added to provide width constraint
        height: double.infinity, // Added to provide height constraint

        child: Column(
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
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/podly', (route) => false,
                            arguments: {'selectedIndex': 4});
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
                          s34,
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
                                    s35,
                                    width: v.width * 0.05,
                                    height: v.width * 0.05,
                                  ),
                                  SizedBox(width: v.width * 0.02),
                                  Text(
                                    "Your Information",
                                    style: TextStyle(
                                      fontSize: v.width * 0.04,
                                      color: Colors.black, // Couleur du texte
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/modif',
                                  arguments: 3);
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
                            "younes benslimane",
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
                            borderRadius: BorderRadius.circular(v.width * 0.2)),
                        child: ClipOval(
                          child: Image.asset(
                            "images/person.jpg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                  Positioned(
                      top: v.height * 0.116,
                      left: v.width * 0.55,
                      child: Container(
                        width: v.width * 0.09,
                        height: v.width * 0.09,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(v.width * 0.2)),
                      )),
                  Positioned(
                      top: v.height * 0.121,
                      left: v.width * 0.56,
                      child: Container(
                        width: v.width * 0.07,
                        height: v.width * 0.07,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(v.width * 0.2)),
                        child: Image.network(s26),
                      )),
                  Positioned(
                      top: v.height * 0.25,
                      left: v.width * 0.07,
                      right: v.width * 0.07,
                      child: Container(
                        width: v.width * 0.8,
                        height: v.height * 0.002, // Épaisseur de la ligne
                        color: Colors.grey[400],
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
                  "natalia1000@gmail.com",
                  style: TextStyle(
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
                        "111",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: v.width * 0.04),
                      ),
                      Text(
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
                        "1k",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: v.width * 0.04),
                      ),
                      Text(
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
                        "246k",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: v.width * 0.04),
                      ),
                      Text(
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
              child: Row(
                // Remplacer Stack et Positioned par une simple Row
                children: [
                  // Premier élément (Upload Podcast)
                  Expanded(
                    // Utiliser Expanded pour partager l'espace disponible
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/po', arguments: 3);
                      },
                      child: Row(
                        children: [
                          SizedBox(width: v.width * 0.01), // Marge à gauche
                          Image.network(s30,
                              width: v.width * 0.06, height: v.width * 0.06),
                          SizedBox(
                              width: v.width *
                                  0.02), // Espace entre l'image et le texte
                          Text("Upload Podcast"),
                        ],
                      ),
                    ),
                  ),

                  // Deuxième élément (Create Playlist)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/pl', arguments: 3);
                      },
                      child: Row(
                        children: [
                          SizedBox(width: v.width * 0.04), // Marge à gauche
                          Image.network(s33,
                              width: v.width * 0.06, height: v.width * 0.06),
                          SizedBox(
                              width: v.width *
                                  0.02), // Espace entre l'image et le texte
                          Text("Create Playlist"),
                        ],
                      ),
                    ),
                  ),
                ],
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
                  Column(children: [
                    // See All header for Podcast
                    if (podcast.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          itemCount: podcast.length,
                          itemBuilder: (context, index) {
                            final item = podcast[index];
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
                                    context,
                                    '/podcast',
                                    arguments: {
                                      'idpod': item["id"]
                                    }, // Envoie l'ID
                                  );
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: v.width * 0.01),
                                    Container(
                                      height: v.width * 0.2,
                                      width: v.width * 0.2,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            v.width * 0.04),
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(item["urlPhoto"]!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: v.width * 0.01),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: v.width * 0.35,
                                          child: Text(
                                            item["name"]!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: v.width * 0.04,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: v.width * 0.015),
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
                                                      child: Image.network(s37),
                                                      width: v.width * 0.05,
                                                      height: v.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: v.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["likes"].toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              v.width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: v.width * 0.02,
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      child: Image.network(s14),
                                                      width: v.width * 0.05,
                                                      height: v.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: v.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["vue"].toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              v.width * 0.035,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: v.width * 0.02,
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      child: Image.network(s38),
                                                      width: v.width * 0.05,
                                                      height: v.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: v.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["comments"]
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize:
                                                              v.width * 0.035,
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
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/modif',
                                            arguments: 4);
                                      },
                                      icon: Image.network(
                                        s34,
                                        width: v.width * 0.05,
                                        height: v.width * 0.05,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (podcast.isEmpty) ...[
                      Column(children: [
                        SizedBox(
                          height: v.height * 0.05,
                        ),
                        SizedBox(
                          width: v.width * 0.7,
                          height: v.height * 0.3,
                          child: Container(
                            child: Image.network(s28),
                          ),
                        ),
                        Text("No Podcast Please Upload",
                            style: TextStyle(
                                fontSize: v.width * 0.04,
                                fontWeight: FontWeight.bold)),
                      ])
                    ],
                  ]),
                  Column(children: [
                    // See All header for Podcast
                    if (playlist.isEmpty) ...[
                      Column(children: [
                        SizedBox(
                          height: v.height * 0.05,
                        ),
                        SizedBox(
                          width: v.width * 0.7,
                          height: v.height * 0.3,
                          child: Container(
                            child: Image.network(s28),
                          ),
                        ),
                        Text("No Playlist Please Create",
                            style: TextStyle(
                                fontSize: v.width * 0.04,
                                fontWeight: FontWeight.bold)),
                      ])
                    ],
                    if (playlist.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          itemCount: playlist.length,
                          itemBuilder: (context, index) {
                            final item = playlist[index];
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
                                        borderRadius: BorderRadius.circular(
                                            v.width * 0.04),
                                        image: DecorationImage(
                                          image:
                                              NetworkImage(item["photoUrl"]!),
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: v.width * 0.03,
                                    ),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                              width: v.width *
                                                  0.19, // Constrain the width of the progress bar
                                              child: Column(children: [
                                                SizedBox(
                                                  height: v.width * 0.02,
                                                ),
                                                Row(children: [
                                                  Text(
                                                    item["podcast"]!.toString(),
                                                    style: TextStyle(
                                                      fontSize: v.width * 0.035,
                                                    ),
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    width: v.width * 0.03,
                                                  ),
                                                  Text(
                                                    "Podcast",
                                                    style: TextStyle(
                                                      fontSize: v.width * 0.035,
                                                    ),
                                                    maxLines: 4,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ])
                                              ]))
                                        ]),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/modif',
                                            arguments: 5);
                                      },
                                      icon: Image.network(
                                        s34,
                                        width: v.width * 0.05,
                                        height: v.width * 0.05,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
