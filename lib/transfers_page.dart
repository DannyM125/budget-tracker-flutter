import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/transfer_dialog.dart';
import 'utils/color_utils.dart';
import 'utils/transactions.dart';
import 'package:intl/intl.dart';
import 'utils/category.dart'; // Import Category class

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  _TransfersPageState createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  // Controllers for adding new transactions
  final TextEditingController _newTransactionNameController =
      TextEditingController();
  final TextEditingController _newTransactionAmountController =
      TextEditingController();
  Category? _newTransactionCategory;
  DateTime? _newTransactionDate;
  String _transactionType = 'Withdrawal';

  // Controllers for filtering
  final TextEditingController _searchController = TextEditingController();
  Category? _filterCategory;
  String _searchQuery = "";

  // Controllers for editing transactions
  final TextEditingController _editNameController = TextEditingController();
  final TextEditingController _editAmountController = TextEditingController();
  Category? _editCategory;
  DateTime? _editDate;

  @override
  Widget build(BuildContext context) {
    // Access the transaction provider
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactionsByDate;

    // Filter transactions based on search query and selected category
    final filteredTransactions = transactions.where((transaction) {
      final matchesSearch =
          transaction.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _filterCategory == null ||
          _filterCategory!.name == 'All' ||
          transaction.category == _filterCategory!.name;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: () => showAddTransferDialog(
                    context,
                    _newTransactionNameController,
                    _newTransactionAmountController,
                    _newTransactionCategory ??
                        Category.getInstance()
                            .first, // Default to the first category
                    _newTransactionDate,
                    _transactionType,
                    (value) => setState(() => _transactionType = value),
                    (date) => setState(() => _newTransactionDate = date),
                    (name, amount, category, date, type) {
                      // Add new transaction using the provider
                      transactionProvider.addTransaction(
                        Transaction(
                          name: name,
                          amount: amount,
                          category: category.name, // Pass the category name
                          date: date,
                          type: type,
                        ),
                      );
                      // Clear controllers after adding
                      _newTransactionNameController.clear();
                      _newTransactionAmountController.clear();
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtils.primaryColor,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Add Transfer',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
              const SizedBox(height: 20),

              // Search bar and category dropdown
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Search by name',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: ColorUtils.primaryColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Category dropdown with 'All' option
                  DropdownButton<Category>(
                    value: _filterCategory,
                    hint: const Text('Category'),
                    onChanged: (Category? newCategory) {
                      setState(() {
                        _filterCategory = newCategory;
                      });
                    },
                    items: [
                      // Adding "All" as a dropdown option
                      DropdownMenuItem<Category>(
                        value: null, // Represents "All" option
                        child: const Text('All'),
                      ),
                      ...Category.getInstance().map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 600,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'All Transactions',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = filteredTransactions[index];
                              final formattedAmount = transaction.type ==
                                      'Deposit'
                                  ? '+\$${transaction.amount.toStringAsFixed(2)}'
                                  : '-\$${transaction.amount.toStringAsFixed(2)}';
                              final formattedDate = DateFormat('MMM d, yyyy')
                                  .format(transaction.date);

                              return Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                                child: ListTile(
                                  title: Text(transaction.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedAmount,
                                        style: TextStyle(
                                          color: transaction.type == 'Deposit'
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '$formattedDate - ${transaction.category}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    _showTransactionDialog(
                                        context, transaction);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDialog(BuildContext context, Transaction transaction) {
    // Pre-fill the dialog fields with the existing transaction details
    _editNameController.text = transaction.name;
    _editAmountController.text = transaction.amount.toStringAsFixed(2);
    _editCategory = Category.getInstance().firstWhere(
      (category) => category.name == transaction.category,
      orElse: () =>
          Category.getInstance().first, // Default to the first category
    );
    _editDate = transaction.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Transaction Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editNameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _editAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                DropdownButton<Category>(
                  value: _editCategory,
                  hint: const Text('Category'),
                  onChanged: (Category? newCategory) {
                    setState(() {
                      _editCategory = newCategory;
                    });
                  },
                  items: Category.getInstance().map((category) {
                    return DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                ),
                TextButton(
                  onPressed: () {
                    // Date picker for selecting the transaction date
                    showDatePicker(
                      context: context,
                      initialDate: _editDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    ).then((pickedDate) {
                      if (pickedDate != null && pickedDate != _editDate) {
                        setState(() {
                          _editDate = pickedDate;
                        });
                      }
                    });
                  },
                  child: Text(
                    'Date: ${_editDate != null ? DateFormat('MMM d, yyyy').format(_editDate!) : 'Select Date'}',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  // Update the transaction details
                  final updatedTransaction = Transaction(
                    name: _editNameController.text,
                    amount: double.tryParse(_editAmountController.text) ?? 0.0,
                    category: _editCategory?.name ?? '',
                    date: _editDate ?? DateTime.now(),
                    type: transaction.type, // Keep the original type
                  );
                  // Update the transaction in the provider
                  Provider.of<TransactionProvider>(context, listen: false)
                      .updateTransaction(transaction, updatedTransaction);
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction updated')),
                  );
                },
                child: const Text('Update'),
              ),
              TextButton(
                onPressed: () {
                  // Delete the transaction from the provider
                  Provider.of<TransactionProvider>(context, listen: false)
                      .removeTransaction(transaction);
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction deleted')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          );
        });
      },
    );
  }
}
