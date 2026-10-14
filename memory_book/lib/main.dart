import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/photo_files.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PhotoFiles.warm();
  runApp(
    const ProviderScope(
      child: MemoryBookApp(),
    ),
  );
}
