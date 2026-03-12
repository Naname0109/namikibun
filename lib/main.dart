import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/app.dart';
import 'package:namikibun/providers/theme_provider.dart';
import 'package:namikibun/screens/onboarding_screen.dart';
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

enum _AppState { splash, onboarding, passcode, main }

class _AppWithSplashState extends ConsumerState<_AppWithSplash> {
  _AppState _state = _AppState.splash;

  void _onSplashComplete() {
    if (!mounted) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!onboardingCompleted) {
      setState(() => _state = _AppState.onboarding);
    } else {
      _checkPasscode();
    }
  }

  void _onOnboardingComplete() {
    if (!mounted) return;
    _checkPasscode();
  }

  void _checkPasscode() {
    final prefs = ref.read(sharedPreferencesProvider);
    final passcodeEnabled = prefs.getBool('passcode_enabled') ?? false;

    if (passcodeEnabled) {
      setState(() => _state = _AppState.passcode);
    } else {
      setState(() => _state = _AppState.main);
    }
  }

  Widget _buildPreMainApp(ThemeMode themeMode, Widget home) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [Locale('ja', 'JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    switch (_state) {
      case _AppState.splash:
        return _buildPreMainApp(
          themeMode,
          SplashScreen(onComplete: _onSplashComplete),
        );
      case _AppState.onboarding:
        return _buildPreMainApp(
          themeMode,
          OnboardingScreen(onComplete: _onOnboardingComplete),
        );
      case _AppState.passcode:
        return _buildPreMainApp(
          themeMode,
          PasscodeScreen(
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
