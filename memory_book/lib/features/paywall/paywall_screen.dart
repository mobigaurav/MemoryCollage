import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../../services/analytics.dart';
import '../../services/premium_service.dart';
import '../../widgets/brand_hero.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String? _busyId;

  @override
  void initState() {
    super.initState();
    analytics.track(AnalyticsEvents.paywallViewed);
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumControllerProvider);
    final plans = premium.plans;
    return Scaffold(
      backgroundColor: MbTokens.leather,
      body: Column(
        children: [
          Expanded(
            child: MbHero(
              fill: true,
              onBack: () => mbPop(context),
              eyebrow: 'Memory Book',
              title: premium.isPremium ? 'Premium is on' : 'Premium',
            subtitle: premium.isPremium
                ? 'Unlimited books, every layout, and films made on this phone.'
                : 'Three books are free. Premium opens the rest. An AI clip is still one credit, not part of the plan.',
            footer: 'Cancel anytime in the App Store or Play Store.',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Perk('Unlimited books on this phone'),
                _Perk('Every collage layout'),
                _Perk('High and 4K exports'),
                _Perk('Film a book or a photo on this phone'),
              ],
            ),
            ),
          ),
          Material(
            color: MbTokens.cream,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final plan in plans) ...[
                    _PlanButton(
                      plan: plan,
                      busy: _busyId == plan.id,
                      highlight: plan.annual,
                      onPressed: _busyId != null ? null : () => _buy(plan),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: MbTokens.ink,
                      side: const BorderSide(color: MbTokens.leather, width: 1.4),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: _busyId != null
                        ? null
                        : () async {
                            setState(() => _busyId = 'pack');
                            await ref
                                .read(premiumControllerProvider.notifier)
                                .buyCreditPack();
                            if (mounted) setState(() => _busyId = null);
                          },
                    child: Text(
                      _busyId == 'pack'
                          ? 'Purchasing…'
                          : '5 AI clips  ·  one time',
                      style: const TextStyle(
                        fontFamily: MbTokens.sans,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MbTokens.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Spent one clip at a time. Premium does not include these.',
                    style: TextStyle(
                      fontFamily: MbTokens.sans,
                      fontSize: 14,
                      height: 1.3,
                      color: MbTokens.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (premium.error != null) ...[
                    Text(
                      premium.error!,
                      style: const TextStyle(
                        fontFamily: MbTokens.sans,
                        fontSize: 15,
                        height: 1.4,
                        color: MbTokens.danger,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SafeArea(
                    top: false,
                    child: TextButton(
                      onPressed: _busyId != null
                          ? null
                          : () => ref.read(premiumControllerProvider.notifier).restore(),
                      child: const Text(
                        'Restore purchases',
                        style: TextStyle(
                          fontFamily: MbTokens.sans,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MbTokens.leather,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buy(PremiumPlan plan) async {
    setState(() => _busyId = plan.id);
    await ref.read(premiumControllerProvider.notifier).purchase(plan.id);
    if (!mounted) return;
    setState(() => _busyId = null);
    if (ref.read(premiumControllerProvider).isPremium) {
      analytics.track(AnalyticsEvents.purchaseCompleted, {'plan': plan.id});
      context.pop();
    }
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
    final titleColor = highlight ? MbTokens.cream : MbTokens.ink;
    final detailColor = highlight ? const Color(0xFFF3E6D0) : MbTokens.inkSoft;
    final label = busy ? 'Purchasing…' : '${plan.title}  ·  ${plan.priceLabel}';
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: MbTokens.sans,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          plan.detail,
          style: TextStyle(
            fontFamily: MbTokens.sans,
            fontSize: 15,
            height: 1.3,
            color: detailColor,
          ),
        ),
      ],
    );
    return SizedBox(
      width: double.infinity,
      child: highlight
          ? FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: MbTokens.leather,
                foregroundColor: MbTokens.cream,
                disabledBackgroundColor: MbTokens.leather,
                disabledForegroundColor: MbTokens.cream,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                alignment: Alignment.centerLeft,
              ),
              onPressed: onPressed,
              child: child,
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MbTokens.ink,
                disabledForegroundColor: MbTokens.ink,
                side: const BorderSide(color: MbTokens.leather, width: 1.4),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                alignment: Alignment.centerLeft,
              ),
              onPressed: onPressed,
              child: child,
            ),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: MbTokens.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
