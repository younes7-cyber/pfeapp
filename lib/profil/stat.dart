import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'dart:async';

import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class Statpage extends StatefulWidget {
  const Statpage({super.key});

  @override
  State<Statpage> createState() => _StatpageState();
}

class _StatpageState extends State<Statpage> {
  List<double> weeklyViews = [
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ]; // Data for each day of the week
  bool isLoading = true;
  String currentUserID = '';

  // Stream subscription to manage the Firestore listener
  StreamSubscription<QuerySnapshot>? _subscription;

  // Current week offset (0 = current week, -1 = previous week, 1 = next week)
  int weekOffset = 0;

  // Reference date to calculate the current week
  late DateTime referenceDate;

  @override
  void initState() {
    super.initState();
    referenceDate = DateTime.now();

    // Delay initialization to ensure the widget is properly mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getCurrentUserAndFetchStats();
      }
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _subscription?.cancel();
    _subscription = null; // Set to null to be extra safe
    super.dispose();
  }

  Future<void> _getCurrentUserAndFetchStats() async {
    if (!mounted) return;

    try {
      if (mounted) {
        setState(() => isLoading = true);
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      currentUserID = user.uid;
      await _fetchWeeklyStats();

      // Set loading to false after all data is fetched
      if (mounted) {
        // Add a small delay to allow animation to complete
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Navigate to previous week
  void _previousWeek() {
    if (!mounted) return;

    if (mounted) {
      setState(() {
        weekOffset -= 1;
        isLoading = true;
      });
    }
    // Cancel existing subscription before creating a new one
    _subscription?.cancel();
    _fetchWeeklyStats();
  }

  // Navigate to next week (limited to current week)
  void _nextWeek() {
    if (!mounted) return;

    if (weekOffset < 0) {
      if (mounted) {
        setState(() {
          weekOffset += 1;
          isLoading = true;
        });
      }
      // Cancel existing subscription before creating a new one
      _subscription?.cancel();
      _fetchWeeklyStats();
    }
  }

  // Reset to current week
  void _currentWeek() {
    if (!mounted) return;

    if (mounted) {
      setState(() {
        weekOffset = 0;
        isLoading = true;
      });
    }
    // Cancel existing subscription before creating a new one
    _subscription?.cancel();
    _fetchWeeklyStats();
  }

  // Get the start date of the selected week
  DateTime _getStartOfWeek() {
    // Get current date
    final DateTime now = referenceDate;

    // Find the date of the most recent Sunday
    final DateTime startOfCurrentWeek =
        now.subtract(Duration(days: now.weekday % 7));

    // Apply the week offset
    return startOfCurrentWeek.add(Duration(days: 7 * weekOffset));
  }

  Future<void> _fetchWeeklyStats() async {
    if (!mounted) return;

    try {
      if (currentUserID.isEmpty) {
        if (mounted) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
        return;
      }

      // Cancel previous subscription if any
      _subscription?.cancel();

      // Calculate start and end of the selected week
      final DateTime startOfWeek = _getStartOfWeek();
      final DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

      // Create a subscription to views for the current user
      _subscription = FirebaseFirestore.instance
          .collection('vues')
          .where('userId', isEqualTo: currentUserID)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        // Only process data if the widget is still mounted
        if (mounted) {
          _processViewsData(snapshot, startOfWeek, endOfWeek);
        }
      });
    } catch (e) {
      if (mounted) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  // Process the snapshot data from Firestore
  void _processViewsData(
      QuerySnapshot snapshot, DateTime startOfWeek, DateTime endOfWeek) {
    // Check if the widget is still mounted before doing any processing
    if (!mounted) return;

    // Reset weekly views
    final List<double> newWeeklyViews = [0, 0, 0, 0, 0, 0, 0];

    // Create a map to count views for each day
    final Map<int, int> dayViewCounts = {
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0
    };

    // For each document, check if it falls within the selected week
    for (final doc in snapshot.docs) {
      try {
        // Get the timestamp from Firestore
        final Timestamp timestamp = doc['timevue'] as Timestamp;
        final DateTime viewDate = timestamp.toDate();

        // Check if the date is within the selected week
        if (viewDate
                .isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            viewDate.isBefore(endOfWeek)) {
          // Calculate the day index (0-6, where 0 is Sunday)
          final int dayIndex = viewDate.weekday % 7;
          // Increment the count for this day
          dayViewCounts[dayIndex] = (dayViewCounts[dayIndex] ?? 0) + 1;
        }
        // ignore: empty_catches
      } catch (e) {}
    }

    // Update our weekly views data
    for (int i = 0; i < 7; i++) {
      newWeeklyViews[i] = dayViewCounts[i]!.toDouble();
    }

    // Check if the widget is still mounted before calling setState
    if (!mounted) return;

    // Update the UI with the new data
    if (mounted) {
      setState(() {
        weeklyViews = newWeeklyViews;
        isLoading = false;
      });
    }
  }

  // Get the title for the current week view
  String _getWeekTitle() {
    final DateTime startOfWeek = _getStartOfWeek();
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    return "Week: ${DateFormat('dd/MM/yyyy').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}";
  }

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return isLoading
        ? const Annimationwidjet()
        : Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: Image.network(
                    themeProvider.isDarkMode ? s97 : s18,
                    width: c.width * 0.07,
                    height: c.width * 0.07,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Text(
                  "Statistics",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                backgroundColor:
                    themeProvider.isDarkMode ? Colors.black : Colors.white,
                elevation: 0,
              ),
              body: SafeArea(
                child: Container(
                  width: c.width,
                  height: c.height,
                  color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(c.width * 0.04),
                    child: Column(
                      children: [
                        SizedBox(height: c.height * 0.03),
                        Text(
                          "Weekly Podcast Views",
                          style: TextStyle(
                            fontSize: c.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: c.height * 0.02),
                        // Week navigation controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: _previousWeek,
                              tooltip: 'Previous Week',
                            ),
                            TextButton(
                              onPressed: _currentWeek,
                              child: Text(
                                weekOffset == 0
                                    ? "Current Week"
                                    : "Return to Current Week",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                              ),
                              onPressed: weekOffset < 0 ? _nextWeek : null,
                              tooltip: weekOffset < 0
                                  ? 'Next Week'
                                  : 'Cannot view future weeks',
                              color: weekOffset < 0 ? Colors.blue : Colors.grey,
                            ),
                          ],
                        ),
                        SizedBox(height: c.height * 0.02),
                        isLoading
                            ? const Center(
                                child: Column(
                                  children: [
                                    Annimationwidjet(),
                                    SizedBox(height: 16),
                                    Text("Loading statistics..."),
                                  ],
                                ),
                              )
                            : BarChartWidget(
                                weeklyViews: weeklyViews,
                                startOfWeek: _getStartOfWeek(),
                              ),
                        SizedBox(height: c.height * 0.02),
                        Text(
                          _getWeekTitle(),
                          style: TextStyle(
                            fontSize: c.width * 0.04,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (weekOffset < 0)
                          Text(
                            "(Historical Data)",
                            style: TextStyle(
                              fontSize: c.width * 0.035,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
  }
}

class BarChartWidget extends StatelessWidget {
  final List<double> weeklyViews;
  final DateTime startOfWeek;

  const BarChartWidget({
    super.key,
    required this.weeklyViews,
    required this.startOfWeek,
  });

  String formatNumber(double number) {
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }
    final formatter = NumberFormat('#,##0.00', 'fr');
    // Pour les nombres importants, appliquer une logique de compactage manuel
    if (number >= 1000000000000000) {
      return '${formatter.format(number / 1000000000000000).replaceAll('\u202f', '')}P';
    } else if (number >= 1000000000000) {
      return '${formatter.format(number / 1000000000000).replaceAll('\u202f', '')}T';
    } else if (number >= 1000000000) {
      return '${formatter.format(number / 1000000000).replaceAll('\u202f', '')}G';
    } else if (number >= 1000000) {
      return '${formatter.format(number / 1000000).replaceAll('\u202f', '')}M';
    } else if (number >= 1000) {
      return '${formatter.format(number / 1000).replaceAll('\u202f', '')}k';
    } else if (number <= 999) {
      final formatter1 = NumberFormat('#0', 'fr');
      return formatter1.format(number);
    }

    return formatter.format(number).replaceAll('\u202f', '');
  }

  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;

    // Create a list of date strings for the x-axis
    final List<String> dateLabels = List.generate(7, (index) {
      final DateTime date = startOfWeek.add(Duration(days: index));
      // Format as day name + short date
      return '${DateFormat('EEE').format(date)}\n${DateFormat('dd/MM').format(date)}';
    });

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return SizedBox(
        height: c.height * 0.5,
        width: c.width * 0.9,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxYValue(),
            barGroups: _chartGroups(),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: c.width * 0.15,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        formatNumber(value),
                        style: TextStyle(
                          fontSize: c.width * 0.035,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dateLabels[value.toInt()],
                        style: TextStyle(
                          fontSize: c.width * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  interval: 1,
                  reservedSize: 40,
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final DateTime date =
                      startOfWeek.add(Duration(days: groupIndex));
                  return BarTooltipItem(
                    '${DateFormat('EEE, MMM dd').format(date)}\n${rod.toY.toInt()} views',
                    TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        ),
      );
    });
  }

  double _getMaxYValue() {
    double max = _getMaxValue();
    // Add some padding to the top of the chart (at least 1 to avoid empty charts)
    return max > 0 ? max + (max * 0.2) : 1;
  }

  List<BarChartGroupData> _chartGroups() {
    return List.generate(weeklyViews.length, (index) {
      // Calculate color based on number of views (higher = darker blue)
      final double maxValue = _getMaxValue();
      final double colorIntensity =
          maxValue > 0 ? 0.5 + (weeklyViews[index] / maxValue * 0.5) : 0.5;

      final Color barColor = Color.fromRGBO(
        33,
        150,
        243,
        colorIntensity,
      );

      // Today's date bar should be highlighted
      final bool isToday = _isToday(index);
      final Color finalColor = isToday ? Colors.blue : barColor;
      final double borderWidth = isToday ? 2.0 : 2.0;
      final Color borderColor = isToday ? Colors.blue : Colors.blue;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyViews[index],
            color: finalColor,
            width: 18,
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: borderColor,
              width: borderWidth,
            ),
          ),
        ],
      );
    });
  }

  double _getMaxValue() {
    double max = 0;
    for (final value in weeklyViews) {
      if (value > max) max = value;
    }
    return max;
  }

  bool _isToday(int dayIndex) {
    final DateTime today = DateTime.now();
    final DateTime dateForThisBar = startOfWeek.add(Duration(days: dayIndex));

    return today.year == dateForThisBar.year &&
        today.month == dateForThisBar.month &&
        today.day == dateForThisBar.day;
  }
}
