import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../app_notifications.dart';
import '../biometric_sign_in.dart';

// VT Index & Revolut-tier Fintech Design System Colors
const _navyCardDark = Color(0xFF0F1E36);
const _brokerGold = Color(0xFFF4C84A);
const _goldAccent = Color(0xFFB18418);
const _goldLight = Color(0xFFFFF7E3);
const _goldBorder = Color(0xFFF0DFAF);

const _blueRoyal = Color(0xFF0875F5);
const _blueDark = Color(0xFF10264A);
const _bluePrimary = Color(0xFF174A8B);
const _blueLight = Color(0xFFEAF2FC);

const _greenAccent = Color(0xFF16845B);
const _greenLight = Color(0xFFEAF7EF);
const _greenBorder = Color(0xFF86EFAC);

const _redAccent = Color(0xFFDC2626);
const _redLight = Color(0xFFFFF1F1);
const _redBorder = Color(0xFFFECACA);

const _bgLight = Color(0xFFF4F7FC);
const _textSecondary = Color(0xFF62738E);

Future<bool?> showSecurityPasswordModal(
  BuildContext context, {
  VoidCallback? onVerified,
  BiometricSignIn? biometricSignIn,
}) async {
  final bio = biometricSignIn ?? BiometricSignIn.instance;
  final isEnabled = await bio.isEnabled();
  final isAvailable = await bio.isAvailable();

  if (isEnabled && isAvailable) {
    try {
      final authenticated = await bio.authenticate(
        localizedReason: 'Authenticate to access Security Center',
      );
      if (authenticated) {
        onVerified?.call();
        return true;
      }
      showAppMessage('Biometric verification not completed. Verify with password.');
    } catch (_) {
      // Fallback to password modal
    }
  }

  if (!context.mounted) return null;

  final verified = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (sheetContext) => VerifySecurityPasswordModal(
      biometricSignIn: bio,
      isBiometricAvailable: isAvailable,
      isBiometricEnabled: isEnabled,
    ),
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
    this.biometricSignIn,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onSelectPage;
  final BiometricSignIn? biometricSignIn;

  @override
  State<SecurityCenterPage> createState() => _SecurityCenterPageState();
}

class _SecurityCenterPageState extends State<SecurityCenterPage> {
  bool _loginCaptchaEnabled = true;
  bool _email2faEnabled = true;
  bool _biometricEnabled = false;
  bool _isDeviceRevoked = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _textColor => _isDark ? const Color(0xFFF2F5FA) : const Color(0xFF10264A);
  Color get _mutedColor => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF62738E);
  Color get _subCardColor => _isDark ? const Color(0xFF132238) : const Color(0xFFF4F7FC);
  Color get _subBorderColor => _isDark ? const Color(0xFF23364E) : const Color(0xFFDCE5F1);

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    try {
      final bio = widget.biometricSignIn ?? BiometricSignIn.instance;
      final enabled = await bio.isEnabled();
      if (mounted) {
        setState(() => _biometricEnabled = enabled);
      }
    } catch (_) {}
  }

  Future<void> _toggleBiometric(bool value) async {
    HapticFeedback.lightImpact();
    final bio = widget.biometricSignIn ?? BiometricSignIn.instance;
    if (value) {
      try {
        if (!await bio.isAvailable()) {
          _showSnack('No fingerprint or Face ID is enrolled on this device.');
          return;
        }
        final verified = await bio.authenticate(
          localizedReason: 'Verify your identity to enable biometric sign-in',
        );
        if (!verified) {
          _showSnack('Biometric verification was not completed.');
          return;
        }
        await bio.setEnabled(true);
        if (mounted) setState(() => _biometricEnabled = true);
        _showSnack('Biometric sign-in enabled');
      } on PlatformException catch (error) {
        _showSnack(error.message ?? 'Biometric authentication failed.');
      } catch (_) {
        _showSnack('Could not enable biometric sign-in.');
      }
    } else {
      try {
        await bio.setEnabled(false);
        if (mounted) setState(() => _biometricEnabled = false);
        _showSnack('Biometric sign-in disabled');
      } catch (_) {
        _showSnack('Could not disable biometric sign-in.');
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    showAppMessage(message);
  }

  BoxDecoration _insetCardDecoration({bool isHighlighted = false}) {
    return BoxDecoration(
      color: _isDark ? _navyCardDark : Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: _isDark
            ? (isHighlighted ? _brokerGold.withValues(alpha: 0.35) : const Color(0xFF1E3554))
            : (isHighlighted ? _goldBorder : const Color(0xFFE2EBF5)),
        width: 1.1,
      ),
      boxShadow: _isDark
          ? const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x0C10264A),
                blurRadius: 20,
                offset: Offset(0, 6),
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: _isDark ? Theme.of(context).scaffoldBackgroundColor : const Color(0xFFF7F9FC),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text('Security Center', style: TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: widget.onBack,
                      tooltip: 'Back',
                      icon: Icon(LucideIcons.chevronLeft, color: _textColor, size: 25),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _securitySectionLabel('Account Security'),
                  const SizedBox(height: 14),
                  _securityActionRow(
                    title: 'Email',
                    trailing: 't****harasan344@gmail.com',
                    onTap: null,
                  ),
                  _securityActionRow(
                    title: 'Login Password',
                    trailing: 'Change',
                    onTap: _showChangeLoginPassword,
                  ),
                  _securityToggleRow(
                    title: 'Mail OTP',
                    subtitle: 'Verify sign-ins using a one-time code sent to your email',
                    value: _email2faEnabled,
                    onChanged: (value) => setState(() => _email2faEnabled = value),
                  ),
                  _securityToggleRow(
                    title: 'Captcha',
                    subtitle: 'Add an extra verification step to protect account access',
                    value: _loginCaptchaEnabled,
                    onChanged: (value) => setState(() => _loginCaptchaEnabled = value),
                  ),
                  _securityToggleRow(
                    title: 'Biometrics',
                    subtitle: 'Use your device fingerprint or Face ID to secure sign-in',
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                    showDivider: false,
                  ),
                  const SizedBox(height: 28),
                  _securitySectionLabel('Other Settings'),
                  const SizedBox(height: 14),
                  _securityActionRow(title: 'Device Management', trailing: '', onTap: () => _openSecuritySubPage('Device Management')),
                  _securityActionRow(title: 'Account Management', trailing: '', onTap: () => _openSecuritySubPage('Account Management'), showDivider: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _securitySectionLabel(String title) => Row(
    children: [
      Container(width: 3, height: 17, decoration: BoxDecoration(color: _blueRoyal, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 10),
      Text(title, style: TextStyle(color: _mutedColor, fontSize: 14, fontWeight: FontWeight.w600)),
    ],
  );

  Widget _securityToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(
        color: _isDark ? const Color(0xFF24364D) : const Color(0xFFE6ECF4),
        width: .8,
      )),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: _textColor, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(subtitle, style: TextStyle(color: _mutedColor, fontSize: 12.5, height: 1.35)),
      ])),
      const SizedBox(width: 12),
      Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: _blueRoyal,
      ),
    ]),
  );

  Widget _securityActionRow({
    required String title,
    required String trailing,
    String? subtitle,
    Color? trailingColor,
    required VoidCallback? onTap,
    bool showDivider = true,
  }) => InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.only(top: subtitle == null ? 19 : 17, bottom: subtitle == null ? 19 : 17),
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: _isDark ? const Color(0xFF24364D) : const Color(0xFFE6ECF4), width: .8)) : null,
      ),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: _textColor, fontSize: 15, fontWeight: FontWeight.w600)),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(subtitle, style: TextStyle(color: _mutedColor, fontSize: 12.5, height: 1.35)),
              ],
            ],
          )),
          if (trailing.isNotEmpty)
            Text(trailing, style: TextStyle(color: trailingColor ?? _mutedColor, fontSize: 14, fontWeight: FontWeight.w500)),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(LucideIcons.chevronRight, color: _mutedColor, size: 19),
          ],
        ],
      ),
    ),
  );

  void _showSecurityAction(String title, String message) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(message, style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant, fontSize: 13, height: 1.5)),
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
          ]),
        ),
      ),
    );
  }

  void _openSecuritySubPage(String page) {
    final legacyDeviceContent = page == 'Device Management'
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTrustedDevicesHeader(),
              const SizedBox(height: 12),
              _buildActiveTrustedDeviceCard(),
              const SizedBox(height: 20),
              _buildSecurityFooterActions(),
            ],
          )
        : null;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => _SecurityReferenceSubPage(
        title: page,
        content: legacyDeviceContent,
      ),
    ));
  }

  Widget _buildSecurityHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDark
              ? const [
                  Color(0xFF142B4D),
                  Color(0xFF0F1E36),
                  Color(0xFF0A1526),
                ]
              : const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF6F9FE),
                  Color(0xFFEBF3FD),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isDark ? const Color(0xFF2C4366) : const Color(0xFFD3E2F5),
          width: 1.1,
        ),
        boxShadow: _isDark
            ? const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x10174A8B),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dual-ring glowing Shield badge
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isDark
                        ? const [Color(0xFF1E3A5F), Color(0xFF12233B)]
                        : const [Color(0xFFEAF2FC), Color(0xFFD6E6F8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _brokerGold.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _brokerGold.withValues(alpha: _isDark ? 0.3 : 0.2),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.shieldCheck,
                    color: _brokerGold,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Security & Devices',
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _greenLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _greenBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.shieldCheck, color: _greenAccent, size: 12),
                              SizedBox(width: 4),
                              Text(
                                '98% Protected',
                                style: TextStyle(
                                  color: _greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Control sign-in protection and manage trusted devices.',
                      style: TextStyle(
                        color: _mutedColor,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status Overview Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF101E31) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isDark ? const Color(0xFF1E3554) : const Color(0xFFE2EBF8),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x8022C55E),
                        blurRadius: 8,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Status: Excellent',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Maximum Protection Active • Level 3 - High Protection',
                        style: TextStyle(
                          color: _mutedColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Security Trust Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTrustChip(
                icon: LucideIcons.shieldCheck,
                label: '2FA Active',
                color: _greenAccent,
                bgColor: _greenLight,
                borderColor: _greenBorder,
              ),
              _buildTrustChip(
                icon: LucideIcons.checkCheck,
                label: 'Device Verified',
                color: _isDark ? const Color(0xFF60A5FA) : _bluePrimary,
                bgColor: _isDark ? const Color(0xFF1E2E48) : _blueLight,
                borderColor: _isDark ? const Color(0xFF2A4266) : const Color(0xFFBFDBFE),
              ),
              _buildTrustChip(
                icon: LucideIcons.lockKeyhole,
                label: '256-Bit SSL',
                color: _goldAccent,
                bgColor: _goldLight,
                borderColor: _goldBorder,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Unified Inset Card 1: SIGN-IN PROTECTION with setting rows and stats footer
  Widget _buildSignInProtectionUnifiedCard() {
    return Container(
      width: double.infinity,
      decoration: _insetCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Top: Badge & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _goldLight,
                    borderRadius: BorderRadius.circular(8),
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
                const SizedBox(height: 12),
                Text(
                  'Your account, your devices',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'New browsers verify with an email one-time code before becoming trusted.',
                  style: TextStyle(color: _mutedColor, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),

          Divider(
            color: _isDark ? const Color(0xFF1E3554) : const Color(0xFFEDF2F7),
            height: 1,
            thickness: 1,
          ),

          // Integrated Setting Row 1: Biometric Access
          _buildIntegratedSettingRow(
            icon: LucideIcons.fingerprint,
            iconBg: _isDark ? const Color(0xFF132D28) : _greenLight,
            iconColor: _greenAccent,
            title: 'Biometric Access',
            subtitle:
                'Use Fingerprint or Face ID for fast and secure access without entering your CRM password each time.',
            isEnabled: _biometricEnabled,
            onToggle: _toggleBiometric,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: _isDark ? const Color(0xFF192C44) : const Color(0xFFF1F5F9),
              height: 1,
              thickness: 0.8,
            ),
          ),

          // Integrated Setting Row 2: Email two-factor verification
          _buildIntegratedSettingRow(
            icon: LucideIcons.mail,
            iconBg: _isDark ? const Color(0xFF2A281E) : _goldLight,
            iconColor: _goldAccent,
            title: 'Email two-factor verification',
            subtitle:
                'When enabled, email OTP is required at every password sign-in. When disabled, trusted devices skip OTP; new or untrusted devices still verify.',
            isEnabled: _email2faEnabled,
            onToggle: (val) {
              setState(() => _email2faEnabled = val);
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: _isDark ? const Color(0xFF192C44) : const Color(0xFFF1F5F9),
              height: 1,
              thickness: 0.8,
            ),
          ),

          // Integrated Setting Row 3: Login CAPTCHA
          _buildIntegratedSettingRow(
            icon: LucideIcons.shieldCheck,
            iconBg: _isDark ? const Color(0xFF162D4A) : _blueLight,
            iconColor: _isDark ? const Color(0xFF60A5FA) : _bluePrimary,
            title: 'Login CAPTCHA',
            subtitle:
                'Require a GeeTest challenge before password sign-in. Trusted existing sessions are not repeatedly challenged.',
            isEnabled: _loginCaptchaEnabled,
            onToggle: (val) {
              setState(() => _loginCaptchaEnabled = val);
            },
          ),

          Divider(
            color: _isDark ? const Color(0xFF1E3554) : const Color(0xFFEDF2F7),
            height: 1,
            thickness: 1,
          ),

          // Stats summary pill footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTwoCol = constraints.maxWidth >= 420;
                final stat1 = Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _subCardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _subBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.laptop, size: 14, color: _mutedColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'TRUSTED DEVICES',
                              style: TextStyle(
                                color: _mutedColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (!_isDeviceRevoked)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x6622C55E),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isDeviceRevoked ? '0' : '1',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Active trusted device',
                        style: TextStyle(color: _mutedColor, fontSize: 12),
                      ),
                    ],
                  ),
                );

                final stat2 = Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _subCardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _subBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.clock, size: 14, color: _mutedColor),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'EXPIRED SESSIONS',
                              style: TextStyle(
                                color: _mutedColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '0',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No longer trusted after 7 days',
                        style: TextStyle(color: _mutedColor, fontSize: 12),
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
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedSettingRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _isDark ? const Color(0xFF2C3E55) : const Color(0xFFDCE5F1),
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onToggle(!isEnabled);
              },
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 12.5,
                      height: 1.38,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildModernSwitchPill(
            isEnabled: isEnabled,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSwitchPill({
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle(!isEnabled);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isEnabled
              ? (_isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F1FD))
              : _subCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled ? _bluePrimary : _subBorderColor,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEnabled ? _bluePrimary : _mutedColor.withValues(alpha: 0.25),
              ),
              child: Icon(
                isEnabled ? LucideIcons.check : LucideIcons.x,
                color: isEnabled ? Colors.white : _mutedColor,
                size: 10,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isEnabled ? 'Enabled' : 'Disabled',
              style: TextStyle(
                color: isEnabled ? _textColor : _mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
              Text(
                'Trusted devices',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isDeviceRevoked
                    ? '0 devices can access your account'
                    : '1 device can access your account',
                style: TextStyle(color: _mutedColor, fontSize: 12.5),
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
            border: Border.all(color: _greenBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x8022C55E),
                      blurRadius: 6,
                    ),
                  ],
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: _insetCardDecoration(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _subCardColor,
                shape: BoxShape.circle,
                border: Border.all(color: _subBorderColor),
              ),
              child: const Icon(LucideIcons.monitorSmartphone, size: 32, color: _textSecondary),
            ),
            const SizedBox(height: 14),
            Text(
              'No trusted devices active',
              style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in again to register this device as trusted.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _mutedColor, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _insetCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _deviceStatusBadge(
                icon: LucideIcons.shield,
                label: 'TRUSTED DEVICE',
                background: _isDark ? const Color(0xFF1E2E48) : _blueLight,
                foreground: _isDark ? const Color(0xFF60A5FA) : _bluePrimary,
                border: _subBorderColor,
              ),
              _deviceStatusBadge(
                icon: LucideIcons.check,
                label: 'This device',
                background: _isDark ? const Color(0xFF132D28) : _greenLight,
                foreground: _isDark ? const Color(0xFF4ADE80) : _greenAccent,
                border: _isDark ? const Color(0xFF1B4D3E) : _greenBorder,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Metallic laptop illustration
          const Center(child: _LaptopSecurityGraphic()),
          const SizedBox(height: 16),

          // Device Name & Status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x8022C55E),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Windows browser',
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF1E2F46) : _blueLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isDark ? const Color(0xFF2C4362) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.layoutGrid,
                      size: 13,
                      color: _isDark ? const Color(0xFF60A5FA) : _bluePrimary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Windows',
                      style: TextStyle(
                        color: _isDark ? const Color(0xFF93C5FD) : _blueDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Divider(
            color: _isDark ? const Color(0xFF1E3554) : const Color(0xFFEDF2F7),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 12),

          // Metadata Rows
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

          Row(
            children: [
              Icon(LucideIcons.laptop, size: 14, color: _mutedColor),
              const SizedBox(width: 7),
              Text(
                'Browser details:',
                style: TextStyle(color: _mutedColor, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _subCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _subBorderColor),
            ),
            child: Text(
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36 Edg/157.0.0.0',
              style: TextStyle(
                color: _mutedColor,
                fontSize: 11,
                height: 1.4,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Action Button: Remove Trust
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _confirmRemoveDevice,
              icon: const Icon(LucideIcons.logOut, size: 15),
              label: const Text(
                'Remove trust',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _redAccent,
                backgroundColor: _isDark
                    ? const Color(0xFF382326)
                    : _redLight,
                side: BorderSide(
                  color: _isDark
                      ? const Color(0xFF693B42)
                      : _redBorder,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
          Text(
            label,
            style: TextStyle(color: foreground, fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveDevice() async {
    HapticFeedback.lightImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(
            color: _isDark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF382326) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shieldAlert, color: _redAccent, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                'Remove trusted device?',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This device will need to verify again the next time it signs in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(46),
                      ),
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
                  Icon(icon, size: 14, color: _mutedColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(color: _mutedColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  value,
                  style: TextStyle(
                    color: _textColor,
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
            Icon(icon, size: 14, color: _mutedColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: _mutedColor, fontSize: 12),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: _textColor,
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

  Future<void> _confirmRevokeAllDevices() async {
    HapticFeedback.lightImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(
            color: _isDark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isDark ? const Color(0xFF382326) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shieldAlert, color: _redAccent, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                'Revoke all trusted devices?',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This will sign out all active sessions across all devices. You will need to verify with an email one-time code the next time you sign in.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(46),
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Revoke all devices'),
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
      HapticFeedback.mediumImpact();
      setState(() => _isDeviceRevoked = true);
      _showSnack('All trusted devices have been revoked');
    }
  }

  Widget _buildSecurityFooterActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Removing a device revokes its active tokens. It must verify by email the next time it signs in.',
          style: TextStyle(color: _mutedColor, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: _confirmRevokeAllDevices,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: _isDark ? const Color(0xFF382326) : const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isDark ? const Color(0xFF693B42) : const Color(0xFFFCA5A5),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 176,
      height: 114,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A2A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2E44) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Laptop screen
          Container(
            width: 128,
            height: 74,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B1220), Color(0xFF1A263C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _brokerGold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _blueRoyal.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF173868),
                  border: Border.all(color: _brokerGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _brokerGold.withValues(alpha: 0.45),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.shieldCheck,
                  color: Color(0xFFFDE68A),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          // Laptop base
          Container(
            width: 146,
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
            width: 32,
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
  const VerifySecurityPasswordModal({
    super.key,
    this.biometricSignIn,
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
  });

  final BiometricSignIn? biometricSignIn;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;

  @override
  State<VerifySecurityPasswordModal> createState() => _VerifySecurityPasswordModalState();
}

typedef VerifySecurityPasswordSheet = VerifySecurityPasswordModal;

class _VerifySecurityPasswordModalState extends State<VerifySecurityPasswordModal> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _surfaceColor => _isDark ? const Color(0xFF101D31) : Colors.white;
  Color get _textColor => _isDark ? const Color(0xFFF2F5FA) : const Color(0xFF10264A);
  Color get _mutedColor => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF62738E);
  Color get _borderColor => _isDark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0);
  Color get _fieldBg => _isDark ? const Color(0xFF16253D) : _bgLight;
  Color get _fieldBorder => _errorMessage != null
      ? _redAccent
      : (_isDark ? const Color(0xFF2A3A53) : const Color(0xFFCBD5E1));

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleVerify() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Password cannot be empty';
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _handleBiometricAuth() async {
    final bio = widget.biometricSignIn ?? BiometricSignIn.instance;
    try {
      final authenticated = await bio.authenticate(
        localizedReason: 'Authenticate to access Security Center',
      );
      if (authenticated && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      // Fallback or ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top drag handle bar (40x4px pill, rounded)
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header top row with shield badge and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _isDark ? const Color(0xFF162744) : _blueLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _brokerGold.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.shieldCheck,
                            color: _brokerGold,
                            size: 22,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop(false);
                        },
                        icon: Icon(
                          LucideIcons.x,
                          color: _mutedColor,
                          size: 20,
                        ),
                        splashRadius: 20,
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title & Subtitle
                  Text(
                    'Security Verification',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter your CRM password to access Security Center.',
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Label: "CRM Password"
                  Text(
                    'CRM Password',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Password input container
                  Container(
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _fieldBorder,
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: _textColor, fontSize: 14),
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      onSubmitted: (_) => _handleVerify(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          LucideIcons.lockKeyhole,
                          color: _mutedColor,
                          size: 18,
                        ),
                        hintText: 'Enter your current password',
                        hintStyle: TextStyle(
                          color: _mutedColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                            color: _mutedColor,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: _redAccent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  // Fingerprint shortcut only if available on device and enabled by user
                  if (widget.isBiometricAvailable && widget.isBiometricEnabled) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _handleBiometricAuth,
                      icon: Icon(
                        LucideIcons.fingerprint,
                        size: 18,
                        color: _isDark ? const Color(0xFF60A5FA) : _bluePrimary,
                      ),
                      label: Text(
                        'Use Fingerprint instead',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isDark ? const Color(0xFF60A5FA) : _bluePrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        side: BorderSide(
                          color: _isDark ? const Color(0xFF2A3A53) : const Color(0xFFDCE5F1),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // Action button: "Verify & Continue"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _bluePrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Verify & Continue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(LucideIcons.arrowRight, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Security footnote
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isDark ? const Color(0xFF1E3A5F) : _blueLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(LucideIcons.shieldCheck, color: _bluePrimary, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Protected by 256-bit encryption. Your password is not stored.',
                          style: TextStyle(
                            color: _mutedColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

  Future<void> _showChangeLoginPassword() async {
    final bio = widget.biometricSignIn ?? BiometricSignIn.instance;
    bool available = false;
    bool enabled = false;
    try {
      available = await bio.isAvailable();
      enabled = await bio.isEnabled();
    } catch (_) {}
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => _ChangeLoginPasswordSheet(
        biometricSignIn: bio,
        isBiometricAvailable: available,
        isBiometricEnabled: enabled,
      ),
    );
  }
}

class _ChangeLoginPasswordSheet extends StatefulWidget {
  const _ChangeLoginPasswordSheet({
    required this.biometricSignIn,
    required this.isBiometricAvailable,
    required this.isBiometricEnabled,
  });
  final BiometricSignIn biometricSignIn;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;

  @override
  State<_ChangeLoginPasswordSheet> createState() => _ChangeLoginPasswordSheetState();
}

class _ChangeLoginPasswordSheetState extends State<_ChangeLoginPasswordSheet> {
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  int _step = 0;
  bool _busy = false;
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  String? _error;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _text => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _field => _dark ? const Color(0xFF16253D) : const Color(0xFFF4F7FC);

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _verifyPassword() {
    if (_current.text.trim().isEmpty) {
      setState(() => _error = 'Enter your current password.');
      return;
    }
    // This is a UI preview only: no password-verification service is connected.
    setState(() { _error = null; _step = 1; });
  }

  Future<void> _verifyBiometric() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      final ok = await widget.biometricSignIn.authenticate(
        localizedReason: 'Verify your identity to change your login password',
      );
      if (!mounted) return;
      if (ok) {
        setState(() => _step = 1);
      } else {
        setState(() => _error = 'Biometric verification was not completed.');
      }
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Biometric verification failed.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Biometric verification failed. Try your password.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _continue() {
    if (_newPassword.text.length < 8) {
      setState(() => _error = 'Use at least 8 characters for your new password.');
    } else if (_newPassword.text != _confirm.text) {
      setState(() => _error = 'The new passwords do not match.');
    } else if (_current.text.isNotEmpty && _newPassword.text == _current.text) {
      setState(() => _error = 'Choose a password different from your current password.');
    } else {
      setState(() { _error = null; _step = 2; });
    }
  }

  void _confirmChange() {
    // No account password is changed until a secure backend endpoint is connected.
    Navigator.of(context).pop();
    showAppMessage('Password change preview completed. No account password was changed.');
  }

  Widget _fieldInput(String label, String hint, TextEditingController controller, bool hidden, VoidCallback toggle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w700)),
      const SizedBox(height: 7),
      Container(
        decoration: BoxDecoration(
          color: _field,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _dark ? const Color(0xFF2A3A53) : const Color(0xFFCBD5E1)),
        ),
        child: TextField(
          controller: controller,
          obscureText: hidden,
          style: TextStyle(color: _text, fontSize: 14),
          onChanged: (_) { if (_error != null) setState(() => _error = null); },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _muted, fontSize: 13),
            prefixIcon: Icon(LucideIcons.lockKeyhole, color: _muted, size: 18),
            suffixIcon: IconButton(onPressed: toggle, icon: Icon(hidden ? LucideIcons.eye : LucideIcons.eyeOff, color: _muted, size: 18)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final title = _step == 0 ? 'Verify your identity' : _step == 1 ? 'Set your new password' : 'Confirm password change';
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: _dark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: _muted.withValues(alpha: .35), borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 18),
              Row(children: [
                const Icon(LucideIcons.shieldCheck, color: _bluePrimary, size: 24),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Change Login Password', style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800)),
                  Text(title, style: TextStyle(color: _muted, fontSize: 12)),
                ])),
                IconButton(onPressed: () => Navigator.pop(context), icon: Icon(LucideIcons.x, color: _muted)),
              ]),
              const SizedBox(height: 16),
              Row(children: List.generate(3, (i) => Expanded(child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                decoration: BoxDecoration(color: i <= _step ? _blueRoyal : (_dark ? const Color(0xFF2A3A53) : const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
              )))),
              const SizedBox(height: 18),
              if (_step == 0) ...[
                Text('Verify your identity before changing your login password.', style: TextStyle(color: _muted, fontSize: 13, height: 1.45)),
                const SizedBox(height: 16),
                _fieldInput('Current password', 'Enter your current password', _current, _hideCurrent, () => setState(() => _hideCurrent = !_hideCurrent)),
                if (widget.isBiometricAvailable && widget.isBiometricEnabled) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _verifyBiometric,
                    icon: const Icon(LucideIcons.fingerprint, size: 19),
                    label: const Text('Use Fingerprint / Face ID instead'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                  ),
                ],
              ] else if (_step == 1) ...[
                Text('Enter a new password and confirm it below.', style: TextStyle(color: _muted, fontSize: 13, height: 1.45)),
                const SizedBox(height: 16),
                _fieldInput('New password', 'At least 8 characters', _newPassword, _hideNew, () => setState(() => _hideNew = !_hideNew)),
                const SizedBox(height: 13),
                _fieldInput('Confirm new password', 'Re-enter your new password', _confirm, _hideConfirm, () => setState(() => _hideConfirm = !_hideConfirm)),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: _dark ? const Color(0xFF142B25) : _greenLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: _dark ? const Color(0xFF245B43) : _greenBorder)),
                  child: Row(children: [
                    const Icon(LucideIcons.shieldCheck, color: _greenAccent, size: 22),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Your new password and confirmation match.', style: TextStyle(color: _text, fontSize: 13, height: 1.4))),
                  ]),
                ),
                const SizedBox(height: 12),
                Text('This is a preview flow. The account password will not change until the secure password update service is connected.', style: TextStyle(color: _muted, fontSize: 12, height: 1.4)),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: _redAccent, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 18),
              SizedBox(height: 50, child: FilledButton(
                onPressed: _busy ? null : _step == 0 ? _verifyPassword : _step == 1 ? _continue : _confirmChange,
                style: FilledButton.styleFrom(backgroundColor: _bluePrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(_step == 0 ? 'Verify & Continue' : _step == 1 ? 'Continue' : 'Confirm Password Change', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              )),
              if (_step > 0) TextButton(onPressed: () => setState(() { _step--; _error = null; }), child: const Text('Back')),
              Text('Your password is never displayed in plain text.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 11)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _SecurityReferenceSubPage extends StatelessWidget {
  const _SecurityReferenceSubPage({required this.title, this.content});
  final String title;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurfaceVariant;
    final surface = dark ? scheme.surface : const Color(0xFFF5F8FF);
    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          if (title == 'Device Management') ...[
            if (content != null) content!,
            if (content == null) ...[
            for (final device in const [
              ('Android / App 2.19.1', 'Current Device', 'Logged In', 'Primary Device', '2026/10/29 12:16:30', '210.18.*.*', 'India Chennai', '968200012202147840', true),
              ('Windows / Chrome 153.0.0.0', 'Logged Out', '', '', '2026/09/26 16:14:54', '2a00:f29:10e0:31ec:947:e027:***:*', 'United Arab Emirates Dubai', '961725672053043200', false),
              ('Windows / Edge 153.0.0.0', 'Logged Out', '', '', '2026/09/26 10:30:18', '210.18.*.*', 'India Chennai', '962373710482104320', false),
              ('Windows / Edge 153.0.0.0', 'Logged Out', '', '', '2026/09/25 15:42:02', '210.18.*.*', 'India Chennai', '962088947942121472', false),
            ]) _subCard(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 58, height: 58, decoration: BoxDecoration(color: device.$9 ? const Color(0xFFE3FFF3) : const Color(0xFFEAF1FF), borderRadius: BorderRadius.circular(16)), child: Icon(device.$9 ? LucideIcons.smartphone : LucideIcons.monitor, color: device.$9 ? const Color(0xFF00B96B) : const Color(0xFF245BFF), size: 29)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(device.$1, style: TextStyle(color: scheme.onSurface, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    _tag(device.$2, device.$9 ? const Color(0xFFE0FFF1) : const Color(0xFFFFF0F0), device.$9 ? const Color(0xFF00B96B) : const Color(0xFFFF3152)),
                    if (device.$3.isNotEmpty) _tag(device.$3, const Color(0xFFEAF1FF), const Color(0xFF245BFF)),
                    if (device.$4.isNotEmpty) _tag(device.$4, const Color(0xFFE0FFF1), const Color(0xFF00B96B)),
                  ]),
                  const SizedBox(height: 6),
                  Text(device.$5, style: TextStyle(color: muted, fontSize: 11)),
                ])),
              ]),
              const Divider(height: 24),
              _dateRow('IP', device.$6, muted),
              const SizedBox(height: 12),
              _dateRow('Region', device.$7, muted),
              const SizedBox(height: 12),
              _dateRow('Device ID', device.$8, muted),
              if (!device.$9) ...[
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: _dangerButton(context, 'Remove', () => _message(context, 'Device removal is not connected yet.'))),
              ],
            ])),
            ],
          ] else if (title == 'Account Management') ...[
            _subCard(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFE8E8), borderRadius: BorderRadius.circular(13)), child: const Icon(LucideIcons.shieldAlert, color: Color(0xFFFF1744), size: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Account status', style: TextStyle(color: scheme.onSurface, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Manage access to your VTIndex account', style: TextStyle(color: muted, fontSize: 12)),
                ])),
                _tag('Active', const Color(0xFFE0FFF1), const Color(0xFF00A968)),
              ]),
            ])),
            _subCard(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Deactivate account', style: TextStyle(color: scheme.onSurface, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              Text('Temporarily suspend access. You can request reactivation later, subject to account verification.', style: TextStyle(color: muted, fontSize: 13, height: 1.45)),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: _actionButton(context, 'Request Deactivation', () => _confirmAccountRequest(context, deactivate: true))),
            ])),
            _subCard(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Delete account', style: const TextStyle(color: Color(0xFFFF1744), fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 7),
              Text('Permanently close your account. Deletion may result in loss of access to account history and services.', style: TextStyle(color: muted, fontSize: 13, height: 1.45)),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: _dangerButton(context, 'Request Account Deletion', () => _confirmAccountRequest(context, deactivate: false))),
            ])),
            Text('Both actions are submitted as requests and require review. No account change occurs from this preview.', style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
          ] else ...[
            _subCard(context, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recent account activity', style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              Text('No account log records are connected in this preview.', style: TextStyle(color: muted, fontSize: 13)),
            ])),
          ],
        ],
      ),
    );
  }


  static Future<void> _confirmAccountRequest(BuildContext context, {required bool deactivate}) async {
    final title = deactivate ? 'Confirm deactivation request' : 'Confirm account deletion request';
    final description = deactivate
        ? 'Your account access may be temporarily suspended after the request is reviewed. Do you want to submit a deactivation request?'
        : 'Account deletion is permanent once approved and may remove access to your account data. Do you want to submit a deletion request?';
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
        decoration: BoxDecoration(
          color: Theme.of(sheetContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Theme.of(sheetContext).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(8)))),
            const SizedBox(height: 22),
            Row(children: [
              Icon(deactivate ? LucideIcons.pauseCircle : LucideIcons.trash2, color: const Color(0xFFFF3152), size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: TextStyle(color: Theme.of(sheetContext).colorScheme.onSurface, fontSize: 17, fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 12),
            Text(description, style: TextStyle(color: Theme.of(sheetContext).colorScheme.onSurfaceVariant, fontSize: 13, height: 1.5)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheetContext, false), child: const Text('Cancel'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF3152)),
                onPressed: () => Navigator.pop(sheetContext, true),
                child: const Text('Confirm Request'),
              )),
            ]),
          ]),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(deactivate
            ? 'Deactivation request preview confirmed. No request was sent.'
            : 'Deletion request preview confirmed. No request was sent.'),
      ));
    }
  }

  static Widget _subCard(BuildContext context, Widget child) => Container(
    width: double.infinity, margin: const EdgeInsets.only(bottom: 18), padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18)),
    child: child,
  );

  static Widget _tag(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
    child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  static Widget _dateRow(String label, String value, Color muted) => Row(children: [
    Expanded(child: Text(label, style: TextStyle(color: muted, fontSize: 13))),
    Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
  ]);

  static Widget _actionButton(BuildContext context, String label, VoidCallback onTap) => SizedBox(height: 46, child: FilledButton.tonal(onPressed: onTap, style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(label, textAlign: TextAlign.center)));

  static Widget _dangerButton(BuildContext context, String label, VoidCallback onTap) => SizedBox(height: 48, child: FilledButton(onPressed: onTap, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFFE4E4), foregroundColor: const Color(0xFFFF1744), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(label)));

  static void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
