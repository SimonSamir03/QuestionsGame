import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../routes/app_routes.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

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
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u{1f30d}', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    ).createShader(bounds),
                    child: const Text(
                      'Choose Language',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\u0627\u062e\u062a\u0631 \u0627\u0644\u0644\u063a\u0629',
                    style: TextStyle(fontSize: 22, color: Color(0xFF8892b0)),
                  ),
                  const SizedBox(height: 48),
                  _buildLanguageButton(
                    flag: '\u{1f1ec}\u{1f1e7}',
                    label: 'English',
                    subtitle: 'Play in English',
                    langCode: 'en',
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageButton(
                    flag: '\u{1f1f8}\u{1f1e6}',
                    label: '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
                    subtitle: '\u0627\u0644\u0639\u0628 \u0628\u0627\u0644\u0639\u0631\u0628\u064a',
                    langCode: 'ar',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required String flag,
    required String label,
    required String subtitle,
    required String langCode,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          final game = Get.find<GameController>();
          game.setLanguage(langCode);
          Get.offAllNamed(AppRoutes.home);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2a2a4a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white54)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF6C63FF), size: 20),
          ],
        ),
      ),
    );
  }
}
