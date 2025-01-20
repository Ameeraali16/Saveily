import 'package:flutter/material.dart';
import 'package:saveily_2/screens/auth/form.dart';
import 'package:saveily_2/screens/auth/welcomePage.dart';
import 'package:saveily_2/theme/color.dart';
import 'package:saveily_2/theme/image_flipper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saveily_2/widgets/passwordFields.dart';
import 'package:saveily_2/widgets/policyBottomSheet.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _termsAccepted = false;
  String _passwordError = '';
  String _formError = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateAndSignUp() async {
  setState(() {
    _formError = '';  // Clear previous error messages
  });

  // Check if all fields are filled
  if (_emailController.text.isEmpty ||
      _passwordController.text.isEmpty ||
      _confirmPasswordController.text.isEmpty ||
      !_termsAccepted) {
    setState(() {
      _formError = 'Please fill all fields and accept terms.';
    });
    return;
  }

  // Check if email format is valid
  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  if (!emailRegex.hasMatch(_emailController.text)) {
    setState(() {
      _formError = 'Please enter a valid email address.';
    });
    return;
  }

  // Check if passwords match
  if (_passwordController.text != _confirmPasswordController.text) {
    setState(() {
      _formError = 'Passwords do not match.';
    });
    return;
  }

  // Proceed to Firebase signup
  await _signUpWithFirebase();
}

  Future<void> _signUpWithFirebase() async {
    // Show loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pop(context); // Close loading circle

      // Navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FormScreen()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close loading circle

     
      if (e.code == 'weak-password') {
        _formError = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        _formError = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        _formError = 'The email address is not valid.';
      } else {
       _formError = 'An unexpected error occurred: ${e.message}';
      }
 setState(() {
      _formError = _formError; // Update form error state
    });

     
    } catch (e) {
      Navigator.pop(context); // Close loading circle

     _formError = 'An error occurred. Please try again.';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomePage()));
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 18,
                    ),
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
                      'Register Free!',
                      style: TextStyle(
                        fontSize: 39,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const Text(
                      "Sign up",
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
                        child: PasswordFieldWithEyeToggle(
                            controller: _passwordController,
                            labelText: 'Password')
                      
                        ),
                    const SizedBox(height: 20),
                    SizedBox(
                        width: 290,
                        height: 37,
                        child: PasswordFieldWithEyeToggle(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm Password')
                      
                        ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value!;
                            });
                          },
                        ),
                        const Text(
                          "I have read terms and conditions",
                          style: TextStyle(
                            fontSize: 11,
                            color: primaryColor,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: _validateAndSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: SizedBox(
                          width: 100,
                          height: 20,
                          child: Center(
                            child: Text(
                              "Sign up",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_formError.isNotEmpty) const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _formError,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 29,
              ),
              const BottomLinks(),
            ],
          ),
        ),
      ),
    );
  }
}
