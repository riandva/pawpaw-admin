import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/admin_theme.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'widgets/app_notification.dart';
import 'landing/admin_landing_screen.dart';
import 'analytics/analytics_view.dart';
import 'commissions/commissions_view.dart';
import 'customer_care/customer_care_view.dart';
import 'partners/partners_management_view.dart';
import 'payouts/payouts_management_view.dart';
import 'transactions/transactions_management_view.dart';
import 'users/users_management_view.dart';
import 'adopt_packages/adopt_packages_view.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: AdminTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTabletOrMobile = constraints.maxWidth < 800;

          return Row(
            children: [
              // Sidebar Navigation
              _buildSidebar(context, controller, isCollapsed: isTabletOrMobile),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    _buildTopHeader(context, controller),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value && controller.users.isEmpty) {
                          return const Center(child: CircularProgressIndicator(color: AdminTheme.primary));
                        }

                        switch (controller.currentTab.value) {
                          case AdminMenuTab.analytics:
                            return const AnalyticsView();
                          case AdminMenuTab.users:
                            return const UsersManagementView();
                          case AdminMenuTab.partners:
                            return const PartnersManagementView();
                          case AdminMenuTab.transactions:
                            return const TransactionsManagementView();
                          case AdminMenuTab.commissions:
                            return const CommissionsView();
                          case AdminMenuTab.payouts:
                            return const PayoutsManagementView();
                          case AdminMenuTab.adoptPackages:
                            return const AdoptPackagesView();
                          case AdminMenuTab.customerCareUser:
                            return const CustomerCareView(initialCategory: 'customer-care');
                          case AdminMenuTab.customerCarePartner:
                            return const CustomerCareView(initialCategory: 'partner-support');
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AdminDashboardController controller, {required bool isCollapsed}) {
    final width = isCollapsed ? 76.0 : 260.0;

    return Container(
      width: width,
      color: AdminTheme.sidebarBg,
      child: Column(
        children: [
          // Brand Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AdminTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🐾', style: TextStyle(fontSize: 22)),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PawPaw Console',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Admin & Operations',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          const SizedBox(height: 12),

          // Menu Items
          Expanded(
            child: Obx(() {
              final current = controller.currentTab.value;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  _buildMenuItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Analisa & Overview',
                    isSelected: current == AdminMenuTab.analytics,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.analytics),
                  ),
                  _buildMenuItem(
                    icon: Icons.people_outline_rounded,
                    activeIcon: Icons.people_rounded,
                    label: 'Kelola Pengguna',
                    isSelected: current == AdminMenuTab.users,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.users),
                  ),
                  _buildMenuItem(
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront_rounded,
                    label: 'Kelola Mitra',
                    isSelected: current == AdminMenuTab.partners,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.partners),
                  ),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Transaksi Platform',
                    isSelected: current == AdminMenuTab.transactions,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.transactions),
                  ),
                  _buildMenuItem(
                    icon: Icons.percent_rounded,
                    activeIcon: Icons.percent_rounded,
                    label: 'Bagi Hasil & Komisi',
                    isSelected: current == AdminMenuTab.commissions,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.commissions),
                  ),
                  _buildMenuItem(
                    icon: Icons.account_balance_outlined,
                    activeIcon: Icons.account_balance_rounded,
                    label: 'Pencairan Dana (Payout)',
                    isSelected: current == AdminMenuTab.payouts,
                    isCollapsed: isCollapsed,
                    badgeCount: controller.payouts.where((p) => p.status == 'pending').length,
                    onTap: () => controller.switchTab(AdminMenuTab.payouts),
                  ),
                  _buildMenuItem(
                    icon: Icons.pets_outlined,
                    activeIcon: Icons.pets_rounded,
                    label: 'Paket Posting Adopsi',
                    isSelected: current == AdminMenuTab.adoptPackages,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.adoptPackages),
                  ),
                  _buildMenuItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    activeIcon: Icons.chat_bubble_rounded,
                    label: 'Live Chat Pelanggan',
                    isSelected: current == AdminMenuTab.customerCareUser,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.customerCareUser),
                  ),
                  _buildMenuItem(
                    icon: Icons.support_agent_outlined,
                    activeIcon: Icons.support_agent_rounded,
                    label: 'Live Chat Mitra',
                    isSelected: current == AdminMenuTab.customerCarePartner,
                    isCollapsed: isCollapsed,
                    onTap: () => controller.switchTab(AdminMenuTab.customerCarePartner),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF334155), height: 1),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    activeIcon: Icons.logout_rounded,
                    label: 'Keluar (Logout)',
                    isSelected: false,
                    isCollapsed: isCollapsed,
                    onTap: () => _showLogoutConfirmDialog(context, controller),
                  ),
                ],
              );
            }),
          ),

          // Bottom Admin Card
          Container(
            padding: const EdgeInsets.all(14),
            color: const Color(0xFF0F172A),
            child: Row(
              mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Obx(() {
                  final admin = controller.currentAdmin.value;
                  final initial = admin != null && admin.name.isNotEmpty
                      ? admin.name[0].toUpperCase()
                      : 'SA';
                  return CircleAvatar(
                    radius: 17,
                    backgroundColor: AdminTheme.primary,
                    child: Text(
                      initial,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AdminTheme.brandDark),
                    ),
                  );
                }),
                if (!isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(() {
                      final admin = controller.currentAdmin.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin?.name ?? 'Super Admin',
                            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            admin?.email ?? 'admin@pawpaw.id',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
                    tooltip: 'Keluar Akun',
                    onPressed: () => _showLogoutConfirmDialog(context, controller),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required bool isCollapsed,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AdminTheme.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AdminTheme.primary : const Color(0xFF94A3B8),
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (badgeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AdminTheme.warning, borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, AdminDashboardController controller) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AdminTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AdminTheme.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 4, backgroundColor: AdminTheme.success),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'System Online • Production Ready',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AdminTheme.success),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AdminTheme.textSecondary),
                onPressed: () {
                  AppNotification.showInfo(
                    title: 'Notifikasi',
                    message: 'Tidak ada peringatan darurat saat ini.',
                  );
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AdminTheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminTheme.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 16, color: AdminTheme.primary),
                    SizedBox(width: 6),
                    Text('Superadmin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: AdminTheme.danger, size: 20),
                tooltip: 'Keluar dari Console',
                onPressed: () => _showLogoutConfirmDialog(context, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, AdminDashboardController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AdminTheme.danger, size: 22),
            SizedBox(width: 10),
            Text(
              'Keluar Akun Admin',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AdminTheme.textPrimary),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari PawPaw Console? Anda harus masuk kembali untuk mengelola transaksi dan data platform.',
          style: TextStyle(fontSize: 13.5, color: AdminTheme.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AdminTheme.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AdminTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.logout();
              Get.offAll(() => const AdminLandingScreen());
            },
            child: const Text('Ya, Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
