import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers.dart';
import 'data/repositories/settings_repository.dart';
import 'services/analytics.dart';
import 'services/reel_jobs.dart';
import 'services/shelf_sync.dart';

class MemoryBookApp extends ConsumerStatefulWidget {
  const MemoryBookApp({super.key});

  @override
  ConsumerState<MemoryBookApp> createState() => _MemoryBookAppState();
}

class _MemoryBookAppState extends ConsumerState<MemoryBookApp> with WidgetsBindingObserver {
  late final _router = createRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appGo = (location) => _router.go(location);
    analytics.init();
    Future.microtask(() async {
      final push = ref.read(pushNotificationsProvider);
      push.onRoute = (route) {
        if (mounted) _router.go(route);
      };
      await push.initialize();
      final weekly = await ref
          .read(settingsRepositoryProvider)
          .getBool(SettingsRepository.weeklyNudgeKey);
      if (weekly) {
        await ref.read(localNotifyProvider).scheduleWeekly(
              title: ShelfSync.weeklyTitle,
              body: ShelfSync.weeklyBody,
            );
      }
      await ref.read(shelfSyncProvider).merge();
      if (mounted) ref.invalidate(reelsProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      ref.read(shelfSyncProvider).push();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (previous, next) {
      final signedIn = next.value != null;
      final was = previous?.value != null;
      if (signedIn && !was) {
        ref.read(pushNotificationsProvider).registerCurrentToken();
        ref.read(shelfSyncProvider).merge().then((_) {
          if (mounted) ref.invalidate(reelsProvider);
        });
      }
    });
    ref.listen(albumsProvider, (previous, next) {
      if (next.hasValue) ref.read(shelfSyncProvider).noteChanged();
    });
    ref.listen(reelsProvider, (previous, next) {
      if (next.hasValue) ref.read(shelfSyncProvider).noteChanged();
    });
    final look = ref.watch(appearanceControllerProvider);
    return MaterialApp.router(
      title: 'Memory Book',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appMessengerKey,
      theme: MbTheme.studio,
      darkTheme: MbTheme.darkroom,
      themeMode: switch (look) {
        ShelfAppearance.paper => ThemeMode.light,
        ShelfAppearance.darkroom => ThemeMode.dark,
        ShelfAppearance.phone => ThemeMode.system,
      },
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark
                  ? const [Color(0xFF1A120E), Color(0xFF2A1810), Color(0xFF120C09)]
                  : const [Color(0xFFFFFBF6), Color(0xFFF3E6D0), Color(0xFFE4D0B8)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.7, -0.9),
                    radius: 1.15,
                    colors: dark
                        ? const [Color(0x33C4A35A), Color(0x00000000)]
                        : const [Color(0x88FFFFFF), Color(0x00FFFFFF)],
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
