import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tour.dart';
import '../providers/tour_provider.dart';
import 'add_edit_city_stay_screen.dart';
import 'city_details_screen.dart';
import 'add_edit_tour_screen.dart';
import '../widgets/glass_card.dart';

class TourDetailsScreen extends StatefulWidget {
  final Tour tour;

  const TourDetailsScreen({super.key, required this.tour});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<TourProvider>(context, listen: false);
        provider.loadCityStays(widget.tour.id);
        provider.loadTourDeductions(widget.tour.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');

    return Consumer<TourProvider>(
      builder: (context, provider, child) {
        // Find latest tour object to reflect any edits made in AddEditTourScreen
        final latestTour = provider.tours.firstWhere(
          (t) => t.id == widget.tour.id, 
          orElse: () => widget.tour,
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(latestTour.title, style: const TextStyle(color: Colors.white)),
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
                      builder: (context) => AddEditTourScreen(tour: latestTour),
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
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
              SafeArea(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : Column(
                        children: [
                          if (latestTour.advanceCash > 0 || latestTour.miscAdvanceCash > 0)
                            GlassCard(
                              margin: const EdgeInsets.all(16.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Advance Cash', style: TextStyle(color: Colors.white70)),
                                        Text('PKR ${latestTour.advanceCash.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    if (latestTour.advanceCash > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Remaining Advance', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                          Text('PKR ${(latestTour.advanceCash - provider.currentTourAdvanceDeducted).toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                    const Divider(color: Colors.white24, height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Misc Advance', style: TextStyle(color: Colors.white70)),
                                        Text('PKR ${latestTour.miscAdvanceCash.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    if (latestTour.miscAdvanceCash > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Remaining Misc', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                          Text('PKR ${(latestTour.miscAdvanceCash - provider.currentTourMiscDeducted).toStringAsFixed(2)}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ).animate().fade().slideY(begin: -0.2, end: 0),
                          Expanded(
                            child: provider.currentCityStays.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No cities added to this tour yet.\nTap + to add a city stay.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, color: Colors.white70),
                                    ),
                                  ).animate().fade().scale()
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 80, top: 16),
                                    itemCount: provider.currentCityStays.length,
                                    itemBuilder: (context, index) {
                    final cityStay = provider.currentCityStays[index];
                    return Dismissible(
                      key: Key(cityStay.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF2C3E50),
                            title: const Text('Delete City?', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'This will also delete connected expenses. Are you sure?',
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
                        provider.deleteCityStay(cityStay.id, widget.tour.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${cityStay.cityName} deleted')),
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
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.location_city, color: Colors.white),
                          ),
                          title: Text(
                            cityStay.cityName,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '${dateFormat.format(cityStay.arrivalDate)} - ${dateFormat.format(cityStay.departureDate)}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CityDetailsScreen(cityStay: cityStay),
                              ),
                            );
                                  },
                                ),
                              ),
                            ).animate().fade(duration: 400.ms, delay: (index * 100).ms).slideX();
                          },
                        ),
                      ),
                    ],
                  ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditCityStayScreen(tourId: widget.tour.id),
                ),
              );
            },
            tooltip: 'Add City Stay',
            child: const Icon(Icons.add_location_alt),
          ),
        );
      },
    );
  }
}
