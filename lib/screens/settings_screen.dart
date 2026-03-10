import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/models/slot.dart';
import 'package:namikibun/providers/slot_provider.dart';
import 'package:namikibun/providers/theme_provider.dart';
import 'package:namikibun/services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(slotProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '設定',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // スロット管理
          _SectionHeader(title: 'スロット管理'),
          slotsAsync.when(
            data: (slots) => _SlotManagement(slots: slots),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('エラー: $e')),
          ),

          const Divider(height: 32),

          // 通知設定
          _SectionHeader(title: '通知設定'),
          slotsAsync.when(
            data: (slots) => _NotificationSettings(slots: slots),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          const Divider(height: 32),

          // テーマ
          _SectionHeader(title: 'テーマ'),
          const _ThemeSelector(),

          const Divider(height: 32),

          // 広告除去（Day 5で実装）
          _SectionHeader(title: '広告除去'),
          const ListTile(
            leading: Icon(Icons.remove_circle_outline),
            title: Text('広告を除去'),
            subtitle: Text('準備中'),
            enabled: false,
          ),

          const Divider(height: 32),

          // バージョン情報 / プライバシーポリシー
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('バージョン'),
            trailing: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('プライバシーポリシー'),
            subtitle: Text('データはすべて端末内に保存されます'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

// --- スロット管理 ---

class _SlotManagement extends ConsumerWidget {
  const _SlotManagement({required this.slots});

  final List<Slot> slots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex--;
            final reordered = List<Slot>.from(slots);
            final item = reordered.removeAt(oldIndex);
            reordered.insert(newIndex, item);
            ref.read(slotProvider.notifier).reorderSlots(reordered);
          },
          itemBuilder: (context, index) {
            final slot = slots[index];
            return ListTile(
              key: ValueKey(slot.id),
              leading: const Icon(Icons.drag_handle),
              title: Text(slot.name),
              subtitle: slot.startTime != null && slot.endTime != null
                  ? Text('${slot.startTime} - ${slot.endTime}')
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _showRenameDialog(context, ref, slot),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: Colors.red.shade400),
                    onPressed: slots.length > 1
                        ? () => _showDeleteDialog(context, ref, slot)
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton.icon(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('スロットを追加'),
          ),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref, Slot slot) {
    final controller = TextEditingController(text: slot.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スロット名を変更'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'スロット名',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(slotProvider.notifier).updateSlotName(slot.id, name);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Slot slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スロットを削除'),
        content: Text('「${slot.name}」を削除しますか？\n過去の記録はそのまま残ります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(slotProvider.notifier).deleteSlot(slot.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('スロットを追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'スロット名',
            hintText: '例: 仕事後',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(slotProvider.notifier).addSlot(name);
                Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}

// --- 通知設定 ---

class _NotificationSettings extends ConsumerWidget {
  const _NotificationSettings({required this.slots});

  final List<Slot> slots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: slots.map((slot) {
        return ListTile(
          title: Text(slot.name),
          subtitle: slot.notifyEnabled && slot.notifyTime != null
              ? Text('${slot.notifyTime} に通知')
              : const Text('OFF'),
          trailing: Switch(
            value: slot.notifyEnabled,
            onChanged: (enabled) async {
              if (enabled) {
                // 初回ON時に通知許可をリクエスト
                final granted =
                    await NotificationService().requestPermissionIfNeeded();
                if (!granted) return;
              }

              String? notifyTime = slot.notifyTime;
              if (enabled && notifyTime == null) {
                // デフォルト通知時刻を設定
                notifyTime = '09:00';
              }

              ref.read(slotProvider.notifier).updateNotification(
                    slot.id,
                    enabled: enabled,
                    notifyTime: notifyTime,
                  );
            },
          ),
          onTap: slot.notifyEnabled
              ? () => _showTimePicker(context, ref, slot)
              : null,
        );
      }).toList(),
    );
  }

  void _showTimePicker(
      BuildContext context, WidgetRef ref, Slot slot) async {
    final currentTime = slot.notifyTime ?? '09:00';
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      ref.read(slotProvider.notifier).updateNotification(
            slot.id,
            enabled: true,
            notifyTime: timeStr,
          );
    }
  }
}

// --- テーマ選択 ---

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode),
            label: Text('ライト'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode),
            label: Text('ダーク'),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.settings_brightness),
            label: Text('システム'),
          ),
        ],
        selected: {themeMode},
        onSelectionChanged: (selected) {
          ref.read(themeModeProvider.notifier).setThemeMode(selected.first);
        },
      ),
    );
  }
}
