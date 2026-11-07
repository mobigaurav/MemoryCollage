import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../providers.dart';
import 'reel_library.dart';

/// Lets a finished job speak from any screen.
final appMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Set by the app once the router exists.
void Function(String location)? appGo;

class ReelJob {
  const ReelJob({required this.id, required this.label});

  final String id;
  final String label;
}

/// Films, AI clips, and edits run here, not on a screen. Leave the screen and they keep going.
class ReelJobs extends Notifier<List<ReelJob>> {
  static const _uuid = Uuid();

  @override
  List<ReelJob> build() => const [];

  /// [work] gets the app's ref, so it may outlive the screen that started it.
  Future<ReelRecord?> run({
    required String label,
    required Future<ReelRecord?> Function(Ref ref) work,
    String? failure,
  }) async {
    final job = ReelJob(id: _uuid.v4(), label: label);
    state = [...state, job];
    try {
      final reel = await work(ref);
      ref.invalidate(reelsProvider);
      if (reel != null) {
        _say(
          '${reel.title} is on Reels.',
          action: SnackBarAction(label: 'Watch', onPressed: () => appGo?.call('/reels')),
        );
        await ref.read(localNotifyProvider).show(
              title: 'Your reel is ready',
              body: '${reel.title} is on Reels.',
            );
      }
      return reel;
    } catch (e) {
      _say('${failure ?? 'Could not finish $label'}: $e');
      return null;
    } finally {
      state = [
        for (final row in state)
          if (row.id != job.id) row,
      ];
    }
  }

  void _say(String text, {SnackBarAction? action}) {
    appMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(text), action: action),
    );
  }
}

final reelJobsProvider =
    NotifierProvider<ReelJobs, List<ReelJob>>(ReelJobs.new);
