import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/transfer_dialog.dart';
import 'utils/color_utils.dart';
import 'utils/transactions.dart';
import 'package:intl/intl.dart';

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  _TransfersPageState createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  DateTime? _selectedDate;
  String _transactionType = 'Withdrawal';

  @override
  Widget build(BuildContext context) {
    // Access the transaction provider
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactionsByDate;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Transfers'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
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
                    _nameController,
                    _amountController,
                    _categoryController,
                    _selectedDate,
                    _transactionType,
                    (value) => setState(() => _transactionType = value),
                    (date) => setState(() => _selectedDate = date),
                    (name, amount, category, date, type) {
                      // Add new transaction using the provider
                      transactionProvider.addTransaction(
                        Transaction(
                          name: name,
                          amount: amount,
                          category: category,
                          date: date,
                          type: type,
                        ),
                      );
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtils.primaryColor,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Add Transfer', 
                    style: TextStyle(color: Colors.white, fontSize: 20)
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => showRecurringTransferDialog(
                    context,
                    _nameController,
                    _amountController,
                    _categoryController,
                    _selectedDate,
                    (date) => setState(() => _selectedDate = date),
                    (name, amount, category, date, frequency) {
                      // Add recurring transaction logic will be implemented here
                      transactionProvider.addTransaction(
                        Transaction(
                          name: '$name (Recurring - $frequency)',
                          amount: amount,
                          category: category,
                          date: date,
                          type: 'Withdrawal', // Most recurring transactions are withdrawals
                        ),
                      );
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtils.primaryColor,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Add Recurring Transfer', 
                    style: TextStyle(color: Colors.white, fontSize: 20)
                  ),
                ),
              ),
              const SizedBox(height: 50),
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
                        'Transfer History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              final formattedAmount = transaction.type == 'Deposit' 
                                  ? '+\$${transaction.amount.toStringAsFixed(2)}' 
                                  : '-\$${transaction.amount.toStringAsFixed(2)}';
                              final formattedDate = DateFormat('MMM d, yyyy').format(transaction.date);
                              
                              return Dismissible(
                                key: Key(transaction.name + transaction.date.toString()),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text("Are you sure you want to delete this transaction?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text("CANCEL"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text("DELETE"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                onDismissed: (direction) {
                                  // Remove the transaction when dismissed
                                  Provider.of<TransactionProvider>(context, listen: false)
                                      .removeTransaction(index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Transaction deleted')),
                                  );
                                },
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    title: Text(transaction.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          formattedAmount,
                                          style: TextStyle(
                                            color: transaction.type == 'Deposit' ? Colors.green : Colors.red,
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
                                      // Show transaction details when tapped
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(transaction.name),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Amount: $formattedAmount'),
                                              Text('Category: ${transaction.category}'),
                                              Text('Date: $formattedDate'),
                                              Text('Type: ${transaction.type}'),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
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
}