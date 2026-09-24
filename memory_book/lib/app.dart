import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MemoryBookApp extends ConsumerStatefulWidget {
  const MemoryBookApp({super.key});

  @override
  ConsumerState<MemoryBookApp> createState() => _MemoryBookAppState();
}

class _MemoryBookAppState extends ConsumerState<MemoryBookApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Memory Book',
      debugShowCheckedModeBanner: false,
      theme: MbTheme.darkroom,
      routerConfig: _router,
    );
  }
}
