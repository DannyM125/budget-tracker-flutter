import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'utils/color_utils.dart';
import 'utils/transactions.dart';
import 'utils/category.dart'; // Add the Category import

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool showSpending = true;
  String selectedPeriod = 'YTD'; // Default to Year-to-Date

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // Filter transactions based on selected period
          final filteredTransactions = _filterTransactionsByPeriod(
            transactionProvider.transactions,
            selectedPeriod,
          );

          // Process transactions into spending and income categories
          final Map<String, double> spendingCategories = {};
          final Map<String, double> incomeCategories = {};

          for (var transaction in filteredTransactions) {
            if (transaction.type == 'Withdrawal' ||
                transaction.type == 'Expense') {
              // Add to spending categories
              if (spendingCategories.containsKey(transaction.category)) {
                spendingCategories[transaction.category] =
                    spendingCategories[transaction.category]! +
                        transaction.amount;
              } else {
                spendingCategories[transaction.category] = transaction.amount;
              }
            } else if (transaction.type == 'Deposit' ||
                transaction.type == 'Income') {
              // Add to income categories
              if (incomeCategories.containsKey(transaction.category)) {
                incomeCategories[transaction.category] =
                    incomeCategories[transaction.category]! +
                        transaction.amount;
              } else {
                incomeCategories[transaction.category] = transaction.amount;
              }
            }
          }

          // Convert maps to lists of maps for the chart and list
          final List<Map<String, dynamic>> spendingList = spendingCategories
              .entries
              .map((entry) => {'category': entry.key, 'amount': entry.value})
              .toList();

          final List<Map<String, dynamic>> incomeList = incomeCategories.entries
              .map((entry) => {'category': entry.key, 'amount': entry.value})
              .toList();

          // Sort lists by amount in descending order
          spendingList.sort((a, b) =>
              (b['amount'] as double).compareTo(a['amount'] as double));
          incomeList.sort((a, b) =>
              (b['amount'] as double).compareTo(a['amount'] as double));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showSpending = !showSpending;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: ColorUtils.primaryColor),
                        child: Text(
                          showSpending
                              ? 'Show Income Report'
                              : 'Show Spending Report',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: ColorUtils.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButton<String>(
                        value: selectedPeriod,
                        icon: Icon(Icons.arrow_drop_down,
                            color: ColorUtils.primaryColor),
                        elevation: 16,
                        style: TextStyle(
                          color: ColorUtils.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        underline: Container(height: 0), // Remove the underline
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPeriod = newValue!;
                          });
                        },
                        items: <String>['Day', 'Week', 'Month', 'YTD']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  flex: 3,
                  child: showSpending
                      ? (spendingList.isEmpty
                          ? _buildEmptyState(
                              'No spending transactions found for $selectedPeriod')
                          : _buildChartSection(spendingList))
                      : (incomeList.isEmpty
                          ? _buildEmptyState(
                              'No income transactions found for $selectedPeriod')
                          : _buildChartSection(incomeList)),
                ),
                const SizedBox(height: 20),
                Text(
                  showSpending
                      ? 'Top Spending Categories:'
                      : 'Top Earning Categories:',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ColorUtils.primaryColor),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: showSpending
                      ? (spendingList.isEmpty
                          ? _buildEmptyState(
                              'Add transactions to see your spending breakdown')
                          : _buildCategoryList(spendingList))
                      : (incomeList.isEmpty
                          ? _buildEmptyState(
                              'Add transactions to see your income breakdown')
                          : _buildCategoryList(incomeList)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Transaction> _filterTransactionsByPeriod(
      List<Transaction> transactions, String period) {
    final now = DateTime.now();
    final startDate = _getStartDateForPeriod(period, now);

    return transactions.where((transaction) {
      // Only include transactions between the start date and now (not in the future)
      return (transaction.date.isAfter(startDate) ||
              transaction.date.isAtSameMomentAs(startDate)) &&
          (transaction.date.isBefore(now) ||
              transaction.date.isAtSameMomentAs(now));
    }).toList();
  }

  DateTime _getStartDateForPeriod(String period, DateTime now) {
    switch (period) {
      case 'Day':
        return DateTime(now.year, now.month, now.day, 0, 0, 0);
      case 'Week':
        // Go back to the most recent Sunday (or whatever day you want to consider as week start)
        final daysToSubtract = now.weekday % 7;
        return DateTime(now.year, now.month, now.day - daysToSubtract, 0, 0, 0);
      case 'Month':
        return DateTime(now.year, now.month, 1, 0, 0, 0);
      case 'YTD':
        return DateTime(now.year, 1, 1, 0, 0, 0);
      default:
        return DateTime(now.year, 1, 1, 0, 0, 0); // Default to YTD
    }
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
          title:
              Text(category['category'], style: const TextStyle(fontSize: 18)),
          trailing: Text(
            '\$${category['amount'].toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _generatePieChartSections(
      List<Map<String, dynamic>> categories) {
    final total =
        categories.fold(0.0, (sum, category) => sum + category['amount']);

    return categories.map((category) {
      final value = category['amount'].toDouble();
      final percentage = (value / total * 100).toStringAsFixed(1);

      return PieChartSectionData(
        value: value,
        color: _getCategoryColor(category['category']),
        radius: 60,
        title: '$percentage%',
        titleStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        badgeWidget: null,
        badgePositionPercentageOffset: 1.75,
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    // Use the Category class to get the color based on the category name
    final categoryObj = Category.getInstance().firstWhere(
      (categoryItem) => categoryItem.name == category,
      orElse: () => Category(
          name: 'Unknown', color: Colors.grey), // Default to grey if not found
    );

    return categoryObj.color;
  }
}
