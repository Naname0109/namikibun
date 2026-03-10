import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/providers/mood_provider.dart';
import 'package:namikibun/widgets/mood_selector.dart';
import 'package:namikibun/widgets/particle_effect.dart';

/// 記録入力ボトムシートを表示する
Future<void> showRecordBottomSheet(
  BuildContext context, {
  required Slot slot,
  required String date,
  MoodRecord? existingRecord,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => RecordBottomSheet(
      slot: slot,
      date: date,
      existingRecord: existingRecord,
    ),
  );
}

class RecordBottomSheet extends ConsumerStatefulWidget {
  const RecordBottomSheet({
    super.key,
    required this.slot,
    required this.date,
    this.existingRecord,
  });

  final Slot slot;
  final String date;
  final MoodRecord? existingRecord;

  @override
  ConsumerState<RecordBottomSheet> createState() => _RecordBottomSheetState();
}

class _RecordBottomSheetState extends ConsumerState<RecordBottomSheet> {
  int? _selectedMoodLevel;
  late TextEditingController _memoController;
  final Set<String> _selectedTags = {};
  bool _isSaving = false;
  final _saveButtonKey = GlobalKey();

  bool get isEditing => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();

    if (isEditing) {
      final record = widget.existingRecord!;
      _selectedMoodLevel = record.moodLevel;
      _memoController.text = record.memo ?? '';
      _selectedTags.addAll(record.tags);
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedMoodLevel == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toIso8601String();
      final notifier = ref.read(moodRecordsProvider.notifier);

      if (isEditing) {
        await notifier.updateRecord(
          widget.existingRecord!.copyWith(
            moodLevel: _selectedMoodLevel!,
            memo: _memoController.text.isEmpty ? null : _memoController.text,
            tags: _selectedTags.toList(),
            updatedAt: now,
          ),
        );
      } else {
        await notifier.addRecord(
          MoodRecord(
            date: widget.date,
            slotId: widget.slot.id,
            moodLevel: _selectedMoodLevel!,
            memo: _memoController.text.isEmpty ? null : _memoController.text,
            tags: _selectedTags.toList(),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (mounted) {
        showParticleEffect(context, _saveButtonKey);
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ドラッグハンドル
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ヘッダー
          Text(
            '${widget.slot.name}の気分',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // 気分選択
          MoodSelector(
            selectedLevel: _selectedMoodLevel,
            onSelected: (level) {
              setState(() => _selectedMoodLevel = level);
            },
          ),
          const SizedBox(height: 24),

          // メモ入力
          TextField(
            controller: _memoController,
            maxLength: AppConstants.memoMaxLength,
            decoration: const InputDecoration(
              hintText: '会議が長かった',
              labelText: 'ひとことメモ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // タグ選択
          Text('タグ', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.defaultTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 保存ボタン
          SizedBox(
            key: _saveButtonKey,
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedMoodLevel != null && !_isSaving
                  ? _save
                  : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? '更新' : '保存'),
            ),
          ),
        ],
      ),
    );
  }
}
