import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_queue/modules/InputVerifications.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('validate hours', () {
    test('for normal hours', () {
      expect(validHour(3), true);
      expect(validHour(12), true);
      expect(validHour(23), true);
      expect(validHour(0), true);
    });

    test('not for negative hours', () {
      expect(validHour(-1), false);
      expect(validHour(-10), false);
    });

    test('not for hours greater than 23', () {
      expect(validHour(24), false);
      expect(validHour(25), false);
      expect(validHour(26), false);
    });
  });

  group('validate emails', () {
    test('for simple valid emails', () {
      expect(validEmail("test@test.com"), true);
      expect(validEmail("up0000000@myport.ac.uk"), true);
    });

    test('for valid emails with special characters', () {
      expect(validEmail("test_email@domain.co.uk"), true);
      expect(validEmail("1234567890@domain.com"), true);
      expect(validEmail("email@subdomain.domain.com"), true);
    });

    test('for invalid emails', () {
      expect(validEmail("plainaddress"), false); // Missing '@' sign and domain
      expect(validEmail("@domain.com"), false); // Missing local part
      expect(validEmail("email.domain.com"), false); // Missing '@' sign
      expect(validEmail("email@domain@domain.com"), false); // Two '@' signs
      expect(validEmail(".email@domain.com"), false); // Leading dot in email is not allowed
      expect(validEmail("email.@domain.com"), false); // Trailing dot in email is not allowed
      expect(validEmail("email..email@domain.com"), false); // Multiple dots in the local part are not allowed
      expect(validEmail("email@domain..com"), false); // Multiple dots in the domain part are not allowed
    });
  });

  group('validate passwords', () {
    test('for valid passwords', () {
      expect(validPassword("password"), true);
      expect(validPassword("password123"), true);
      expect(validPassword("password123!"), true);
      expect(validPassword("password123!@#"), true);
    });

    test('for invalid passwords', () {
      // just checking for length
      expect(validPassword("pass"), false);
      expect(validPassword("12345"), false);
    });
  });

  group('validate UK phone numbers', () {
    test('for valid phone numbers', () {
      expect(validPhone("07712345678"), true);
      expect(validPhone("07712 345 678"), true);
      expect(validPhone("07712 345678"), true);
      expect(validPhone("07712345678"), true);
      expect(validPhone("07712 345 678"), true);
      expect(validPhone("07712 345678"), true);
      expect(validPhone("07712345678"), true);
      expect(validPhone("07712 345 678"), true);
      expect(validPhone("07712 345678"), true);
      expect(validPhone("+447712345678"), true);
      expect(validPhone("+44 7712 345 678"), true);
      expect(validPhone("+44 7712 345678"), true);
      expect(validPhone("+44 7712345678"), true);
      expect(validPhone("+44 7712 345 678"), true);
      expect(validPhone("+44 7712 345678"), true);
      expect(validPhone("+44 7712345678"), true);
      expect(validPhone("+44 7712 345 678"), true);
      expect(validPhone("+44 7712 345678"), true);
    });

    test('for invalid phone numbers', () {
      expect(validPhone("0000"), false);
      expect(validPhone("0771234567"), false);
    });
  });
}
