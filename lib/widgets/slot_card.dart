import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/models/mood_record.dart';
import 'package:namikibun/models/slot.dart';

class SlotCard extends StatelessWidget {
  const SlotCard({
    super.key,
    required this.slot,
    this.record,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Slot slot;
  final MoodRecord? record;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  bool get hasRecord => record != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: hasRecord ? () => _showContextMenu(context) : null,
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasRecord
                ? AppConstants.moodColors[record!.moodLevel]!
                    .withValues(alpha: 0.5)
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: hasRecord ? _buildRecordedContent(theme) : _buildEmptyContent(theme),
      ),
    );
  }

  Widget _buildRecordedContent(ThemeData theme) {
    final emoji = AppConstants.moodEmojis[record!.moodLevel]!;
    final color = AppConstants.moodColors[record!.moodLevel]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                slot.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(emoji, style: const TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            AppConstants.moodLabels[record!.moodLevel]!,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (record!.memo != null && record!.memo!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            record!.memo!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (record!.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: record!.tags
                .take(3)
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slot.name,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (slot.startTime != null && slot.endTime != null)
          Text(
            '${slot.startTime} - ${slot.endTime}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('記録する'),
            style: OutlinedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
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
                onEdit();
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
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
