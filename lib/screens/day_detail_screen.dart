import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/providers/slot_provider.dart';
import 'package:namikibun/screens/record_bottom_sheet.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/ad_banner.dart';
import 'package:namikibun/widgets/empty_state.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';
import 'package:namikibun/widgets/wave_chart.dart';

class DayDetailScreen extends ConsumerWidget {
  const DayDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final slotsAsync = ref.watch(slotProvider);
    final recordsAsync = ref.watch(moodRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? DesignTokens.backgroundGradientDark
            : DesignTokens.backgroundGradientLight,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: _DateNavigator(
            date: selectedDate,
            isToday: AppDateUtils.isSameLogicalDate(
              selectedDate,
              AppDateUtils.getLogicalToday(),
            ),
            onPrevious: () => ref.read(selectedDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1)),
            onNext: () {
              final today = AppDateUtils.getLogicalToday();
              if (selectedDate.isBefore(today)) {
                ref.read(selectedDateProvider.notifier).state =
                    selectedDate.add(const Duration(days: 1));
              }
            },
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 波形グラフ
              SizedBox(
                height: 200,
                child: slotsAsync.when(
                  data: (slots) => recordsAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return const EmptyState(
                          message: '気分を記録してみましょう',
                        );
                      }
                      return WaveChart(slots: slots, records: records);
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('エラー: $e')),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('エラー: $e')),
                ),
              ),

              // スロットカード一覧（縦並び）
              Expanded(
                child: slotsAsync.when(
                  data: (slots) => recordsAsync.when(
                    data: (records) => _SlotList(
                      slots: slots,
                      records: records,
                      date: selectedDate,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('エラー: $e')),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('エラー: $e')),
                ),
              ),

              // バナー広告
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left, size: 20),
          visualDensity: VisualDensity.compact,
        ),
        Text(
          AppDateUtils.formatDisplayDate(date),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: isToday ? null : onNext,
          icon: const Icon(Icons.chevron_right, size: 20),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _SlotList extends ConsumerWidget {
  const _SlotList({
    required this.slots,
    required this.records,
    required this.date,
  });

  final List<Slot> slots;
  final List<MoodRecord> records;
  final DateTime date;

  MoodRecord? _findRecord(String slotId) {
    final matches = records.where((r) => r.slotId == slotId);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateString = AppDateUtils.formatDate(date);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        ...slots.map((slot) {
          final record = _findRecord(slot.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PremiumSlotCard(
              slot: slot,
              record: record,
              onTap: () => showRecordBottomSheet(
                context,
                slot: slot,
                date: dateString,
                existingRecord: record,
              ),
              onDelete: () async {
                final id = record?.id;
                if (id != null) {
                  await ref.read(moodRecordsProvider.notifier).deleteRecord(id);
                }
              },
            ),
          );
        }),
        // + 記録を追加ボタン
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: OutlinedButton.icon(
            onPressed: () => _showSlotPicker(context, ref, dateString),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('記録を追加'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showSlotPicker(BuildContext context, WidgetRef ref, String dateString) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusL)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'スロットを選択',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...slots.map((slot) {
              final hasRecord = _findRecord(slot.id) != null;
              return ListTile(
                leading: Icon(
                  hasRecord ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: hasRecord ? Colors.green : null,
                ),
                title: Text(slot.name),
                subtitle: hasRecord ? const Text('記録済み') : null,
                enabled: !hasRecord,
                onTap: () {
                  Navigator.pop(context);
                  showRecordBottomSheet(
                    context,
                    slot: slot,
                    date: dateString,
                  );
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// プレミアムスロットカード（80px高、縦並び用）
class _PremiumSlotCard extends StatefulWidget {
  const _PremiumSlotCard({
    required this.slot,
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  final Slot slot;
  final MoodRecord? record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_PremiumSlotCard> createState() => _PremiumSlotCardState();
}

class _PremiumSlotCardState extends State<_PremiumSlotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _wobbleController;
  late Animation<double> _wobbleAnimation;

  @override
  void initState() {
    super.initState();
    _wobbleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _wobbleAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
    );
    if (widget.record != null) {
      _wobbleController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PremiumSlotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.record != null && !_wobbleController.isAnimating) {
      _wobbleController.repeat(reverse: true);
    } else if (widget.record == null && _wobbleController.isAnimating) {
      _wobbleController.stop();
      _wobbleController.reset();
    }
  }

  @override
  void dispose() {
    _wobbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasRecord = widget.record != null;
    final moodLevel = widget.record?.moodLevel;
    final color = moodLevel != null
        ? AppConstants.moodColors[moodLevel]!
        : theme.colorScheme.outline;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: hasRecord ? () => _showContextMenu(context) : null,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          color: hasRecord
              ? color.withValues(alpha: 0.06)
              : theme.colorScheme.surface.withValues(alpha: 0.6),
          boxShadow: DesignTokens.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // 左端カラーライン
            Container(
              width: 4,
              color: hasRecord ? color : color.withValues(alpha: 0.2),
            ),
            const SizedBox(width: 12),
            // 波キャラアイコン
            if (hasRecord)
              AnimatedBuilder(
                animation: _wobbleAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _wobbleAnimation.value,
                    child: child,
                  );
                },
                child: MoodWaveIcon(
                  level: moodLevel!,
                  size: 48,
                  showShadow: false,
                ),
              )
            else
              SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 28,
                ),
              ),
            const SizedBox(width: 12),
            // テキスト部分
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.slot.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasRecord
                        ? (widget.record!.memo?.isNotEmpty == true
                            ? widget.record!.memo!
                            : AppConstants.moodLabels[moodLevel]!)
                        : 'タップして記録',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: hasRecord ? 0.6 : 0.4,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 右端
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: hasRecord
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppConstants.moodLabels[moodLevel]!,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('編集'),
              onTap: () {
                Navigator.pop(context);
                widget.onTap();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade400),
              title: Text('削除', style: TextStyle(color: Colors.red.shade400)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('記録を削除'),
        content: const Text('この記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
