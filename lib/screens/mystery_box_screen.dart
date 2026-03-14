import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mystery_box_controller.dart';
import '../controllers/game_controller.dart';

class MysteryBoxScreen extends StatefulWidget {
  const MysteryBoxScreen({super.key});

  @override
  State<MysteryBoxScreen> createState() => _MysteryBoxScreenState();
}

class _MysteryBoxScreenState extends State<MysteryBoxScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  final game = Get.find<GameController>();
  final ctrl = Get.put(MysteryBoxController());

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _shakeAnim = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  void _openBox() {
    ctrl.openBox();
    _shakeController.stop();
  }

  Future<void> _openAnotherBox() async {
    await ctrl.openAnotherBox();
    if (!ctrl.isOpened.value) {
      _shakeController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAr = game.isAr;
      final isOpened = ctrl.isOpened.value;
      final reward = ctrl.reward.value;

      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isAr ? 'صندوق الغموض' : 'Mystery Box'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isOpened) ...[
                  AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _shakeAnim.value,
                        child: child,
                      );
                    },
                    child: const Text('🎁', style: TextStyle(fontSize: 120)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isAr ? 'لديك صندوق غموض!' : 'You got a Mystery Box!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'اضغط لفتحه' : 'Tap to open it',
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _openBox,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        isAr ? 'افتح الصندوق!' : 'Open Box!',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
                if (isOpened && reward != null) ...[
                  const Text('🎉', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    isAr ? 'حصلت على:' : 'You got:',
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a4a),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          reward['type'] == 'coins' ? '🪙' : (reward['type'] == 'life' ? '❤️' : '⚡'),
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reward['label'] as String,
                          style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _openAnotherBox,
                      icon: const Icon(Icons.play_circle),
                      label: Text(isAr ? 'شاهد إعلان لصندوق آخر' : 'Watch Ad for Another Box'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4ECDC4),
                        side: const BorderSide(color: Color(0xFF4ECDC4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      isAr ? 'متابعة' : 'Continue',
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
