import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/presentation/screens/auth/forgot_password_screen.dart';
import 'package:level_bot/presentation/screens/auth/login_screen.dart';
import 'package:level_bot/presentation/screens/auth/register_screen.dart';
import 'package:level_bot/presentation/screens/exercises/exercise_detail_screen.dart';
import 'package:level_bot/presentation/screens/exercises/exercise_library_screen.dart';
import 'package:level_bot/presentation/screens/feed/feed_screen.dart';
import 'package:level_bot/presentation/screens/feed/post_detail_screen.dart';
import 'package:level_bot/presentation/screens/home/home_screen.dart';
import 'package:level_bot/presentation/screens/profile/edit_profile_screen.dart';
import 'package:level_bot/presentation/screens/profile/profile_screen.dart';
import 'package:level_bot/presentation/screens/programs/create_program_screen.dart';
import 'package:level_bot/presentation/screens/programs/program_detail_screen.dart';
import 'package:level_bot/presentation/screens/programs/programs_screen.dart';
import 'package:level_bot/presentation/screens/progress/progress_screen.dart';
import 'package:level_bot/presentation/screens/splash/splash_screen.dart';
import 'package:level_bot/presentation/screens/workout/active_workout_screen.dart';
import 'package:level_bot/presentation/screens/workout/workout_history_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authStateChanges = FirebaseAuth.instance.authStateChanges();

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isSplash) return null;
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authStateChanges),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const FeedScreen(),
            routes: [
              GoRoute(
                path: 'post/:postId',
                name: 'post-detail',
                builder: (context, state) => PostDetailScreen(
                  postId: state.pathParameters['postId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.programs,
            name: 'programs',
            builder: (context, state) => const ProgramsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-program',
                builder: (context, state) => const CreateProgramScreen(),
              ),
              GoRoute(
                path: ':programId',
                name: 'program-detail',
                builder: (context, state) => ProgramDetailScreen(
                  programId: state.pathParameters['programId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.workout,
            name: 'workout',
            builder: (context, state) => const WorkoutHistoryScreen(),
            routes: [
              GoRoute(
                path: 'active',
                name: 'active-workout',
                builder: (context, state) => const ActiveWorkoutScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.exercises,
            name: 'exercises',
            builder: (context, state) => const ExerciseLibraryScreen(),
            routes: [
              GoRoute(
                path: ':exerciseId',
                name: 'exercise-detail',
                builder: (context, state) => ExerciseDetailScreen(
                  exerciseId: state.pathParameters['exerciseId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.progress,
            name: 'progress',
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: ':userId',
                name: 'user-profile',
                builder: (context, state) => ProfileScreen(
                  userId: state.pathParameters['userId'],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String home = '/home';
  static const String programs = '/programs';
  static const String workout = '/workout';
  static const String exercises = '/exercises';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
