import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';
import 'package:namikibun/l10n/app_localizations.dart';
import 'package:namikibun/widgets/mood_wave_icon.dart';

class MoodSelector extends StatefulWidget {
  const MoodSelector({
    super.key,
    this.selectedLevel,
    required this.onSelected,
  });

  final int? selectedLevel;
  final ValueChanged<int> onSelected;

  @override
  State<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends State<MoodSelector>
    with TickerProviderStateMixin {
  final Map<int, AnimationController> _controllers = {};
  final Map<int, Animation<double>> _animations = {};

  @override
  void initState() {
    super.initState();
    for (int i = AppConstants.moodLevelMin;
        i <= AppConstants.moodLevelMax;
        i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _controllers[i] = controller;
      _animations[i] = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.0),
          weight: 50,
        ),
      ]).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTap(int level) {
    _controllers[level]!.forward(from: 0);
    widget.onSelected(level);
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.selectedLevel != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(AppConstants.moodLevelMax, (index) {
        final level = index + 1;
        final isSelected = widget.selectedLevel == level;
        final l10n = AppLocalizations.of(context)!;
        final label = AppConstants.localizedMoodLabels(l10n)[level]!;
        final color = AppConstants.moodColors[level]!;

        return AnimatedBuilder(
          animation: _animations[level]!,
          builder: (context, child) {
            return Transform.scale(
              scale: _animations[level]!.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: () => _onTap(level),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: hasSelection && !isSelected ? 0.5 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? color : Colors.grey.shade300,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: MoodWaveIcon(
                            level: level,
                            size: 36,
                            showShadow: false,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? color : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
