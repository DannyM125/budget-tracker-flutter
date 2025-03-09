import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'transfers_page.dart';
import 'reports_page.dart';
import 'account_page.dart';
import 'utils/transactions.dart';
import 'utils/transfer_dialog.dart';
import 'utils/color_utils.dart';
import 'utils/category.dart'; // Import the Category class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Budget App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: ColorUtils.primaryColor,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainNavigationScreen(),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  // List of all pages in the app
  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const TransfersPage(),
    const Placeholder(), // This is a placeholder for the add button
    const ReportsPage(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Show quick actions dialog when the add button is pressed
      _showAddTransferDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddTransferDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    Category? selectedCategory = Category.getInstance().first;  // Default to the first category

    showAddTransferDialog(
      context,
      nameController,
      amountController,
      selectedCategory, // Pass a valid Category object
      null,
      'Withdrawal',
      (value) {},
      (date) {},
      (name, amount, category, date, type) {
        Provider.of<TransactionProvider>(context, listen: false).addTransaction(
          Transaction(
            name: name,
            amount: amount,
            category: category.name,
            date: date,
            type: type,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ValueListenableBuilder<Color>(
        valueListenable: ColorUtils.primaryColorNotifier,
        builder: (context, primaryColor, child) {
          return BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.swap_horiz),
                label: 'Transfers',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
            type: BottomNavigationBarType.fixed,
          );
        },
      ),
    );
  }
}
