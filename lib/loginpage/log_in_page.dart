import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
// Inside your _LoginPageState class, add these fields
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> user = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      await fetchuser();
      await Future.delayed(const Duration(seconds: 1));
      setState(() => isLoading = false);
    });
  }

  bool isLoading = true;
  Future<void> fetchuser() async {
    try {
      final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Ajout des logs pour déboguer
      debugPrint('Nombre de chaînes trouvées : ${querySnapshot.docs.length}');
      debugPrint(
          'Données des chaînes : ${querySnapshot.docs.map((doc) => doc.data()).toList()}');

      setState(() {
        user = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des chaînes : $e');
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorMessage;
  bool _obscureText = true;
  bool _rememberMe = false;
  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        errorMessage = null;
      });

      // Initialiser Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Déconnexion pour éviter les conflits

      // Sélection d'un compte Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Connexion Google annulée par l'utilisateur");
        return;
      }

      print("Email Google sélectionné: ${googleUser.email}");

      // Vérifier si l'utilisateur existe dans la base de données avec méthode google
      bool userExistsInDatabase =
          await checkIfUserExistsWithGoogleMethod(googleUser.email);

      if (!userExistsInDatabase) {
        setState(() {
          errorMessage =
              "Aucun compte n'existe avec cet email. Veuillez d'abord vous inscrire.";
        });
        return;
      }

      // L'utilisateur existe dans votre base, procéder à la connexion Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        print("User is signed in!");
        print(
            "Connexion réussie avec l'utilisateur: ${userCredential.user?.email}");

        if (userCredential.user != null) {
          if (_rememberMe) {
            await saveUser(googleUser.email);
          }
          // Navigation vers la page Podly après connexion réussie
          Navigator.pushNamed(context, '/podly');
        }
      } on FirebaseAuthException catch (authError) {
        print("Erreur de connexion: ${authError.code} - ${authError.message}");
        setState(() {
          errorMessage = "Erreur de connexion: ${authError.message}";
        });

        // Si l'authentification crée un utilisateur automatiquement, le supprimer
        try {
          await FirebaseAuth.instance.currentUser?.delete();
        } catch (e) {
          // Ignorer les erreurs de suppression
        }
        await FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print("Erreur générale: $e");
      setState(() {
        errorMessage = "Une erreur inattendue est survenue.";
      });
    }
  }

// Fonction modifiée pour vérifier si l'utilisateur existe avec la méthode google
  Future<bool> checkIfUserExistsWithGoogleMethod(String email) async {
    try {
      // Vérification dans votre collection Firestore avec l'email ET la méthode
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('methode', isEqualTo: 'google')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Erreur lors de la vérification de l'utilisateur: $e");
      return false;
    }
  }

  Future<void> saveUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  @override
  Widget build(BuildContext context) {
    final Size siz = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: isLoading
              ? const Text("")
              : Form(
                  key: _formKey,
                  child: Stack(
                    children: [
                      Positioned(
                          left: siz.width * 0.35,
                          top: siz.height * 0.01,
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
                        top: siz.height * 0.07,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.width * 0.3,
                          margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.03),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: /* ClipOval(
                            child: Image.network(
                              user[0]['photoUrl'],
                              fit: BoxFit.cover,
                            )),*/
                              Text(""),
                        ),
                      ),

                      // Error message display
                      if (errorMessage != null)
                        Positioned(
                          top: siz.height * 0.22,
                          left: siz.width * 0.1,
                          right: siz.width * 0.1,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
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
                          child: TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email cannot be empty';
                              }
                              if (!value.endsWith('@gmail.com')) {
                                return 'The email must end with @gmail.com';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFD9D9D9),
                              hintText: "Enter Email",
                              hintStyle: const TextStyle(color: Colors.grey),
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(siz.width * 0.028),
                                child: Image.network(
                                  s12,
                                  width: siz.width * 0.05,
                                  height: siz.width * 0.05,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide: const BorderSide(
                                  color: Colors.red,
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
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password cannot be empty';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFD9D9D9),
                              hintText: "Enter Password",
                              hintStyle: const TextStyle(color: Colors.grey),
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(siz.width * 0.028),
                                child: Image.network(
                                  s13,
                                  width: siz.width * 0.05,
                                  height: 0.05,
                                ),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(siz.width * 0.028),
                                  child: Image.network(
                                    s14,
                                    width: siz.width * 0.05,
                                    height: siz.width * 0.05,
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD9D9D9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(siz.width * 0.05)),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Remember Me checkbox and Forgot Password
                      Positioned(
                        top: siz.height * 0.545,
                        left: siz.width * 0.06,
                        right: siz.width * 0.06,
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

                      // Login button with Firebase Auth implementation
                      Positioned(
                        top: siz.height * 0.62,
                        left: siz.width * 0.18,
                        child: Container(
                          height: siz.height * 0.075,
                          width: siz.width * 0.65,
                          decoration: BoxDecoration(
                            color: const Color(0xFF754CEF),
                            borderRadius:
                                BorderRadius.circular(siz.width * 0.05),
                          ),
                          child: MaterialButton(
                            onPressed: () async {
                              setState(() {
                                errorMessage = null;
                              });

                              // Validate form
                              if (_formKey.currentState!.validate()) {
                                try {
                                  // Vérifier d'abord si l'utilisateur existe dans Firestore
                                  final QuerySnapshot userCheck =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .where('email',
                                              isEqualTo: emailController.text)
                                          .where('methode',
                                              isEqualTo: 'password')
                                          .get();

                                  // Si aucun document n'est trouvé, l'utilisateur n'existe pas
                                  if (userCheck.docs.isEmpty) {
                                    setState(() {
                                      errorMessage = "User does not exist";
                                    });
                                    return; // Arrêter l'exécution ici
                                  }

                                  // L'utilisateur existe, procéder à l'authentification
                                  UserCredential userCredential =
                                      await FirebaseAuth.instance
                                          .signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  // Si l'utilisateur est connecté avec succès
                                  if (userCredential.user != null) {
                                    // Vérifier si "Remember Me" est coché
                                    if (_rememberMe) {
                                      await saveUser(emailController.text);
                                    }

                                    // Redirection vers la page d'accueil
                                    Navigator.pushNamed(context, '/podly');
                                  }
                                } on FirebaseAuthException catch (e) {
                                  print("Firebase Auth Error Code: ${e.code}");
                                  print(
                                      "Firebase Auth Error Message: ${e.message}");

                                  setState(() {
                                    switch (e.code) {
                                      case 'wrong-password':
                                        errorMessage =
                                            "Incorrect password. Please try again.";
                                        break;
                                      case 'user-not-found':
                                        errorMessage =
                                            "No account found with this email.";
                                        break;
                                      case 'invalid-credential':
                                        errorMessage =
                                            "Invalid email or password.";
                                        break;
                                      case 'invalid-email':
                                        errorMessage = "Invalid email format.";
                                        break;
                                      case 'user-disabled':
                                        errorMessage =
                                            "This account has been disabled.";
                                        break;
                                      case 'too-many-requests':
                                        errorMessage =
                                            "Too many login attempts. Try again later.";
                                        break;
                                      default:
                                        errorMessage =
                                            "Login failed: ${e.message}";
                                    }
                                  });
                                } catch (e) {
                                  print("General Error: $e");
                                  setState(() {
                                    errorMessage =
                                        "An unexpected error occurred.";
                                  });
                                }
                              }
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: siz.width * 0.042),
                            ),
                          ),
                        ),
                      ),
                      // Sign Up link at bottom
                      Positioned(
                        top: siz.height * 0.88,
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
                      ),
                      Positioned(
                          top: siz.height * 0.72,
                          left: siz.width * 0.16,
                          child: Container(
                            width: siz.width * 0.7,
                            height: siz.height * 0.003, // Épaisseur de la ligne
                            color: Colors.black,
                          )),
                      Positioned(
                        top: siz.height * 0.77,
                        left: siz.width * 0.18,
                        child: Container(
                          height: siz.height * 0.075,
                          width: siz.width * 0.65,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(siz.width * 0.05),
                          ),
                          child: MaterialButton(
                            onPressed: () async {
                              await signInWithGoogle();
                            },
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(siz.width * 0.02),
                                  child: Image.network(
                                    s15,
                                    width: siz.width * 0.09,
                                    height: siz.width * 0.09,
                                  ),
                                ),
                                Text(
                                  "Continue With Google",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: siz.width * 0.04),
                                ),
                              ],
                            ),
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
