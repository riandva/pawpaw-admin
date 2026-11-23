import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../models/admin_models.dart';
import 'user_detail_modal.dart';

class UsersManagementView extends StatelessWidget {
  const UsersManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Obx(() {
      final userList = controller.users;

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
                      'Manajemen Pengguna (Customers) 👤',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Daftar akun pemilik hewan terdaftar, status keanggotaan, dan saldo dompet.',
                      style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                    ),
                  ],
                );

                final badge = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AdminTheme.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Total: ${userList.length} Pengguna',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AdminTheme.brandDark, fontSize: 13),
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

            // Search Bar & Filter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AdminTheme.cardDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari berdasarkan nama, email, atau nomor HP...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AdminTheme.textMuted),
                        filled: true,
                        fillColor: AdminTheme.background,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => controller.userSearchQuery.value = val,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Table (Responsive Horizontal Scroll)
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
                        DataColumn(label: Text('Nama Lengkap', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Kontak / Email', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Status Member', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Status Akun', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Saldo Dompet', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Tanggal Bergabung', style: TextStyle(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Aksi', style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                      rows: userList.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AdminTheme.primaryLight,
                                    backgroundImage: user.profilePicture != null && user.profilePicture!.startsWith('http')
                                        ? NetworkImage(user.profilePicture!)
                                        : null,
                                    child: user.profilePicture == null || !user.profilePicture!.startsWith('http')
                                        ? Text(
                                            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: AdminTheme.primaryDark),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(user.email, style: const TextStyle(fontSize: 13)),
                                  Text(user.phone, style: TextStyle(fontSize: 11, color: AdminTheme.textMuted)),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.isSubscribe ? AdminTheme.successLight : AdminTheme.divider,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.isSubscribe ? 'PawPass VIP' : 'Reguler',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: user.isSubscribe ? AdminTheme.success : AdminTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: user.isBlocked ? AdminTheme.errorLight : AdminTheme.successLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.isBlocked ? 'Diblokir' : 'Aktif',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: user.isBlocked ? AdminTheme.error : AdminTheme.success,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(currency.format(user.wallet), style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(dateFormat.format(user.createdAt), style: TextStyle(fontSize: 12, color: AdminTheme.textSecondary))),
                            DataCell(
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AdminTheme.textSecondary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                onSelected: (val) {
                                  if (val == 'detail') {
                                    UserDetailModal.show(context, user, controller);
                                  } else if (val == 'block') {
                                    _confirmBlockUser(context, user, controller);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'detail',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility_outlined, size: 18, color: AdminTheme.brandDark),
                                        SizedBox(width: 10),
                                        Text('Lihat Detail Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'block',
                                    child: Row(
                                      children: [
                                        Icon(
                                          user.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                                          size: 18,
                                          color: user.isBlocked ? AdminTheme.success : AdminTheme.error,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          user.isBlocked ? 'Buka Blokir Akun' : 'Blokir Pengguna',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: user.isBlocked ? AdminTheme.success : AdminTheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

  void _confirmBlockUser(BuildContext context, UserModel user, AdminDashboardController controller) {
    final reasonController = TextEditingController();
    final isBlocking = !user.isBlocked;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isBlocking ? Icons.block_rounded : Icons.check_circle_rounded,
              color: isBlocking ? AdminTheme.error : AdminTheme.success,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              isBlocking ? 'Blokir Pengguna' : 'Buka Blokir Pengguna',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBlocking
                  ? 'Apakah Anda yakin ingin memblokir akun ${user.name}? Pengguna ini tidak akan dapat login atau bertransaksi di aplikasi.'
                  : 'Aktifkan kembali akses akun untuk ${user.name}?',
              style: const TextStyle(fontSize: 14, color: AdminTheme.textSecondary),
            ),
            if (isBlocking) ...[
              const SizedBox(height: 16),
              const Text('Alasan Pemblokiran (Opsional):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Pelanggaran syarat & ketentuan...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal', style: TextStyle(color: AdminTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocking ? AdminTheme.error : AdminTheme.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await controller.toggleBlockUser(
                user.id,
                isBlocked: isBlocking,
                reason: reasonController.text.trim(),
              );
            },
            child: Text(isBlocking ? 'Ya, Blokir' : 'Buka Blokir'),
          ),
        ],
      ),
    );
  }
}
