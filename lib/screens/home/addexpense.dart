import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<String> _categories = ['Food', 'Entertainment', 'Shopping', 'Travel'];

  // Submit Expense Logic
  void _submitExpense() async {
    final expense = _expenseController.text;
    final note = _noteController.text;
    final category = _selectedCategory ?? 'Uncategorized';
    final date = _selectedDate ?? DateTime.now();

    // Get current user
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      _showErrorDialog('No user is currently signed in.');
      return;
    }

    final String email = currentUser.email!;
    DocumentReference? userDoc;

    // Find user account in tracking collection
    final account = FirebaseFirestore.instance.collection('tracking');
    QuerySnapshot adminSnapshot = await account
        .where('adminEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (adminSnapshot.docs.isNotEmpty) {
      userDoc = adminSnapshot.docs.first.reference;
    } else {
      QuerySnapshot allAccountsSnapshot = await account.get();
      for (var doc in allAccountsSnapshot.docs) {
        List<dynamic>? userEmails = doc['userEmails'] as List<dynamic>?;
        if (userEmails != null && userEmails.contains(email)) {
          userDoc = doc.reference;
          break;
        }
      }
    }

    if (userDoc == null) {
      _showErrorDialog('No account found for this user.');
      return;
    }

    // Add expense to Firestore
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
      _showSuccessDialog(expense, category, note, date);
      _clearFields();
    } catch (e) {
      _showErrorDialog('Failed to add expense: $e');
    }
  }

  // Error dialog
  void _showErrorDialog(String message) {
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

  // Success dialog
  void _showSuccessDialog(String expense, String category, String note, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text('Expense Added'),
        content: Text(
          'Expense: $expense\nCategory: $category\nNote: $note\nDate: ${date.toLocal().toString().split(' ')[0]}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Clear input fields after submission
  void _clearFields() {
    setState(() {
      _expenseController.clear();
      _noteController.clear();
      _selectedCategory = null;
      _selectedDate = null;
    });
  }

  // Category dropdown
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        
        value: _selectedCategory,
        hint: const Text('Select Category'),
        items: _categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList()
          ..add(const DropdownMenuItem<String>(
            value: 'Add New Category',
            child: Text('Add New Category'),
          )),
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
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
        dropdownColor: bgColor,
      ),
    );
  }

  // Add new category dialog
  void _showAddCategoryDialog() {
    final TextEditingController _newCategoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text('Add New Category'),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(hintText: 'Enter category name'),
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

  // Date picker
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

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Add Expenses',
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              _buildExpenseTextField(),
              _buildCategoryDropdown(),
          
              _buildDatePicker(),
              SizedBox(height: 15,),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Expense text field
  Widget _buildExpenseTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: _expenseController,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          labelText: 'Enter Expense',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
         inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Allows only digits
      ],
      ),
    );
  }

 

  // Date picker display
  Widget _buildDatePicker() {
    return Row(
      children: [
        SizedBox(width: 2,),
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
    );
  }

  // Submit button
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor
        ),
        onPressed: _submitExpense,
        child: const Text('Save',
        style: TextStyle(
          color: Colors.white
        ),),
      ),
    );
  }
}
