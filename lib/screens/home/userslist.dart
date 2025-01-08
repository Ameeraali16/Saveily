import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saveily_2/functions/functions.dart';
import 'package:saveily_2/theme/color.dart';

void main() {
  runApp(MaterialApp(
    home: UserListScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;

  List<Map<String, dynamic>> _filteredUsers = [];
  String adminEmail = '';
  List<String> userEmails = [];
  bool isChildAccount = false;  // Added variable to track child account status

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
    _loadUserData();  // New method to load user data
  }

  // New method to load user data including child account status
  Future<void> _loadUserData() async {
    // Fetch account document
    final document = await fetchAccountDocument(_currentUser.email!);
    if (document != null) {
      setState(() {
        adminEmail = document['adminEmail'] ?? '';
        userEmails = List<String>.from(document['userEmails'] ?? []);
      });
    }

    // Fetch user document to check isChildAccount status
    try {
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: _currentUser.email)
          .get();
      
      if (userDoc.docs.isNotEmpty) {
        setState(() {
          isChildAccount = userDoc.docs.first.data()['isChildAccount'] ?? false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchUsers() async {
    if (isChildAccount) return;  // Don't fetch if child account

    String searchQuery = _searchController.text.trim();

    if (searchQuery.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: searchQuery)
            .get();

        List<Map<String, dynamic>> users = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {
          _filteredUsers = users;
        });
      } catch (e) {
        print('Error fetching users: $e');
      }
    }
  }

  Future<void> _addUserToTracking(Map<String, dynamic> user) async {
    if (isChildAccount) return;  // Don't allow adding if child account

    final document = await fetchAccountDocument(_currentUser.email!);
    if (document != null) {
      String encodedAdminEmail = document['adminEmail'];
      final trackingCollection = FirebaseFirestore.instance.collection('tracking');

      final querySnapshot = await trackingCollection
          .where('adminEmail', isEqualTo: encodedAdminEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docSnapshot = querySnapshot.docs.first;
        List<dynamic> currentUserEmails = List.from(docSnapshot['userEmails'] ?? []);

        if (!currentUserEmails.contains(user['email'])) {
          currentUserEmails.add(user['email']);

          await docSnapshot.reference.update({
            'userEmails': currentUserEmails,
          });

          fetchAccountDocument(_currentUser.email!).then((updatedDocument) {
            setState(() {
              if (updatedDocument != null) {
                userEmails = List<String>.from(updatedDocument['userEmails'] ?? []);
              }
            });
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['email']} added to your tracking list')),
          );

          _searchController.clear();
          setState(() {
            _filteredUsers = [];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user['email']} is already in the list')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tracking document not found for the given admin email')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Account Members'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              enabled: !isChildAccount,  // Disable TextField if child account
              decoration: InputDecoration(
                hintText: isChildAccount 
                    ? 'Search disabled for child accounts' 
                    : 'Search users by email...',
                prefixIcon: Icon(
                  Icons.search,
                  color: isChildAccount ? Colors.grey : null,  // Grey out icon if disabled
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: isChildAccount ? Colors.grey[300] : Colors.grey[100],  // Darker background if disabled
              ),
              onChanged: (value) => fetchUsers(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Admin Email'),
                  subtitle: Text(adminEmail),
                ),
                const SizedBox(height: 8),
                const Text('User Emails:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...userEmails.map((email) => ListTile(
                      title: Text(email),
                    )),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(user['avatar'] ?? 'lib/assets/defaultpfp.png'),
                    ),
                    title: Text(user['firstName'] ?? 'Unknown'),
                    subtitle: Text(user['email'] ?? 'No Email'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: isChildAccount ? null : () => _addUserToTracking(user),  // Disable button if child account
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}