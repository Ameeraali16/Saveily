import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saveily_2/screens/auth/searchAccount.dart';
import 'package:saveily_2/screens/auth/stepperform.dart';
import 'package:saveily_2/theme/color.dart';


void main() {
  runApp(const MaterialApp(
    home: FormScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // Initialize controllers
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  DateTime _selectedDate = DateTime.now(); // Track the selected date
  bool _isChildAccount = false; // Track the slider state
  File? _profileImage;

   // Firebase instance for Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
@override
void initState() {
  super.initState();
  _printCurrentUser(); // Call the function to print the current user
}

void _printCurrentUser() {
  final user = _auth.currentUser;
  if (user != null) {
    print('Current User: ${user.email}');
  } else {
    print('No user is currently logged in.');
  }
}

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedDate,
                  minimumYear: 1970,
                  maximumYear: DateTime.now().year,
                  onDateTimeChanged: (DateTime date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: const Text("Done"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


   Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }


Future<bool> _saveUserProfile() async {
  if (!_validateInputs()) {
    return false; // Validation failed
  }

  // Show a loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Retrieve the current logged-in user's email
    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.of(context).pop(); // Close loading dialog
      return false; // User is not logged in
    }

    // Set default profile image if not selected
    String profileImageUrl = '';
    if (_profileImage != null) {
      // Upload image to Firebase Storage and get the URL
      // Example: profileImageUrl = await uploadProfileImage(_profileImage);
      profileImageUrl = 'uploaded_image_url'; // Replace with actual uploaded URL
    } else {
      profileImageUrl = 'lib/assets/defaultpfp.png'; // Default image
    }

    // Prepare the user data to store in Firestore
    Map<String, dynamic> userData = {
      'email': user.email,
      'firstName': _firstnameController.text,
      'lastName': _lastnameController.text,
      'dateOfBirth': _selectedDate.toIso8601String(),
      'isChildAccount': _isChildAccount,
      'profileImageUrl': profileImageUrl,
    };

    // Store the user data in Firestore
    await _firestore.collection('users').doc(user.uid).set(userData);

    Navigator.of(context).pop(); // Close loading dialog
    return true; // Successfully saved the profile
  } catch (e) {
    // Handle any errors
    Navigator.of(context).pop(); // Close loading dialog
    print('Error saving user profile: $e');
    return false; // Operation failed
  }
}


String _formError = '';

bool _validateInputs() {
    setState(() {
      _formError = ''; // Reset error message
    });

    if (_firstnameController.text.isEmpty || _lastnameController.text.isEmpty || _selectedDate == null) {
      setState(() {
        _formError = 'Please fill in all fields.';
      });
      return false;
    }
    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
     appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: const Text(
              "Let's Set Up Your Profile..",
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
     // backgroundColor: SecondaryColor,
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1), // Shadow color with opacity
        spreadRadius: 2, // How much the shadow spreads
        blurRadius: 5, // How blurry the shadow is
        offset: Offset(0, 4), // The shadow's position (x, y)
      ),]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                 
                
                   Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                           backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage('lib/assets/defaultpfp.png') as ImageProvider,
                          child: _profileImage == null
                              ? null
                              : null,
                        ),
                      ),
SizedBox(height: 5,),
                       Text(
                    'Edit picture',
                    style: TextStyle(
                        fontFamily: 'Roboto',
                        color: TextColor,
                        fontSize: 12
                    ),
                  ),
                    ],
                  ),
                ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 290,
                    height: 50,
                    child: TextField(
                      controller: _firstnameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 290,
                    height: 50,
                    child: TextField(
                      controller: _lastnameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Date of Birth:",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "${_selectedDate.toLocal()}"
                                .split(' ')[0], // Display the date
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Enable Child Account:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Tooltip(
                            message:
                                "Enable this if the user is a child and should have restricted access.",
                            child: IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () {},
                              iconSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      CupertinoSwitch(
                        value: _isChildAccount,
                        onChanged: (bool value) {
                          setState(() {
                            _isChildAccount = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 290,
                        height: 50,
                        child: ElevatedButton(
  onPressed: () async {
    try {
      bool success = await _saveUserProfile(); // Attempt to save user profile
      if (success) {
        // Action for "Join an Account"
        // Navigate to the search accounts page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchAccountPage()),
        );
      }
    } catch (e) {
      setState(() {
        _formError = 'An unexpected error occurred: $e';
      });
    }
  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "I want to join a tracking account..",
                            style: TextStyle(
                                fontFamily: 'Roboto', color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),


                      SizedBox(
                        width: 290,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isChildAccount
                              ? null // Disable if child account is enabled
                              : () async {
          try {
            bool success = await _saveUserProfile(); // Attempt to save user profile
            if (success) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Stepperform(), // Replace with your actual page
                ),
              );
            }
          } catch (e) {
            _formError ='An unexpected error occurred: $e';
          };

                              },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isChildAccount
                                ? Colors.grey
                                : primaryColor, // Gray out if disabled
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "I want to set up a tracking account..",
                            style: TextStyle(
                                fontFamily: 'Roboto', color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
          ),
        ),
    
    );
  }
}
