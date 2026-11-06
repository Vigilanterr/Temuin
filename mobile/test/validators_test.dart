import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('accepts a valid email', () {
      expect(validateEmail('user@example.com'), isNull);
    });

    test('rejects empty and malformed emails', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
      expect(validateEmail('user.example.com'), isNotNull);
      expect(validateEmail('user@'), isNotNull);
    });
  });

  group('validateRequired', () {
    test('rejects empty values', () {
      expect(validateRequired('', 'Judul'), 'Judul wajib diisi');
      expect(validateRequired('   ', 'Judul'), 'Judul wajib diisi');
    });

    test('accepts non-empty values', () {
      expect(validateRequired('Dompet', 'Judul'), isNull);
    });
  });

  group('validateMinLength', () {
    test('enforces minimum length', () {
      expect(
        validateMinLength('abc', 6, 'Password'),
        'Password minimal 6 karakter',
      );
      expect(validateMinLength('abcdef', 6, 'Password'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('must match the password', () {
      expect(validateConfirmPassword('abcdef', 'abcdef'), isNull);
      expect(validateConfirmPassword('abcdeg', 'abcdef'), isNotNull);
      expect(validateConfirmPassword('', 'abcdef'), isNotNull);
    });
  });

  group('validateOptionalUrl', () {
    test('accepts empty input', () {
      expect(validateOptionalUrl(''), isNull);
      expect(validateOptionalUrl(null), isNull);
    });

    test('accepts http and https URLs', () {
      expect(validateOptionalUrl('https://example.com/a.jpg'), isNull);
      expect(validateOptionalUrl('http://example.com/a.jpg'), isNull);
    });

    test('rejects invalid schemes and malformed URLs', () {
      expect(validateOptionalUrl('ftp://example.com/a.jpg'), isNotNull);
      expect(validateOptionalUrl('example.com/a.jpg'), isNotNull);
    });
  });
}
