import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), _navigate);
  }

  void _navigate() {
    if (StorageService().hasKey('language')) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.language);
    }
  }
}
