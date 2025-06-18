import 'dart:math';
import 'package:flutter/material.dart';
import 'package:client/authentication/login.dart';
import 'package:client/authentication/register.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for subtle app bar fade-in
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
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
          ),
          automaticallyImplyLeading: false,
          title: FadeTransition(
            opacity: _fadeAnimation,
            child: const Text(
              'save to serve',
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.login,
                    color: Colors.white, semanticLabel: 'Login'),
                text: 'Connexion',
              ),
              Tab(
                icon: Icon(Icons.person_add,
                    color: Colors.white, semanticLabel: 'Register'),
                text: "S'inscrire",
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFA5D6A7), // Mint Green
                Color(0xFFFFFFFF), // White for clean background
              ],
            ),
          ),
          child: Column(
            children: [
              // Eco-friendly message
              Container(
                margin: const EdgeInsets.all(16.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '"Rejoignez Save to Serve pour sauver des repas en sur place !"',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // TabBarView
              const Expanded(
                child: TabBarView(
                  children: [
                    LoginScreen(),
                    RegisterScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
