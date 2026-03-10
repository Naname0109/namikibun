import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/services/purchase_service.dart';

/// 広告除去の状態を管理するプロバイダー
final isAdRemovedProvider =
    NotifierProvider<IsAdRemovedNotifier, bool>(IsAdRemovedNotifier.new);

class IsAdRemovedNotifier extends Notifier<bool> {
  @override
  bool build() {
    // 初期値はfalse、initializeで非同期に更新
    _initialize();
    return false;
  }

  Future<void> _initialize() async {
    final service = PurchaseService();
    final removed = await service.isAdRemoved();
    if (removed) {
      state = true;
    }

    // 購入状態変更時にstateを更新
    service.onPurchaseUpdated = (isRemoved) {
      state = isRemoved;
    };
  }

  void setAdRemoved(bool value) {
    state = value;
  }

  /// 広告除去を購入
  Future<void> purchaseRemoveAds() async {
    await PurchaseService().purchaseRemoveAds();
  }

  /// 購入を復元
  Future<void> restorePurchases() async {
    await PurchaseService().restorePurchases();
  }
}
