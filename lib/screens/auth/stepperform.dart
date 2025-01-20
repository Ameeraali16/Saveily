import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saveily_2/screens/home/homepage.dart';
import 'package:saveily_2/theme/color.dart';

class Stepperform extends StatefulWidget {
  const Stepperform({super.key});

  @override
  State<Stepperform> createState() => _StepperformState();
}

class _StepperformState extends State<Stepperform> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentStep = 0;
  TextEditingController incomeController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  bool notificationsEnabled = false;
  String selectedCurrency = 'PKR';
  String? incomeError;
  String? budgetError;

  List<Map<String, dynamic>> usersList = []; // List to hold users fetched
  List<Map<String, dynamic>> selectedUsers = []; // List to hold selected users

  final List<String> currencies = [
    'PKR',
  ];

  void addUserToSelected(Map<String, dynamic> user) {
    setState(() {
      selectedUsers.add(user); // Add the user to the selected list
    });
  }

  // 1. Method to fetch users from Firestore
  Future<void> fetchUsers() async {
    String searchQuery = searchController.text.trim();

    if (searchQuery.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: searchQuery)
            .get(); // Querying users based on the UID

        List<Map<String, dynamic>> users = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        setState(() {
          usersList = users; // Updating the list of users found
        });
      } catch (e) {
        print('Error fetching users: $e');
      }
    }
  }

  Future<void> saveTrackingInformation({
    required String adminEmail,
    required String income,
    required String balance,
    required bool enableNotifications,
    required List<Map<String, dynamic>> expenses,
    required List<String> userEmails,
  }) async {
    try {
      // Get the current user to associate with the tracking information
      User? user = FirebaseAuth.instance.currentUser;

       String adminEmail = FirebaseAuth.instance.currentUser?.email ?? 'unknown@example.com';
    
    // Retrieve income and balance data
    String income = incomeController.text;
    String balance = budgetController.text;

      if (user != null) {
        String userId = user.uid;

        // Prepare the data to be saved
        Map<String, dynamic> trackingData = {
          'adminEmail': adminEmail,
          'income': income,
          'balance': balance,
          'enableNotifications': enableNotifications,
          'expenses': expenses,
         'userEmails': selectedUsers.isNotEmpty
          ? selectedUsers.map((user) => user['email'] as String).toList()
          : [],
          'userId': userId, // Store the current user's UID as a reference
          'createdAt': Timestamp.now(),
        };

        // Save the tracking data to Firestore
        await FirebaseFirestore.instance
            .collection('tracking')
            .add(trackingData);
        print('Tracking information saved successfully.');
        
      } else {
        print('No user is currently logged in.');
      }
    } catch (e) {
      print('Error saving tracking information: $e');
    }
    
  }

  void finishSetup() async {
  try {
    // Get current user email
    String adminEmail = FirebaseAuth.instance.currentUser?.email ?? 'unknown@example.com';
    
    // Retrieve income and balance data
    String income = incomeController.text;
    String balance = budgetController.text;

    // Call the method to save tracking information
    await saveTrackingInformation(
      adminEmail: adminEmail,
      income: income,
      balance: balance,
      enableNotifications: notificationsEnabled,
      expenses: [], // Assuming no expenses are added yet
      userEmails: selectedUsers.isNotEmpty
          ? selectedUsers.map((user) => user['email'] as String).toList()
          : [],
    );

    // After successful tracking information saving, navigate to MainScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  } catch (e) {
    print('Error in finishSetup: $e');
  }
}


  void validateStepFields() {
    setState(() {
      if (_currentStep == 0) {
        incomeError =
            incomeController.text.isEmpty ? 'Please enter your income.' : null;
      } else if (_currentStep == 1) {
        budgetError = budgetController.text.isEmpty
            ? 'Please enter your current balance.'
            : null;
      }
    });
  }

  bool canProceedToNextStep() {
    if (_currentStep == 0 && incomeController.text.isEmpty) {
      return false;
    } else if (_currentStep == 1 && budgetController.text.isEmpty) {
      return false;
    }
    return true;
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
            child: FittedBox(
               fit: BoxFit.scaleDown,
              child: Text(
                "Let's set up your tracking account..",
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
      ),
      body: SingleChildScrollView(
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
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                    maxHeight: 500,
                  ),
                  child: Theme(
                    data: ThemeData(
                      canvasColor: Colors.white,
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: primaryColor,
                            secondary: SecondaryColor,
                          ),
                    ),
                    child: Stepper(
                      type: StepperType.horizontal,
                      steps: [
                        Step(
                          title: const Text(""),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "Enter Your House Income: ",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // TextField for income
                                  SizedBox(
                                    width:
                                        200, // Adjust width to avoid overflow
                                    height: 37,
                                    child: TextField(
                                      controller: incomeController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Income',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Currency label and dropdown
                                  // const Text("Currency:"),
                                  // SizedBox(
                                  //   width: 80, // Adjust width to ensure it fits
                                  //   height: 37,
                                  //   child: DropdownButtonFormField<String>(
                                  //     value: selectedCurrency,
                                  //     onChanged: (String? newValue) {
                                  //       setState(() {
                                  //         selectedCurrency = newValue!;
                                  //       });
                                  //     },
                                  //     items: currencies.map((String currency) {
                                  //       return DropdownMenuItem<String>(
                                  //         value: currency,
                                  //         child: Text(
                                  //           currency,
                                  //           style: const TextStyle(fontSize: 12),
                                  //         ),
                                  //       );
                                  //     }).toList(),
                                  //     decoration: InputDecoration(
                                  //       border: OutlineInputBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(15),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              if (incomeError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    incomeError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                          isActive: _currentStep >= 0,
                          state: _currentStep == 0
                              ? StepState.editing
                              : StepState.complete,
                        ),
                        //STEP 2

                        Step(
                          title: const Text(""),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "What Is Your Current Balance: ",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // TextField for income
                                  SizedBox(
                                    width:
                                        200, // Adjust width to avoid overflow
                                    height: 37,
                                    child: TextField(
                                      controller: budgetController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                      //  labelText: 'Saving Goal',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Currency label and dropdown
                                  // const Text("Currency:"),
                                  // SizedBox(
                                  //   width: 80, // Adjust width to ensure it fits
                                  //   height: 37,
                                  //   child: DropdownButtonFormField<String>(
                                  //     value: selectedCurrency,
                                  //     onChanged: (String? newValue) {
                                  //       setState(() {
                                  //         selectedCurrency = newValue!;
                                  //       });
                                  //     },
                                  //     items: currencies.map((String currency) {
                                  //       return DropdownMenuItem<String>(
                                  //         value: currency,
                                  //         child: Text(
                                  //           currency,
                                  //           style: const TextStyle(fontSize: 12),
                                  //         ),
                                  //       );
                                  //     }).toList(),
                                  //     decoration: InputDecoration(
                                  //       border: OutlineInputBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(15),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              if (budgetError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    budgetError!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                          isActive: _currentStep >= 1,
                          state: _currentStep == 1
                              ? StepState.editing
                              : StepState.complete,
                        ),

                        //STEP 3

                        Step(
                          title: const Text(""),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                'Search by email to add people',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              SizedBox(
                                width: 300,
                                height: 37,
                                child: TextField(
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    labelText: '*optional',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    fetchUsers();
                                  },
                                ),
                              ),

                              if (usersList.isNotEmpty) 
                  ...usersList.map((user) {
                    return ListTile(
                      title: Text(user['firstName'] ?? 'Unknown'),
                      subtitle: Text(user['email'] ?? 'No email'),
                      trailing: ElevatedButton(
                       onPressed: () {
      // Check if user is already in the selectedUsers list
      bool userExists = selectedUsers.any((selectedUser) => selectedUser['email'] == user['email']);
      
      if (!userExists) {
        addUserToSelected(user); // Add user if not already selected
      } else {
        // Optionally, show a message that the user has already been added
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${user['firstName']} has already been added.'))
        );
      }
    },
                        child: const Text('Add'),
                      ),
                    );
                  }).toList(),

                  
                              const SizedBox(
                                height: 20,
                              ),
                              SwitchListTile(
                                title: const Text(
                                    'Enable Notifications and reminders'),
                                value: notificationsEnabled,
                                onChanged: (bool value) {
                                  setState(() {
                                    notificationsEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          isActive: _currentStep >= 2,
                          state: _currentStep == 2
                              ? StepState.editing
                              : StepState.complete,
                        ),
                      ],
                      currentStep: _currentStep,
                      onStepTapped: (int newIndex) {
                        // setState(() {
                        //   _currentStep = newIndex;
                        // });
                      },
                     onStepContinue: () {
                      validateStepFields();
                      if (canProceedToNextStep()) {
                        if (_currentStep < 2) {
                          setState(() {
                            _currentStep += 1;
                          });
                             } else {
                          finishSetup(); // Trigger the finish setup logic
                        }
                      }
                    },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() {
                            _currentStep -= 1;
                          });
                        }
                      },
                      controlsBuilder:
                          (BuildContext context, ControlsDetails details) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const SizedBox(
                              height: 90,
                            ),
                            // Custom Cancel button (only show on steps 2 and above)
                            if (_currentStep > 0)
                              ElevatedButton(
                                onPressed: details.onStepCancel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            // Custom Continue button
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _currentStep == 2 ? 'Finish' : 'Next',
                                style: const TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
