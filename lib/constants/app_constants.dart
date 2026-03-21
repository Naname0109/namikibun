import 'package:flutter/material.dart';

import 'package:namikibun/l10n/app_localizations.dart';

/// アプリ全体で使用する定数
class AppConstants {
  AppConstants._();

  // 外部リンク
  static const String termsOfUseUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
  static const String privacyPolicyUrl =
      'https://naname0109.github.io/namikibun/';

  // 日付境界: 午前4時
  static const int dateBoundaryHour = 4;

  // 気分レベル
  static const int moodLevelMin = 1;
  static const int moodLevelMax = 5;

  // メモの最大文字数
  static const int memoMaxLength = 50;

  // 気分レベルに対応するラベル（ローカライズ版）
  static Map<int, String> localizedMoodLabels(AppLocalizations l10n) => {
    1: l10n.moodVeryBad,
    2: l10n.moodBadLabel,
    3: l10n.moodNormal,
    4: l10n.moodGoodLabel,
    5: l10n.moodVeryGood,
  };

  // 気分レベルに対応する色
  static const Map<int, Color> moodColors = {
    1: Color(0xFFE76F51), // コーラルレッド
    2: Color(0xFFFF8C42), // オレンジ
    3: Color(0xFFFFD93D), // イエロー
    4: Color(0xFF95D5B2), // ライトグリーン
    5: Color(0xFF4ECDC4), // ミントグリーン
  };

  // デフォルトタグ（日本語）
  static const List<String> defaultTags = [
    '仕事',
    '運動',
    '食事',
    '人間関係',
    '天気',
    'その他',
  ];

  // デフォルトタグ（英語）
  static const List<String> defaultTagsEn = [
    'Work',
    'Exercise',
    'Meals',
    'Social',
    'Weather',
    'Other',
  ];

  // タグに対応する色
  static const Map<String, Color> tagColors = {
    '仕事': Color(0xFF4A90D9),     // 青
    '運動': Color(0xFF4ECDC4),     // 緑
    '食事': Color(0xFFFF8C42),     // オレンジ
    '人間関係': Color(0xFFE88EBF), // ピンク
    '天気': Color(0xFF7EC8E3),     // 水色
    'その他': Color(0xFF9E9E9E),   // グレー
    'Work': Color(0xFF4A90D9),
    'Exercise': Color(0xFF4ECDC4),
    'Meals': Color(0xFFFF8C42),
    'Social': Color(0xFFE88EBF),
    'Weather': Color(0xFF7EC8E3),
    'Other': Color(0xFF9E9E9E),
  };

  // デフォルトスロット（日本語）
  static const List<Map<String, dynamic>> defaultSlots = [
    {
      'id': 'morning',
      'name': '朝',
      'order_index': 0,
      'start_time': '06:00',
      'end_time': '12:00',
      'notify_time': '08:00',
    },
    {
      'id': 'afternoon',
      'name': '昼',
      'order_index': 1,
      'start_time': '12:00',
      'end_time': '18:00',
      'notify_time': '13:00',
    },
    {
      'id': 'evening',
      'name': '夜',
      'order_index': 2,
      'start_time': '18:00',
      'end_time': '24:00',
      'notify_time': '21:00',
    },
  ];

  // デフォルトスロット（英語）
  static const List<Map<String, dynamic>> defaultSlotsEn = [
    {
      'id': 'morning',
      'name': 'Morning',
      'order_index': 0,
      'start_time': '06:00',
      'end_time': '12:00',
      'notify_time': '08:00',
    },
    {
      'id': 'afternoon',
      'name': 'Afternoon',
      'order_index': 1,
      'start_time': '12:00',
      'end_time': '18:00',
      'notify_time': '13:00',
    },
    {
      'id': 'evening',
      'name': 'Evening',
      'order_index': 2,
      'start_time': '18:00',
      'end_time': '24:00',
      'notify_time': '21:00',
    },
  ];

  // 広告関連
  static const String adBannerUnitIdAndroid = 'ca-app-pub-2099665494657429/4390211966';
  static const String adBannerUnitIdIos = 'ca-app-pub-2099665494657429/1808280656';
  static const String rewardedAdUnitIdAndroid = 'ca-app-pub-2099665494657429/1676748283';
  static const String rewardedAdUnitIdIos = 'ca-app-pub-2099665494657429/2035365575';

  // 課金関連 - Product IDs（サブスクモデル）
  static const String premiumMonthlyProductId = 'namikibun_premium_monthly';
  static const String premiumYearlyProductId = 'namikibun_premium_yearly';
  static const String removeAdsProductId = 'namikibun_remove_ads2';

  static const Set<String> allProductIds = {
    premiumMonthlyProductId,
    premiumYearlyProductId,
    removeAdsProductId,
  };

  static const Set<String> subscriptionProductIds = {
    premiumMonthlyProductId,
    premiumYearlyProductId,
  };

  // 旧Product IDs（移行判定用）
  static const String legacyRemoveAdsProductId = 'remove_ads';
  static const Set<String> legacyProductIds = {
    'namikibun_slot_expansion',
    'namikibun_photo_memo',
    'namikibun_privacy_lock',
    'namikibun_stats_plus',
    'namikibun_all_in_one',
  };

  // 無料スロット上限
  static const int freeSlotLimit = 3;

  // リワード動画アンロック時間（24時間）
  static const Duration rewardedAdUnlockDuration = Duration(hours: 24);
}
