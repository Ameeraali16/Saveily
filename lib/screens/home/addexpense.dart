import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saveily_2/screens/home/homepage.dart';
import 'package:saveily_2/theme/color.dart';

void main() {
  runApp(const MaterialApp(
    home: Addexpense(),
    debugShowCheckedModeBanner: false,
  ));
}

class Addexpense extends StatefulWidget {
  const Addexpense({super.key});

  @override
  State<Addexpense> createState() => _AddexpenseState();
}

class _AddexpenseState extends State<Addexpense> {
  final _expenseController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  List<String> _categories = [
    'Food',
    'Entertainment',
    'Shopping',
    'Travel',
  ];


//Logic

void _submitExpense() async {
  final expense = _expenseController.text;
  final note = _noteController.text;
  final category = _selectedCategory ?? 'Uncategorized';
  final date = _selectedDate ?? DateTime.now();

  // Get the current user
  final User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('No user is currently signed in.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  final String email = currentUser.email!;
  print("Current user email: $email");

  // Initialize variables to store the document reference
  DocumentReference? userDoc;
  
  // First try to find account by adminEmail
  final account = FirebaseFirestore.instance.collection('tracking');
  QuerySnapshot adminSnapshot = await account
      .where('adminEmail', isEqualTo: email)
      .limit(1)
      .get();

  if (adminSnapshot.docs.isNotEmpty) {
    userDoc = adminSnapshot.docs.first.reference;
  } else {
    // If not found as admin, search in userEmails array
    QuerySnapshot allAccountsSnapshot = await account.get();
    for (var doc in allAccountsSnapshot.docs) {
      List<dynamic>? userEmails = doc['userEmails'] as List<dynamic>?;
      print("Checking userEmails: $userEmails");
      if (userEmails != null && userEmails.contains(email)) {
        userDoc = doc.reference;
        print("Found account with userEmail in the list.");
        break;
      }
    }
  }

  if (userDoc == null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('No account found for this user.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  // Create the new expense
  Map<String, dynamic> newExpense = {
    'expense': expense,
    'note': note,
    'category': category,
    'date': date,
    'userEmail': email,
  };

  try {
    await userDoc.update({
      'expenses': FieldValue.arrayUnion([newExpense]),
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expense Added'),
        content: Text(
          'Expense: $expense\n'
          'Category: $category\n'
          'Note: $note\n'
          'Date: ${date.toLocal().toString().split(' ')[0]}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    setState(() {
      _expenseController.clear();
      _noteController.clear();
      _selectedCategory = null;
      _selectedDate = null;
    });
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to add expense: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title:  Text(
                  'Add Expenses',
                  style: TextStyle(color: Colors.black, fontSize: 25),
                ),
        backgroundColor: bgColor,
         leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to MainScreen when back button is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                SizedBox(height: 12,),

                // Add Expense TextField
              TextField(
  controller: _expenseController,
  decoration: InputDecoration(
    fillColor: Colors.white,
    filled: true,
    labelText: 'Enter Expense',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0), // Adjust the value to make the corners as round as needed
      borderSide: BorderSide.none, // Removes the border color
    ),
    contentPadding: const EdgeInsets.all(20), // Center vertically
    alignLabelWithHint: true, // Aligns label with the center
  ),
  textAlign: TextAlign.center,
  keyboardType: TextInputType.number,
),

                const SizedBox(height: 20),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('Select Category'),
                  items: [
                    ..._categories.map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                    const DropdownMenuItem<String>(
                      value: 'Add New Category',
                      child: Text('Add New Category'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue == 'Add New Category') {
                      _showAddCategoryDialog();
                    } else {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                     filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0), // Adjust the value to make the corners as round as needed
      borderSide: BorderSide.none,
                    ),
                   // labelText: 'Category',
                  ),
                ),
                const SizedBox(height: 20),

                // Note TextField
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                     filled: true,
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(
borderRadius: BorderRadius.circular(12.0), // Adjust the value to make the corners as round as needed
      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // Date Picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? 'Selected Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                            : 'No Date Selected. Using Today\'s Date.',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitExpense,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController _newCategoryController =
        TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(
            hintText: 'Enter category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newCategoryController.text.isNotEmpty) {
                setState(() {
                  _categories.add(_newCategoryController.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    setState(() {
      _selectedDate = pickedDate ?? DateTime.now();
    });
  }
}
