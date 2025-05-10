import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class Annimationwidjet extends StatefulWidget {
  // ignore: use_super_parameters
  const Annimationwidjet({Key? key}) : super(key: key);

  @override
  State<Annimationwidjet> createState() => _AnnimationwidjetState();
}

class _AnnimationwidjetState extends State<Annimationwidjet>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final int barCount = 6; // Réduit à 6 barres

  @override
  void initState() {
    super.initState();

    // Créer 6 contrôleurs pour des animations indépendantes
    _controllers = List.generate(
      barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + math.Random().nextInt(700)),
        vsync: this,
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return Container(
        color: themeProvider.isDarkMode
            ? Colors.black.withOpacity(0.01)
            : Colors.white.withOpacity(0.01),
        child: Center(
          child: SizedBox(
            width:
                screenWidth * 0.4, // Réduit la largeur pour centrer davantage
            height: MediaQuery.of(context).size.height * 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centre les barres
              children: List.generate(barCount, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) {
                      return Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return Container(
                            width: screenWidth *
                                0.03, // Largeur fixe pour chaque barre
                            height: _controllers[index].value * 80,
                            decoration: BoxDecoration(
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black, // Toutes les barres en blanc
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
