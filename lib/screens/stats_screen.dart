import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/providers/stats_provider.dart';
import 'package:namikibun/providers/tag_provider.dart';
import 'package:namikibun/services/feature_gate.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/ad_banner.dart';
import 'package:namikibun/widgets/detailed_stats_section.dart';
import 'package:namikibun/widgets/empty_state.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';
import 'package:namikibun/widgets/premium_lock_overlay.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedMonth = ref.watch(selectedStatsMonthProvider);
    final statsAsync = ref.watch(monthlyStatsProvider);

    return SafeArea(
      child: Column(
        children: [
          // 月ヘッダー
          _StatsMonthHeader(
            month: selectedMonth,
            onPrevious: () =>
                ref.read(selectedStatsMonthProvider.notifier).state =
                    DateTime(selectedMonth.year, selectedMonth.month - 1),
            onNext: () {
              final now = AppDateUtils.getLogicalToday();
              final nextMonth =
                  DateTime(selectedMonth.year, selectedMonth.month + 1);
              if (!nextMonth.isAfter(DateTime(now.year, now.month))) {
                ref.read(selectedStatsMonthProvider.notifier).state = nextMonth;
              }
            },
            canGoNext: () {
              final now = AppDateUtils.getLogicalToday();
              final nextMonth =
                  DateTime(selectedMonth.year, selectedMonth.month + 1);
              return !nextMonth.isAfter(DateTime(now.year, now.month));
            },
          ),

          // 統計コンテンツ
          Expanded(
            child: statsAsync.when(
              data: (stats) {
                if (stats.totalRecordDays < 3) {
                  return EmptyState(
                    icon: Icons.bar_chart,
                    message: l10n.statsMinDays,
                  );
                }
                return _StatsContent(stats: stats);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.error}: $e')),
            ),
          ),

          // バナー広告
          const AdBanner(),
        ],
      ),
    );
  }
}

class _StatsMonthHeader extends StatelessWidget {
  const _StatsMonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.canGoNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool Function() canGoNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
          ),
          Expanded(
            child: Text(
              l10n.monthYear(month.year, month.month),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: canGoNext() ? onNext : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends ConsumerWidget {
  const _StatsContent({required this.stats});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final weeklyAsync = ref.watch(weeklyStatsProvider);
    final gate = ref.watch(featureGateProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // 週間サマリー
        weeklyAsync.when(
          data: (weekly) {
            if (weekly.thisWeekRecordCount <= 0) return const SizedBox.shrink();
            final card = Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _WeeklySummaryCard(weekly: weekly),
            );
            if (gate.canViewWeeklyReport) return card;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: PremiumLockOverlay(child: _WeeklySummaryCard(weekly: weekly)),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),

        // 時間帯別平均気分（棒グラフ）
        _SectionTitle(title: l10n.averageMoodByTime),
        const SizedBox(height: 8),
        _SlotAverageBarChart(stats: stats),
        const SizedBox(height: 20),

        // 月全体の気分推移（折れ線グラフ）
        _SectionTitle(title: l10n.monthlyMoodTrend),
        const SizedBox(height: 8),
        _DailyTrendLineChart(dailyAverages: stats.dailyAverages),
        const SizedBox(height: 20),

        // タグ分析
        if (stats.tagCounts.isNotEmpty) ...[
          _SectionTitle(title: l10n.averageMoodByTag),
          const SizedBox(height: 8),
          if (gate.canViewTagAnalytics)
            _TagAnalyticsSection(stats: stats)
          else
            PremiumLockOverlay(child: _TagAnalyticsSection(stats: stats)),
          const SizedBox(height: 20),
        ],

        // 今月のハイライト
        _SectionTitle(title: l10n.thisMonthHighlights),
        const SizedBox(height: 8),
        _HighlightCards(stats: stats),
        const SizedBox(height: 20),

        // 詳細分析（統計プラス）
        if (gate.canUseStatsPlus) ...[
          _SectionTitle(title: l10n.detailedAnalytics),
          const SizedBox(height: 8),
          const DetailedStatsSection(),
        ] else ...[
          const StatsPlusPurchaseCard(),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _SlotAverageBarChart extends StatelessWidget {
  const _SlotAverageBarChart({required this.stats});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entries = stats.slotAverages.entries.toList();

    if (entries.isEmpty) {
      return SizedBox(height: 150, child: Center(child: Text(l10n.noData)));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: BarChart(
        BarChartData(
          maxY: 5.0,
          minY: 1.0,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 4,
                getTitlesWidget: (value, _) {
                  if ((value - 5).abs() < 0.01) {
                    return SizedBox(
                      width: 48,
                      height: 24,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MoodWaveIconMini(level: 5, size: 14),
                          const SizedBox(width: 2),
                          Text(l10n.moodGood, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    );
                  }
                  if ((value - 1).abs() < 0.01) {
                    return SizedBox(
                      width: 48,
                      height: 24,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MoodWaveIconMini(level: 1, size: 14),
                          const SizedBox(width: 2),
                          Text(l10n.moodBad, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final slotId = entries[index].key;
                  final name = stats.slotNames[slotId] ?? slotId;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(name, style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ),
          barGroups: entries.asMap().entries.map((e) {
            final avg = e.value.value;
            final colorLevel = avg.round().clamp(1, 5);
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: avg,
                  color: AppConstants.moodColors[colorLevel],
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DailyTrendLineChart extends StatelessWidget {
  const _DailyTrendLineChart({required this.dailyAverages});

  final Map<String, double> dailyAverages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sortedEntries = dailyAverages.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) {
      return SizedBox(height: 150, child: Center(child: Text(l10n.noData)));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].value));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: LineChart(
        LineChartData(
          minY: 1.0,
          maxY: 5.0,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 4,
                getTitlesWidget: (value, _) {
                  if ((value - 5).abs() < 0.01) {
                    return SizedBox(
                      width: 48,
                      height: 24,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MoodWaveIconMini(level: 5, size: 14),
                          const SizedBox(width: 2),
                          Text(l10n.moodGood, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    );
                  }
                  if ((value - 1).abs() < 0.01) {
                    return SizedBox(
                      width: 48,
                      height: 24,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MoodWaveIconMini(level: 1, size: 14),
                          const SizedBox(width: 2),
                          Text(l10n.moodBad, style: TextStyle(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (sortedEntries.length / 5).ceilToDouble().clamp(1, double.infinity),
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedEntries.length) {
                    return const SizedBox.shrink();
                  }
                  final date = sortedEntries[index].key;
                  final day = date.split('-').last;
                  return Text(
                    l10n.dayLabel(int.parse(day)),
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: spots.length >= 3,
              curveSmoothness: 0.3,
              color: theme.colorScheme.primary,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, _, _) {
                  final level = spot.y.round().clamp(1, 5);
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppConstants.moodColors[level]!,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _HighlightCards extends StatelessWidget {
  const _HighlightCards({required this.stats});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        if (stats.bestRecord != null)
          Expanded(
            child: _HighlightCard(
              label: l10n.bestDay,
              moodLevel: stats.bestRecord!.moodLevel,
              date: _formatHighlightDate(stats.bestRecord!.date),
              memo: stats.bestRecord!.memo,
              color: AppConstants.moodColors[stats.bestRecord!.moodLevel]!,
            ),
          ),
        if (stats.bestRecord != null && stats.worstRecord != null)
          const SizedBox(width: 12),
        if (stats.worstRecord != null)
          Expanded(
            child: _HighlightCard(
              label: l10n.worstDay,
              moodLevel: stats.worstRecord!.moodLevel,
              date: _formatHighlightDate(stats.worstRecord!.date),
              memo: stats.worstRecord!.memo,
              color: AppConstants.moodColors[stats.worstRecord!.moodLevel]!,
            ),
          ),
      ],
    );
  }

  String _formatHighlightDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day}';
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.label,
    required this.moodLevel,
    required this.date,
    this.memo,
    required this.color,
  });

  final String label;
  final int moodLevel;
  final String date;
  final String? memo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              MoodWaveIcon(level: moodLevel, size: 28),
              const SizedBox(width: 8),
              Text(
                date,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (memo != null && memo!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              memo!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// 週間サマリーカード
class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.weekly});

  final WeeklyStats weekly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final avgLevel = weekly.thisWeekAverage.round().clamp(1, 5);
    final color = AppConstants.moodColors[avgLevel]!;
    final change = weekly.weekOverWeekChange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklySummary,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              MoodWaveIcon(level: avgLevel, size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.average(weekly.thisWeekAverage.toStringAsFixed(1)),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    l10n.recordCount(weekly.thisWeekRecordCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: change >= 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        change >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 16,
                        color: change >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: change >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// タグ分析セクション
class _TagAnalyticsSection extends ConsumerWidget {
  const _TagAnalyticsSection({required this.stats});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tagsAsync = ref.watch(tagProvider);

    // DBタグから色マップを構築
    final tagColorMap = <String, Color>{};
    if (tagsAsync.hasValue) {
      for (final tag in tagsAsync.value!) {
        tagColorMap[tag.name] = tagColorFromHex(tag.colorHex);
      }
    }

    // 使用回数でソート
    final sortedTags = stats.tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedTags.isNotEmpty ? sortedTags.first.value : 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Column(
        children: sortedTags.map((entry) {
          final tag = entry.key;
          final count = entry.value;
          final avg = stats.tagAverages[tag] ?? 3.0;
          final avgLevel = avg.round().clamp(1, 5);
          final tagColor = tagColorMap[tag] ?? AppConstants.tagColors[tag] ?? theme.colorScheme.outline;
          final ratio = count / maxCount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // タグ名
                SizedBox(
                  width: 64,
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tagColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 横棒グラフ
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 14,
                      backgroundColor: tagColor.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        tagColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 平均値
                SizedBox(
                  width: 30,
                  child: Text(
                    avg.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 4),
                // 平均気分アイコン（大きく）
                MoodWaveIconMini(level: avgLevel, size: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
