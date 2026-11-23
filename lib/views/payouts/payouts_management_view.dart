import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';

class PayoutsManagementView extends StatelessWidget {
  const PayoutsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Obx(() {
      final payoutList = controller.payouts;

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
                      'Pencairan Saldo Mitra (Payouts & Withdrawals) 🏦',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tinjau, setujui, atau tolak permintaan transfer dana hasil order dari dompet mitra ke rekening bank.',
                      style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                    ),
                  ],
                );

                final badge = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminTheme.warningLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminTheme.warning.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${payoutList.where((p) => p.status == 'pending').length} Menunggu Persetujuan',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.warning, fontSize: 13),
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

            // Payouts Table (Responsive Horizontal Scroll)
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
                        DataColumn(label: Text('Nama Mitra', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Rekening Tujuan Bank', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Nominal Penarikan', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Tanggal Pengajuan', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Aksi Persetujuan', style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                      rows: payoutList.map((po) {
                        final isPending = po.status == 'pending';
                        final isApproved = po.status == 'approved';

                        return DataRow(
                          cells: [
                            DataCell(Text(po.partnerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${po.bankName} - ${po.accountNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('a.n ${po.accountHolder}', style: TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                                ],
                              ),
                            ),
                            DataCell(Text(currency.format(po.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AdminTheme.brandDark))),
                            DataCell(Text(dateFormat.format(po.requestedAt), style: TextStyle(fontSize: 12, color: AdminTheme.textSecondary))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isApproved
                                      ? AdminTheme.successLight
                                      : (isPending ? AdminTheme.warningLight : AdminTheme.dangerLight),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  po.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isApproved
                                        ? AdminTheme.success
                                        : (isPending ? AdminTheme.warning : AdminTheme.danger),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              isPending
                                  ? Row(
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AdminTheme.success,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => controller.approvePayout(po.id),
                                          child: const Text('Setujui', style: TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 8),
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AdminTheme.danger,
                                            side: const BorderSide(color: AdminTheme.danger),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => controller.rejectPayout(po.id),
                                          child: const Text('Tolak', style: TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      isApproved ? 'Telah Ditransfer' : 'Ditolak',
                                      style: TextStyle(fontSize: 12, color: AdminTheme.textMuted, fontStyle: FontStyle.italic),
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
