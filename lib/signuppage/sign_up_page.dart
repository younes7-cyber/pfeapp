import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pfeapp/constants.dart';
/*import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';*/

class SignUppage extends StatefulWidget {
  const SignUppage({super.key});

  @override
  State<SignUppage> createState() => _SignUppageState();
}

class _SignUppageState extends State<SignUppage> {
  bool _obscureText = true;
  bool __obscureText = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController confirm = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final Size sizee = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
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
                      child: Text(
                        "Register",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: sizee.width * 0.09,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                // Error message display
                if (errorMessage != null)
                  Positioned(
                    top: sizee.height * 0.27,
                    left: sizee.width * 0.1,
                    right: sizee.width * 0.1,
                    child: Container(
                      padding: EdgeInsets.all(8),
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
                  top: sizee.height * 0.34,
                  left: sizee.width * 0.1,
                  child: const SizedBox(
                      child: Text(
                    "Email",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )),
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
                          padding: EdgeInsets.all(sizee.width * 0.028),
                          child: Image.network(
                            s12,
                            width: sizee.width * 0.05,
                            height: sizee.width * 0.05,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(sizee.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(sizee.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(sizee.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
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
                  child: const SizedBox(
                      child: Text(
                    "Password",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )),
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
                          padding: EdgeInsets.all(sizee.width * 0.028),
                          child: Image.network(
                            s13,
                            width: sizee.width * 0.05,
                            height: sizee.width * 0.05,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(sizee.width * 0.028),
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
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(sizee.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(sizee.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
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
                  child: const SizedBox(
                      child: Text(
                    "Confirm Password",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  )),
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
                          padding: EdgeInsets.all(sizee.width * 0.028),
                          child: Image.network(
                            s13,
                            width: sizee.width * 0.05,
                            height: sizee.width * 0.05,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              __obscureText = !__obscureText;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(sizee.width * 0.028),
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
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(sizee.width * 0.05)),
                          borderSide:
                              const BorderSide(color: Color(0xFFD9D9D9)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(sizee.width * 0.05)),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
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
                  top: sizee.height * 0.715,
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
                      onPressed: () async {
                        setState(() {
                          errorMessage = null;
                        });

                        // Validate form
                        if (_formKey.currentState!.validate()) {
                          try {
                            final userExists = (await FirebaseAuth.instance
                                    .fetchSignInMethodsForEmail(email.text))
                                .isNotEmpty;

                            if (userExists) {
                              setState(() {
                                errorMessage = "This email is already in use";
                              });
                              return;
                            }

                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: email.text,
                              password: pass.text,
                            );

                            FirebaseAuth.instance.currentUser!
                                .sendEmailVerification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Email Verification sent. Please check your inbox.'),
                                backgroundColor: Color(0xFF754CEF),
                              ),
                            );
                            Navigator.pushNamed(context, '/verif');
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              errorMessage =
                                  e.message ?? "An error has occurred";
                            });
                          } catch (e) {
                            setState(() {
                              errorMessage = "An error has occurred";
                            });
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
                /*Positioned(
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
                        onPressed: () async {
                          try {
                            setState(() {
                              errorMessage = null;
                            });

                            // Initialize Google Sign In
                            final GoogleSignIn googleSignIn = GoogleSignIn();
                            final GoogleSignInAccount? googleUser =
                                await googleSignIn.signIn();

                            if (googleUser == null) {
                              // User canceled the sign-in process
                              return;
                            }

                            // Get authentication details
                            final GoogleSignInAuthentication googleAuth =
                                await googleUser.authentication;
                            GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken,
                            );

                            // Check if user already exists
                            try {
                              final methods = await FirebaseAuth.instance
                                  .fetchSignInMethodsForEmail(googleUser.email);

                              if (methods.isNotEmpty) {
                                // User already exists, show error
                                setState(() {
                                  errorMessage =
                                      "This Google account is already registered. Please log in instead.";
                                });

                                // Sign out from Google
                                await googleSignIn.signOut();
                                return;
                              }
                            } catch (e) {
                              // Continue with new sign up
                            }

                            // Sign up with Google

                            // Send email verification
                            await FirebaseAuth.instance.currentUser!
                                .sendEmailVerification();
                            Navigator.pushNamed(context, '/verif');
                          } catch (e) {
                            setState(() {
                              errorMessage =
                                  "Google sign in failed: ${e.toString()}";
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(sizee.width * 0.02),
                              child: Image.network(
                                s15,
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

// Replace the existing Facebook button code with this:
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
                        onPressed: () async {
                          try {
                            setState(() {
                              errorMessage = null;
                            });

                            // Initialize Facebook Sign In
                            final LoginResult result =
                                await FacebookAuth.instance.login();

                            if (result.status != LoginStatus.success) {
                              // User canceled or login failed
                              throw Exception("Facebook login failed");
                            }

                            // Get user data
                            final userData =
                                await FacebookAuth.instance.getUserData();
                            final String email = userData['email'] ?? '';

                            if (email.isEmpty) {
                              setState(() {
                                errorMessage =
                                    "Could not get email from Facebook";
                              });
                              return;
                            }

                            // Check if user already exists
                            try {
                              final methods = await FirebaseAuth.instance
                                  .fetchSignInMethodsForEmail(email);

                              if (methods.isNotEmpty) {
                                // User already exists, show error
                                setState(() {
                                  errorMessage =
                                      "This Facebook account is already registered. Please log in instead.";
                                });

                                // Sign out from Facebook
                                await FacebookAuth.instance.logOut();
                                return;
                              }
                            } catch (e) {
                              // Continue with new sign up
                            }

                            // Create a credential directly from the auth provider
                            final authCredential =
                                FacebookAuthProvider.credential(
                                    result.accessToken?.tokenString ?? '');

                            // Sign up with Facebook
                            await FirebaseAuth.instance
                                .signInWithCredential(authCredential);

                            // Send email verification
                            await FirebaseAuth.instance.currentUser!
                                .sendEmailVerification();
                            Navigator.pushNamed(context, '/verif');
                          } catch (e) {
                            setState(() {
                              errorMessage =
                                  "Facebook sign in failed: ${e.toString()}";
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(sizee.width * 0.02),
                              child: Image.network(
                                s16,
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
                ),*/
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
          ),
        ),
      ),
    );
  }
}
