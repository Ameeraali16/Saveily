import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:saveily_2/screens/auth/form.dart';
import 'package:saveily_2/screens/auth/welcomePage.dart';
import 'package:saveily_2/screens/home/homepage.dart';
import 'package:saveily_2/theme/color.dart';
import 'package:saveily_2/theme/image_flipper.dart';
import 'package:saveily_2/widgets/policyBottomSheet.dart';

void main() {
  runApp(const MaterialApp(
    home: Login(),
    debugShowCheckedModeBanner: false,
  ));
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

   String _message = '';
   String _formError = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  bool _validateInputs() {
    setState(() {
      _formError = ''; // Reset error message
    });

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _formError = 'Please fill in all fields.';
      });
      return false;
    }
    return true;
  }


  //Login method

  Future<void> _signInWithFirebase() async {
  if (!_validateInputs()) return;

  // Show loading circle
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Authenticate with Firebase
    final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // Get the current user
    final user = FirebaseAuth.instance.currentUser;
    print('User signed in: ${user?.uid}'); // Debugging

    if (user != null) {
      // Check if the user exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // Replace with your Firestore collection name
          .doc(user.uid) // Use UID as the document ID
          .get();

      print('User document exists: ${userDoc.exists}'); // Debugging

      if (userDoc.exists) {
        // Navigate to the home screen
        Navigator.pop(context); // Close the loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        // Navigate to the profile creation screen
        Navigator.pop(context); // Close the loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FormScreen()),
        );
      }
    } else {
      // User is null
      setState(() {
        _formError = 'Failed to retrieve user information.';
      });
      Navigator.pop(context); // Close the loading dialog
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context); // Close the loading dialog

    String errorMessage = 'An error occurred. Please try again.';
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password provided.';
    }
    setState(() {
      _formError = errorMessage;
    });
    print('FirebaseAuthException: ${e.message}'); // Debugging
  } catch (e) {
    Navigator.pop(context); // Close the loading dialog
    setState(() {
      _formError = 'An unexpected error occurred: $e';
    });
    print('Unexpected error: $e'); // Debugging
  }
}


  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  //Reset password feature

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _formError = 'Please enter your email to reset the password.';
      });
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message = 'Password reset email sent! Please check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
      });
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
              Row( mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                            onPressed: () {
                              Navigator.push(
                    context, MaterialPageRoute(builder: (context) => WelcomePage()));
                            },
                            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 18,),
                          ),
                ],
              ),
             
              ImageFlipper(),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 39,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 290,
                      height: 37,
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 290,
                      height: 37,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:_resetPassword ,
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryColor,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        )
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _signInWithFirebase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: SizedBox(
                          width: 100,
                          height: 20,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "Log in",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                     if (_formError.isNotEmpty)
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          _formError,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12),
                        ),
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
