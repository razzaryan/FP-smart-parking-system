import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkir_dashboard/main.dart';

void main() {
  testWidgets('User can always access and book parking slots directly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ParkingApp());

    // 1. Login user
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'user');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'user123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // 2. Langsung tampil slot tersedia dan banner aktif
    expect(find.text('Slot Tersedia'), findsOneWidget);
    expect(find.text('Tersedia'), findsWidgets);

    // 3. User memesan Slot 2 secara langsung
    await tester.tap(find.text('SLOT 2'));
    await tester.pumpAndSettle();
    expect(find.text('Pesan Slot 2?'), findsOneWidget);
    await tester.tap(find.text('Pesan Sekarang'));
    await tester.pumpAndSettle();

    // 4. Tiket aktif terbit
    expect(find.text('TIKET PARKIR AKTIF'), findsOneWidget);
    expect(find.text('SLOT 2'), findsWidgets);
  });

  testWidgets('Admin controls wifi connection inside admin dashboard', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const ParkingApp());

    // 1. Login admin
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'admin');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'admin123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    // 2. Di dashboard admin, status wifi awal TERPUTUS
    expect(find.text('Smart Parking - Petugas'), findsOneWidget);
    expect(find.text('TERPUTUS'), findsOneWidget);

    // 3. Hubungkan Wi-Fi di dashboard admin
    await tester.tap(find.text('Hubungkan Wi-Fi Sensor'));
    await tester.pumpAndSettle();
    expect(find.text('TERHUBUNG'), findsOneWidget);

    // 4. Slot bisa diubah oleh admin
    await tester.tap(find.text('SLOT 1'));
    await tester.pumpAndSettle();
    expect(find.text('Sensor: Kosong'), findsWidgets);
  });
}
