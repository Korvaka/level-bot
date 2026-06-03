import 'package:flutter/material.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/gamification_entity.dart';

class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.xp, this.large = false});

  final int xp;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final level = GamificationConstants.levelFromXp(xp);
    final title = GamificationConstants.levelTitle(level);
    final size = large ? 56.0 : 36.0;
    final fontSize = large ? 16.0 : 12.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _levelColors(level),
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _levelColors(level).first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$level',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          if (large)
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  List<Color> _levelColors(int level) {
    if (level <= 2) return [Colors.grey.shade400, Colors.grey.shade600];
    if (level <= 4) return [Colors.green.shade400, Colors.green.shade700];
    if (level <= 6) return [Colors.blue.shade400, Colors.blue.shade700];
    if (level <= 8) return [Colors.purple.shade400, Colors.purple.shade700];
    if (level <= 10) return [AppColors.primary, AppColors.primaryDark];
    if (level <= 13) return [Colors.orange.shade400, Colors.orange.shade700];
    if (level <= 16) return [Colors.red.shade400, Colors.red.shade700];
    if (level <= 19) return [Colors.amber.shade400, Colors.deepOrange.shade700];
    return [Colors.yellow.shade300, Colors.orange.shade800];
  }
}

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final level = GamificationConstants.levelFromXp(xp);
    final progress = GamificationConstants.progressToNextLevel(xp);
    final currentLevelXp = GamificationConstants.xpForCurrentLevel(level);
    final nextLevelXp = GamificationConstants.xpForNextLevel(level);
    final xpInLevel = xp - currentLevelXp;
    final xpNeeded = nextLevelXp - currentLevelXp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${level} · ${GamificationConstants.levelTitle(level)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Text(
              '$xpInLevel / $xpNeeded XP',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}
