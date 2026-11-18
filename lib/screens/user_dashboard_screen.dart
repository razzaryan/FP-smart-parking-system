import 'package:flutter/material.dart';
import '../controllers/parking_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/user_status_banner.dart';
import '../widgets/active_ticket_card.dart';
import '../widgets/slot_card.dart';

class UserDashboardScreen extends StatelessWidget {
  final ParkingController controller;
  final VoidCallback onLogout;

  const UserDashboardScreen({
    super.key,
    required this.controller,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text(
          'Smart Parking',
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
                Icon(Icons.person, size: 14, color: AppColors.secondary),
                SizedBox(width: 4),
                Text(
                  'Pengendara',
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
                const Icon(Icons.local_parking, color: AppColors.accent, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Sisa Slot: ${controller.availableCount} / ${controller.maxCapacity}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: controller.isFull ? AppColors.statusDanger : AppColors.statusSuccess,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                controller.isFull ? 'PENUH' : 'TERSEDIA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
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
              UserStatusBanner(
                isFull: controller.isFull,
                availableCount: controller.availableCount,
              ),
              const SizedBox(height: 20),
              if (controller.myBookedSlot != null) ...[
                ActiveTicketCard(
                  bookedSlot: controller.myBookedSlot!,
                  checkInTime: controller.checkInTime,
                  onCheckout: () {
                    final released = controller.checkout();
                    if (released != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Anda telah keluar dari Slot $released. Terima kasih!'),
                          backgroundColor: AppColors.secondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Slot Parkir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    'Ketuk slot kosong untuk memesan',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                ),
                itemCount: controller.maxCapacity,
                itemBuilder: (context, index) {
                  return SlotCard(
                    index: index,
                    isOccupied: controller.slotsOccupied[index],
                    isMySlot: controller.myBookedSlot == index,
                    onTap: () {
                      if (controller.myBookedSlot == index) {
                        _showCheckoutDialog(context);
                      } else if (!controller.slotsOccupied[index]) {
                        _showBookingConfirmDialog(context, index);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Slot ${index + 1} sedang terisi kendaraan lain.'),
                            backgroundColor: AppColors.statusDanger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(color: AppColors.statusSuccess, label: 'Tersedia'),
                    _buildLegendItem(color: AppColors.statusDanger, label: 'Terisi'),
                    _buildLegendItem(color: AppColors.secondary, label: 'Slot Anda'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLogout();
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

  void _showBookingConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Pesan Slot ${index + 1}?'),
        content: Text(
          'Slot ${index + 1} sedang kosong. Konfirmasi pemesanan sekarang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.bookSlot(
                index,
                onAlreadyBooked: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Anda sudah memesan Slot ${controller.myBookedSlot! + 1}. Selesaikan pemesanan aktif terlebih dahulu.',
                      ),
                      backgroundColor: AppColors.statusWarning,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil memesan Slot ${index + 1}!'),
                      backgroundColor: AppColors.statusSuccess,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.secondary,
            ),
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Parkiran?'),
        content: Text(
          'Anda akan menyelesaikan sesi parkir di Slot ${controller.myBookedSlot! + 1}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final released = controller.checkout();
              if (released != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Anda telah keluar dari Slot $released. Terima kasih!'),
                    backgroundColor: AppColors.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Keluar Parkir'),
          ),
        ],
      ),
    );
  }
}
