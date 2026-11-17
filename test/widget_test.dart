import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';

void main() {
  testWidgets('KosFinderApp displays KosListPage and AppBar title',
      (WidgetTester tester) async {
    // Build KosFinderApp
    await tester.pumpWidget(const KosFinderApp());

    // Pastikan AppBar menampilkan nama aplikasi 'KosFinder'
    expect(find.text('KosFinder'), findsOneWidget);

    // Pastikan ada tombol info dan refresh di AppBar
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);

    // Tunggu FutureBuilder selesai dievaluasi
    await tester.pumpAndSettle();

    // Verifikasi pesan empty state tampil ketika belum ada data kos (US01-AC2)
    expect(
      find.text('Belum ada kos yang terdaftar saat ini'),
      findsOneWidget,
    );
  });

  testWidgets('About dialog displays developer NIM and Name',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KosFinderApp());
    await tester.pumpAndSettle();

    // Ketuk tombol info di AppBar
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    // Verifikasi identitas pengembang wajib sesuai AGENTS.md
    expect(find.text('Tentang KosFinder'), findsOneWidget);
    expect(find.text('NIM: 2415051108'), findsOneWidget);
    expect(find.text('Nama: Ketut Rona Dino'), findsOneWidget);

    // Tutup dialog
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Tentang KosFinder'), findsNothing);
  });
}
