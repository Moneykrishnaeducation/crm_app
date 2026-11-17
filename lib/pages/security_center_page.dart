import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

const _securityNavy = Color(0xFF10264A);
const _securityPanel = Color(0xFFFFFFFF);
const _securityBorder = Color(0xFFDCE5F1);
const _bgLight = Color(0xFFF8FAFC);
const _blueDark = Color(0xFF10264A);
const _blueLight = Color(0xFFEAF2FC);
const _bluePrimary = Color(0xFF174A8B);
const _borderColor = _securityBorder;
const _cardBg = _securityPanel;
const _goldAccent = Color(0xFFB18418);
const _goldBorder = Color(0xFFF0DFAF);
const _goldLight = Color(0xFFFFF7E3);
const _greenAccent = Color(0xFF16845B);
const _greenLight = Color(0xFFEAF7EF);
const _redAccent = Color(0xFFB94C4C);
const _textPrimary = _securityNavy;
const _textSecondary = Color(0xFF62738E);

Future<bool?> showSecurityPasswordModal(
  BuildContext context, {
  VoidCallback? onVerified,
}) async {
  final verified = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const VerifySecurityPasswordModal(),
  );

  if (verified == true && onVerified != null) {
    onVerified();
  }
  return verified;
}

class SecurityCenterPage extends StatefulWidget {
  const SecurityCenterPage({
    super.key,
    required this.onBack,
    required this.onSelectPage,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onSelectPage;

  @override
  State<SecurityCenterPage> createState() => _SecurityCenterPageState();
}

class _SecurityCenterPageState extends State<SecurityCenterPage> {
  bool _loginCaptchaEnabled = true;
  bool _email2faEnabled = true;
  bool _isDeviceRevoked = false;

  BoxDecoration _mobileCardDecoration() => BoxDecoration(
    color: _cardBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: _borderColor),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0D10264A),
        blurRadius: 16,
        offset: Offset(0, 5),
      ),
    ],
  );

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgLight,
      child: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          children: [
            // Top Mobile Navigation Bar
            _buildTopNavBar(),
            const SizedBox(height: 16),

            // Header Card: "Security & Devices"
            _buildSecurityHeaderCard(),
            const SizedBox(height: 16),

            // Card 1: SIGN-IN PROTECTION
            _buildSignInProtectionCard(),
            const SizedBox(height: 16),

            // Card 2: Login CAPTCHA
            _buildLoginCaptchaCard(),
            const SizedBox(height: 16),

            // Card 3: Email two-factor verification
            _buildEmail2faCard(),
            const SizedBox(height: 24),

            // Section Header: "Trusted devices"
            _buildTrustedDevicesHeader(),
            const SizedBox(height: 14),

            // Card 4: Active Trusted Device ("Windows browser")
            _buildActiveTrustedDeviceCard(),
            const SizedBox(height: 20),

            // Bottom Footer & Actions
            _buildSecurityFooterActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Row(
      children: [
        InkWell(
          onTap: widget.onBack,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF174783)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowLeft, color: const Color(0xFF10264A), size: 16),
                SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Security Center',
                style: TextStyle(
                  color: const Color(0xFF10264A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Control sign-in protection and manage trusted devices.',
                style: TextStyle(color: Color(0xFF62738E), fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x1A22C55E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x6622C55E)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.shieldCheck, color: Color(0xFF22C55E), size: 14),
              SizedBox(width: 4),
              Text(
                'Protected',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _mobileCardDecoration(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 460;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FA),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF174783)),
                    ),
                    child: const Icon(LucideIcons.shieldCheck, color: _bluePrimary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security & Devices',
                          style: TextStyle(
                            color: const Color(0xFF10264A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Control sign-in protection and manage trusted devices.',
                          style: TextStyle(color: Color(0xFF62738E), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 12),
                    _buildRefreshDevicesButton(),
                  ],
                ],
              ),
              if (isNarrow) ...[
                const SizedBox(height: 14),
                _buildRefreshDevicesButton(),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildRefreshDevicesButton() {
    return InkWell(
      onTap: () => _showSnack('Devices refreshed'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.refreshCw, size: 14, color: Color(0xFF62738E)),
            SizedBox(width: 6),
            Text(
              'Refresh devices',
              style: TextStyle(
                color: Color(0xFF62738E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInProtectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _mobileCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _goldLight,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _goldBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.shield, color: _goldAccent, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'SIGN-IN PROTECTION',
                      style: TextStyle(
                        color: _goldAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your account, your devices',
            style: TextStyle(
              color: const Color(0xFF10264A),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'New browsers verify with an email one-time code before becoming trusted.',
            style: TextStyle(color: Color(0xFF62738E), fontSize: 13),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoCol = constraints.maxWidth >= 450;
              final stat1 = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF13376E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.laptop, size: 14, color: Color(0xFF62738E)),
                        SizedBox(width: 6),
                        Text(
                          'TRUSTED DEVICES',
                          style: TextStyle(
                            color: Color(0xFF62738E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isDeviceRevoked ? '0' : '1',
                      style: const TextStyle(
                        color: const Color(0xFF10264A),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Active trusted device',
                      style: TextStyle(color: Color(0xFF62738E), fontSize: 12),
                    ),
                  ],
                ),
              );

              final stat2 = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF13376E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.clock, size: 14, color: Color(0xFF62738E)),
                        SizedBox(width: 6),
                        Text(
                          'EXPIRED SESSIONS',
                          style: TextStyle(
                            color: Color(0xFF62738E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '0',
                      style: TextStyle(
                        color: const Color(0xFF10264A),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'No longer trusted after 7 days',
                      style: TextStyle(color: Color(0xFF62738E), fontSize: 12),
                    ),
                  ],
                ),
              );

              if (isTwoCol) {
                return Row(
                  children: [
                    Expanded(child: stat1),
                    const SizedBox(width: 12),
                    Expanded(child: stat2),
                  ],
                );
              }
              return Column(
                children: [
                  stat1,
                  const SizedBox(height: 12),
                  stat2,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCaptchaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _mobileCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: const Icon(LucideIcons.shieldCheck, color: _bluePrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _loginCaptchaEnabled = !_loginCaptchaEnabled),
                  child: const Text(
                    'Login CAPTCHA',
                    style: TextStyle(
                      color: const Color(0xFF10264A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _loginCaptchaEnabled = !_loginCaptchaEnabled),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _loginCaptchaEnabled ? const Color(0xFFE8F1FD) : const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _loginCaptchaEnabled ? _bluePrimary : _borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _loginCaptchaEnabled ? LucideIcons.checkSquare : LucideIcons.square,
                        color: _loginCaptchaEnabled ? _bluePrimary : _textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _loginCaptchaEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          color: _loginCaptchaEnabled ? const Color(0xFF10264A) : const Color(0xFF62738E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Require a GeeTest challenge before password sign-in. Trusted existing sessions are not repeatedly challenged.',
            style: TextStyle(color: Color(0xFF62738E), fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildEmail2faCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _mobileCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _goldBorder),
                ),
                child: const Icon(LucideIcons.mail, color: _goldAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _email2faEnabled = !_email2faEnabled),
                  child: const Text(
                    'Email two-factor verification',
                    style: TextStyle(
                      color: const Color(0xFF10264A),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => setState(() => _email2faEnabled = !_email2faEnabled),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _email2faEnabled ? const Color(0xFFE8F1FD) : const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _email2faEnabled ? _bluePrimary : _borderColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _email2faEnabled ? LucideIcons.checkSquare : LucideIcons.square,
                        color: _email2faEnabled ? _bluePrimary : _textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _email2faEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          color: _email2faEnabled ? const Color(0xFF10264A) : const Color(0xFF62738E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'When enabled, email OTP is required at every password sign-in. When disabled, trusted devices skip OTP; new or untrusted devices still verify.',
            style: TextStyle(color: Color(0xFF62738E), fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustedDevicesHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trusted devices',
                style: TextStyle(
                  color: const Color(0xFF10264A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isDeviceRevoked ? '0 devices can access your account' : '1 device can access your account',
                style: const TextStyle(color: Color(0xFF62738E), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _greenLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Protection active',
                style: TextStyle(
                  color: _greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTrustedDeviceCard() {
    if (_isDeviceRevoked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: _mobileCardDecoration(),
        child: const Column(
          children: [
            Icon(LucideIcons.monitorSmartphone, size: 30, color: _textSecondary),
            SizedBox(height: 10),
            Text(
              'No trusted devices active',
              style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Sign in again to register this device as trusted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _mobileCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _deviceStatusBadge(
                icon: LucideIcons.shield,
                label: 'TRUSTED DEVICE',
                background: _blueLight,
                foreground: _bluePrimary,
                border: const Color(0xFFBFDBFE),
              ),
              _deviceStatusBadge(
                icon: LucideIcons.check,
                label: 'This device',
                background: _greenLight,
                foreground: _greenAccent,
                border: const Color(0xFF86EFAC),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: _LaptopSecurityGraphic()),
          const SizedBox(height: 14),
          const Text(
            'Windows browser',
            style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: _blueLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.layoutGrid, size: 13, color: _bluePrimary),
                SizedBox(width: 6),
                Text('Windows', style: TextStyle(color: _blueDark, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: _securityBorder, height: 1),
          const SizedBox(height: 12),
          _buildDeviceDetailRow(
            icon: LucideIcons.mapPin,
            label: 'Public IP:',
            value: '104.22.224.94',
          ),
          const SizedBox(height: 9),
          _buildDeviceDetailRow(
            icon: LucideIcons.globe,
            label: 'Cloudflare proxy IP:',
            value: '104.22.224.94',
          ),
          const SizedBox(height: 9),
          _buildDeviceDetailRow(
            icon: LucideIcons.clock,
            label: 'Last active:',
            value: '16/11/2026, 9:17:26 am',
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(LucideIcons.laptop, size: 14, color: _textSecondary),
              SizedBox(width: 7),
              Text('Browser details:', style: TextStyle(color: _textSecondary, fontSize: 11.5)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _securityBorder),
            ),
            child: const Text(
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36 Edg/157.0.0.0',
              style: TextStyle(color: Color(0xFF40536F), fontSize: 10.5, height: 1.35),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: _confirmRemoveDevice,
              icon: const Icon(LucideIcons.logOut, size: 15),
              label: const Text('Remove trust', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _redAccent,
                backgroundColor: const Color(0xFFFFF1F1),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceStatusBadge({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: foreground),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: foreground, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveDevice() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.shieldAlert, color: _redAccent, size: 30),
              const SizedBox(height: 12),
              const Text('Remove trusted device?', style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text(
                'This device will need to verify again the next time it signs in.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: _redAccent, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Remove device'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _isDeviceRevoked = true);
      _showSnack('Device removed from this screen');
    }
  }

  Widget _buildDeviceDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 340) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: const Color(0xFF62738E)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(color: Color(0xFF62738E), fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: const Color(0xFF10264A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF62738E)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF62738E), fontSize: 12),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: const Color(0xFF10264A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecurityFooterActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Removing a device revokes its active tokens. It must verify by email the next time it signs in.',
          style: TextStyle(color: Color(0xFF62738E), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () {
            setState(() => _isDeviceRevoked = true);
            _showSnack('All trusted devices have been revoked');
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shieldOff, size: 16, color: _redAccent),
                SizedBox(width: 8),
                Text(
                  'Revoke all devices',
                  style: TextStyle(
                    color: _redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LaptopSecurityGraphic extends StatelessWidget {
  const _LaptopSecurityGraphic();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 105,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Laptop screen
          Container(
            width: 118,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _goldAccent, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _bluePrimary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E3A8A),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.eye,
                  color: Color(0xFFFDE68A),
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          // Laptop base
          Container(
            width: 136,
            height: 6,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF94A3B8), Color(0xFFCBD5E1), Color(0xFF94A3B8)],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Laptop notch
          Container(
            width: 28,
            height: 2,
            decoration: const BoxDecoration(
              color: Color(0xFF64748B),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
            ),
          ),
        ],
      ),
    );
  }
}

class VerifySecurityPasswordModal extends StatefulWidget {
  const VerifySecurityPasswordModal({super.key});

  @override
  State<VerifySecurityPasswordModal> createState() => _VerifySecurityPasswordModalState();
}

class _VerifySecurityPasswordModalState extends State<VerifySecurityPasswordModal> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your CRM password to continue.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password verification is not connected yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1E0F172A),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Royal Blue with Gold/White accents
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_blueDark, Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _goldAccent.withValues(alpha: 0.5)),
                          ),
                          child: const Icon(
                            LucideIcons.lock,
                            color: Color(0xFFFDE68A),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Security Verification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body: Pure white
              Container(
                color: _cardBg,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Verify it's you",
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your CRM password to open the Security & Devices tab.',
                      style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'CRM password',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _borderColor,
                          width: 1.2,
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: _textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your current password',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                              color: _textSecondary,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        onSubmitted: (_) => _handleVerify(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _goldLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(LucideIcons.shieldCheck, color: _goldAccent, size: 14),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Your password is checked securely and is not stored.',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _bluePrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Verify password →',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(LucideIcons.arrowRight, size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
