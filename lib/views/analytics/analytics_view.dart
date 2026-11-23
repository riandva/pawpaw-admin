import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Obx(() {
      final a = controller.analytics.value;
      if (a == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Subtitle (Responsive Header)
            LayoutBuilder(
              builder: (context, headerConstraints) {
                final isNarrow = headerConstraints.maxWidth < 650;
                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Keuangan & Analisa Platform 📊',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Lacak perputaran GMV, total komisi PawPaw, dan pencairan dana mitra secara real-time.',
                      style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                    ),
                  ],
                );

                final actionBtn = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => controller.loadAllData(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Segarkan Data'),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      const SizedBox(height: 12),
                      actionBtn,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    actionBtn,
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Top Stat Cards (Responsive Grid)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int crossAxisCount;
                final double childAspectRatio;

                if (width < 600) {
                  crossAxisCount = 1;
                  childAspectRatio = 2.4;
                } else if (width < 1000) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.9;
                } else {
                  crossAxisCount = 4;
                  childAspectRatio = 1.8;
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildStatCard(
                      title: 'Total Gross GMV',
                      value: currency.format(a.totalGrossGMV),
                      subtitle: '+14.2% dari bulan lalu',
                      icon: Icons.payments_rounded,
                      color: AdminTheme.info,
                      bgColor: AdminTheme.infoLight,
                    ),
                    _buildStatCard(
                      title: 'Komisi Platform (10%)',
                      value: currency.format(a.totalPlatformCommission),
                      subtitle: 'Pendapatan Bersih PawPaw',
                      icon: Icons.account_balance_wallet_rounded,
                      color: AdminTheme.primaryDark,
                      bgColor: AdminTheme.primaryLight,
                    ),
                    _buildStatCard(
                      title: 'Pencairan Dana Mitra',
                      value: currency.format(a.totalPartnerPayouts),
                      subtitle: 'Total dana ditransfer ke mitra',
                      icon: Icons.arrow_outward_rounded,
                      color: AdminTheme.warning,
                      bgColor: AdminTheme.warningLight,
                    ),
                    _buildStatCard(
                      title: 'Laba Bersih Platform',
                      value: currency.format(a.netPlatformProfit),
                      subtitle: 'Earning after operational fee',
                      icon: Icons.trending_up_rounded,
                      color: AdminTheme.success,
                      bgColor: AdminTheme.successLight,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Platform Growth Metrics Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 800;

                final ecosystemCard = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AdminTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pertumbuhan Ekosistem',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AdminTheme.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRow('Pengguna Terdaftar', '${a.registeredUsersCount} User Aktif', Icons.people_outline, AdminTheme.info),
                      const Divider(height: 24),
                      _buildMetricRow('Mitra Penyedia Layanan', '${a.activePartnersCount} Mitra Bisnis', Icons.storefront_outlined, AdminTheme.primaryDark),
                      const Divider(height: 24),
                      _buildMetricRow('Total Booking Berhasil', '${a.totalTransactionsCount} Transaksi Selesai', Icons.task_alt_rounded, AdminTheme.success),
                    ],
                  ),
                );

                final serviceCard = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AdminTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Komposisi Layanan Populer',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AdminTheme.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildProgressRow('Pet Grooming', 0.45, '45% dari total pesanan', const Color(0xFFFAAD03)),
                      const SizedBox(height: 14),
                      _buildProgressRow('Dog Walking Club', 0.30, '30% dari total pesanan', const Color(0xFF0284C7)),
                      const SizedBox(height: 14),
                      _buildProgressRow('Telemedicine Dokter Hewan', 0.15, '15% dari total pesanan', const Color(0xFF2EA43E)),
                      const SizedBox(height: 14),
                      _buildProgressRow('Pet Hotel & Daycare', 0.10, '10% dari total pesanan', const Color(0xFF8B5CF6)),
                    ],
                  ),
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      ecosystemCard,
                      const SizedBox(height: 16),
                      serviceCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: ecosystemCard),
                    const SizedBox(width: 16),
                    Expanded(child: serviceCard),
                  ],
                );
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AdminTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AdminTheme.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary),
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AdminTheme.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AdminTheme.textSecondary, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildProgressRow(String label, double value, String desc, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AdminTheme.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              desc,
              style: const TextStyle(fontSize: 11, color: AdminTheme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: value,
          backgroundColor: AdminTheme.divider,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}

