import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service.dart';

class BannerAdController extends GetxController {
  BannerAd? bannerAd;
  final isAdLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AdsService().shouldShowAds) _loadAd();
  }

  void _loadAd() {
    bannerAd = AdsService().createBannerAd(
      onAdLoaded: (ad) => isAdLoaded.value = true,
      onAdFailedToLoad: (ad, error) {
        isAdLoaded.value = false;
        Future.delayed(const Duration(seconds: 30), () {
          if (!isClosed) _loadAd();
        });
      },
    );
    bannerAd!.load();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    super.onClose();
  }
}

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BannerAdController(), tag: 'banner_${identityHashCode(this)}');

    return Obx(() {
      if (!AdsService().shouldShowAds || !ctrl.isAdLoaded.value || ctrl.bannerAd == null) {
        return const SizedBox.shrink();
      }
      return Container(
        width: ctrl.bannerAd!.size.width.toDouble(),
        height: ctrl.bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: ctrl.bannerAd!),
      );
    });
  }
}
