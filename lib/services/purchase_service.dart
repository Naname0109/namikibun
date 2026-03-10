import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/constants/app_constants.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  static const _adRemovedKey = 'ad_removed';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  ProductDetails? _product;

  bool get isAvailable => _isAvailable;
  ProductDetails? get product => _product;

  /// 購入状態変更のコールバック
  void Function(bool isAdRemoved)? onPurchaseUpdated;

  /// 初期化：ストア接続 + 購入ストリーム監視
  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    // 購入ストリームを監視（未完了トランザクションの処理含む）
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );

    // 商品情報を取得
    final response = await _iap.queryProductDetails(
      {AppConstants.removeAdsProductId},
    );
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
    }
  }

  /// ローカルの購入状態を確認
  Future<bool> isAdRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adRemovedKey) ?? false;
  }

  /// 広告除去を購入
  Future<void> purchaseRemoveAds() async {
    if (_product == null) return;

    final purchaseParam = PurchaseParam(productDetails: _product!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 購入を復元
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// 購入ストリームのハンドラ
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != AppConstants.removeAdsProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _savePurchaseState(true);
          onPurchaseUpdated?.call(true);
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          break;
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// 購入状態をローカルに保存
  Future<void> _savePurchaseState(bool removed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adRemovedKey, removed);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
