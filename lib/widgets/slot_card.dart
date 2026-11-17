import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final int index;
  final bool isOccupied;
  final bool isMySlot;
  final bool isOffline;
  final VoidCallback onTap;

  const SlotCard({
    super.key,
    required this.index,
    required this.isOccupied,
    required this.isMySlot,
    this.isOffline = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    Color borderColor;
    Color accentColor;

    if (isOffline && !isMySlot) {
      cardColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade300;
      accentColor = Colors.grey.shade500;
    } else if (isMySlot) {
      cardColor = Colors.indigo.shade50;
      borderColor = Colors.indigo.shade400;
      accentColor = Colors.indigo.shade700;
    } else if (isOccupied) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      accentColor = Colors.red.shade700;
    } else {
      cardColor = Colors.green.shade50;
      borderColor = Colors.green.shade200;
      accentColor = Colors.green.shade700;
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
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SLOT ${index + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isMySlot
                      ? Colors.indigo.shade900
                      : (isOffline ? Colors.grey.shade600 : Colors.grey.shade700),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Icon(
                isMySlot
                    ? Icons.directions_car_filled
                    : (isOffline
                        ? Icons.cloud_off_rounded
                        : (isOccupied ? Icons.directions_car : Icons.local_parking)),
                size: 38,
                color: accentColor,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isMySlot
                      ? 'Slot Anda'
                      : (isOffline ? 'Offline' : (isOccupied ? 'Terisi' : 'Tersedia')),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
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
