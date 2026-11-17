import 'package:flutter/material.dart';
import '../controllers/parking_controller.dart';
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
      appBar: AppBar(
        title: const Text(
          'Smart Parking',
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
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 14, color: Colors.indigo.shade700),
                const SizedBox(width: 4),
                Text(
                  'Pengendara',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
                          backgroundColor: Colors.indigo,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Slot Parkir',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1B4B),
                    ),
                  ),
                  Text(
                    'Ketuk slot kosong untuk memesan',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                            backgroundColor: Colors.red.shade700,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(color: Colors.green, label: 'Tersedia'),
                    _buildLegendItem(color: Colors.red, label: 'Terisi'),
                    _buildLegendItem(color: Colors.indigo, label: 'Slot Anda'),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
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
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLogout();
            },
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
          FilledButton(
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
                      backgroundColor: Colors.orange.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Berhasil memesan Slot ${index + 1}!'),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              final released = controller.checkout();
              if (released != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Anda telah keluar dari Slot $released. Terima kasih!'),
                    backgroundColor: Colors.indigo,
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
