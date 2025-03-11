import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final Size siz = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                  left: siz.width * 0.35,
                  top: siz.height * 0.05,
                  child: Column(
                    children: [
                      Text(
                        "LOG IN",
                        style: TextStyle(
                            fontSize: siz.width * 0.09,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )),
              Positioned(
                left: siz.width * 0.35,
                top: siz.height * 0.15,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
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
              ),
              Positioned(
                top: siz.height * 0.31,
                left: siz.width * 0.1,
                child: const Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: siz.height * 0.335,
                left: siz.width * 0.07,
                right: siz.width * 0.07,
                child: SizedBox(
                  width: siz.width - 60,
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),

                      hintText: "Enter Email",
                      hintStyle: const TextStyle(color: Colors.grey),
                      // Utilisation d'une image depuis les assets comme prefixIcon
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(siz.width *
                            0.028), // Ajustez le padding selon vos besoins
                        child: Image.asset(
                          "images/gmail.png", // Remplacez par le chemin de votre icône
                          width: siz.width *
                              0.05, // Ajustez la taille selon vos besoins
                          height: siz.width * 0.05,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(siz.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(siz.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(siz.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: siz.height * 0.425,
                left: siz.width * 0.1,
                child: const Text(
                  "Password",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: siz.height * 0.45,
                left: siz.width * 0.07,
                right: siz.width * 0.07,
                child: SizedBox(
                  width: siz.width - 60,
                  child: TextField(
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD9D9D9),
                      hintText: "Enter Password",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(siz.width * 0.028),
                        child: Image.asset(
                          "images/look.png",
                          width: siz.width * 0.05,
                          height: 0.05,
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
                          padding: EdgeInsets.all(siz.width * 0.028),
                          child: Image.asset(
                            "images/view.png",
                            width: siz.width * 0.05,
                            height: siz.width * 0.05,
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(siz.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(siz.width * 0.05)),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(siz.width * 0.05)),
                        borderSide: const BorderSide(
                          color: Color(0xFFD9D9D9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Add these after the password TextField
              Positioned(
                top: siz.height * 0.525,
                left: siz.width * 0.07,
                right: siz.width * 0.07,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF754CEF),
                        ),
                        const Text(
                          "Remember Me",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/pass');
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF754CEF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

// Add a login button below
              Positioned(
                top: siz.height * 0.6,
                left: siz.width * 0.18,
                child: Container(
                  height: siz.height * 0.075,
                  width: siz.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(siz.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/podly');
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                          color: Colors.white, fontSize: siz.width * 0.042),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: siz.height * 0.7,
                  left: siz.width * 0.16,
                  child: Container(
                    width: siz.width * 0.7,
                    height: siz.height * 0.003, // Épaisseur de la ligne
                    color: Colors.black,
                  )),
              Positioned(
                top: siz.height * 0.72,
                left: siz.width * 0.18,
                child: Container(
                  height: siz.height * 0.075,
                  width: siz.width * 0.65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(siz.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/SignUp');
                    },
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(siz.width * 0.02),
                          child: Image.asset(
                            "images/google.png",
                            width: siz.width * 0.09,
                            height: siz.width * 0.09,
                          ),
                        ),
                        Text(
                          "Continue With Google",
                          style: TextStyle(
                              color: Colors.black, fontSize: siz.width * 0.04),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: siz.height * 0.8,
                left: siz.width * 0.2,
                child: SizedBox(
                  child: Container(
                    height: siz.height * 0.055,
                    width: siz.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(siz.width * 0.05),
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        // Navigator.pushNamed(context, '/LogIn');
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(siz.width * 0.02),
                            child: Image.asset(
                              "images/facebook.png",
                              width: siz.width * 0.07,
                              height: siz.width * 0.07,
                            ),
                          ),
                          Text(
                            "Continue With Facebook",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: siz.width * 0.04),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: siz.height * 0.89,
                left: siz.width * 0.28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't Have Account?",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: siz.width * 0.035,
                          fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/SignUp', (route) => false);
                      },
                      child: Text(
                        "  Sign Up",
                        style: TextStyle(
                            color: const Color(0xFF754CEF),
                            fontSize: siz.width * 0.035,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
