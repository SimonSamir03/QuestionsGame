import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/splash_controller.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/animated_bg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final splashController = Get.find<SplashController>();
    return Scaffold(
      body: AnimatedGameBg(
        color1: kGradientTop,
        color2: kBgColor,
        particleCount: 25,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Bouncing brain with 3D glow
              AnimatedBuilder(
                animation: splashController.bounceAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, splashController.bounceAnim.value),
                  child: child,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(rs(28)),
                    boxShadow: [
                      // 3D base shadow
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.3),
                        offset: Offset(0, rs(6)),
                        blurRadius: 0,
                      ),
                      // Neon glow
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.4),
                        blurRadius: rs(30),
                        spreadRadius: rs(5),
                      ),
                      // Far shadow
                      BoxShadow(
                        color: kPinkColor.withValues(alpha: 0.2),
                        blurRadius: rs(40),
                        spreadRadius: rs(2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(rs(24)),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: rs(120),
                      height: rs(120),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: rs(24)),
              // Title with glow
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: ShaderMask(
                  shaderCallback: (bounds) => kBrandGradient.createShader(bounds),
                  child: Text(
                    'BrainPlay',
                    style: TextStyle(
                      fontSize: kFontSizeDisplay,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      shadows: [
                        Shadow(
                          color: kPrimaryColor.withValues(alpha: 0.5),
                          blurRadius: rs(20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: rs(8)),
              FadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: Text(
                  '\u0623\u0644\u063a\u0627\u0632 \u0648\u0630\u0643\u0627\u0621',
                  style: TextStyle(
                    fontSize: kFontSizeH4,
                    color: kTextHint,
                  ),
                ),
              ),
              SizedBox(height: rs(40)),
              FadeSlideIn(
                delay: const Duration(milliseconds: 700),
                child: Container(
                  width: rs(40),
                  height: rs(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.3),
                        blurRadius: rs(12),
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: rs(2.5),
                    color: kPrimaryColor,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
