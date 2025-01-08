import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:saveily_2/screens/auth/form.dart';
import 'package:saveily_2/screens/auth/login.dart';
import 'package:saveily_2/screens/auth/signup.dart';
import 'package:saveily_2/screens/home/homepage.dart';
import 'package:saveily_2/theme/color.dart';
import 'package:saveily_2/theme/image_flipper.dart';
import 'package:saveily_2/widgets/policyBottomSheet.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


//Welcome page contains just the ui and only buttons linking to
//signup with email page
//login page
//google signup page

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

Future<void> handleGoogleSignIn(BuildContext context) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // Add this for web
    scopes: [
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/contacts.readonly', // People API scope
    ],
  );

  try {
    // Initialize gapi for web if needed
    if (kIsWeb) {
      await window.gapi?.load('auth2', () {});
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser != null) {
      // Get user details if needed
      // final googleEmail = googleUser.email;
      // final googleDisplayName = googleUser.displayName;
      // final googlePhotoUrl = googleUser.photoUrl;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user is signing in for the first time
        final additionalInfo = userCredential.additionalUserInfo;
        if (additionalInfo != null && additionalInfo.isNewUser) {
          // Navigate to FormPage if first-time sign-in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => FormScreen()),
          );
        } else {
          // Navigate to MainScreen if already signed in before
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        }
      }
    }
  } catch (e) {
    print("Error during Google Sign-In: $e");
    // More detailed error handling
    String errorMessage = 'Google Sign-In failed';
    if (e.toString().contains('People API has not been used')) {
      errorMessage = 'Please wait a few minutes and try again. The API is being activated.';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ImageFlipper(), // This should now be visible if the ImageFlipper works properly
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.1), // Shadow color with opacity
                        spreadRadius: 2, // How much the shadow spreads
                        blurRadius: 5, // How blurry the shadow is
                        offset: Offset(0, 4), // The shadow's position (x, y)
                      ),
                    ]),
                child: Column(
                  children: [
                    const Text('Sign Up',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Roboto',
                        )),
                    const Text(
                      "It's easier to sign up now",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: SizedBox(
                          width: 290,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "I'll use Email",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                         handleGoogleSignIn(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: SizedBox(
                          width: 290,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Image.asset(
                                "lib/assets/googleIcon.png",
                                // color: Colors.white,
                                width: 40,
                                height: 40,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Continue with Google",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: const Text(
                            "Log in",
                            style: TextStyle(color: primaryColor),
                          ),
                        )
                      ],
                    ),
                  
                   
                  ],
                ),
              ),
              SizedBox(height: 29,),
             const BottomLinks(),
            ],
          ),
        ),
      ),
    );
  }
}

extension on SingletonFlutterWindow {
  get gapi => null;
}
