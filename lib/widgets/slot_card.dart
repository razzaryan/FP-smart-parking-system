import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SlotCard extends StatelessWidget {
  final int index;
  final bool isOccupied;
  final bool isMySlot;
  final VoidCallback onTap;

  const SlotCard({
    super.key,
    required this.index,
    required this.isOccupied,
    required this.isMySlot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    Color borderColor;
    Color statusColor;

    if (isMySlot) {
      cardColor = AppColors.secondary;
      borderColor = AppColors.accent;
      statusColor = AppColors.accent;
    } else if (isOccupied) {
      cardColor = AppColors.surface;
      borderColor = AppColors.statusDanger.withValues(alpha: 0.35);
      statusColor = AppColors.statusDanger;
    } else {
      cardColor = AppColors.surface;
      borderColor = AppColors.statusSuccess.withValues(alpha: 0.35);
      statusColor = AppColors.statusSuccess;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: isMySlot ? 2 : 1),
            boxShadow: [
              BoxShadow(
                color: isMySlot
                    ? AppColors.secondary.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SLOT ${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isMySlot ? Colors.white : AppColors.secondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Icon(
                isMySlot
                    ? Icons.directions_car_filled
                    : (isOccupied ? Icons.directions_car : Icons.local_parking),
                size: 38,
                color: statusColor,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isMySlot
                      ? AppColors.accent.withValues(alpha: 0.2)
                      : statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: isMySlot ? Border.all(color: AppColors.accent) : null,
                ),
                child: Text(
                  isMySlot
                      ? 'Slot Anda'
                      : (isOccupied ? 'Terisi' : 'Tersedia'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
