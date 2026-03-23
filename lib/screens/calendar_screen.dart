import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/providers/slot_provider.dart';
import 'package:namikibun/services/feature_gate.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/ad_banner.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';
import 'package:namikibun/widgets/responsive_wrapper.dart';

/// スロットのテーマカラーパレット（order_index順）
const _slotThemeColors = [
  Color(0xFFFF9F43), // 朝 - ウォームアンバー
  Color(0xFFFF6B6B), // 昼 - コーラルオレンジ
  Color(0xFF6C5CE7), // 夜 - インディゴ
  Color(0xFF00B894), // 4th - ティール
  Color(0xFFE17055), // 5th - テラコッタ
  Color(0xFF0984E3), // 6th - ブルー
  Color(0xFFFD79A8), // 7th - ピンク
  Color(0xFF636E72), // 8th - グレー
];

Color _slotColor(int orderIndex) {
  return _slotThemeColors[orderIndex % _slotThemeColors.length];
}

/// スロットフィルターでレコードを絞り込むヘルパー
Map<String, List<MoodRecord>> _filterRecordsBySlot(
  Map<String, List<MoodRecord>> recordsMap,
  String? slotFilter,
) {
  if (slotFilter == null) return recordsMap;
  final filtered = <String, List<MoodRecord>>{};
  for (final entry in recordsMap.entries) {
    final slotRecords = entry.value.where((r) => r.slotId == slotFilter).toList();
    if (slotRecords.isNotEmpty) {
      filtered[entry.key] = slotRecords;
    }
  }
  return filtered;
}

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final calendarAsync = ref.watch(calendarRecordsProvider);
    final streakAsync = ref.watch(consecutiveRecordDaysProvider);
    final slotFilter = ref.watch(selectedSlotFilterProvider);

    return SafeArea(
      child: ResponsiveWrapper(
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

          // スロットフィルターチップ
          const _SlotFilterChips(),

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
                data: (recordsMap) {
                  final filteredMap = _filterRecordsBySlot(recordsMap, slotFilter);
                  return Column(
                    children: [
                      Expanded(
                        child: _CalendarBody(
                          month: selectedMonth,
                          recordsMap: filteredMap,
                          onDayTapped: (date) {
                            ref.read(selectedDateProvider.notifier).state = date;
                            context.push('/home/day');
                          },
                        ),
                      ),
                      // 今日の気分サマリーカード（常に全体表示）
                      _TodaySummaryCard(
                        recordsMap: recordsMap,
                        onTap: () {
                          ref.read(selectedDateProvider.notifier).state =
                              AppDateUtils.getLogicalToday();
                          context.push('/home/day');
                        },
                      ),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('${AppLocalizations.of(context)!.error}: $e')),
              ),
            ),
          ),

          // バナー広告
          const AdBanner(),
        ],
      ),
      ),
    );
  }
}

/// スロットフィルターチップ
class _SlotFilterChips extends ConsumerWidget {
  const _SlotFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(slotProvider);
    final selectedFilter = ref.watch(selectedSlotFilterProvider);
    final gate = ref.watch(featureGateProvider);
    final l10n = AppLocalizations.of(context)!;

    return slotsAsync.when(
      data: (slots) {
        // 削除済みスロットがフィルター中なら全体にリセット
        if (selectedFilter != null && !slots.any((s) => s.id == selectedFilter)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedSlotFilterProvider.notifier).state = null;
          });
        }

        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // 「全体」チップ
              _FilterChip(
                label: l10n.slotFilterAll,
                isSelected: selectedFilter == null,
                color: null,
                isLocked: false,
                onTap: () {
                  ref.read(selectedSlotFilterProvider.notifier).state = null;
                },
              ),
              const SizedBox(width: 8),
              // 各スロットのチップ
              ...slots.map((slot) {
                final isSelected = selectedFilter == slot.id;
                final color = _slotColor(slot.orderIndex);
                final isLocked = !gate.canUseSlotFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: slot.name,
                    isSelected: isSelected,
                    color: color,
                    isLocked: isLocked,
                    onTap: () {
                      if (isLocked) {
                        _showPremiumDialog(context);
                      } else {
                        ref.read(selectedSlotFilterProvider.notifier).state =
                            isSelected ? null : slot.id;
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 40),
      error: (_, _) => const SizedBox(height: 40),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFF4A90D9)),
            const SizedBox(width: 8),
            Text(l10n.moodByTimeSlot),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.slotFilterPremiumDesc),
            const SizedBox(height: 8),
            Text(
              l10n.premiumOnlyFeature,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(dialogContext).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.push('/settings/store');
            },
            child: Text(l10n.openStore),
          ),
        ],
      ),
    );
  }
}

/// 個別のフィルターチップ
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.isLocked,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color? color; // null = 「全体」（グラデーション）
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // カラードット
            if (color != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [Colors.white, Colors.white70]
                        : [
                            const Color(0xFF4ECDC4),
                            const Color(0xFFFFD93D),
                            const Color(0xFFE76F51),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            // ラベル
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            // ロックアイコン
            if (isLocked && !isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.lock_outline,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ],
        ),
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
                today: AppDateUtils.getLogicalToday(),
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
    required this.today,
  });

  final DateTime month;
  final Map<String, List<MoodRecord>> recordsMap;
  final Brightness brightness;
  final DateTime today;

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

    // 今月か過去月かで右端の日を決定（今月なら今日まで、過去月なら月末まで）
    final isCurrentMonth = month.year == today.year && month.month == today.month;
    final effectiveLastDay = isCurrentMonth
        ? today.day.clamp(1, lastDay)
        : lastDay;
    // 除算用（最低2にして0除算回避）
    final maxDay = effectiveLastDay < 2 ? 2 : effectiveLastDay;

    // アンカーポイント: 月初と右端にもポイントを追加して全幅に波を広げる
    final anchoredPoints = <_WavePoint>[];

    // 月初アンカー
    if (dataPoints.first.day > 1) {
      anchoredPoints.add(_WavePoint(day: 1, average: dataPoints.first.average));
    }

    anchoredPoints.addAll(dataPoints);

    // 右端アンカー（effectiveLastDayまで）
    if (dataPoints.last.day < effectiveLastDay) {
      anchoredPoints.add(_WavePoint(day: effectiveLastDay, average: dataPoints.last.average));
    }

    // X座標: 日を画面幅にマッピング（effectiveLastDayが右端に来る）
    final points = <Offset>[];
    final realDataIndices = <int>[]; // 実データのインデックス
    final gapSegments = <_GapSegment>[];

    for (int i = 0; i < anchoredPoints.length; i++) {
      final x = (anchoredPoints[i].day - 1) / (maxDay - 1) * size.width;
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

    // Catmull-Romスプラインでパスを構築（テンション調整でなめらかに）
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : points[i + 1];

      // テンション 1/4 でよりなめらかに（デフォルト 1/6）
      final cp1x = p1.dx + (p2.dx - p0.dx) / 4;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 4;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 4;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 4;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // 塗りつぶし用パス（波の範囲内のみ）
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // 気分色グラデーション（上=ミントグリーン(高気分)、下=コーラル(低気分)）
    final baseAlpha = brightness == Brightness.dark ? 0.10 : 0.08;
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [
          const Color(0xFF4ECDC4).withValues(alpha: baseAlpha),
          const Color(0xFFFFD93D).withValues(alpha: baseAlpha * 0.5),
          const Color(0xFFE76F51).withValues(alpha: baseAlpha * 0.3),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 線を描画（気分色グラデーション）
    final linePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [
          const Color(0xFF4ECDC4).withValues(alpha: 0.25),
          const Color(0xFFE76F51).withValues(alpha: 0.20),
        ],
      )
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

    // 実データの位置にドット（気分色、枠付き）を打つ
    final outerColor = brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade300;
    for (final idx in realDataIndices) {
      final p = points[idx];
      final avg = anchoredPoints[idx].average;
      final moodLevel = avg.round().clamp(1, 5);
      final dotColor = AppConstants.moodColors[moodLevel]!;
      final outerPaint = Paint()
        ..color = outerColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 4, outerPaint);
      final innerPaint = Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p, 2.5, innerPaint);
    }
  }

  @override
  bool shouldRepaint(_BackgroundWavePainter oldDelegate) =>
      month != oldDelegate.month ||
      recordsMap != oldDelegate.recordsMap ||
      brightness != oldDelegate.brightness ||
      today != oldDelegate.today;
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
    final l10n = AppLocalizations.of(context)!;
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
            l10n.streakDays(days),
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
    final l10n = AppLocalizations.of(context)!;
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final weekdays = AppDateUtils.weekdays(l10n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(weekdays.length, (index) {
          final day = weekdays[index];
          final color = index == 5
              ? Colors.blue.shade400
              : index == 6
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
        }),
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
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
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
            else
              const SizedBox(width: 22, height: 22),
          ],
        ),
      ),
    );
  }
}

/// 今日の気分サマリーカード
class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({
    required this.recordsMap,
    required this.onTap,
  });

  final Map<String, List<MoodRecord>> recordsMap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final today = AppDateUtils.getLogicalToday();
    final todayStr = AppDateUtils.formatDate(today);
    final todayRecords = recordsMap[todayStr] ?? [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          boxShadow: DesignTokens.softShadow,
        ),
        child: todayRecords.isNotEmpty
            ? Row(
                children: [
                  MoodWaveIconMini(
                    level: (todayRecords
                                .map((r) => r.moodLevel)
                                .reduce((a, b) => a + b) /
                            todayRecords.length)
                        .round()
                        .clamp(1, 5),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.todayAverageMood}: ${(todayRecords.map((r) => r.moodLevel).reduce((a, b) => a + b) / todayRecords.length).toStringAsFixed(1)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          l10n.recordCount(todayRecords.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              )
            : Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.todayRecordPrompt,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ],
              ),
      ),
    );
  }
}
