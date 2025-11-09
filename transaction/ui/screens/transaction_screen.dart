import 'package:code_fit/features/transaction/ui/screens/second_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../model/transaction_item.dart';
import '../widgets/transaction_button.dart';
import '../widgets/transactions.dart';

class TransactionHomeScreen extends StatefulWidget {
  const TransactionHomeScreen({super.key});

  @override
  State<TransactionHomeScreen> createState() => _TransactionHomeScreenState();
}

class _TransactionHomeScreenState extends State<TransactionHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fabController;
  String _searchQuery = '';
  bool _isGridView = true;
  String _selectedCategory = 'All';

  final List<TransactionItem> transactions = [
    TransactionItem("Transaction 1", Icons.send, Colors.blue, (page) => ScaleTransition1(page)),
    TransactionItem("Transaction 2", Icons.call_received, Colors.green, (page) => ScaleTransition2(page)),
    TransactionItem("Transaction 3", Icons.receipt_long, Colors.orange, (page) => ScaleTransition3(page)),
    TransactionItem("Transaction 4", Icons.account_balance, Colors.purple, (page) => ScaleTransition4(page)),
    TransactionItem("Transaction 5", Icons.phone_android, Colors.red, (page) => ScaleTransition5(page)),
    TransactionItem("Transaction 6", Icons.phone, Colors.teal, (page) => ScaleTransition6(page)),
    TransactionItem("Transaction 7", Icons.store, Colors.indigo, (page) => ScaleTransition7(page)),
    TransactionItem("Transaction 8", Icons.request_page, Colors.amber, (page) => FadeRoute1(page)),
    TransactionItem("Transaction 9", Icons.call_split, Colors.pink, (page) => SlideTransition1(page)),
    TransactionItem("Transaction 10", Icons.money_off, Colors.brown, (page) => ScaleTransition1(page)),
    TransactionItem("Transaction 11", Icons.trending_up, Colors.cyan, (page) => ScaleTransition2(page)),
    TransactionItem("Transaction 12", Icons.savings, Colors.lightGreen, (page) => ScaleTransition3(page)),
    TransactionItem("Transaction 13", Icons.money, Colors.deepOrange, (page) => ScaleTransition4(page)),
    TransactionItem("Transaction 14", Icons.currency_exchange, Colors.deepPurple, (page) => ScaleTransition5(page)),
    TransactionItem("Transaction 15", Icons.security, Colors.blueGrey, (page) => ScaleTransition6(page)),
    TransactionItem("Transaction 16", Icons.electrical_services, Colors.yellow, (page) => ScaleTransition7(page)),
    TransactionItem("Transaction 17", Icons.shopping_cart, Colors.lime, (page) => FadeRoute1(page)),
    TransactionItem("Transaction 18", Icons.account_balance_wallet, Colors.grey, (page) => SlideTransition1(page)),
    TransactionItem("Transaction 19", Icons.volunteer_activism, Colors.red, (page) => ScaleTransition1(page)),
    TransactionItem("Transaction 20", Icons.subscriptions, Colors.lightBlue, (page) => ScaleTransition2(page)),
  ];

  final List<String> categories = ['All', 'Popular', 'Recent', 'Favorites'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fabController.dispose();
    super.dispose();
  }

  List<TransactionItem> get filteredTransactions {
    return transactions.where((transaction) {
      final matchesSearch = _searchQuery.isEmpty ||
          transaction.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredTransactions;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
        SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 50,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Transactions',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),



          // Transaction Grid/List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0 , vertical: 25.0),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(
              child: _buildEmptyState(),
            )
                : _isGridView
                ? SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildAnimatedGridItem(filtered[index], index);
                },
                childCount: filtered.length,
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildAnimatedListItem(filtered[index], index);
                },
                childCount: filtered.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Floating Action Button
    );
  }


  Widget _buildAnimatedGridItem(TransactionItem transaction, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Clamp the value between 0.0 and 1.0
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue,
          child: Opacity(
            opacity: clampedValue, // Use clamped value
            child: TransactionButton(
              transaction: transaction,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  transaction.transitionBuilder(TransactionScreen(
                    transactionName: transaction.name,
                    color: transaction.color,
                    icon: transaction.icon,
                  )),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedListItem(TransactionItem transaction, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        // Clamp the value between 0.0 and 1.0
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(50 * (1 - clampedValue), 0),
          child: Opacity(
            opacity: clampedValue, // Use clamped value
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: transaction.color.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: transaction.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.color,
                    size: 28,
                  ),
                ),
                title: Text(
                  transaction.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Tap to continue',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    transaction.transitionBuilder(TransactionScreen(
                      transactionName: transaction.name,
                      color: transaction.color,
                      icon: transaction.icon,
                    )),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}