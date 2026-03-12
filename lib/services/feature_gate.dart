import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/providers/purchase_provider.dart';
import 'package:namikibun/providers/rewarded_ad_provider.dart';

/// デバッグモード無効化フラグ（リリース挙動テスト用）
final debugFeatureOverrideProvider = StateProvider<bool>((ref) => false);

/// FeatureGate: 各機能のアクセス判定
final featureGateProvider = Provider<FeatureGate>((ref) {
  final purchaseNotifier = ref.watch(purchaseStateProvider.notifier);
  ref.watch(purchaseStateProvider);
  final rewardedAdState = ref.watch(rewardedAdProvider);
  final debugOverride = ref.watch(debugFeatureOverrideProvider);

  return FeatureGate(
    purchaseNotifier: purchaseNotifier,
    rewardedAdState: rewardedAdState,
    debugOverride: debugOverride,
  );
});

class FeatureGate {
  const FeatureGate({
    required this.purchaseNotifier,
    required this.rewardedAdState,
    required this.debugOverride,
  });

  final PurchaseStateNotifier purchaseNotifier;
  final RewardedAdState rewardedAdState;
  final bool debugOverride;

  bool get _isDebugUnlocked => kDebugMode && !debugOverride;

  bool canAddSlot(int currentCount) {
    if (_isDebugUnlocked) return true;
    return purchaseNotifier.isPremium ||
        currentCount < AppConstants.freeSlotLimit;
  }

  bool get canAttachPhoto {
    if (_isDebugUnlocked) return true;
    return purchaseNotifier.isPremium;
  }

  bool get canUsePasscode {
    if (_isDebugUnlocked) return true;
    return purchaseNotifier.isPremium;
  }

  bool get canViewTagAnalytics {
    if (_isDebugUnlocked) return true;
    return purchaseNotifier.isPremium ||
        purchaseNotifier.isAdFree ||
        rewardedAdState.isUnlocked;
  }

  bool get canViewWeeklyReport {
    if (_isDebugUnlocked) return true;
    return purchaseNotifier.isPremium ||
        purchaseNotifier.isAdFree ||
        rewardedAdState.isUnlocked;
  }

  bool get canUseStatsPlus {
    if (_isDebugUnlocked) return true;
    return purchaseNotifier.isPremium;
  }

  bool get isAdFree {
    if (_isDebugUnlocked) return true;
    return purchaseNotifier.isAdFree;
  }
}
