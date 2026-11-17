class AppConfig {
  // Konfigurasi Supabase asli
  static const String supabaseUrl = 'https://dzdvdyaxjqbfaevkypvf.supabase.co';
  
  // Anon Key dari Supabase
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR6ZHZkeWF4anFiZmFldmt5cHZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ5MDI4NDUsImV4cCI6MjExMDQ3ODg0NX0.l7AbRAVMBPSnzNc05uGFOem7ArW0xDBdTlzBL7dnGMQ';

  // Cek apakah URL sudah diisi (bukan kosong)
  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // Cek format URL valid (harus diawali http/https)
  static bool isValidUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }
}