import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();

    return Obx(() {
      final isAr = game.isAr;

      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isAr ? '\u0627\u0644\u0625\u0639\u062f\u0627\u062f\u0627\u062a' : 'Settings'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(isAr ? '\u0627\u0644\u0635\u0648\u062a' : 'Audio', [
              _buildSwitch(
                icon: Icons.volume_up,
                label: isAr ? '\u0627\u0644\u0645\u0624\u062b\u0631\u0627\u062a \u0627\u0644\u0635\u0648\u062a\u064a\u0629' : 'Sound Effects',
                value: game.soundEnabled.value,
                onChanged: (val) {
                  game.setSoundEnabled(val);
                  SoundService().setSoundEnabled(val);
                },
              ),
              _buildSwitch(
                icon: Icons.music_note,
                label: isAr ? '\u0627\u0644\u0645\u0648\u0633\u064a\u0642\u0649' : 'Background Music',
                value: game.musicEnabled.value,
                onChanged: (val) {
                  game.setMusicEnabled(val);
                  SoundService().setMusicEnabled(val);
                  if (val) {
                    SoundService().startBackgroundMusic();
                  } else {
                    SoundService().stopBackgroundMusic();
                  }
                },
              ),
            ]),
            const SizedBox(height: 20),
            _buildSection(isAr ? '\u0627\u0644\u0644\u063a\u0629' : 'Language', [
              _buildLanguageSelector(game, isAr),
            ]),
            const SizedBox(height: 20),
            _buildSection(isAr ? '\u0627\u0644\u062d\u0633\u0627\u0628' : 'Account', [
              _buildInfoTile(Icons.star, isAr ? '\u0627\u0644\u062d\u0627\u0644\u0629' : 'Status',
                  game.isPremium.value ? (isAr ? '\u0628\u0631\u064a\u0645\u064a\u0648\u0645' : 'Premium') : (isAr ? '\u0645\u062c\u0627\u0646\u064a' : 'Free')),
              _buildInfoTile(Icons.local_fire_department, isAr ? '\u0623\u064a\u0627\u0645 \u0645\u062a\u062a\u0627\u0644\u064a\u0629' : 'Streak',
                  '${game.streakDays.value} ${isAr ? '\u064a\u0648\u0645' : 'days'}'),
            ]),
            const SizedBox(height: 20),
            _buildSection(isAr ? '\u062d\u0648\u0644 \u0627\u0644\u062a\u0637\u0628\u064a\u0642' : 'About', [
              _buildInfoTile(Icons.info, isAr ? '\u0627\u0644\u0625\u0635\u062f\u0627\u0631' : 'Version', '1.0.0'),
              _buildInfoTile(Icons.code, isAr ? '\u0627\u0644\u0645\u0637\u0648\u0631' : 'Developer', 'BrainPlay Team'),
            ]),
          ],
        ),
      );
    });
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a4a),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C63FF)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildLanguageSelector(GameController game, bool isAr) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.language, color: Color(0xFF6C63FF)),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                _langButton('EN', 'en', game),
                const SizedBox(width: 12),
                _langButton('\u0639\u0631\u0628\u064a', 'ar', game),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langButton(String label, String code, GameController game) {
    final isSelected = game.language.value == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => game.setLanguage(code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF6C63FF) : Colors.white24),
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: FontWeight.bold,
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C63FF)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Text(value, style: const TextStyle(color: Colors.white54)),
    );
  }
}
