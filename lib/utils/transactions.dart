import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class Transaction {
  final String name;
  final double amount;
  final String category;
  final DateTime date;
  final String type;

  Transaction({
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'type': type,
    };
  }

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

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [
    Transaction(name: 'Salary', amount: 2000.0, category: 'Income', date: DateTime.now().subtract(Duration(days: 30)), type: 'Deposit'),
    Transaction(name: 'Rent Payment', amount: 800.0, category: 'Housing', date: DateTime.now().subtract(Duration(days: 25)), type: 'Withdrawal'),
    Transaction(name: 'Grocery Shopping', amount: 120.0, category: 'Food', date: DateTime.now().subtract(Duration(days: 20)), type: 'Withdrawal'),
    Transaction(name: 'Freelance Work', amount: 500.0, category: 'Income', date: DateTime.now().subtract(Duration(days: 15)), type: 'Deposit'),
    Transaction(name: 'Dinner Out', amount: 80.0, category: 'Food', date: DateTime.now().subtract(Duration(days: 5)), type: 'Withdrawal'),
  ];

  List<Transaction> get transactions => _transactions;

  List<Transaction> get transactionsByDate {
    final sortedList = List<Transaction>.from(_transactions);
    sortedList.sort((a, b) => b.date.compareTo(a.date));
    return sortedList;
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('transactions');
    
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data);
      _transactions = jsonList.map((e) => Transaction.fromMap(e)).toList();
    } else {
      _transactions = _getSampleData();
      await saveTransactions();
    }
    notifyListeners();
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(_transactions.map((e) => e.toMap()).toList());
    await prefs.setString('transactions', jsonString);
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    saveTransactions();
    notifyListeners();
  }

  void removeTransaction(int index) {
    _transactions.removeAt(index);
    saveTransactions();
    notifyListeners();
  }

  void updateTransaction(int index, Transaction updatedTransaction) {
    _transactions[index] = updatedTransaction;
    saveTransactions();
    notifyListeners();
  }

  double getCurrentBalance() {
    return _transactions.fold(0.0, (sum, item) => sum + (item.type == 'Deposit' ? item.amount : -item.amount));
  }

  String getFormattedBalance() {
    return '\$${getCurrentBalance().toStringAsFixed(2)}';
  }

  List<FlSpot> getBalanceOverTimeData() {
    final sortedTransactions = List<Transaction>.from(_transactions);
    sortedTransactions.sort((a, b) => a.date.compareTo(b.date));

    double runningBalance = 0.0;
    List<FlSpot> spots = [];
    
    for (int i = 0; i < sortedTransactions.length; i++) {
      if (sortedTransactions[i].type == 'Deposit') {
        runningBalance += sortedTransactions[i].amount;
      } else {
        runningBalance -= sortedTransactions[i].amount;
      }
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }
    
    return spots;
  }

  List<Transaction> getTransactionsByType(String type) {
    return _transactions.where((transaction) => transaction.type == type).toList();
  }

  List<Transaction> getRecurringTransactions() {
    return [];
  }

  List<Transaction> _getSampleData() {
    return [
      Transaction(name: 'Salary', amount: 2000.0, category: 'Income', date: DateTime.now().subtract(Duration(days: 30)), type: 'Deposit'),
      Transaction(name: 'Rent', amount: 800.0, category: 'Housing', date: DateTime.now().subtract(Duration(days: 25)), type: 'Withdrawal'),
      Transaction(name: 'Groceries', amount: 120.0, category: 'Food', date: DateTime.now().subtract(Duration(days: 20)), type: 'Withdrawal'),
    ];
  }
}
