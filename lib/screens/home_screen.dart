import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/providers/slot_provider.dart';
import 'package:namikibun/screens/record_bottom_sheet.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/empty_state.dart';
import 'package:namikibun/widgets/slot_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final slotsAsync = ref.watch(slotProvider);
    final recordsAsync = ref.watch(moodRecordsProvider);

    return SafeArea(
      child: Column(
        children: [
          // ヘッダー: 日付表示 + 左右矢印
          _DateHeader(
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
            onToday: () => ref.read(selectedDateProvider.notifier).state =
                AppDateUtils.getLogicalToday(),
          ),

          // 波形グラフエリア（画面上部40%）
          Expanded(
            flex: 4,
            child: recordsAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return EmptyState(
                    icon: Icons.waves,
                    message: '最初の気分を記録してみましょう',
                    actionLabel: '記録する',
                    onAction: () => _openRecordSheet(
                      context,
                      ref,
                      slotsAsync.valueOrNull?.firstOrNull,
                      records,
                      selectedDate,
                    ),
                  );
                }
                // Day 3で波形グラフを実装予定
                return _WaveChartPlaceholder(records: records);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('エラー: $e')),
            ),
          ),

          // スロットカード一覧
          Expanded(
            flex: 3,
            child: slotsAsync.when(
              data: (slots) => recordsAsync.when(
                data: (records) => _SlotCardList(
                  slots: slots,
                  records: records,
                  date: selectedDate,
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('エラー: $e')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('エラー: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _openRecordSheet(
    BuildContext context,
    WidgetRef ref,
    Slot? slot,
    List<MoodRecord> records,
    DateTime date,
  ) {
    if (slot == null) return;
    showRecordBottomSheet(
      context,
      slot: slot,
      date: AppDateUtils.formatDate(date),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

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
            child: GestureDetector(
              onTap: isToday ? null : onToday,
              child: Column(
                children: [
                  Text(
                    AppDateUtils.formatDisplayDate(date),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isToday)
                    Text(
                      'タップで今日に戻る',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: isToday ? null : onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _WaveChartPlaceholder extends StatelessWidget {
  const _WaveChartPlaceholder({required this.records});

  final List<MoodRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 簡易的なドット表示（Day 3で波形グラフに置き換え）
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: records.map((r) {
                final color = AppConstants.moodColors[r.moodLevel]!;
                return Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.moodEmojis[r.moodLevel]!,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              '${records.length}件の記録',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotCardList extends ConsumerWidget {
  const _SlotCardList({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            'スロット',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: slots.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final slot = slots[index];
              final record = _findRecord(slot.id);
              return SlotCard(
                slot: slot,
                record: record,
                onTap: () => showRecordBottomSheet(
                  context,
                  slot: slot,
                  date: dateString,
                  existingRecord: record,
                ),
                onEdit: () => showRecordBottomSheet(
                  context,
                  slot: slot,
                  date: dateString,
                  existingRecord: record,
                ),
                onDelete: () async {
                  if (record != null) {
                    await ref
                        .read(moodRecordsProvider.notifier)
                        .deleteRecord(record.id!);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
