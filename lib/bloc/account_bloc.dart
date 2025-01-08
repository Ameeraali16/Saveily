import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final CollectionReference account =
      FirebaseFirestore.instance.collection('tracking');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  AccountBloc() : super(AccountInitial()) {
    on<LoadAccount>((event, emit) async {
      try {
        // Get the current user
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          emit(AccountError("No user is currently signed in."));
          return;
        }

        final String email = currentUser.email!;

        // Fetch account document where email matches
        QuerySnapshot accountSnapshot = await account
            .where('adminEmail', isEqualTo: email)
            .limit(1) // Get only the first matching document
            .get();

        Map<String, dynamic>? accountData;

        if (accountSnapshot.docs.isNotEmpty) {
          // If a document is found in 'email' field, use it
          accountData = accountSnapshot.docs.first.data() as Map<String, dynamic>;
        } else {
          // If no document is found, check the 'userEmails' list in each document
          QuerySnapshot allAccountsSnapshot = await account.get();

          for (var doc in allAccountsSnapshot.docs) {
            List<dynamic>? userEmails = doc['userEmails'] as List<dynamic>?;

            if (userEmails != null && userEmails.contains(email)) {
              accountData = doc.data() as Map<String, dynamic>;
              break; // Stop the loop once the document is found
            }
          }
        }

        if (accountData == null) {
          emit(AccountError("No account found for this user."));
          return;
        }

        // Fetch user data
        QuerySnapshot userSnapshot = await users
            .where('email', isEqualTo: email)
            .limit(1) // Get only the first matching document
            .get();

        if (userSnapshot.docs.isEmpty) {
          emit(AccountError("No user information found for this user."));
          return;
        }

        final Map<String, dynamic> userData =
            userSnapshot.docs.first.data() as Map<String, dynamic>;

        // Emit a state with both account and user data
        emit(AccountLoaded(account: accountData, user: userData));
      } catch (e) {
        emit(AccountError(e.toString()));
      }
    });






  on<UpdateUser>((event, emit) async {
      try {
        // Get the current user
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          emit(AccountError("No user is currently signed in."));
          return;
        }

        final String email = currentUser.email!;

        // Locate the user's document in the 'users' collection
        QuerySnapshot userSnapshot = await users
            .where('email', isEqualTo: email)
            .limit(1) // Get only the first matching document
            .get();

        if (userSnapshot.docs.isEmpty) {
          emit(AccountError("User document not found."));
          return;
        }







        // Update the user's document
        DocumentReference userDocRef = userSnapshot.docs.first.reference;

        await userDocRef.update({
          'firstName': event.firstName,
          'lastName': event.lastName,
          'income': event.income,
        });

        emit(UserUpdatedSuccessfully());
      } catch (e) {
        emit(AccountError(e.toString()));
      }
    });

     on<AddExpense>((event, emit) async {
      try {
        // Get the currently logged-in user's email
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          emit(AccountError("No user is currently signed in."));
          return;
        }

        final String email = currentUser.email!;

        // Locate the account document where the user is an admin or part of userEmails
        QuerySnapshot accountSnapshot = await account
            .where('admin', isEqualTo: email)
            .get();

        DocumentReference? accountDocRef;

        if (accountSnapshot.docs.isNotEmpty) {
          accountDocRef = accountSnapshot.docs.first.reference;
        } else {
          // Check if the user's email is in the userEmails list
          QuerySnapshot allAccountsSnapshot = await account.get();

          for (var doc in allAccountsSnapshot.docs) {
            List<dynamic>? userEmails = doc['userEmails'] as List<dynamic>?;

            if (userEmails != null && userEmails.contains(email)) {
              accountDocRef = doc.reference;
              break; // Stop the loop once the account is found
            }
          }
        }

        if (accountDocRef == null) {
          emit(AccountError("No account found for the current user."));
          return;
        }

        // Add the expense to the account's expenses array
        await accountDocRef.update({
          'expenses': FieldValue.arrayUnion([
            {
              'category': event.category,
              'note': event.note,
              'spent': event.spent,
              'addedBy': email,
              'timestamp': FieldValue.serverTimestamp(),
            }
          ])
        });

        emit(ExpenseAddedSuccessfully());
      } catch (e) {
        emit(AccountError(e.toString()));
      }
    });
  }
}
  




