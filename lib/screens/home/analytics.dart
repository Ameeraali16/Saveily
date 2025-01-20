import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveily_2/bloc/account_bloc.dart';
import 'package:saveily_2/screens/home/homepage.dart';
import 'package:saveily_2/theme/color.dart';


class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  Map<String, Color> categoryColorMap = {};

  int currentIndex = 1; // Start at Analytics page (Stats)
  List<Color> availableColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.yellow,
    Colors.cyan,
    Colors.indigo,
  ];
  List<Color> usedColors = [];

  Color getRandomColor() {
    final random = Random();
    List<Color> unusedColors = availableColors
        .where((color) => !usedColors.contains(color))
        .toList();

    if (unusedColors.isEmpty) {
      usedColors.clear(); // Reset if all colors are used
      unusedColors = availableColors;
    }

    Color randomColor = unusedColors[random.nextInt(unusedColors.length)];
    usedColors.add(randomColor);
    return randomColor;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger loading account data each time this page is visited
    context.read<AccountBloc>().add(LoadAccount());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: TextColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, state) {
              if (state is AccountError) {
                // Show error if the account data loading fails
                return Center(child: Text(state.error));
              } else if (state is AccountLoaded) {
                // Access the expense data from the state
                final List<Map<String, dynamic>> expenses =
                    List<Map<String, dynamic>>.from(state.account['expenses'] ?? []);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expense Distribution',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: TextColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Pie chart with increased radius
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: PieChart(
                            PieChartData(
                              sections: _getPieChartSections(expenses),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 0, // No space between sections
                              centerSpaceRadius: 0, // Remove the inner circle
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Transactions List (Optional, if you want to show a list below chart)
                   // Transactions List
SizedBox(
  height: 200, // Set a fixed height for the ListView
  child: ListView.builder(
    itemCount: expenses.length,
    itemBuilder: (context, index) {
      final item = expenses[index];
      final category = item['category'];
      final expenseAmount = _parseExpense(item['expense']);
      final categoryColor = _getCategoryColor(category);

      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          tileColor: categoryColor.withOpacity(0.1), // Set a lighter color for the background
          title: Text(item['category']),
          trailing: Text(
            '\$${expenseAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    },
  ),
)

                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          // Add your action here
        },
      ),
    );
  }

  // Convert expense data to pie chart sections
  List<PieChartSectionData> _getPieChartSections(List<Map<String, dynamic>> expenses) {
    // Step 1: Group expenses by category
    Map<String, double> categorySums = {};

    for (var expense in expenses) {
      final category = expense['category'] ?? 'Unknown'; // Default category is 'Unknown'
      final amount = _parseExpense(expense['expense']); // Convert expense to double

      // Add to the category sum
      if (categorySums.containsKey(category)) {
        categorySums[category] = categorySums[category]! + amount;
      } else {
        categorySums[category] = amount;
      }
    }

    // Step 2: Sort categories by their total sum in descending order
    final sortedCategories = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Step 3: Convert to PieChartSectionData
    return sortedCategories.map((entry) {
      final category = entry.key;
      final value = entry.value;

      return PieChartSectionData(
        value: value,
        title: '',
        color: _getCategoryColor(category),
        radius: 100, // Adjust radius to control the size
        titleStyle: const TextStyle(
          fontSize: 0, // Remove title text
        ),
      );
    }).toList();
  }

  // Parse string expense to double, defaulting to 0.0 if invalid
  double _parseExpense(String? expense) {
    if (expense == null || expense.isEmpty) {
      return 0.0; // Default to 0.0 if expense is null or empty
    }

    // Try parsing the string to a double
    final parsedExpense = double.tryParse(expense);

    // Return the parsed value or default to 0.0 if parsing fails
    return parsedExpense ?? 0.0;
  }


Color _getCategoryColor(String category) {
  // Predefined categories
  switch (category) {
    case 'Groceries':
      return Colors.green;
    case 'Transport':
      return Colors.blue;
    case 'Shopping':
      return Colors.orange;
    case 'Entertainment':
      return Colors.purple;
    case 'Bills':
      return Colors.red;
    default:
      // Check if the category already has an assigned color
      if (categoryColorMap.containsKey(category)) {
        return categoryColorMap[category]!;
      }

      // Assign a new random color if it's a new category
      Color newColor = getRandomColor();
      
      // Store the new category and its assigned color
      categoryColorMap[category] = newColor;

      return newColor;
  }
}
}


class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
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
        onTap: onItemSelected,
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
