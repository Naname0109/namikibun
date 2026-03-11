import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/providers/purchase_provider.dart';
import 'package:namikibun/providers/slot_provider.dart';
import 'package:namikibun/providers/theme_provider.dart';
import 'package:namikibun/services/notification_service.dart';
import 'package:namikibun/services/purchase_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(slotProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '設定',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // スロット管理
          _SettingsCard(
            title: 'スロット管理',
            child: slotsAsync.when(
              data: (slots) => _SlotManagement(slots: slots),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('エラー: $e')),
            ),
          ),
          const SizedBox(height: DesignTokens.cardSpacing),

          // 通知設定
          _SettingsCard(
            title: '通知設定',
            child: slotsAsync.when(
              data: (slots) => _NotificationSettings(slots: slots),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: DesignTokens.cardSpacing),

          // テーマ
          _SettingsCard(
            title: 'テーマ',
            child: const _ThemeSelector(),
          ),
          const SizedBox(height: DesignTokens.cardSpacing),

          // 広告除去
          _SettingsCard(
            title: '広告除去',
            child: const _AdRemovalTile(),
          ),
          const SizedBox(height: DesignTokens.cardSpacing),

          // アプリ情報
          _SettingsCard(
            title: 'アプリ情報',
            child: Column(
              children: [
                _InfoRow(label: 'バージョン', value: '1.0.0'),
                const Divider(height: 1),
                _InfoRow(
                  label: 'プライバシーポリシー',
                  subtitle: 'データはすべて端末内に保存されます',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// セクションカード（角丸16px、ソフトシャドウ）
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value, this.subtitle});

  final String label;
  final String? value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
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
        // カプセル型チップ表示
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: slots.asMap().entries.map((entry) {
              final slot = entry.value;
              final theme = Theme.of(context);
              return Chip(
                label: Text(slot.name),
                deleteIcon: Icon(Icons.close, size: 16, color: Colors.red.shade400),
                onDeleted: slots.length > 1
                    ? () => _showDeleteDialog(context, ref, slot)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // スロットリスト（並び替え可能）
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
              dense: true,
              leading: Icon(Icons.drag_handle, size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              title: Text(slot.name),
              subtitle: slot.startTime != null && slot.endTime != null
                  ? Text('${slot.startTime} - ${slot.endTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ))
                  : null,
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showRenameDialog(context, ref, slot),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('スロットを追加'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
              ),
            ),
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
          maxLength: 20,
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
          maxLength: 20,
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
    final theme = Theme.of(context);
    return Column(
      children: slots.map((slot) {
        return ListTile(
          dense: true,
          title: Text(slot.name),
          subtitle: slot.notifyEnabled && slot.notifyTime != null
              ? Text('${slot.notifyTime} に通知',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ))
              : Text('OFF',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  )),
          trailing: Switch(
            value: slot.notifyEnabled,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (enabled) async {
              if (enabled) {
                final granted =
                    await NotificationService().requestPermissionIfNeeded();
                if (!granted) return;
              }

              String? notifyTime = slot.notifyTime;
              if (enabled && notifyTime == null) {
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

// --- テーマ選択（プレビュー付きカード） ---

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _ThemeOption(
            icon: Icons.light_mode,
            label: 'ライト',
            isSelected: themeMode == ThemeMode.light,
            colors: [const Color(0xFFF8F9FA), const Color(0xFFEFF2F7)],
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            icon: Icons.dark_mode,
            label: 'ダーク',
            isSelected: themeMode == ThemeMode.dark,
            colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            icon: Icons.settings_brightness,
            label: 'システム',
            isSelected: themeMode == ThemeMode.system,
            colors: [const Color(0xFFF8F9FA), const Color(0xFF1A1A2E)],
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 広告除去 ---

class _AdRemovalTile extends ConsumerWidget {
  const _AdRemovalTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdRemoved = ref.watch(isAdRemovedProvider);
    final product = PurchaseService().product;

    if (isAdRemoved) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('広告除去済み', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    'すべての広告が非表示になっています',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('広告を除去', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      product != null ? product.price : '読み込み中...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: product != null
                    ? () => ref.read(isAdRemovedProvider.notifier).purchaseRemoveAds()
                    : null,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('購入'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => ref.read(isAdRemovedProvider.notifier).restorePurchases(),
              child: const Text('購入を復元'),
            ),
          ),
        ),
      ],
    );
  }
}
