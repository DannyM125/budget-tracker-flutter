import 'package:flutter/material.dart';
import 'color_utils.dart';
import 'package:intl/intl.dart';

// Function to show the dialog for adding a regular transfer
void showAddTransferDialog(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController amountController,
  TextEditingController categoryController,
  DateTime? selectedDate,
  String transactionType,
  Function(String) onTransactionTypeChanged,
  Function(DateTime) onDateSelected,
  Function(String, double, String, DateTime, String) onAddTransaction,
) {
  // Reset controllers
  nameController.clear();
  amountController.clear();
  categoryController.clear();
  
  // Set default date to today if not already set
  DateTime date = selectedDate ?? DateTime.now();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Transfer'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Transfer Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Transaction Type: '),
                      DropdownButton<String>(
                        value: transactionType,
                        items: const [
                          DropdownMenuItem(value: 'Deposit', child: Text('Deposit')),
                          DropdownMenuItem(value: 'Withdrawal', child: Text('Withdrawal')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            onTransactionTypeChanged(value!);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Date: '),
                      TextButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null && picked != date) {
                            setState(() {
                              date = picked;
                              onDateSelected(picked);
                            });
                          }
                        },
                        child: Text(
                          DateFormat('MMM d, yyyy').format(date),
                          style: TextStyle(color: ColorUtils.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Validate inputs
                  if (nameController.text.isEmpty ||
                      amountController.text.isEmpty ||
                      categoryController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  // Parse amount, handling potential errors
                  double? amount;
                  try {
                    amount = double.parse(amountController.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }

                  // Add the transaction
                  onAddTransaction(
                    nameController.text,
                    amount,
                    categoryController.text,
                    date,
                    transactionType,
                  );

                  Navigator.of(context).pop();
                  
                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction added successfully')),
                  );
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}