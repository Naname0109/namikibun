import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/constants/design_tokens.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/models/slot.dart';
import 'package:namikibun/models/tag.dart';
import 'package:namikibun/providers/purchase_provider.dart';
import 'package:namikibun/providers/rewarded_ad_provider.dart';
import 'package:namikibun/providers/slot_provider.dart';
import 'package:namikibun/providers/tag_provider.dart';
import 'package:namikibun/providers/locale_provider.dart';
import 'package:namikibun/providers/theme_provider.dart';
import 'package:namikibun/screens/passcode_screen.dart';
import 'package:namikibun/services/feature_gate.dart';
import 'package:namikibun/services/notification_service.dart';
import 'package:namikibun/services/purchase_service.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final slotsAsync = ref.watch(slotProvider);
    final tagsAsync = ref.watch(tagProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            l10n.settings,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // スロット管理
          _sectionTitle(context, l10n.slotManagement),
          slotsAsync.when(
            data: (slots) => _SlotManagement(slots: slots),
            loading: () => const _SectionCard(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => _SectionCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('${l10n.error}: $e')),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // タグ管理
          _sectionTitle(context, l10n.tagManagement),
          tagsAsync.when(
            data: (tags) => _TagManagement(tags: tags),
            loading: () => const _SectionCard(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (e, _) => _SectionCard(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('${l10n.error}: $e')),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 通知設定
          _sectionTitle(context, l10n.notifications),
          _SectionCard(
            child: slotsAsync.when(
              data: (slots) => _NotificationSettings(slots: slots),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 20),

          // テーマ
          _sectionTitle(context, l10n.theme),
          _SectionCard(
            child: const _ThemeSelector(),
          ),
          const SizedBox(height: 20),

          // 言語
          _sectionTitle(context, l10n.language),
          _SectionCard(
            child: const _LanguageSelector(),
          ),
          const SizedBox(height: 20),

          // セキュリティ
          _sectionTitle(context, l10n.security),
          _SectionCard(
            child: const _PasscodeSetting(),
          ),
          const SizedBox(height: 20),

          // ストア
          _sectionTitle(context, l10n.store),
          const _StoreSection(),
          const SizedBox(height: 20),

          // その他
          _sectionTitle(context, l10n.other),
          _SectionCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.info_outline,
                  label: l10n.version,
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
                  label: l10n.privacyPolicy,
                  subtitle: l10n.privacyPolicyDesc,
                ),
              ],
            ),
          ),

          // 開発者オプション（デバッグモードのみ）
          if (kDebugMode) ...[
            const SizedBox(height: 20),
            _sectionTitle(context, l10n.debugOptions),
            const _DebugMenu(),
          ],
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // スロット一覧カード
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            boxShadow: DesignTokens.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: ReorderableListView.builder(
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
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Container(
                key: ValueKey(slot.id),
                color: theme.colorScheme.surface,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // ドラッグハンドル（48x48dpタップ領域）
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Center(
                              child: Icon(
                                Icons.drag_indicator,
                                size: 20,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 波ちゃんアイコン
                          MoodWaveIconMini(level: 3, size: 20),
                          const SizedBox(width: 10),
                          // スロット名 + 通知時刻
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slot.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (slot.notifyTime != null)
                                  Text(
                                    l10n.notificationTime(slot.notifyTime!),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // 編集ボタン
                          IconButton(
                            onPressed: () => _showRenameDialog(context, ref, slot),
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            tooltip: l10n.renameSlot,
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                              foregroundColor: theme.colorScheme.primary,
                              minimumSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          // 削除ボタン
                          if (slots.length > 1) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _showDeleteDialog(context, ref, slot),
                              icon: const Icon(Icons.delete_outline, size: 20),
                              tooltip: l10n.deleteSlot,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.withValues(alpha: 0.15),
                                foregroundColor: Colors.red.shade400,
                                minimumSize: const Size(36, 36),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (index < slots.length - 1)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // ＋ スロットを追加 ボタン
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.addSlot),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
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
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Text(
            l10n.renameSlot,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 20,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                  cursorColor: theme.colorScheme.primary,
                  contextMenuBuilder: (context, editableTextState) {
                    return AdaptiveTextSelectionToolbar.editableText(
                      editableTextState: editableTextState,
                    );
                  },
                  decoration: InputDecoration(
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
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(slotProvider.notifier).updateSlotName(slot.id, name);
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Slot slot) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Text(
            l10n.deleteSlot,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deleteSlotConfirmDetail(slot.name),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                ref.read(slotProvider.notifier).deleteSlot(slot.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final gate = ref.read(featureGateProvider);
    if (!gate.canAddSlot(slots.length)) {
      context.push('/settings/store');
      return;
    }
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Text(
            l10n.addSlot,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 20,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                  cursorColor: theme.colorScheme.primary,
                  contextMenuBuilder: (context, editableTextState) {
                    return AdaptiveTextSelectionToolbar.editableText(
                      editableTextState: editableTextState,
                    );
                  },
                  decoration: InputDecoration(
                    hintText: l10n.slotHintExample,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  ref.read(slotProvider.notifier).addSlot(name);
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }
}

// --- タグ管理 ---

class _TagManagement extends ConsumerWidget {
  const _TagManagement({required this.tags});

  final List<Tag> tags;

  static const _paletteColors = [
    'FF4A90D9', // 青
    'FF4ECDC4', // 緑
    'FFFF8C42', // オレンジ
    'FFE88EBF', // ピンク
    'FF7EC8E3', // 水色
    'FF9E9E9E', // グレー
    'FFE76F51', // コーラル
    'FF95D5B2', // ライトグリーン
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タグ一覧カード
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            boxShadow: DesignTokens.softShadow,
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...tags.map((tag) {
                final color = tagColorFromHex(tag.colorHex);
                return GestureDetector(
                  onTap: () => _showEditTagDialog(context, ref, tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        if (!tag.isDefault) ...[
                          const SizedBox(width: 2),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _showDeleteTagDialog(context, ref, tag),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: color.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              // ＋ タグ追加チップ
              GestureDetector(
                onTap: () => _showAddTagDialog(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      Icon(
                        Icons.add,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.addTag,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    String selectedColor = _paletteColors[0];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: Text(
              l10n.addTag,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 10,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                    cursorColor: theme.colorScheme.primary,
                    contextMenuBuilder: (context, editableTextState) {
                      return AdaptiveTextSelectionToolbar.editableText(
                        editableTextState: editableTextState,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: l10n.tagHintExample,
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.chooseColor,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ColorPalette(
                  colors: _paletteColors,
                  selectedColor: selectedColor,
                  onSelected: (color) => setDialogState(() => selectedColor = color),
                ),
                const SizedBox(height: 24),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    final success = await ref.read(tagProvider.notifier).addTag(name, selectedColor);
                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.tagAlreadyExists)),
                        );
                      }
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditTagDialog(BuildContext context, WidgetRef ref, Tag tag) {
    final controller = TextEditingController(text: tag.name);
    String selectedColor = tag.colorHex;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            title: Text(
              l10n.editTag,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 10,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                    cursorColor: theme.colorScheme.primary,
                    contextMenuBuilder: (context, editableTextState) {
                      return AdaptiveTextSelectionToolbar.editableText(
                        editableTextState: editableTextState,
                      );
                    },
                    decoration: InputDecoration(
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
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.chooseColor,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _ColorPalette(
                  colors: _paletteColors,
                  selectedColor: selectedColor,
                  onSelected: (color) => setDialogState(() => selectedColor = color),
                ),
                const SizedBox(height: 24),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.cancel,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    final success = await ref.read(tagProvider.notifier).updateTag(
                      tag.id,
                      name: name,
                      colorHex: selectedColor,
                    );
                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.tagAlreadyExists)),
                        );
                      }
                    }
                  }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteTagDialog(BuildContext context, WidgetRef ref, Tag tag) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          title: Text(
            l10n.deleteTag,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deleteTagConfirmDetail(tag.name),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {
                ref.read(tagProvider.notifier).deleteTag(tag.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
  }
}

/// 色選択パレット（2行×4列）
class _ColorPalette extends StatelessWidget {
  const _ColorPalette({
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  final List<String> colors;
  final String selectedColor;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((hex) {
        final color = tagColorFromHex(hex);
        final isSelected = hex == selectedColor;
        return GestureDetector(
          onTap: () => onSelected(hex),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
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
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _ThemeOption(
            label: l10n.themeLight,
            isSelected: themeMode == ThemeMode.light,
            previewColors: [const Color(0xFFF8F9FA), const Color(0xFFEFF2F7)],
            previewTextColor: const Color(0xFF333333),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            label: l10n.themeDark,
            isSelected: themeMode == ThemeMode.dark,
            previewColors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
            previewTextColor: const Color(0xFFEEEEEE),
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(width: 12),
          _ThemeOption(
            label: l10n.themeSystem,
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

// --- 言語セレクター ---

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _LanguageOption(
            label: l10n.languageJapanese,
            iconText: 'あ',
            isSelected: currentLocale.languageCode == 'ja',
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ja')),
          ),
          const SizedBox(width: 12),
          _LanguageOption(
            label: l10n.languageEnglish,
            iconText: 'A',
            isSelected: currentLocale.languageCode == 'en',
            onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.iconText,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String iconText;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
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
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.surface,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      iconText,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
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

// --- ストアセクション ---

class _StoreSection extends ConsumerWidget {
  const _StoreSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final purchaseState = ref.watch(purchaseStateProvider);
    final isPremium = purchaseState['premium'] ?? false;

    return _SectionCard(
      child: InkWell(
        onTap: () => context.push('/settings/store'),
        borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.green.withValues(alpha: 0.1)
                      : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPremium ? Icons.workspace_premium : Icons.store,
                  color: isPremium ? Colors.green : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? l10n.premiumMember : l10n.premiumRegister,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      isPremium
                          ? l10n.premiumActiveDesc
                          : l10n.premiumInactiveDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPremium
                            ? Colors.green
                            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: isPremium ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (isPremium)
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- デバッグメニュー ---

class _DebugMenu extends ConsumerWidget {
  const _DebugMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final purchaseState = ref.watch(purchaseStateProvider);
    final debugOverride = ref.watch(debugFeatureOverrideProvider);
    final isPremium = purchaseState['premium'] ?? false;
    final isAdFree = purchaseState['remove_ads'] ?? false;
    final rewardedState = ref.watch(rewardedAdProvider);

    return _SectionCard(
      child: Column(
        children: [
          // デバッグモード無効化トグル
          _debugToggle(
            theme: theme,
            icon: Icons.bug_report,
            label: l10n.debugDisable,
            subtitle: l10n.debugDisableDesc,
            value: debugOverride,
            activeColor: Colors.orange,
            onChanged: (v) =>
                ref.read(debugFeatureOverrideProvider.notifier).state = v,
          ),
          _debugDivider(theme),
          // プレミアム状態トグル
          _debugToggle(
            theme: theme,
            icon: Icons.workspace_premium,
            label: l10n.premiumStatus,
            subtitle: isPremium ? l10n.premiumActive : l10n.premiumInactive,
            value: isPremium,
            activeColor: Colors.green,
            onChanged: (v) {
              PurchaseService().debugSetPremium(v);
              ref.read(purchaseStateProvider.notifier).debugRefresh();
            },
          ),
          _debugDivider(theme),
          // 広告除去状態トグル
          _debugToggle(
            theme: theme,
            icon: Icons.block,
            label: l10n.adFreeStatus,
            subtitle: isAdFree ? l10n.purchased : l10n.notPurchased,
            value: isAdFree,
            activeColor: Colors.green,
            onChanged: (v) {
              PurchaseService().debugSetAdFree(v);
              ref.read(purchaseStateProvider.notifier).debugRefresh();
            },
          ),
          _debugDivider(theme),
          // 動画アンロック状態トグル
          _debugToggle(
            theme: theme,
            icon: Icons.play_circle_outline,
            label: l10n.videoUnlockStatus,
            subtitle: rewardedState.isUnlocked ? l10n.videoUnlocked : l10n.videoLocked,
            value: rewardedState.isUnlocked,
            activeColor: Colors.blue,
            onChanged: (v) {
              if (v) {
                ref.read(rewardedAdProvider.notifier).onRewardEarned();
              } else {
                ref.read(rewardedAdProvider.notifier).debugResetTimestamp();
              }
            },
          ),
          _debugDivider(theme),
          // リセットボタン群
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('first_launch_date');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.resetFirstLaunchDone)),
                            );
                          }
                        },
                        icon: const Icon(Icons.restart_alt, size: 16),
                        label: Text(l10n.resetFirstLaunch, style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(rewardedAdProvider.notifier).debugResetTimestamp();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.resetVideoTimestampDone)),
                          );
                        },
                        icon: const Icon(Icons.videocam_off, size: 16),
                        label: Text(l10n.resetVideoTimestamp, style: const TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('onboarding_completed');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.resetOnboardingDone)),
                        );
                      }
                    },
                    icon: const Icon(Icons.school, size: 16),
                    label: Text(l10n.resetOnboarding, style: const TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.purple),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _debugToggle({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _debugDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
      indent: 16,
      endIndent: 16,
    );
  }
}

// --- パスコード設定 ---

class _PasscodeSetting extends ConsumerStatefulWidget {
  const _PasscodeSetting();

  @override
  ConsumerState<_PasscodeSetting> createState() => _PasscodeSettingState();
}

class _PasscodeSettingState extends ConsumerState<_PasscodeSetting> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _isEnabled = prefs.getBool('passcode_enabled') ?? false;
  }

  Future<bool> _confirmPasscodeDisable(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.disablePasscode),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.enterCurrentPasscode),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.passcodeLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final prefs = ref.read(sharedPreferencesProvider);
                final savedHash = prefs.getString('passcode_hash');
                final inputHash = sha256.convert(utf8.encode(controller.text)).toString();
                if (inputHash == savedHash) {
                  await prefs.setBool('passcode_enabled', false);
                  await prefs.remove('passcode_hash');
                  if (context.mounted) Navigator.pop(context, true);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.incorrectPasscode)),
                    );
                  }
                }
              },
              child: Text(l10n.disablePasscode),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.passcodeLock, style: theme.textTheme.bodyMedium),
                Text(
                  l10n.passcodeLockDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEnabled,
            activeTrackColor: theme.colorScheme.primary,
            onChanged: (enabled) async {
              if (enabled) {
                final gate = ref.read(featureGateProvider);
                if (!gate.canUsePasscode) {
                  if (context.mounted) {
                    context.push('/settings/store');
                  }
                  return;
                }
                final success = await showPasscodeSetupDialog(context);
                if (success) {
                  setState(() => _isEnabled = true);
                }
              } else {
                // パスコード確認ダイアログ
                final confirmed = await _confirmPasscodeDisable(context, ref);
                if (confirmed) {
                  setState(() => _isEnabled = false);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
