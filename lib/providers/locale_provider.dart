import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/providers/theme_provider.dart';

/// SharedPreferencesのキー（サービス層からも参照される）
const localePrefsKey = 'app_locale';

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(localePrefsKey);
    return switch (saved) {
      'en' => const Locale('en'),
      'ja' => const Locale('ja'),
      _ => const Locale('ja'), // デフォルトは日本語
    };
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(localePrefsKey, locale.languageCode);
  }
}
