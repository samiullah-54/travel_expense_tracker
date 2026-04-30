import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tour_provider.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TravelExpenseTrackerApp());
}

class TravelExpenseTrackerApp extends StatelessWidget {
  const TravelExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TourProvider()..loadTours()),
      ],
      child: MaterialApp(
        title: 'Travel Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
