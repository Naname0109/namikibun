import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/services/purchase_service.dart';

/// 購入状態: { 'premium': bool, 'remove_ads': bool }
final purchaseStateProvider =
    NotifierProvider<PurchaseStateNotifier, Map<String, bool>>(
        PurchaseStateNotifier.new);

class PurchaseStateNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    _initialize();
    return {'premium': false, 'remove_ads': false};
  }

  Future<void> _initialize() async {
    final service = PurchaseService();
    final states = await service.getAllPurchaseStates();
    state = states;

    service.onPurchaseUpdated = (key, value) {
      state = {...state, key: value};
    };
  }

  bool get isPremium => state['premium'] ?? false;
  bool get isAdFree =>
      isPremium || (state['remove_ads'] ?? false);

  bool get canUseUnlimitedSlots => isPremium;
  bool get canAttachPhoto => isPremium;
  bool get canUsePasscode => isPremium;
  bool get canUseStatsPlus => isPremium;

  Future<void> purchaseSubscription(String productId) async {
    await PurchaseService().purchaseSubscription(productId);
  }

  Future<void> purchaseRemoveAds() async {
    await PurchaseService().purchaseNonConsumable(AppConstants.removeAdsProductId);
  }

  Future<void> restorePurchases() async {
    await PurchaseService().restorePurchases();
  }

  /// デバッグ用
  void debugRefresh() {
    _initialize();
  }
}

// --- 便利Provider ---

final isPremiumProvider = Provider<bool>((ref) {
  final notifier = ref.watch(purchaseStateProvider.notifier);
  ref.watch(purchaseStateProvider);
  return notifier.isPremium;
});

final isAdFreeProvider = Provider<bool>((ref) {
  final notifier = ref.watch(purchaseStateProvider.notifier);
  ref.watch(purchaseStateProvider);
  return notifier.isAdFree;
});

final canUseUnlimitedSlotsProvider = Provider<bool>((ref) {
  final notifier = ref.watch(purchaseStateProvider.notifier);
  ref.watch(purchaseStateProvider);
  return notifier.canUseUnlimitedSlots;
});

final canAttachPhotoProvider = Provider<bool>((ref) {
  final notifier = ref.watch(purchaseStateProvider.notifier);
  ref.watch(purchaseStateProvider);
  return notifier.canAttachPhoto;
});

final canUsePasscodeProvider = Provider<bool>((ref) {
  final notifier = ref.watch(purchaseStateProvider.notifier);
  ref.watch(purchaseStateProvider);
  return notifier.canUsePasscode;
});

final canUseStatsPlusProvider = Provider<bool>((ref) {
  final notifier = ref.watch(purchaseStateProvider.notifier);
  ref.watch(purchaseStateProvider);
  return notifier.canUseStatsPlus;
});

/// 後方互換
final isAdRemovedProvider = isAdFreeProvider;
