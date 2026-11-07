import 'package:flutter_test/flutter_test.dart';
import 'package:memory_book/services/premium_service.dart';

void main() {
  test('the tester account is premium outside a release build', () {
    final granted = PremiumState.grantTester(
      PremiumState.free,
      'mobigaurav@gmail.com',
    );
    expect(granted.isPremium, isTrue);
    expect(granted.source, 'tester');
  });

  test('a debug run uses the RevenueCat test store', () {
    expect(PremiumService.activeKey, startsWith('test_'));
  });

  test('any other account stays free', () {
    final other = PremiumState.grantTester(PremiumState.free, 'someone@example.com');
    expect(other.isPremium, isFalse);
    final guest = PremiumState.grantTester(PremiumState.free, null);
    expect(guest.isPremium, isFalse);
  });
}
