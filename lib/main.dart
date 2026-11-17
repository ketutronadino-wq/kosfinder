import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isConfigured && AppConfig.isValidUrl(AppConfig.supabaseUrl)) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  runApp(const KosFinderApp());
}

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const KosListPage(),
    );
  }
}

class KosListPage extends StatefulWidget {
  const KosListPage({super.key});

  @override
  State<KosListPage> createState() => _KosListPageState();
}

class _KosListPageState extends State<KosListPage> {
  late Future<List<Map<String, dynamic>>> _kostsFuture;

  @override
  void initState() {
    super.initState();
    _loadKosts();
  }

  void _loadKosts() {
    setState(() {
      _kostsFuture = _fetchKosts();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchKosts() async {
    if (!AppConfig.isConfigured || !AppConfig.isValidUrl(AppConfig.supabaseUrl)) {
      return [];
    }

    final response = await Supabase.instance.client
        .from('kosts')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Rp 0';
    final numPrice = num.tryParse(price.toString()) ?? 0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return '${formatter.format(numPrice)} / bulan';
  }

  Color _getGenderColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'putra':
        return Colors.blue;
      case 'putri':
        return Colors.pink;
      case 'campur':
      default:
        return Colors.purple;
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang KosFinder'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aplikasi Pencarian & Publikasi Kos'),
            SizedBox(height: 12),
            Text(
              'Pengembang:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('NIM: 2415051108'),
            Text('Nama: Ketut Rona Dino'),
            SizedBox(height: 8),
            Text('Versi: 1.0.0 (Slice 1)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(String genderType) {
    return Container(
      color: _getGenderColor(genderType).withValues(alpha: 0.08),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apartment,
              size: 48,
              color: _getGenderColor(genderType).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              'Foto Kos',
              style: TextStyle(
                color: _getGenderColor(genderType).withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KosFinder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () => _showAboutDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _loadKosts,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _kostsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memuat data kos...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            final errorMsg = snapshot.error.toString();
            final isTableMissing = errorMsg.contains('PGRST205');

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Dapat Terhubung ke Database',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isTableMissing
                          ? 'Tabel "kosts" belum dibuat di database Supabase Anda. Silakan jalankan berkas supabase/migrations/001_init.sql di SQL Editor Supabase.'
                          : 'Terjadi kesalahan saat memuat data: $errorMsg',
                      style: const TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadKosts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final kosts = snapshot.data ?? [];

          // US01-AC2: Tampilan ketika data kosong
          if (kosts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home_work_outlined,
                        size: 72, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada kos yang terdaftar saat ini',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kos yang aktif akan ditampilkan di sini. Tarik ke bawah atau tekan tombol muat ulang untuk memperbarui.',
                      style: TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadKosts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Segarkan'),
                    ),
                  ],
                ),
              ),
            );
          }

          // US01-AC1: Menampilkan daftar kartu kos aktif
          return RefreshIndicator(
            onRefresh: () async => _loadKosts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: kosts.length,
              itemBuilder: (context, index) {
                final kos = kosts[index];
                final name = kos['name'] ?? 'Kos Tanpa Nama';
                final genderType = (kos['gender_type'] ?? 'campur').toString();
                final area = kos['area_campus'] ?? '-';
                final address = kos['address'] ?? '-';
                final priceText = _formatPrice(kos['price_monthly']);
                final status = (kos['status'] ?? 'tersedia').toString();
                final isAvailable = status.toLowerCase() == 'tersedia';
                final imageUrl = kos['image_url'] as String?;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar atau Fallback Placeholder
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: imageUrl != null && imageUrl.trim().isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(genderType),
                              )
                            : _buildPlaceholderImage(genderType),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Badge Tipe Kos
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getGenderColor(genderType)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Kos ${genderType.toUpperCase()}',
                                    style: TextStyle(
                                      color: _getGenderColor(genderType),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                // Badge Ketersediaan
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? Colors.green.withValues(alpha: 0.15)
                                        : Colors.red.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAvailable ? 'Tersedia' : 'Penuh',
                                    style: TextStyle(
                                      color: isAvailable
                                          ? Colors.green[800]
                                          : Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Nama Kos
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Lokasi / Kampus & Alamat
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '$area • $address',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Harga Bulanan
                            Text(
                              priceText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
