class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'superadmin' | 'finance' | 'support'

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'superadmin',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicture;
  final double wallet;
  final double pointDonation;
  final bool isSubscribe;
  final bool isBlocked;
  final String? blockReason;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicture,
    required this.wallet,
    this.pointDonation = 0.0,
    required this.isSubscribe,
    this.isBlocked = false,
    this.blockReason,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Pelanggan PawPaw',
      email: json['email'] ?? '-',
      phone: json['phone'] ?? json['phoneNumber'] ?? '-',
      profilePicture: json['profilePicture']?.toString(),
      wallet: (json['wallet'] is num) ? (json['wallet'] as num).toDouble() : 0.0,
      pointDonation: (json['pointDonation'] is num) ? (json['pointDonation'] as num).toDouble() : 0.0,
      isSubscribe: json['isSubscribe'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      blockReason: json['blockReason'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class UserPetModel {
  final String id;
  final String name;
  final String? breed;
  final String? typeName;
  final String? genderName;
  final String? imageUrl;
  final double? weight;
  final int? ageMonth;
  final bool isStambum;
  final DateTime? dateOfBirth;

  UserPetModel({
    required this.id,
    required this.name,
    this.breed,
    this.typeName,
    this.genderName,
    this.imageUrl,
    this.weight,
    this.ageMonth,
    this.isStambum = false,
    this.dateOfBirth,
  });

  factory UserPetModel.fromJson(Map<String, dynamic> json) {
    final petType = json['petType'];
    final typeName = (petType is Map) ? petType['name'] : null;

    final gender = json['gender'];
    final genderName = (gender is Map) ? gender['name'] : null;

    final image = json['image'];
    final imageUrl = (image is Map) ? image['url'] : null;

    return UserPetModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Anabul',
      breed: json['petRace'],
      typeName: typeName,
      genderName: genderName,
      imageUrl: imageUrl,
      weight: (json['weight'] is num) ? (json['weight'] as num).toDouble() : null,
      ageMonth: json['age'] is int ? json['age'] : null,
      isStambum: json['isStambum'] ?? false,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.tryParse(json['dateOfBirth'].toString()) : null,
    );
  }
}

class UserPostModel {
  final String id;
  final String category; // 'adopt', 'marketplace', 'lost_found'
  final String categoryLabel;
  final String title;
  final String? desc;
  final double price;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;

  UserPostModel({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.title,
    this.desc,
    required this.price,
    required this.status,
    this.imageUrl,
    required this.createdAt,
  });

  factory UserPostModel.fromJson(Map<String, dynamic> json) {
    return UserPostModel(
      id: json['id'] ?? json['_id'] ?? '',
      category: json['category'] ?? 'adopt',
      categoryLabel: json['categoryLabel'] ?? 'Postingan',
      title: json['title'] ?? 'Judul Postingan',
      desc: json['desc'],
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'active',
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PartnerModel {
  final String id;
  final String userId;
  final String businessName;
  final String ownerName;
  final String phone;
  final String city;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final bool isOnline;
  final double walletBalance;
  final List<String> availableRoles;
  final String activeRole;
  final Map<String, bool> verifiedRoles;

  PartnerModel({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.city,
    required this.rating,
    required this.totalReviews,
    required this.isVerified,
    required this.isOnline,
    required this.walletBalance,
    required this.availableRoles,
    required this.activeRole,
    this.verifiedRoles = const {},
  });

  bool isRoleVerified(String roleKey) => verifiedRoles[roleKey] ?? false;

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    final rawVerifiedRoles = json['verifiedRoles'];
    final Map<String, bool> parsedVerifiedRoles = {};
    if (rawVerifiedRoles is Map) {
      rawVerifiedRoles.forEach((key, value) {
        parsedVerifiedRoles[key.toString()] = value == true;
      });
    }
    return PartnerModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      businessName: json['businessName'] ?? 'Mitra PawPaw',
      ownerName: json['ownerName'] ?? json['user']?['name'] ?? 'Mitra',
      phone: json['phone'] ?? json['user']?['phone'] ?? json['user']?['phoneNumber'] ?? '-',
      city: json['city'] ?? 'Denpasar',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 5.0,
      totalReviews: json['totalReviews'] ?? 0,
      isVerified: json['isVerified'] ?? true,
      isOnline: json['isOnline'] ?? true,
      walletBalance: (json['walletBalance'] is num) ? (json['walletBalance'] as num).toDouble() : 0.0,
      availableRoles: (json['availableRoles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['groomer', 'dogwalker'],
      activeRole: json['activeRole'] ?? 'groomer',
      verifiedRoles: parsedVerifiedRoles,
    );
  }
}

class TransactionModel {
  final String id;
  final String code;
  final String customerName;
  final String partnerName;
  final String serviceName;
  final double grossAmount;
  final double platformFee; // Komisi PawPaw (e.g. 10%)
  final double partnerNet;
  final String status; // 'pending' | 'paid' | 'completed' | 'cancelled'
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.code,
    required this.customerName,
    required this.partnerName,
    required this.serviceName,
    required this.grossAmount,
    required this.platformFee,
    required this.partnerNet,
    required this.status,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final gross = (json['grossAmount'] is num)
        ? (json['grossAmount'] as num).toDouble()
        : ((json['price'] is num) ? (json['price'] as num).toDouble() : 0.0);
    final fee = (json['platformFee'] is num)
        ? (json['platformFee'] as num).toDouble()
        : gross * 0.10;
    final net = (json['partnerNet'] is num)
        ? (json['partnerNet'] as num).toDouble()
        : gross - fee;

    return TransactionModel(
      id: json['id'] ?? json['_id'] ?? '',
      code: json['code'] ?? json['bookingNumber'] ?? 'PP-${(json['id'] ?? '').toString().substring(0, 6)}',
      customerName: json['customerName'] ?? json['customer']?['name'] ?? 'Pelanggan',
      partnerName: json['partnerName'] ?? json['partner']?['name'] ?? 'Mitra PawPaw',
      serviceName: json['serviceName'] ?? json['packageName'] ?? 'Layanan PawPaw',
      grossAmount: gross,
      platformFee: fee,
      partnerNet: net,
      status: json['status'] ?? 'completed',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class PayoutModel {
  final String id;
  final String partnerName;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final double amount;
  final String status; // 'pending' | 'approved' | 'rejected'
  final DateTime requestedAt;

  PayoutModel({
    required this.id,
    required this.partnerName,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    required this.amount,
    required this.status,
    required this.requestedAt,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      id: json['id'] ?? json['_id'] ?? '',
      partnerName: json['partnerName'] ?? json['partner']?['name'] ?? 'Mitra PawPaw',
      bankName: json['bankName'] ?? 'BCA',
      accountNumber: json['accountNumber'] ?? json['bankAccountNumber'] ?? '-',
      accountHolder: json['accountHolder'] ?? json['accountHolderName'] ?? json['bankAccountName'] ?? 'Mitra',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      status: json['status'] ?? 'pending',
      requestedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class RevenueAnalytics {
  final double totalGrossGMV;
  final double totalPlatformCommission;
  final double totalPartnerPayouts;
  final double netPlatformProfit;
  final int totalTransactionsCount;
  final int activePartnersCount;
  final int registeredUsersCount;

  RevenueAnalytics({
    required this.totalGrossGMV,
    required this.totalPlatformCommission,
    required this.totalPartnerPayouts,
    required this.netPlatformProfit,
    required this.totalTransactionsCount,
    required this.activePartnersCount,
    required this.registeredUsersCount,
  });
}

class CustomerCareRoomModel {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String category; // 'customer-care' | 'partner-support'
  final String? lastMessage;
  final String? lastMessageType;
  final DateTime lastUpdated;
  final int unreadCount;

  CustomerCareRoomModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.category = 'customer-care',
    this.lastMessage,
    this.lastMessageType,
    required this.lastUpdated,
    required this.unreadCount,
  });

  bool get isPartner => category == 'partner-support';

  factory CustomerCareRoomModel.fromJson(Map<String, dynamic> json) {
    final from = json['from'] as Map<String, dynamic>?;
    final lastMsg = json['lastMessage'] as Map<String, dynamic>?;
    final cat = json['category']?.toString() ?? 'customer-care';

    return CustomerCareRoomModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['fromId'] ?? from?['_id'] ?? '',
      userName: from?['name'] ?? (cat == 'partner-support' ? 'Mitra PawPaw' : 'Pengguna PawPaw'),
      userAvatar: from?['profilePicture'],
      category: cat,
      lastMessage: lastMsg?['content']?.toString() ?? '',
      lastMessageType: lastMsg?['type']?.toString() ?? 'text',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
      unreadCount: (json['fromRead'] is num) ? (json['fromRead'] as num).toInt() : 0,
    );
  }
}

class CustomerCareMessageModel {
  final String id;
  final String chatId;
  final bool isAdmin;
  final String type; // 'text' | 'image' | 'location'
  final String content;
  final DateTime date;

  CustomerCareMessageModel({
    required this.id,
    required this.chatId,
    required this.isAdmin,
    required this.type,
    required this.content,
    required this.date,
  });

  factory CustomerCareMessageModel.fromJson(Map<String, dynamic> json) {
    return CustomerCareMessageModel(
      id: json['id'] ?? json['_id'] ?? '',
      chatId: json['chatId'] ?? '',
      isAdmin: json['isAdmin'] == true,
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now()),
    );
  }
}

class AdoptPackageModel {
  final String id;
  final String name;
  final String description;
  final String type; // 'free' | 'paid'
  final int days;
  final int activeDays;
  final double price;
  final bool isActive;

  AdoptPackageModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.days,
    required this.activeDays,
    required this.price,
    this.isActive = true,
  });

  bool get isFree => price <= 0 || type == 'free';

  factory AdoptPackageModel.fromJson(Map<String, dynamic> json) {
    final priceVal = (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0;
    return AdoptPackageModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'Paket Adopsi',
      description: json['description'] ?? '',
      type: json['type'] ?? (priceVal > 0 ? 'paid' : 'free'),
      days: (json['days'] is num) ? (json['days'] as num).toInt() : 0,
      activeDays: (json['activeDays'] is num) ? (json['activeDays'] as num).toInt() : 30,
      price: priceVal,
      isActive: json['isActive'] ?? true,
    );
  }
}

