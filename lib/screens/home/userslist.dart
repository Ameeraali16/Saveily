import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saveily_2/functions/functions.dart';
import 'package:saveily_2/theme/color.dart';



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
      body: Padding(
        padding: const EdgeInsets.all(16.0), 
        child: Column(
          children: [
           // Conditionally show the search field
          if (!isChildAccount)
            TextField(
              controller: _searchController,
              enabled: !isChildAccount,
              decoration: InputDecoration(
                hintText: isChildAccount
                    ? 'Search disabled for child accounts'
                    : 'Search users by email...',
                prefixIcon: Icon(
                  Icons.search,
                  color: isChildAccount ? Colors.grey : null,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: isChildAccount ? Colors.grey[300] : Colors.grey[100],
              ),
              onChanged: (value) => fetchUsers(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Card(
                elevation: 4,
margin: const EdgeInsets.only(bottom: 16.0),
child: Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryColor, Colors.blue], // Choose your gradient colors here
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(10), // Optional: for rounded corners
  ),
  child: ListTile(
    leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
    title: const Text('Admin Email', style: TextStyle(color: Colors.white)),
    subtitle: Text(adminEmail, style: const TextStyle(color: Colors.white)),
  ),
),
                  ),
                  const SizedBox(height: 8),
                  const Text('User Emails:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...userEmails.map((email) => Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.green),
                          title: Text(email, style: const TextStyle(color: Colors.black87)),
                        ),
                      )),
                  if (_filteredUsers.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        'Search Results',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ..._filteredUsers.map((user) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                           decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryColor, Colors.blue], // Choose your gradient colors here
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(10), // Optional: for rounded corners
  ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                  user['avatar'] ?? 'lib/assets/defaultpfp.png'),
                            ),
                            
                            title: Text(user['firstName'] ?? 'Unknown',style: TextStyle(color: Colors.white),),
                            subtitle: Text(user['email'] ?? 'No Email',style: TextStyle(color: Colors.white),),
                            trailing: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: isChildAccount ? null : () => _addUserToTracking(user),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}