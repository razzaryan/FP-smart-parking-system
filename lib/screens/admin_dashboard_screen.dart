import 'package:flutter/material.dart';
import '../controllers/parking_controller.dart';
import '../widgets/summary_item.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ParkingController controller;
  final VoidCallback onLogout;

  const AdminDashboardScreen({
    super.key,
    required this.controller,
    required this.onLogout,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.controller.sensorIp);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun petugas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Parking - Petugas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: Colors.teal.shade700),
                const SizedBox(width: 4),
                Text(
                  'Petugas',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Simulasi',
            onPressed: () {
              controller.resetAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua slot parkir direset menjadi kosong.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            tooltip: 'Keluar Akun',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SummaryItem(
                      label: 'Total Slot',
                      value: '${controller.maxCapacity}',
                      color: Colors.indigo,
                      icon: Icons.local_parking,
                    ),
                    Container(width: 1, height: 48, color: Colors.grey.shade200),
                    SummaryItem(
                      label: 'Tersedia',
                      value: '${controller.availableCount}',
                      color: controller.isFull ? Colors.red : Colors.green,
                      icon: Icons.check_circle_outline,
                    ),
                    Container(width: 1, height: 48, color: Colors.grey.shade200),
                    SummaryItem(
                      label: 'Terisi',
                      value: '${controller.occupiedCount}',
                      color: Colors.orange.shade800,
                      icon: Icons.directions_car_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sensor Wi-Fi Config Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.wifi,
                              color: controller.wifiConnected ? Colors.green.shade700 : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sensor Hardware ESP32',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: controller.wifiConnected ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.wifiConnected ? Colors.green.shade300 : Colors.red.shade300,
                            ),
                          ),
                          child: Text(
                            controller.wifiConnected ? 'TERHUBUNG' : 'TERPUTUS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: controller.wifiConnected ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SSID: ${controller.ssidName}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ipController,
                      decoration: const InputDecoration(
                        labelText: 'IP Sensor ESP32',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.toggleWifi(_ipController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                controller.wifiConnected
                                    ? 'Terhubung ke ${controller.ssidName} (${controller.sensorIp})'
                                    : 'Terputus dari ${controller.ssidName}',
                              ),
                              backgroundColor:
                                  controller.wifiConnected ? Colors.green.shade700 : Colors.red.shade700,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(controller.wifiConnected ? Icons.wifi_off : Icons.wifi),
                        label: Text(controller.wifiConnected ? 'Putuskan Wi-Fi Sensor' : 'Hubungkan Wi-Fi Sensor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.wifiConnected ? Colors.red.shade600 : Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Slot Controls
              const Text(
                'Kontrol & Status Slot Fisik',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B)),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: controller.maxCapacity,
                itemBuilder: (context, index) {
                  final isOccupied = controller.slotsOccupied[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => controller.adminToggleSlot(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isOccupied ? Colors.red.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOccupied ? Colors.red.shade200 : Colors.green.shade200,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SLOT ${index + 1}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              isOccupied ? Icons.sensors : Icons.sensors_off,
                              color: isOccupied ? Colors.red.shade700 : Colors.green.shade700,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOccupied ? 'Sensor: Terdeteksi' : 'Sensor: Kosong',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isOccupied ? Colors.red.shade800 : Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Simulator Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Simulator Gerbang Masuk / Keluar',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.isFull ? null : controller.adminCarEnter,
                            icon: const Icon(Icons.login),
                            label: const Text('Mobil Masuk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.occupiedCount == 0 ? null : controller.adminCarExit,
                            icon: const Icon(Icons.logout),
                            label: const Text('Mobil Keluar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
