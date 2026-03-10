import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:namikibun/constants/app_constants.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _initialized = false;

  /// 広告SDKの初期化
  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
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
}
