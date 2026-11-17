import 'package:flutter/material.dart';

class UserStatusBanner extends StatelessWidget {
  final bool isFull;
  final int availableCount;

  const UserStatusBanner({
    super.key,
    required this.isFull,
    required this.availableCount,
  });

  @override
  Widget build(BuildContext context) {
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
