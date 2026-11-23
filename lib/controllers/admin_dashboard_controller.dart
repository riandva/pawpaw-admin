import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/admin_api.dart';
import '../config/constants.dart';
import '../models/admin_models.dart';
import '../services/admin_notification_service.dart';
import '../views/widgets/app_notification.dart';

enum AdminMenuTab {
  analytics,
  users,
  partners,
  transactions,
  commissions,
  payouts,
  adoptPackages,
  customerCareUser,
  customerCarePartner,
}

class AdminDashboardController extends GetxController {
  final AdminApi _api = AdminApi();

  final Rxn<AdminUser> currentAdmin = Rxn<AdminUser>();
  final Rx<AdminMenuTab> currentTab = AdminMenuTab.analytics.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  // Data Observables
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<PartnerModel> partners = <PartnerModel>[].obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxList<PayoutModel> payouts = <PayoutModel>[].obs;
  final Rxn<RevenueAnalytics> analytics = Rxn<RevenueAnalytics>();

  // Filter & Search
  final RxString userSearchQuery = ''.obs;
  final RxString partnerSearchQuery = ''.obs;
  final RxString selectedRoleFilter = 'all'.obs;
  final RxDouble commissionRate = 10.0.obs; // Platform fee percentage

  @override
  void onInit() {
    super.onInit();
    initSession();
  }

  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.adminUserKey);
    final token = prefs.getString(AppConstants.tokenKey);
    if (userJson != null && token != null) {
      try {
        currentAdmin.value = AdminUser.fromJson(jsonDecode(userJson));
        isLoggedIn.value = true;
        await loadAllData();
        await AdminNotificationService().registerTokenToBackend();
      } catch (_) {
        isLoggedIn.value = false;
      }
    } else {
      isLoggedIn.value = false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    try {
      final admin = await _api.login(email, password);
      if (admin != null) {
        currentAdmin.value = admin;
        isLoggedIn.value = true;
        await loadAllData();
        await AdminNotificationService().registerTokenToBackend();
        AppNotification.showSuccess(
          title: 'Selamat Datang',
          message: 'Berhasil masuk sebagai ${admin.name}',
        );
        return true;
      } else {
        AppNotification.showError(
          title: 'Login Gagal',
          message: 'Email atau kata sandi administrator salah.',
        );
        return false;
      }
    } catch (e) {
      AppNotification.showError(
        title: 'Kesalahan Sistem',
        message: 'Gagal terhubung ke server backend: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _api.getUsers(),
        _api.getPartners(),
        _api.getTransactions(),
        _api.getPayouts(),
        _api.getRevenueAnalytics(),
      ]);

      users.value = results[0] as List<UserModel>;
      partners.value = results[1] as List<PartnerModel>;
      transactions.value = results[2] as List<TransactionModel>;
      payouts.value = results[3] as List<PayoutModel>;
      analytics.value = results[4] as RevenueAnalytics;
    } finally {
      isLoading.value = false;
    }
  }

  void switchTab(AdminMenuTab tab) {
    currentTab.value = tab;
  }

  Future<void> approvePayout(String payoutId) async {
    final success = await _api.updatePayoutStatus(payoutId, 'approved');
    if (success) {
      final index = payouts.indexWhere((p) => p.id == payoutId);
      if (index != -1) {
        final old = payouts[index];
        payouts[index] = PayoutModel(
          id: old.id,
          partnerName: old.partnerName,
          bankName: old.bankName,
          accountNumber: old.accountNumber,
          accountHolder: old.accountHolder,
          amount: old.amount,
          status: 'approved',
          requestedAt: old.requestedAt,
        );
        AppNotification.showSuccess(
          title: 'Payout Disetujui',
          message: 'Dana Rp ${old.amount} berhasil diproses ke rekening ${old.bankName}',
        );
      }
    }
  }

  Future<void> rejectPayout(String payoutId) async {
    final success = await _api.updatePayoutStatus(payoutId, 'rejected');
    if (success) {
      final index = payouts.indexWhere((p) => p.id == payoutId);
      if (index != -1) {
        final old = payouts[index];
        payouts[index] = PayoutModel(
          id: old.id,
          partnerName: old.partnerName,
          bankName: old.bankName,
          accountNumber: old.accountNumber,
          accountHolder: old.accountHolder,
          amount: old.amount,
          status: 'rejected',
          requestedAt: old.requestedAt,
        );
        AppNotification.showError(
          title: 'Payout Ditolak',
          message: 'Pengajuan penarikan dana mitra ditolak',
        );
      }
    }
  }

  Future<void> togglePartnerVerification(String partnerId, {String? roleKey}) async {
    final index = partners.indexWhere((p) => p.id == partnerId);
    if (index != -1) {
      final old = partners[index];
      final newStatus = roleKey != null ? !old.isRoleVerified(roleKey) : !old.isVerified;
      final success = await _api.verifyPartner(partnerId, newStatus, roleKey: roleKey);
      if (success) {
        final updatedVerifiedRoles = Map<String, bool>.from(old.verifiedRoles);
        if (roleKey != null) {
          updatedVerifiedRoles[roleKey] = newStatus;
        } else {
          for (final role in old.availableRoles) {
            updatedVerifiedRoles[role] = newStatus;
          }
        }
        final overallVerified = roleKey != null
            ? updatedVerifiedRoles.values.any((v) => v)
            : newStatus;

        partners[index] = PartnerModel(
          id: old.id,
          userId: old.userId,
          businessName: old.businessName,
          ownerName: old.ownerName,
          phone: old.phone,
          city: old.city,
          rating: old.rating,
          totalReviews: old.totalReviews,
          isVerified: overallVerified,
          isOnline: old.isOnline,
          walletBalance: old.walletBalance,
          availableRoles: old.availableRoles,
          activeRole: old.activeRole,
          verifiedRoles: updatedVerifiedRoles,
        );
        AppNotification.showSuccess(
          title: 'Status Verifikasi Diperbarui',
          message: roleKey != null
              ? 'Role $roleKey untuk ${old.businessName} ${newStatus ? "Disetujui" : "Dicabut"}'
              : 'Mitra ${old.businessName} ${newStatus ? "Telah Diverifikasi Resmi" : "Status Verifikasi Dicabut"}',
        );
      }
    }
  }

  Future<void> toggleBlockUser(String userId, {required bool isBlocked, String? reason}) async {
    final success = await _api.toggleBlockUser(userId, isBlocked: isBlocked, reason: reason);
    if (success) {
      final index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final old = users[index];
        users[index] = UserModel(
          id: old.id,
          name: old.name,
          email: old.email,
          phone: old.phone,
          profilePicture: old.profilePicture,
          wallet: old.wallet,
          pointDonation: old.pointDonation,
          isSubscribe: old.isSubscribe,
          isBlocked: isBlocked,
          blockReason: isBlocked ? reason : null,
          createdAt: old.createdAt,
        );
        users.refresh();
      }
      if (isBlocked) {
        AppNotification.showError(
          title: 'Pengguna Diblokir',
          message: 'Akses akun pengguna berhasil dinonaktifkan.',
        );
      } else {
        AppNotification.showSuccess(
          title: 'Blokir Dibuka',
          message: 'Akun pengguna telah diaktifkan kembali.',
        );
      }
    } else {
      AppNotification.showError(
        title: 'Gagal Memperbarui Status',
        message: 'Terjadi kendala saat memperbarui status pemblokiran pengguna.',
      );
    }
  }

  Future<void> logout() async {
    await AdminNotificationService().unregisterTokenFromBackend();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.adminUserKey);
    currentAdmin.value = null;
    isLoggedIn.value = false;
    AppNotification.showInfo(
      title: 'Sesi Berakhir',
      message: 'Anda telah berhasil keluar dari akun administrator.',
    );
  }
}

