import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Always leaves the current screen. Used because some routes replace the
/// stack (`go`) and would otherwise trap the user with no back button.
void popToShelf(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go('/library');
  }
}

Widget shelfBackButton(BuildContext context) {
  return IconButton(
    tooltip: 'Back',
    onPressed: () => popToShelf(context),
    icon: const Icon(Icons.arrow_back_ios_new),
  );
}
