import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _currentFilter = 'all';
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      _currentFilter = 'all';
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isLoading = false);
    });
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final Size a = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: isLoading
              ? const Annimationwidjet()
              : Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.black
                          : Colors.white,
                    ),
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
                                  child: Image.network(
                                    themeProvider.isDarkMode ? s97 : s18,
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
                                top: a.height * 0.03,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    "Notifications & Reports",
                                    style: TextStyle(
                                      fontSize: a.width * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: a.height * 0.02,
                                right: a.width * 0.05,
                                child: PopupMenuButton<String>(
                                  icon: Image.network(
                                    themeProvider.isDarkMode ? s106 : s49,
                                    width: a.width * 0.05,
                                    height: a.width * 0.05,
                                  ),
                                  color: themeProvider.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  onSelected: (String value) {
                                    setState(() {
                                      _currentFilter = value;
                                    });
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'all',
                                      child: Text('All'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'read',
                                      child: Text('Read'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'unread',
                                      child: Text('Unread'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Combined notifications and reports
                        Expanded(
                          child: StreamBuilder<List<dynamic>>(
                            stream: _getCombinedStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(child: Annimationwidjet());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error loading data: ${snapshot.error}',
                                    style: TextStyle(
                                      fontSize: a.width * 0.04,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              }

                              final combinedItems = snapshot.data ?? [];

                              // Apply filter
                              final filteredItems = combinedItems.where((item) {
                                if (_currentFilter == 'read') {
                                  return item['isviewed'] == true;
                                } else if (_currentFilter == 'unread') {
                                  return item['isviewed'] == false;
                                }
                                return true; // 'all' filter
                              }).toList();

                              if (filteredItems.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No $_currentFilter items',
                                    style: TextStyle(
                                      fontSize: a.width * 0.04,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: a.width * 0.02),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];

                                  if (item['type'] == 'notification') {
                                    return NotificationItem(
                                      notification: item,
                                      onTap: () =>
                                          _handleNotificationTap(item['id']),
                                    );
                                  } else {
                                    return ReportItem(
                                      report: item,
                                      onTap: () => _handleReportTap(
                                          context, item['id'], item['message']),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                })),
    );
  }

  Stream<List<dynamic>> _getCombinedStream() {
    // Get notifications
    final notificationsStream = FirebaseFirestore.instance
        .collection('nofi')
        .where('user2', isEqualTo: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      final notifications = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Get user details
        final userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('userId', isEqualTo: data['user1'])
            .get();

        // Vérifiez si la requête a retourné des documents
        if (userQuerySnapshot.docs.isNotEmpty) {
          // Prenez le premier document correspondant
          final userData = userQuerySnapshot.docs.first.data();
          notifications.add({
            'id': doc.id,
            'text': data['text'],
            'date': data['date'],
            'isviewed': data['isviewed'] ?? false,
            'photoUrl': userData['photoUrl'] ?? '',
            'userName':
                '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}',
            'userId': data['user1'],
            'type': 'notification',
            'timestamp':
                data['date'] is Timestamp ? data['date'] : Timestamp.now(),
          });
        }
      }
      return notifications;
    });
    // Get reports
    final reportsStream = FirebaseFirestore.instance
        .collection('reports')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'message': data['message'] ?? '',
          'reportedAt': data['reportedAt'],
          'isviewed': data['isviewed'] ?? false,
          'type': 'report',
          'timestamp': data['reportedAt'] is Timestamp
              ? data['reportedAt']
              : Timestamp.now(),
        };
      }).toList();
    });

    // Combine and sort both streams using the correct Rx.combineLatest2 method
    return Rx.combineLatest2(
      notificationsStream,
      reportsStream,
      (List<Map<String, dynamic>> notifications,
          List<Map<String, dynamic>> reports) {
        final combined = [...notifications, ...reports];
        // Sort by timestamp in descending order
        combined.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        return combined;
      },
    );
  }

  void _handleNotificationTap(String notificationId) async {
    // Update notification as viewed
    await FirebaseFirestore.instance
        .collection('nofi')
        .doc(notificationId)
        .update({'isviewed': true});
  }

  void _handleReportTap(
      BuildContext context, String reportId, String message) async {
    // Update report as viewed
    await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .update({'isviewed': true});

    // Show full report message in dialog
    showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) =>
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
              return AlertDialog(
                backgroundColor:
                    themeProvider.isDarkMode ? Colors.black : Colors.white,
                title: const Text('Report Details'),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            }));
  }
}

class NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size a = MediaQuery.of(context).size;
    final bool isRead = notification['isviewed'] ?? false;
    final String date = notification['date'] is Timestamp
        ? _formatTimestamp(notification['date'])
        : notification['date'].toString();

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(a.width * 0.02),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(a.width * 0.05),
            border: Border.all(color: Colors.black12),
            color: isRead
                ? themeProvider.isDarkMode
                    ? Colors.black
                    : Colors.white
                : themeProvider.isDarkMode
                    ? Colors.grey
                    : const Color(0xFFD9D9D9),
          ),
          width: a.width * 0.95,
          height: a.width * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Purple dot indicator for unread
                  if (!isRead)
                    Container(
                      width: a.width * 0.02,
                      height: a.width * 0.02,
                      margin: EdgeInsets.only(
                        left: a.width * 0.03,
                        right: a.width * 0.03,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isRead) SizedBox(width: a.width * 0.08),

                  // User profile image
                  Container(
                    width: a.width * 0.08,
                    height: a.width * 0.08,
                    margin: EdgeInsets.only(right: a.width * 0.03),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                        child: notification['photoUrl'] != null &&
                                notification['photoUrl'].isNotEmpty
                            ? Image.network(notification['photoUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person))
                            : const Icon(Icons.person)),
                  ),

                  // Notification content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: a.width * 0.5,
                        child: Text(
                          notification['userName'] ?? 'User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: a.width * 0.01),
                      SizedBox(
                        width: a.width * 0.5,
                        child: Text(
                          notification['text'] ?? '',
                          style: TextStyle(
                            fontSize: a.width * 0.035,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Date
              Padding(
                padding: EdgeInsets.only(right: a.width * 0.03),
                child: Text(
                  date,
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: a.width * 0.03,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ReportItem extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const ReportItem({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size a = MediaQuery.of(context).size;
    final bool isRead = report['isviewed'] ?? false;
    final String date = report['reportedAt'] is Timestamp
        ? _formatTimestamp(report['reportedAt'])
        : report['reportedAt'].toString();

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(a.width * 0.02),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(a.width * 0.05),
            border: Border.all(color: Colors.black12),
            color: isRead
                ? themeProvider.isDarkMode
                    ? Colors.black
                    : Colors.white
                : themeProvider.isDarkMode
                    ? Colors.grey
                    : const Color(0xFFD9D9D9),
          ),
          width: a.width * 0.95,
          height: a.width * 0.3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Purple dot indicator for unread
                  if (!isRead)
                    Container(
                      width: a.width * 0.02,
                      height: a.width * 0.02,
                      margin: EdgeInsets.only(
                        left: a.width * 0.03,
                        right: a.width * 0.03,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (isRead) SizedBox(width: a.width * 0.08),

                  // Report icon
                  Container(
                    width: a.width * 0.08,
                    height: a.width * 0.08,
                    margin: EdgeInsets.only(right: a.width * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.report_problem_outlined,
                      color: Colors.red,
                      size: a.width * 0.05,
                    ),
                  ),

                  // Report content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: a.width * 0.5,
                        child: Text(
                          'Report Notice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: a.width * 0.01),
                      SizedBox(
                        width: a.width * 0.5,
                        child: Text(
                          report['message'] ?? '',
                          style: TextStyle(
                            fontSize: a.width * 0.035,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Date
              Padding(
                padding: EdgeInsets.only(right: a.width * 0.03),
                child: Text(
                  date,
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: a.width * 0.03,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
}
