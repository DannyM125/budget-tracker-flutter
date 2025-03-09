import 'package:flutter/material.dart';
import 'color_utils.dart';

void showAddTransferDialog(
  BuildContext context,
  TextEditingController amountController,
  TextEditingController categoryController,
  DateTime? selectedDate,
  String transactionType,
  Function(String) onTransactionTypeChanged,
  Function(DateTime?) onDateSelected,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Add Transfer',
        style: TextStyle(color: Colors.black), // Black text for title
      ),
      backgroundColor: Colors.white, // White background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: transactionType,
            items: ['Withdrawal', 'Deposit']
                .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type, style: TextStyle(color: Colors.black))))
                .toList(),
            onChanged: (value) {
              onTransactionTypeChanged(value!);
            },
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              labelStyle:
                  TextStyle(color: Colors.black), // Black text for label
            ),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Category',
              labelStyle:
                  TextStyle(color: Colors.black), // Black text for label
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              onDateSelected(pickedDate);
            },
            child: const Text(
              'Select Date',
              style: TextStyle(color: Colors.black), // Black text for button
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black), // Black text for cancel
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorUtils.primaryColor, // Blue background for save button
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white), // White text for save button
          ),
        ),
      ],
    ),
  );
}

void showRecurringTransferDialog(
  BuildContext context,
  TextEditingController amountController,
  TextEditingController categoryController,
  DateTime? selectedDate,
  Function(DateTime?) onDateSelected,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'Add Recurring Transfer',
        style: TextStyle(color: Colors.black), // Black text for title
      ),
      backgroundColor: Colors.white, // White background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: categoryController,
            decoration: const InputDecoration(
              labelText: 'Category',
              labelStyle:
                  TextStyle(color: Colors.black), // Black text for label
            ),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              labelStyle:
                  TextStyle(color: Colors.black), // Black text for label
            ),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              onDateSelected(pickedDate);
            },
            child: const Text(
              'Select Start Date',
              style: TextStyle(color: Colors.black), // Black text for button
            ),
          ),
          DropdownButton<String>(
            value: 'Monthly',
            items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                .map((cycle) => DropdownMenuItem(
                    value: cycle,
                    child: Text(cycle, style: TextStyle(color: Colors.black))))
                .toList(),
            onChanged: (value) {},
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black), // Black text for cancel
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Blue background for save button
          ),
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.white), // White text for save button
          ),
        ),
      ],
    ),
  );
}
