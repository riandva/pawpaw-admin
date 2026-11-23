import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../widgets/app_notification.dart';

class CommissionsView extends StatelessWidget {
  const CommissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Obx(() {
      final a = controller.analytics.value;
      final currentRate = controller.commissionRate.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Pengaturan & Laporan Komisi Platform 💰',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Skema bagi hasil otomatis per transaksi antara Platform PawPaw dan Mitra.',
              style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            // Commission Setting Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AdminTheme.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 600;
                      final titleCol = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Persentase Komisi Platform Saat Ini',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AdminTheme.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dikenakan otomatis pada setiap pesanan yang telah diselesaikan (completed).',
                            style: TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                          ),
                        ],
                      );

                      final badge = Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AdminTheme.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AdminTheme.primary),
                        ),
                        child: Text(
                          '${currentRate.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AdminTheme.primaryDark),
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleCol,
                            const SizedBox(height: 12),
                            badge,
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleCol),
                          const SizedBox(width: 16),
                          badge,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Slider(
                    value: currentRate,
                    min: 5.0,
                    max: 25.0,
                    divisions: 20,
                    activeColor: AdminTheme.primary,
                    inactiveColor: AdminTheme.divider,
                    label: '${currentRate.toStringAsFixed(1)}%',
                    onChanged: (val) {
                      controller.commissionRate.value = val;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          '5% (Rendah)',
                          style: TextStyle(fontSize: 11.5, color: AdminTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Flexible(
                        child: Text(
                          '10% (Standar)',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AdminTheme.primaryDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Flexible(
                        child: Text(
                          '25% (Maksimal)',
                          style: TextStyle(fontSize: 11.5, color: AdminTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      AppNotification.showSuccess(
                        title: 'Pengaturan Disimpan',
                        message: 'Tarif komisi platform ${currentRate.toStringAsFixed(1)}% berhasil diperbarui.',
                      );
                    },
                    child: const Text('Simpan Perubahan Tarif Komisi'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Commission Summary Breakdown (Responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 750;

                final totalCard = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AdminTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Akumulasi Komisi Diterima', style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(currency.format(a?.totalPlatformCommission ?? 0), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AdminTheme.primaryDark)),
                      const SizedBox(height: 4),
                      const Text('100% dialokasikan untuk operasional, server, dan asuransi proteksi anabul.', style: TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                    ],
                  ),
                );

                final avgCard = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AdminTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rata-rata Komisi per Transaksi', style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(currency.format(14300), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AdminTheme.success)),
                      const SizedBox(height: 4),
                      const Text('Dihitung dari 342 transaksi pesanan layanan anabul.', style: TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                    ],
                  ),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      totalCard,
                      const SizedBox(height: 16),
                      avgCard,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: totalCard),
                    const SizedBox(width: 16),
                    Expanded(child: avgCard),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

