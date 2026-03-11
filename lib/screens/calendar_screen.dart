import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';

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

          // カレンダーグリッド（背景に月間波形、左右スワイプ対応）
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
                data: (recordsMap) => _CalendarBody(
                  month: selectedMonth,
                  recordsMap: recordsMap,
                  onDayTapped: (date) {
                    ref.read(selectedDateProvider.notifier).state = date;
                    context.push('/home/day');
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

/// カレンダー本体（背景波形 + グリッド）
class _CalendarBody extends StatelessWidget {
  const _CalendarBody({
    required this.month,
    required this.recordsMap,
    required this.onDayTapped,
  });

  final DateTime month;
  final Map<String, List<MoodRecord>> recordsMap;
  final ValueChanged<DateTime> onDayTapped;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 背景波形（RepaintBoundary で最適化）
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _BackgroundWavePainter(
                month: month,
                recordsMap: recordsMap,
                brightness: Theme.of(context).brightness,
              ),
            ),
          ),
        ),
        // カレンダーグリッド
        _CalendarGrid(
          month: month,
          recordsMap: recordsMap,
          onDayTapped: onDayTapped,
        ),
      ],
    );
  }
}

/// 月間の気分推移を背景全面に波で描画するペインター
class _BackgroundWavePainter extends CustomPainter {
  _BackgroundWavePainter({
    required this.month,
    required this.recordsMap,
    required this.brightness,
  });

  final DateTime month;
  final Map<String, List<MoodRecord>> recordsMap;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final lastDay = DateTime(month.year, month.month + 1, 0).day;

    // 日ごとの平均気分を収集
    final dataPoints = <_WavePoint>[];
    for (int d = 1; d <= lastDay; d++) {
      final dateStr = AppDateUtils.formatDate(
        DateTime(month.year, month.month, d),
      );
      final records = recordsMap[dateStr];
      if (records != null && records.isNotEmpty) {
        final avg = records.map((r) => r.moodLevel).reduce((a, b) => a + b) /
            records.length;
        dataPoints.add(_WavePoint(day: d, average: avg));
      }
    }

    if (dataPoints.isEmpty) return;

    // アンカーポイント: 月初と月末にもポイントを追加して全幅に波を広げる
    final anchoredPoints = <_WavePoint>[];

    // 月初アンカー
    if (dataPoints.first.day > 1) {
      anchoredPoints.add(_WavePoint(day: 1, average: dataPoints.first.average));
    }

    anchoredPoints.addAll(dataPoints);

    // 月末アンカー
    if (dataPoints.last.day < lastDay) {
      anchoredPoints.add(_WavePoint(day: lastDay, average: dataPoints.last.average));
    }

    // X座標: 日を画面幅にマッピング
    final points = <Offset>[];
    final realDataIndices = <int>[]; // 実データのインデックス
    final gapSegments = <_GapSegment>[];

    for (int i = 0; i < anchoredPoints.length; i++) {
      final x = (anchoredPoints[i].day - 1) / (lastDay - 1).clamp(1, 999) * size.width;
      final y = size.height -
          ((anchoredPoints[i].average - 1) / 4) * size.height * 0.6 -
          size.height * 0.2;
      points.add(Offset(x, y));

      // 実データかどうかを記録
      final isReal = dataPoints.any((dp) => dp.day == anchoredPoints[i].day);
      if (isReal) {
        realDataIndices.add(i);
      }

      // 5日以上のギャップを検出
      if (i > 0) {
        final gap = anchoredPoints[i].day - anchoredPoints[i - 1].day;
        if (gap >= 5) {
          gapSegments.add(_GapSegment(startIndex: i - 1, endIndex: i));
        }
      }
    }

    if (points.length == 1) {
      final dotPaint = Paint()
        ..color = const Color(0xFF4A90D9).withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points.first, 6, dotPaint);
      return;
    }

    // Catmull-Romスプラインでパスを構築
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

    // 塗りつぶし用パス（全幅）
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // グラデーション塗りつぶし（濃くして背景として認識しやすく）
    final baseAlpha = brightness == Brightness.dark ? 0.18 : 0.15;
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [
          const Color(0xFF4A90D9).withValues(alpha: baseAlpha),
          const Color(0xFF4ECDC4).withValues(alpha: baseAlpha * 0.3),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 線を描画（太く、濃く）
    final linePaint = Paint()
      ..color = const Color(0xFF4A90D9).withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // ギャップ区間を薄く表示（推測区間）
    for (final gap in gapSegments) {
      final gapRect = Rect.fromLTRB(
        points[gap.startIndex].dx,
        0,
        points[gap.endIndex].dx,
        size.height,
      );
      final gapPaint = Paint()
        ..color = (brightness == Brightness.dark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.5));
      canvas.drawRect(gapRect, gapPaint);
    }

    // 実データの位置にドット（枠付き）を打つ
    final outerColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade300;
    for (final idx in realDataIndices) {
      final p = points[idx];
      final outerPaint = Paint()
        ..color = outerColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 5, outerPaint);
      final innerPaint = Paint()
        ..color = const Color(0xFF4A90D9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 3.5, innerPaint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundWavePainter oldDelegate) =>
      month != oldDelegate.month ||
      recordsMap != oldDelegate.recordsMap ||
      brightness != oldDelegate.brightness;
}

class _WavePoint {
  const _WavePoint({required this.day, required this.average});
  final int day;
  final double average;
}

class _GapSegment {
  const _GapSegment({required this.startIndex, required this.endIndex});
  final int startIndex;
  final int endIndex;
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
        childAspectRatio: 0.75,
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

    Color? bgColor;
    if (avg != null && !isFuture) {
      final level = avg.round().clamp(1, 5);
      bgColor = AppConstants.moodColors[level]!.withValues(alpha: 0.08);
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
              ? theme.colorScheme.surface.withValues(alpha: 0.2)
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
            // なみちゃんの顔（記録ありの日）or 空のスペース
            if (records.isNotEmpty && !isFuture)
              MoodWaveIconMini(
                level: avg!.round().clamp(1, 5),
                size: 22,
              )
            else if (!isFuture)
              SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 22, height: 22),
          ],
        ),
      ),
    );
  }
}
