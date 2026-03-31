import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/game_controller.dart';
import '../models/notification_model.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationItem item = Get.arguments as NotificationItem;
    final gc = Get.find<GameController>();

    return Obx(() {
      final isAr = gc.isAr;
      final lang = gc.language.value;
      final isDark = isDarkCtx(context);
      return Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: kTextPrimary,
            leading: _build3DBackButton(context),
            title: Text('notification_detail'.tr),
            centerTitle: true,
          ),
          body: AnimatedGameBg(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                left: rs(16),
                right: rs(16),
                bottom: rs(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.imageUrl != null) ...[
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(rs(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                            offset: Offset(0, rs(4)),
                            blurRadius: rs(12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(rs(16)),
                        child: Image.network(
                          item.imageUrl!,
                          width: double.infinity,
                          height: rs(200),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    SizedBox(height: rs(16)),
                  ],
                  // Title + time + body in a depth card
                  DepthCard(
                    padding: EdgeInsets.all(rs(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          item.title(lang),
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: kFontSizeH3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: rs(8)),
                        // Time
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(rs(4)),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [kPrimaryColor.withValues(alpha: 0.15), kPrimaryColor.withValues(alpha: 0.05)]),
                                borderRadius: BorderRadius.circular(rs(6)),
                              ),
                              child: Icon(Icons.access_time, color: kPrimaryColor, size: rs(16)),
                            ),
                            SizedBox(width: rs(6)),
                            Text(
                              item.timeAgo(isAr),
                              style: TextStyle(color: kTextHint, fontSize: kFontSizeCaption),
                            ),
                          ],
                        ),
                        SizedBox(height: rs(16)),
                        Divider(color: kBorderColor),
                        SizedBox(height: rs(16)),
                        // Body
                        Text(
                          item.body(lang),
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: kFontSizeBodyLarge,
                            height: 1.6,
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
      );
    });
  }

  Widget _build3DBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        margin: EdgeInsets.all(rs(8)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkCtx(context) ? kDarkCardColor : Colors.white,
              isDarkCtx(context)
                  ? HSLColor.fromColor(kDarkCardColor).withLightness(0.18).toColor()
                  : const Color(0xFFF0F0F0),
            ],
          ),
          borderRadius: BorderRadius.circular(rs(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkCtx(context) ? 0.4 : 0.10),
              offset: Offset(0, rs(3)),
              blurRadius: 0,
            ),
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.10),
              blurRadius: rs(8),
              offset: Offset(0, rs(2)),
            ),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new, size: rs(18), color: kTextPrimary),
      ),
    );
  }
}
