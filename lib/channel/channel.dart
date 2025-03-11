import 'package:flutter/material.dart';

class Channelpage extends StatefulWidget {
  const Channelpage({super.key});
  @override
  State<Channelpage> createState() => _ChannelpageState();
}

class _ChannelpageState extends State<Channelpage>
    with SingleTickerProviderStateMixin {
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
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this);
  }

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
                            arguments: {'selectedIndex': 0});
                      },
                      icon: Image.asset(
                        "images/retour.png",
                        width: v.width * 0.07,
                        height: v.width * 0.07,
                      ),
                    ),
                  ),
                  Positioned(
                      top: v.height * 0.01,
                      right: v.width * 0.03,
                      child: PopupMenuButton(
                        icon: Image.asset(
                          "images/menu.png",
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
                                  Image.asset(
                                    "images/report.png",
                                    width: v.width * 0.05,
                                    height: v.width * 0.05,
                                  ),
                                  SizedBox(width: v.width * 0.02),
                                  Text(
                                    "Report",
                                    style: TextStyle(
                                      fontSize: v.width * 0.04,
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
                      )),
                  Positioned(
                    top: v.height * 0.05,
                    left: v.width * 0.39,
                    child: Positioned(
                        top: v.height * 0.02,
                        left: v.width * 0.3,
                        child: Container(
                            width: v.width * 0.4,
                            height: v.height * 0.1,
                            //      decoration: BoxDecoration(color: Colors.black),
                            child: Text(
                              "younes benslimane",
                              style: TextStyle(
                                  fontSize: v.width * 0.06,
                                  fontWeight: FontWeight.bold),
                            ))),
                  ),
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
                            "images/nat.png",
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
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    isPressed = !isPressed;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1),
                  height: v.height * 0.07,
                  width: v.width * 0.75,
                  decoration: BoxDecoration(
                    color: isPressed ? Colors.white : const Color(0xFF754CEF),
                    borderRadius: BorderRadius.all(
                      Radius.circular(v.width * 0.05),
                    ),
                    border: isPressed
                        ? Border.all(color: const Color(0xFF754CEF))
                        : null,
                  ),
                  child: Stack(
                    children: [
                      if (!isPressed)
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
                      if (isPressed)
                        Positioned(
                          top: v.height * 0.015,
                          left: v.width * 0.2,
                          child: Row(
                            children: [
                              Image.asset(
                                "images/follow.png",
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
                                  icon: Image.asset(
                                    "images/aa.png",
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
                          itemCount: pod.length,
                          itemBuilder: (context, index) {
                            final item = pod[index];
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
                                  Navigator.pushNamed(context, '/podcast');
                                },
                                child: Row(
                                  children: [
                                    SizedBox(width: v.width * 0.01),
                                    Container(
                                      child: Image.asset(
                                        "images/play1.png",
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
                                        borderRadius: BorderRadius.circular(
                                            v.width * 0.04),
                                        image: DecorationImage(
                                          image: AssetImage(item["img"]!),
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
                                            item["tit"]!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: v.width * 0.04,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
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
                                                      child: Image.asset(
                                                          "images/like.png"),
                                                      width: v.width * 0.05,
                                                      height: v.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: v.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["like"]!,
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
                                                      child: Image.asset(
                                                          "images/view.png"),
                                                      width: v.width * 0.05,
                                                      height: v.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: v.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["view"]!,
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
                                                      child: Image.asset(
                                                          "images/comment.png"),
                                                      width: v.width * 0.05,
                                                      height: v.width * 0.05,
                                                    ),
                                                    SizedBox(
                                                      width: v.width * 0.01,
                                                    ),
                                                    Text(
                                                      item["com"]!,
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
                                  icon: Image.asset(
                                    "images/aa.png",
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
                          itemCount: play.length,
                          itemBuilder: (context, index) {
                            final item = play[index];
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
                                          image: AssetImage(item["img"]!),
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
                                            item["tit"]!,
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
                                                Text(
                                                  item["tite"]!,
                                                  style: TextStyle(
                                                    fontSize: v.width * 0.035,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
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
