// Basic unit tests for pure utility functions used across the app.
//
// These tests target the HelperUtils helpers that do not depend on
// platform plugins, so they can run in a plain `flutter test` session.

import 'package:flutter_test/flutter_test.dart';

import 'package:immozen/utils/helper_utils.dart';

void main() {
  group('HelperUtils.checkHost', () {
    test('appends trailing slash when missing', () {
      expect(HelperUtils.checkHost('https://api.example.com'), 'https://api.example.com/');
    });

    test('keeps existing trailing slash', () {
      expect(HelperUtils.checkHost('https://api.example.com/'), 'https://api.example.com/');
    });
  });

  group('HelperUtils.comparableVersion', () {
    test('parses dotted version into comparable integer', () {
      expect(HelperUtils.comparableVersion('1.0.0'), 100);
      expect(HelperUtils.comparableVersion('1.2.3'), 123);
      expect(HelperUtils.comparableVersion('10.20.30'), 102030);
    });
  });

  group('HelperUtils.getFileSizeString', () {
    test('returns 0b for zero bytes', () {
      expect(HelperUtils.getFileSizeString(bytes: 0), '0b');
    });

    test('returns kb for byte sizes above 1024', () {
      expect(HelperUtils.getFileSizeString(bytes: 2048, decimals: 1), '2.0kb');
    });

    test('returns mb for byte sizes above 1MB', () {
      expect(HelperUtils.getFileSizeString(bytes: 1048576), '1mb');
    });
  });
}
