import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/providers/slot_provider.dart';
import 'package:namikibun/screens/record_bottom_sheet.dart';
import 'package:namikibun/utils/date_utils.dart';
import 'package:namikibun/widgets/ad_banner.dart';
import 'package:namikibun/widgets/empty_state.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';
import 'package:namikibun/widgets/responsive_wrapper.dart';
import 'package:namikibun/widgets/wave_chart.dart';

class DayDetailScreen extends ConsumerWidget {
  const DayDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final slotsAsync = ref.watch(slotProvider);
    final recordsAsync = ref.watch(moodRecordsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
          child: ResponsiveWrapper(
          child: Column(
            children: [
              // 波形グラフ
              SizedBox(
                height: 200,
                child: slotsAsync.when(
                  data: (slots) => recordsAsync.when(
                    data: (records) {
                      if (records.isEmpty) {
                        return EmptyState(
                          message: l10n.letsRecordMood,
                        );
                      }
                      return WaveChart(slots: slots, records: records);
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('${l10n.error}: $e')),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('${l10n.error}: $e')),
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
                    error: (e, _) => Center(child: Text('${l10n.error}: $e')),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('${l10n.error}: $e')),
                ),
              ),

              // バナー広告
              const AdBanner(),
            ],
          ),
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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left, size: 20),
          visualDensity: VisualDensity.compact,
        ),
        Text(
          AppDateUtils.formatDisplayDate(date, l10n),
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
    final l10n = AppLocalizations.of(context)!;

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
          child: FilledButton.tonalIcon(
            onPressed: () => _showSlotPicker(context, ref, dateString),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addRecord),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // 下部メッセージ
        if (records.isEmpty)
          _buildBottomMessage(
            context,
            '🌊 ${l10n.tapToRecordToday}',
            showSleepingIcon: true,
          )
        else if (records.length == 1)
          _buildBottomMessage(
            context,
            l10n.tryAddingAnother,
          ),
      ],
    );
  }

  Widget _buildBottomMessage(BuildContext context, String message, {bool showSleepingIcon = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Center(
        child: Column(
          children: [
            if (showSleepingIcon)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MoodWaveIcon(level: 3, size: 36),
              ),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSlotPicker(BuildContext context, WidgetRef ref, String dateString) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: ResponsiveWrapper.maxContentWidth),
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
                l10n.selectSlot,
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
                subtitle: hasRecord ? Text(l10n.recorded) : null,
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
    with TickerProviderStateMixin {
  late AnimationController _wobbleController;
  late Animation<double> _wobbleAnimation;
  double _scale = 1.0;

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
    final l10n = AppLocalizations.of(context)!;
    final hasRecord = widget.record != null;
    final moodLevel = widget.record?.moodLevel;
    final color = moodLevel != null
        ? AppConstants.moodColors[moodLevel]!
        : theme.colorScheme.outline;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onLongPress: hasRecord ? () => _showContextMenu(context) : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
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
            // 左端カラーライン + レベル表示
            Container(
              width: 4,
              color: hasRecord ? color : color.withValues(alpha: 0.2),
            ),
            if (hasRecord)
              Container(
                width: 28,
                alignment: Alignment.center,
                child: Text(
                  'Lv.$moodLevel',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              )
            else
              const SizedBox(width: 8),
            const SizedBox(width: 4),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                  if (hasRecord && widget.record!.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: widget.record!.tags.take(3).map((tag) {
                          final tagColor = AppConstants.tagColors[tag] ??
                              theme.colorScheme.outline;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: tagColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: tagColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  else
                    Text(
                      hasRecord
                          ? (widget.record!.memo?.isNotEmpty == true
                              ? widget.record!.memo!
                              : AppConstants.localizedMoodLabels(l10n)[moodLevel]!)
                          : l10n.tapToRecord,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: hasRecord ? 0.7 : 0.6,
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
                        AppConstants.localizedMoodLabels(l10n)[moodLevel]!,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: ResponsiveWrapper.maxContentWidth),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.edit),
              onTap: () {
                Navigator.pop(context);
                widget.onTap();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red.shade400),
              title: Text(l10n.delete, style: TextStyle(color: Colors.red.shade400)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.deleteRecordConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
