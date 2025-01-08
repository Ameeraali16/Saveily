import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference account =
      FirebaseFirestore.instance.collection('tracking');

Future<Map<String, dynamic>?> fetchAccountDocument(String email) async {
  // Fetch the account document by adminEmail
  QuerySnapshot accountSnapshot = await account
      .where('adminEmail', isEqualTo: email)
      .limit(1)
      .get();

  if (accountSnapshot.docs.isNotEmpty) {
    return accountSnapshot.docs.first.data() as Map<String, dynamic>;
  }

  // If not found, loop through all accounts and check userEmails list
  QuerySnapshot allAccountsSnapshot = await account.get();

  for (var doc in allAccountsSnapshot.docs) {
    List<dynamic>? userEmails = doc['userEmails'] as List<dynamic>?;
    if (userEmails != null && userEmails.contains(email)) {
      return doc.data() as Map<String, dynamic>;
    }
  }

  return null; // No matching document found
}


// Function to calculate total expense
String calculateTotalExpense(List<Map<String, dynamic>> expenses) {
  double totalExpense = 0.0;

  for (var expense in expenses) {
    final expenseValue = expense['expense'] ?? '0'; // Default to '0' if no value found

    // Ensure that the expense is a valid number, convert it to double
    if (expenseValue is String) {
      totalExpense += double.tryParse(expenseValue) ?? 0.0;
    } else if (expenseValue is num) {
      totalExpense += expenseValue.toDouble();
    }
  }

  return totalExpense.toStringAsFixed(2); // Returning as string with 2 decimal places
}

// Function to calculate and return the total expense and updated balance
String calculateUpdatedBalance(String currentBalanceStr, List<Map<String, dynamic>> expenses) {
  // Calculate the total expense
  final totalExpenseStr = calculateTotalExpense(expenses);
  final totalExpense = double.tryParse(totalExpenseStr) ?? 0.0;

  // Retrieve the current balance (ensure it's a number and not empty)
  final double currentBalance = double.tryParse(currentBalanceStr) ?? 0.0;

  // Subtract the total expense from the current balance to get the updated balance
  final double updatedBalance = currentBalance - totalExpense;

  // Return both the total expense and the updated balance as strings
  return updatedBalance.toStringAsFixed(2);
}
