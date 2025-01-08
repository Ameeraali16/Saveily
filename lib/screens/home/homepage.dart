import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveily_2/bloc/account_bloc.dart';
import 'package:saveily_2/functions/functions.dart';
import 'package:saveily_2/models/transactionModel.dart';
import 'package:saveily_2/screens/home/addexpense.dart';
import 'package:saveily_2/screens/home/analytics.dart';
import 'package:saveily_2/screens/home/userprofile.dart';
import 'package:saveily_2/screens/home/userslist.dart';
import 'package:saveily_2/theme/color.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

// MainScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  int currentIndex = 0;


   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger loading account data each time this page is visited
    context.read<AccountBloc>().add(LoadAccount());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // Ensure bgColor is defined
      body: SafeArea(
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountInitial) {
              context.read<AccountBloc>().add(LoadAccount());
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AccountLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AccountLoaded) {
              final String userName = state.user['firstName'] ?? 'No name'; // Default value
      final String profileImageUrl = state.user['profileImageUrl'] ?? ''; // Default empty string


      final String balance = state.account['balance'] ?? '';
       final String income = state.account['income'] ?? '';
     final List<Map<String, dynamic>> expenses = List<Map<String, dynamic>>.from(state.account['expenses'] ?? []);
     final String updatedBalance =  calculateUpdatedBalance(balance, expenses);

        final String totalExpense = calculateTotalExpense( expenses);
        
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 10.0,
                ),
                child: Column(
                  children: [
                    UserProfileSection(
                       userName: userName,
        profileImageUrl: profileImageUrl,
                    ),

                 
                    const SizedBox(height: 20),
                    BalanceCard(
                      balance : updatedBalance ,
                      income: income,
                      exp : totalExpense
                    ),
                    const SizedBox(height: 40),
                    TransactionsSection(expenses : expenses),
                  ],
                ),
              );
            }

              if( state is AccountError){
                  print("Account error: ${state.error}");
      
                return Center(child: Text('Error: Bloc error'),);
              }

            return const Center(
              child: Text("Unexpected State"), // Fallback UI
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onItemSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Addexpense()),
          );
        },
      ),
    );
  }
}

// Components

class UserProfileSection extends StatelessWidget {
 final String userName;
  final String profileImageUrl;

  const UserProfileSection({
    super.key,
    required this.userName,
    required this.profileImageUrl,
  });




  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UserProfile(), 
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow[700],
                      ),
                      child: ClipOval(
                        child: profileImageUrl.isNotEmpty
                            ? Image.network(
                                profileImageUrl,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.yellow[800],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                     userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserListScreen(), // Replace with your actual page
              ),
            );
          },
          icon: const Icon(
            Icons.settings,
            color: TextColor,
          ),
        ),
      ],
    );
  }
}

class BalanceCard extends StatelessWidget {
  final String balance;
  final String income;
  final String exp;

 const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.exp
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.grey.shade300,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),

          //BALANCE
          Text(
            'PKR $balance',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IncomeExpenseBlock(
                  iconColor: Colors.greenAccent,
                  label: 'Income',
                  amount:  'PKR $income',
                ),
                IncomeExpenseBlock(
                  iconColor: Colors.red,
                  label: 'Expenses',
                  amount: 'PKR $exp',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IncomeExpenseBlock extends StatelessWidget {
  final Color iconColor;
  final String label;
  final String amount;

  const IncomeExpenseBlock({
    super.key,
    required this.iconColor,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            color: Colors.white30,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              CupertinoIcons.arrow_down,
              size: 12,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TransactionsSection extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const TransactionsSection({
    super.key,
    required this.expenses,
  
  });

  @override
  Widget build(BuildContext context) {
   

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Add View All action
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, i) {
                return TransactionItem(expense: expenses[i], index: i);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
 final Map<String, dynamic> expense;
  final int index;

  const TransactionItem({
    super.key,
    required this.expense,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
     // Extracting the relevant data from the Map
    final String expenseName = expense['expense'] ?? 'No Expense'; // Ensure it's a String
    final String category = expense['category'] ?? 'Uncategorized'; // Ensure it's a String
    final String email = expense['userEmail'] ?? 'unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.money_dollar_circle,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                 "\pkr${expenseName}.00",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
width: 15,
              ),
              // Below is the email text section to display under the category (or where appropriate):
Text(
  "By $email",
  style: TextStyle(
    fontSize: 12,
    color: Colors.grey.shade600,
    fontWeight: FontWeight.w400,
  ),
),
            ],
          ),
        ),
        
      ),
    );

  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required Null Function(dynamic index) onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedItem = Colors.green.shade600;
    final unselectedItem = Colors.grey;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0 && currentIndex != 0) {
            // Navigate back to the Main Screen
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1 && currentIndex != 1) {
            // Navigate to the Analytics Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Analytics()),
            );
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 3,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
              color: currentIndex == 0 ? selectedItem : unselectedItem,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.graph_square_fill,
              color: currentIndex == 1 ? selectedItem : unselectedItem,
            ),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Addexpense(), // Replace with your actual page
          ),
        );
      },
      shape: const CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
