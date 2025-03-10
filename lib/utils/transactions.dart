import 'dart:convert';
import 'package:budget_app/utils/category.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Transaction model class to store individual transaction data
class Transaction {
  final String name;
  final double amount;
  String category;
  final DateTime date;
  final String type;

  Transaction({
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  // Convert Transaction to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'type': type,
    };
  }

  // Create Transaction from Map for retrieval
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: map['type'],
    );
  }
}

// TransactionProvider class to manage transactions
class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  static const String _storageKey = 'transactions_data';

  TransactionProvider() {
    // Load transactions when the provider is initialized
    loadTransactions();
  }

  // Get all transactions
  List<Transaction> get transactions => _transactions;

  // Get transactions sorted by date (newest first)
  List<Transaction> get transactionsByDate {
    final sortedList = List<Transaction>.from(_transactions);
    sortedList.sort((a, b) => b.date.compareTo(a.date));
    return sortedList;
  }

  // Load transactions from shared preferences
  Future<void> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? transactionsJson = prefs.getString(_storageKey);

      if (transactionsJson != null) {
        final List<dynamic> decodedList = jsonDecode(transactionsJson);
        _transactions =
            decodedList.map((item) => Transaction.fromMap(item)).toList();
        notifyListeners();
      } else {
        // If no stored data, use initial sample data
        _initializeWithSampleData();
        saveTransactions(); // Save the sample data for future use
      }
    } catch (e) {
      print('Error loading transactions: $e');
      // If there's an error, initialize with sample data
      _initializeWithSampleData();
    }
  }

  // Save transactions to shared preferences
  Future<void> saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> transactionMaps =
          _transactions.map((transaction) => transaction.toMap()).toList();
      final String transactionsJson = jsonEncode(transactionMaps);
      await prefs.setString(_storageKey, transactionsJson);
    } catch (e) {
      print('Error saving transactions: $e');
    }
  }

  // Initialize with sample data
  void _initializeWithSampleData() {
    _transactions = [
      Transaction(
        name: 'Salary',
        amount: 2000.0,
        category: 'Income',
        date: DateTime.now().subtract(const Duration(days: 30)),
        type: 'Deposit',
      ),
      Transaction(
        name: 'Rent Payment',
        amount: 800.0,
        category: 'Housing',
        date: DateTime.now().subtract(const Duration(days: 25)),
        type: 'Withdrawal',
      ),
      Transaction(
        name: 'Grocery Shopping',
        amount: 120.0,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 20)),
        type: 'Withdrawal',
      ),
      Transaction(
        name: 'Freelance Work',
        amount: 500.0,
        category: 'Income',
        date: DateTime.now().subtract(const Duration(days: 15)),
        type: 'Deposit',
      ),
      Transaction(
        name: 'Dinner Out',
        amount: 80.0,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: 'Withdrawal',
      ),
    ];
    notifyListeners();
  }

  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await saveTransactions();
    notifyListeners();
  }

  // Remove a transaction
  Future<void> removeTransaction(Transaction transaction) async {
    _transactions.removeAt(_transactions.indexOf(transaction));
    await saveTransactions();
    notifyListeners();
  }

  Future<void> deleteTransactionsByCategory(Category category) async {
    _transactions
        .removeWhere((transaction) => transaction.category == category.name);
    await saveTransactions();
    notifyListeners();
  }

  // Update a transaction
  Future<void> updateTransaction(
      Transaction oldTransaction, Transaction updatedTransaction) async {
    int index = _transactions.indexOf(oldTransaction);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      await saveTransactions();
      notifyListeners();
    }
  }

  Future<void> updateTransactionsByCategory(
      String oldCategoryName, String newCategoryName) async {
    for (var transaction in _transactions) {
      if (transaction.category == oldCategoryName) {
        transaction.category = newCategoryName;
      }
    }
    await saveTransactions();
    notifyListeners();
  }

  // Calculate current balance (modified to exclude future transactions)
  double getCurrentBalance() {
    double balance = 0.0;
    final now = DateTime.now();

    for (var transaction in _transactions) {
      // Only consider transactions up to the current date
      if (transaction.date.isBefore(now) ||
          transaction.date.isAtSameMomentAs(now)) {
        if (transaction.type == 'Deposit') {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }
    }
    return balance;
  }

  // Get formatted balance string
  String getFormattedBalance() {
    return '\$${getCurrentBalance().toStringAsFixed(2)}';
  }

  // Get balance data for chart (modified for YTD and to exclude future transactions)
  List<FlSpot> getBalanceOverTimeData() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1, 0, 0, 0);

    // Filter transactions to only include those from start of year to now
    final filteredTransactions = _transactions
        .where((transaction) =>
            (transaction.date.isAfter(startOfYear) ||
                transaction.date.isAtSameMomentAs(startOfYear)) &&
            (transaction.date.isBefore(now) ||
                transaction.date.isAtSameMomentAs(now)))
        .toList();

    // Sort filtered transactions by date (oldest first)
    filteredTransactions.sort((a, b) => a.date.compareTo(b.date));

    // If no transactions in the period, return empty list
    if (filteredTransactions.isEmpty) {
      return [];
    }

    // Calculate running balance over time
    double runningBalance = 0.0;
    List<FlSpot> spots = [];

    for (int i = 0; i < filteredTransactions.length; i++) {
      if (filteredTransactions[i].type == 'Deposit') {
        runningBalance += filteredTransactions[i].amount;
      } else {
        runningBalance -= filteredTransactions[i].amount;
      }
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }

    return spots;
  }

  // Get transactions by type (Deposit or Withdrawal)
  List<Transaction> getTransactionsByType(String type) {
    return _transactions
        .where((transaction) => transaction.type == type)
        .toList();
  }

  // Get recurring transactions (placeholder - you'll need to implement the logic based on your needs)
  List<Transaction> getRecurringTransactions() {
    // This is a placeholder - you'll need to define what makes a transaction recurring
    return [];
  }
}
