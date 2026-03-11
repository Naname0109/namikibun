import 'package:flutter/material.dart';

/// デザイントークン: UI全体で統一的に使う値
class DesignTokens {
  DesignTokens._();

  // 角丸
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;

  // シャドウ
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 20,
          spreadRadius: -5,
          offset: const Offset(0, 4),
        ),
      ];

  // 背景グラデーション (ライト)
  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FA), Color(0xFFEFF2F7)],
  );

  // 背景グラデーション (ダーク)
  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
  );

  // カード余白
  static const double cardSpacing = 16.0;
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
}
