import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
    final statusColor = isFull ? AppColors.statusDanger : AppColors.statusSuccess;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFull ? Icons.do_not_disturb_on : Icons.check_circle,
              color: statusColor,
              size: 26,
            ),
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
                    color: statusColor,
                  ),
                ),
                Text(
                  isFull
                      ? 'Mohon tunggu kendaraan lain keluar.'
                      : '$availableCount dari 4 slot siap digunakan.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
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
