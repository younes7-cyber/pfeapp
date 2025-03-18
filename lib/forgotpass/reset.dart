import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pfeapp/constants.dart';
import 'dart:async';

class Resetpage extends StatefulWidget {
  const Resetpage({super.key});

  @override
  State<Resetpage> createState() => _ResetpageState();
}

class _ResetpageState extends State<Resetpage> {
  bool _isResendDisabled = false;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  String _message =
      "We sent a reset password email to your Email, please check your inbox";

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
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

  void _resendResetPasswordEmail() async {
    try {
      // Get the user's email - this should be passed to this page or retrieved from somewhere
      // For demonstration, I'm using a placeholder approach
      // In a real app, you would get this from your auth state or pass it to this page
      String email = FirebaseAuth.instance.currentUser?.email ?? '';

      // If no email is available in the current user, you might need to
      // either pass it from the previous page or store it temporarily
      if (email.isEmpty) {
        // This is a fallback - in real implementation, you should handle this better
        setState(() {
          _message = "No email found. Please go back and try again.";
        });
        return;
      }

      // Send the reset password email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Please check your inbox.'),
          backgroundColor: Color(0xFF754CEF),
        ),
      );
      setState(() {
        _isResendDisabled = true;
        _message = "Reset password email sent again! Please check your inbox.";
      });

      // Start countdown and re-enable button after 30 seconds
      _startCountdown();
    } catch (e) {
      setState(() {
        _message = "An error occurred: ${e.toString()}. Please try again.";
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
              // Back button to return to the password reset page
              Positioned(
                top: si.height * 0.05,
                left: si.width * 0.1,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/pass', (route) => false);
                  },
                  icon: Image.network(
                    s18, // Back icon
                    width: si.width * 0.09,
                    height: si.width * 0.09,
                  ),
                ),
              ),

              // Image for password reset
              Positioned(
                top: si.height * 0.15,
                left: si.width * 0.15,
                child: Container(
                  width: si.width * 0.7,
                  height: si.width * 0.7,
                  child: Image.network(s17, fit: BoxFit.contain),
                ),
              ),

              // Message text
              Positioned(
                top: si.height * 0.45,
                left: si.width * 0.1,
                child: Container(
                  width: si.width * 0.8,
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: si.width * 0.055,
                    ),
                  ),
                ),
              ),

              // Done button to go back to login
              Positioned(
                top: si.height * 0.6,
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
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/LogIn', (route) => false);
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: si.width * 0.042,
                      ),
                    ),
                  ),
                ),
              ),

              // Resend email button
              Positioned(
                top: si.height * 0.7,
                left: si.width * 0.18,
                child: Container(
                  height: si.height * 0.075,
                  width: si.width * 0.65,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(si.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed:
                        _isResendDisabled ? null : _resendResetPasswordEmail,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Resend Email",
                          style: TextStyle(
                            color: Color(0xFF754CEF),
                            fontSize: si.width * 0.042,
                            fontWeight: FontWeight.bold,
                          ),
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
          ),
        ),
      ),
    );
  }
}
