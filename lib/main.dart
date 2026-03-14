import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/storage_service.dart';
import 'services/ads_service.dart';
import 'routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'bindings/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await AdsService().initialize();
  runApp(const BrainPlayApp());
}

class BrainPlayApp extends StatelessWidget {
  const BrainPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BrainPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF4ECDC4),
          error: Color(0xFFFF5252),
        ),
        useMaterial3: true,
      ),
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
