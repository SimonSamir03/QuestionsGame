import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brainplay/constants/constants.dart';
import 'controllers/game_controller.dart';
import 'services/storage_service.dart';
import 'services/ads_service.dart';
import 'services/notification_service.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'bindings/app_bindings.dart';
import 'translations/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await StorageService.init();
  // Firebase — skip if not configured (e.g. missing google-services.json)
  try {
    await Firebase.initializeApp();
    if (kDebugMode) print('FCM: Firebase initialized');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService().init();
    if (kDebugMode) print('FCM: token=${StorageService().fcmToken}');
  } catch (e) {
    if (kDebugMode) print('FCM: Firebase init FAILED: $e');
  }
  await AdsService().initialize();
  // Put GameController early so it's available before GetMaterialApp builds.
  Get.put(GameController(), permanent: true);
  runApp(const BrainPlayApp());
}

class BrainPlayApp extends StatelessWidget {
  const BrainPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final gc = Get.find<GameController>();
    return GetMaterialApp(
      title: gc.language.value == 'ar' ? kAppNameAr : kAppNameEn,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Locale(gc.language.value),
      fallbackLocale: const Locale('en'),
      theme: buildAppTheme(gc.language.value, gc.isDarkMode.value),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
