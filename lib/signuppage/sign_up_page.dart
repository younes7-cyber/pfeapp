import 'package:flutter/material.dart';

class SignUppage extends StatefulWidget {
  const SignUppage({super.key});

  @override
  State<SignUppage> createState() => _SignUppageState();
}

class _SignUppageState extends State<SignUppage> {
  bool _obscureText = true;
  bool __obscureText = true;
  @override
  Widget build(BuildContext context) {
    final Size sizee = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              left: sizee.width * 0.3,
              top: sizee.height * 0.05,
              child: SizedBox(
                height: sizee.height * 0.2,
                child: SizedBox(
                  width: sizee.width * 0.4,
                  height: sizee.height * 0.2,
                  child: Image.asset(
                    "images/11.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Positioned(
                top: sizee.height * 0.28,
                left: sizee.width * 0.3,
                child: SizedBox(
                  height: sizee.height * 0.07,
                  child: Text(
                    "Register",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: sizee.width * 0.09,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            Positioned(
              top: sizee.height * 0.37,
              left: sizee.width * 0.1,
              child: const SizedBox(
                  child: Text(
                "Email",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
            ),
            Positioned(
              top: sizee.height * 0.395,
              left: sizee.width * 0.07,
              right: sizee.width * 0.07,
              child: SizedBox(
                width: sizee.width - 60,
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),

                    hintText: "Enter Email",
                    hintStyle: const TextStyle(color: Colors.grey),
                    // Utilisation d'une image depuis les assets comme prefixIcon
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(sizee.width *
                          0.028), // Ajustez le padding selon vos besoins
                      child: Image.asset(
                        "images/gmail.png", // Remplacez par le chemin de votre icône
                        width: sizee.width *
                            0.05, // Ajustez la taille selon vos besoins
                        height: sizee.width * 0.05,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(
                        color: Color(0xFFD9D9D9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: sizee.height * 0.485,
              left: sizee.width * 0.1,
              child: const SizedBox(
                  child: Text(
                "Password",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
            ),
            Positioned(
              top: sizee.height * 0.51,
              left: sizee.width * 0.07,
              right: sizee.width * 0.07,
              child: SizedBox(
                width: sizee.width - 60,
                child: TextField(
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),
                    hintText: "Enter Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(sizee.width * 0.028),
                      child: Image.asset(
                        "images/look.png",
                        width: sizee.width * 0.05,
                        height: sizee.width * 0.05,
                      ),
                    ),
                    // Correction de la syntaxe du suffixIcon
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(sizee.width * 0.028),
                        child: Image.asset(
                          "images/view.png",
                          width: sizee.width * 0.05,
                          height: sizee.width * 0.05,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(
                        color: Color(0xFFD9D9D9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: sizee.height * 0.595,
              left: sizee.width * 0.1,
              child: const SizedBox(
                  child: Text(
                "Confirm Password",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
            ),
            Positioned(
              top: sizee.height * 0.62,
              left: sizee.width * 0.07,
              right: sizee.width * 0.07,
              child: SizedBox(
                width: sizee.width - 60,
                child: TextField(
                  obscureText: __obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFD9D9D9),
                    hintText: "Enter Password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(sizee.width * 0.028),
                      child: Image.asset(
                        "images/look.png",
                        width: sizee.width * 0.05,
                        height: sizee.width * 0.05,
                      ),
                    ),
                    // Correction de la syntaxe du suffixIcon
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          __obscureText = false;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(sizee.width * 0.028),
                        child: Image.asset(
                          "images/view.png",
                          width: sizee.width * 0.05,
                          height: sizee.width * 0.05,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                      borderSide: const BorderSide(
                        color: Color(0xFFD9D9D9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: sizee.height * 0.705,
              left: sizee.width * 0.18,
              child: SizedBox(
                  child: Container(
                padding: EdgeInsets.all(sizee.width * 0.05),
                decoration: BoxDecoration(
                  color: const Color(0xFF754CEF),
                  borderRadius:
                      BorderRadius.all(Radius.circular(sizee.width * 0.05)),
                ),
                height: sizee.height * 0.075,
                width: sizee.width * 0.65,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/complete');
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )),
            ),
            Positioned(
                top: sizee.height * 0.8,
                left: sizee.width * 0.16,
                child: Container(
                  width: sizee.width * 0.7,
                  height: sizee.height * 0.003, // Épaisseur de la ligne
                  color: Colors.black,
                )),
            Positioned(
              top: sizee.height * 0.81,
              left: sizee.width * 0.2,
              child: SizedBox(
                child: Container(
                  height: sizee.height * 0.055,
                  width: sizee.width * 0.65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sizee.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/LogIn');
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(sizee.width * 0.02),
                          child: Image.asset(
                            "images/google.png",
                            width: sizee.width * 0.09,
                            height: sizee.width * 0.09,
                          ),
                        ),
                        Text(
                          "Continue With Google",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: sizee.width * 0.04),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: sizee.height * 0.869,
              left: sizee.width * 0.2,
              child: SizedBox(
                child: Container(
                  height: sizee.height * 0.055,
                  width: sizee.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sizee.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/LogIn');
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(sizee.width * 0.02),
                          child: Image.asset(
                            "images/facebook.png",
                            width: sizee.width * 0.07,
                            height: sizee.width * 0.07,
                          ),
                        ),
                        Text(
                          "  Continue With Facebook",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: sizee.width * 0.038),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: sizee.height * 0.925,
              left: sizee.width * 0.43,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "OR",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: sizee.width * 0.04,
                        fontWeight: FontWeight.w500),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/LogIn', (route) => false);
                    },
                    child: Text(
                      "  Log In",
                      style: TextStyle(
                          color: const Color(0xFF754CEF),
                          fontSize: sizee.width * 0.04,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
