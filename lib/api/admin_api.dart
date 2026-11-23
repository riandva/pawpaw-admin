import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/admin_models.dart';
import 'api_client.dart';

class AdminApi {
  final ApiClient _client = ApiClient();

  Future<AdminUser?> login(String email, String password) async {
    try {
      final res = await _client.post('admin/login', data: {
        'email': email,
        'password': password,
      });

      if (res.statusCode == 200 && res.data['data'] != null) {
        final data = res.data['data'];
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);

        final admin = AdminUser.fromJson(data);
        await prefs.setString(AppConstants.adminUserKey, jsonEncode(admin.toJson()));
        return admin;
      }
    } catch (e) {
      debugPrint('[AdminApi] Login error: $e');
    }

    return null;
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final res = await _client.get('admin/users');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getUsers error: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getUserDetail(String userId) async {
    try {
      final res = await _client.get('admin/user/$userId/detail');
      if (res.statusCode == 200 && res.data['data'] != null) {
        return res.data['data'] as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[AdminApi] getUserDetail error: $e');
    }
    return null;
  }

  Future<bool> toggleBlockUser(String userId, {required bool isBlocked, String? reason}) async {
    try {
      final res = await _client.patch('admin/user/$userId/block', data: {
        'isBlocked': isBlocked,
        if (reason != null && reason.isNotEmpty) 'blockReason': reason,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] toggleBlockUser error: $e');
      return false;
    }
  }

  Future<List<UserPetModel>> getUserPets(String userId) async {
    try {
      final res = await _client.get('admin/user/$userId/pets');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list.map((item) => UserPetModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getUserPets error: $e');
    }
    return [];
  }

  Future<List<UserPostModel>> getUserPosts(String userId) async {
    try {
      final res = await _client.get('admin/user/$userId/posts');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list.map((item) => UserPostModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getUserPosts error: $e');
    }
    return [];
  }

  Future<List<PartnerModel>> getPartners() async {
    try {
      final res = await _client.get('admin/partners');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list.map((item) => PartnerModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getPartners error: $e');
    }
    return [];
  }

  Future<bool> verifyPartner(String partnerId, bool isVerified, {String? roleKey}) async {
    try {
      final res = await _client.patch('admin/partners/$partnerId/verify', data: {
        'isVerified': isVerified,
        'roleKey': ?roleKey,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] verifyPartner error: $e');
      return false;
    }
  }

  Future<List<TransactionModel>> getTransactions() async {
    try {
      final res = await _client.get('admin/transactions');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list.map((item) => TransactionModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getTransactions error: $e');
    }
    return [];
  }

  Future<List<PayoutModel>> getPayouts() async {
    try {
      final res = await _client.get('admin/payouts');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list.map((item) => PayoutModel.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getPayouts error: $e');
    }
    return [];
  }

  Future<bool> updatePayoutStatus(String payoutId, String status) async {
    try {
      final res = await _client.patch('admin/payouts/$payoutId/status', data: {
        'status': status,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] updatePayoutStatus error: $e');
      return false;
    }
  }

  Future<RevenueAnalytics> getRevenueAnalytics() async {
    try {
      final res = await _client.get('admin/dashboard/summary');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final data = res.data['data'] as Map<String, dynamic>;
        final gross = (data['totalGrossVolume'] is num)
            ? (data['totalGrossVolume'] as num).toDouble()
            : 0.0;
        final commission = (data['totalPlatformRevenue'] is num)
            ? (data['totalPlatformRevenue'] as num).toDouble()
            : 0.0;
        final payouts = (data['totalPartnerPayouts'] is num)
            ? (data['totalPartnerPayouts'] as num).toDouble()
            : 0.0;

        return RevenueAnalytics(
          totalGrossGMV: gross,
          totalPlatformCommission: commission,
          totalPartnerPayouts: payouts,
          netPlatformProfit: commission,
          totalTransactionsCount: (data['totalBookings'] is num)
              ? (data['totalBookings'] as num).toInt()
              : 0,
          activePartnersCount: (data['activePartners'] is num)
              ? (data['activePartners'] as num).toInt()
              : 0,
          registeredUsersCount: (data['totalUsers'] is num)
              ? (data['totalUsers'] as num).toInt()
              : 0,
        );
      }
    } catch (e) {
      debugPrint('[AdminApi] getRevenueAnalytics error: $e');
    }

    return RevenueAnalytics(
      totalGrossGMV: 0.0,
      totalPlatformCommission: 0.0,
      totalPartnerPayouts: 0.0,
      netPlatformProfit: 0.0,
      totalTransactionsCount: 0,
      activePartnersCount: 0,
      registeredUsersCount: 0,
    );
  }

  // Real-time Support Chat (User & Partner)
  Future<List<CustomerCareRoomModel>> getCustomerCareRooms({String category = 'all'}) async {
    try {
      final res = await _client.get('admin/customer-care/list', queryParameters: {
        'category': category,
      });
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list
            .map((item) => CustomerCareRoomModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getCustomerCareRooms error: $e');
    }
    return [];
  }

  Future<List<CustomerCareMessageModel>> getCustomerCareMessages(String roomId) async {
    try {
      final res = await _client.get('admin/customer-care/room/$roomId');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list
            .map((item) => CustomerCareMessageModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getCustomerCareMessages error: $e');
    }
    return [];
  }

  Future<CustomerCareMessageModel?> sendCustomerCareMessage(String roomId, String text) async {
    try {
      final res = await _client.post('admin/customer-care/room/$roomId', data: {
        'type': 'text',
        'content': text,
      });
      if (res.statusCode == 200 && res.data['data'] != null) {
        return CustomerCareMessageModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[AdminApi] sendCustomerCareMessage error: $e');
    }
    return null;
  }

  Future<bool> registerFcmToken(String fcmToken) async {
    try {
      final res = await _client.post('admin/token', data: {
        'token': fcmToken,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] registerFcmToken error: $e');
      return false;
    }
  }

  Future<bool> unregisterFcmToken(String fcmToken) async {
    try {
      final res = await _client.delete('admin/token', data: {
        'token': fcmToken,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] unregisterFcmToken error: $e');
      return false;
    }
  }

  // ==================== ADOPT PACKAGES ====================
  Future<List<AdoptPackageModel>> getAdoptPackages() async {
    try {
      final res = await _client.get('admin/adopt-package');
      if (res.statusCode == 200 && res.data['data'] != null) {
        final list = res.data['data'] as List<dynamic>;
        return list.map((e) => AdoptPackageModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('[AdminApi] getAdoptPackages error: $e');
    }
    return [];
  }

  Future<bool> createAdoptPackage({
    required String name,
    required String description,
    required String type,
    required int days,
    required int activeDays,
    required double price,
    bool isActive = true,
  }) async {
    try {
      final res = await _client.post('admin/adopt-package', data: {
        'name': name,
        'description': description,
        'type': type,
        'days': days,
        'activeDays': activeDays,
        'price': price,
        'isActive': isActive,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] createAdoptPackage error: $e');
      return false;
    }
  }

  Future<bool> updateAdoptPackage(
    String id, {
    String? name,
    String? description,
    String? type,
    int? days,
    int? activeDays,
    double? price,
    bool? isActive,
  }) async {
    try {
      final res = await _client.patch('admin/adopt-package/$id', data: {
        'name': ?name,
        'description': ?description,
        'type': ?type,
        'days': ?days,
        'activeDays': ?activeDays,
        'price': ?price,
        'isActive': ?isActive,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] updateAdoptPackage error: $e');
      return false;
    }
  }

  Future<bool> deleteAdoptPackage(String id) async {
    try {
      final res = await _client.delete('admin/adopt-package/$id');
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('[AdminApi] deleteAdoptPackage error: $e');
      return false;
    }
  }
}
