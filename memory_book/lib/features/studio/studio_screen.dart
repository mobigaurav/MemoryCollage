import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text('Studio', style: text.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Collages and films live here. The shelf stays a shelf of books.',
              style: text.bodyLarge,
            ),
            const SizedBox(height: 28),
            _StudioCard(
              icon: Icons.grid_view_rounded,
              title: 'Collage',
              body: 'Arrange stills on paper, then save or share a print.',
              onTap: () => context.push('/collage'),
            ),
            const SizedBox(height: 16),
            _StudioCard(
              icon: Icons.movie_creation_outlined,
              title: 'Memory film',
              body: 'Turn stills into a reel with music, titles, and a page turn.',
              onTap: () => context.push('/video'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioCard extends StatelessWidget {
  const _StudioCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
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
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: MbTokens.leather,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: MbTokens.cream, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(body, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: MbTokens.caption),
            ],
          ),
        ),
      ),
    );
  }
}
