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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            '設定',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // スロット管理
          _sectionTitle(context, 'スロット管理'),
          _SectionCard(
            child: slotsAsync.when(
              data: (slots) => _SlotManagement(slots: slots),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text('エラー: $e')),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 通知設定
          _sectionTitle(context, '通知設定'),
          _SectionCard(
            child: slotsAsync.when(
              data: (slots) => _NotificationSettings(slots: slots),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 20),

          // テーマ
          _sectionTitle(context, 'テーマ'),
          _SectionCard(
            child: const _ThemeSelector(),
          ),
          const SizedBox(height: 20),

          // 広告除去
          _sectionTitle(context, '広告除去'),
          _SectionCard(
            child: const _AdRemovalTile(),
          ),
          const SizedBox(height: 20),

          // その他
          _sectionTitle(context, 'その他'),
          _SectionCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.info_outline,
                  label: 'バージョン',
                  value: '1.0.0',
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                  indent: 16,
                  endIndent: 16,
                ),
                _InfoRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'プライバシーポリシー',
                  subtitle: 'データはすべて端末内に保存されます',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

/// セクションカード（角丸16px、白背景＋ソフトシャドウ）
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        boxShadow: DesignTokens.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.icon,
    this.value,
    this.subtitle,
  });

  final IconData? icon;
  final String label;
  final String? value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 12),
          ],
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // カプセル型チップ横並び
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...slots.map((slot) {
                final accentColor = theme.colorScheme.primary;
                return GestureDetector(
                  onLongPress: () => _showSlotActions(context, ref, slot),
                  onTap: () => _showRenameDialog(context, ref, slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          slot.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              // ＋チップ
              GestureDetector(
                onTap: () => _showAddDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        '追加',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (slots.length > 1) ...[
            const SizedBox(height: 12),
            Text(
              '長押しで編集・削除 / ドラッグで並び替え',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
          // 並び替えリスト
          const SizedBox(height: 8),
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
              return Container(
                key: ValueKey(slot.id),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.drag_handle,
                      size: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        slot.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (slot.startTime != null && slot.endTime != null)
                      Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSlotActions(BuildContext context, WidgetRef ref, Slot slot) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignTokens.radiusL)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('名前を変更'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref, slot);
              },
            ),
            if (slots.length > 1)
              ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
                title: Text('削除', style: TextStyle(color: Colors.red.shade400)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, ref, slot);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
      children: [
        for (int i = 0; i < slots.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              indent: 16,
              endIndent: 16,
            ),
          _NotificationRow(slot: slots[i]),
        ],
      ],
    );
  }
}

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.slot});

  final Slot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isEnabled = slot.notifyEnabled;
    final timeStr = slot.notifyTime ?? '09:00';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // スロット名
          Expanded(
            child: Text(
              slot.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // 時刻表示（タップでピッカー）
          if (isEnabled)
            GestureDetector(
              onTap: () => _showTimePicker(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeStr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          // トグル
          Switch(
            value: isEnabled,
            activeTrackColor: theme.colorScheme.primary,
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
        ],
      ),
    );
  }

  void _showTimePicker(BuildContext context, WidgetRef ref) async {
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

// --- テーマ選択（ミニプレビュー付きカード） ---

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _ThemeOption(
            label: 'ライト',
            isSelected: themeMode == ThemeMode.light,
            previewColors: [const Color(0xFFF8F9FA), const Color(0xFFEFF2F7)],
            previewTextColor: const Color(0xFF333333),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            label: 'ダーク',
            isSelected: themeMode == ThemeMode.dark,
            previewColors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
            previewTextColor: const Color(0xFFEEEEEE),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            label: 'システム',
            isSelected: themeMode == ThemeMode.system,
            previewColors: [const Color(0xFFF8F9FA), const Color(0xFF1A1A2E)],
            previewTextColor: const Color(0xFF888888),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.isSelected,
    required this.previewColors,
    required this.previewTextColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final List<Color> previewColors;
  final Color previewTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            // ミニプレビュー
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: isSelected ? 2.5 : 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: previewColors,
                ),
              ),
              child: Stack(
                children: [
                  // ミニUIプレビュー要素
                  Positioned(
                    top: 12,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: previewTextColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 8,
                    right: 20,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: previewTextColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // チェックマーク
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
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
    final theme = Theme.of(context);

    if (isAdRemoved) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '広告除去済み',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'すべての広告が非表示になっています',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.tertiary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.workspace_premium, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '広告を除去',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      product != null ? product.price : '読み込み中...',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('購入'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => ref.read(isAdRemovedProvider.notifier).restorePurchases(),
              child: Text(
                '購入を復元',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
