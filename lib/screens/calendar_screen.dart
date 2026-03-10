import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/empty_state.dart';
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
                  // 右スワイプ → 前月
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month - 1);
                } else if (details.primaryVelocity! < 0) {
                  // 左スワイプ → 次月（未来月制限あり）
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
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '連続$days日記録中',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
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

    // 月曜始まり: weekday 1(月)→0, 7(日)→6
    final startWeekday = (firstDayOfMonth.weekday - 1) % 7;

    final today = AppDateUtils.getLogicalToday();
    final hasAnyRecords = recordsMap.isNotEmpty;

    if (!hasAnyRecords) {
      return const EmptyState(
        icon: Icons.calendar_month,
        message: 'まだ記録がありません',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
          color: isFuture
              ? theme.colorScheme.surface.withValues(alpha: 0.5)
              : null,
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
          ],
        ),
      ),
    );
  }
}
