import 'package:flutter/material.dart';
import 'dart:async';

import '../../home/views/home_view.dart';
import '../services/supabase_service.dart';
import 'login.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    final isLoggedIn = SupabaseService.instance.isLoggedIn;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => isLoggedIn ? const HomeView() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B4C7D), // AppColors.primary
              Color(0xFF8B5A9B), // AppColors.primaryDark
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -80,
              top: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 150,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Game controller icon
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_esports_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // App name
                      const Text(
                        'SEWA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'PS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tagline
                      Text(
                        'PlayStation Rental Service',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.7),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}