import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Podlypage extends StatefulWidget {
  const Podlypage({super.key});

  @override
  State<Podlypage> createState() => _PodlypageState();
}

class _PodlypageState extends State<Podlypage> {
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email'); // Supprime l'utilisateur sauvegardé
  }

  final List<Map<String, String>> po = [
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
  final List<Map<String, String>> pod = [
    {"img": "images/a.png", "tit": "The Joe Rogen...", "tite": "younes"},
    {"img": "images/b.png", "tit": "Needs A Freinds", "tite": "younes"},
    {"img": "images/c.png", "tit": "Follow Your Dream", "tite": "younes"},
    {"img": "images/a.png", "tit": "The Joe Rogen...", "tite": "younes"},
    {"img": "images/b.png", "tit": "The Joe Rogen...", "tite": "younes"},
    {"img": "images/c.png", "tit": "The Joe Rogen...", "tite": "younes"},
  ];
  final List<Map<String, String>> cra = [
    {"img": "images/d.png", "tite": "Younes"},
    {"img": "images/e.png", "tite": "ALi"},
    {"img": "images/f.png", "tite": "Abderahmne"},
    {"img": "images/g.png", "tite": "Mohammed"},
    {"img": "images/h.png", "tite": "Amine"},
  ];
  final List<Map<String, String>> cat = [
    {"tite": "Education", "img": "images/ed.jpg"},
    {"tite": "History", "img": "images/his.jpg"},
    {"tite": "Comedie", "img": "images/come.jpg"},
    {"tite": "Tv&Films", "img": "images/film.jpg"},
    {"tite": "Music", "img": "images/music.jpg"},
    {"tite": "Books", "img": "images/book.jpg"},
    {"tite": "Culture", "img": "images/cultur.jpg"},
    {"tite": "Self", "img": "images/self.jpg"},
    {"tite": "Marketing", "img": "images/mar.jpg"},
    {"tite": "Sport", "img": "images/sport.jpg"},
    {"tite": "Gaming", "img": "images/game.jpg"},
    {"tite": "Food", "img": "images/food.jpg"},
    {"tite": "Travel", "img": "images/travel.jpg"},
    {"tite": "Religion", "img": "images/rel.jpg"},
    {"tite": "Art", "img": "images/art.jpg"},
    {"tite": "Sciences", "img": "images/sience.jpg"},
  ];
  final List<Map<String, String>> play = [
    {"img": "images/person.jpg", "tit": "My Playlist", "tite": "50 Podcast"},
    {"img": "images/k.png", "tit": "Need A Freind", "tite": "63 Podcast"},
    {"img": "images/k.png", "tit": "Need A Freind", "tite": "70 Podcast"},
    {"img": "images/xx.png", "tit": "Music", "tite": "15 Podcast"},
  ];
  final List<Map<String, String>> cre = [
    {"img": "images/w.png", "tite": "Younes"},
    {"img": "images/x.png", "tite": "ALi"},
    {"img": "images/v.png", "tite": "Abderahmne"},
    {"img": "images/n.png", "tite": "Mohammed"},
    {"img": "images/l.png", "tite": "Amine"},
  ];
  bool val = false;
  bool val1 = true;
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _selectedIndex = 0;
  late int r = 1;
  late int q = 1;
  @override
  void initState() {
    super.initState();
    // Ajouter un listener pour détecter les changements de scroll
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentIndex != next) {
        setState(() {
          _currentIndex = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      _showBottomSheet();
    }
  }

  late int y = 1;
  late int o = 1;
  late int ch = 1;
  void _showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Image.asset("images/cha.png", width: 25, height: 25),
                title: Text("Create Channel"),
                onTap: () {
                  Navigator.pushNamed(context, '/ch', arguments: 2);
                  // Ajouter navigation ou logique ici
                },
              ),
              ListTile(
                leading:
                    Image.asset("images/podcast.png", width: 25, height: 25),
                title: Text("Upload Podcast"),
                onTap: () {
                  Navigator.pushNamed(context, '/po', arguments: 2);
                  // Ajouter navigation ou logique ici
                },
              ),
              ListTile(
                leading: Image.asset("images/playl.png", width: 25, height: 25),
                title: Text("Create Playlist"),
                onTap: () {
                  Navigator.pushNamed(context, '/pl', arguments: 2);
                  // Ajouter navigation ou logique ici
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('selectedIndex')) {
      setState(() {
        _selectedIndex = args['selectedIndex'];
      });
    }
  }

  Widget _buildBody(BuildContext context) {
    final Size x = MediaQuery.of(context).size;

    switch (_selectedIndex) {
      case 0:
        r = 1;
        print(r);
        return Column(
          children: [
            SizedBox(
              height: x.height * 0.15,
              child: Stack(
                children: [
                  Positioned(
                    top: x.height * 0.005,
                    left: x.width * 0.005,
                    child: Row(
                      children: [
                        SizedBox(
                          width: x.width * 0.15,
                          height: x.width * 0.15,
                          child: Image.asset(
                            "images/podly.jpg",
                            width: x.width * 0.15,
                            height: x.width * 0.15,
                          ),
                        ),
                        Text(
                          "Podly",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: x.height * 0.033,
                    right: x.width * 0.07,
                    child: Row(
                      children: [
                        SizedBox(
                          width: x.width * 0.05, // Added width
                          height: x.width * 0.05, // Added height
                          child: GestureDetector(
                            onTap: () {
                              showSearch(context: context, delegate: Search());
                            },
                            child: Image.asset(
                              "images/search.png",
                              width: x.width * 0.05,
                              height: x.width * 0.05,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: x.width * 0.05, // Added width
                          height: x.width * 0.05, // Added height
                        ),
                        SizedBox(
                          width: x.width * 0.05, // Added width
                          height: x.width * 0.05, // Added height
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/nofi');
                            },
                            child: Image.asset(
                              "images/nofi.png",
                              width: x.width * 0.05,
                              height: x.width * 0.05,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                      top: x.height * 0.08,
                      left: x.width * 0.08,
                      child: Text(
                        "Hello Younes3100",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: x.width * 0.065),
                      ))
                ],
              ),
            ),
            SizedBox(
              height: x.height * 0.03,
              child: Stack(
                children: [
                  Positioned(
                      left: x.width * 0.05,
                      child: Text(
                        "Featured",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: x.width * 0.05),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: x.height * 0.22,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Container(
                          margin:
                              EdgeInsets.symmetric(horizontal: x.width * 0.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(x.width * 0.05),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            "images/fetur.png",
                            fit: BoxFit.fill,
                          ),
                        );
                      },
                    ),
                  ),
                  // Indicateurs de points
                  SizedBox(height: x.width * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        width: x.width * 0.015,
                        height: x.width * 0.015,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? const Color(0xFF754CEF)
                              : const Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  height: x.height * 0.05,
                  child: Stack(children: [
                    Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Recently Played",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        )),
                    Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: SizedBox(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.asset("images/o.png"),
                        )),
                    Positioned(
                        top: x.height * 0.007,
                        right: x.width * 0.12,
                        child: Text(
                          "See All",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: const Color(0xFF754CEF)),
                        )),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  3, // Passe la valeur de r comme argument
                            );

                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ])),
              SizedBox(
                height: x.height * 0.23,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pod.length,
                  itemBuilder: (context, index) {
                    final podItem = pod[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.2,
                      height: x.width *
                          0.35, // Increased height to accommodate content
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Add this
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: x.width * 0.2,
                            width: x.width * 0.2,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.04),
                              image: DecorationImage(
                                image: AssetImage(
                                    podItem["img"] ?? "images/placeholder.png"),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: x.width * 0.01),
                          Flexible(
                              child: Text(
                            podItem["tit"] ?? "Untitled",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.04,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                          SizedBox(
                            height: x.width * 0.01,
                          ),
                          Flexible(
                              child: Text(
                            podItem["tite"] ?? "Unknown",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: x.width * 0.035,
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
                  height: x.height * 0.05,
                  child: Stack(children: [
                    Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Recommended For you",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        )),
                    Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: SizedBox(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.asset("images/q.png"),
                        )),
                    Positioned(
                        top: x.height * 0.007,
                        right: x.width * 0.12,
                        child: Text(
                          "See All",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: const Color(0xFF754CEF)),
                        )),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  4, // Passe la valeur de r comme argument
                            );
                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ])),
              SizedBox(
                height: x.height * 0.23,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: po.length,
                  itemBuilder: (context, index) {
                    final podItem = po[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.2,
                      height: x.width *
                          0.35, // Increased height to accommodate content
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Add this
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: x.width * 0.2,
                            width: x.width * 0.2,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.04),
                              image: DecorationImage(
                                image: AssetImage(
                                    podItem["img"] ?? "images/placeholder.png"),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: x.width * 0.01),
                          Flexible(
                              child: Text(
                            podItem["tit"] ?? "Untitled",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.04,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                          SizedBox(
                            height: x.width * 0.01,
                          ),
                          Flexible(
                              child: Text(
                            podItem["tite"] ?? "Unknown",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: x.width * 0.035,
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
                  height: x.height * 0.05,
                  child: Stack(children: [
                    Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Top Creator",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        )),
                    Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: SizedBox(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.asset("images/u.png"),
                        )),
                    Positioned(
                        top: x.height * 0.007,
                        right: x.width * 0.12,
                        child: Text(
                          "See All",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: const Color(0xFF754CEF)),
                        )),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  5, // Passe la valeur de r comme argument
                            );
                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ])),
              SizedBox(
                height: x.height * 0.23,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cra.length,
                  itemBuilder: (context, index) {
                    final craItem = cra[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: x.width * 0.2,
                              width: x.width * 0.2,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(x.width * 0.1),
                                image: DecorationImage(
                                  image: AssetImage(craItem["img"] ??
                                      "images/placeholder.png"),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    print('Error loading image: $exception');
                                  },
                                ),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/channel');
                                },
                              )),
                          SizedBox(
                            height: x.width * 0.01,
                          ),
                          Text(
                            craItem["tite"] ?? "Unknown",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.03,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                  height: x.height * 0.05,
                  child: Stack(children: [
                    Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Trending Podcast",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        )),
                    Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: SizedBox(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.asset("images/r.png"),
                        )),
                    Positioned(
                        top: x.height * 0.007,
                        right: x.width * 0.12,
                        child: Text(
                          "See All",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: const Color(0xFF754CEF)),
                        )),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  6, // Passe la valeur de r comme argument
                            );
                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ])),
              SizedBox(
                height: x.height * 0.23,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pod.length,
                  itemBuilder: (context, index) {
                    final podItem = pod[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.2,
                      height: x.width *
                          0.35, // Increased height to accommodate content
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Add this
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: x.width * 0.2,
                            width: x.width * 0.2,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.04),
                              image: DecorationImage(
                                image: AssetImage(
                                    podItem["img"] ?? "images/placeholder.png"),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: x.width * 0.01),
                          Flexible(
                              child: Text(
                            podItem["tit"] ?? "Untitled",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.04,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                          SizedBox(
                            height: x.width * 0.01,
                          ),
                          Flexible(
                              child: Text(
                            podItem["tite"] ?? "Unknown",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: x.width * 0.035,
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
                  height: x.height * 0.05,
                  child: Stack(children: [
                    Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Top Liked",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        )),
                    Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: SizedBox(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.asset("images/i.png"),
                        )),
                    Positioned(
                        top: x.height * 0.007,
                        right: x.width * 0.12,
                        child: Text(
                          "See All",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: const Color(0xFF754CEF)),
                        )),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  7, // Passe la valeur de r comme argument
                            );
                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ])),
              SizedBox(
                height: x.height * 0.23,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pod.length,
                  itemBuilder: (context, index) {
                    final podItem = pod[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.2,
                      height: x.width *
                          0.35, // Increased height to accommodate content
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Add this
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: x.width * 0.2,
                            width: x.width * 0.2,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.04),
                              image: DecorationImage(
                                image: AssetImage(
                                    podItem["img"] ?? "images/placeholder.png"),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: x.width * 0.01),
                          Flexible(
                              child: Text(
                            podItem["tit"] ?? "Untitled",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.04,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                          SizedBox(
                            height: x.width * 0.01,
                          ),
                          Flexible(
                              child: Text(
                            podItem["tite"] ?? "Unknown",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: x.width * 0.035,
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
                  height: x.height * 0.05,
                  child: Stack(children: [
                    Positioned(
                        left: x.width * 0.08,
                        child: Text(
                          "Top Seen ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.05),
                        )),
                    Positioned(
                        top: x.height * 0.01,
                        left: x.width * 0.03,
                        child: Container(
                          width: x.width * 0.04,
                          height: x.width * 0.04,
                          child: Image.asset("images/t.png"),
                        )),
                    Positioned(
                        top: x.height * 0.007,
                        right: x.width * 0.12,
                        child: Text(
                          "See All",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.035,
                              color: Color(0xFF754CEF)),
                        )),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  8, // Passe la valeur de r comme argument
                            );
                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ])),
              SizedBox(
                height: x.height * 0.23,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pod.length,
                  itemBuilder: (context, index) {
                    final podItem = pod[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.2,
                      height: x.width *
                          0.35, // Increased height to accommodate content
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Add this
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: x.width * 0.2,
                            width: x.width * 0.2,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(x.width * 0.04),
                              image: DecorationImage(
                                image: AssetImage(
                                    podItem["img"] ?? "images/placeholder.png"),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  print('Error loading image: $exception');
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: x.width * 0.01),
                          Flexible(
                              child: Text(
                            podItem["tit"] ?? "Untitled",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: x.width * 0.04,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                          SizedBox(
                            height: x.width * 0.01,
                          ),
                          Flexible(
                              child: Text(
                            podItem["tite"] ?? "Unknown",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: x.width * 0.035,
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
            ]))),
          ],
        );

      case 1:
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: x.width * 0.1),
              Container(
                height: x.height * 0.8,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: x.width * 0.05),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: x.width * 0.1,
                    mainAxisSpacing: x.width * 0.1,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: cat.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Text(
                          cat[index]["tite"] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: x.width * 0.07,
                          ),
                        ),
                        Container(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/seeall',
                                arguments: 11,
                                // Passe la valeur de r comme argument
                              );
                              print(r);
                            },
                            child: Container(
                              height: x.width * 0.25,
                              width: x.width * 0.4,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(x.width * 0.04),
                                color:
                                    Colors.grey[200], // Add a background color
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(x.width * 0.04),
                                child: Image.asset(
                                  cat[index]["img"] ?? "images/placeholder.png",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );

      case 3:
        r = 2;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: x.height * 0.05),
              // En-tête Followed Creator
              SizedBox(
                height: x.height * 0.05,
                child: Stack(
                  children: [
                    Positioned(
                      left: x.width * 0.08,
                      child: Text(
                        "Followed Creator",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: x.width * 0.05,
                        ),
                      ),
                    ),
                    Positioned(
                      top: x.height * 0.01,
                      left: x.width * 0.03,
                      child: SizedBox(
                        width: x.width * 0.04,
                        height: x.width * 0.04,
                        child: Image.asset("images/fol.png"),
                      ),
                    ),
                    Positioned(
                      top: x.height * 0.007,
                      right: x.width * 0.12,
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: x.width * 0.035,
                          color: Color(0xFF754CEF),
                        ),
                      ),
                    ),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  9, // Passe la valeur de r comme argument
                            );
                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ],
                ),
              ),
              // Liste des créateurs
              SizedBox(
                height: x.height * 0.23,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cre.length,
                  itemBuilder: (context, index) {
                    final creItem = cre[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(x.width * 0.1),
                                image: DecorationImage(
                                  image: AssetImage(creItem["img"] ??
                                      "images/placeholder.png"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: x.width * 0.01),
                          Flexible(
                            child: Text(
                              creItem["tite"] ?? "Unknown",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.03,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // En-tête Favorite Playlist
              SizedBox(
                height: x.height * 0.05,
                child: Stack(
                  children: [
                    Positioned(
                      left: x.width * 0.08,
                      child: Text(
                        "Favorit Playlist",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: x.width * 0.05,
                        ),
                      ),
                    ),
                    Positioned(
                      top: x.height * 0.01,
                      left: x.width * 0.03,
                      child: SizedBox(
                        width: x.width * 0.04,
                        height: x.width * 0.04,
                        child: Image.asset("images/fav.png"),
                      ),
                    ),
                    Positioned(
                      top: x.height * 0.007,
                      right: x.width * 0.12,
                      child: Text(
                        "See All",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: x.width * 0.035,
                          color: Color(0xFF754CEF),
                        ),
                      ),
                    ),
                    Positioned(
                        top: x.height * -0.01,
                        right: x.width * 0.01,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/seeall',
                              arguments:
                                  10, // Passe la valeur de r comme argument
                            );
                            print(r);
                          },
                          icon: Image.asset(
                            "images/aa.png",
                            width: x.width * 0.04,
                            height: x.width * 0.04,
                          ),
                        )),
                  ],
                ),
              ),
              // Liste des playlists
              SizedBox(
                height: x.height * 0.4,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: play.length,
                  itemBuilder: (context, index) {
                    final playItem = play[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: x.width * 0.02),
                      width: x.width * 0.32,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(x.width * 0.04),
                                image: DecorationImage(
                                  image: AssetImage(playItem["img"] ??
                                      "images/placeholder.png"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: x.width * 0.03),
                          Flexible(
                            child: Text(
                              playItem["tit"] ?? "Untitled",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: x.width * 0.04,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: x.width * 0.01),
                          Flexible(
                            child: Text(
                              playItem["tite"] ?? "Unknown",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: x.width * 0.035,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

      case 4:
        return Stack(
            fit: StackFit
                .expand, // Force le Stack à prendre tout l'espace disponible
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: x.width,
                  height: x.height * 0.25,
                  decoration: BoxDecoration(color: Color(0xFF754CEF)),
                ),
              ),
              Positioned(
                top: x.height * 0.02,
                left: x.width * 0.05,
                child: Text(
                  "Account",
                  style: TextStyle(
                      fontSize: x.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Positioned(
                top: x.height * 0.1,
                left: x.width * 0.03,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.17,
                  height: MediaQuery.of(context).size.width * 0.17,
                  margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.03),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "images/person.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: x.height * 0.11,
                  left: x.width * 0.25,
                  child: Text(
                    "younes benslimane",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: x.width * 0.04),
                  )),
              Positioned(
                  top: x.height * 0.14,
                  left: x.width * 0.25,
                  child: Text(
                    "younesbens3100@gmail.com",
                    style: TextStyle(
                        color: Colors.white,
                        // fontWeight: FontWeight.bold,
                        fontSize: x.width * 0.03),
                  )),
              Positioned(
                  top: x.height * 0.11,
                  right: x.width * 0.05,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/modif', arguments: 2);
                    },
                    icon: Image.asset(
                      "images/modif.png",
                      width: x.width * 0.05,
                      height: x.width * 0.05,
                      //   color:Colors.white,
                    ),
                  )),
              Positioned(
                top: x.width * 0.4,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(x.width * 0.05),
                  ),
                  width: x.width,
                  height: x.height * 0.08,
                ),
              ),
              Positioned(
                top: x.height * 0.22,
                left: x.width * 0.03,
                child: Text(
                  "Account Settings",
                  style: TextStyle(
                    fontSize: x.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: x.height * 0.31,
                left: x.width * 0.03,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/your');
                    },
                    child: Image.asset(
                      "images/cha1.jpg",
                      width: x.width * 0.07,
                      height: x.width * 0.07,
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: x.height * 0.3,
                  left: x.width * 0.15,
                  child: Container(
                    width: x.width,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/your');
                      },
                      child: Text(
                        "Your Channel",
                        style: TextStyle(
                          fontSize: x.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
              Positioned(
                  top: x.height * 0.33,
                  left: x.width * 0.15,
                  child: Container(
                    width: x.width,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/your');
                        },
                        child: Text(
                          "You Can Visit Your Channel And See Your Information ",
                          style: TextStyle(
                              fontSize: x.width * 0.025, color: Colors.grey),
                        )),
                  )),
              Positioned(
                top: x.height * 0.38,
                left: x.width * 0.03,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/stat');
                    },
                    child: Image.asset(
                      "images/stat1.jpg",
                      width: x.width * 0.07,
                      height: x.width * 0.07,
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: x.height * 0.37,
                  left: x.width * 0.15,
                  child: Container(
                    width: x.width,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/stat');
                      },
                      child: Text(
                        "Stat",
                        style: TextStyle(
                            fontSize: x.width * 0.045,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
              Positioned(
                  top: x.height * 0.4,
                  left: x.width * 0.15,
                  child: Container(
                    width: x.width,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/stat');
                        },
                        child: Text(
                          "Find All Your Result Of The Week ",
                          style: TextStyle(
                              fontSize: x.width * 0.025, color: Colors.grey),
                        )),
                  )),
              Positioned(
                top: x.height * 0.45,
                left: x.width * 0.03,
                child: Container(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                    child: Image.asset(
                      "images/about1.png",
                      width: x.width * 0.07,
                      height: x.width * 0.07,
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: x.height * 0.44,
                  left: x.width * 0.15,
                  child: Container(
                    width: x.width,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/about');
                      },
                      child: Text(
                        "About Us",
                        style: TextStyle(
                            fontSize: x.width * 0.045,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )),
              Positioned(
                  top: x.height * 0.47,
                  left: x.width * 0.15,
                  child: Container(
                    width: x.width,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/about');
                        },
                        child: Text(
                          "You Can Send The Messang Or Follow Us In Another App",
                          style: TextStyle(
                              fontSize: x.width * 0.025, color: Colors.grey),
                        )),
                  )),
              Positioned(
                top: x.height * 0.52,
                left: x.width * 0.03,
                child: Text(
                  "App Settings",
                  style: TextStyle(
                    fontSize: x.width * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: x.height * 0.61,
                left: x.width * 0.03,
                child: Image.asset(
                  "images/load1.jpg",
                  width: x.width * 0.07,
                  height: x.width * 0.07,
                ),
              ),
              Positioned(
                top: x.height * 0.6,
                left: x.width * 0.15,
                child: Text(
                  "Load Data",
                  style: TextStyle(
                      fontSize: x.width * 0.045, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                  top: x.height * 0.63,
                  left: x.width * 0.15,
                  child: Text(
                    "Load Your Data From Your Firebase ",
                    style: TextStyle(
                        fontSize: x.width * 0.025, color: Colors.grey),
                  )),
              Positioned(
                top: x.height * 0.68,
                left: x.width * 0.03,
                child: Image.asset(
                  "images/dark1.jpg",
                  width: x.width * 0.07,
                  height: x.width * 0.07,
                ),
              ),
              Positioned(
                top: x.height * 0.67,
                left: x.width * 0.15,
                child: Text(
                  "Dark Mode",
                  style: TextStyle(
                      fontSize: x.width * 0.045, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                  top: x.height * 0.7,
                  left: x.width * 0.15,
                  child: Text(
                    "Change Your Mode Dark Or Ligth",
                    style: TextStyle(
                        fontSize: x.width * 0.025, color: Colors.grey),
                  )),
              Positioned(
                top: x.height * 0.75,
                left: x.width * 0.03,
                child: Image.asset(
                  "images/geo1.png",
                  width: x.width * 0.07,
                  height: x.width * 0.07,
                ),
              ),
              Positioned(
                top: x.height * 0.74,
                left: x.width * 0.15,
                child: Text(
                  "Geolocation",
                  style: TextStyle(
                      fontSize: x.width * 0.045, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                  top: x.height * 0.67,
                  right: x.width * 0.1,
                  child: Switch(
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[350],
                      activeTrackColor: Color(0xFF754CEF),
                      value: val1,
                      onChanged: (val1) {})),
              Positioned(
                  top: x.height * 0.77,
                  left: x.width * 0.15,
                  child: Text(
                    "Find Your Position  ",
                    style: TextStyle(
                        fontSize: x.width * 0.025, color: Colors.grey),
                  )),
              Positioned(
                  top: x.height * 0.74,
                  right: x.width * 0.1,
                  child: Switch(
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[350],
                      activeTrackColor: Color(0xFF754CEF),
                      value: val,
                      onChanged: (val) {
                        val = true;
                      })),
              Positioned(
                top: x.height * 0.82,
                left: x.width * 0.04,
                child: Image.asset(
                  "images/logout.png",
                  width: x.width * 0.06,
                  height: x.width * 0.06,
                ),
              ),
              Positioned(
                top: x.height * 0.815,
                left: x.width * 0.15,
                child: GestureDetector(
                  onTap: () async {
                    await logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/LogIn', (route) => false);
                  },
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                        fontSize: x.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
              ),
            ]);
      default:
        return const Center(child: Text(''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size x = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity, // Added to provide width constraint
          height: double.infinity, // Added to provide height constraint
          decoration: const BoxDecoration(color: Colors.white),
          child: _buildBody(context),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF754CEF),
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "images/cate.png",
              width: x.width * 0.05,
              height: x.width * 0.05,
              color: _selectedIndex == 1
                  ? const Color(0xFF754CEF)
                  : Colors.grey[800],
            ),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              // Déplace l'icône vers le bas
              width: x.width * 0.085,
              height: x.width * 0.085,
              child: Image.asset(
                "images/add.png",
                color: _selectedIndex == 2
                    ? const Color(0xFF754CEF)
                    : Colors.grey[600],
              ),
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "images/bib.png",
              width: x.width * 0.05,
              height: x.width * 0.05,
              color: _selectedIndex == 3
                  ? const Color(0xFF754CEF)
                  : Colors.grey[800],
            ),
            label: 'Librairy',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class Search extends SearchDelegate<String> {
  final List<String> suggestions = [
    'BARCA',
    'ALI AZROU',
    'younes with coran',
  ];

  final List<String> recentSearches = [
    'Recent search 1',
    'Recent search 2',
    'Recent search 3',
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    // Personnalisation du thème de la barre de recherche
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions pour la barre d'application (bouton effacer)
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
          color: Colors.black,
        ),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Icône de retour à gauche de la barre d'application
    return IconButton(
      icon: Image.asset(
        "images/retour.png",
        width: MediaQuery.of(context).size.width * 0.06,
        height: MediaQuery.of(context).size.width * 0.06,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filtrer les résultats basés sur la requête de recherche
    final results = suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Au lieu d'afficher les résultats ici, naviguer vers une nouvelle page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Navigator.of(context).canPop()) {
        // Éviter de naviguer plusieurs fois vers la page de résultats
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(
              query: query,
              results: results,
            ),
          ),
        );
      }
    });

    // Retourner un widget de chargement en attendant la navigation
    return Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Afficher les suggestions lorsque quelqu'un cherche quelque chose
    final suggestionList = query.isEmpty
        ? recentSearches
        : suggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: query.isEmpty
                ? Icon(Icons.history, color: Colors.black)
                : Icon(Icons.search, color: Colors.black),
            title: Text(
              suggestionList[index],
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              query = suggestionList[index];
              showResults(context);
            },
          );
        },
      ),
    );
  }
}

class SearchResultsPage extends StatefulWidget {
  final String query;
  final List<String> results;

  const SearchResultsPage({
    Key? key,
    required this.query,
    required this.results,
  }) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = MediaQuery.of(context).size;

    // Sample data for podcasts
    final List<Map<String, String>> podd = [
      {
        "img": "images/a.png",
        "tit": "The Joe Rogen...",
        "tite": "younes",
        "cat": "music",
        "like": "1K",
        "view": "4k"
      },
      {
        "img": "images/b.png",
        "tit": "Needs A Freinds",
        "tite": "younes",
        "cat": "music",
        "like": "900",
        "view": "3.8k"
      },
      {
        "img": "images/c.png",
        "tit": "Follow Your Dream",
        "tite": "younes",
        "cat": "music",
        "like": "700",
        "view": "3.2k"
      },
      {
        "img": "images/a.png",
        "tit": "The Joe Rogen...",
        "tite": "younes",
        "cat": "music",
        "like": "500",
        "view": "2.8k"
      },
      {
        "img": "images/b.png",
        "tit": "The Joe Rogen...",
        "tite": "younes",
        "cat": "music",
        "like": "200",
        "view": "1k"
      },
    ];

    // Sample data for channels
    final List<Map<String, String>> craa = [
      {
        "img": "images/d.png",
        "tite": "Younes cccccccccccc",
        "fol": "275K",
      },
      {
        "img": "images/e.png",
        "tite": "ALi",
        "fol": "150k",
      },
      {
        "img": "images/f.png",
        "tite": "Abderahmne",
        "fol": "100K",
      },
      {"img": "images/g.png", "tite": "Mohammed", "fol": "37K"},
      {"img": "images/h.png", "tite": "Amine", "fol": "22K"},
    ];

    // Sample data for playlists
    final List<Map<String, String>> play = [
      {"img": "images/person.jpg", "tit": "My Playlist", "tite": "50 Podcast"},
      {"img": "images/k.png", "tit": "Need A Freind", "tite": "63 Podcast"},
      {"img": "images/k.png", "tit": "Need A Freind", "tite": "70 Podcast"},
      {"img": "images/xx.png", "tit": "Music", "tite": "15 Podcast"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Image.asset(
            "images/retour.png",
            width: q.width * 0.06,
            height: q.width * 0.06,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Résultats pour "${widget.query}"',
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Podcast'),
                Tab(text: 'Channel'),
                Tab(text: 'Playlist'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: widget.results.isEmpty
            ? Center(
                child: Text(
                  'Aucun résultat trouvé pour "${widget.query}"',
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  // Podcast tab content
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: q.width * 0.02),
                    itemCount: podd.length,
                    itemBuilder: (context, index) {
                      final item = podd[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: q.width * 0.03,
                          vertical: q.width * 0.02,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12),
                        ),
                        width: q.width * 0.94,
                        height: q.width * 0.3,
                        child: Row(
                          children: [
                            SizedBox(width: q.width * 0.03),
                            Image.asset(
                              "images/play1.png",
                              width: q.width * 0.09,
                              height: q.width * 0.09,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: q.width * 0.03),
                            Container(
                              height: q.width * 0.2,
                              width: q.width * 0.2,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.04),
                                image: DecorationImage(
                                  image: AssetImage(item["img"]!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: q.width * 0.04),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["tit"]!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: q.width * 0.04,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: q.width * 0.01),
                                  Text(
                                    item["tite"]!,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: q.width * 0.035,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: q.width * 0.02),
                          ],
                        ),
                      );
                    },
                  ),

                  // Channel tab content
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: q.width * 0.02),
                    itemCount: craa.length,
                    itemBuilder: (context, index) {
                      final item = craa[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: q.width * 0.03,
                          vertical: q.width * 0.02,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12),
                        ),
                        width: q.width * 0.94,
                        height: q.width * 0.3,
                        child: Row(
                          children: [
                            SizedBox(width: q.width * 0.03),
                            Container(
                              height: q.width * 0.2,
                              width: q.width * 0.2,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.1),
                                image: DecorationImage(
                                  image: AssetImage(item["img"]!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: q.width * 0.04),
                            Expanded(
                              child: Text(
                                item["tite"]!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: q.width * 0.04,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: q.width * 0.02),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Followers",
                                  style: TextStyle(
                                    fontSize: q.width * 0.035,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item["fol"]!,
                                  style: TextStyle(
                                    fontSize: q.width * 0.035,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: q.width * 0.03),
                          ],
                        ),
                      );
                    },
                  ),

                  // Playlist tab content
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: q.width * 0.02),
                    itemCount: play.length,
                    itemBuilder: (context, index) {
                      final item = play[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: q.width * 0.03,
                          vertical: q.width * 0.02,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12),
                        ),
                        width: q.width * 0.94,
                        height: q.width * 0.3,
                        child: Row(
                          children: [
                            SizedBox(width: q.width * 0.03),
                            Container(
                              height: q.width * 0.25,
                              width: q.width * 0.25,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.04),
                                image: DecorationImage(
                                  image: AssetImage(item["img"]!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: q.width * 0.04),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item["tit"]!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: q.width * 0.04,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: q.width * 0.02),
                                  Text(
                                    item["tite"]!,
                                    style: TextStyle(
                                      fontSize: q.width * 0.035,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: q.width * 0.03),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
