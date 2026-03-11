import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/constants/design_tokens.dart';
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
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DesignTokens.radiusL),
      ),
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
  String? _photoPath;
  bool _isNewPhoto = false;
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
      _photoPath = record.photoPath;
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<String?> _copyPhotoToAppDir(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final ext = p.extension(sourcePath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final destPath = p.join(photosDir.path, fileName);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _photoPath = image.path;
        _isNewPhoto = true;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedMoodLevel == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now().toIso8601String();
      final notifier = ref.read(moodRecordsProvider.notifier);

      // 新しい写真が選ばれていればアプリディレクトリにコピー
      String? savedPhotoPath = _photoPath;
      if (_photoPath != null && _isNewPhoto) {
        savedPhotoPath = await _copyPhotoToAppDir(_photoPath!);
      }

      if (isEditing) {
        await notifier.updateRecord(
          widget.existingRecord!.copyWith(
            moodLevel: _selectedMoodLevel!,
            memo: _memoController.text.isEmpty ? null : _memoController.text,
            tags: _selectedTags.toList(),
            photoPath: savedPhotoPath,
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
            photoPath: savedPhotoPath,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (mounted) {
        // Hapticフィードバック
        HapticFeedback.lightImpact();
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
        top: 12,
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

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
              HapticFeedback.selectionClick();
              setState(() => _selectedMoodLevel = level);
            },
          ),
          const SizedBox(height: 24),

          // メモ入力
          TextField(
            controller: _memoController,
            maxLength: AppConstants.memoMaxLength,
            decoration: InputDecoration(
              hintText: '会議が長かった',
              labelText: 'ひとことメモ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
              final tagColor = AppConstants.tagColors[tag];
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                selectedColor: tagColor?.withValues(alpha: 0.2),
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
          const SizedBox(height: 16),

          // 写真
          Text('写真', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickPhoto,
            child: _photoPath != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_photoPath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photoPath = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '写真を追加',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
