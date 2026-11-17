import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkir_dashboard/main.dart';

void main() {
  testWidgets('App loads login screen and can login as user', (WidgetTester tester) async {
    await tester.pumpWidget(const ParkingApp());

    // Verifikasi berada di Login Screen
    expect(find.text('Smart Parking System'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    // Coba login sebagai user
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'user');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'user123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // Verifikasi masuk ke User Dashboard
    expect(find.text('Pengendara'), findsOneWidget);
    expect(find.text('Pilih Slot Parkir'), findsOneWidget);

    // Logout
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    expect(find.text('Konfirmasi Keluar'), findsOneWidget);
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    // Kembali ke Login Screen
    expect(find.text('Smart Parking System'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Can login as admin and access admin features', (WidgetTester tester) async {
    await tester.pumpWidget(const ParkingApp());

    // Coba login sebagai admin
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'admin123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // Verifikasi masuk ke Admin Dashboard
    expect(find.text('Smart Parking - Petugas'), findsOneWidget);
    expect(find.text('Sensor Hardware ESP32'), findsOneWidget);

    // Verifikasi slot offline saat Wi-Fi terputus
    expect(find.text('Sensor: Offline'), findsWidgets);

    // Coba tekan slot saat wifi terputus (harus gagal/muncul snackbar)
    await tester.tap(find.text('SLOT 1'));
    await tester.pump();
    expect(find.text('Wi-Fi sensor terputus. Hubungkan ke ESP32 untuk mengubah status slot.'), findsOneWidget);

    // Tunggu snackbar selesai menghilang
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Hubungkan Wi-Fi
    await tester.tap(find.text('Hubungkan Wi-Fi Sensor'));
    await tester.pump();
    expect(find.text('TERHUBUNG'), findsOneWidget);

    // Tunggu snackbar koneksi menghilang
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Tekan slot saat wifi terhubung (berhasil mengubah status)
    await tester.tap(find.text('SLOT 1'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Sensor: Kosong'), findsWidgets);
  });
}
