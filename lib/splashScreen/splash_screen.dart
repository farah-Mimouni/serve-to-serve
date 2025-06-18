import 'dart:async';

import 'package:flutter/material.dart';
import '../authentication/auth_screen.dart';
import '../global/global.dart';
import '../mainScreens/home_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  startTimer() {
    Timer(const Duration(seconds: 2), () async {
      if (firebaseAuth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Start animation
    _animationController.forward();

    // Start navigation timer
    startTimer();
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2E7D32), // Forest Green
              Color(0xFFA5D6A7), // Mint Green
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Image
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/welcome.png',
                      height: 120, // Smaller for balance
                      width: 120,
                      fit: BoxFit.contain,
                      semanticLabel: 'Logo Save to Serve',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // App Name
                  const Text(
                    'Économisez des aliments avec Save to Serve',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tagline
                  const Text(
                    'Sauvez les repas excédentaires et économisez',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Eco Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sauvez les repas excédentaires !',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
