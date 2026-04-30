import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/tour_provider.dart';
import 'add_edit_tour_screen.dart';
import 'tour_details_screen.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Business Tours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Animated Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ).animate().fade(duration: const Duration(seconds: 1)),

          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Consumer<TourProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (provider.tours.isEmpty) {
                        return Center(
                          child: const Text(
                            'No tours scheduled yet.\nTap + to schedule a new business tour.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ).animate().fade().scale(),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 16),
                        itemCount: provider.tours.length,
                        itemBuilder: (context, index) {
                          final tour = provider.tours[index];
                          final dateFormat = DateFormat('MMM dd, yyyy');

                          return Dismissible(
                            key: Key(tour.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF2C3E50),
                                  title: const Text('Delete Tour?', style: TextStyle(color: Colors.white)),
                                  content: const Text(
                                    'This will also delete all associated city stays and expenses. This action cannot be undone.',
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
                              provider.deleteTour(tour.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${tour.title} deleted')),
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
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.flight_takeoff, color: Colors.white),
                                ),
                                title: Text(
                                  tour.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${dateFormat.format(tour.startDate)} - ${dateFormat.format(tour.endDate)}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      if (tour.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          tour.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white54),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TourDetailsScreen(tour: tour),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ).animate().fade(duration: 500.ms, delay: (index * 100).ms).slideX();
                        },
                      );
                    },
                  ),
                ),
                
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black.withAlpha(76),
                  width: double.infinity,
                  child: const Column(
                    children: [
                      Text(
                        'All rights are reserved to Sami Ullah',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'For a personalize app contact me on email: sami5510556@gmail.com',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60), // Above footer
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddEditTourScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
