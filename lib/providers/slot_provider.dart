import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/models/slot.dart';
import 'package:namikibun/services/database_service.dart';

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
}
