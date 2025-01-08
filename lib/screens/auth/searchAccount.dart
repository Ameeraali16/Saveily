import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saveily_2/screens/home/homepage.dart';
import 'package:saveily_2/theme/color.dart';

class SearchAccountPage extends StatefulWidget {
  @override
  _SearchAccountPageState createState() => _SearchAccountPageState();
}

class _SearchAccountPageState extends State<SearchAccountPage> {
  TextEditingController searchController = TextEditingController();
  String searchEmail = "";
  List<DocumentSnapshot> searchResults = [];

  // Fetching documents from Firebase based on the email entered
  void searchAccount() async {
    if (searchEmail.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tracking')
        .where('adminEmail', isEqualTo: searchEmail)
        .get();

    setState(() {
      searchResults = querySnapshot.docs;
    });
  }

  // Add the current user's email to the userEmails list and navigate
  void joinAccount(String documentId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('tracking')
          .doc(documentId);

      // Update the userEmails list in the document
      await docRef.update({
        'userEmails': FieldValue.arrayUnion([currentUser.email])
      });

      // Navigate to MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: true,
        title: Text('Search Account')),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(labelText: 'Enter Admin Email'),
              onChanged: (value) {
                setState(() {
                  searchEmail = value;
                });
                searchAccount();
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  var document = searchResults[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text('Tracker ID: ${document.id}'),
                      subtitle: Text('Admin Email: ${document['adminEmail']}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          joinAccount(document.id);
                        },
                        child: Text('Join'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
