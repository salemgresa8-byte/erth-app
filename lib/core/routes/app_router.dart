import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/expert/expert_dashboard.dart';
import '../../features/expert/restoration_log_form.dart';
import '../../features/shared/qr_scanner_screen.dart';
import '../../features/tourist/artifact_story_screen.dart';
import '../../features/tourist/tourist_dashboard.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const expert = '/expert';
  static const tourist = '/tourist';
  static const scanner = '/scan';
  static const story = '/artifact-story';
  static const restorationForm = '/restoration-form';
}

/// `extra` for [AppRoutes.story] and [AppRoutes.restorationForm] is the
/// artifact row (Map<String, dynamic>) fetched from Supabase.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: AppRoutes.expert, builder: (_, __) => const ExpertDashboard()),
    GoRoute(
        path: AppRoutes.tourist, builder: (_, __) => const TouristDashboard()),
    GoRoute(
        path: AppRoutes.scanner, builder: (_, __) => const QrScannerScreen()),
    GoRoute(
      path: AppRoutes.story,
      builder: (_, state) => ArtifactStoryScreen(
          artifact: state.extra! as Map<String, dynamic>),
    ),
    GoRoute(
      path: AppRoutes.restorationForm,
      builder: (_, state) => RestorationLogForm(
          artifact: state.extra! as Map<String, dynamic>),
    ),
  ],
);
