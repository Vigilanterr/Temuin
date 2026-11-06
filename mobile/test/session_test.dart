import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/session.dart';

String tokenWithExpiry(DateTime expiry) {
  String part(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'id': 1, 'exp': expiry.millisecondsSinceEpoch ~/ 1000})}.'
      'signature';
}

void main() {
  group('Session.isTokenValid', () {
    test('accepts a token that expires in the future', () {
      expect(
        Session.isTokenValid(
          tokenWithExpiry(DateTime.now().add(const Duration(days: 1))),
        ),
        isTrue,
      );
    });

    test('rejects an expired token', () {
      expect(
        Session.isTokenValid(
          tokenWithExpiry(DateTime.now().subtract(const Duration(minutes: 1))),
        ),
        isFalse,
      );
    });

    test('rejects malformed or empty tokens', () {
      expect(Session.isTokenValid(null), isFalse);
      expect(Session.isTokenValid(''), isFalse);
      expect(Session.isTokenValid('not-a-jwt'), isFalse);
      expect(Session.isTokenValid('a.b.c'), isFalse);
    });
  });
}
