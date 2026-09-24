import 'package:flutter/material.dart';

import '../../core/haptics.dart';
import '../../core/theme/tokens.dart';
import '../book/page_curl.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  static const _pages = [
    (
      title: 'Open it like a book',
      body:
          'Covers, paper, and a real page turn. Not another grid of thumbnails.',
    ),
    (
      title: 'Write on the page',
      body:
          'Tap an empty corner. Add a photo, crop it, caption it, keep the date.',
    ),
    (
      title: 'Share a still or a reel',
      body:
          'Send a spread to someone you love, or flip the whole album as a 9:16 film.',
    ),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MbTokens.leatherDark,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: PageCurlSpread(
                  left: const PaperPage(
                    child: Center(
                      child: Text(
                        'June',
                        style: TextStyle(
                          color: MbTokens.ink,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  right: const PaperPage(
                    isLeft: false,
                    child: Center(
                      child: Icon(
                        Icons.photo_outlined,
                        color: MbTokens.slotDash,
                        size: 48,
                      ),
                    ),
                  ),
                  onTurnForward: () => MbHaptics.pageTurn(),
                  onTurnBack: () {},
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: MbTokens.paper,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () {
                      if (_index < _pages.length - 1) {
                        _page.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOut,
                        );
                      } else {
                        widget.onComplete();
                      }
                    },
                    child: Text(
                      _index == _pages.length - 1 ? 'Open the shelf' : 'Next',
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onComplete,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.next = '/library'});
  final String next;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: MbTokens.leatherDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories, size: 88, color: MbTokens.foil),
            SizedBox(height: 16),
            Text(
              'Memory Book',
              style: TextStyle(
                fontFamily: MbTokens.serif,
                fontSize: 40,
                height: 1.1,
                color: MbTokens.cream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
