import 'package:flutter/material.dart';

import 'package:namikibun/constants/app_constants.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(AppConstants.moodLevelMax, (index) {
        final level = index + 1;
        final isSelected = widget.selectedLevel == level;
        final emoji = AppConstants.moodEmojis[level]!;
        final label = AppConstants.moodLabels[level]!;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? color.withValues(alpha: 0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
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
        );
      }),
    );
  }
}
