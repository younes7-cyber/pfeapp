import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class SignUppage extends StatefulWidget {
  const SignUppage({super.key});

  @override
  State<SignUppage> createState() => _SignUppageState();
}

class _SignUppageState extends State<SignUppage> {
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
  bool _obscureText = true;
  bool __obscureText = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController confirm = TextEditingController();
  String? errorMessage;
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // First, make sure we're signed out of Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      // Prompt user to select Google account
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Check if email exists in Firestore 'users' collection with Google method
      final QuerySnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: googleUser.email)
          .get();

      // If email already exists with Google method, show error and return
      if (userDoc.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            errorMessage = "This email is already in use";
          });
        }
        return;
      }

      // Continue with creating the user since email doesn't exist with Google method
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get current user ID
      final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseMessaging.instance.subscribeToTopic(currentUserId);

      // Get FCM token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      // Add user data to Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'email': googleUser.email,
        'userId': currentUserId,
        'methode': 'google',
        'firstName': '',
        'lastName': '',
        'age': 0,
        'country': '',
        'photoUrl':
            'https://migwbqbtfzszopvhdzre.supabase.co/storage/v1/object/public/pfeapp/profile/output-onlinejpgtools%20(2).jpg', // Utilise l'URL finale
        'createdAt': FieldValue.serverTimestamp(),
        'fcmToken': fcmToken, // Store FCM token
        'notificationTopic': currentUserId,
      });

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "A verification email has been sent. Please check your inbox."),
          backgroundColor: Color(0xFF754CEF),
        ),
      );

      // Navigate to verification page
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/verif');
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = "Google signin faild";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size sizee = MediaQuery.of(context).size;
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
                    child: Form(
                      key: _formKey,
                      child: Stack(
                        children: [
                          Positioned(
                            left: sizee.width * 0.3,
                            top: sizee.height * 0.01,
                            child: SizedBox(
                              height: sizee.height * 0.2,
                              child: SizedBox(
                                width: sizee.width * 0.4,
                                height: sizee.height * 0.2,
                                child: Image.network(
                                  s11,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              top: sizee.height * 0.21,
                              left: sizee.width * 0.3,
                              child: SizedBox(
                                  height: sizee.height * 0.07,
                                  child: Consumer<ThemeProvider>(
                                    builder: (context, themeProvider, child) {
                                      return Text(
                                        'Register',
                                        style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: sizee.width * 0.09,
                                            fontWeight: FontWeight.bold),
                                      );
                                    },
                                  )
                                  /*Text(
                        "Register",
                        style: TextStyle(
                            color: Colors.black,
                           ),
                      ),*/
                                  )),
                          // Error message display
                          if (errorMessage != null)
                            Positioned(
                              top: sizee.height * 0.28,
                              left: sizee.width * 0.1,
                              right: sizee.width * 0.1,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: themeProvider.isDarkMode
                                      ? Colors.red.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.1),
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
                            top: sizee.height * 0.34,
                            left: sizee.width * 0.1,
                            child: SizedBox(child: Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                              return Text(
                                "Email",
                                style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold),
                              );
                            })),
                          ),
                          Positioned(
                            top: sizee.height * 0.365,
                            left: sizee.width * 0.07,
                            right: sizee.width * 0.07,
                            child: SizedBox(
                              width: sizee.width - 60,
                              child: TextFormField(
                                controller: email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email cannot be empty';
                                  }
                                  if (!value.endsWith('@gmail.com')) {
                                    return 'The email must end with @gmail.com';
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  hintText: "Enter Email",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  prefixIcon: Padding(
                                    padding:
                                        EdgeInsets.all(sizee.width * 0.028),
                                    child: Image.network(
                                      s12,
                                      width: sizee.width * 0.05,
                                      height: sizee.width * 0.05,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: sizee.height * 0.47,
                            left: sizee.width * 0.1,
                            child: SizedBox(child: Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                              return Text(
                                "Password",
                                style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold),
                              );
                            })),
                          ),
                          Positioned(
                            top: sizee.height * 0.495,
                            left: sizee.width * 0.07,
                            right: sizee.width * 0.07,
                            child: SizedBox(
                              width: sizee.width - 60,
                              child: TextFormField(
                                controller: pass,
                                obscureText: _obscureText,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password cannot be empty';
                                  }
                                  return null;
                                },
                                cursorColor: Colors.black,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  hintText: "Enter Password",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  prefixIcon: Padding(
                                    padding:
                                        EdgeInsets.all(sizee.width * 0.028),
                                    child: Image.network(
                                      s13,
                                      width: sizee.width * 0.05,
                                      height: sizee.width * 0.05,
                                    ),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      if (mounted) {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(sizee.width * 0.028),
                                      child: Image.network(
                                        s14,
                                        width: sizee.width * 0.05,
                                        height: sizee.width * 0.05,
                                      ),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: sizee.height * 0.595,
                            left: sizee.width * 0.1,
                            child: SizedBox(child: Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                              return Text(
                                "Confirm Password",
                                style: TextStyle(
                                    color: themeProvider.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold),
                              );
                            })),
                          ),
                          Positioned(
                            top: sizee.height * 0.62,
                            left: sizee.width * 0.07,
                            right: sizee.width * 0.07,
                            child: SizedBox(
                              width: sizee.width - 60,
                              child: TextFormField(
                                controller: confirm,
                                obscureText: __obscureText,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm password cannot be empty';
                                  }
                                  if (value != pass.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                cursorColor: Colors.black,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFD9D9D9),
                                  hintText: "Enter Password",
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  errorStyle: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  prefixIcon: Padding(
                                    padding:
                                        EdgeInsets.all(sizee.width * 0.028),
                                    child: Image.network(
                                      s13,
                                      width: sizee.width * 0.05,
                                      height: sizee.width * 0.05,
                                    ),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      if (mounted) {
                                        setState(() {
                                          __obscureText = !__obscureText;
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(sizee.width * 0.028),
                                      child: Image.network(
                                        s14,
                                        width: sizee.width * 0.05,
                                        height: sizee.width * 0.05,
                                      ),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFD9D9D9)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(sizee.width * 0.05)),
                                    borderSide: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              top: sizee.height * 0.83,
                              left: sizee.width * 0.16,
                              child: Container(
                                width: sizee.width * 0.7,
                                height: sizee.height *
                                    0.003, // Épaisseur de la ligne
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              )),
                          Positioned(
                            top: sizee.height * 0.73,
                            left: sizee.width * 0.18,
                            child: SizedBox(
                                child: Container(
                              padding: EdgeInsets.all(sizee.width * 0.05),
                              decoration: BoxDecoration(
                                color: const Color(0xFF754CEF),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(sizee.width * 0.05)),
                              ),
                              height: sizee.height * 0.075,
                              width: sizee.width * 0.65,
                              child: MaterialButton(
                                onPressed: () async {
                                  if (mounted) {
                                    setState(() {
                                      errorMessage = null;
                                    });
                                  }
                                  // Validate form
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      // First check if email exists in Firestore 'users' collection
                                      final QuerySnapshot userDoc =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .where('email',
                                                  isEqualTo: email.text)
                                              .get();

                                      // Check if user already exists in Firestore
                                      if (userDoc.docs.isNotEmpty) {
                                        if (mounted) {
                                          setState(() {
                                            errorMessage =
                                                "This email is already in use";
                                          });
                                        }
                                        return;
                                      }

                                      // If not in Firestore, proceed with Firebase Auth creation
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                        email: email.text,
                                        password: pass.text,
                                      );

                                      // Get current user ID after creation
                                      final String currentUserId = FirebaseAuth
                                          .instance.currentUser!.uid;
                                      // Subscribe to FCM topic with user's ID
                                      await FirebaseMessaging.instance
                                          .subscribeToTopic(currentUserId);

                                      // Get FCM token
                                      String? fcmToken = await FirebaseMessaging
                                          .instance
                                          .getToken();
                                      // Add user data to Firestore
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .add({
                                        'email': email.text,
                                        'userId': currentUserId,
                                        'methode': 'password',
                                        'firstName': '',
                                        'lastName': '',
                                        'age': 0,
                                        'country': '',
                                        'photoUrl':
                                            'https://migwbqbtfzszopvhdzre.supabase.co/storage/v1/object/public/pfeapp/profile/output-onlinejpgtools%20(2).jpg', // Utilise l'URL finale
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                        'fcmToken': fcmToken, // Store FCM token
                                        'notificationTopic':
                                            currentUserId, // Store notification topic
                                      });

                                      // Send verification email
                                      FirebaseAuth.instance.currentUser!
                                          .sendEmailVerification();

                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email Verification sent. Please check your inbox.'),
                                          backgroundColor: Color(0xFF754CEF),
                                        ),
                                      );

                                      // ignore: use_build_context_synchronously
                                      Navigator.pushNamed(context, '/verif');
                                    } on FirebaseAuthException catch (e) {
                                      if (mounted) {
                                        setState(() {
                                          errorMessage = e.message ??
                                              "An error has occurred";
                                        });
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        setState(() {
                                          errorMessage =
                                              "An error has occurred";
                                        });
                                      }
                                    }
                                  }
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )),
                          ),
                          Positioned(
                            top: sizee.height * 0.84,
                            left: sizee.width * 0.2,
                            child: SizedBox(
                              child: Container(
                                height: sizee.height * 0.055,
                                width: sizee.width * 0.65,
                                decoration: BoxDecoration(
                                  color: themeProvider.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(sizee.width * 0.05),
                                ),
                                child: MaterialButton(
                                  onPressed: () {
                                    signInWithGoogle(context);
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(
                                          sizee.width * 0.02,
                                        ),
                                        child: Image.network(
                                          themeProvider.isDarkMode ? s95 : s15,
                                          width: sizee.width * 0.09,
                                          height: sizee.width * 0.09,
                                        ),
                                      ),
                                      Consumer<ThemeProvider>(builder:
                                          (context, themeProvider, child) {
                                        return Text(
                                          "Continue With Google",
                                          style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: sizee.width * 0.04,
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: sizee.height * 0.91,
                            left: sizee.width * 0.43,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "OR",
                                  style: TextStyle(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
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
                    ),
                  );
                })),
    );
  }
}
