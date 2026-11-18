import 'package:flutter/material.dart';
import '../controllers/parking_controller.dart';
import '../theme/app_colors.dart';
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
              foregroundColor: Colors.white,
            ),
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
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Smart Parking - Petugas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.secondary,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: AppColors.secondary),
                SizedBox(width: 4),
                Text(
                  'Petugas',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Reset Simulasi',
            onPressed: () {
              if (!controller.wifiConnected) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wi-Fi sensor terputus. Hubungkan ke ESP32 untuk mereset slot.'),
                    backgroundColor: AppColors.statusDanger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              controller.resetAll();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua slot parkir direset menjadi kosong.'),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Keluar Akun',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 52,
        color: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wifi,
                  size: 16,
                  color: controller.wifiConnected ? AppColors.accent : Colors.white38,
                ),
                const SizedBox(width: 8),
                Text(
                  'ESP32: ${controller.wifiConnected ? controller.sensorIp : "Offline"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              'Terisi: ${controller.occupiedCount} / ${controller.maxCapacity}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SummaryItem(
                      label: 'Total Slot',
                      value: '${controller.maxCapacity}',
                      color: AppColors.secondary,
                      icon: Icons.local_parking,
                    ),
                    Container(width: 1, height: 48, color: AppColors.surfaceBorder),
                    SummaryItem(
                      label: 'Tersedia',
                      value: '${controller.availableCount}',
                      color: controller.isFull ? AppColors.statusDanger : AppColors.statusSuccess,
                      icon: Icons.check_circle_outline,
                    ),
                    Container(width: 1, height: 48, color: AppColors.surfaceBorder),
                    SummaryItem(
                      label: 'Terisi',
                      value: '${controller.occupiedCount}',
                      color: AppColors.statusWarning,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
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
                              color: controller.wifiConnected ? AppColors.statusSuccess : AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Sensor Hardware ESP32',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: controller.wifiConnected
                                ? AppColors.statusSuccess.withValues(alpha: 0.12)
                                : AppColors.statusDanger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.wifiConnected
                                  ? AppColors.statusSuccess.withValues(alpha: 0.3)
                                  : AppColors.statusDanger.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            controller.wifiConnected ? 'TERHUBUNG' : 'TERPUTUS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: controller.wifiConnected ? AppColors.statusSuccess : AppColors.statusDanger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SSID: ${controller.ssidName}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
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
                              backgroundColor: controller.wifiConnected
                                  ? AppColors.secondary
                                  : AppColors.statusDanger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(controller.wifiConnected ? Icons.wifi_off : Icons.wifi),
                        label: Text(controller.wifiConnected ? 'Putuskan Wi-Fi Sensor' : 'Hubungkan Wi-Fi Sensor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.wifiConnected ? AppColors.statusDanger : AppColors.accent,
                          foregroundColor: controller.wifiConnected ? Colors.white : AppColors.secondary,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
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
                  final slotStatusColor = !controller.wifiConnected
                      ? AppColors.textMuted
                      : (isOccupied ? AppColors.statusDanger : AppColors.statusSuccess);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!controller.wifiConnected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Wi-Fi sensor terputus. Hubungkan ke ESP32 untuk mengubah status slot.',
                              ),
                              backgroundColor: AppColors.statusDanger,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }
                        controller.adminToggleSlot(index);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: slotStatusColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SLOT ${index + 1}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Icon(
                              !controller.wifiConnected
                                  ? Icons.sensors_off
                                  : (isOccupied ? Icons.sensors : Icons.sensors_off),
                              color: slotStatusColor,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              !controller.wifiConnected
                                  ? 'Sensor: Offline'
                                  : (isOccupied ? 'Sensor: Terdeteksi' : 'Sensor: Kosong'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: slotStatusColor,
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Simulator Gerbang Masuk / Keluar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (!controller.wifiConnected || controller.isFull)
                                ? null
                                : controller.adminCarEnter,
                            icon: const Icon(Icons.login),
                            label: const Text('Mobil Masuk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: (!controller.wifiConnected || controller.occupiedCount == 0)
                                ? null
                                : controller.adminCarExit,
                            icon: const Icon(Icons.logout),
                            label: const Text('Mobil Keluar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(color: AppColors.secondary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!controller.wifiConnected) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Simulator gerbang dinonaktifkan saat sensor offline.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.statusWarning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
