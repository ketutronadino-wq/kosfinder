class AppConfig {
  // URL Project Supabase BARU
  static const String supabaseUrl = 'https://ondjfadwdbhtpitkyhhd.supabase.co';
  
  // Anon Key BARU dari Supabase
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uZGpmYWR3ZGJodHBpdGt5aGhkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ5NTY2MzAsImV4cCI6MjExMDUzMjYzMH0.Xctzmn292CiC0jq99bK0pPeniMVRiacU5esDYa_ixIo';

  // Cek apakah konfigurasi sudah diisi
  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Cek format URL valid
  static bool isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}