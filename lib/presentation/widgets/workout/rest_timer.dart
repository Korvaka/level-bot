import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/utils/formatters.dart';

class RestTimer extends StatefulWidget {
  const RestTimer({
    super.key,
    required this.seconds,
    required this.totalSeconds,
    required this.onSkip,
    required this.onAddTime,
  });

  final int seconds;
  final int totalSeconds;
  final VoidCallback onSkip;
  final VoidCallback onAddTime;

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(RestTimer old) {
    super.didUpdateWidget(old);
    // Haptic when 3 seconds remain
    if (widget.seconds <= 3 && widget.seconds > 0 && old.seconds > widget.seconds) {
      HapticFeedback.lightImpact();
    }
    // Strong haptic at 0
    if (widget.seconds == 0 && old.seconds == 1) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalSeconds > 0
        ? widget.seconds / widget.totalSeconds
        : 0.0;
    final isAlmostDone = widget.seconds <= 5;

    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: Colors.white10,
                    color: isAlmostDone ? AppColors.error : AppColors.secondary,
                  ),
                ),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Text(
                      Formatters.formatTimer(widget.seconds),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isAlmostDone
                            ? Color.lerp(AppColors.error, Colors.white,
                                _pulseController.value)
                            : Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rest Period',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAlmostDone ? 'Almost done!' : 'Recovery in progress...',
                  style: TextStyle(
                    color: isAlmostDone ? AppColors.secondary : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // +30s button
          IconButton(
            onPressed: widget.onAddTime,
            icon: const Text(
              '+30',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            tooltip: 'Add 30 seconds',
          ),
          // Skip button
          TextButton(
            onPressed: widget.onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              side: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Skip', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
