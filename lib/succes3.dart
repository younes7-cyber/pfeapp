import 'package:flutter/material.dart';
import 'package:pfeapp/annimation.dart';

import 'package:pfeapp/constants.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class Succes3page extends StatefulWidget {
  const Succes3page({super.key});

  @override
  State<Succes3page> createState() => _Succes3pageState();
}

class _Succes3pageState extends State<Succes3page> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() => isLoading = true);
      }
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => isLoading = false);
      }
    });
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    final Size c = MediaQuery.of(context).size;
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
                    child: Stack(children: [
                      // Show verified UI
                      Positioned(
                        top: c.height * 0.05,
                        left: c.width * 0.15,
                        child: SizedBox(
                          width: c.width * 0.7,
                          height: c.width * 0.9,
                          child: Image.network(
                              themeProvider.isDarkMode ? s101 : s100,
                              fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: c.height * 0.53,
                        left: c.width * 0.15,
                        child: SizedBox(
                          width: c.width,
                          child: Text(
                            "Succesful Create Playlist",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: c.width * 0.06,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: c.height * 0.67,
                        left: c.width * 0.18,
                        child: Container(
                          height: c.height * 0.075,
                          width: c.width * 0.65,
                          decoration: BoxDecoration(
                            color: const Color(0xFF754CEF),
                            borderRadius: BorderRadius.circular(c.width * 0.05),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              // Navigate to complete profile page
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/podly', (route) => false,
                                  arguments: {'selectedIndex': 4});
                            },
                            child: Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: c.width * 0.042,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                })),
    );
  }
}
