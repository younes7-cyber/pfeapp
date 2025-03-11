import 'package:flutter/material.dart';

class SeeAllpage extends StatefulWidget {
  const SeeAllpage({super.key});

  @override
  State<SeeAllpage> createState() => _SeeAllpagepageState();
}

class _SeeAllpagepageState extends State<SeeAllpage>
    with SingleTickerProviderStateMixin {
  final List<Map<String, String>> poda = [
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
  final List<Map<String, String>> cra = [
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
  final List<Map<String, String>> play = [
    {"img": "images/person.jpg", "tit": "My Playlist", "tite": "50 Podcast"},
    {"img": "images/k.png", "tit": "Need A Freind", "tite": "63 Podcast"},
    {"img": "images/k.png", "tit": "Need A Freind", "tite": "70 Podcast"},
    {"img": "images/xx.png", "tit": "Music", "tite": "15 Podcast"},
  ];
  final List<Map<String, String>> cre = [
    {"img": "images/w.png", "tite": "Younes", "fol": "100K"},
    {"img": "images/x.png", "tite": "ALi", "fol": "100K"},
    {"img": "images/v.png", "tite": "Abderahmne", "fol": "100K"},
    {"img": "images/n.png", "tite": "Mohammed", "fol": "100K"},
    {"img": "images/l.png", "tite": "Amine", "fol": "100K"},
  ];
  List<Map<String, String>> combinedList = [];

  late int r;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  late TabController _tabController;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is int) {
      r = args;
    } else {
      r = 0; // Valeur par défaut si aucun argument n'est passé
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size q = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
            child: Container(
      width: double.infinity, // Added to provide width constraint
      height: double.infinity, // Added to provide height constraint
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(children: [
        SizedBox(
          height: q.width * 0.15,
          child: Stack(
            children: [
              Positioned(
                top: q.height * 0.01,
                left: q.width * 0.03,
                child: IconButton(
                  onPressed: () {
                    if (r == 3 ||
                        r == 4 ||
                        r == 5 ||
                        r == 6 ||
                        r == 7 ||
                        r == 8)
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/podly', (route) => false,
                          arguments: {'selectedIndex': 0});

                    if (r == 9 || r == 10)
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/podly', (route) => false,
                          arguments: {'selectedIndex': 3});
// Ouvre dans Library
                    if (r == 11)
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/podly', (route) => false,
                          arguments: {'selectedIndex': 1});
                    if (r == 12)
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/channel',
                        (route) => false,
                      );
                    if (r == 13)
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/channel',
                        (route) => false,
                      );
//vre dans Categories // Ouvre dans Categories
                  },
                  icon: Image.asset(
                    "images/retour.png",
                    width: q.width * 0.07,
                    height: q.width * 0.07,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (r == 3)
                  for (var item in pod)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(
                        children: [
                          SizedBox(
                            width: q.width * 0.01,
                          ),
                          Image.asset(
                            "images/play1.png",
                            width: q.width * 0.09,
                            height: q.width * 0.09,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: q.width * 0.03,
                          ),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: q.width * 0.06),
                              SizedBox(
                                width: q.width * 0.25,
                                child: Text(
                                  item["tit"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: q.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                height: q.width * 0.01,
                              ),
                              Text(
                                item["tite"]!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: q.width * 0.035,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: q.width * 0.05,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: q.width * 0.07,
                              ),
                              SizedBox(
                                width: q.width *
                                    0.2, // Constrain the width of the progress bar
                                child: LinearProgressIndicator(
                                  value: 0.65, // 65% de progression
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF754CEF)),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '65%',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                if (r == 4)
                  for (var item in pod)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(
                        children: [
                          SizedBox(
                            width: q.width * 0.01,
                          ),
                          Image.asset(
                            "images/play1.png",
                            width: q.width * 0.09,
                            height: q.width * 0.09,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: q.width * 0.03,
                          ),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: q.width * 0.06),
                              SizedBox(
                                width: q.width * 0.25,
                                child: Text(
                                  item["tit"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: q.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                height: q.width * 0.01,
                              ),
                              Text(
                                item["tite"]!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: q.width * 0.035,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: q.width * 0.05,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: q.width *
                                      0.2, // Constrain the width of the progress bar
                                  child: Column(
                                    children: [
                                      Text(
                                        "Category",
                                        style: TextStyle(
                                            fontSize: q.width * 0.035,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        item["cat"]!,
                                        style: TextStyle(
                                          fontSize: q.width * 0.035,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                if (r == 5)
                  for (var item in cra)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(children: [
                        SizedBox(
                          width: q.width * 0.01,
                        ),
                        Container(
                          height: q.width * 0.2,
                          width: q.width * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(q.width * 0.1),
                            image: DecorationImage(
                              image: AssetImage(item["img"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: q.width * 0.04),
                        SizedBox(height: q.width * 0.06),
                        SizedBox(
                          width: q.width * 0.45,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: q.width *
                                    0.2, // Constrain the width of the progress bar
                                child: Column(
                                  children: [
                                    Text(
                                      "Followers",
                                      style: TextStyle(
                                          fontSize: q.width * 0.035,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      item["fol"]!,
                                      style: TextStyle(
                                        fontSize: q.width * 0.035,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ]),
                    ),
                if (r == 6)
                  for (var item in pod)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(
                        children: [
                          SizedBox(
                            width: q.width * 0.01,
                          ),
                          Image.asset(
                            "images/play1.png",
                            width: q.width * 0.09,
                            height: q.width * 0.09,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: q.width * 0.03,
                          ),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: q.width * 0.06),
                              SizedBox(
                                width: q.width * 0.25,
                                child: Text(
                                  item["tit"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: q.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                height: q.width * 0.01,
                              ),
                              Text(
                                item["tite"]!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: q.width * 0.035,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: q.width * 0.09,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: q.width *
                                      0.2, // Constrain the width of the progress bar
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            child:
                                                Image.asset("images/like.png"),
                                            width: q.width * 0.05,
                                            height: q.width * 0.05,
                                          ),
                                          SizedBox(
                                            width: q.width * 0.01,
                                          ),
                                          Text(
                                            item["like"]!,
                                            style: TextStyle(
                                                fontSize: q.width * 0.035,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: q.width * 0.02,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            child:
                                                Image.asset("images/view.png"),
                                            width: q.width * 0.05,
                                            height: q.width * 0.05,
                                          ),
                                          SizedBox(
                                            width: q.width * 0.01,
                                          ),
                                          Text(
                                            item["view"]!,
                                            style: TextStyle(
                                                fontSize: q.width * 0.035,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
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
                if (r == 7)
                  for (var item in pod)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(
                        children: [
                          SizedBox(
                            width: q.width * 0.01,
                          ),
                          Image.asset(
                            "images/play1.png",
                            width: q.width * 0.09,
                            height: q.width * 0.09,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: q.width * 0.03,
                          ),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: q.width * 0.06),
                              SizedBox(
                                width: q.width * 0.25,
                                child: Text(
                                  item["tit"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: q.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                height: q.width * 0.01,
                              ),
                              Text(
                                item["tite"]!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: q.width * 0.035,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: q.width * 0.09,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: q.width *
                                      0.2, // Constrain the width of the progress bar
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            child:
                                                Image.asset("images/like.png"),
                                            width: q.width * 0.05,
                                            height: q.width * 0.05,
                                          ),
                                          SizedBox(
                                            width: q.width * 0.01,
                                          ),
                                          Text(
                                            item["like"]!,
                                            style: TextStyle(
                                                fontSize: q.width * 0.035,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
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
                if (r == 8)
                  for (var item in pod)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(
                        children: [
                          SizedBox(
                            width: q.width * 0.01,
                          ),
                          Image.asset(
                            "images/play1.png",
                            width: q.width * 0.09,
                            height: q.width * 0.09,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: q.width * 0.03,
                          ),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: q.width * 0.06),
                              SizedBox(
                                width: q.width * 0.25,
                                child: Text(
                                  item["tit"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: q.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                height: q.width * 0.01,
                              ),
                              Text(
                                item["tite"]!,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: q.width * 0.035,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: q.width * 0.09,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: q.width *
                                      0.2, // Constrain the width of the progress bar
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            child:
                                                Image.asset("images/view.png"),
                                            width: q.width * 0.05,
                                            height: q.width * 0.05,
                                          ),
                                          SizedBox(
                                            width: q.width * 0.01,
                                          ),
                                          Text(
                                            item["view"]!,
                                            style: TextStyle(
                                                fontSize: q.width * 0.035,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
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
                if (r == 9)
                  for (var item in cre)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(children: [
                        SizedBox(
                          width: q.width * 0.01,
                        ),
                        Container(
                          height: q.width * 0.2,
                          width: q.width * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(q.width * 0.1),
                            image: DecorationImage(
                              image: AssetImage(item["img"]!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: q.width * 0.04),
                        SizedBox(height: q.width * 0.06),
                        SizedBox(
                          width: q.width * 0.45,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: q.width *
                                    0.2, // Constrain the width of the progress bar
                                child: Column(
                                  children: [
                                    Text(
                                      "Followers",
                                      style: TextStyle(
                                          fontSize: q.width * 0.035,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      item["fol"]!,
                                      style: TextStyle(
                                        fontSize: q.width * 0.035,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ]),
                    ),
                if (r == 10)
                  for (var item in play)
                    Container(
                      margin: EdgeInsets.only(bottom: q.width * 0.02),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(q.width * 0.05),
                          border: Border.all(color: Colors.black12)),
                      width: q.width * 0.95,
                      height: q.width * 0.3,
                      child: Row(
                        children: [
                          SizedBox(
                            width: q.width * 0.01,
                          ),
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
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: q.width * 0.02),
                              SizedBox(
                                width: q.width * 0.3,
                                child: Text(
                                  item["tit"]!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: q.width * 0.04,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: q.width * 0.04,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: q.width *
                                      0.2, // Constrain the width of the progress bar
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: q.width * 0.02,
                                      ),
                                      Text(
                                        item["tite"]!,
                                        style: TextStyle(
                                          fontSize: q.width * 0.035,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                if (r == 11) ...[
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    tabs: const [
                      Tab(text: 'Podcast'),
                      Tab(text: 'Channel'),
                      Tab(text: 'Playlist'),
                    ],
                  ),
                  // Remplacez Expanded par un SizedBox avec une hauteur fixe
                  SizedBox(
                    height: MediaQuery.of(context)
                        .size
                        .height, // Ajustez la hauteur selon vos besoins
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Contenu pour l'onglet Podcast
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: podd.length,
                          itemBuilder: (context, index) {
                            final item = podd[index];
                            return Container(
                              margin: EdgeInsets.all(q.width * 0.02),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12),
                              ),
                              width: q.width * 0.95,
                              height: q.width * 0.3,
                              child: Row(
                                children: [
                                  SizedBox(width: q.width * 0.01),
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
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: q.width * 0.06),
                                      SizedBox(
                                        width: q.width * 0.4,
                                        child: Text(
                                          item["tit"]!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: q.width * 0.04,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: q.width * 0.01),
                                      Text(
                                        item["tite"]!,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: q.width * 0.035,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        // Contenu pour l'onglet Channel
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: craa.length,
                          itemBuilder: (context, index) {
                            final item = craa[index];
                            return Container(
                              margin: EdgeInsets.all(q.width * 0.02),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(q.width * 0.05),
                                border: Border.all(color: Colors.black12),
                              ),
                              width: q.width * 0.95,
                              height: q.width * 0.3,
                              child: Row(
                                children: [
                                  SizedBox(width: q.width * 0.01),
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
                                  SizedBox(height: q.width * 0.06),
                                  SizedBox(
                                    width: q.width * 0.45,
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: q.width * 0.2,
                                        child: Column(
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
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: play.length,
                          itemBuilder: (context, index) {
                            final item = play[index];
                            return Container(
                              margin: EdgeInsets.all(q.width * 0.02),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(q.width * 0.05),
                                  border: Border.all(color: Colors.black12)),
                              width: q.width * 0.95,
                              height: q.width * 0.3,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: q.width * 0.01,
                                  ),
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
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: q.width * 0.02),
                                      SizedBox(
                                        width: q.width * 0.3,
                                        child: Text(
                                          item["tit"]!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: q.width * 0.04,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: q.width * 0.04,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: q.width *
                                              0.2, // Constrain the width of the progress bar
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: q.width * 0.02,
                                              ),
                                              Text(
                                                item["tite"]!,
                                                style: TextStyle(
                                                  fontSize: q.width * 0.035,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                if (r == 12) ...[
                  SizedBox(
                    height: q.height,
                    child: ListView.builder(
                      itemCount: poda.length,
                      itemBuilder: (context, index) {
                        final item = poda[index];
                        return Container(
                          margin: EdgeInsets.all(q.width * 0.02),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(q.width * 0.05),
                            border: Border.all(color: Colors.black12),
                          ),
                          width: q.width * 0.95,
                          height: q.width * 0.3,
                          child: Row(
                            children: [
                              SizedBox(width: q.width * 0.01),
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
                              SizedBox(width: q.width * 0.02),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: q.width * 0.0),
                                  SizedBox(
                                    width: q.width * 0.35,
                                    child: Text(
                                      item["tit"]!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: q.width * 0.04,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: q.width * 0.01),
                                ],
                              ),
                              SizedBox(
                                width: q.width * 0.05,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: q.width *
                                          0.2, // Constrain the width of the progress bar
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                child: Image.asset(
                                                    "images/like.png"),
                                                width: q.width * 0.05,
                                                height: q.width * 0.05,
                                              ),
                                              SizedBox(
                                                width: q.width * 0.01,
                                              ),
                                              Text(
                                                item["like"]!,
                                                style: TextStyle(
                                                    fontSize: q.width * 0.035,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: q.width * 0.02,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                child: Image.asset(
                                                    "images/view.png"),
                                                width: q.width * 0.05,
                                                height: q.width * 0.05,
                                              ),
                                              SizedBox(
                                                width: q.width * 0.01,
                                              ),
                                              Text(
                                                item["view"]!,
                                                style: TextStyle(
                                                    fontSize: q.width * 0.035,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: q.width * 0.02,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                child: Image.asset(
                                                    "images/comment.png"),
                                                width: q.width * 0.05,
                                                height: q.width * 0.05,
                                              ),
                                              SizedBox(
                                                width: q.width * 0.01,
                                              ),
                                              Text(
                                                item["com"]!,
                                                style: TextStyle(
                                                    fontSize: q.width * 0.035,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (r == 13) ...[
                  SizedBox(
                    height: q.height,
                    child: // Playlist tab
                        ListView.builder(
                      itemCount: play.length,
                      itemBuilder: (context, index) {
                        final item = play[index];
                        return Container(
                          margin: EdgeInsets.all(q.width * 0.02),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(q.width * 0.05),
                            border: Border.all(color: Colors.black12),
                          ),
                          width: q.width * 0.95,
                          height: q.width * 0.3,
                          child: Row(
                            children: [
                              SizedBox(
                                width: q.width * 0.01,
                              ),
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
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: q.width * 0.02),
                                  SizedBox(
                                    width: q.width * 0.3,
                                    child: Text(
                                      item["tit"]!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: q.width * 0.04,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: q.width * 0.04,
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                        width: q.width *
                                            0.2, // Constrain the width of the progress bar
                                        child: Column(children: [
                                          SizedBox(
                                            height: q.width * 0.02,
                                          ),
                                          Text(
                                            item["tite"]!,
                                            style: TextStyle(
                                              fontSize: q.width * 0.035,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ]))
                                  ])
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ]),
    )));
  }
}
