import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final String profileImageUrl;
  final String dateOfBirth; // Keeping it as a string for now
  final bool isChildAccount;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profileImageUrl,
    required this.dateOfBirth,
    required this.isChildAccount,
  });

  // Factory method to create a User object from Firestore data
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? 'lib/assets/defaultpfp.png',
      dateOfBirth: data['dateOfBirth'] ?? '',
      isChildAccount: data['isChildAccount'] ?? false,
    );
  }

  // Method to convert a User object to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth,
      'isChildAccount': isChildAccount,
    };
  }
}
