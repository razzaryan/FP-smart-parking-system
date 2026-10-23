import 'package:flutter/material.dart';

void main() {
  runApp(const ParkingApp());
}

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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _activeScreen = 0;

  final List<bool> _slotsOccupied = [true, false, false, false];

  int? _myBookedSlot;
  String? _checkInTime;

  int get _maxCapacity => _slotsOccupied.length;
  int get _occupiedCount => _slotsOccupied.where((occupied) => occupied).length;
  int get _availableCount => _maxCapacity - _occupiedCount;
  bool get _isFull => _occupiedCount >= _maxCapacity;
  double get _occupancyRate => _occupiedCount / _maxCapacity;

  void _bookSlotAsUser(int index) {
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

  void _adminCarEnter() {
    final int emptyIndex = _slotsOccupied.indexOf(false);
    if (emptyIndex != -1) {
      setState(() {
        _slotsOccupied[emptyIndex] = true;
      });
    }
  }

  void _adminCarExit() {
    for (int i = _maxCapacity - 1; i >= 0; i--) {
      if (_slotsOccupied[i] && i != _myBookedSlot) {
        setState(() {
          _slotsOccupied[i] = false;
        });
        return;
      }
    }
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
    // Menampilkan Halaman Pilih Peran (Login Gate) jika _activeScreen == 0
    if (_activeScreen == 0) {
      return _buildLoginGateScreen();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Keluar / Ganti Akses',
          onPressed: () => setState(() => _activeScreen = 0),
        ),
        title: Text(
          _activeScreen == 1
              ? 'User Parking Information'
              : 'Dashboard Admin (Sensor)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: _activeScreen == 1
            ? Colors.indigo.shade50
            : Colors.amber.shade100,
        actions: [
          if (_activeScreen == 2)
            IconButton(
              onPressed: _resetAll,
              tooltip: 'Kosongkan Semua Slot',
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: _activeScreen == 1 ? _buildUserDashboard() : _buildAdminDashboard(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _activeScreen - 1,
        onDestinationSelected: (index) {
          setState(() {
            _activeScreen = index + 1;
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
            label: 'Simulasi Admin',
          ),
        ],
      ),
    );
  }

  Widget _buildLoginGateScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B), // Deep Indigo Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_parking_rounded,
                        size: 52,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Smart Parking System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sistem Pemantauan Lahan Parkir Real-Time\n(Kapasitas 4 Slot Utama)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMiniPreviewStat(
                            'Kapasitas',
                            '$_maxCapacity',
                            Colors.indigo,
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          _buildMiniPreviewStat(
                            'Terisi',
                            '$_occupiedCount',
                            Colors.orange.shade800,
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          _buildMiniPreviewStat(
                            'Tersedia',
                            '$_availableCount',
                            Colors.green.shade700,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => setState(() => _activeScreen = 1),
                        icon: const Icon(Icons.person),
                        label: const Text('Masuk sebagai Pengguna'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _activeScreen = 2),
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Masuk sebagai Admin'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo.shade900,
                          side: BorderSide(color: Colors.indigo.shade200, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniPreviewStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildUserDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserStatusBanner(),
          const SizedBox(height: 16),

          if (_myBookedSlot != null) ...[
            _buildActiveTicketCard(),
            const SizedBox(height: 16),
          ],

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
                        'Kontrol Sensor Lahan Parkir',
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