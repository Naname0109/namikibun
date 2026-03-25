import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';
import 'package:namikibun/widgets/responsive_wrapper.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final isTablet = ResponsiveWrapper.isTablet(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildPage1(theme, l10n, isTablet),
                    _buildPage2(theme, l10n, isTablet),
                    _buildPage3(theme, l10n, isTablet),
                    _buildPage4(theme, l10n, isTablet),
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
      ),
    );
  }

  Widget _buildPage1(ThemeData theme, AppLocalizations l10n, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MoodWaveIcon(level: 5, size: isTablet ? 180 : 120),
          const SizedBox(height: 32),
          Text(
            l10n.welcomeToNamikibun,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 36 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingDesc1,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: isTablet ? 20 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2(ThemeData theme, AppLocalizations l10n, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.recordMoodIn5Levels,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 36 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ...List.generate(5, (index) {
            final level = 5 - index;
            final color = AppConstants.moodColors[level]!;
            return Padding(
              padding: EdgeInsets.only(bottom: isTablet ? 18 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoodWaveIcon(level: level, size: isTablet ? 60 : 40),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: isTablet ? 150 : 100,
                    child: Text(
                      AppConstants.localizedMoodLabels(l10n)[level]!,
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  Container(
                    width: isTablet ? 48 : 32,
                    height: isTablet ? 12 : 8,
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

  Widget _buildPage3(ThemeData theme, AppLocalizations l10n, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month,
            size: isTablet ? 120 : 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            l10n.reviewOnCalendar,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 36 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingDesc3,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: isTablet ? 20 : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPage4(ThemeData theme, AppLocalizations l10n, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MoodWaveIcon(level: 4, size: isTablet ? 120 : 80),
          const SizedBox(height: 32),
          Text(
            l10n.letsGetStarted,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 36 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingDesc4,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: isTablet ? 20 : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _complete,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isTablet ? 22 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                l10n.getStarted,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
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
