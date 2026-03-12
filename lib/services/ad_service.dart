import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/constants/app_constants.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static const _firstLaunchKey = 'first_launch_date';

  bool _initialized = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  bool get isRewardedAdReady => _rewardedAd != null;
  bool get isRewardedAdLoading => _isRewardedAdLoading;

  /// 広告SDKの初期化 + 初回起動日記録
  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;

    // 初回起動日の記録
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_firstLaunchKey)) {
      await prefs.setString(_firstLaunchKey, DateTime.now().toUtc().toIso8601String());
    }
  }

  /// プラットフォーム別のバナー広告ユニットIDを取得
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.adBannerUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.adBannerUnitIdIos;
    }
    return '';
  }

  /// プラットフォーム別のリワード広告ユニットIDを取得
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.rewardedAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.rewardedAdUnitIdIos;
    }
    return '';
  }

  /// バナー広告を表示すべきか（常にtrue、isAdFreeは呼び出し側で判定）
  bool get shouldShowBannerAd => true;

  /// リワード動画を表示すべきか（初回起動から24時間以上経過）
  Future<bool> shouldShowRewardedAd() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchStr = prefs.getString(_firstLaunchKey);
    if (firstLaunchStr == null) return false;
    final firstLaunch = DateTime.parse(firstLaunchStr);
    return DateTime.now().toUtc().difference(firstLaunch).inHours >= 24;
  }

  /// リワード広告をプリロード
  void preloadRewardedAd() {
    if (_rewardedAd != null || _isRewardedAdLoading) return;
    final unitId = rewardedAdUnitId;
    if (unitId.isEmpty) return;

    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedAdLoading = false;
        },
      ),
    );
  }

  /// リワード広告を表示し、完了コールバックを呼ぶ
  Future<bool> showRewardedAd({
    required void Function() onRewarded,
  }) async {
    if (_rewardedAd == null) return false;

    final ad = _rewardedAd!;
    _rewardedAd = null;

    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadRewardedAd(); // 次の広告をプリロード
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preloadRewardedAd();
      },
    );

    await ad.show(onUserEarnedReward: (_, reward) {
      rewarded = true;
      onRewarded();
    });

    return rewarded;
  }
}
