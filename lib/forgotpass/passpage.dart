import 'package:flutter/material.dart';

class Passpage extends StatefulWidget {
  const Passpage({super.key});

  @override
  State<Passpage> createState() => _PasspageState();
}

class _PasspageState extends State<Passpage> {
  @override
  Widget build(BuildContext context) {
    final Size si = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                  top: si.height * 0.05,
                  left: si.width * 0.1,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/LogIn', (route) => false);
                    },
                    icon: Image.asset(
                      "images/retour.png",
                      width: si.width * 0.09,
                      height: si.width * 0.09,
                    ),
                  )),
              Positioned(
                top: si.height * 0.26,
                left: si.width * 0.1,
                child: Text(
                  "Forgot Your Password",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: si.width * 0.075),
                ),
              ),
              Positioned(
                top: si.height * 0.32,
                left: si.width * 0.1,
                child: const Text(
                  "Don't Worry! Enter Your Email,And We'll Help You",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Positioned(
                top: si.height * 0.34,
                left: si.width * 0.1,
                child: const Text(
                  " Reset Your Password",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Positioned(
                top: si.height * 0.4,
                left: si.width * 0.1,
                child: const Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: si.height * 0.425,
                left: si.width * 0.07,
                right: si.width * 0.07,
                child: SizedBox(
                  width: si.width - 60,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter Email",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(si.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.asset(
                          "images/gmail.png", // Remplacez par le chemin de votre icône
                          width: si.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: si.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(si.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(si.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(si.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: si.height * 0.53,
                left: si.width * 0.18,
                child: Container(
                  height: si.height * 0.075,
                  width: si.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(si.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Implement login logic
                    },
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white, fontSize: si.width * 0.042),
                    ),
                  ),
                ),
              ),
            ],
          )),
    ));
  }
}
