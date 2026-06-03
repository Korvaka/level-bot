class GamificationConstants {
  GamificationConstants._();

  static const int xpPerSet = 5;
  static const int xpPerCompletedSet = 10;
  static const int xpPerWorkout = 50;
  static const int xpPerPR = 150;
  static const int xpPerStreak7 = 100;
  static const int xpPerStreak30 = 500;

  static const List<int> levelThresholds = [
    0,      // Level 1
    200,    // Level 2
    500,    // Level 3
    1000,   // Level 4
    1800,   // Level 5
    3000,   // Level 6
    4500,   // Level 7
    6500,   // Level 8
    9000,   // Level 9
    12000,  // Level 10
    16000,  // Level 11
    21000,  // Level 12
    27000,  // Level 13
    34000,  // Level 14
    42000,  // Level 15
    52000,  // Level 16
    64000,  // Level 17
    78000,  // Level 18
    95000,  // Level 19
    115000, // Level 20
  ];

  static int levelFromXp(int xp) {
    int level = 1;
    for (int i = 0; i < levelThresholds.length; i++) {
      if (xp >= levelThresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }
    return level;
  }

  static int xpForNextLevel(int currentLevel) {
    if (currentLevel >= levelThresholds.length) return 999999;
    return levelThresholds[currentLevel]; // index currentLevel = level+1
  }

  static int xpForCurrentLevel(int currentLevel) {
    if (currentLevel <= 1) return 0;
    return levelThresholds[currentLevel - 1];
  }

  static double progressToNextLevel(int xp) {
    final level = levelFromXp(xp);
    final current = xpForCurrentLevel(level);
    final next = xpForNextLevel(level);
    if (next == current) return 1.0;
    return ((xp - current) / (next - current)).clamp(0.0, 1.0);
  }

  static String levelTitle(int level) {
    if (level <= 2) return 'Rookie';
    if (level <= 4) return 'Challenger';
    if (level <= 6) return 'Athlete';
    if (level <= 8) return 'Warrior';
    if (level <= 10) return 'Champion';
    if (level <= 13) return 'Elite';
    if (level <= 16) return 'Legend';
    if (level <= 19) return 'Titan';
    return 'GOD';
  }
}

enum Achievement {
  firstWorkout,
  warrior10,
  centurion100,
  firstPR,
  pr10,
  streak7,
  streak30,
  volumeKing,
  earlyBird,
  nightOwl,
  socialButterfly,
  programCreator,
}

extension AchievementExt on Achievement {
  String get title {
    switch (this) {
      case Achievement.firstWorkout: return 'First Rep';
      case Achievement.warrior10: return 'Warrior';
      case Achievement.centurion100: return 'Centurion';
      case Achievement.firstPR: return 'Personal Best';
      case Achievement.pr10: return 'PR Machine';
      case Achievement.streak7: return 'Weekly Warrior';
      case Achievement.streak30: return 'Unstoppable';
      case Achievement.volumeKing: return 'Volume King';
      case Achievement.earlyBird: return 'Early Bird';
      case Achievement.nightOwl: return 'Night Owl';
      case Achievement.socialButterfly: return 'Social';
      case Achievement.programCreator: return 'Architect';
    }
  }

  String get description {
    switch (this) {
      case Achievement.firstWorkout: return 'Complete your first workout';
      case Achievement.warrior10: return 'Complete 10 workouts';
      case Achievement.centurion100: return 'Complete 100 workouts';
      case Achievement.firstPR: return 'Set your first Personal Record';
      case Achievement.pr10: return 'Set 10 Personal Records';
      case Achievement.streak7: return '7-day workout streak';
      case Achievement.streak30: return '30-day workout streak';
      case Achievement.volumeKing: return 'Lift 100,000 kg total volume';
      case Achievement.earlyBird: return 'Work out before 7am';
      case Achievement.nightOwl: return 'Work out after 10pm';
      case Achievement.socialButterfly: return 'Follow 10 athletes';
      case Achievement.programCreator: return 'Create a training program';
    }
  }

  String get icon {
    switch (this) {
      case Achievement.firstWorkout: return '🏋️';
      case Achievement.warrior10: return '⚔️';
      case Achievement.centurion100: return '🛡️';
      case Achievement.firstPR: return '🏆';
      case Achievement.pr10: return '💎';
      case Achievement.streak7: return '🔥';
      case Achievement.streak30: return '🌟';
      case Achievement.volumeKing: return '👑';
      case Achievement.earlyBird: return '🌅';
      case Achievement.nightOwl: return '🌙';
      case Achievement.socialButterfly: return '🤝';
      case Achievement.programCreator: return '📋';
    }
  }

  int get xpReward {
    switch (this) {
      case Achievement.firstWorkout: return 100;
      case Achievement.warrior10: return 300;
      case Achievement.centurion100: return 1000;
      case Achievement.firstPR: return 200;
      case Achievement.pr10: return 500;
      case Achievement.streak7: return 200;
      case Achievement.streak30: return 800;
      case Achievement.volumeKing: return 500;
      case Achievement.earlyBird: return 150;
      case Achievement.nightOwl: return 150;
      case Achievement.socialButterfly: return 100;
      case Achievement.programCreator: return 200;
    }
  }
}
