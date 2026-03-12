import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pageCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPage1(theme),
                  _buildPage2(theme),
                  _buildPage3(theme),
                  _buildPage4(theme),
                ],
              ),
            ),
            // ページインジケーター
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pageCount, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MoodWaveIcon(level: 5, size: 120),
          const SizedBox(height: 32),
          Text(
            'ようこそ波きぶんへ',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '毎日の気分を波のように記録して\n自分の心の動きを見つめましょう',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '気分を5段階で記録',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...List.generate(5, (index) {
            final level = 5 - index;
            final color = AppConstants.moodColors[level]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoodWaveIcon(level: level, size: 40),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: Text(
                      AppConstants.moodLabels[level]!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPage3(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'カレンダーで振り返り',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '月間の気分の波をカレンダーで確認\n統計やグラフで傾向を分析できます',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage4(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MoodWaveIcon(level: 4, size: 80),
          const SizedBox(height: 32),
          Text(
            'さっそく始めましょう',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '朝・昼・夜の3つの時間帯で\n気分を記録してみましょう',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _complete,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                '始める',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
