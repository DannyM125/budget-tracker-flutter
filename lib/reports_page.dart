import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'utils/color_utils.dart';
import 'utils/transactions.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool showSpending = true;
  final Map<String, Color> categoryColors = {
    'Food': Colors.orange,
    'Transportation': Colors.blue,
    'Entertainment': Colors.green,
    'Bills': Colors.red,
    'Salary': Colors.purple,
    'Freelance': Colors.yellow,
    'Investments': Colors.pink,
  }; //TODO MEGH SAVE THIS IN JSON

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // Process transactions into spending and income categories
          final Map<String, double> spendingCategories = {};
          final Map<String, double> incomeCategories = {};

          for (var transaction in transactionProvider.transactions) {
            if (transaction.type == 'Withdrawal' || transaction.type == 'Expense') {
              // Add to spending categories
              if (spendingCategories.containsKey(transaction.category)) {
                spendingCategories[transaction.category] = 
                    spendingCategories[transaction.category]! + transaction.amount;
              } else {
                spendingCategories[transaction.category] = transaction.amount;
              }
            } else if (transaction.type == 'Deposit' || transaction.type == 'Income') {
              // Add to income categories
              if (incomeCategories.containsKey(transaction.category)) {
                incomeCategories[transaction.category] = 
                    incomeCategories[transaction.category]! + transaction.amount;
              } else {
                incomeCategories[transaction.category] = transaction.amount;
              }
            }
          }

          // Convert maps to lists of maps for the chart and list
          final List<Map<String, dynamic>> spendingList = spendingCategories.entries
              .map((entry) => {'category': entry.key, 'amount': entry.value})
              .toList();

          final List<Map<String, dynamic>> incomeList = incomeCategories.entries
              .map((entry) => {'category': entry.key, 'amount': entry.value})
              .toList();

          // Sort lists by amount in descending order
          spendingList.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
          incomeList.sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSpending = !showSpending;
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: ColorUtils.primaryColor),
                  child: Text(
                    showSpending ? 'Show Income Report' : 'Show Spending Report',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  flex: 3,
                  child: showSpending
                      ? (spendingList.isEmpty
                          ? _buildEmptyState('No spending transactions found')
                          : _buildChartSection(spendingList))
                      : (incomeList.isEmpty
                          ? _buildEmptyState('No income transactions found')
                          : _buildChartSection(incomeList)),
                ),
                const SizedBox(height: 20),
                Text(
                  showSpending ? 'Top Spending Categories:' : 'Top Earning Categories:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: ColorUtils.primaryColor),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: showSpending
                      ? (spendingList.isEmpty
                          ? _buildEmptyState('Add transactions to see your spending breakdown')
                          : _buildCategoryList(spendingList))
                      : (incomeList.isEmpty
                          ? _buildEmptyState('Add transactions to see your income breakdown')
                          : _buildCategoryList(incomeList)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 60, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<Map<String, dynamic>> data) {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: _generatePieChartSections(data),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(category['category']),
            radius: 10,
          ),
          title: Text(category['category'], style: const TextStyle(fontSize: 18)),
          trailing: Text(
            '\$${category['amount'].toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _generatePieChartSections(List<Map<String, dynamic>> categories) {
    return categories.map(
      (category) => PieChartSectionData(
        value: category['amount'].toDouble(),
        color: _getCategoryColor(category['category']),
        title: categories.length <= 3 
            ? '${category['category']}\n\$${category['amount'].toStringAsFixed(2)}'
            : '\$${category['amount'].toStringAsFixed(0)}',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: categories.length > 3 ? null : null,
        badgePositionPercentageOffset: 1.1,
      ),
    ).toList();
  }

  Color _getCategoryColor(String category) {
    // Check if we have a predefined color for this category
    if (categoryColors.containsKey(category)) {
      return categoryColors[category]!;
    }
    
    // If not, generate a color based on the category name for consistency
    int hashCode = category.hashCode;
    return Color((hashCode & 0xFFFFFF) | 0xFF000000); 
    /*This is kinda sick ngl, it creates a color based off the chars in the 
    category name!*/
  }
}