import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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

// FAQ Model
class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
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
    Category? selectedCategory =
        Category.getInstance().first; // Default to the first category

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

  void _showGoogleFormPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoogleFormPage(
          primaryColor: ColorUtils.primaryColorNotifier.value,
        ),
      ),
    );
  }

  void _showAppFAQPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppFAQPage(
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
                  title: const Text('Budgeting Q&A Flashcards'),
                  onTap: () {
                    // Close the drawer
                    Navigator.pop(context);
                    // Show flashcards page
                    _showFlashcards();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Question Box'),
                  onTap: () {
                    // Close the drawer
                    Navigator.pop(context);
                    // Show Google Form page
                    _showGoogleFormPage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('App Details & FAQ'),
                  onTap: () {
                    // Close the drawer
                    Navigator.pop(context);
                    // Show App FAQ page
                    _showAppFAQPage();
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

// Google Form Page with WebView
class GoogleFormPage extends StatefulWidget {
  final Color primaryColor;

  const GoogleFormPage({
    Key? key,
    required this.primaryColor,
  }) : super(key: key);

  @override
  _GoogleFormPageState createState() => _GoogleFormPageState();
}

class _GoogleFormPageState extends State<GoogleFormPage> {
  final String googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSehGev8vJLcdLm8gXi5kAUAbtd6JRUeXCubi5KfVzVkJ59nAA/viewform';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Question Box', style: TextStyle(color: Colors.white)),
        backgroundColor: widget.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(googleFormUrl),
            ),
          ),
        ],
      ),
    );
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
      answer:
          "Budgeting is the process of creating a plan to spend your money. This spending plan is called a budget. Creating this plan allows you to determine in advance whether you will have enough money to do the things you need to do or would like to do.",
    ),
    FlashCard(
      question: "What is the 50/30/20 rule?",
      answer:
          "The 50/30/20 rule is a budgeting method that allocates 50% of income to needs, 30% to wants, and 20% to savings and debt repayment.",
    ),
    FlashCard(
      question: "What is an emergency fund?",
      answer:
          "An emergency fund is money set aside for unexpected expenses such as medical bills, car repairs, or job loss. Experts recommend saving 3-6 months of living expenses.",
    ),
    FlashCard(
      question: "What is the difference between fixed and variable expenses?",
      answer:
          "Fixed expenses remain constant each month (rent, mortgage, car payment), while variable expenses fluctuate (groceries, utilities, entertainment).",
    ),
    FlashCard(
      question: "What is the envelope budgeting system?",
      answer:
          "The envelope system involves dividing cash into different envelopes for various spending categories. When an envelope is empty, you stop spending in that category until the next budget period.",
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
                      onPressed: _currentIndex < _flashcards.length - 1
                          ? _nextCard
                          : null,
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
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AppFAQPage(
                          primaryColor: widget.primaryColor,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.help_outline),
                  label: const Text('App Details & FAQ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// New App FAQ Page
class AppFAQPage extends StatefulWidget {
  final Color primaryColor;

  const AppFAQPage({
    Key? key,
    required this.primaryColor,
  }) : super(key: key);

  @override
  _AppFAQPageState createState() => _AppFAQPageState();
}

class _AppFAQPageState extends State<AppFAQPage> {
  // Question categories
  final List<String> _categories = [
    'Getting Started',
    'App Features',
    'Budget Management',
    'Transactions',
    'Technical Support',
  ];

  String _selectedCategory = 'Getting Started';

  // Map of questions and answers for each category
  final Map<String, List<FAQ>> _faqsByCategory = {
    'Getting Started': [
      FAQ(
        question: 'How do I set up my first budget?',
        answer:
            'To set up your first budget, go to the Home tab and tap on "Create Budget". You can then choose from our preset budget templates or create a custom one. Enter your income, set your spending limits for each category, and you\'re all set to start tracking!',
      ),
      FAQ(
        question: 'Can I import data from other budget apps?',
        answer:
            'Yes! Our app supports importing data from CSV files and directly from several popular budget applications. Go to Account > Settings > Import Data to get started with transferring your financial information.',
      ),
      FAQ(
        question: 'How do I customize spending categories?',
        answer:
            'You can customize spending categories by going to Home > Categories > Edit. From there, you can add new categories, rename existing ones, set custom icons, and arrange them in your preferred order. Changes will apply to all your budgets and reports.',
      ),
      FAQ(
        question: 'Is there a tutorial for new users?',
        answer:
            'Yes, we have an interactive tutorial for new users. It will automatically start when you first open the app. If you want to revisit it, go to Account > Help > App Tutorial to see step-by-step guides for all major features.',
      ),
      FAQ(
        question: 'How do I connect my bank accounts?',
        answer:
            'To connect your bank accounts, navigate to Account > Linked Accounts > Add New. Search for your bank, follow the secure authentication process, and select which accounts you want to sync. Your transactions will update automatically after linking.',
      ),
    ],
    'App Features': [
      FAQ(
        question: 'How do I create recurring transactions?',
        answer:
            'To create recurring transactions, tap the + button in the bottom navigation bar, enter the transaction details, then toggle on "Recurring" and set your preferred frequency (daily, weekly, monthly, etc.) and duration.',
      ),
      FAQ(
        question: 'Can I set spending alerts?',
        answer:
            'Yes, you can set spending alerts by going to Home > Categories, selecting a category, and tapping "Set Alert". Choose the threshold amount and you\'ll receive notifications when you reach a certain percentage of your budget.',
      ),
      FAQ(
        question: 'How do I generate financial reports?',
        answer:
            'To generate financial reports, go to the Reports tab and select the type of report you want (spending by category, monthly overview, savings tracking, etc.). You can customize the date range and export reports as PDF or CSV.',
      ),
      FAQ(
        question: 'Can I use this app offline?',
        answer:
            'Yes, you can use most features of our app offline. Your data will sync automatically when you reconnect to the internet. For features requiring real-time information like account balances, an internet connection is required.',
      ),
      FAQ(
        question: 'How do I track my financial goals?',
        answer:
            'To track financial goals, go to Home > Goals > Add New Goal. Enter your target amount, deadline, and optionally link it to specific categories or accounts. The app will show your progress and provide suggestions to help you reach your goals faster.',
      ),
    ],
    'Budget Management': [
      FAQ(
        question: 'How do I adjust my monthly budget?',
        answer:
            'To adjust your monthly budget, go to the Home tab, select the budget you want to modify, and tap "Edit Budget". You can then update income amounts, category allocations, and savings targets. Changes will apply from the current month forward unless specified.',
      ),
      FAQ(
        question: 'Can I create separate budgets for different purposes?',
        answer:
            'Yes, you can create multiple budgets for different purposes. Go to Home > Budgets > Add New Budget to set up separate budgets for personal expenses, business costs, vacation planning, or any other financial goal you have.',
      ),
      FAQ(
        question: 'How do I roll over unused budget amounts?',
        answer:
            'To roll over unused budget amounts, go to the category settings and enable "Roll Over". This will add any unspent money to next month\'s budget for that category. You can also set a maximum roll-over amount to prevent excessive accumulation.',
      ),
      FAQ(
        question: 'How are my spending insights calculated?',
        answer:
            'Spending insights are calculated using your transaction history, budget allocations, and spending patterns. The app analyzes this data to identify trends, suggest optimizations, and help you make better financial decisions based on your unique habits.',
      ),
      FAQ(
        question: 'Can I set up a joint budget with someone else?',
        answer:
            'Yes, you can set up joint budgets. Go to Home > Budgets > Create Joint Budget and enter the email of the person you want to share with. Both users will have access to view and edit the budget, and all changes will sync in real-time.',
      ),
    ],
    'Transactions': [
      FAQ(
        question: 'How do I add a new transaction?',
        answer:
            'To add a new transaction, tap the + button in the center of the bottom navigation bar. Enter the transaction amount, select a category, add notes if needed, and tap Save. You can also attach receipts by tapping the camera icon during this process.',
      ),
      FAQ(
        question: 'Can I split a transaction between categories?',
        answer:
            'Yes, you can split transactions between multiple categories. When adding or editing a transaction, tap "Split" and you can divide the amount across different budget categories. This is useful for shopping trips or bills that cover multiple expense types.',
      ),
      FAQ(
        question: 'How do I edit or delete transactions?',
        answer:
            'To edit or delete a transaction, find it in your transaction list, swipe left, and select "Edit" or "Delete". You can also tap on the transaction to view details and then use the edit or delete buttons at the bottom of the screen.',
      ),
      FAQ(
        question: 'Why are some transactions categorized automatically?',
        answer:
            'Transactions are categorized automatically using our smart recognition system that learns from your past behavior and common merchant types. The app gets better at auto-categorizing over time as you correct or confirm its suggestions.',
      ),
      FAQ(
        question: 'Can I export my transaction history?',
        answer:
            'Yes, you can export your transaction history by going to Reports > Transactions > Export. You can choose CSV or PDF format, select a date range, and filter by account or category before exporting the data to your device or cloud storage.',
      ),
    ],
    'Technical Support': [
      FAQ(
        question: 'How do I reset my password?',
        answer:
            'To reset your password, go to the login screen and tap "Forgot Password". Enter your email address and follow the instructions sent to your inbox. For security reasons, password reset links expire after 24 hours.',
      ),
      FAQ(
        question: 'Is my financial data secure?',
        answer:
            'Yes, your financial data is secured with industry-standard encryption both during transmission and storage. We use bank-level security protocols, and your sensitive information is never stored unencrypted on your device or our servers.',
      ),
      FAQ(
        question: 'How do I backup my data?',
        answer:
            'Your data is automatically backed up to your account in the cloud when connected to the internet. For manual backups, go to Account > Settings > Backup & Restore > Create Backup. You can store backups locally or in your preferred cloud storage.',
      ),
      FAQ(
        question: 'The app is crashing. What should I do?',
        answer:
            'If the app is crashing, first try closing and reopening it. If that doesn\'t work, go to Settings > Apps > Budget App > Clear Cache. If crashes persist, ensure your app is updated to the latest version or contact our support team with details about when the crashes occur.',
      ),
      FAQ(
        question: 'How do I contact customer support?',
        answer:
            'You can contact customer support by going to Account > Help > Contact Support. You can submit a ticket, start a live chat during business hours, or schedule a callback. Our support team is available 7 days a week from 8 AM to 8 PM EST.',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details & FAQ',
            style: TextStyle(color: Colors.white)),
        backgroundColor: widget.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: widget.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    'Select a category:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categories.map((category) {
                      bool isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? widget.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: widget.primaryColor,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : widget.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // FAQ list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _faqsByCategory[_selectedCategory]!.length,
              itemBuilder: (context, index) {
                final faq = _faqsByCategory[_selectedCategory]![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        faq.question,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          faq.answer,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
