import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/city_stay.dart';
import '../providers/tour_provider.dart';
import 'add_edit_expense_screen.dart';
import 'add_edit_city_stay_screen.dart';
import '../widgets/glass_card.dart';

class CityDetailsScreen extends StatefulWidget {
  final CityStay cityStay;

  const CityDetailsScreen({super.key, required this.cityStay});

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TourProvider>(context, listen: false).loadExpenses(widget.cityStay.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Consumer<TourProvider>(
      builder: (context, provider, child) {
        final latestCityStay = provider.currentCityStays.firstWhere(
          (cs) => cs.id == widget.cityStay.id,
          orElse: () => widget.cityStay,
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text('${latestCityStay.cityName} Expenses', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditCityStayScreen(
                        tourId: latestCityStay.tourId,
                        cityStay: latestCityStay,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                ),
              ),
              SafeArea(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Column(
                        children: [
                    GlassCard(
                      margin: const EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              '${dateFormat.format(latestCityStay.arrivalDate)} - ${dateFormat.format(latestCityStay.departureDate)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            const Text('Total Expenses', style: TextStyle(fontSize: 18, color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                              'PKR ${provider.getTotalExpensesForCityStay(latestCityStay.id).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fade().slideY(begin: -0.2, end: 0),
                    Expanded(
                      child: provider.currentExpenses.isEmpty
                          ? const Center(
                              child: Text(
                                'No expenses logged yet.\nTap + to add an expense.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ).animate().fade()
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: provider.currentExpenses.length,
                              itemBuilder: (context, index) {
                                final expense = provider.currentExpenses[index];
                                return Dismissible(
                                  key: Key(expense.id),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFF2C3E50),
                                        title: const Text('Delete Expense?', style: TextStyle(color: Colors.white)),
                                        content: const Text(
                                          'Are you sure you want to delete this expense?',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  onDismissed: (direction) {
                                    provider.deleteExpense(expense.id, widget.cityStay.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${expense.category} expense deleted')),
                                    );
                                  },
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withAlpha(200),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  child: GlassCard(
                                    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: ListTile(
                                      leading: expense.imagePath != null
                                          ? CircleAvatar(
                                              backgroundImage: FileImage(File(expense.imagePath!)),
                                            )
                                          : CircleAvatar(
                                              backgroundColor: Colors.white24,
                                              child: _getCategoryIcon(expense.category),
                                            ),
                                      title: Text(expense.category, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dateFormat.format(expense.date), style: const TextStyle(color: Colors.white70)),
                                          if (expense.description.isNotEmpty) Text(expense.description, style: const TextStyle(color: Colors.white54)),
                                        ],
                                      ),
                                      trailing: Text(
                                        'PKR ${expense.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddEditExpenseScreen(
                                              cityStayId: widget.cityStay.id,
                                              expense: expense,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ).animate().fade(duration: 400.ms, delay: (index * 50).ms).slideX();
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF8E44AD),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditExpenseScreen(cityStayId: widget.cityStay.id),
                ),
              );
            },
            tooltip: 'Add Expense',
            child: const Icon(Icons.add_shopping_cart),
          ),
        );
      },
    );
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Fuel':
        return const Icon(Icons.local_gas_station, color: Colors.white);
      case 'Tolls':
        return const Icon(Icons.toll, color: Colors.white);
      case 'Hotel':
        return const Icon(Icons.hotel, color: Colors.white);
      case 'Food':
        return const Icon(Icons.restaurant, color: Colors.white);
      case 'Ironing':
        return const Icon(Icons.dry_cleaning, color: Colors.white);
      default:
        // PKR Note icon roughly maps to money
        return const Icon(Icons.payments, color: Colors.white);
    }
  }
}
