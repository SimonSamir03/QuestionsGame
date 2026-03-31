import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import 'button_3d.dart';

class GameConfirmDialog {
  GameConfirmDialog._();

  static void show({
    required String title,
    String? message,
    String? cancelLabel,
    String? confirmLabel,
    Color? confirmColor,
    required VoidCallback onConfirm,
  }) {
    final accent = confirmColor ?? kPrimaryColor;

    Get.dialog(
      Builder(builder: (context) {
      final isDark = isDarkCtx(context);
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: rs(24), vertical: rs(28)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [kDarkCardColor, HSLColor.fromColor(kDarkCardColor).withLightness(0.2).toColor()]
                  : [Colors.white, const Color(0xFFF8F6FF)],
            ),
            borderRadius: BorderRadius.circular(rs(24)),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: rs(20),
                spreadRadius: rs(2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: rs(12),
                offset: Offset(0, rs(6)),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: kFontSizeH3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: rs(12)),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextSecondary, fontSize: kFontSizeBody),
                ),
              ],
              SizedBox(height: rs(24)),
              Button3D(
                label: confirmLabel ?? 'confirm'.tr,
                color: accent,
                onTap: () {
                  Get.back();
                  onConfirm();
                },
              ),
              SizedBox(height: rs(10)),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  cancelLabel ?? 'cancel'.tr,
                  style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
                ),
              ),
            ],
          ),
        ),
      );
      }),
    );
  }
}
