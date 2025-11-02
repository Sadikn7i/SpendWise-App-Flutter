import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ExpenseTrackerHome(onThemeToggle: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });
}

class ExpenseTrackerHome extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const ExpenseTrackerHome({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<ExpenseTrackerHome> createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Expense> _expenses = [];
  String? _selectedFilter;
  String _searchQuery = '';
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Entertainment',
    'Health',
    'Other',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Bills': Icons.receipt_long,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Other': Icons.more_horiz,
  };

  final Map<String, Color> _categoryColors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Shopping': Colors.purple,
    'Bills': Colors.red,
    'Entertainment': Colors.pink,
    'Health': Colors.green,
    'Other': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  double get totalExpenses {
    return filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> get filteredExpenses {
    var expenses = _expenses;
    
    if (_selectedFilter != null) {
      expenses = expenses.where((e) => e.category == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      expenses = expenses
          .where((e) =>
              e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    return expenses;
  }

  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (var category in _categories) {
      totals[category] = _expenses
          .where((e) => e.category == category)
          .fold(0, (sum, e) => sum + e.amount);
    }
    return totals;
  }

  void _showAddExpenseBottomSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String selectedCategory = 'Food';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_card,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Add New Expense',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'e.g., Lunch at restaurant',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      hintText: '0',
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: '¥ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final isSelected = category == selectedCategory;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedCategory = category;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _categoryColors[category]
                                : Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _categoryColors[category]!
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _categoryIcons[category],
                                color: isSelected ? Colors.white : null,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Add additional details...',
                      prefixIcon: const Icon(Icons.note),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isEmpty ||
                                amountController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill required fields'),
                                ),
                              );
                              return;
                            }

                            final amount = double.tryParse(amountController.text);
                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a valid amount'),
                                ),
                              );
                              return;
                            }

                            setState(() {
                              _expenses.add(
                                Expense(
                                  id: DateTime.now().toString(),
                                  title: titleController.text,
                                  amount: amount,
                                  category: selectedCategory,
                                  date: DateTime.now(),
                                  notes: notesController.text.isEmpty
                                      ? null
                                      : notesController.text,
                                ),
                              );
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Expense added successfully!'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add Expense',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showAddExpenseBottomSheet,
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search expenses...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
        ),

        // Total Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Total Expenses',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¥${totalExpenses.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${filteredExpenses.length} transactions',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Category Filter Chips
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedFilter == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              ..._categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    avatar: Icon(_categoryIcons[category], size: 18),
                    label: Text(category),
                    selected: _selectedFilter == category,
                    selectedColor: _categoryColors[category]?.withOpacity(0.3),
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? category : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),

        // Expense List
        Expanded(
          child: filteredExpenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No expenses found'
                            : 'No expenses yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search'
                            : 'Tap the button below to add one',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return Dismissible(
                      key: Key(expense.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _expenses.remove(expense);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Expense deleted'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                setState(() {
                                  _expenses.add(expense);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _categoryColors[expense.category]?.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _categoryIcons[expense.category],
                              color: _categoryColors[expense.category],
                            ),
                          ),
                          title: Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              if (expense.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  expense.notes!,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          trailing: Text(
                            '¥${expense.amount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    final totals = categoryTotals;
    final maxAmount = totals.values.isEmpty ? 1.0 : totals.values.reduce(math.max);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.pie_chart,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Spending by Category',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ..._categories.map((category) {
                  final amount = totals[category] ?? 0;
                  final percentage = maxAmount > 0 ? (amount / maxAmount) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _categoryIcons[category],
                                  color: _categoryColors[category],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '¥${amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _categoryColors[category]!,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.insights,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Quick Stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatRow('Total Expenses', '¥${totalExpenses.toStringAsFixed(0)}'),
                _buildStatRow('Total Transactions', '${_expenses.length}'),
                _buildStatRow(
                  'Average per Transaction',
                  _expenses.isEmpty
                      ? '¥0'
                      : '¥${(totalExpenses / _expenses.length).toStringAsFixed(0)}',
                ),
                _buildStatRow(
                  'Highest Expense',
                  _expenses.isEmpty
                      ? '¥0'
                      : '¥${_expenses.map((e) => e.amount).reduce(math.max).toStringAsFixed(0)}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
