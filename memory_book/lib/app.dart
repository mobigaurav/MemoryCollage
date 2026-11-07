import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers.dart';
import 'services/analytics.dart';
import 'services/reel_jobs.dart';

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
    appGo = (location) => _router.go(location);
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
      scaffoldMessengerKey: appMessengerKey,
      theme: MbTheme.studio,
      builder: (context, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFBF6),
                Color(0xFFF3E6D0),
                Color(0xFFE4D0B8),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.7, -0.9),
                    radius: 1.15,
                    colors: [Color(0x88FFFFFF), Color(0x00FFFFFF)],
                  ),
                ),
              ),
              _DismissKeyboard(
                child: child ?? const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
      routerConfig: _router,
    );
  }
}

/// A tap that misses the field lets the keyboard go. Buttons still receive the tap.
class _DismissKeyboard extends StatelessWidget {
  const _DismissKeyboard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final focus = FocusManager.instance.primaryFocus;
        if (focus == null || !focus.hasFocus) return;
        final object = focus.context?.findRenderObject();
        if (object is! RenderBox || !object.attached || !object.hasSize) {
          focus.unfocus();
          return;
        }
        final field = object.localToGlobal(Offset.zero) & object.size;
        if (!field.contains(event.position)) focus.unfocus();
      },
      child: child,
    );
  }
}
