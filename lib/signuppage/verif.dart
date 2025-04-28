import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfeapp/annimation.dart';
import 'package:pfeapp/constants.dart';
import 'dart:async';

import 'package:pfeapp/theme_provider.dart';
import 'package:provider/provider.dart';

class Verifpage extends StatefulWidget {
  const Verifpage({super.key});

  @override
  State<Verifpage> createState() => _VerifpageState();
}

class _VerifpageState extends State<Verifpage> {
  bool _isResendDisabled = false;
  bool _isVerified = false;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => isLoading = true);
      _checkEmailVerification();
      await Future.delayed(const Duration(seconds: 3));
      setState(() => isLoading = false);
    });
  }

  bool isLoading = true;
  final String emaill = FirebaseAuth.instance.currentUser?.email ?? "";
  final String id = FirebaseAuth.instance.currentUser?.uid ?? "";
  void _checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // Reload user information

    if (user != null && user.emailVerified) {
      setState(() {
        _isVerified = true;
      });
    }
  }

  void _startCountdown() {
    _countdownSeconds = 30;
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _isResendDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  void _resendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('reset email sent. Please check your inbox.'),
          backgroundColor: Color(0xFF754CEF),
        ),
      );
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _isResendDisabled = true;
        });

        // Start countdown and re-enable button after 30 seconds
        _startCountdown();
      }
    } catch (e) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size si = MediaQuery.of(context).size;
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
                      child: Stack(
                        children: [
                          if (_isVerified) ...[
                            // Show verified UI
                            Positioned(
                              top: si.height * 0.1,
                              left: si.width * 0.15,
                              child: SizedBox(
                                width: si.width * 0.7,
                                height: si.width * 0.7,
                                child: Image.network(
                                    themeProvider.isDarkMode ? s99 : s17,
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: si.height * 0.44,
                              left: si.width * 0.01,
                              child: SizedBox(
                                width: si.width,
                                child: Text(
                                  "Thank You For Verifying Your Email, Now You Must Complete Your Profile",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: si.width * 0.06,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: si.height * 0.65,
                              left: si.width * 0.18,
                              child: Container(
                                height: si.height * 0.075,
                                width: si.width * 0.65,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF754CEF),
                                  borderRadius:
                                      BorderRadius.circular(si.width * 0.05),
                                ),
                                child: MaterialButton(
                                  onPressed: () {
                                    // Navigate to complete profile page
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/complete', (route) => false);
                                  },
                                  child: Text(
                                    "Complete Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: si.width * 0.042,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Show unverified UI

                            Positioned(
                              top: si.height * 0.05,
                              left: si.width * 0.07,
                              child: IconButton(
                                onPressed: () async {
                                  try {
                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null) {
                                      await user
                                          .delete(); //  Supprime le compte
                                      final firestore =
                                          FirebaseFirestore.instance;

                                      // 1. Supprimer l'utilisateur de la collection users
                                      await firestore
                                          .collection('users')
                                          .where('userId', isEqualTo: id)
                                          .get()
                                          .then((snapshot) {
                                        for (DocumentSnapshot ds
                                            in snapshot.docs) {
                                          ds.reference.delete();
                                        }
                                      });
                                    }
                                    // ignore: empty_catches
                                  } catch (e) {}

                                  // Redirige vers la page d'inscription
                                  Navigator.pushNamedAndRemoveUntil(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      '/SignUp',
                                      (route) => false);
                                },
                                icon: Image.network(
                                  themeProvider.isDarkMode ? s97 : s18,
                                  width: si.width * 0.09,
                                  height: si.width * 0.09,
                                ),
                              ),
                            ),
                            Positioned(
                              top: si.height * 0.12,
                              left: si.width * 0.15,
                              child: SizedBox(
                                width: si.width * 0.7,
                                height: si.width * 0.7,
                                child: Image.network(
                                    themeProvider.isDarkMode ? s98 : s20,
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: si.height * 0.49,
                              left: si.width * 0.07,
                              child: SizedBox(
                                width: si.width,
                                child: Text(
                                  "We Sent A Verification To Your Email $emaill, Please Check Your Inbox",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: si.width * 0.06,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: si.height * 0.7,
                              left: si.width * 0.18,
                              child: Container(
                                height: si.height * 0.075,
                                width: si.width * 0.65,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF754CEF),
                                  borderRadius:
                                      BorderRadius.circular(si.width * 0.05),
                                ),
                                child: MaterialButton(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.currentUser
                                        ?.reload();
                                    User? user =
                                        FirebaseAuth.instance.currentUser;
                                    if (user != null && user.emailVerified) {
                                      setState(() {
                                        _isVerified = true;
                                      });
                                    }
                                  },
                                  child: Text(
                                    "I Verified My Email",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: si.width * 0.042,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: si.height * 0.8,
                              left: si.width * 0.18,
                              child: Container(
                                height: si.height * 0.07,
                                width: si.width * 0.65,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(si.width * 0.01),
                                  ),
                                ),
                                child: MaterialButton(
                                  onPressed: _isResendDisabled
                                      ? null
                                      : _resendVerificationEmail,
                                  padding: EdgeInsets.all(si.width * 0.01),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Resend Email",
                                        style:
                                            TextStyle(color: Color(0xFF754CEF)),
                                      ),
                                      if (_countdownSeconds > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEAE4F9),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "$_countdownSeconds s",
                                            style: const TextStyle(
                                              color: Color(0xFF754CEF),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  })));
  }
}
