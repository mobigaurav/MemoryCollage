import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config.dart';
import '../../core/nav.dart';
import '../../core/theme/tokens.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../services/auth_ai.dart';
import '../../widgets/local_photo.dart';
import '../../widgets/brand_hero.dart';
import '../ai/cloud_clip.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _invite() async {
    await SharePlus.instance.share(
      ShareParams(
        text:
            'I keep family photos in Memory Book. The book stays on the phone. ${AppConfig.siteUrl}',
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumControllerProvider);
    final session = ref.watch(authSessionProvider).value;
    final credits = ref.watch(creditBalanceProvider).value ?? 0;
    return Scaffold(
      backgroundColor: MbTokens.cream,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          MbHero(
            eyebrow: 'Profile',
            title: 'You',
            subtitle: session == null
                ? 'Guest on this phone. Sign in only when you want an AI credit.'
                : 'This account holds your AI credits.',
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
                const _SectionLabel('On this phone'),
                _Panel(
                  child: const ListTile(
                    leading: Icon(Icons.photo_library_outlined, color: MbTokens.leather),
                    title: Text('Photos from this week'),
                    subtitle: Text('A quiet reminder. No marketing pushes.'),
                    trailing: _WeeklySwitch(),
                  ),
                ),
                const SizedBox(height: 22),
                const _SectionLabel('About'),
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
                      const Divider(height: 1),
                      _Row(
                        icon: Icons.ios_share,
                        title: 'Invite friends',
                        subtitle: 'Send Memory Book to someone who keeps photos.',
                        onTap: _invite,
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
      style: const TextStyle(
        fontFamily: MbTokens.sans,
        fontSize: 13,
        color: MbTokens.inkSoft,
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
          color: MbTokens.inkSoft,
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
                  color: MbTokens.paper,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: MbTokens.leather, size: 22),
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
              const Icon(Icons.chevron_right, color: MbTokens.leather),
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
