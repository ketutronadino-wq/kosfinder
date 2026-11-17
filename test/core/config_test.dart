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
  });
}
