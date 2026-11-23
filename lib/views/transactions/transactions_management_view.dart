import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../widgets/app_notification.dart';

class TransactionsManagementView extends StatelessWidget {
  const TransactionsManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Obx(() {
      final txList = controller.transactions;

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
                      'Monitoring Transaksi Platform 💳',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Semua transaksi booking grooming, dog walking, telemedicine & penitipan hewan.',
                      style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                    ),
                  ],
                );

                final exportBtn = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.brandDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    AppNotification.showSuccess(
                      title: 'Ekspor Laporan',
                      message: 'Laporan transaksi CSV/Excel berhasil di-generate.',
                    );
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Export CSV/Excel'),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleCol,
                      const SizedBox(height: 12),
                      exportBtn,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleCol),
                    const SizedBox(width: 16),
                    exportBtn,
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Transactions Table (Responsive Horizontal Scroll)
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
                        DataColumn(label: Text('Kode Booking', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Layanan & Pelanggan', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Mitra Penyedia', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Total Gross', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Fee PawPaw', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Net Mitra', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Status Order', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Waktu', style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                      rows: txList.map((tx) {
                        final isCompleted = tx.status == 'completed';
                        final isPaid = tx.status == 'paid';

                        return DataRow(
                          cells: [
                            DataCell(Text(tx.code, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AdminTheme.info))),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(tx.serviceName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('Pelanggan: ${tx.customerName}', style: TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                                ],
                              ),
                            ),
                            DataCell(Text(tx.partnerName, style: const TextStyle(fontSize: 13))),
                            DataCell(Text(currency.format(tx.grossAmount), style: const TextStyle(fontWeight: FontWeight.w700))),
                            DataCell(Text(currency.format(tx.platformFee), style: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.primaryDark))),
                            DataCell(Text(currency.format(tx.partnerNet), style: const TextStyle(fontWeight: FontWeight.w600, color: AdminTheme.success))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AdminTheme.successLight
                                      : (isPaid ? AdminTheme.infoLight : AdminTheme.warningLight),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tx.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isCompleted
                                        ? AdminTheme.success
                                        : (isPaid ? AdminTheme.info : AdminTheme.warning),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(dateFormat.format(tx.createdAt), style: TextStyle(fontSize: 11.5, color: AdminTheme.textSecondary))),
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
