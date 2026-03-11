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
import 'package:namikibun/providers/tag_provider.dart';
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

  Color _moodColor() {
    if (_selectedMoodLevel == null) return Colors.grey;
    return AppConstants.moodColors[_selectedMoodLevel!] ?? Colors.grey;
  }

  Widget _buildSectionLabel(ThemeData theme, String label, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildMoodSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: MoodSelector(
        selectedLevel: _selectedMoodLevel,
        onSelected: (level) {
          HapticFeedback.selectionClick();
          setState(() => _selectedMoodLevel = level);
        },
      ),
    );
  }

  Widget _buildMemoField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _memoController,
        maxLength: AppConstants.memoMaxLength,
        contextMenuBuilder: (context, editableTextState) {
          return AdaptiveTextSelectionToolbar.editableText(
            editableTextState: editableTextState,
          );
        },
        decoration: InputDecoration(
          hintText: '会議が長かった',
          hintStyle: TextStyle(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          labelText: 'ひとことメモ',
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          counterStyle: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildTagSelector(ThemeData theme) {
    final tagsAsync = ref.watch(tagProvider);
    return tagsAsync.when(
      data: (tags) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) {
          final isSelected = _selectedTags.contains(tag.name);
          final color = tagColorFromHex(tag.colorHex);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedTags.remove(tag.name);
                } else {
                  _selectedTags.add(tag.name);
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? color.withValues(alpha: 0.5)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.12),
                ),
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  tag.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? color
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      loading: () => const SizedBox(
        height: 36,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) => const Text('タグの読み込みに失敗しました'),
    );
  }

  Widget _buildPhotoSection(ThemeData theme) {
    if (_photoPath != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(_photoPath!),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _photoPath = null),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickPhoto,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: 16,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '写真を追加',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    final moodColor = _moodColor();
    final isEnabled = _selectedMoodLevel != null && !_isSaving;

    return SizedBox(
      key: _saveButtonKey,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isEnabled
              ? LinearGradient(
                  colors: [
                    moodColor,
                    moodColor.withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: isEnabled ? null : theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
        child: FilledButton(
          onPressed: isEnabled ? _save : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
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
              : Text(
                  isEditing ? '更新' : '保存',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isEnabled
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
        ),
      ),
    );
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
      child: SingleChildScrollView(
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          const SizedBox(height: 20),

          // ヘッダー
          Text(
            '${widget.slot.name}の気分',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '今の気分を選んでください',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),

          // 気分選択
          _buildMoodSelector(theme),
          const SizedBox(height: 20),

          // メモ入力
          _buildMemoField(theme),
          const SizedBox(height: 20),

          // タグ選択
          _buildSectionLabel(
            theme,
            'タグ',
            trailing: _selectedTags.isNotEmpty
                ? Text(
                    '(${_selectedTags.length})',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  )
                : null,
          ),
          _buildTagSelector(theme),
          const SizedBox(height: 20),

          // 写真
          _buildSectionLabel(
            theme,
            '写真',
            trailing: _photoPath != null
                ? Icon(
                    Icons.check_circle,
                    size: 16,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          _buildPhotoSection(theme),
          const SizedBox(height: 16),

            // 保存ボタン
            _buildSaveButton(theme),
          ],
        ),
      ),
    );
  }
}

/// ダッシュ線ボーダーを描画するペインター
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || borderRadius != oldDelegate.borderRadius;
}
