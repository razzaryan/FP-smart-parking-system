import 'package:flutter/material.dart';

void main() {
  runApp(const ParkingApp());
}

// 1. Root Widget Aplikasi
class ParkingApp extends StatelessWidget {
  const ParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// 2. Halaman Utama dengan Navigasi (User View & Admin View)
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // Index tab aktif: 0 = Dashboard Pengguna, 1 = Panel Admin
  int _selectedIndex = 0;

  // Status 4 Slot Parkir (true = Terisi, false = Kosong)
  // Nilai awal: Slot A1 terisi (true), sedangkan A2, A3, A4 kosong (false)
  final List<bool> _slotsOccupied = [true, false, false, false];

  // Menyimpan nomor index slot yang sedang ditempati oleh Pengguna aplikasi ini
  // Bernilai null jika pengguna belum parkir
  int? _myBookedSlot;
  String? _checkInTime;

  // Getter otomatis untuk perhitungan kapasitas
  int get _maxCapacity => _slotsOccupied.length;
  int get _occupiedCount => _slotsOccupied.where((occupied) => occupied).length;
  int get _availableCount => _maxCapacity - _occupiedCount;
  bool get _isFull => _occupiedCount >= _maxCapacity;
  double get _occupancyRate => _occupiedCount / _maxCapacity;

  // --- LOGIKA UNTUK PENGGUNA (USER) ---
  void _bookSlotAsUser(int index) {
    // Validasi: Pengguna hanya boleh mengambil 1 slot dalam satu waktu
    if (_myBookedSlot != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Anda sudah parkir di Slot A${_myBookedSlot! + 1}. Selesaikan parkir terlebih dahulu!',
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Jika slot kosong, kunci slot untuk pengguna ini
    if (!_slotsOccupied[index]) {
      final now = TimeOfDay.now();
      setState(() {
        _slotsOccupied[index] = true;
        _myBookedSlot = index;
        _checkInTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil menempati Slot A${index + 1}!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _checkoutAsUser() {
    if (_myBookedSlot != null) {
      final int releasedSlot = _myBookedSlot! + 1;
      setState(() {
        _slotsOccupied[_myBookedSlot!] = false;
        _myBookedSlot = null;
        _checkInTime = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anda telah keluar dari Slot A$releasedSlot. Hati-hati di jalan!'),
          backgroundColor: Colors.indigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // --- LOGIKA UNTUK ADMIN (SIMULASI SENSOR) ---
  void _adminCarEnter() {
    // Cari slot pertama yang masih kosong
    final int emptyIndex = _slotsOccupied.indexOf(false);
    if (emptyIndex != -1) {
      setState(() {
        _slotsOccupied[emptyIndex] = true;
      });
    }
  }

  void _adminCarExit() {
    // Prioritaskan mengeluarkan mobil selain milik pengguna aktif terlebih dahulu
    for (int i = _maxCapacity - 1; i >= 0; i--) {
      if (_slotsOccupied[i] && i != _myBookedSlot) {
        setState(() {
          _slotsOccupied[i] = false;
        });
        return;
      }
    }
    // Jika yang tersisa hanya mobil pengguna aktif, keluarkan juga
    if (_myBookedSlot != null) {
      setState(() {
        _slotsOccupied[_myBookedSlot!] = false;
        _myBookedSlot = null;
        _checkInTime = null;
      });
    }
  }

  void _adminToggleSlot(int index) {
    setState(() {
      _slotsOccupied[index] = !_slotsOccupied[index];
      // Jika slot yang dimatikan admin adalah slot milik user, hapus tiket user
      if (!_slotsOccupied[index] && _myBookedSlot == index) {
        _myBookedSlot = null;
        _checkInTime = null;
      }
    });
  }

  void _resetAll() {
    setState(() {
      for (int i = 0; i < _maxCapacity; i++) {
        _slotsOccupied[i] = false;
      }
      _myBookedSlot = null;
      _checkInTime = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Informasi Parkir Pengguna'
              : 'Dashboard Admin (Sensor)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _selectedIndex == 0
            ? Colors.indigo.shade50
            : Colors.amber.shade100,
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              onPressed: _resetAll,
              tooltip: 'Kosongkan Semua Slot',
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      // Menampilkan halaman sesuai tab yang dipilih
      body: _selectedIndex == 0 ? _buildUserDashboard() : _buildAdminDashboard(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tampilan Pengguna',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Administrator',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAMPILAN 1: DASHBOARD PENGGUNA (USER)
  // ===========================================================================
  Widget _buildUserDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Banner Status Ketersediaan Parkir
          _buildUserStatusBanner(),
          const SizedBox(height: 16),

          // 2. Kartu Tiket Parkir Aktif (Hanya muncul jika user sedang parkir)
          if (_myBookedSlot != null) ...[
            _buildActiveTicketCard(),
            const SizedBox(height: 16),
          ],

          // 3. Judul & Legenda Denah Slot Parkir
          const Text(
            'Pilih Slot Parkir (Lahan Utama)',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk pada slot berwarna hijau untuk memarkirkan mobil Anda.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),

          // Indikator Legenda Warna
          Row(
            children: [
              _buildLegendItem(Colors.green, 'Kosong'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.red, 'Terisi'),
              const SizedBox(width: 16),
              _buildLegendItem(Colors.indigo, 'Mobil Anda'),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Grid 4 Slot Parkir Interaktif (2 Kolom x 2 Baris)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _maxCapacity,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              return _buildInteractiveUserSlotCard(index);
            },
          ),
        ],
      ),
    );
  }

  // Banner besar informasi sisa slot untuk Pengguna
  Widget _buildUserStatusBanner() {
    final Color bannerColor =
        _isFull ? Colors.red.shade700 : Colors.green.shade700;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: bannerColor.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isFull ? Icons.block : Icons.local_parking,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isFull ? 'MOHON MAAF, PARKIR PENUH!' : 'SLOT PARKIR TERSEDIA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isFull
                      ? 'Seluruh $_maxCapacity slot sedang terisi. Silakan tunggu.'
                      : 'Tersisa $_availableCount dari $_maxCapacity slot yang siap digunakan.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kartu Tiket Aktif saat pengguna berhasil memilih slot
  Widget _buildActiveTicketCard() {
    return Card(
      elevation: 0,
      color: Colors.indigo.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.indigo.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.confirmation_number, color: Colors.indigo.shade800),
                    const SizedBox(width: 8),
                    Text(
                      'Status Parkir Anda Aktif',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Slot A${_myBookedSlot! + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Waktu Masuk: $_checkInTime',
              style: TextStyle(fontSize: 13, color: Colors.indigo.shade800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _checkoutAsUser,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                ),
                icon: const Icon(Icons.exit_to_app, size: 18),
                label: const Text('Selesai Parkir / Keluar Lahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kotak Slot Parkir untuk Pengguna
  Widget _buildInteractiveUserSlotCard(int index) {
    final bool isOccupied = _slotsOccupied[index];
    final bool isMySlot = _myBookedSlot == index;

    Color bgColor;
    Color borderColor;
    Color mainColor;
    String statusLabel;
    IconData slotIcon;

    if (isMySlot) {
      bgColor = Colors.indigo.shade50;
      borderColor = Colors.indigo;
      mainColor = Colors.indigo.shade800;
      statusLabel = 'Mobil Anda';
      slotIcon = Icons.directions_car;
    } else if (isOccupied) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade300;
      mainColor = Colors.red.shade700;
      statusLabel = 'Terisi';
      slotIcon = Icons.directions_car_filled;
    } else {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade400;
      mainColor = Colors.green.shade800;
      statusLabel = 'Kosong (Ketuk)';
      slotIcon = Icons.add_circle_outline;
    }

    return InkWell(
      onTap: !isOccupied ? () => _bookSlotAsUser(index) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SLOT A${index + 1}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 8),
            Icon(slotIcon, size: 34, color: mainColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAMPILAN 2: DASHBOARD ADMIN (KONTROL SENSOR & MONITORING)
  // ===========================================================================
  Widget _buildAdminDashboard() {
    final Color statusColor = _isFull ? Colors.red : Colors.green;
    final String statusText = _isFull ? 'Penuh' : 'Tersedia';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Kartu Ringkasan Admin
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    label: 'Total Kapasitas',
                    value: _maxCapacity.toString(),
                    color: Colors.indigo,
                    icon: Icons.local_parking,
                  ),
                  Container(height: 40, width: 1, color: Colors.grey.shade300),
                  _buildSummaryItem(
                    label: 'Terisi',
                    value: _occupiedCount.toString(),
                    color: Colors.orange.shade800,
                    icon: Icons.directions_car,
                  ),
                  Container(height: 40, width: 1, color: Colors.grey.shade300),
                  _buildSummaryItem(
                    label: 'Tersedia',
                    value: _availableCount.toString(),
                    color: Colors.green.shade700,
                    icon: Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kartu Kontrol Sensor Admin
          Card(
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Control Sensor Parking System',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk kotak slot di bawah untuk mengubah status sensor per slot secara langsung:',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),

                  // 4 Kotak Sensor yang bisa diklik langsung oleh Admin
                  Row(
                    children: List.generate(_maxCapacity, (index) {
                      final bool isOccupied = _slotsOccupied[index];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _adminToggleSlot(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isOccupied
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isOccupied
                                    ? Colors.red.shade300
                                    : Colors.green.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  isOccupied
                                      ? Icons.sensors
                                      : Icons.sensors_off,
                                  color: isOccupied ? Colors.red : Colors.green,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'A${index + 1}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  isOccupied ? 'ON' : 'OFF',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isOccupied
                                        ? Colors.red.shade700
                                        : Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _occupancyRate,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isFull
                            ? Colors.red
                            : (_occupancyRate >= 0.75 ? Colors.orange : Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tombol + Mobil Masuk & - Mobil Keluar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _occupiedCount > 0 ? _adminCarExit : null,
                          icon: const Icon(Icons.remove, size: 18),
                          label: const Text('Mobil Keluar'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: Colors.red.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: !_isFull ? _adminCarEnter : null,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Mobil Masuk'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}