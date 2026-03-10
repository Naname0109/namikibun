import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/models/slot.dart';
import 'package:namikibun/services/database_service.dart';
import 'package:namikibun/services/notification_service.dart';

final slotProvider =
    AsyncNotifierProvider<SlotNotifier, List<Slot>>(SlotNotifier.new);

class SlotNotifier extends AsyncNotifier<List<Slot>> {
  @override
  Future<List<Slot>> build() async {
    return await DatabaseService().getActiveSlots();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => DatabaseService().getActiveSlots(),
    );
  }

  Future<void> addSlot(String name) async {
    final db = DatabaseService();
    final maxIndex = await db.getMaxOrderIndex();
    final id = 'slot_${DateTime.now().microsecondsSinceEpoch}';
    final slot = Slot(
      id: id,
      name: name,
      orderIndex: maxIndex + 1,
    );
    await db.insertSlot(slot);
    ref.invalidateSelf();
  }

  Future<void> updateSlotName(String slotId, String newName) async {
    final db = DatabaseService();
    final slot = await db.getSlotById(slotId);
    if (slot == null) return;
    await db.updateSlot(slot.copyWith(name: newName));
    ref.invalidateSelf();
  }

  Future<void> deleteSlot(String slotId) async {
    // 最低1つはスロットを残す
    final current = state.valueOrNull ?? [];
    if (current.length <= 1) return;

    await DatabaseService().softDeleteSlot(slotId);
    await NotificationService().cancelSlotReminder(slotId);
    ref.invalidateSelf();
  }

  Future<void> reorderSlots(List<Slot> reorderedSlots) async {
    await DatabaseService().reorderSlots(reorderedSlots);
    ref.invalidateSelf();
  }

  Future<void> updateNotification(
    String slotId, {
    required bool enabled,
    String? notifyTime,
  }) async {
    final db = DatabaseService();
    final slot = await db.getSlotById(slotId);
    if (slot == null) return;

    final updated = slot.copyWith(
      notifyEnabled: enabled,
      notifyTime: notifyTime ?? slot.notifyTime,
    );
    await db.updateSlot(updated);

    final notifService = NotificationService();
    if (enabled) {
      await notifService.scheduleSlotReminder(updated);
    } else {
      await notifService.cancelSlotReminder(slotId);
    }

    ref.invalidateSelf();
  }
}
