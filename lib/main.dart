import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/app.dart';
import 'package:namikibun/providers/theme_provider.dart';
import 'package:namikibun/services/ad_service.dart';
import 'package:namikibun/services/purchase_service.dart';

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
      child: const NamikibunApp(),
    ),
  );
}
