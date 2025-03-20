import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Passpage extends StatefulWidget {
  const Passpage({super.key});

  @override
  State<Passpage> createState() => _PasspageState();
}

class _PasspageState extends State<Passpage> {
  // Add a controller for the email TextField
  final TextEditingController _emailController = TextEditingController();
  // Add a form key to validate the form
  final _formKey = GlobalKey<FormState>();
  // Add variable to track loading state during API call

  // Function to send reset password email
  Future<void> _sendResetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get the email from the controller
        final email = _emailController.text.trim();

        // Call Firebase Auth to send password reset email
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Password reset email sent. Please check your inbox.'),
            backgroundColor: Color(0xFF754CEF),
          ),
        );

        // Navigate to reset page
        Navigator.pushNamed(context, '/reset');
      } catch (e) {
        // Show error message if sending fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error sending password reset email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Hide loading indicator
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _emailController.dispose();
    super.dispose();
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
              Positioned(
                  top: si.height * 0.05,
                  left: si.width * 0.1,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/LogIn', (route) => false);
                    },
                    icon: Image.network(
                      s18,
                      width: si.width * 0.09,
                      height: si.width * 0.09,
                    ),
                  )),
              Positioned(
                top: si.height * 0.12,
                left: si.width * 0.15,
                child: Container(
                  width: si.width * 0.7,
                  height: si.width * 0.7,
                  child: Image.network(s20, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: si.height * 0.46,
                left: si.width * 0.1,
                child: Text(
                  "Forgot Your Password",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: si.width * 0.075),
                ),
              ),
              Positioned(
                top: si.height * 0.52,
                left: si.width * 0.1,
                child: const Text(
                  "Don't Worry! Enter Your Email,And We'll Help You",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Positioned(
                top: si.height * 0.54,
                left: si.width * 0.1,
                child: const Text(
                  " Reset Your Password",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Positioned(
                top: si.height * 0.6,
                left: si.width * 0.1,
                child: const Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: si.height * 0.625,
                left: si.width * 0.07,
                right: si.width * 0.07,
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: si.width - 60,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        hintText: "Enter Email",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(si.width * 0.028),
                          child: Image.network(
                            s12,
                            width: si.width * 0.05,
                            height: si.width * 0.05,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(si.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(si.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(si.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(si.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      // Add the validator
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.endsWith('@gmail.com')) {
                          return 'The email must end with @gmail.com';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              // Update the submit button to show loading indicator when processing
              Positioned(
                top: si.height * 0.73,
                left: si.width * 0.18,
                child: Container(
                  height: si.height * 0.075,
                  width: si.width * 0.65,
                  decoration: BoxDecoration(
                    color: const Color(0xFF754CEF),
                    borderRadius: BorderRadius.circular(si.width * 0.05),
                  ),
                  child: MaterialButton(
                    onPressed: _sendResetPassword,
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
