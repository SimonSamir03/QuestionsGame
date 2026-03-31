import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/game_controller.dart';
import '../controllers/challenge_controller.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController bounceController;
  late Animation<double> bounceAnim;

  @override
  void onInit() {
    super.onInit();
    bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    bounceAnim = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.easeInOut),
    );
    _initAndNavigate();
  }

  Future<void> _initAndNavigate() async {
    // Run auth + minimum splash display in parallel
    await Future.wait([
      _deviceAuth(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    _navigate();
  }

  Future<void> _deviceAuth() async {
    try {
      final storage   = StorageService();
      final deviceId  = await _ensureDeviceId(storage);
      final info      = await _getDeviceInfo();

      if (kDebugMode) print('AUTH: starting deviceAuth... deviceId=$deviceId');
      if (kDebugMode) print('AUTH: fcmToken=${storage.fcmToken != null ? "present" : "null"}');

      final result = await ApiService().deviceAuth(
        deviceId   : deviceId,
        platform   : info['platform']!,
        model      : info['model'],
        deviceName : info['device_name'],
        osVersion  : info['os_version'],
        appVersion : '1.0.0',
        fcmToken   : storage.fcmToken,
      );

      if (result != null) {
        final user = result['user'] as Map<String, dynamic>;
        final gc = Get.find<GameController>();
        gc.syncFromApi(user);
        gc.fetchConfig(); // fire-and-forget: fetch remote config
        if (kDebugMode) print('AUTH: success, token saved=${storage.authToken != null}');

        // Always sync FCM token via dedicated endpoint
        final fcm = storage.fcmToken;
        if (fcm != null) {
          try {
            await ApiService().syncFcmToken(fcm);
          } catch (e) {
            if (kDebugMode) print('AUTH: fcm sync error: $e');
          }
        } else {
          if (kDebugMode) print('AUTH: WARNING — fcm token is null!');
        }

        // Sync completed levels from server
        await _syncProgress();

        // Load challenges after auth succeeds
        Get.put(ChallengeController(), permanent: true);
      } else {
        if (kDebugMode) print('AUTH: deviceAuth returned null');
      }
    } catch (e, st) {
      // Offline — continue with local data
      if (kDebugMode) {
        print('AUTH: deviceAuth exception: $e\n$st');
      }
    }
  }

  /// Returns a stable device ID that survives app reinstalls.
  /// Generates a deterministic ID from hardware info — no random UUIDs.
  Future<String> _ensureDeviceId(StorageService storage) async {
    final plugin = DeviceInfoPlugin();
    String id;
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      // Stable hardware identifiers that survive reinstalls and OS updates
      final raw = '${info.brand}:${info.model}:${info.device}:${info.board}:${info.hardware}';
      id = const Uuid().v5(Namespace.dns.value, raw);
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      // identifierForVendor persists until all apps from the vendor are uninstalled
      id = info.identifierForVendor ?? const Uuid().v5(Namespace.dns.value, info.utsname.machine);
    } else {
      // Fallback: use stored ID or generate one
      id = storage.deviceId ?? const Uuid().v4();
    }

    storage.deviceId = id;
    return id;
  }

  Future<Map<String, String?>> _getDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      return {
        'platform'    : 'android',
        'model'       : '${info.manufacturer} ${info.model}',
        'device_name' : info.device,
        'os_version'  : 'Android ${info.version.release}',
      };
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return {
        'platform'    : 'ios',
        'model'       : info.utsname.machine,
        'device_name' : info.name,
        'os_version'  : 'iOS ${info.systemVersion}',
      };
    }
    return {'platform': 'android', 'model': null, 'device_name': null, 'os_version': null};
  }

  Future<void> _syncProgress() async {
    try {
      final result = await ApiService().getUserProgress();
      if (result != null && result['progress'] is Map) {
        final progress = Map<String, dynamic>.from(result['progress']);
        final gc = Get.find<GameController>();
        final merged = Map<String, Set<int>>.from(gc.completedLevels);
        for (final entry in progress.entries) {
          final levels = Set<int>.from((entry.value as List).map((e) => (e as num).toInt()));
          merged[entry.key] = (merged[entry.key] ?? {})..addAll(levels);
        }
        gc.completedLevels.value = merged;
      }
    } catch (e) {
      if (kDebugMode) print('SYNC PROGRESS: error → $e');
    }
  }

  void _navigate() {
    if (StorageService().hasKey('language')) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.language);
    }
  }

  @override
  void onClose() {
    bounceController.dispose();
    super.onClose();
  }
}
