
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveily_2/bloc/account_bloc.dart';
import 'package:saveily_2/functions/functions.dart';
import 'package:saveily_2/screens/home/addexpense.dart';
import 'package:saveily_2/screens/home/analytics.dart';
import 'package:saveily_2/screens/home/userprofile.dart';
import 'package:saveily_2/screens/home/userslist.dart';
import 'package:saveily_2/theme/color.dart';


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
   
    context.read<AccountBloc>().add(LoadAccount());
  }

  @override
  Widget build(BuildContext context) {
    return 
      Scaffold(
        backgroundColor: bgColor,
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
                final String userName = state.user['firstName'] ?? 'No name'; 
        final String profileImageUrl = state.user['profileImageUrl'] ?? ''; 
      
      
        final String balance = state.account['balance'] ?? '';
         final String income = state.account['income'] ?? '';
       final List<Map<String, dynamic>> expenses = List<Map<String, dynamic>>.from(state.account['expenses'] ?? []);
       final String updatedBalance =  calculateUpdatedBalance(balance, expenses);
      
          final String totalExpense = calculateTotalExpense( expenses);
          
                return SingleChildScrollView(
                  child: Padding(
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
                  ),
                );
              }
      
                if( state is AccountError){
                    print("Account error: ${state.error}");
        
                  return const Center(child: Text('Error: Bloc error'),);
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
                          const UserProfile(), 
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
                    const Text(
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
                      style: const TextStyle(
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
                    const UserListScreen(), 
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
        gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, Colors.blue], 
      ),
      //  color: color2,
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
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          //BALANCE
          Text(
            'PKR $balance',
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
    return Column(
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
           TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => TransactionListModal(expenses: expenses),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: TextColor,
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      
        SizedBox(
          height: 300, 
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: expenses.length,
            itemBuilder: (context, i) {
              return TransactionItem(expense: expenses[i], index: i);
            },
          ),
        ),
      ],
    );
  }
}

class TransactionListModal extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  const TransactionListModal({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            'All Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
   
    final String expenseName = expense['expense'] ?? 'No Expense'; 
    final String category = expense['category'] ?? 'Uncategorized'; 
    final String email = expense['userEmail'] ?? 'unknown';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, Colors.blue], 
      ),
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
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.money_dollar_circle,
                        color:primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          color:  Colors.white,
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
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
width: 15,
              ),
             
Text(
  "By $email",
  style: TextStyle(
    fontSize: 12,
    color:  Colors.white,
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
              MaterialPageRoute(builder: (context) => const Analytics()),
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
            builder: (context) => const Addexpense(), 
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
