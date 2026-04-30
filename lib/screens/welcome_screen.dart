import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';
import 'dart:ui';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = true;
  String? _userName;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedName = prefs.getString('userName');
    
    if (storedName != null && storedName.isNotEmpty) {
      setState(() {
        _userName = storedName;
        _isLoading = false;
      });

      // Show welcome back for 2 seconds, then navigate
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C3E50), Color(0xFF3498DB), Color(0xFF8E44AD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .shimmer(duration: const Duration(seconds: 5), color: Colors.white24),

          // Center Card setup
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(51)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: _userName != null ? _buildWelcomeBack() : _buildNameInput(),
                ),
              ),
            ).animate().fade(duration: 800.ms).scale(curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBack() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 60)
            .animate().scale(delay: 400.ms).shake(),
        const SizedBox(height: 24),
        Text(
          'Welcome Back,',
          style: TextStyle(fontSize: 24, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Text(
          '$_userName!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate().slideY(begin: 0.5, end: 0, delay: 200.ms),
        const SizedBox(height: 16),
        const Text(
          'Preparing your business tours...',
          style: TextStyle(fontSize: 16, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildNameInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.travel_explore, color: Colors.white, size: 60)
            .animate().slideY(begin: -1, end: 0).fade(),
        const SizedBox(height: 24),
        const Text(
          'Let\'s Personalize Your Experience',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withAlpha(25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.person, color: Colors.white70),
          ),
          onSubmitted: (_) => _saveName(),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF3498DB),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _saveName,
          child: const Text('Get Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ).animate().scale(delay: 500.ms),
      ],
    );
  }
}
