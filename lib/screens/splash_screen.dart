import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // Ensure SplashController is running (it handles navigation after 3s)
    Get.find<SplashController>();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16213e), Color(0xFF1a1a2e)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                ),
                child: const Text('\u{1f9e0}', style: TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                ).createShader(bounds),
                child: const Text(
                  'BrainPlay',
                  style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              const Text('\u0623\u0644\u063a\u0627\u0632 \u0648\u0630\u0643\u0627\u0621', style: TextStyle(fontSize: 20, color: Color(0xFF8892b0))),
              const SizedBox(height: 40),
              const SizedBox(
                width: 40, height: 40,
                child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF6C63FF)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
