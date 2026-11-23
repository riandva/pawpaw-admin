import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/admin_api.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../../models/admin_models.dart';

class UserDetailModal extends StatefulWidget {
  final UserModel user;
  final AdminDashboardController controller;

  const UserDetailModal({
    super.key,
    required this.user,
    required this.controller,
  });

  static void show(BuildContext context, UserModel user, AdminDashboardController controller) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => UserDetailModal(user: user, controller: controller),
    );
  }

  @override
  State<UserDetailModal> createState() => _UserDetailModalState();
}

class _UserDetailModalState extends State<UserDetailModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminApi _api = AdminApi();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  bool _isLoading = true;
  List<UserPetModel> _pets = [];
  List<UserPostModel> _posts = [];
  Map<String, dynamic>? _userDetailData;
  late bool _isBlocked;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isBlocked = widget.user.isBlocked;
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.getUserDetail(widget.user.id),
        _api.getUserPets(widget.user.id),
        _api.getUserPosts(widget.user.id),
      ]);

      if (mounted) {
        setState(() {
          _userDetailData = results[0] as Map<String, dynamic>?;
          _pets = results[1] as List<UserPetModel>;
          _posts = results[2] as List<UserPostModel>;
          if (_userDetailData != null && _userDetailData!['isBlocked'] != null) {
            _isBlocked = _userDetailData!['isBlocked'] == true;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmBlockToggle() {
    final reasonController = TextEditingController();
    final isBlocking = !_isBlocked;

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
                  ? 'Apakah Anda yakin ingin memblokir akun ${widget.user.name}? Pengguna ini tidak akan dapat login atau bertransaksi di aplikasi.'
                  : 'Aktifkan kembali akses akun untuk ${widget.user.name}?',
              style: const TextStyle(fontSize: 14, color: AdminTheme.textSecondary),
            ),
            if (isBlocking) ...[
              const SizedBox(height: 16),
              const Text('Alasan Pemblokiran (Opsional):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Melanggar ketentuan komunitas...',
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
              await widget.controller.toggleBlockUser(
                widget.user.id,
                isBlocked: isBlocking,
                reason: reasonController.text.trim(),
              );
              setState(() {
                _isBlocked = isBlocking;
              });
            },
            child: Text(isBlocking ? 'Ya, Blokir' : 'Buka Blokir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 800 ? 760.0 : screenWidth * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: dialogWidth,
        height: 680,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header Bar
            _buildHeader(context),

            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AdminTheme.divider)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AdminTheme.brandDark,
                labelColor: AdminTheme.brandDark,
                unselectedLabelColor: AdminTheme.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  const Tab(
                    icon: Icon(Icons.person_outline_rounded, size: 18),
                    text: 'Profil & Info',
                  ),
                  Tab(
                    icon: const Icon(Icons.pets_rounded, size: 18),
                    text: 'Daftar Hewan (${_pets.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.article_outlined, size: 18),
                    text: 'Riwayat Postingan (${_posts.length})',
                  ),
                ],
              ),
            ),

            // Tab View Body
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileTab(),
                        _buildPetsTab(),
                        _buildPostsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AdminTheme.background,
        border: Border(bottom: BorderSide(color: AdminTheme.divider)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AdminTheme.primaryLight,
            backgroundImage: widget.user.profilePicture != null && widget.user.profilePicture!.startsWith('http')
                ? NetworkImage(widget.user.profilePicture!)
                : null,
            child: widget.user.profilePicture == null || !widget.user.profilePicture!.startsWith('http')
                ? Text(
                    widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AdminTheme.brandDark),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.user.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isBlocked ? AdminTheme.errorLight : AdminTheme.successLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isBlocked ? 'DIBLOKIR' : 'AKTIF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _isBlocked ? AdminTheme.error : AdminTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.user.email} • ID: ${widget.user.id.substring(0, 8)}...',
                  style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                ),
              ],
            ),
          ),
          // Action Buttons
          OutlinedButton.icon(
            onPressed: _confirmBlockToggle,
            style: OutlinedButton.styleFrom(
              foregroundColor: _isBlocked ? AdminTheme.success : AdminTheme.error,
              side: BorderSide(color: _isBlocked ? AdminTheme.success : AdminTheme.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            icon: Icon(_isBlocked ? Icons.lock_open_rounded : Icons.block_rounded, size: 16),
            label: Text(_isBlocked ? 'Buka Blokir' : 'Blokir Akun', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AdminTheme.textMuted),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Tutup',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Badges
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'Saldo Dompet',
                  value: currency.format(widget.user.wallet),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AdminTheme.brandDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Status Keanggotaan',
                  value: widget.user.isSubscribe ? 'PawPass VIP' : 'Reguler',
                  icon: Icons.star_outline_rounded,
                  color: widget.user.isSubscribe ? const Color(0xFFD97706) : AdminTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  title: 'Point Donasi',
                  value: '${widget.user.pointDonation.toInt()} Pts',
                  icon: Icons.volunteer_activism_outlined,
                  color: AdminTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Detail Info Table
          const Text(
            'Informasi Akun Lengkap',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AdminTheme.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDataRow('Nama Lengkap', widget.user.name),
                const Divider(height: 20),
                _buildDataRow('Alamat Email', widget.user.email),
                const Divider(height: 20),
                _buildDataRow('Nomor HP / WhatsApp', widget.user.phone),
                const Divider(height: 20),
                _buildDataRow('Status Akun', _isBlocked ? 'Diblokir oleh Admin' : 'Aktif Normal'),
                if (_isBlocked && widget.user.blockReason != null && widget.user.blockReason!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _buildDataRow('Alasan Blokir', widget.user.blockReason!, isHighlight: true),
                ],
                const Divider(height: 20),
                _buildDataRow('Terdaftar Sejak', dateFormat.format(widget.user.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsTab() {
    if (_pets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_rounded, size: 54, color: AdminTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Anabul Terdaftar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pengguna ini belum menambahkan hewan peliharaan ke profilnya.',
              style: TextStyle(fontSize: 13, color: AdminTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _pets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pet = _pets[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AdminTheme.divider),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AdminTheme.primarySubtle,
                  borderRadius: BorderRadius.circular(10),
                  image: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(pet.imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: pet.imageUrl == null || pet.imageUrl!.isEmpty
                    ? const Icon(Icons.pets_rounded, color: AdminTheme.brandDark, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pet.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                        ),
                        if (pet.isStambum) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AdminTheme.primarySubtle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Stambum', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AdminTheme.brandDark)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.typeName ?? "Hewan"} • Ras: ${pet.breed ?? "Campuran"} • Gender: ${pet.genderName ?? "-"}',
                      style: const TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                    ),
                    if (pet.weight != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Berat: ${pet.weight} kg',
                        style: const TextStyle(fontSize: 12, color: AdminTheme.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 54, color: AdminTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Riwayat Postingan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.textSecondary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pengguna ini belum membuat posting adopsi, marketplace, atau info hewan hilang.',
              style: TextStyle(fontSize: 13, color: AdminTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = _posts[index];
        Color categoryColor;
        switch (post.category) {
          case 'adopt':
            categoryColor = const Color(0xFF2563EB);
            break;
          case 'marketplace':
            categoryColor = const Color(0xFF059669);
            break;
          default:
            categoryColor = const Color(0xFFD97706);
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AdminTheme.divider),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AdminTheme.background,
                  borderRadius: BorderRadius.circular(10),
                  image: post.imageUrl != null && post.imageUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(post.imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: post.imageUrl == null || post.imageUrl!.isEmpty
                    ? Icon(Icons.image_outlined, color: AdminTheme.textMuted.withValues(alpha: 0.6), size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            post.categoryLabel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: categoryColor),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          dateFormat.format(post.createdAt),
                          style: const TextStyle(fontSize: 11, color: AdminTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AdminTheme.textPrimary),
                    ),
                    if (post.desc != null && post.desc!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        post.desc!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
                      ),
                    ],
                    if (post.price > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        currency.format(post.price),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AdminTheme.brandDark),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AdminTheme.textSecondary)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isHighlight ? AdminTheme.error : AdminTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
