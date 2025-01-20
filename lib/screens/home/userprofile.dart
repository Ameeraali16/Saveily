import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:saveily_2/bloc/account_bloc.dart';
import 'package:saveily_2/screens/auth/welcomePage.dart';
import 'package:saveily_2/theme/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}


class _UserProfileState extends State<UserProfile> {

    void didChangeDependencies() {
    super.didChangeDependencies();
   
    context.read<AccountBloc>().add(LoadAccount());
  } 


  File? _imageFile;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String initialFirstName = '';
  String initialLastName = '';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  void _copyEmail(String email) {
    Clipboard.setData(ClipboardData(text: email)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email copied to clipboard')),
      );
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()), // Navigate to WelcomePage
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
Future<void> _saveChanges(String userEmail) async {
  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();

  // Check if any of the fields were changed
  if (firstName != initialFirstName || lastName != initialLastName) {
    // Display success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Center(child: Text('Changes saved successfully!'
        ,style: TextStyle(
          color: Colors.black
        ),)),backgroundColor: bgColor,),
    );

    try {
      // Query the Firestore collection 'users' to find the document with the matching email
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If the document exists, update it
        final userDoc = querySnapshot.docs.first; // Get the first document (assuming emails are unique)
        
        await userDoc.reference.update({
          'firstName': firstName,
          'lastName': lastName,
        });
      } else {
        // Document with the given email not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User document not found')),
        );
      }
    } catch (e) {
      // Catch any errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving changes')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: bgColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountError) {
            return Center(child: Text('Error: ${state.error}'));
          }
      if (state is AccountLoaded) {
  final userData = state.user;
  final email = userData['email'] ?? '';
  final imageUrl = userData['imageUrl'];

  // Initialize names with null checks
  initialFirstName = userData['firstName'] ?? '';
  initialLastName = userData['lastName'] ?? '';

  _firstNameController.text = initialFirstName;
  _lastNameController.text = initialLastName;
  return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : imageUrl != null && imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl) as ImageProvider
                                : const AssetImage('lib/assets/defaultpfp.png') as ImageProvider,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyEmail(email),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    onPressed: () => _saveChanges(email),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
