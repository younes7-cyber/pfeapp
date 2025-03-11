import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class Podcastpage extends StatefulWidget {
  const Podcastpage({super.key});
  @override
  State<Podcastpage> createState() => _PodcastpageState();
}

class _PodcastpageState extends State<Podcastpage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> po = [
    {
      "img": "images/qq.png",
      "tit": "The Joe Rogen..JJJJJ",
      "cat": "music",
      "like": "100K",
      "view": "4k",
      "com": "400",
      "tite": "younes",
    },
    {
      "img": "images/ss.png",
      "tit": "Needs A Freinds",
      "cat": "music",
      "like": "900",
      "view": "3.8k",
      "com": "400",
      "tite": "younes",
    },
    {
      "img": "images/dd.png",
      "tit": "Follow Your Dream",
      "cat": "music",
      "like": "700",
      "view": "3.2k",
      "com": "400",
      "tite": "younes",
    },
    {
      "img": "images/a.png",
      "tit": "The Joe Rogen...",
      "cat": "music",
      "like": "500",
      "view": "2.8k",
      "com": "400",
      "tite": "younes",
    },
    {
      "img": "images/b.png",
      "tit": "The Joe Rogen...",
      "cat": "music",
      "like": "200",
      "view": "1k",
      "com": "400",
      "tite": "younes",
    },
  ];
  final List<Map<String, String>> pod = [
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
  bool isPressed = false;
  bool showWhiteContainer = false;
  @override
  Widget build(BuildContext context) {
    final Size w = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
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
                  child: Image.asset("images/his.jpg", fit: BoxFit.cover),
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
                        borderRadius: BorderRadius.circular(w.width * 0.05)),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/podly', (route) => false,
                            arguments: {'selectedIndex': 0});
                      },
                      icon: Image.asset(
                        "images/retour.png",
                        width: w.width * 0.07,
                        height: w.width * 0.07,
                      ),
                    ),
                  )),
              Positioned(
                  top: w.height * 0.01,
                  right: w.width * 0.03,
                  child: Container(
                      width: w.width * 0.09,
                      height: w.width * 0.09,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(w.width * 0.05)),
                      child: PopupMenuButton(
                        icon: Image.asset(
                          "images/menu.png",
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
                                  Image.asset(
                                    "images/report.png",
                                    width: w.width * 0.05,
                                    height: w.width * 0.05,
                                  ),
                                  SizedBox(width: w.width * 0.02),
                                  Text(
                                    "Report",
                                    style: TextStyle(
                                      fontSize: w.width * 0.04,
                                      color: Colors.black, // Couleur du texte
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
              Positioned(
                top: w.height * 0.32,
                right: w.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/listen');
                  },
                  icon: Image.asset(
                    "images/play1.png",
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
                      "Episode 1 | History Of Algeria",
                      style: TextStyle(
                        fontSize: w.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                    ),
                    Text(
                      "17/07/2024",
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
                    Image.asset("images/like.png",
                        width: w.width * 0.05, height: w.width * 0.05),
                    SizedBox(
                      width: w.width * 0.01,
                    ),
                    Text("100k",
                        style: TextStyle(
                          fontSize: w.width * 0.035,
                          color: Colors.black,
                        )),
                    SizedBox(
                      width: w.width * 0.03,
                    ),
                    Image.asset("images/unlike.png",
                        width: w.width * 0.05, height: w.width * 0.05),
                    SizedBox(
                      width: w.width * 0.01,
                    ),
                    Text("100k",
                        style: TextStyle(
                          fontSize: w.width * 0.035,
                          color: Colors.black,
                        )),
                    SizedBox(
                      width: w.width * 0.03,
                    ),
                    Image.asset("images/view.png",
                        width: w.width * 0.05, height: w.width * 0.05),
                    SizedBox(
                      width: w.width * 0.01,
                    ),
                    Text("100k",
                        style: TextStyle(
                          fontSize: w.width * 0.035,
                          color: Colors.black,
                        )),
                    SizedBox(
                      width: w.width * 0.03,
                    ),
                    Image.asset("images/comment.png",
                        width: w.width * 0.05, height: w.width * 0.05),
                    SizedBox(
                      width: w.width * 0.01,
                    ),
                    Text("100k",
                        style: TextStyle(
                          fontSize: w.width * 0.035,
                          color: Colors.black,
                        )),
                    SizedBox(
                      width: w.width * 0.03,
                    ),
                    Image.asset("images/par.png",
                        width: w.width * 0.05, height: w.width * 0.05),
                    SizedBox(
                      width: w.width * 0.01,
                    ),
                    Text("100k",
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
                      fontSize: w.width * 0.04, fontWeight: FontWeight.bold),
                ),
              ),

// Fix the second ReadMoreText (at w.height * 0.5)
              Positioned(
                top: w.height * 0.49,
                left: w.width * 0.05, // Add left positioning
                child: Container(
                  width: w.width * 0.9, // Add width constraint
                  child: ReadMoreText(
                    'Flutter is Googles mobile UI open source framework to build high-quality native (super fast) interfaces for iOS and Android apps with the unified codebase.',
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
                          borderRadius: BorderRadius.circular(w.width * 0.2)),
                      child: ClipOval(
                        child: Image.asset(
                          "images/person.jpg",
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
                              "Younes Benslimane",
                              style: TextStyle(
                                  fontSize: w.width * 0.045,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                        Text("100k",
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
                                ? Border.all(color: const Color(0xFF754CEF))
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
                                      Image.asset(
                                        "images/follow.png",
                                        width: w.width * 0.05,
                                        height: w.width * 0.05,
                                      ),
                                      SizedBox(width: w.width * 0.01),
                                      Text(
                                        "Following",
                                        style: TextStyle(
                                          color: const Color(0xFF754CEF),
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
                  ])),
              Positioned(
                  top: w.height * 0.71,
                  left: w.width * 0.03,
                  child: Row(children: [
                    Image.asset(
                      "images/more.png",
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
                    itemCount: po.length,
                    itemBuilder: (context, index) {
                      final podItem = po[index];
                      return Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: w.width * 0.02),
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
                                  image: AssetImage(podItem["img"] ??
                                      "images/placeholder.png"),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    print('Error loading image: $exception');
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: w.width * 0.01),
                            Flexible(
                                child: Text(
                              podItem["tit"] ?? "Untitled",
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
                              podItem["tite"] ?? "Unknown",
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
