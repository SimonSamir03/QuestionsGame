import 'dart:io';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  // Set to false for production release
  static const bool _isTestMode = false;

  // ─── Test Ad Unit IDs (Google's official test IDs) ───
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // ─── Production Ad Unit IDs ───
  // Android
  static const String _androidBannerId = 'ca-app-pub-5077591301078112/2994533536';
  static const String _androidInterstitialId = 'ca-app-pub-5077591301078112/3661252527';
  static const String _androidRewardedId = 'ca-app-pub-5077591301078112/6454936829';
  // iOS
  static const String _iosBannerId = 'ca-app-pub-5077591301078112/1370131104';
  static const String _iosInterstitialId = 'ca-app-pub-5077591301078112/1589622951';
  static const String _iosRewardedId = 'ca-app-pub-5077591301078112/9559466529';

  // ─── Ad Unit ID Getters ───
  static String get bannerAdUnitId {
    if (_isTestMode) return _testBannerId;
    return Platform.isAndroid ? _androidBannerId : _iosBannerId;
  }

  static String get interstitialAdUnitId {
    if (_isTestMode) return _testInterstitialId;
    return Platform.isAndroid ? _androidInterstitialId : _iosInterstitialId;
  }

  static String get rewardedAdUnitId {
    if (_isTestMode) return _testRewardedId;
    return Platform.isAndroid ? _androidRewardedId : _iosRewardedId;
  }

  // ─── State ───
  bool _isPremium = false;
  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  void setPremium(bool premium) => _isPremium = premium;
  bool get isPremium => _isPremium;
  bool get shouldShowAds => !_isPremium;

  // ─── Initialize ───
  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
    debugPrint('✅ AdMob initialized');

    // Pre-load ads
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  // ─── Banner Ad ───
  BannerAd createBannerAd({
    AdSize adSize = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded ?? (_) => debugPrint('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad?.call(ad, error);
        },
      ),
    );
  }

  // ─── Interstitial Ad ───
  void _loadInterstitialAd() {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          debugPrint('Interstitial failed to load: $error');
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  Future<void> showInterstitial() async {
    if (_isPremium) return;

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Interstitial failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
          _loadInterstitialAd();
        },
      );
      await _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not ready, loading...');
      _loadInterstitialAd();
    }
  }

  // ─── Rewarded Ad ───
  void _loadRewardedAd() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          debugPrint('Rewarded ad failed to load: $error');
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  Future<bool> showRewarded() async {
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not ready, loading...');
      _loadRewardedAd();
      return false;
    }

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        rewarded = true;
      },
    );

    // Wait a moment for the callback to fire
    await Future.delayed(const Duration(milliseconds: 500));
    return rewarded;
  }

  /// Check if a rewarded ad is ready to show
  bool get isRewardedAdReady => _rewardedAd != null;

  // ─── Mystery Box Reward Generator ───
  Map<String, dynamic> generateMysteryReward() {
    final random = Random();
    final rewards = [
      {'type': 'coins', 'amount': 20, 'label': '20 Coins'},
      {'type': 'coins', 'amount': 50, 'label': '50 Coins'},
      {'type': 'coins', 'amount': 100, 'label': '100 Coins'},
      {'type': 'life', 'amount': 1, 'label': '1 Extra Life'},
      {'type': 'life', 'amount': 3, 'label': '3 Extra Lives'},
      {'type': 'double', 'amount': 2, 'label': 'Double Coins Next Round'},
    ];
    return rewards[random.nextInt(rewards.length)];
  }

  /// Dispose all loaded ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
