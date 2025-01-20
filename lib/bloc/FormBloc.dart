// form_event.dart
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ProfileFormEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateFirstName extends ProfileFormEvent {
  final String firstName;
  UpdateFirstName(this.firstName);
  @override
  List<Object> get props => [firstName];
}

class UpdateLastName extends ProfileFormEvent {
  final String lastName;
  UpdateLastName(this.lastName);
  @override
  List<Object> get props => [lastName];
}

class UpdateDateOfBirth extends ProfileFormEvent {
  final DateTime dateOfBirth;
  UpdateDateOfBirth(this.dateOfBirth);
  @override
  List<Object> get props => [dateOfBirth];
}

class UpdateChildAccount extends ProfileFormEvent {
  final bool isChildAccount;
  UpdateChildAccount(this.isChildAccount);
  @override
  List<Object> get props => [isChildAccount];
}

class UpdateProfileImage extends ProfileFormEvent {
  final File image;
  UpdateProfileImage(this.image);
  @override
  List<Object> get props => [image];
}

class SaveProfile extends ProfileFormEvent {}

// form_state.dart
class ProfileFormState extends Equatable {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final bool isChildAccount;
  final File? profileImage;
  final String? error;
  final bool isLoading;
  final bool isSuccess;

  const ProfileFormState({
    this.firstName = '',
    this.lastName = '',
    required this.dateOfBirth,
    this.isChildAccount = false,
    this.profileImage,
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  ProfileFormState copyWith({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    bool? isChildAccount,
    File? profileImage,
    String? error,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return ProfileFormState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isChildAccount: isChildAccount ?? this.isChildAccount,
      profileImage: profileImage ?? this.profileImage,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        dateOfBirth,
        isChildAccount,
        profileImage,
        error,
        isLoading,
        isSuccess,
      ];
}

// form_bloc.dart


class ProfileFormBloc extends Bloc<ProfileFormEvent, ProfileFormState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileFormBloc({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore,
        super(ProfileFormState(dateOfBirth: DateTime.now())) {
    on<UpdateFirstName>(_onUpdateFirstName);
    on<UpdateLastName>(_onUpdateLastName);
    on<UpdateDateOfBirth>(_onUpdateDateOfBirth);
    on<UpdateChildAccount>(_onUpdateChildAccount);
    on<UpdateProfileImage>(_onUpdateProfileImage);
    on<SaveProfile>(_onSaveProfile);
  }

  void _onUpdateFirstName(UpdateFirstName event, Emitter<ProfileFormState> emit) {
    emit(state.copyWith(firstName: event.firstName));
  }

  void _onUpdateLastName(UpdateLastName event, Emitter<ProfileFormState> emit) {
    emit(state.copyWith(lastName: event.lastName));
  }

  void _onUpdateDateOfBirth(UpdateDateOfBirth event, Emitter<ProfileFormState> emit) {
    emit(state.copyWith(dateOfBirth: event.dateOfBirth));
  }

  void _onUpdateChildAccount(UpdateChildAccount event, Emitter<ProfileFormState> emit) {
    emit(state.copyWith(isChildAccount: event.isChildAccount));
  }

  void _onUpdateProfileImage(UpdateProfileImage event, Emitter<ProfileFormState> emit) {
    emit(state.copyWith(profileImage: event.image));
  }

  Future<void> _onSaveProfile(SaveProfile event, Emitter<ProfileFormState> emit) async {
    if (!_validateInputs()) {
      emit(state.copyWith(error: 'Please fill in all fields.'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'No user logged in.',
        ));
        return;
      }

      String profileImageUrl = state.profileImage != null
          ? 'uploaded_image_url' // Replace with actual upload logic
          : 'lib/assets/defaultpfp.png';

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'firstName': state.firstName,
        'lastName': state.lastName,
        'dateOfBirth': state.dateOfBirth.toIso8601String(),
        'isChildAccount': state.isChildAccount,
        'profileImageUrl': profileImageUrl,
      });

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error saving profile: $e',
      ));
    }
  }

  bool _validateInputs() {
    return state.firstName.isNotEmpty && state.lastName.isNotEmpty;
  }
}