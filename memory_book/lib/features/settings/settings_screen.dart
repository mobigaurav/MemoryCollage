import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/nav.dart';
import '../../core/theme/tokens.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../services/auth_ai.dart';
import '../../services/export_history.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumControllerProvider);
    final session = ref.watch(authSessionProvider).value;
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text('You', style: text.headlineMedium),
            const SizedBox(height: 8),
            Text(
              session == null
                  ? 'Browsing as a guest. Books stay on this phone.'
                  : 'Signed in. Credits follow this account.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 24),
            _Panel(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session == null
                          ? 'Guest'
                          : (session.email ?? session.subject),
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session == null
                          ? 'Sign in when you want to spend an AI credit. Nothing else asks for an account.'
                          : '${session.provider} · $credits AI credits',
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    if (session == null)
                      FilledButton(
                        onPressed: () => context.push('/account'),
                        child: const Text('Sign in or create account'),
                      )
                    else
                      OutlinedButton(
                        onPressed: () => ref.read(authServiceProvider).signOut(),
                        child: const Text('Sign out'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const _SectionLabel('Settings'),
            _Panel(
              child: Column(
                children: [
                  _Row(
                    title: 'Premium',
                    subtitle: premium.isPremium
                        ? 'Unlocked via ${premium.source}'
                        : 'Watermark on exports, three books on the shelf',
                    onTap: () => context.push('/paywall'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    title: Text('Photos from this week'),
                    subtitle: Text('A quiet reminder. No marketing pushes.'),
                    trailing: _WeeklySwitch(),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    title: Text('Privacy'),
                    subtitle: Text(
                      'Photos stay in the app until you export them or spend a credit.',
                    ),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    title: Text('Support'),
                    subtitle: Text(AppConfig.supportEmail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _ExportHistoryTile(),
            const SizedBox(height: 28),
            const _SectionLabel('Make'),
            _Panel(
              child: _Row(
                title: 'Bring a photo to life',
                subtitle: 'A credit makes a short clip. On-phone film needs no account.',
                onTap: () => context.push('/ai'),
              ),
            ),
            const SizedBox(height: 28),
            const _SectionLabel('Developer'),
            _Panel(
              child: _Row(
                title: 'Page-curl spike',
                subtitle: 'Try the reel encoder on a spread.',
                onTap: () => context.push('/dev/curl'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: MbTokens.sans,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: MbTokens.caption,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(MbTokens.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: MbTokens.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class AiLabScreen extends ConsumerStatefulWidget {
  const AiLabScreen({super.key});

  @override
  ConsumerState<AiLabScreen> createState() => _AiLabScreenState();
}

class _AiLabScreenState extends ConsumerState<AiLabScreen> {
  String? _image;
  AiJobResult? _result;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    final session = ref.watch(authSessionProvider).value;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: shelfBackButton(context),
        title: const Text('AI lab'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generative motion is a credit, not the product.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              session == null
                  ? 'Sign in first. The ledger lives beside your account so a reinstall cannot invent credits.'
                  : 'Signed in. Balance $credits. ${AppConfig.aiBaseUrl.isEmpty ? "Cloud video is off, so a credit films the photo on this phone." : "Cloud video is connected."}',
              style: const TextStyle(color: MbTokens.paperDeep),
            ),
            const SizedBox(height: 16),
            if (session == null)
              FilledButton(
                onPressed: () => context.push('/account'),
                child: const Text('Create account or sign in'),
              ),
            if (session == null) const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final path = await ref.read(photoServiceProvider).pickSingle();
                setState(() => _image = path);
              },
              child: Text(_image == null ? 'Choose a page photo' : 'Photo selected'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _image == null || _busy
                  ? null
                  : () async {
                      final leave = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: MbTokens.leather,
                          title: const Text('This photo leaves the device'),
                          content: const Text(
                            'Spending a credit sends this picture to the AI proxy to make a short clip. It is not used to train a model. If the service fails, the credit comes back and you can make an on-device reel instead.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Keep it here'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Send this photo'),
                            ),
                          ],
                        ),
                      );
                      if (leave != true) return;
                      setState(() => _busy = true);
                      final result = await ref
                          .read(aiVideoClientProvider)
                          .generateFromImage(imagePath: _image!);
                      setState(() {
                        _result = result;
                        _busy = false;
                      });
                    },
              child: Text(_busy ? 'Sending…' : 'Spend 1 credit'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Text(_result!.message ?? ''),
              if (_result!.fallbackToOnDevice)
                TextButton(
                  onPressed: () => context.push('/video'),
                  child: const Text('Make an on-device Memory Reel instead'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeeklySwitch extends ConsumerStatefulWidget {
  const _WeeklySwitch();

  @override
  ConsumerState<_WeeklySwitch> createState() => _WeeklySwitchState();
}

class _WeeklySwitchState extends ConsumerState<_WeeklySwitch> {
  bool _on = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final on = await ref
          .read(settingsRepositoryProvider)
          .getBool(SettingsRepository.weeklyNudgeKey);
      if (mounted) setState(() => _on = on);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _on,
      onChanged: (v) async {
        setState(() => _on = v);
        await ref
            .read(settingsRepositoryProvider)
            .setBool(SettingsRepository.weeklyNudgeKey, v);
        if (v) await ref.read(localNotifyProvider).request();
      },
    );
  }
}

class _ExportHistoryTile extends ConsumerStatefulWidget {
  const _ExportHistoryTile();

  @override
  ConsumerState<_ExportHistoryTile> createState() => _ExportHistoryTileState();
}

class _ExportHistoryTileState extends ConsumerState<_ExportHistoryTile> {
  List<ExportRecord> _rows = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final rows = await ref.read(exportHistoryProvider).load();
    if (mounted) setState(() => _rows = rows);
  }

  @override
  Widget build(BuildContext context) {
    if (_rows.isEmpty) {
      return const ListTile(
        title: Text('Recent exports'),
        subtitle: Text('Saves and shares show up here.'),
      );
    }
    return Column(
      children: [
        const ListTile(title: Text('Recent exports')),
        for (final row in _rows.take(6))
          ListTile(
            title: Text(row.label),
            subtitle: Text(row.at.toLocal().toString().split('.').first),
          ),
      ],
    );
  }
}
