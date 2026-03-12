import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/constants/app_constants.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  // SharedPreferences キー
  static const _keyPremium = 'subscription_premium_active';
  static const _keyRemoveAds = 'purchased_remove_ads';
  static const _keyLegacyPremium = 'legacy_premium_migrated';
  static const _legacyAdRemovedKey = 'ad_removed';

  // 旧ばら売り商品のキー（移行用）
  static const _legacyKeys = [
    'purchased_remove_ads',
    'purchased_slot_expansion',
    'purchased_photo_memo',
    'purchased_privacy_lock',
    'purchased_stats_plus',
    'purchased_all_in_one',
  ];

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  final Map<String, ProductDetails> _products = {};

  bool get isAvailable => _isAvailable;
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);
  ProductDetails? getProduct(String productId) => _products[productId];

  /// 購入状態変更のコールバック
  void Function(String productId, bool purchased)? onPurchaseUpdated;

  /// 初期化：ストア接続 + 購入ストリーム監視 + 旧データ移行
  Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {},
    );

    final response = await _iap.queryProductDetails(AppConstants.allProductIds);
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }

    // 旧購入者の移行
    await _migrateLegacyPurchases();

    // 起動時にサブスク状態を検証（少し遅延させてUIちらつき防止）
    Future.delayed(const Duration(seconds: 2), () => _validateSubscriptions());
  }

  /// 旧ばら売り購入者を移行
  Future<void> _migrateLegacyPurchases() async {
    final prefs = await SharedPreferences.getInstance();

    // 旧ad_removedキーの移行
    final legacyAdRemoved = prefs.getBool(_legacyAdRemovedKey) ?? false;
    if (legacyAdRemoved && !(prefs.getBool(_keyRemoveAds) ?? false)) {
      await prefs.setBool(_keyRemoveAds, true);
    }

    // 旧ばら売り購入者→プレミアム扱い（all_in_one, slot_expansion等）
    if (!(prefs.getBool(_keyLegacyPremium) ?? false)) {
      bool hasLegacy = false;
      for (final key in _legacyKeys) {
        if (key == 'purchased_remove_ads') continue; // 広告除去は別扱い
        if (prefs.getBool(key) ?? false) {
          hasLegacy = true;
          break;
        }
      }
      if (hasLegacy) {
        await prefs.setBool(_keyPremium, true);
        await prefs.setBool(_keyLegacyPremium, true);
      }
    }
  }

  /// プレミアム（サブスク）が有効か
  Future<bool> isPremiumActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPremium) ?? false;
  }

  /// 広告除去が購入済みか
  Future<bool> isAdRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRemoveAds) ?? false;
  }

  /// 全購入状態をまとめて取得
  Future<Map<String, bool>> getAllPurchaseStates() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'premium': prefs.getBool(_keyPremium) ?? false,
      'remove_ads': prefs.getBool(_keyRemoveAds) ?? false,
    };
  }

  /// サブスクを購入
  Future<void> purchaseSubscription(String productId) async {
    final product = _products[productId];
    if (product == null) return;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 買い切り商品を購入
  Future<void> purchaseNonConsumable(String productId) async {
    final product = _products[productId];
    if (product == null) return;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// 購入を復元（UIから手動で呼ばれた場合）
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// 起動時のサブスク検証（キャッシュリセット→リストア）
  Future<void> _validateSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final isLegacy = prefs.getBool(_keyLegacyPremium) ?? false;
    if (!isLegacy) {
      // 旧買い切りユーザーでない場合のみサブスクをリセット
      // リストア完了後にストリームで再設定される
      await prefs.setBool(_keyPremium, false);
    }
    await _iap.restorePurchases();
  }

  /// 購入ストリームのハンドラ
  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (AppConstants.subscriptionProductIds.contains(purchase.productID)) {
            await _savePremiumState(true);
            onPurchaseUpdated?.call('premium', true);
          } else if (purchase.productID == AppConstants.removeAdsProductId) {
            await _saveAdFreeState(true);
            onPurchaseUpdated?.call('remove_ads', true);
          }
          // 旧商品IDの復元にも対応
          if (AppConstants.legacyProductIds.contains(purchase.productID)) {
            await _savePremiumState(true);
            onPurchaseUpdated?.call('premium', true);
          }
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _savePremiumState(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremium, active);
  }

  Future<void> _saveAdFreeState(bool purchased) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemoveAds, purchased);
  }

  // --- デバッグ用メソッド ---

  Future<void> debugSetPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPremium, value);
    onPurchaseUpdated?.call('premium', value);
  }

  Future<void> debugSetAdFree(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRemoveAds, value);
    onPurchaseUpdated?.call('remove_ads', value);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
