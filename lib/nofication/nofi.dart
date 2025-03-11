import 'package:flutter/material.dart';

class Nofipage extends StatefulWidget {
  const Nofipage({super.key});

  @override
  State<Nofipage> createState() => _NofipageState();
}

class _NofipageState extends State<Nofipage> {
  late List<Map<String, String>> notifications;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Initialize notifications with isRead property
    notifications = [
      {
        "title": "YOUNES Benslimane See YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "Younes subscribe You",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
      {
        "title": "YOUNES Liked YOUR PODCAST",
        "date": "12/02/2025",
        "isRead": "false"
      },
    ];
  }

  List<Map<String, String>> get filteredNotifications {
    switch (_currentFilter) {
      case 'read':
        return notifications
            .where((notif) => notif["isRead"] == "true")
            .toList();
      case 'unread':
        return notifications
            .where((notif) => notif["isRead"] == "false")
            .toList();
      default:
        return notifications;
    }
  }

  void _handleNotificationTap(int index) {
    setState(() {
      notifications[index]["isRead"] = "true";
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size a = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // Header section
              SizedBox(
                height: a.height * 0.1,
                child: Stack(
                  children: [
                    Positioned(
                      top: a.height * 0.03,
                      left: a.width * 0.05,
                      child: GestureDetector(
                        child: Image.asset(
                          "images/retour.png",
                          width: a.width * 0.08,
                          height: a.width * 0.08,
                        ),
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/podly', (route) => false);
                        },
                      ),
                    ),
                    Positioned(
                      top: a.height * 0.02,
                      right: a.width * 0.05,
                      child: PopupMenuButton<String>(
                        icon: Image.asset(
                          "images/menu.png",
                          width: a.width * 0.05,
                          height: a.width * 0.05,
                        ),
                        color: Colors.white,
                        onSelected: (String value) {
                          setState(() {
                            _currentFilter = value;
                          });
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'all',
                            child: Text('all'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'read',
                            child: Text('read'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'unread',
                            child: Text('unread'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: filteredNotifications.isEmpty
                    ? Center(
                        child: Text(
                          'No ${_currentFilter} notifications',
                          style: TextStyle(
                            fontSize: a.width * 0.04,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: a.width * 0.02),
                          child: Column(
                            children: filteredNotifications
                                .asMap()
                                .entries
                                .map((entry) {
                              // Find the original index in the unfiltered list
                              final int originalIndex =
                                  notifications.indexOf(entry.value);
                              final notif = entry.value;
                              return GestureDetector(
                                onTap: () =>
                                    _handleNotificationTap(originalIndex),
                                child: NotificationCard(
                                  title: notif["title"]!,
                                  date: notif["date"]!,
                                  isRead: notif["isRead"] == "true",
                                ),
                              );
                            }).toList(),
                          ),
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

class NotificationCard extends StatelessWidget {
  final String title;
  final String date;
  final bool isRead;

  const NotificationCard({
    super.key,
    required this.title,
    required this.date,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
          border: Border.all(color: Colors.black12),
          color: isRead ? Colors.white : const Color(0xFFD9D9D9),
        ),
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.width * 0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.02,
                  height: MediaQuery.of(context).size.width * 0.02,
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.03,
                      right: MediaQuery.of(context).size.width * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.08,
                  height: MediaQuery.of(context).size.width * 0.08,
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.03),
              child: Text(
                date,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ));
  }
}
