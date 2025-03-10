import 'package:budget_app/utils/category.dart';
import 'package:flutter/material.dart';
import 'color_utils.dart';
import 'package:intl/intl.dart';

// Function to show the dialog for adding a regular transfer
void showAddTransferDialog(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController amountController,
  Category? selectedCategory, // Change from String? to Category?
  DateTime? selectedDate,
  String transactionType,
  Function(String) onTransactionTypeChanged,
  Function(DateTime) onDateSelected,
  Function(String, double, Category, DateTime, String)
      onAddTransaction, // Change String to Category
) {
  // Reset controllers
  nameController.clear();
  amountController.clear();

  // Set default date to today if not already set
  DateTime date = selectedDate ?? DateTime.now();

  // Create a local variable to track transaction type inside the dialog
  String localTransactionType = transactionType;

  // Predefined category list
  List<Category> categories = Category.getInstance();

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
                    decoration:
                        const InputDecoration(labelText: 'Transfer Name'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Category: '),
                      DropdownButton<Category>(
                        value: selectedCategory ??
                            categories.first, // Default to first category
                        items: categories.map((Category category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (Category? value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Transaction Type: '),
                      DropdownButton<String>(
                        value: localTransactionType,
                        items: const [
                          DropdownMenuItem(
                              value: 'Deposit', child: Text('Deposit')),
                          DropdownMenuItem(
                              value: 'Withdrawal', child: Text('Withdrawal')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            localTransactionType = value!;
                            onTransactionTypeChanged(value);
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
                      selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all fields')),
                    );
                    return;
                  }

                  // Parse amount, handling potential errors
                  double? amount;
                  try {
                    amount = double.parse(amountController.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a valid amount')),
                    );
                    return;
                  }

                  // Add the transaction
                  onAddTransaction(
                    nameController.text,
                    amount,
                    selectedCategory!,
                    date,
                    localTransactionType,
                  );

                  Navigator.of(context).pop();

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Transaction added successfully')),
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
