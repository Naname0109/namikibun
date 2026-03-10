import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/providers/stats_provider.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/empty_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  return const EmptyState(
                    icon: Icons.bar_chart,
                    message: '3日以上記録すると\n統計が表示されます',
                  );
                }
                return _StatsContent(stats: stats);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('エラー: $e')),
            ),
          ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              '${month.year}年${month.month}月',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: canGoNext() ? onNext : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats});

  final MonthlyStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // 時間帯別平均気分（棒グラフ）
        _SectionTitle(title: '時間帯別の平均気分'),
        const SizedBox(height: 8),
        _SlotAverageBarChart(stats: stats),
        const SizedBox(height: 24),

        // 月全体の気分推移（折れ線グラフ）
        _SectionTitle(title: '月全体の気分推移'),
        const SizedBox(height: 8),
        _DailyTrendLineChart(dailyAverages: stats.dailyAverages),
        const SizedBox(height: 24),

        // 今月のハイライト
        _SectionTitle(title: '今月のハイライト'),
        const SizedBox(height: 8),
        _HighlightCards(stats: stats),
        const SizedBox(height: 24),
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
    final theme = Theme.of(context);
    final entries = stats.slotAverages.entries.toList();

    if (entries.isEmpty) {
      return const SizedBox(height: 150, child: Center(child: Text('データなし')));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          maxY: 5.5,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final level = value.toInt();
                  if (level < 1 || level > 5) return const SizedBox.shrink();
                  return Text(
                    AppConstants.moodEmojis[level]!,
                    style: const TextStyle(fontSize: 12),
                  );
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
    final theme = Theme.of(context);
    final sortedEntries = dailyAverages.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) {
      return const SizedBox(height: 150, child: Center(child: Text('データなし')));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedEntries.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedEntries[i].value));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          minY: 0.5,
          maxY: 5.5,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final level = value.toInt();
                  if (level < 1 || level > 5) return const SizedBox.shrink();
                  return Text(
                    AppConstants.moodEmojis[level]!,
                    style: const TextStyle(fontSize: 12),
                  );
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
                    '${int.parse(day)}日',
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
    return Row(
      children: [
        if (stats.bestRecord != null)
          Expanded(
            child: _HighlightCard(
              label: '最高の日',
              emoji: AppConstants.moodEmojis[stats.bestRecord!.moodLevel]!,
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
              label: '最低の日',
              emoji: AppConstants.moodEmojis[stats.worstRecord!.moodLevel]!,
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
    required this.emoji,
    required this.date,
    this.memo,
    required this.color,
  });

  final String label;
  final String emoji;
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
        borderRadius: BorderRadius.circular(12),
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
              Text(emoji, style: const TextStyle(fontSize: 24)),
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
