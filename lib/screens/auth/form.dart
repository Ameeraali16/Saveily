import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saveily_2/bloc/FormBloc.dart';
import 'package:saveily_2/screens/auth/searchAccount.dart';
import 'package:saveily_2/screens/auth/stepperform.dart';
import 'package:saveily_2/theme/color.dart';

class FormScreen extends StatelessWidget {
  const FormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  const FormScreenContent();
   
  }
}

class FormScreenContent extends StatelessWidget {
  const FormScreenContent({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      context.read<ProfileFormBloc>().add(UpdateProfileImage(File(pickedFile.path)));
    }
  }

  void _showDatePicker(BuildContext context) {
    final maximumAllowedYear = 2019;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: 

                CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: context.read<ProfileFormBloc>().state.dateOfBirth.isAfter(DateTime(maximumAllowedYear, 12, 31))
                      ? DateTime(maximumAllowedYear, 12, 31)  
                      : context.read<ProfileFormBloc>().state.dateOfBirth,
                  minimumYear: 1970,
                  maximumYear: maximumAllowedYear,
                  onDateTimeChanged: (DateTime date) {
                    context.read<ProfileFormBloc>().add(UpdateDateOfBirth(date));
                  },
                ),

              ),
              CupertinoButton(
                child: const Text("Done"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              "Let's Set Up Your Profile..",
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<ProfileFormBloc, ProfileFormState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Navigate based on child account status
            if (state.isChildAccount) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchAccountPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Stepperform()),
              );
            }
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(context),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: state.profileImage != null
                                  ? FileImage(state.profileImage!)
                                  : const AssetImage('lib/assets/defaultpfp.png') as ImageProvider,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Edit picture',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: TextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // First Name
                    SizedBox(
                      width: 290,
                      height: 50,
                      child: TextField(
                        onChanged: (value) => context.read<ProfileFormBloc>().add(UpdateFirstName(value)),
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Last Name
                    SizedBox(
                      width: 290,
                      height: 50,
                      child: TextField(
                        onChanged: (value) => context.read<ProfileFormBloc>().add(UpdateLastName(value)),
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date of Birth
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Date of Birth:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => _showDatePicker(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              "${state.dateOfBirth.toLocal()}".split(' ')[0],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Child Account Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Enable Child Account:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Tooltip(
                              message: "Enable this if the user is a child and should have restricted access.",
                              child: IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {},
                                iconSize: 15,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        CupertinoSwitch(
                          value: state.isChildAccount,
                          onChanged: (value) => context.read<ProfileFormBloc>().add(UpdateChildAccount(value)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Join Account Button
                        SizedBox(
                          width: 290,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => context.read<ProfileFormBloc>().add(SaveProfile()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "I want to join a tracking account..",
                              style: TextStyle(fontFamily: 'Roboto', color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Set Up Account Button
                       // Set Up Account Button
                        SizedBox(
                          width: 290,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.isChildAccount
                                ? null
                                : () => context.read<ProfileFormBloc>().add(SaveProfile()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isChildAccount ? Colors.grey : primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "I want to set up a tracking account..",
                              style: TextStyle(fontFamily: 'Roboto', color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Error Message
                    if (state.error != null) ...[
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}