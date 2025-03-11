import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class Playlistpage extends StatefulWidget {
  const Playlistpage({super.key});
  @override
  State<Playlistpage> createState() => _PlaylistpageState();
}

class _PlaylistpageState extends State<Playlistpage>
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
                  child: Image.asset("images/come.jpg", fit: BoxFit.cover),
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
                top: w.height * 0.33,
                right: w.width * 0.05,
                child: Image.asset(
                  "images/play1.png",
                  width: w.width * 0.14,
                  height: w.width * 0.14,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: w.height * 0.33,
                child: Container(
                  width: w.width * 0.7,
                  child: Column(children: [
                    Text(
                      "Collection Mr Beast",
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

// Fix the typo in the description text
              Positioned(
                top: w.height * 0.43,
                left: w.width * 0.05,
                child: Text(
                  "Description", // Fixed spelling
                  style: TextStyle(
                      fontSize: w.width * 0.04, fontWeight: FontWeight.bold),
                ),
              ),

// Fix the second ReadMoreText (at w.height * 0.5)
              Positioned(
                top: w.height * 0.46,
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
                  left: w.width * 0.25,
                  child: Row(children: [
                    Container(
                      child: GestureDetector(
                        child: Row(
                          children: [
                            Image.asset(
                              "images/sav.png",
                              width: w.width * 0.06,
                              height: w.width * 0.06,
                            ),
                            SizedBox(
                              width: w.width * 0.02,
                            ),
                            Text(
                              "Save",
                              style: TextStyle(
                                  fontSize: w.width * 0.035,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: w.width * 0.1,
                    ),
                    Container(
                      child: GestureDetector(
                        child: Row(
                          children: [
                            Image.asset(
                              "images/par.png",
                              width: w.width * 0.06,
                              height: w.width * 0.06,
                            ),
                            SizedBox(
                              width: w.width * 0.02,
                            ),
                            Text(
                              "Share",
                              style: TextStyle(
                                  fontSize: w.width * 0.035,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  ])),
              Positioned(
                top: w.height * 0.65, // Adjust position as needed
                left: 0,
                right: 0,
                bottom:
                    0, // Add a bottom constraint to give the ListView a defined space
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: w.width * 0.02),
                  child: ListView.builder(
                    itemCount: pod.length,
                    itemBuilder: (context, index) {
                      final item = pod[index];
                      return Container(
                        margin: EdgeInsets.all(w.width * 0.02),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(w.width * 0.05),
                          border: Border.all(color: Colors.black12),
                        ),
                        width: w.width * 0.95,
                        height: w.width * 0.3,
                        child: Row(
                          // Add this to prevent overflow
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(width: w.width * 0.01),
                            Image.asset(
                              "images/play1.png",
                              width: w.width *
                                  0.07, // Slightly reduce size if needed
                              height: w.width * 0.07,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                                width:
                                    w.width * 0.02), // Reduce spacing slightly
                            Container(
                              height: w.width * 0.2,
                              width: w.width *
                                  0.18, // Adjust width to be slightly smaller
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(w.width * 0.04),
                                image: DecorationImage(
                                  image: AssetImage(item["img"]!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: w.width * 0.02),
                            Expanded(
                              // Add Expanded to make text take available space
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: w.width * 0.0),
                                  Text(
                                    item["tit"]!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: w.width *
                                          0.035, // Slightly smaller font
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: w.width * 0.01),
                                ],
                              ),
                            ),
                            // No fixed width SizedBox here - let the Expanded handle spacing
                            Container(
                              width: w.width *
                                  0.2, // Fixed width for the stats column
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Make row take minimum space
                                    children: [
                                      Image.asset(
                                        "images/like.png",
                                        width: w.width * 0.04,
                                        height: w.width * 0.04,
                                      ),
                                      SizedBox(width: w.width * 0.01),
                                      Text(
                                        item["like"]!,
                                        style: TextStyle(
                                            fontSize: w.width *
                                                0.03, // Slightly smaller font
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Make row take minimum space
                                    children: [
                                      Image.asset(
                                        "images/view.png",
                                        width: w.width * 0.04,
                                        height: w.width * 0.04,
                                      ),
                                      SizedBox(width: w.width * 0.01),
                                      Text(
                                        item["view"]!,
                                        style: TextStyle(
                                            fontSize: w.width *
                                                0.03, // Slightly smaller font
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Make row take minimum space
                                    children: [
                                      Image.asset(
                                        "images/comment.png",
                                        width: w.width * 0.04,
                                        height: w.width * 0.04,
                                      ),
                                      SizedBox(width: w.width * 0.01),
                                      Text(
                                        item["com"]!,
                                        style: TextStyle(
                                            fontSize: w.width *
                                                0.03, // Slightly smaller font
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  // Similar modifications for view and comment rows
                                  // ...
                                ],
                              ),
                            ),
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
