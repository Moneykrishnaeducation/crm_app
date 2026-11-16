import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

const _securityNavy = Color(0xFF06163B);
const _securityPanel = Color(0xFF081D44);
const _securityBorder = Color(0xFF13376E);

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

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F326D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _securityNavy,
      child: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
          children: [
            // Top Navigation Bar
            _buildTopNavBar(),
            const SizedBox(height: 16),

            // Header Card
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
              color: const Color(0xFF0A204A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF174783)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowLeft, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
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
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Control sign-in protection and manage trusted devices.',
                style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 11),
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
      decoration: BoxDecoration(
        color: _securityPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _securityBorder),
      ),
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
                      color: const Color(0xFF0D2F63),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF174783)),
                    ),
                    child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF38BDF8), size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security & Devices',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Control sign-in protection and manage trusted devices.',
                          style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 12),
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
          color: const Color(0xFF0A204A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1D4D8F)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.refreshCw, size: 14, color: Color(0xFF8EA5C8)),
            SizedBox(width: 6),
            Text(
              'Refresh devices',
              style: TextStyle(
                color: Color(0xFF8EA5C8),
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
      decoration: BoxDecoration(
        color: _securityPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _securityBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.shield, color: Color(0xFF4988E8), size: 14),
              SizedBox(width: 6),
              Text(
                'SIGN-IN PROTECTION',
                style: TextStyle(
                  color: Color(0xFF4988E8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Your account, your devices',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'New browsers verify with an email one-time code before becoming trusted.',
            style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isTwoCol = constraints.maxWidth >= 450;
              final stat1 = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF06163B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF13376E)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.laptop, size: 14, color: Color(0xFF8EA5C8)),
                        SizedBox(width: 6),
                        Text(
                          'TRUSTED DEVICES',
                          style: TextStyle(
                            color: Color(0xFF8EA5C8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isDeviceRevoked ? '0' : '1',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Active trusted device',
                      style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 12),
                    ),
                  ],
                ),
              );

              final stat2 = Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF06163B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF13376E)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.clock, size: 14, color: Color(0xFF8EA5C8)),
                        SizedBox(width: 6),
                        Text(
                          'EXPIRED SESSIONS',
                          style: TextStyle(
                            color: Color(0xFF8EA5C8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No longer trusted after 7 days',
                      style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 12),
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
      decoration: BoxDecoration(
        color: _securityPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _securityBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2F63),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF174783)),
                ),
                child: const Icon(LucideIcons.shieldCheck, color: Color(0xFF38BDF8), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _loginCaptchaEnabled = !_loginCaptchaEnabled),
                  child: const Text(
                    'Login CAPTCHA',
                    style: TextStyle(
                      color: Colors.white,
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
                    color: _loginCaptchaEnabled ? const Color(0xFF0F3670) : const Color(0xFF06163B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _loginCaptchaEnabled ? const Color(0xFF2563EB) : const Color(0xFF1D4D8F),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _loginCaptchaEnabled ? LucideIcons.checkSquare : LucideIcons.square,
                        color: _loginCaptchaEnabled ? const Color(0xFF38BDF8) : const Color(0xFF8EA5C8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Enabled',
                        style: TextStyle(
                          color: _loginCaptchaEnabled ? Colors.white : const Color(0xFF8EA5C8),
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
            style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildEmail2faCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _securityPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _securityBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D2F63),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF174783)),
                ),
                child: const Icon(LucideIcons.mail, color: Color(0xFF38BDF8), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _email2faEnabled = !_email2faEnabled),
                  child: const Text(
                    'Email two-factor verification',
                    style: TextStyle(
                      color: Colors.white,
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
                    color: _email2faEnabled ? const Color(0xFF0F3670) : const Color(0xFF06163B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _email2faEnabled ? const Color(0xFF2563EB) : const Color(0xFF1D4D8F),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _email2faEnabled ? LucideIcons.checkSquare : LucideIcons.square,
                        color: _email2faEnabled ? const Color(0xFF38BDF8) : const Color(0xFF8EA5C8),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Enabled',
                        style: TextStyle(
                          color: _email2faEnabled ? Colors.white : const Color(0xFF8EA5C8),
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
            style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 12.5, height: 1.4),
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
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isDeviceRevoked ? '0 devices can access your account' : '1 device can access your account',
                style: const TextStyle(color: Color(0xFF8EA5C8), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Protection active',
              style: TextStyle(
                color: Color(0xFF22C55E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveTrustedDeviceCard() {
    if (_isDeviceRevoked) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _securityPanel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _securityBorder),
        ),
        child: const Center(
          child: Text(
            'No trusted devices active. Sign in again to register a trusted device.',
            style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _securityPanel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _securityBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: [shield] TRUSTED DEVICE ... [✓ This device]
          LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth < 340) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.shield, color: Color(0xFF4988E8), size: 14),
                        SizedBox(width: 6),
                        Text(
                          'TRUSTED DEVICE',
                          style: TextStyle(
                            color: Color(0xFF4988E8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C3925),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF14532D)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.check, size: 12, color: Color(0xFF22C55E)),
                          SizedBox(width: 4),
                          Text(
                            'This device',
                            style: TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.shield, color: Color(0xFF4988E8), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'TRUSTED DEVICE',
                        style: TextStyle(
                          color: Color(0xFF4988E8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C3925),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF14532D)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.check, size: 12, color: Color(0xFF22C55E)),
                        SizedBox(width: 4),
                        Text(
                          'This device',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          // Illustration
          const Center(child: _LaptopSecurityGraphic()),
          const SizedBox(height: 16),

          // Title & Windows chip
          const Text(
            'Windows browser',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2563EB)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.layoutGrid, size: 13, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  'Windows',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: _securityBorder, height: 1),
          const SizedBox(height: 14),

          // Details List
          _buildDeviceDetailRow(
            icon: LucideIcons.mapPin,
            label: 'Public IP:',
            value: '104.22.224.94',
          ),
          const SizedBox(height: 10),
          _buildDeviceDetailRow(
            icon: LucideIcons.mapPin,
            label: 'Cloudflare proxy IP:',
            value: '104.22.224.94',
          ),
          const SizedBox(height: 10),
          _buildDeviceDetailRow(
            icon: LucideIcons.clock,
            label: 'Last active:',
            value: '16/11/2026, 9:17:26 am',
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.laptop, size: 14, color: Color(0xFF8EA5C8)),
                  SizedBox(width: 8),
                  Text(
                    'Browser details:',
                    style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF06163B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _securityBorder),
                ),
                child: const Text(
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36 Edg/157.0.0.0',
                  style: TextStyle(
                    color: Color(0xFFCFDCF3),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // [Remove trust] button
          InkWell(
            onTap: () {
              setState(() => _isDeviceRevoked = true);
              _showSnack('Device trust removed');
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF2A0F16),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF5C1D24)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.logOut, size: 14, color: Color(0xFFFF5C5C)),
                  SizedBox(width: 6),
                  Text(
                    'Remove trust',
                    style: TextStyle(
                      color: Color(0xFFFF5C5C),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                  Icon(icon, size: 14, color: const Color(0xFF8EA5C8)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(color: Color(0xFF8EA5C8), fontSize: 12),
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
                    color: Colors.white,
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
            Icon(icon, size: 14, color: const Color(0xFF8EA5C8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF8EA5C8), fontSize: 12),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.white,
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
          style: TextStyle(color: Color(0xFF8EA5C8), fontSize: 12, height: 1.4),
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
              color: const Color(0xFF1E0A10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF5C1D24)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shieldOff, size: 16, color: Color(0xFFFF5C5C)),
                SizedBox(width: 8),
                Text(
                  'Revoke all devices',
                  style: TextStyle(
                    color: Color(0xFFFF5C5C),
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
    return SizedBox(
      width: 140,
      height: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glowing screen
          Container(
            width: 114,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2450), Color(0xFF030D1F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F2B5C),
                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.eye,
                  color: Color(0xFF38BDF8),
                  size: 18,
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
                colors: [Color(0xFF334155), Color(0xFF64748B), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Laptop notch
          Container(
            width: 28,
            height: 2,
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
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
    Navigator.of(context).pop(true);
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
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Dark royal navy background (#082452) with top rounded corners (24px)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: const Color(0xFF082452),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D326F),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF1D4D8F)),
                      ),
                      child: const Icon(
                        LucideIcons.lock,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D326F),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF1D4D8F)),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          color: Color(0xFF8EA5C8),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body: Soft light blue background (#F0F6FD)
              Container(
                color: const Color(0xFFF0F6FD),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Verify it's you",
                      style: TextStyle(
                        color: Color(0xFF081F4D),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter your CRM password to open the Security & Devices tab.',
                      style: TextStyle(
                        color: Color(0xFF5A739C),
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'CRM password',
                      style: TextStyle(
                        color: Color(0xFF081F4D),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD8E5F4),
                          width: 1.2,
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Color(0xFF081F4D), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your current password',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                              color: const Color(0xFF5A739C),
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
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.shieldCheck, color: Color(0xFF2563EB), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your password is checked securely and is not stored.',
                            style: TextStyle(
                              color: Color(0xFF5A739C),
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
                          backgroundColor: const Color(0xFF143878),
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
