import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Statpage extends StatefulWidget {
  const Statpage({super.key});

  @override
  State<Statpage> createState() => _StatpageState();
}

class _StatpageState extends State<Statpage> {
  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            "images/retour.png",
            width: c.width * 0.07,
            height: c.width * 0.07,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "State",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          width: c.width,
          height: c.height,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(c.width * 0.04),
            child: Column(
              children: [
                SizedBox(
                    height: c.height * 0.05), // Espace supplémentaire en haut
                BarChartWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
    return Container(
      height: c.height * 0.7, // Augmentation de la hauteur du graphique
      width: c.width * 0.9, // Largeur presque totale
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _chartGroups(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: c.width * 0.15, // Espace réservé plus grand
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: c.width * 0.035,
                      color: Colors.grey[700],
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final days = [
                    'Sun',
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat'
                  ];
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(
                      fontSize: c.width * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                interval: 1,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              tooltipPadding: EdgeInsets.all(5),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toString(),
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _chartGroups() {
    List<double> data = [500, 700, 800, 1200, 1500, 2000, 1000];
    return List.generate(data.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index],
            color: Colors.blue, // Couleur bleue standard pour toutes les barres
            width: 20, // Largeur des barres légèrement augmentée
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
