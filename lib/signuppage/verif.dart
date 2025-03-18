import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfeapp/constants.dart';
import 'dart:async';

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
  String _message = "We sent a verification email. Please check your inbox.";
  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

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

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
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
          content: Text('Password reset email sent. Please check your inbox.'),
          backgroundColor: Color(0xFF754CEF),
        ),
      );
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _isResendDisabled = true;
          _message = "Verification email sent! Check your inbox.";
        });

        // Start countdown and re-enable button after 30 seconds
        _startCountdown();
      }
    } catch (e) {
      setState(() {
        _message = "An error occurred. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size si = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            if (_isVerified) ...[
              // Show verified UI
              Positioned(
                top: si.height * 0.1,
                left: si.width * 0.15,
                child: Container(
                  width: si.width * 0.7,
                  height: si.width * 0.7,
                  child: Image.network(s17, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: si.height * 0.4,
                left: si.width * 0.1,
                child: Container(
                  width: si.width * 0.9,
                  child: Text(
                    "Thank You For Verifying Your Email, Now You Must Complete Your Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: si.width * 0.075,
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
                    borderRadius: BorderRadius.circular(si.width * 0.05),
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
                left: si.width * 0.1,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/SignUp', (route) => false);
                  },
                  icon: Image.network(
                    s18,
                    width: si.width * 0.09,
                    height: si.width * 0.09,
                  ),
                ),
              ),
              Positioned(
                top: si.height * 0.26,
                left: si.width * 0.1,
                child: Container(
                  width: si.width * 0.9,
                  child: Text(
                    "We Sent A Verification To Your Email, Please Check Your Inbox",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: si.width * 0.075,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: si.height * 0.5,
                left: si.width * 0.18,
                child: Container(
                  height: si.height * 0.075,
                  width: si.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(si.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.currentUser?.reload();
                      User? user = FirebaseAuth.instance.currentUser;
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
                top: si.height * 0.6,
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
                    onPressed:
                        _isResendDisabled ? null : _resendVerificationEmail,
                    padding: EdgeInsets.all(si.width * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Resend Email",
                          style: TextStyle(color: Color(0xFF754CEF)),
                        ),
                        if (_countdownSeconds > 0) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFFEAE4F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$_countdownSeconds s",
                              style: TextStyle(
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
      ),
    ));
  }
}
