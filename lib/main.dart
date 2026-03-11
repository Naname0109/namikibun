import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/app.dart';
import 'package:namikibun/providers/theme_provider.dart';
import 'package:namikibun/screens/passcode_screen.dart';
import 'package:namikibun/screens/splash_screen.dart';
import 'package:namikibun/services/ad_service.dart';
import 'package:namikibun/services/purchase_service.dart';
import 'package:namikibun/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // 広告SDK・課金サービスの初期化（非同期、起動をブロックしない）
  AdService().initialize();
  PurchaseService().initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const _AppWithSplash(),
    ),
  );
}

class _AppWithSplash extends ConsumerStatefulWidget {
  const _AppWithSplash();

  @override
  ConsumerState<_AppWithSplash> createState() => _AppWithSplashState();
}

enum _AppState { splash, passcode, main }

class _AppWithSplashState extends ConsumerState<_AppWithSplash> {
  _AppState _state = _AppState.splash;

  void _onSplashComplete() {
    if (!mounted) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final passcodeEnabled = prefs.getBool('passcode_enabled') ?? false;

    if (passcodeEnabled) {
      setState(() => _state = _AppState.passcode);
    } else {
      setState(() => _state = _AppState.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    switch (_state) {
      case _AppState.splash:
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: SplashScreen(onComplete: _onSplashComplete),
        );
      case _AppState.passcode:
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: PasscodeScreen(
            onUnlocked: () {
              if (mounted) setState(() => _state = _AppState.main);
            },
          ),
        );
      case _AppState.main:
        return const NamikibunApp();
    }
  }
}
