import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/providers/stats_provider.dart';
import 'package:namikibun/providers/tag_provider.dart';

class DetailedStatsSection extends ConsumerWidget {
  const DetailedStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailedAsync = ref.watch(detailedStatsProvider);

    return detailedAsync.when(
      data: (stats) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 月別比較
          if (stats.lastMonthAverage != null && stats.thisMonthAverage != null) ...[
            _MonthComparisonCard(stats: stats),
            const SizedBox(height: 24),
          ],

          // タグ相関インサイト
          if (stats.tagCorrelations.isNotEmpty) ...[
            _TagCorrelationInsights(
              correlations: stats.tagCorrelations,
            ),
            const SizedBox(height: 24),
          ],

          // 曜日別パターン
          if (stats.weekdayPattern.isNotEmpty) ...[
            _WeekdayPatternChart(pattern: stats.weekdayPattern),
            const SizedBox(height: 24),
          ],
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// 月別比較カード
class _MonthComparisonCard extends StatelessWidget {
  const _MonthComparisonCard({required this.stats});

  final DetailedStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thisAvg = stats.thisMonthAverage!;
    final lastAvg = stats.lastMonthAverage!;
    final diff = thisAvg - lastAvg;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '月別比較',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MonthBar(
                  label: '先月',
                  average: lastAvg,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MonthBar(
                  label: '今月',
                  average: thisAvg,
                  color: AppConstants.moodColors[thisAvg.round().clamp(1, 5)]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: diff >= 0
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                diff >= 0
                    ? '先月より +${diff.toStringAsFixed(1)} 改善'
                    : '先月より ${diff.toStringAsFixed(1)} 低下',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: diff >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({
    required this.label,
    required this.average,
    required this.color,
  });

  final String label;
  final double average;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          average.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (average / 5).clamp(0, 1),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// タグ相関インサイト
class _TagCorrelationInsights extends ConsumerWidget {
  const _TagCorrelationInsights({required this.correlations});

  final Map<String, double> correlations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tagsAsync = ref.watch(tagProvider);
    final tagColorMap = <String, Color>{};
    if (tagsAsync.hasValue) {
      for (final tag in tagsAsync.value!) {
        tagColorMap[tag.name] = tagColorFromHex(tag.colorHex);
      }
    }

    // 差分の絶対値でソート
    final sorted = correlations.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'タグ相関インサイト',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.take(5).map((entry) {
            final tagColor = tagColorMap[entry.key] ?? theme.colorScheme.outline;
            final diff = entry.value;
            final isPositive = diff >= 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: tagColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '「${entry.key}」タグの日は平均気分が${isPositive ? '+' : ''}${diff.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 曜日別パターンチャート
class _WeekdayPatternChart extends StatelessWidget {
  const _WeekdayPatternChart({required this.pattern});

  final Map<int, double> pattern;

  static const _weekdayLabels = {
    1: '月',
    2: '火',
    3: '水',
    4: '木',
    5: '金',
    6: '土',
    7: '日',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '曜日別パターン',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: 5.5,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      getTitlesWidget: (value, _) {
                        final day = value.toInt() + 1;
                        return Text(
                          _weekdayLabels[day] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: (day == 6 || day == 7)
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (index) {
                  final weekday = index + 1;
                  final avg = pattern[weekday] ?? 0;
                  final hasData = avg > 0;
                  final colorLevel = hasData ? avg.round().clamp(1, 5) : 3;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: hasData ? avg : 3,
                        color: hasData
                            ? AppConstants.moodColors[colorLevel]
                            : Colors.grey.withValues(alpha: 0.15),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        borderSide: hasData
                            ? BorderSide.none
                            : const BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
