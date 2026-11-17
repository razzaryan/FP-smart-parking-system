import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkir_dashboard/main.dart';

void main() {
  testWidgets('User can only book slot when wifi is connected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ParkingApp());

    // 1. Awalnya Wi-Fi terputus di login screen
    expect(find.text('Status Wi-Fi: TERPUTUS'), findsOneWidget);

    // 2. User login saat wifi terputus (bisa masuk)
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'user');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'user123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // 3. Status sensor offline di halaman user
    expect(find.text('Koneksi Sensor Offline'), findsOneWidget);
    expect(find.text('Offline'), findsWidgets);

    // 4. Tekan slot kosong (SLOT 2) saat wifi terputus -> gagal / muncul notifikasi
    await tester.tap(find.text('SLOT 2'));
    await tester.pumpAndSettle();
    expect(
      find.text('Sensor parkir offline. Pemesanan slot hanya dapat dilakukan saat Wi-Fi terhubung.'),
      findsOneWidget,
    );

    // 5. Logout kembali ke login screen
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    // 6. Sambungkan Wi-Fi di login screen
    await tester.tap(find.text('Sambungkan'));
    await tester.pumpAndSettle();
    expect(find.text('Status Wi-Fi: TERHUBUNG'), findsOneWidget);

    // 7. Login kembali sebagai user saat wifi terhubung
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'user');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'user123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // 8. Banner online & slot tersedia
    expect(find.text('Slot Tersedia'), findsOneWidget);
    expect(find.text('Tersedia'), findsWidgets);

    // 9. Pesan Slot 2 berhasil
    await tester.tap(find.text('SLOT 2'));
    await tester.pumpAndSettle();
    expect(find.text('Pesan Slot 2?'), findsOneWidget);
    await tester.tap(find.text('Pesan Sekarang'));
    await tester.pumpAndSettle();

    // 10. Tiket aktif muncul
    expect(find.text('TIKET PARKIR AKTIF'), findsOneWidget);
    expect(find.text('SLOT 2'), findsWidgets);
  });

  testWidgets('Admin cannot login when wifi is disconnected, can login after wifi connected', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ParkingApp());

    // 1. Wi-Fi terputus di awal
    expect(find.text('Status Wi-Fi: TERPUTUS'), findsOneWidget);

    // 2. Coba login sebagai admin saat wifi terputus -> ditolak
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'admin123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(
      find.text('Admin hanya bisa mengakses saat Wi-Fi sensor terhubung. Silakan hubungkan ESP32 terlebih dahulu.'),
      findsOneWidget,
    );

    // 3. Sambungkan Wi-Fi
    await tester.tap(find.text('Sambungkan'));
    await tester.pumpAndSettle();
    expect(find.text('Status Wi-Fi: TERHUBUNG'), findsOneWidget);

    // 4. Login lagi sebagai admin setelah wifi terhubung -> berhasil
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Smart Parking - Petugas'), findsOneWidget);
    expect(find.text('Sensor Hardware ESP32'), findsOneWidget);
    expect(find.text('TERHUBUNG'), findsOneWidget);
    expect(find.text('Sensor: Terdeteksi'), findsWidgets);

    // 5. Admin memiliki otoritas penuh mengubah slot
    await tester.tap(find.text('SLOT 1'));
    await tester.pumpAndSettle();
    expect(find.text('Sensor: Kosong'), findsWidgets);
  });
}
