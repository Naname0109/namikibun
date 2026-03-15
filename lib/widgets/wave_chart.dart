import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';

class WaveChart extends StatefulWidget {
  const WaveChart({
    super.key,
    required this.slots,
    required this.records,
  });

  final List<Slot> slots;
  final List<MoodRecord> records;

  @override
  State<WaveChart> createState() => _WaveChartState();
}

class _WaveChartState extends State<WaveChart> {
  bool _showData = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showData = true);
    });
  }

  @override
  void didUpdateWidget(WaveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) {
      setState(() => _showData = false);
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) setState(() => _showData = true);
      });
    }
  }

  /// スロットIDからレコードを検索
  MoodRecord? _findRecord(String slotId) {
    final matches = widget.records.where((r) => r.slotId == slotId);
    return matches.isEmpty ? null : matches.first;
  }

  /// 記録済みのデータポイントを構築
  List<FlSpot> _buildSpots() {
    if (!_showData) return [];

    final spots = <FlSpot>[];
    for (int i = 0; i < widget.slots.length; i++) {
      final record = _findRecord(widget.slots[i].id);
      if (record != null) {
        spots.add(FlSpot(i.toDouble(), record.moodLevel.toDouble()));
      }
    }
    return spots;
  }

  int get _dataPointCount {
    int count = 0;
    for (final slot in widget.slots) {
      if (_findRecord(slot.id) != null) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final pointCount = _dataPointCount;
    final spots = _buildSpots();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: LineChart(
        LineChartData(
          minY: 1.0,
          maxY: 5.0,
          minX: -0.5,
          maxX: widget.slots.length - 0.5,
          gridData: const FlGridData(show: false),
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
                interval: 1,
                getTitlesWidget: (value, _) {
                  final index = value.round();
                  if ((value - index).abs() > 0.01) return const SizedBox.shrink();
                  if (index < 0 || index >= widget.slots.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.slots[index].name,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final level = spot.y.toInt();
                  return LineTooltipItem(
                    AppConstants.localizedMoodLabels(l10n)[level] ?? '',
                    TextStyle(
                      color: AppConstants.moodColors[level],
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            _buildLineBarData(spots, pointCount),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<FlSpot> spots, int pointCount) {
    // 0点: グレーの点線
    if (pointCount == 0 || spots.isEmpty) {
      final dummySpots = List.generate(
        widget.slots.length,
        (i) => FlSpot(i.toDouble(), 3),
      );
      return LineChartBarData(
        spots: dummySpots,
        isCurved: false,
        color: Colors.grey.shade300,
        barWidth: 1,
        dashArray: [5, 5],
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }

    // 色のグラデーション
    final colors = spots
        .map((s) => AppConstants.moodColors[s.y.toInt()]!)
        .toList();
    final gradientColors = colors.length >= 2 ? colors : [colors.first, colors.first];

    // 1点: 点のみ
    if (pointCount == 1) {
      return LineChartBarData(
        spots: spots,
        barWidth: 0,
        color: Colors.transparent,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
            radius: 8,
            color: AppConstants.moodColors[spot.y.toInt()]!,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(show: false),
      );
    }

    // 2点: 直線、3点以上: スプライン曲線
    return LineChartBarData(
      spots: spots,
      isCurved: pointCount >= 3,
      curveSmoothness: 0.35,
      gradient: LinearGradient(colors: gradientColors),
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
          radius: 5,
          color: AppConstants.moodColors[spot.y.toInt()]!,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gradientColors.first.withValues(alpha: 0.3),
            gradientColors.last.withValues(alpha: 0.02),
          ],
        ),
      ),
    );
  }
}
