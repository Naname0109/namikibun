import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/providers/purchase_provider.dart';
import 'package:namikibun/providers/rewarded_ad_provider.dart';
import 'package:namikibun/services/ad_service.dart';

/// ぼかしオーバーレイ付きプレミアム誘導
class PremiumLockOverlay extends ConsumerWidget {
  const PremiumLockOverlay({
    super.key,
    required this.child,
    this.showRewardedAdOption = true,
  });

  final Widget child;
  final bool showRewardedAdOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final rewardedState = ref.watch(rewardedAdProvider);

    return Stack(
      children: [
        // ぼかしコンテンツ
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: child,
          ),
        ),
        // オーバーレイ
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 32,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  // 動画視聴ボタン
                  if (showRewardedAdOption &&
                      rewardedState.shouldShowRewardedAd &&
                      !ref.watch(isAdFreeProvider)) ...[
                    FilledButton.icon(
                      onPressed: AdService().isRewardedAdReady
                          ? () => ref.read(rewardedAdProvider.notifier).showRewardedAd()
                          : null,
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: Text(l10n.watchVideoToUnlock),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // プレミアム誘導ボタン
                  OutlinedButton(
                    onPressed: () => context.push('/settings/store'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(l10n.unlockWithPremium),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 統計プラス購入誘導カード
class StatsPlusPurchaseCard extends ConsumerWidget {
  const StatsPlusPurchaseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 36,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.detailedAnalytics,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.detailedAnalyticsDesc,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/settings/store'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(l10n.unlockWithPremiumShort),
          ),
        ],
      ),
    );
  }
}
