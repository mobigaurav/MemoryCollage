import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../widgets/brand_hero.dart';

class StudioScreen extends ConsumerWidget {
  const StudioScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final reels = await ref.read(reelLibraryProvider).load();
    if (!context.mounted) return;
    if (reels.isEmpty) {
      context.go('/reels');
      return;
    }
    if (reels.length == 1) {
      context.push('/reel/edit?id=${reels.first.id}');
      return;
    }
    final id = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: MbTokens.cream,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Which reel?',
                style: TextStyle(
                  fontFamily: MbTokens.serif,
                  fontSize: 22,
                  color: MbTokens.ink,
                ),
              ),
            ),
            for (final reel in reels)
              ListTile(
                title: Text(reel.title),
                subtitle: Text(reel.kind),
                onTap: () => Navigator.pop(ctx, reel.id),
              ),
          ],
        ),
      ),
    );
    if (id != null && context.mounted) context.push('/reel/edit?id=$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: MbTokens.cream,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const MbHero(
            eyebrow: 'Make',
            title: 'Studio',
            subtitle: 'A still collage, a film, or a cut of a reel you already made.',
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              children: [
            _StudioCard(
              icon: Icons.grid_view_rounded,
              kicker: 'Still',
              title: 'Collage',
              body: 'Place photos in a frame or drag them free. Export is the picture, not a screenshot.',
              onTap: () => context.push('/collage'),
            ),
            const SizedBox(height: 14),
            _StudioCard(
              icon: Icons.movie_creation_outlined,
              kicker: 'Moving',
              title: 'Memory film',
              body: 'Stills, a frame shape, and a song you pick. The phone encodes the file.',
              onTap: () => context.push('/video'),
            ),
            const SizedBox(height: 14),
            _StudioCard(
              icon: Icons.calendar_month_outlined,
              kicker: 'This year',
              title: 'Year film',
              body: 'A film from the dates already on the photos. Made on this phone. No credit.',
              onTap: () => context.push('/year'),
            ),
            const SizedBox(height: 14),
            _StudioCard(
              icon: Icons.movie_filter_outlined,
              kicker: 'Cut',
              title: 'Edit a reel',
              body: 'Trim, crop, and join two clips on this phone. AI restyle is Premium.',
              onTap: () => _edit(context, ref),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioCard extends StatelessWidget {
  const _StudioCard({
    required this.icon,
    required this.kicker,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final String kicker;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(MbTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MbTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: MbTokens.leather,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: MbTokens.cream, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kicker.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: MbTokens.sans,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: MbTokens.leather,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(body, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: MbTokens.leather),
            ],
          ),
        ),
      ),
    );
  }
}
