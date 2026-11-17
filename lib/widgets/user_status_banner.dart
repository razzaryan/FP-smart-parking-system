import 'package:flutter/material.dart';

class UserStatusBanner extends StatelessWidget {
  final bool isFull;
  final int availableCount;
  final bool wifiConnected;

  const UserStatusBanner({
    super.key,
    required this.isFull,
    required this.availableCount,
    this.wifiConnected = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!wifiConnected) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: Colors.orange.shade800,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koneksi Sensor Offline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  Text(
                    'Sistem sensor parkir belum tersambung ke Wi-Fi. Pemesanan slot ditangguhkan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFull ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFull ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isFull ? Icons.do_not_disturb_on : Icons.check_circle,
            color: isFull ? Colors.red.shade700 : Colors.green.shade700,
            size: 32,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFull ? 'Parkiran Penuh' : 'Slot Tersedia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isFull ? Colors.red.shade900 : Colors.green.shade900,
                  ),
                ),
                Text(
                  isFull
                      ? 'Mohon tunggu kendaraan lain keluar.'
                      : '$availableCount dari 4 slot siap digunakan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isFull ? Colors.red.shade700 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
