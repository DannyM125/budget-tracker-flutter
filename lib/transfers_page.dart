import 'package:flutter/material.dart';
import 'utils/transfer_dialog.dart';
import 'utils/color_utils.dart';

class TransfersPage extends StatefulWidget {
  const TransfersPage({super.key});

  @override
  _TransfersPageState createState() => _TransfersPageState();
}

class _TransfersPageState extends State<TransfersPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  DateTime? _selectedDate;
  String _transactionType = 'Withdrawal';

  final List<Map<String, dynamic>> _transactions = [
    {'amount': 100, 'type': 'Deposit'},
    {'amount': 50, 'type': 'Withdrawal'},
    {'amount': 200, 'type': 'Deposit'},
    {'amount': 75, 'type': 'Withdrawal'},
    {'amount': 150, 'type': 'Deposit'},
  ]; //TODO MEGH JSON STUFF

  @override
  Widget build(BuildContext context) {
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
                  _amountController,
                  _categoryController,
                  _selectedDate,
                  _transactionType,
                  (value) => setState(() => _transactionType = value),
                  (date) => setState(() => _selectedDate = date),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtils.primaryColor,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Add Transfer', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => showRecurringTransferDialog(
                  context,
                  _amountController,
                  _categoryController,
                  _selectedDate,
                  (date) => setState(() => _selectedDate = date),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorUtils.primaryColor,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Add Recurring Transfer', style: TextStyle(color: Colors.white, fontSize: 20)),

              ),
            ),
            const SizedBox(height: 50),
            SizedBox(height: 600,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: ListView.builder(
                          itemCount: _transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = _transactions[index];
                            final amount = transaction['amount'] as int;
                            final type = transaction['type'] as String;
                            final formattedAmount = type == 'Deposit' ? '+\$${amount}' : '-\$${amount}';
                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                              child: ListTile(
                                title: Text('Transfer #${index + 1}'),
                                subtitle: Text('Amount: $formattedAmount',
                                    style: TextStyle(
                                      color: type == 'Deposit' ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    )),
                                trailing: const Icon(Icons.arrow_forward_ios),
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
    ));
  }
}
