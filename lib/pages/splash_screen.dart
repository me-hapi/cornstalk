import 'package:flutter/material.dart';
import 'dart:math';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _checkSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkSession() async {
    final Session? session = Supabase.instance.client.auth.currentSession;

    await _controller.forward();

    if (!mounted) return;

    if (session != null) {
      // If a session exists, navigate to the home page
      context.go('/home');
    } else {
      // If no session exists, navigate to the auth page
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3FF90), // Light yellow background
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // CornStalk Logo slightly higher in the center
                Image.asset('assets/cornstalk_logo.png', height: 150, width: 150),
                const SizedBox(height: 10),
                // Text below the CornStalk Logo
                const Text(
                  'CornStalk',
                  style: TextStyle(
                    fontFamily: 'LazyDog',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF055212), // Dark green text color
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Cornfield Image at the very bottom
          Positioned(
            bottom: -3,
            left: 0,
            right: 0,
            child: Image.asset('assets/cornfield.png', fit: BoxFit.cover, height: 250),
          ),
        ],
      ),
    );
  }
}