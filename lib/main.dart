import 'package:flutter/material.dart';
import 'home_page.dart';
import 'transfers_page.dart';
import 'reports_page.dart';
import 'account_page.dart';
import 'utils/transfer_dialog.dart';
import 'utils/color_utils.dart';

void main() {
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budgeting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: ColorUtils.primaryColor,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TransfersPage(),
    const HomePage(), // this is never actually used just a filler for the array
    const ReportsPage(),
    const AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTransferDialog() {
    showAddTransferDialog(
      context,
      TextEditingController(),
      TextEditingController(),
      null,
      'Withdrawal',
      (newType) {},
      (newDate) {},
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
          onTap: (index) {
            if (index == 2) {
              _showAddTransferDialog();
            } else {
              _onItemTapped(index);
            }
          },
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
