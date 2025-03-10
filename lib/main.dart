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

// FlashCard Model
class FlashCard {
  final String question;
  final String answer;

  FlashCard({required this.question, required this.answer});
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
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

  void _showFlashcards() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardsPage(
          primaryColor: ColorUtils.primaryColorNotifier.value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ColorUtils.primaryColorNotifier,
      builder: (context, primaryColor, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(
              _getAppBarTitle(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: primaryColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState!.openEndDrawer();
                },
              ),
            ],
          ),
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Replace DrawerHeader with a more compact container
                Container(
                  color: primaryColor,
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                  child: const Row(
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.question_answer),
                  title: const Text('Q&A'),
                  onTap: () {
                    // Close the drawer
                    Navigator.pop(context);
                    // Show flashcards page
                    _showFlashcards();
                  },
                ),
                // Add more drawer items here if needed
              ],
            ),
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
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
          ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Transfers';
      case 3:
        return 'Reports';
      case 4:
        return 'Account';
      default:
        return 'Budget App';
    }
  }
}

class FlashcardsPage extends StatefulWidget {
  final Color primaryColor;
  
  const FlashcardsPage({
    Key? key,
    required this.primaryColor,
  }) : super(key: key);

  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  
  // Sample flashcards - replace with your own content
  final List<FlashCard> _flashcards = [
    FlashCard(
      question: "What is budgeting?",
      answer: "Budgeting is the process of creating a plan to spend your money. This spending plan is called a budget. Creating this plan allows you to determine in advance whether you will have enough money to do the things you need to do or would like to do.",
    ),
    FlashCard(
      question: "What is the 50/30/20 rule?",
      answer: "The 50/30/20 rule is a budgeting method that allocates 50% of income to needs, 30% to wants, and 20% to savings and debt repayment.",
    ),
    FlashCard(
      question: "What is an emergency fund?",
      answer: "An emergency fund is money set aside for unexpected expenses such as medical bills, car repairs, or job loss. Experts recommend saving 3-6 months of living expenses.",
    ),
    FlashCard(
      question: "What is the difference between fixed and variable expenses?",
      answer: "Fixed expenses remain constant each month (rent, mortgage, car payment), while variable expenses fluctuate (groceries, utilities, entertainment).",
    ),
    FlashCard(
      question: "What is the envelope budgeting system?",
      answer: "The envelope system involves dividing cash into different envelopes for various spending categories. When an envelope is empty, you stop spending in that category until the next budget period.",
    ),
  ];

  void _nextCard() {
    setState(() {
      if (_currentIndex < _flashcards.length - 1) {
        _currentIndex++;
        _showAnswer = false;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _showAnswer = false;
      }
    });
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards', style: TextStyle(color: Colors.white)),
        backgroundColor: widget.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Card ${_currentIndex + 1} of ${_flashcards.length}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Flashcard
          Expanded(
            child: GestureDetector(
              onTap: _toggleAnswer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAnswer ? 'Answer:' : 'Question:',
                          style: TextStyle(
                            fontSize: 18,
                            color: widget.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _showAnswer 
                              ? _flashcards[_currentIndex].answer 
                              : _flashcards[_currentIndex].question,
                          style: const TextStyle(fontSize: 22),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Tap to ${_showAnswer ? 'see question' : 'reveal answer'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentIndex > 0 ? _previousCard : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentIndex < _flashcards.length - 1 ? _nextCard : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}