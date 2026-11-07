import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/config.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../services/auth_ai.dart';
import '../../services/reel_jobs.dart';

/// Empty string means send the photo with no extra words. Null means cancel.
Future<String?> askClipPrompt(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => const _ClipPrompt(),
  );
}

class _ClipPrompt extends ConsumerStatefulWidget {
  const _ClipPrompt();

  @override
  ConsumerState<_ClipPrompt> createState() => _ClipPromptState();
}

class _ClipPromptState extends ConsumerState<_ClipPrompt> {
  final _controller = TextEditingController();
  bool _buying = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    final premium = ref.watch(premiumControllerProvider);
    return AlertDialog(
      backgroundColor: MbTokens.cream,
      title: const Text('This photo leaves the device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Not free. This spends 1 credit. You have $credits. Premium does not include AI clips.',
            style: const TextStyle(
              fontFamily: MbTokens.sans,
              fontSize: 16,
              height: 1.4,
              color: MbTokens.ink,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Words only describe the motion, such as a breeze or a smile. They do not replace the picture.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'How should it move? Optional',
              hintText: 'A slow breeze, a small smile',
            ),
          ),
          if (premium.error != null) ...[
            const SizedBox(height: 8),
            Text(premium.error!, style: const TextStyle(color: MbTokens.ink)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _buying
              ? null
              : () async {
                  setState(() => _buying = true);
                  await ref.read(premiumControllerProvider.notifier).buyCreditPack();
                  if (mounted) setState(() => _buying = false);
                },
          child: Text(_buying ? 'Buying…' : 'Buy ${AppConfig.creditPackSize} clips'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Keep it here'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Spend 1 credit'),
        ),
      ],
    );
  }
}

/// Sends the photo, then lets the clip finish in the background. It lands on Reels.
Future<AiJobResult> runCloudClip(
  BuildContext context,
  WidgetRef ref, {
  String? imagePath,
  String? prompt,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(
    const SnackBar(content: Text('Sending the photo…')),
  );
  final client = ref.read(aiVideoClientProvider);
  final started = await client.generate(imagePath: imagePath, prompt: prompt);
  messenger.hideCurrentSnackBar();
  if (!started.ok) return started;
  unawaited(
    ref.read(reelJobsProvider.notifier).run(
          label: 'AI clip',
          failure: 'The AI clip did not finish',
          work: (ref) async {
            final finished = await ref.read(aiVideoClientProvider).awaitClip(started);
            final url = finished.videoUrl;
            if (url == null || url.isEmpty) {
              throw StateError(finished.message ?? 'No video came back');
            }
            final response = await http.get(Uri.parse(url));
            if (response.statusCode >= 400) {
              throw StateError('The clip was ready, but it could not be saved on this phone');
            }
            final file = await ref
                .read(exportServiceProvider)
                .writeBytes(response.bodyBytes, 'mp4');
            return ref.read(reelLibraryProvider).keep(
                  source: file,
                  title: 'AI clip',
                  kind: 'ai',
                );
          },
        ),
  );
  messenger.showSnackBar(
    const SnackBar(
      content: Text('Making the clip. It takes about a minute and shows up on Reels. Keep going.'),
    ),
  );
  return AiJobResult(
    ok: true,
    status: 'started',
    jobId: started.jobId,
    message: 'Making the clip. It will show up on Reels.',
  );
}
