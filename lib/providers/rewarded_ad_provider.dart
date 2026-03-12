import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/services/ad_service.dart';

/// リワード広告の24時間アンロック状態
final rewardedAdProvider =
    NotifierProvider<RewardedAdNotifier, RewardedAdState>(
        RewardedAdNotifier.new);

class RewardedAdState {
  const RewardedAdState({
    this.isUnlocked = false,
    this.lastWatchedAt,
    this.shouldShowRewardedAd = false,
  });

  final bool isUnlocked;
  final DateTime? lastWatchedAt;
  final bool shouldShowRewardedAd;

  Duration? get remainingTime {
    if (lastWatchedAt == null) return null;
    final elapsed = DateTime.now().toUtc().difference(lastWatchedAt!);
    final remaining = AppConstants.rewardedAdUnlockDuration - elapsed;
    return remaining.isNegative ? null : remaining;
  }
}

class RewardedAdNotifier extends Notifier<RewardedAdState> {
  static const _lastWatchedKey = 'rewarded_ad_last_watched';

  @override
  RewardedAdState build() {
    _initialize();
    return const RewardedAdState();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWatchedStr = prefs.getString(_lastWatchedKey);
    final shouldShow = await AdService().shouldShowRewardedAd();

    DateTime? lastWatched;
    bool isUnlocked = false;

    if (lastWatchedStr != null) {
      lastWatched = DateTime.parse(lastWatchedStr);
      final elapsed = DateTime.now().toUtc().difference(lastWatched);
      isUnlocked = elapsed < AppConstants.rewardedAdUnlockDuration;
    }

    state = RewardedAdState(
      isUnlocked: isUnlocked,
      lastWatchedAt: lastWatched,
      shouldShowRewardedAd: shouldShow,
    );

    // リワード広告をプリロード
    if (shouldShow) {
      AdService().preloadRewardedAd();
    }
  }

  /// 動画視聴完了時に呼ぶ
  Future<void> onRewardEarned() async {
    final now = DateTime.now().toUtc();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastWatchedKey, now.toIso8601String());

    state = RewardedAdState(
      isUnlocked: true,
      lastWatchedAt: now,
      shouldShowRewardedAd: state.shouldShowRewardedAd,
    );
  }

  /// リワード広告を表示
  Future<bool> showRewardedAd() async {
    return AdService().showRewardedAd(
      onRewarded: () => onRewardEarned(),
    );
  }

  /// デバッグ用: タイムスタンプリセット
  Future<void> debugResetTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastWatchedKey);
    state = RewardedAdState(
      isUnlocked: false,
      lastWatchedAt: null,
      shouldShowRewardedAd: state.shouldShowRewardedAd,
    );
  }
}
