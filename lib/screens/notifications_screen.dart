import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brainplay/constants/constants.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/game_controller.dart';
import '../models/notification_model.dart';
import '../routes/app_routes.dart';
import '../widgets/animated_bg.dart';
import '../widgets/depth_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(NotificationsController());
    final gc = Get.find<GameController>();

    return Obx(() {
      final isAr = gc.isAr;
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
            title: Text('notifications_title'.tr),
            centerTitle: true,
            actions: [
              if (ctrl.notifications.isNotEmpty)
                TextButton(
                  onPressed: ctrl.markAllAsRead,
                  child: Text(
                    'notifications_mark_all'.tr,
                    style: TextStyle(color: kPrimaryColor, fontSize: kFontSizeCaption),
                  ),
                ),
            ],
          ),
          body: AnimatedGameBg(
            child: ctrl.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ctrl.notifications.isEmpty
                    ? _buildEmpty(isAr)
                    : RefreshIndicator(
                        onRefresh: ctrl.fetchNotifications,
                        child: ListView.builder(
                          padding: EdgeInsets.only(
                            top: kToolbarHeight + MediaQuery.of(context).padding.top + rs(8),
                            left: rs(12),
                            right: rs(12),
                            bottom: rs(12),
                          ),
                          itemCount: ctrl.notifications.length,
                          itemBuilder: (context, index) {
                            final item = ctrl.notifications[index];
                            return Obx(() => _buildNotificationCard(context, item, ctrl, gc));
                          },
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

  Widget _buildEmpty(bool isAr) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: rs(64), color: kTextDisabled),
          SizedBox(height: rs(16)),
          Text(
            'notifications_empty'.tr,
            style: TextStyle(color: kTextHint, fontSize: kFontSizeBodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationItem item,
    NotificationsController ctrl,
    GameController gc,
  ) {
    final lang = gc.language.value;
    final isAr = gc.isAr;
    final isRead = ctrl.isRead(item.id);
    final isDark = isDarkCtx(context);

    return DepthCard(
      margin: EdgeInsets.only(bottom: rs(10)),
      padding: EdgeInsets.all(rs(14)),
      accentColor: isRead ? null : kPrimaryColor,
      elevation: isRead ? 0.5 : 0.9,
      onTap: () {
        ctrl.markAsRead(item.id);
        Get.toNamed(AppRoutes.notificationDetail, arguments: item);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon / image
          Container(
            width: rs(44),
            height: rs(44),
            decoration: BoxDecoration(
              gradient: isRead
                  ? null
                  : LinearGradient(colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.7)]),
              color: isRead ? kBorderColor.withValues(alpha: 0.3) : null,
              borderRadius: BorderRadius.circular(rs(12)),
              boxShadow: isRead
                  ? []
                  : [
                      BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: rs(8), offset: Offset(0, rs(2))),
                    ],
            ),
            child: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(rs(12)),
                    child: Image.network(item.imageUrl!, fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.notifications_outlined,
                    color: isRead ? kTextDisabled : Colors.white,
                    size: rs(22),
                  ),
          ),
          SizedBox(width: rs(12)),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title(lang),
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: kFontSizeBody,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: rs(8),
                        height: rs(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: kPrimaryColor.withValues(alpha: 0.5), blurRadius: rs(6)),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: rs(4)),
                Text(
                  item.body(lang),
                  style: TextStyle(color: kTextSecondary, fontSize: kFontSizeCaption),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: rs(6)),
                Text(
                  item.timeAgo(isAr),
                  style: TextStyle(color: kTextHint, fontSize: kFontSizeTiny),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
