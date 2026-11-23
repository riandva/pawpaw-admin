import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../config/admin_theme.dart';
import '../../controllers/admin_dashboard_controller.dart';
import '../admin_main_screen.dart';

class AdminLandingScreen extends StatefulWidget {
  const AdminLandingScreen({super.key});

  @override
  State<AdminLandingScreen> createState() => _AdminLandingScreenState();
}

class _AdminLandingScreenState extends State<AdminLandingScreen> {
  final AdminDashboardController _ctrl = Get.find<AdminDashboardController>();
  final _emailCtrl = TextEditingController(text: 'admin@pawpaw.id');
  final _passwordCtrl = TextEditingController(text: 'admin123');
  final _formKey = GlobalKey<FormState>();
  final RxBool _obscurePass = true.obs;
  final RxBool _isSubmitting = false.obs;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    _isSubmitting.value = true;
    try {
      final success = await _ctrl.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      if (success) {
        Get.offAll(() => const AdminMainScreen());
      }
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // PawPaw Logo Header with ic_logo_text.svg
                _buildLogoHeader(),
                const SizedBox(height: 28),

                // Login Form Card
                _buildLoginFormCard(context),
                const SizedBox(height: 24),

                // Footer copyright
                const Text(
                  '© 2026 PT PawPaw Indonesia Raya. All Rights Reserved.',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        // SVG Logo with text
        SvgPicture.asset(
          'assets/icons/ic_logo_text.svg',
          width: 170,
          semanticsLabel: 'PawPaw Logo',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AdminTheme.brandDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_rounded, size: 13, color: AdminTheme.primary),
              SizedBox(width: 6),
              Text(
                'ADMIN CONSOLE & OPERATIONS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Masuk ke Console',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AdminTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gunakan kredensial akun administrator Anda untuk melanjutkan.',
              style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
            ),
            const SizedBox(height: 28),

            // Email Field
            const Text(
              'Email Administrator',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'admin@pawpaw.id',
                prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AdminTheme.textMuted),
                filled: true,
                fillColor: AdminTheme.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AdminTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AdminTheme.border),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
                if (!val.contains('@')) return 'Format email tidak valid';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Field
            const Text(
              'Kata Sandi',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AdminTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Obx(() => TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePass.value,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AdminTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20,
                        color: AdminTheme.textMuted,
                      ),
                      onPressed: () => _obscurePass.toggle(),
                    ),
                    filled: true,
                    fillColor: AdminTheme.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AdminTheme.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AdminTheme.border),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Kata sandi wajib diisi';
                    if (val.length < 4) return 'Kata sandi terlalu pendek';
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                )),
            const SizedBox(height: 22),

            // Quick Demo Credentials Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AdminTheme.primarySubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminTheme.primary.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AdminTheme.brandDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Default: admin@pawpaw.id / admin123',
                      style: TextStyle(fontSize: 11.5, color: AdminTheme.brandDark, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.brandDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting.value ? null : _handleLogin,
                    child: _isSubmitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Masuk ke Dashboard',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
