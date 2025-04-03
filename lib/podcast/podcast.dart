import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
import 'package:readmore/readmore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Podcastpage extends StatefulWidget {
  const Podcastpage({super.key});
  @override
  State<Podcastpage> createState() => _PodcastpageState();
}

class _PodcastpageState extends State<Podcastpage>
    with SingleTickerProviderStateMixin {
  // Récupération de l'ID
  String? idpod;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final user = FirebaseAuth.instance.currentUser?.uid;
  bool isLoading = true;
  List<Map<String, dynamic>> podcast = [];
  List<Map<String, dynamic>> channel = [];
  List<Map<String, dynamic>> userPodcasts = [];
  bool isYourPodcast = false;
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
            .where('idUser', isEqualTo: idUser)
            .get();

        if (podcastsSnapshot.docs.isNotEmpty) {
          setState(() {
            userPodcasts = podcastsSnapshot.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
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
          await fetchPodcastById(idpod!);
          await fetchChannelByPodcastId(idpod!);
          await fetchPodcastsByUserId(idpod!);
          await checkIfCurrentUserOwnsPodcast(idpod!);
        }
      }

      setState(() => isLoading = false);
    });
  }

  bool isPressed = false;
  bool showWhiteContainer = false;
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
                        height: w.height * 0.35,
                        child: Image.network(podcast[0]["urlPhoto"],
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: w.width * 0.6,
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
                      top: w.height * 0.32,
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
                      top: w.height * 0.33,
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
                            podcast[0]["dateCreation"].toString(),
                            style: TextStyle(
                              fontSize: w.width * 0.04,
                            ),
                            maxLines: 3,
                          ),
                        ]),
                      ),
                    ),
                    Positioned(
                        top: w.height * 0.42,
                        left: w.width * 0.05,
                        child: Row(children: [
                          Image.network(s37,
                              width: w.width * 0.05, height: w.width * 0.05),
                          SizedBox(
                            width: w.width * 0.01,
                          ),
                          Text(podcast[0]["likes"].toString(),
                              style: TextStyle(
                                fontSize: w.width * 0.035,
                                color: Colors.black,
                              )),
                          SizedBox(
                            width: w.width * 0.05,
                          ),
                          Image.network(s41,
                              width: w.width * 0.05, height: w.width * 0.05),
                          SizedBox(
                            width: w.width * 0.01,
                          ),
                          Text(podcast[0]["unlikes"].toString(),
                              style: TextStyle(
                                fontSize: w.width * 0.035,
                                color: Colors.black,
                              )),
                          SizedBox(
                            width: w.width * 0.05,
                          ),
                          Image.network(s14,
                              width: w.width * 0.05, height: w.width * 0.05),
                          SizedBox(
                            width: w.width * 0.01,
                          ),
                          Text(podcast[0]["vue"].toString(),
                              style: TextStyle(
                                fontSize: w.width * 0.035,
                                color: Colors.black,
                              )),
                          SizedBox(
                            width: w.width * 0.05,
                          ),
                          Image.network(s38,
                              width: w.width * 0.05, height: w.width * 0.05),
                          SizedBox(
                            width: w.width * 0.01,
                          ),
                          Text(podcast[0]["comments"].toString(),
                              style: TextStyle(
                                fontSize: w.width * 0.035,
                                color: Colors.black,
                              )),
                          SizedBox(
                            width: w.width * 0.05,
                          ),
                          Image.network(s45,
                              width: w.width * 0.05, height: w.width * 0.05),
                          SizedBox(
                            width: w.width * 0.01,
                          ),
                          Text(podcast[0]["shares"].toString(),
                              style: TextStyle(
                                fontSize: w.width * 0.035,
                                color: Colors.black,
                              )),
                        ])),

// Fix the typo in the description text
                    Positioned(
                      top: w.height * 0.46,
                      left: w.width * 0.05,
                      child: Text(
                        "Description", // Fixed spelling
                        style: TextStyle(
                            fontSize: w.width * 0.04,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

// Fix the second ReadMoreText (at w.height * 0.5)
                    Positioned(
                      top: w.height * 0.49,
                      left: w.width * 0.05, // Add left positioning
                      child: Container(
                        width: w.width * 0.9, // Add width constraint
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
                    ),
                    Positioned(
                        top: w.height * 0.6,
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
                              Text(channel[0]["followers"].toString(),
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
                          if (isYourPodcast == false) ...[
                            SizedBox(
                              height: w.height * 0.05,
                              width: w.width * 0.3,
                              child: MaterialButton(
                                onPressed: () {
                                  setState(() {
                                    isPressed = !isPressed;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 1),
                                  height: w.height * 0.05,
                                  width: w.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: isPressed
                                        ? Colors.white
                                        : const Color(0xFF754CEF),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(w.width * 0.05),
                                    ),
                                    border: isPressed
                                        ? Border.all(
                                            color: const Color(0xFF754CEF))
                                        : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (!isPressed)
                                        Positioned(
                                          top: w.height * 0.014,
                                          left: w.width * 0.012,
                                          child: Text(
                                            "Follow Now",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: w.width * 0.035,
                                            ),
                                          ),
                                        ),
                                      if (isPressed)
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
                          ],
                        ])),
                    Positioned(
                        top: w.height * 0.71,
                        left: w.width * 0.03,
                        child: Row(children: [
                          Image.network(
                            s52,
                            width: w.width * 0.06,
                            height: w.width * 0.06,
                          ),
                          SizedBox(
                            width: w.width * 0.02,
                          ),
                          Text(
                            "More Podcast",
                            style: TextStyle(
                                fontSize: w.width * 0.04,
                                fontWeight: FontWeight.bold),
                          )
                        ])),
                    Positioned(
                      top: w.height * 0.75, // Adjust position as needed
                      left: 0,
                      right: 0,
                      bottom:
                          0, // Add a bottom constraint to give the ListView a defined space
                      child: SizedBox(
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
                                mainAxisSize: MainAxisSize.min, // Add this
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: w.width * 0.2,
                                    width: w.width * 0.2,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(w.width * 0.04),
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(podItem["urlPhoto"]),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {
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
                                  SizedBox(
                                    height: w.width * 0.01,
                                  ),
                                  Flexible(
                                      child: Text(
                                    channel[0]["name"],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: w.width * 0.035,
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
