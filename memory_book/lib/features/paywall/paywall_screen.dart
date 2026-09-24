import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/nav.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../services/premium_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumControllerProvider);
    final plans = premium.plans;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: shelfBackButton(context),
        title: const Text('Memory Book Premium'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            premium.isPremium ? 'Premium is on.' : 'Keep the paper clean.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            premium.configured
                ? 'Annual is the family plan. Monthly is there if you want to try it.'
                : 'RevenueCat is not keyed yet. Plans below unlock locally so you can keep testing.',
            style: const TextStyle(color: MbTokens.paperDeep),
          ),
          const SizedBox(height: 16),
          const _Perk('Export without watermarks'),
          const _Perk('Every template and cover cloth'),
          const _Perk('Unlimited books and 4K stills'),
          const _Perk('Album → Reel without a free-tier stamp'),
          const SizedBox(height: 20),
          for (final plan in plans) ...[
            _PlanButton(
              plan: plan,
              busy: _busyId == plan.id,
              highlight: plan.annual,
              onPressed: premium.isPremium || _busyId != null
                  ? null
                  : () => _buy(plan),
            ),
            const SizedBox(height: 10),
          ],
          if (premium.error != null) ...[
            const SizedBox(height: 8),
            Text(
              premium.error!,
              style: const TextStyle(color: MbTokens.paperDeep),
            ),
          ],
          TextButton(
            onPressed: _busyId != null
                ? null
                : () => ref.read(premiumControllerProvider.notifier).restore(),
            child: const Text('Restore purchases'),
          ),
          if (AppConfig.devUnlockEnabled) ...[
            const Divider(),
            Text(
              'Dev testing stays open. Store builds set DEV_UNLOCK=false.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextButton(
              onPressed: () async {
                await ref.read(premiumControllerProvider.notifier).unlockLocally();
                if (context.mounted) context.pop();
              },
              child: const Text('Dev unlock'),
            ),
            if (premium.isPremium && premium.source != 'revenuecat')
              TextButton(
                onPressed: () => ref
                    .read(premiumControllerProvider.notifier)
                    .clearLocalUnlock(),
                child: const Text('Clear dev unlock'),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _buy(PremiumPlan plan) async {
    setState(() => _busyId = plan.id);
    await ref.read(premiumControllerProvider.notifier).purchase(plan.id);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (ref.read(premiumControllerProvider).isPremium) context.pop();
  }
}

class _PlanButton extends StatelessWidget {
  const _PlanButton({
    required this.plan,
    required this.busy,
    required this.highlight,
    required this.onPressed,
  });

  final PremiumPlan plan;
  final bool busy;
  final bool highlight;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final label = busy ? 'Purchasing…' : '${plan.title}  ·  ${plan.priceLabel}';
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Text(plan.detail, style: const TextStyle(fontSize: 12)),
      ],
    );
    if (highlight) {
      return FilledButton(
        onPressed: onPressed,
        child: Align(alignment: Alignment.centerLeft, child: child),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: Align(alignment: Alignment.centerLeft, child: child),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check, color: MbTokens.foil),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
