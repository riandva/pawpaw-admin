import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../widgets/app_notification.dart';

class PartnersManagementView extends StatelessWidget {
  const PartnersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Obx(() {
      final partnerList = controller.partners;

      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Responsive)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                final titleCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manajemen Mitra Penyedia Layanan 🐾',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kelola verifikasi bisnis, status operasional, role aktif, dan saldo dompet mitra.',
                      style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                    ),
                  ],
                );

                final badge = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${partnerList.length} Mitra Terdaftar',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.primaryDark, fontSize: 13),
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
            const SizedBox(height: 20),

            // Search & Filter Tabs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AdminTheme.cardDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari bisnis mitra, kota, atau nama pemilik...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AdminTheme.textMuted),
                        filled: true,
                        fillColor: AdminTheme.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => controller.partnerSearchQuery.value = val,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Partner Table (Responsive Horizontal Scroll)
            Expanded(
              child: Container(
                decoration: AdminTheme.cardDecoration(),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AdminTheme.background),
                      columns: const [
                        DataColumn(label: Text('Nama Bisnis & Pemilik', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Role Layanan', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Kota / Lokasi', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Rating / Ulasan', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Saldo Dompet', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Verifikasi Resmi', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                      rows: partnerList.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(p.businessName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                  Text('${p.ownerName} • ${p.phone}', style: TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                                ],
                              ),
                            ),
                            DataCell(
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: p.availableRoles.map((role) {
                                  final approved = p.isRoleVerified(role);
                                  return Tooltip(
                                    message: approved
                                        ? 'Role $role disetujui (klik untuk cabut)'
                                        : 'Role $role belum disetujui (klik untuk setujui)',
                                    child: InkWell(
                                      onTap: () => controller.togglePartnerVerification(p.id, roleKey: role),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: approved ? AdminTheme.successLight : AdminTheme.warningLight,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: (approved ? AdminTheme.success : AdminTheme.warning).withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              approved ? Icons.check_circle_rounded : Icons.pending_rounded,
                                              size: 11,
                                              color: approved ? AdminTheme.success : AdminTheme.warning,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              role,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: approved ? AdminTheme.success : AdminTheme.warning,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            DataCell(Text(p.city, style: const TextStyle(fontSize: 13))),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: AdminTheme.warning, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${p.rating} (${p.totalReviews})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                            ),
                            DataCell(Text(currency.format(p.walletBalance), style: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.primaryDark))),
                            DataCell(
                              InkWell(
                                onTap: () => controller.togglePartnerVerification(p.id),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: p.isVerified ? AdminTheme.successLight : AdminTheme.warningLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(p.isVerified ? Icons.check_circle_rounded : Icons.pending_rounded, size: 14, color: p.isVerified ? AdminTheme.success : AdminTheme.warning),
                                      const SizedBox(width: 4),
                                      Text(
                                        p.isVerified ? 'Verified' : 'Belum Verif',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: p.isVerified ? AdminTheme.success : AdminTheme.warning,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'toggle') {
                                    controller.togglePartnerVerification(p.id);
                                  } else {
                                    AppNotification.showInfo(
                                      title: 'Katalog Layanan',
                                      message: 'Menampilkan daftar service dari ${p.businessName}',
                                    );
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(value: 'toggle', child: Text(p.isVerified ? 'Cabut Verifikasi' : 'Verifikasi Akun')),
                                  const PopupMenuItem(value: 'services', child: Text('Lihat Layanan & Varian')),
                                ],
                                icon: const Icon(Icons.more_horiz_rounded),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
