import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config.dart';
import 'pages/auth_page.dart';
import 'pages/kos_form_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isConfigured && AppConfig.isValidUrl(AppConfig.supabaseUrl)) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
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
      home: const AuthGate(), // Cek Login/Register dulu
    );
  }
}

// ==========================================
// AUTH GATE (Cek Status Login)
// ==========================================
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan status login
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const AuthPage(); // Jika belum login, tampilkan Login
    } else {
      return const KosListPage(); // Jika sudah login, tampilkan Daftar Kos
    }
  }
}

// ==========================================
// KOS LIST PAGE (Fitur Utama + Filter + CRUD)
// ==========================================
class KosListPage extends StatefulWidget {
  const KosListPage({super.key});

  @override
  State<KosListPage> createState() => _KosListPageState();
}

class _KosListPageState extends State<KosListPage> {
  late Future<List<Map<String, dynamic>>> _kostsFuture;

  // State Filter (T02)
  String _searchQuery = '';
  int? _maxPrice;
  String _typeFilter = 'Semua';

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
            Text('Pengembang:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('NIM: 2415051108'),
            Text('Nama: Ketut Rona Dino'),
            SizedBox(height: 8),
            Text('Versi: 1.0.0 (Release)'),
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

  // Logika Filter (T02)
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> source) {
    return source.where((k) {
      final name = (k['name'] ?? '').toString().toLowerCase();
      final area = (k['area_campus'] ?? '').toString().toLowerCase();
      final address = (k['address'] ?? '').toString().toLowerCase();

      final matchesQuery = _searchQuery.isEmpty ||
          name.contains(_searchQuery) ||
          area.contains(_searchQuery) ||
          address.contains(_searchQuery);

      final price = num.tryParse(k['price_monthly']?.toString() ?? '0') ?? 0;
      final matchesPrice = _maxPrice == null || price <= _maxPrice!;

      final gender = (k['gender_type'] ?? '').toString().toLowerCase();
      final matchesType =
          _typeFilter == 'Semua' || gender == _typeFilter.toLowerCase();

      return matchesQuery && matchesPrice && matchesType;
    }).toList();
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Cari kos (nama/area/alamat)',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              DropdownButton<int?>(
                value: _maxPrice,
                hint: const Text('Harga'),
                items: const [
                  DropdownMenuItem<int?>(value: null, child: Text('Semua')),
                  DropdownMenuItem<int?>(value: 500000, child: Text('< 500rb')),
                  DropdownMenuItem<int?>(value: 1000000, child: Text('< 1jt')),
                ],
                onChanged: (val) => setState(() => _maxPrice = val),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: ['Semua', 'Putra', 'Putri', 'Campur']
                      .map((type) => ChoiceChip(
                            label: Text(type),
                            selected: _typeFilter == type,
                            onSelected: (_) =>
                                setState(() => _typeFilter = type),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final String currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      // Tombol Tambah Kos (Hanya muncul jika sudah login)
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              tooltip: 'Tambah Kos',
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const KosFormPage()),
                );
                _loadKosts(); // Refresh setelah tambah data
              },
            )
          : null,
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text(
                            'Gagal Memuat Data',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
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
                final filtered = _applyFilters(kosts);

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 72, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada kos yang cocok dengan kriteria Anda',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadKosts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final kos = filtered[index];
                      final name = kos['name'] ?? 'Kos Tanpa Nama';
                      final genderType = (kos['gender_type'] ?? 'campur').toString();
                      final area = kos['area_campus'] ?? '-';
                      final address = kos['address'] ?? '-';
                      final priceText = _formatPrice(kos['price_monthly']);
                      final status = (kos['status'] ?? 'tersedia').toString();
                      final isAvailable = status.toLowerCase() == 'tersedia';
                      final imageUrl = kos['image_url'] as String?;
                      final isOwner = kos['owner_id'] == currentUserId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto / Placeholder
                            SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: imageUrl != null && imageUrl.trim().isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
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
                                      // Badge Tipe
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getGenderColor(genderType).withValues(alpha: 0.15),
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
                                      // Badge Status
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isAvailable
                                              ? Colors.green.withValues(alpha: 0.15)
                                              : Colors.red.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isAvailable ? 'Tersedia' : 'Penuh',
                                          style: TextStyle(
                                            color: isAvailable ? Colors.green[800] : Colors.red[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      
                                      // Tombol Edit & Hapus (Hanya untuk Pemilik)
                                      if (isOwner) ...[
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          tooltip: 'Edit',
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => KosFormPage(kosData: kos),
                                              ),
                                            );
                                            _loadKosts();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                          tooltip: 'Hapus',
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (c) => AlertDialog(
                                                title: const Text('Konfirmasi Hapus'),
                                                content: const Text('Anda yakin ingin menghapus kos ini?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(c, false),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(c, true),
                                                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await Supabase.instance.client
                                                  .from('kosts')
                                                  .delete()
                                                  .eq('id', kos['id']);
                                              _loadKosts();
                                            }
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '$area • $address',
                                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
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
          ),
        ],
      ),
    );
  }
}