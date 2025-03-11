import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                // Image Section
                Positioned(
                  left: size.width * 0.1,
                  top: size.height * 0.03,
                  child: SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.35, // Reduced height
                    child: Image.asset(
                      "images/home.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // Welcome Text Section
                Positioned(
                  top: size.height * 0.43, // Adjusted position
                  left: size.width * 0.1,
                  right: size.width * 0.1,
                  child: SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.height * 0.05, // Reduced height
                          child: Text(
                            "WELCOME",
                            style: TextStyle(
                              fontSize: size.width * 0.09,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        SizedBox(
                          height: size.height * 0.05, // Reduced height
                          child: Text(
                            "TO",
                            style: TextStyle(
                              fontSize: size.width * 0.09,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        SizedBox(
                          height: size.height * 0.059, // Reduced height
                          child: Text(
                            "Podly",
                            style: TextStyle(
                              fontSize: size.width * 0.09,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        SizedBox(
                          height: size.height * 0.025, // Reduced height
                          child: const Text(
                            "Listen Your Favorite Podcast",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.025, // Reduced height
                          child: const Text(
                            "Anywhere, Anytime",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Buttons Section
                Positioned(
                  top: size.height * 0.75, // Adjusted position
                  left: size.width * 0.1,
                  right: size.width * 0.1,
                  child: SizedBox(
                    width: size.width * 0.8,
                    height: size.height * 0.2, // Reduced height
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: size.height * 0.07, // Slightly reduced height
                          width: size.width * 0.65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(size.width * 0.01),
                            ),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/LogIn');
                            },
                            padding: EdgeInsets.all(size.width * 0.01),
                            child: const Text(
                              "Log In",
                              style: TextStyle(color: Color(0xFF754CEF)),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        Container(
                          height: size.height * 0.07, // Slightly reduced height
                          width: size.width * 0.65,
                          decoration: BoxDecoration(
                            color: const Color(0xFF754CEF),
                            borderRadius: BorderRadius.all(
                              Radius.circular(size.width * 0.05),
                            ),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/SignUp');
                            },
                            padding: EdgeInsets.all(size.width * 0.01),
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
