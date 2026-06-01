class AppConstants {
  AppConstants._();

  static const String appName = 'LevelBot';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String exercisesCollection = 'exercises';
  static const String programsCollection = 'programs';
  static const String workoutSessionsCollection = 'workout_sessions';
  static const String postsCollection = 'posts';
  static const String personalRecordsCollection = 'personal_records';
  static const String followsCollection = 'follows';
  static const String likesCollection = 'likes';
  static const String commentsCollection = 'comments';

  // Storage Paths
  static const String profilePhotosPath = 'profile_photos';
  static const String postMediaPath = 'post_media';
  static const String exerciseMediaPath = 'exercise_media';

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String exerciseBox = 'exercise_box';
  static const String programBox = 'program_box';
  static const String workoutBox = 'workout_box';
  static const String settingsBox = 'settings_box';

  // Pagination
  static const int defaultPageSize = 20;
  static const int feedPageSize = 15;

  // Workout
  static const int defaultRestSeconds = 90;
  static const int minRestSeconds = 15;
  static const int maxRestSeconds = 600;

  // Profile
  static const int maxBioLength = 150;
  static const int maxDisplayNameLength = 30;
  static const int maxPseudoLength = 20;

  // Validation
  static const int minPasswordLength = 8;
  static const double minWeight = 20.0;
  static const double maxWeight = 300.0;
  static const double minHeight = 100.0;
  static const double maxHeight = 250.0;
  static const int minAge = 13;
  static const int maxAge = 100;

  // RPE Scale
  static const double minRpe = 1.0;
  static const double maxRpe = 10.0;

  // Cache Duration
  static const Duration exerciseCacheDuration = Duration(days: 7);
  static const Duration profileCacheDuration = Duration(hours: 1);
}
