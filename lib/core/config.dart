/// Konfigurasi aplikasi yang membaca kredensial dari environment (--dart-define)
class AppConfig {
  /// URL proyek Supabase, dibaca dari --dart-define=SUPABASE_URL=...
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Anon key proyek Supabase, dibaca dari --dart-define=SUPABASE_ANON_KEY=...
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Memeriksa apakah kredensial Supabase sudah diset melalui --dart-define
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
