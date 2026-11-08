import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../core/nav.dart';
import '../../core/theme/chrome.dart';
import '../../core/theme/tokens.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../services/auth_ai.dart';
import '../../services/shelf_sync.dart';
import '../../widgets/local_photo.dart';
import '../../widgets/brand_hero.dart';
import '../ai/cloud_clip.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this account?'),
        content: const Text(
          'This removes the account, the books, and the reels saved to it. Family books you own are removed too. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(pushNotificationsProvider).unregister();
      await ref.read(shelfSyncProvider).erase();
      await ref.read(authServiceProvider).signOut();
      ref.invalidate(reelsProvider);
    } on ShelfException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _invite() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'Memory Book keeps photo books, collages, and short films. ${AppConfig.siteUrl}',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumControllerProvider);
    final session = ref.watch(authSessionProvider).value;
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          MbHero(
            eyebrow: 'Profile',
            title: 'You',
            subtitle: session == null
                ? 'Guest on this phone. Sign in to keep books and reels on the account.'
                : 'Books and reels on this account come back after you sign in.',
            child: session == null
                ? FilledButton(
                    style: mbInverseButton(),
                    onPressed: () => context.push('/account'),
                    child: const Text('Sign in or create account'),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.email ?? session.subject,
                        style: const TextStyle(
                          fontFamily: MbTokens.sans,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: MbTokens.cream,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session.provider} · $credits AI credits',
                        style: const TextStyle(
                          fontFamily: MbTokens.sans,
                          fontSize: 15,
                          color: Color(0xE6FAF4E8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: MbTokens.cream,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 44),
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () async {
                          await ref.read(pushNotificationsProvider).unregister();
                          await ref.read(authServiceProvider).signOut();
                        },
                        child: const Text(
                          'Sign out',
                          style: TextStyle(
                            fontFamily: MbTokens.sans,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: MbTokens.cream,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFFFD0C8),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 44),
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () => _deleteAccount(context, ref),
                        child: const Text(
                          'Delete account',
                          style: TextStyle(
                            fontFamily: MbTokens.sans,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('Account'),
                _Panel(
                  child: _Row(
                    icon: Icons.auto_awesome,
                    title: premium.isPremium ? 'Premium is on' : 'Memory Book Premium',
                    subtitle: premium.isPremium
                        ? 'Unlimited books, every layout, films made on this phone.'
                        : 'Three books free. Premium opens the rest. AI clips stay one credit.',
                    onTap: () => context.push('/paywall'),
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('Family'),
                _Panel(
                  child: _Row(
                    icon: Icons.groups_outlined,
                    title: 'Family books',
                    subtitle: 'A private book. People with the code add photos.',
                    onTap: () => context.push('/family'),
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('Look'),
                _Panel(child: const _AppearancePicker()),
                const SizedBox(height: 22),
                const _SectionLabel('On this phone'),
                _Panel(
                  child: ListTile(
                    leading: Icon(Icons.photo_library_outlined, color: context.mbAccent),
                    title: Text('Photos from this week'),
                    subtitle: Text('Sunday at 10:00 on this phone. No marketing pushes.'),
                    trailing: _WeeklySwitch(),
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('Memory Book'),
                _Panel(
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.menu_book_outlined,
                        title: 'About us',
                        subtitle: 'The shelf, the studio, and the film.',
                        onTap: () => _open('${AppConfig.siteUrl}/about'),
                      ),
                      const Divider(height: 1),
                      _Row(
                        icon: Icons.mail_outline,
                        title: 'Contact us',
                        subtitle: 'Write to support@mysticvedic.com.',
                        onTap: () => _open('${AppConfig.siteUrl}/contact'),
                      ),
                      const Divider(height: 1),
                      _Row(
                        icon: Icons.ios_share,
                        title: 'Share the app',
                        subtitle: 'Send Memory Book to someone who keeps photos.',
                        onTap: _invite,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('Legal'),
                _Panel(
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                        subtitle: 'How photos stay on this phone.',
                        onTap: () => _open('${AppConfig.siteUrl}/privacy'),
                      ),
                      const Divider(height: 1),
                      _Row(
                        icon: Icons.description_outlined,
                        title: 'Terms of service',
                        subtitle: 'The agreement for Memory Book.',
                        onTap: () => _open('${AppConfig.siteUrl}/terms'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const _VersionLabel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionLabel extends StatefulWidget {
  const _VersionLabel();

  @override
  State<_VersionLabel> createState() => _VersionLabelState();
}

class _VersionLabelState extends State<_VersionLabel> {
  String _label = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (!mounted) return;
      setState(() => _label = 'Version ${info.version} (${info.buildNumber})');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_label.isEmpty) return const SizedBox.shrink();
    return Text(
      _label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: MbTokens.sans,
        fontSize: 13,
        color: Theme.of(context).textTheme.bodySmall?.color,
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

class _AppearancePicker extends ConsumerWidget {
  const _AppearancePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final look = ref.watch(appearanceControllerProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Row(
        children: [
          for (final choice in ShelfAppearance.values) ...[
            if (choice != ShelfAppearance.paper) const SizedBox(width: 8),
            Expanded(
              child: _LookChoice(
                selected: look == choice,
                icon: switch (choice) {
                  ShelfAppearance.paper => Icons.wb_sunny_outlined,
                  ShelfAppearance.darkroom => Icons.dark_mode_outlined,
                  ShelfAppearance.phone => Icons.phone_iphone,
                },
                label: switch (choice) {
                  ShelfAppearance.paper => 'Paper',
                  ShelfAppearance.darkroom => 'Darkroom',
                  ShelfAppearance.phone => 'Phone',
                },
                onTap: () => ref.read(appearanceControllerProvider.notifier).choose(choice),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LookChoice extends StatelessWidget {
  const _LookChoice({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = selected
        ? (dark ? MbTokens.foil : MbTokens.leather)
        : (dark ? const Color(0xFF3A2418) : MbTokens.paper);
    final ink = selected
        ? (dark ? MbTokens.ink : MbTokens.cream)
        : (dark ? MbTokens.cream : MbTokens.ink);
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: ink, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: MbTokens.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ink,
                ),
              ),
            ],
          ),
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
      color: context.mbSurface,
      elevation: 6,
      shadowColor: const Color(0x40301810),
      shape: MbTokens.glassShape(MbTokens.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.mbChip,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: context.mbAccent, size: 22),
              ),
              const SizedBox(width: 14),
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
              Icon(Icons.chevron_right, color: context.mbAccent),
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
  final _prompt = TextEditingController();
  String? _image;
  AiJobResult? _result;
  bool _busy = false;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _make() async {
    final words = _prompt.text.trim();
    if (_image == null && words.isEmpty) return;
    setState(() => _busy = true);
    final result = await runCloudClip(
      context,
      ref,
      imagePath: _image,
      prompt: words,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _busy = false;
    });
  }

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
        child: ListView(
          children: [
            Text(
              'Generative motion is a credit, not the product.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              session == null
                  ? 'Sign in first. A photo clip spends 1 of your credits. Runway bills about 25 of its own credits for a 5-second clip.'
                  : 'Balance $credits. With a photo, words only describe the motion. A 5-second photo clip uses about 25 Runway credits. Memory Book still spends 1 of yours.',
              style: Theme.of(context).textTheme.bodyLarge,
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
              child: Text(_image == null ? 'Choose a photo' : 'Choose a different photo'),
            ),
            if (_image != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: LocalPhoto(path: _image!, cacheSize: const Size(360, 480)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _prompt,
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Prompt',
                hintText: _image == null
                    ? 'A paper boat crossing a quiet lake'
                    : 'A slow breeze, a small smile',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy || (_image == null && _prompt.text.trim().isEmpty)
                  ? null
                  : _make,
              child: Text(_busy ? 'Making the clip…' : 'Spend 1 credit'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => ref.read(premiumControllerProvider.notifier).buyCreditPack(),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text('Buy ${AppConfig.creditPackSize} clips'),
            ),
            const SizedBox(height: 8),
            Text(
              'An AI clip is not free, and Premium does not include it.',
              style: TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 14,
                height: 1.35,
                color: context.mbMuted,
              ),
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
        final notify = ref.read(localNotifyProvider);
        if (v) {
          await notify.scheduleWeekly(
            title: ShelfSync.weeklyTitle,
            body: ShelfSync.weeklyBody,
          );
        } else {
          await notify.cancelWeekly();
        }
      },
    );
  }
}
