import 'package:flutter_test/flutter_test.dart';
import 'package:user/app/features/social/models/reel_social_proof.dart';
import 'package:user/app/features/social/services/contact_phone.dart';

void main() {
  group('normalizePhone — must match the backend canonical form', () {
    test('+91 with spaces', () {
      expect(normalizePhone('+91 98765 43210'), '919876543210');
    });

    test('leading zero stripped', () {
      expect(normalizePhone('098765 43210'), '9876543210');
    });

    test('dashes, brackets and empty input', () {
      expect(normalizePhone('(987) 654-3210'), '9876543210');
      expect(normalizePhone(''), '');
      expect(normalizePhone('     '), '');
    });
  });

  group('sha256Hex — cross-language golden vectors (node:crypto)', () {
    test('known digests', () {
      expect(
        sha256Hex('919876543210'),
        '92b5072176e723878b5e06ff3ca61898e4eb74e8c46642a0f2db800b17364ab0',
      );
      expect(
        sha256Hex('9876543210'),
        '7619ee8cea49187f309616e30ecf54be072259b43760f1f550a644945d5572f2',
      );
    });

    test('format and determinism', () {
      final hash = sha256Hex('919876543210');
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(hash), isTrue);
      expect(sha256Hex('919876543210'), hash);
      expect(sha256Hex('919876543211') == hash, isFalse);
    });
  });

  group('formatProofText — token templates localize', () {
    const es = {
      'one': 'A {name} le gusta esto',
      'two': 'A {first} y {second} les gusta esto',
      'manyOne': 'A {first}, {second} y 1 más les gusta esto',
      'manyOther': 'A {first}, {second} y {others} más les gusta esto',
    };

    String esText(List<String> names, int total) {
      return formatProofText(
        names: names,
        total: total,
        one: es['one']!,
        two: es['two']!,
        manyOne: es['manyOne']!,
        manyOther: es['manyOther']!,
      );
    }

    test('spanish templates render', () {
      expect(esText(['Rahul'], 1), 'A Rahul le gusta esto');
      expect(esText(['Rahul', 'Priya'], 2), 'A Rahul y Priya les gusta esto');
      expect(
        esText(['Rahul', 'Priya'], 5),
        'A Rahul, Priya y 3 más les gusta esto',
      );
    });

    test('empty stays empty in any language', () {
      expect(esText([], 0), '');
    });
  });

  group('ReelSocialProof.displayText', () {
    const rahul = SocialProofPerson(userId: 'u1', name: 'Rahul');
    const priya = SocialProofPerson(userId: 'u2', name: 'Priya');

    test('empty hides the row', () {
      expect(const ReelSocialProof(people: [], total: 0).displayText(), '');
    });

    test('one and two people', () {
      expect(
        const ReelSocialProof(people: [rahul], total: 1).displayText(),
        'Rahul liked this',
      );
      expect(
        const ReelSocialProof(people: [rahul, priya], total: 2).displayText(),
        'Rahul and Priya liked this',
      );
    });

    test('overflow counts the rest', () {
      expect(
        const ReelSocialProof(people: [rahul, priya], total: 5).displayText(),
        'Rahul, Priya and 3 others liked this',
      );
    });
  });
}
