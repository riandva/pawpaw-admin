import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/admin_api.dart';
import '../../config/admin_theme.dart';
import '../../models/admin_models.dart';
import '../widgets/app_notification.dart';

class AdoptPackagesView extends StatefulWidget {
  const AdoptPackagesView({super.key});

  @override
  State<AdoptPackagesView> createState() => _AdoptPackagesViewState();
}

class _AdoptPackagesViewState extends State<AdoptPackagesView> {
  final AdminApi _api = AdminApi();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  bool _isLoading = true;
  List<AdoptPackageModel> _packages = [];

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() => _isLoading = true);
    final list = await _api.getAdoptPackages();
    if (mounted) {
      setState(() {
        _packages = list;
        _isLoading = false;
      });
    }
  }

  void _showPackageDialog({AdoptPackageModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final activeDaysCtrl = TextEditingController(text: (existing?.activeDays ?? 30).toString());
    final priceCtrl = TextEditingController(text: (existing?.price ?? 0).toInt().toString());
    String selectedType = existing?.type ?? 'free';
    bool isActive = existing?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            existing == null ? 'Tambah Paket Posting Adopsi' : 'Edit Paket Posting Adopsi',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tipe Paket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Gratis (Ads Reward)'),
                          selected: selectedType == 'free',
                          onSelected: (_) {
                            setDialogState(() {
                              selectedType = 'free';
                              priceCtrl.text = '0';
                            });
                          },
                          selectedColor: AdminTheme.successLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Berbayar (Premium)'),
                          selected: selectedType == 'paid',
                          onSelected: (_) {
                            setDialogState(() {
                              selectedType = 'paid';
                              if (priceCtrl.text == '0') priceCtrl.text = '25000';
                            });
                          },
                          selectedColor: AdminTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Paket',
                      hintText: selectedType == 'free' ? 'Contoh: Paket Gratis (Tonton Iklan)' : 'Contoh: Paket Prioritas 30 Hari',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Singkat',
                      hintText: 'Contoh: Tayang 14 hari dengan menonton 1 iklan reward',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: activeDaysCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Masa Aktif (Hari)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          enabled: selectedType == 'paid',
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Harga (Rp)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktifkan Paket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    value: isActive,
                    onChanged: (val) => setDialogState(() => isActive = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AdminTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.brandDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  AppNotification.showError(title: 'Validasi', message: 'Nama paket wajib diisi');
                  return;
                }
                final activeDays = int.tryParse(activeDaysCtrl.text.trim()) ?? 30;
                final price = selectedType == 'free' ? 0.0 : (double.tryParse(priceCtrl.text.trim()) ?? 0.0);

                Navigator.pop(ctx);
                bool ok;
                if (existing == null) {
                  ok = await _api.createAdoptPackage(
                    name: name,
                    description: descCtrl.text.trim(),
                    type: selectedType,
                    days: activeDays,
                    activeDays: activeDays,
                    price: price,
                    isActive: isActive,
                  );
                } else {
                  ok = await _api.updateAdoptPackage(
                    existing.id,
                    name: name,
                    description: descCtrl.text.trim(),
                    type: selectedType,
                    days: activeDays,
                    activeDays: activeDays,
                    price: price,
                    isActive: isActive,
                  );
                }

                if (ok) {
                  AppNotification.showSuccess(
                    title: 'Berhasil',
                    message: existing == null ? 'Paket adopsi baru ditambahkan' : 'Paket adopsi diperbarui',
                  );
                  _fetchPackages();
                } else {
                  AppNotification.showError(title: 'Gagal', message: 'Gagal menyimpan paket adopsi');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePackage(AdoptPackageModel pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Paket?'),
        content: Text('Yakin ingin menghapus paket "${pkg.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await _api.deleteAdoptPackage(pkg.id);
      if (ok) {
        AppNotification.showSuccess(title: 'Dihapus', message: 'Paket "${pkg.name}" berhasil dihapus');
        _fetchPackages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paket Posting Adopsi 🐾',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AdminTheme.textPrimary),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Atur paket posting adopsi: Paket Gratis (dengan Ads Reward) dan Paket Berbayar.',
                      style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showPackageDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminTheme.brandDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Paket', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AdminTheme.primary))
                : _packages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 54, color: AdminTheme.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('Belum Ada Paket Adopsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            const Text('Tambahkan 1 paket gratis (Ads Reward) dan 1 paket berbayar.', style: TextStyle(color: AdminTheme.textMuted)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _packages.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pkg = _packages[index];
                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: AdminTheme.cardDecoration(),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: pkg.isFree ? AdminTheme.successLight : AdminTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    pkg.isFree ? Icons.play_circle_outline_rounded : Icons.workspace_premium_rounded,
                                    color: pkg.isFree ? AdminTheme.success : AdminTheme.primaryDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(pkg.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: pkg.isFree ? AdminTheme.successLight : AdminTheme.primaryLight,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              pkg.isFree ? 'GRATIS • ADS REWARD' : 'BERBAYAR',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: pkg.isFree ? AdminTheme.success : AdminTheme.primaryDark,
                                              ),
                                            ),
                                          ),
                                          if (!pkg.isActive) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AdminTheme.errorLight,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'NONAKTIF',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AdminTheme.error),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (pkg.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(pkg.description, style: const TextStyle(fontSize: 13, color: AdminTheme.textSecondary)),
                                      ],
                                      const SizedBox(height: 6),
                                      Text(
                                        'Masa Aktif: ${pkg.activeDays} Hari  •  Harga: ${pkg.isFree ? "Gratis (Tonton Iklan)" : currency.format(pkg.price)}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AdminTheme.brandDark),
                                  onPressed: () => _showPackageDialog(existing: pkg),
                                  tooltip: 'Edit Paket',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AdminTheme.error),
                                  onPressed: () => _deletePackage(pkg),
                                  tooltip: 'Hapus Paket',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
