import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/mini_wave_painter.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final calendarAsync = ref.watch(calendarRecordsProvider);
    final streakAsync = ref.watch(consecutiveRecordDaysProvider);

    return SafeArea(
      child: Column(
        children: [
          // 連続記録日数バッジ
          streakAsync.when(
            data: (days) => days > 0
                ? _StreakBadge(days: days)
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // 月サマリーグラフ
          calendarAsync.when(
            data: (recordsMap) => _MonthlySummaryWave(
              month: selectedMonth,
              recordsMap: recordsMap,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // 月ヘッダー
          _MonthHeader(
            month: selectedMonth,
            onPrevious: () =>
                ref.read(selectedMonthProvider.notifier).state =
                    DateTime(selectedMonth.year, selectedMonth.month - 1),
            onNext: () {
              final now = AppDateUtils.getLogicalToday();
              final nextMonth =
                  DateTime(selectedMonth.year, selectedMonth.month + 1);
              if (!nextMonth.isAfter(DateTime(now.year, now.month))) {
                ref.read(selectedMonthProvider.notifier).state = nextMonth;
              }
            },
            canGoNext: () {
              final now = AppDateUtils.getLogicalToday();
              final nextMonth =
                  DateTime(selectedMonth.year, selectedMonth.month + 1);
              return !nextMonth.isAfter(DateTime(now.year, now.month));
            },
          ),

          // 曜日ヘッダー
          const _WeekdayHeader(),

          // カレンダーグリッド（左右スワイプ対応）
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! > 0) {
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month - 1);
                } else if (details.primaryVelocity! < 0) {
                  final now = AppDateUtils.getLogicalToday();
                  final nextMonth =
                      DateTime(selectedMonth.year, selectedMonth.month + 1);
                  if (!nextMonth.isAfter(DateTime(now.year, now.month))) {
                    ref.read(selectedMonthProvider.notifier).state = nextMonth;
                  }
                }
              },
              child: calendarAsync.when(
                data: (recordsMap) => _CalendarGrid(
                  month: selectedMonth,
                  recordsMap: recordsMap,
                  onDayTapped: (date) {
                    ref.read(selectedDateProvider.notifier).state = date;
                    context.go('/home');
                  },
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('エラー: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 月全体の気分推移サマリーグラフ（横長の波形ライン）
class _MonthlySummaryWave extends StatelessWidget {
  const _MonthlySummaryWave({
    required this.month,
    required this.recordsMap,
  });

  final DateTime month;
  final Map<String, List<MoodRecord>> recordsMap;

  @override
  Widget build(BuildContext context) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    // 日付インデックス付きの平均データ（記録がない日はnull）
    final dailyData = <_DayAverage>[];

    for (int d = 1; d <= lastDay; d++) {
      final dateStr = AppDateUtils.formatDate(
        DateTime(month.year, month.month, d),
      );
      final records = recordsMap[dateStr];
      if (records != null && records.isNotEmpty) {
        final avg = records.map((r) => r.moodLevel).reduce((a, b) => a + b) /
            records.length;
        dailyData.add(_DayAverage(day: d, lastDay: lastDay, average: avg));
      }
    }

    if (dailyData.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(DesignTokens.radiusS),
      ),
      child: CustomPaint(
        size: const Size(double.infinity, 40),
        painter: _SummaryWavePainter(
          dailyData: dailyData,
          brightness: Theme.of(context).brightness,
        ),
      ),
    );
  }
}

class _DayAverage {
  const _DayAverage({required this.day, required this.lastDay, required this.average});
  final int day;
  final int lastDay;
  final double average;

  /// 月の中での正規化位置 (0.0 ~ 1.0)
  double get normalized => (day - 1) / (lastDay - 1).clamp(1, 999);
}

class _SummaryWavePainter extends CustomPainter {
  _SummaryWavePainter({required this.dailyData, required this.brightness});

  final List<_DayAverage> dailyData;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    if (dailyData.isEmpty) return;

    final points = <Offset>[];
    for (final d in dailyData) {
      final x = dailyData.length == 1
          ? size.width / 2
          : d.normalized * size.width;
      final y = size.height - ((d.average - 1) / 4) * size.height * 0.7 - size.height * 0.15;
      points.add(Offset(x, y));
    }

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4A90D9);

    if (points.length == 1) {
      final dotPaint = Paint()
        ..color = const Color(0xFF4A90D9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points.first, 3, dotPaint);
      return;
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SummaryWavePainter oldDelegate) =>
      dailyData != oldDelegate.dailyData;
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4ECDC4).withValues(alpha: 0.15),
            const Color(0xFF4A90D9).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 波しぶきアイコン
          Icon(
            Icons.water_drop,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '連続$days日記録中',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _weekdays.map((day) {
          final color = day == '土'
              ? Colors.blue.shade400
              : day == '日'
                  ? Colors.red.shade400
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6);
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.recordsMap,
    required this.onDayTapped,
  });

  final DateTime month;
  final Map<String, List<MoodRecord>> recordsMap;
  final ValueChanged<DateTime> onDayTapped;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    final startWeekday = (firstDayOfMonth.weekday - 1) % 7;
    final today = AppDateUtils.getLogicalToday();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.8,
      ),
      itemCount: startWeekday + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox.shrink();
        }

        final day = index - startWeekday + 1;
        final date = DateTime(month.year, month.month, day);
        final dateStr = AppDateUtils.formatDate(date);
        final records = recordsMap[dateStr] ?? [];
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isFuture = date.isAfter(today);

        return _CalendarDayCell(
          day: day,
          records: records,
          isToday: isToday,
          isFuture: isFuture,
          onTap: isFuture ? null : () => onDayTapped(date),
        );
      },
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.records,
    required this.isToday,
    required this.isFuture,
    this.onTap,
  });

  final int day;
  final List<MoodRecord> records;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  double? get _averageMood {
    if (records.isEmpty) return null;
    return records.map((r) => r.moodLevel).reduce((a, b) => a + b) /
        records.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = _averageMood;

    // 背景色: 平均気分レベルに応じて薄く着色
    Color? bgColor;
    if (avg != null && !isFuture) {
      final level = avg.round().clamp(1, 5);
      bgColor = AppConstants.moodColors[level]!.withValues(alpha: 0.1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusS),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
          color: isFuture
              ? theme.colorScheme.surface.withValues(alpha: 0.3)
              : bgColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isFuture
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                    : isToday
                        ? theme.colorScheme.primary
                        : null,
              ),
            ),
            const SizedBox(height: 2),
            if (!isFuture)
              MiniWaveWidget(
                records: records,
                width: 36,
                height: 20,
              ),
            // 記録ありの日: 波キャラ顔ドット
            if (records.isNotEmpty && !isFuture)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.moodColors[avg!.round().clamp(1, 5)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
