import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/core/config.dart';

void main() {
  group('AppConfig Tests', () {
    test('default configuration state when not provided via dart-define', () {
      // Saat dijalankan tanpa --dart-define, nilai harus berupa string kosong
      expect(AppConfig.supabaseUrl, isEmpty);
      expect(AppConfig.supabaseAnonKey, isEmpty);
      expect(AppConfig.isConfigured, isFalse);
    });

    test('isValidUrl returns true for valid URLs', () {
      expect(AppConfig.isValidUrl('https://example.supabase.co'), isTrue);
      expect(AppConfig.isValidUrl('http://127.0.0.1:54321'), isTrue);
      expect(
        AppConfig.isValidUrl('https://dzdvdyaxjqbfaevkypvf.supabase.co'),
        isTrue,
      );
    });

    test('isValidUrl returns false for invalid URLs', () {
      expect(AppConfig.isValidUrl(''), isFalse);
      expect(AppConfig.isValidUrl('   '), isFalse);
      expect(AppConfig.isValidUrl('not_a_valid_url'), isFalse);
      expect(AppConfig.isValidUrl('ftp://example.com'), isFalse);
      expect(AppConfig.isValidUrl('https://'), isFalse);
    });
  });
}
