// lib/pages/kos_form_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../core/config.dart';

class KosFormPage extends StatefulWidget {
  /// If `kosData` is null the page works in *create* mode,
  /// otherwise it works in *edit* mode and the fields are pre‑filled.
  final Map<String, dynamic>? kosData;

  const KosFormPage({Key? key, this.kosData}) : super(key: key);

  @override
  State<KosFormPage> createState() => _KosFormPageState();
}

class _KosFormPageState extends State<KosFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _facilitiesCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();

  // gender / tipe kos
  String _type = 'Campur';
  bool _isLoading = false;
  String? _errorMsg;

  bool get _isEdit => widget.kosData != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final k = widget.kosData!;
      _nameCtrl.text = k['name'] ?? '';
      _addressCtrl.text = k['address'] ?? '';
      _areaCtrl.text = k['area_campus'] ?? '';
      _priceCtrl.text = k['price_monthly']?.toString() ?? '';
      _facilitiesCtrl.text = k['facilities']?.join(', ') ?? '';
      _type = (k['gender_type'] ?? 'Campur').toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _areaCtrl.dispose();
    _priceCtrl.dispose();
    _facilitiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supa = Supabase.instance.client;
    final Map<String, dynamic> payload = {
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'area_campus': _areaCtrl.text.trim(),
      'price_monthly': int.tryParse(_priceCtrl.text.trim()) ?? 0,
      'gender_type': _type.toLowerCase(),
      // store fasilitas as a string array (you can adapt this)
      'facilities':
          _facilitiesCtrl.text.split(',').map((e) => e.trim()).toList(),
      // the owner_id is the logged‑in user
      'owner_id': supa.auth.currentUser?.id,
      'is_active': true,
      'whatsapp_number': _whatsappCtrl.text.trim(),
    };

    try {
      if (_isEdit) {
        await supa
            .from('kosts')
            .update(payload)
            .eq('id', widget.kosData!['id']);
      } else {
        await supa.from('kosts').insert(payload);
      }
      if (mounted) Navigator.of(context).pop(); // return to list
    } on PostgrestException catch (e) {
      setState(() => _errorMsg = e.message);
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit Kos' : 'Tambah Kos';
    return Scaffold(
      appBar: AppBar(
        title: Text('KosFinder – $title'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ---- Name ----
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Kos',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              // ---- Tipe (gender) ----
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipe Kos',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Putra', child: Text('Putra')),
                  DropdownMenuItem(value: 'Putri', child: Text('Putri')),
                  DropdownMenuItem(value: 'Campur', child: Text('Campur')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'Campur'),
              ),
              const SizedBox(height: 12),
              // ---- Area / Campus ----
              TextFormField(
                controller: _areaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Area / Kampus',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // ---- Alamat ----
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // ---- Harga ----
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Harga per bulan (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? 'Harga wajib diisi'
                    : (int.tryParse(v) == null ? 'Masukkan angka' : null),
              ),
              const SizedBox(height: 12),
              // ---- Fasilitas (comma‑separated) ----
TextFormField(
  controller: _whatsappCtrl,
  decoration: const InputDecoration(
    labelText: 'Nomor WhatsApp (contoh: 628123...)',
    border: OutlineInputBorder(),
  ),
  keyboardType: TextInputType.phone,
  validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
),
              TextFormField(
                controller: _facilitiesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fasilitas (pisahkan dengan koma)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}