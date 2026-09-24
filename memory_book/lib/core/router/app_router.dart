import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/settings_repository.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/book/book_reader_screen.dart';
import '../../features/book/page_curl_spike_screen.dart';
import '../../features/collage/collage_studio_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/paywall/paywall_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/studio/studio_screen.dart';
import '../../features/video/video_studio_screen.dart';
import '../../providers.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashGate(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingGate(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/studio',
                builder: (context, state) => const StudioScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/you',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/book/new',
        builder: (context, state) => NewBookScreen(
          styleId: state.uri.queryParameters['style'],
          suggestedTitle: state.uri.queryParameters['title'],
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/book/:id',
        builder: (context, state) => BookReaderScreen(
          albumId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/collage',
        builder: (context, state) => const CollageStudioScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/video',
        builder: (context, state) => const VideoStudioScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/settings',
        redirect: (context, state) => '/you',
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/account',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/ai',
        builder: (context, state) => const AiLabScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: '/dev/curl',
        builder: (context, state) => const PageCurlSpikeScreen(),
      ),
    ],
  );
}

class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key});

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1200), _go);
    ref.read(authServiceProvider).refreshSession();
  }

  Future<void> _go() async {
    try {
      final done = await ref
          .read(settingsRepositoryProvider)
          .getBool(SettingsRepository.onboardingKey);
      if (!mounted) return;
      context.go(done ? '/library' : '/onboarding');
    } catch (_) {
      if (!mounted) return;
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) => const SplashScreen(next: '/library');
}

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingScreen(
      onComplete: () async {
        await ref
            .read(settingsRepositoryProvider)
            .setBool(SettingsRepository.onboardingKey, true);
        if (context.mounted) context.go('/library');
      },
    );
  }
}
