import 'package:flutter_test/flutter_test.dart';

import 'package:laforika/features/home/presentation/home_search.dart';

void main() {
  group('homeSearchMatches', () {
    test('empty query matches all', () {
      expect(
        homeSearchMatches(query: '   ', haystackParts: ['امنیت حساب']),
        isTrue,
      );
    });

    test('matches Persian substrings case-insensitively for Latin', () {
      expect(
        homeSearchMatches(
          query: 'امنیت',
          haystackParts: ['امنیت حساب', 'نشست‌ها'],
        ),
        isTrue,
      );
      expect(
        homeSearchMatches(
          query: 'ACCOUNT',
          haystackParts: ['account security'],
        ),
        isTrue,
      );
    });

    test('non-matching query fails', () {
      expect(
        homeSearchMatches(query: 'چت', haystackParts: ['امنیت حساب']),
        isFalse,
      );
    });
  });
}
