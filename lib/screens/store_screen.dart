import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/providers/purchase_provider.dart';
import 'package:namikibun/services/purchase_service.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final purchaseState = ref.watch(purchaseStateProvider);
    final isPremium = purchaseState['premium'] ?? false;
    final isAdFree = (purchaseState['remove_ads'] ?? false) || isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.namikibunStore),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ヘッダー波ちゃん
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MoodWaveIcon(level: 5, size: 56),
            ),
          ),

          // プレミアムカード
          _PremiumCard(isPremium: isPremium),
          const SizedBox(height: 16),

          // 広告除去（買い切り）カード
          if (!isPremium)
            _AdRemovalCard(isAdFree: isAdFree),
          const SizedBox(height: 24),

          // 購入を復元
          Center(
            child: TextButton(
              onPressed: () {
                ref.read(purchaseStateProvider.notifier).restorePurchases();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.restoringPurchases)),
                );
              },
              child: Text(
                l10n.restorePurchases,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          // 利用規約
          Center(
            child: TextButton(
              onPressed: () async {
                final url = Uri.parse(AppConstants.termsOfUseUrl);
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.termsOfUse)),
                    );
                  }
                }
              },
              child: Text(
                l10n.termsOfUse,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

          // プライバシーポリシー
          Center(
            child: TextButton(
              onPressed: () async {
                final url = Uri.parse(AppConstants.privacyPolicyUrl);
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.privacyPolicy)),
                    );
                  }
                }
              },
              child: Text(
                l10n.privacyPolicy,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// プレミアム会員カード
class _PremiumCard extends ConsumerWidget {
  const _PremiumCard({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final monthlyProduct =
        PurchaseService().getProduct(AppConstants.premiumMonthlyProductId);
    final yearlyProduct =
        PurchaseService().getProduct(AppConstants.premiumYearlyProductId);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        gradient: isPremium
            ? null
            : LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.12),
                  theme.colorScheme.tertiary.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isPremium ? Colors.green.withValues(alpha: 0.08) : null,
        border: Border.all(
          color: isPremium
              ? Colors.green.withValues(alpha: 0.3)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // バッジ
            if (!isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.freeTrialDays,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // タイトル
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: isPremium ? Colors.green : theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.namikibunPremium,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPremium
                        ? Colors.green
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 機能一覧
            ...[
              l10n.noAds,
              l10n.unlimitedSlots,
              l10n.photoAttachment,
              l10n.passcodeLock,
              l10n.detailedAnalytics,
              l10n.moodByTimeSlot,
            ].map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: isPremium
                            ? Colors.green
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),

            // ボタン
            if (isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.premiumMember,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // 年額ボタン（おすすめ）
              Text(
                l10n.perMonthPrice,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ref.read(purchaseStateProvider.notifier)
                        .purchaseSubscription(AppConstants.premiumYearlyProductId);
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    l10n.yearlyPrice(yearlyProduct?.price ?? '¥4,800'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 月額ボタン
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(purchaseStateProvider.notifier)
                        .purchaseSubscription(AppConstants.premiumMonthlyProductId);
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    l10n.monthlyPrice(monthlyProduct?.price ?? '¥580'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 広告除去（買い切り）カード
class _AdRemovalCard extends ConsumerWidget {
  const _AdRemovalCard({required this.isAdFree});

  final bool isAdFree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final product =
        PurchaseService().getProduct(AppConstants.removeAdsProductId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isAdFree
                  ? Colors.green.withValues(alpha: 0.1)
                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isAdFree ? Icons.check_circle : Icons.block,
              color: isAdFree ? Colors.green : theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.removeAdsOnly,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.forThoseWhoJustWantRemoveAds,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isAdFree)
            Text(
              l10n.purchased,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            )
          else
            FilledButton(
              onPressed: () {
                ref.read(purchaseStateProvider.notifier).purchaseRemoveAds();
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(product?.price ?? '¥600'),
            ),
        ],
      ),
    );
  }
}
