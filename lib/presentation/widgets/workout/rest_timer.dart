import 'package:flutter/material.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/utils/formatters.dart';

class RestTimer extends StatelessWidget {
  const RestTimer({super.key, required this.seconds, required this.onSkip});
  final int seconds;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: AppColors.secondary.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: AppColors.secondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Rest: ${Formatters.formatTimer(seconds)}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
