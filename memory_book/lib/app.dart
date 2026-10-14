import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'providers.dart';
import 'services/analytics.dart';

class MemoryBookApp extends ConsumerStatefulWidget {
  const MemoryBookApp({super.key});

  @override
  ConsumerState<MemoryBookApp> createState() => _MemoryBookAppState();
}

class _MemoryBookAppState extends ConsumerState<MemoryBookApp> {
  late final _router = createRouter();

  @override
  void initState() {
    super.initState();
    analytics.init();
    Future.microtask(() async {
      final push = ref.read(pushNotificationsProvider);
      push.onRoute = (route) {
        if (mounted) _router.go(route);
      };
      await push.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (previous, next) {
      final signedIn = next.value != null;
      final was = previous?.value != null;
      if (signedIn && !was) {
        ref.read(pushNotificationsProvider).registerCurrentToken();
      }
    });
    return MaterialApp.router(
      title: 'Memory Book',
      debugShowCheckedModeBanner: false,
      theme: MbTheme.studio,
      builder: (context, child) {
        return ColoredBox(
          color: MbTokens.cream,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: _router,
    );
  }
}
