import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isAr = gameState.language == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isAr ? 'الإعدادات' : 'Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(isAr ? 'الصوت' : 'Audio', [
            _buildSwitch(
              icon: Icons.volume_up,
              label: isAr ? 'المؤثرات الصوتية' : 'Sound Effects',
              value: gameState.soundEnabled,
              onChanged: (val) {
                gameState.setSoundEnabled(val);
                SoundService().setSoundEnabled(val);
              },
            ),
            _buildSwitch(
              icon: Icons.music_note,
              label: isAr ? 'الموسيقى' : 'Background Music',
              value: gameState.musicEnabled,
              onChanged: (val) {
                gameState.setMusicEnabled(val);
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
          _buildSection(isAr ? 'اللغة' : 'Language', [
            _buildLanguageSelector(gameState, isAr),
          ]),
          const SizedBox(height: 20),
          _buildSection(isAr ? 'الحساب' : 'Account', [
            _buildInfoTile(Icons.star, isAr ? 'الحالة' : 'Status',
                gameState.isPremium ? (isAr ? 'بريميوم' : 'Premium') : (isAr ? 'مجاني' : 'Free')),
            _buildInfoTile(Icons.local_fire_department, isAr ? 'أيام متتالية' : 'Streak',
                '${gameState.streakDays} ${isAr ? 'يوم' : 'days'}'),
          ]),
          const SizedBox(height: 20),
          _buildSection(isAr ? 'حول التطبيق' : 'About', [
            _buildInfoTile(Icons.info, isAr ? 'الإصدار' : 'Version', '1.0.0'),
            _buildInfoTile(Icons.code, isAr ? 'المطور' : 'Developer', 'BrainPlay Team'),
          ]),
        ],
      ),
    );
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
        activeColor: const Color(0xFF4ECDC4),
      ),
    );
  }

  Widget _buildLanguageSelector(GameState gameState, bool isAr) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.language, color: Color(0xFF6C63FF)),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                _langButton('EN', 'en', gameState),
                const SizedBox(width: 12),
                _langButton('عربي', 'ar', gameState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langButton(String label, String code, GameState gameState) {
    final isSelected = gameState.language == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => gameState.setLanguage(code),
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
