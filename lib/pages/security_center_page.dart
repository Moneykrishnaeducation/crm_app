import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../app_notifications.dart';
import '../biometric_sign_in.dart';
import '../services/auth_api.dart';

// VT Index & Revolut-tier Fintech Design System Colors
const _navyCardDark = Color(0xFF0F1E36);
const _brokerGold = Color(0xFFF4C84A);
const _goldAccent = Color(0xFFB18418);
const _goldLight = Color(0xFFFFF7E3);
const _goldBorder = Color(0xFFF0DFAF);

const _blueRoyal = Color(0xFF0875F5);
const _bluePrimary = Color(0xFF174A8B);
const _blueLight = Color(0xFFEAF2FC);

const _greenAccent = Color(0xFF16845B);
const _greenLight = Color(0xFFEAF7EF);
const _greenBorder = Color(0xFF86EFAC);

const _redAccent = Color(0xFFDC2626);

const _bgLight = Color(0xFFF4F7FC);

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
      showAppMessage(
        'Biometric verification not completed. Verify with password.',
      );
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
  bool _email2faEnabled = false;
  bool _securitySettingsLoading = true;
  bool _biometricEnabled = false;
  String _emailAddress = '';
  bool _emailLoading = true;
  List<Map<String, dynamic>> _trustedDevices = [];
  bool _devicesLoading = false;
  String? _devicesError;
  final ValueNotifier<int> _devicePageRevision = ValueNotifier<int>(0);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _textColor =>
      _isDark ? const Color(0xFFF2F5FA) : const Color(0xFF10264A);
  Color get _mutedColor =>
      _isDark ? const Color(0xFF94A3B8) : const Color(0xFF62738E);

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
    unawaited(_loadProfileEmail());
    unawaited(_loadSecuritySettings());
  }

  @override
  void dispose() {
    _devicePageRevision.dispose();
    super.dispose();
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final results = await Future.wait([
        AuthApi.instance.getCaptchaSettings(),
        AuthApi.instance.getTwoFactorSettings(),
      ]);
      if (!mounted) return;
      setState(() {
        _loginCaptchaEnabled = _readEnabled(
          results[0],
          fallback: _loginCaptchaEnabled,
        );
        _email2faEnabled = _readEnabled(results[1], fallback: _email2faEnabled);
      });
    } catch (_) {
      // Settings remain editable locally if the API is unavailable.
    } finally {
      if (mounted) {
        setState(() => _securitySettingsLoading = false);
      }
    }
  }

  Future<void> _loadProfileEmail() async {
    try {
      final response = await AuthApi.instance.getProfile();
      dynamic value = response;
      String email = '';
      for (var depth = 0; depth < 4 && value is Map; depth++) {
        final profile = value.cast<String, dynamic>();
        final candidate = profile['email'] ?? profile['email_address'];
        if (candidate != null && candidate.toString().trim().isNotEmpty) {
          email = candidate.toString().trim();
          break;
        }
        value = profile['user'] ?? profile['profile'] ?? profile['data'];
      }
      if (mounted) setState(() => _emailAddress = email);
    } catch (error) {
      debugPrint('Security Center email load failed: $error');
      if (mounted) setState(() => _emailAddress = '');
    } finally {
      if (mounted) setState(() => _emailLoading = false);
    }
  }

  bool _readEnabled(Map<String, dynamic> response, {required bool fallback}) {
    for (final key in const [
      'enabled',
      'is_enabled',
      'captcha_enabled',
      'two_factor_enabled',
      'require_otp',
      'require_captcha_at_login',
      'require_email_otp_at_login',
    ]) {
      final value =
          response[key] ??
          (response['data'] is Map ? (response['data'] as Map)[key] : null);
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
    }
    return fallback;
  }

  Future<void> _updateCaptchaSetting(bool value) async {
    final previous = _loginCaptchaEnabled;
    setState(() => _loginCaptchaEnabled = value);
    try {
      await AuthApi.instance.setCaptchaSettings(value);
      _showSnack('Login CAPTCHA setting updated');
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _loginCaptchaEnabled = previous);
      _showSnack(error.message);
    } catch (_) {
      if (mounted) setState(() => _loginCaptchaEnabled = previous);
      _showSnack('Could not update CAPTCHA settings.');
    }
  }

  Future<void> _updateTwoFactorSetting(bool value) async {
    final previous = _email2faEnabled;
    setState(() => _email2faEnabled = value);
    try {
      await AuthApi.instance.setTwoFactorSettings(value);
      _showSnack('Email OTP setting updated');
    } on AuthApiException catch (error) {
      if (mounted) setState(() => _email2faEnabled = previous);
      _showSnack(error.message);
    } catch (_) {
      if (mounted) setState(() => _email2faEnabled = previous);
      _showSnack('Could not update email OTP settings.');
    }
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
            ? (isHighlighted
                  ? _brokerGold.withValues(alpha: 0.35)
                  : const Color(0xFF1E3554))
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
    return Container(
      color: _isDark ? const Color(0xFF081526) : const Color(0xFFF4F7FC),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 112),
                children: [
                  _buildSecurityIntro(),
                  const SizedBox(height: 22),
                  _securitySectionLabel('ACCOUNT SECURITY'),
                  const SizedBox(height: 10),
                  _securityPanel([
                    _securityActionRow(
                      title: 'Email address',
                      subtitle: 'Your registered account email',
                      trailing: _emailLoading
                          ? 'Loading...'
                          : _emailAddress.isNotEmpty
                          ? _emailAddress
                          : 'Unavailable',
                      icon: LucideIcons.mail,
                      onTap: null,
                    ),
                    _securityActionRow(
                      title: 'Login password',
                      subtitle: 'Update your password regularly',
                      trailing: 'Change',
                      trailingColor: _brokerGold,
                      icon: LucideIcons.lockKeyhole,
                      onTap: _showChangeLoginPassword,
                    ),
                    AppSkeletonizer(
                      enabled: _securitySettingsLoading,
                      child: Column(
                        children: [
                          _securityToggleRow(
                            title: 'Mail OTP',
                            subtitle:
                                'One-time sign-in code sent to your email',
                            value: _email2faEnabled,
                            icon: LucideIcons.mailCheck,
                            onChanged: _updateTwoFactorSetting,
                          ),
                          _securityToggleRow(
                            title: 'Captcha',
                            subtitle:
                                'Additional check during account sign-in',
                            value: _loginCaptchaEnabled,
                            icon: LucideIcons.scanFace,
                            onChanged: _updateCaptchaSetting,
                          ),
                        ],
                      ),
                    ),
                    _securityToggleRow(
                      title: 'Biometrics',
                      subtitle: 'Use fingerprint or Face ID on this device',
                      value: _biometricEnabled,
                      icon: LucideIcons.fingerprint,
                      onChanged: _toggleBiometric,
                      showDivider: false,
                    ),
                  ]),
                  const SizedBox(height: 22),
                  _securitySectionLabel('DEVICE & ACCOUNT'),
                  const SizedBox(height: 10),
                  _securityPanel([
                    _securityActionRow(
                      title: 'Device Management',
                      subtitle:
                          'Review devices that have accessed your account',
                      trailing: '',
                      icon: LucideIcons.monitorSmartphone,
                      onTap: () => _openSecuritySubPage('Device Management'),
                    ),
                    _securityActionRow(
                      title: 'Account Management',
                      subtitle: 'Manage account status and closure requests',
                      trailing: '',
                      icon: LucideIcons.userRoundCog,
                      onTap: () => _openSecuritySubPage('Account Management'),
                      showDivider: false,
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(LucideIcons.info, size: 14, color: _mutedColor),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Keep your contact details current and enable multiple sign-in protections for better account security.',
                          style: TextStyle(
                            color: _mutedColor,
                            fontSize: 11.5,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityIntro() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123B70), Color(0xFF0A2850), Color(0xFF071C38)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _brokerGold.withValues(alpha: .55), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2010244A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _brokerGold.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _brokerGold.withValues(alpha: .65)),
                ),
                child: const Icon(
                  LucideIcons.shieldCheck,
                  color: _brokerGold,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protect your account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.25,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your sign-in and device security',
                      style: TextStyle(
                        color: Color(0xFFD6E3F4),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.shieldCheck,
                color: _brokerGold.withValues(alpha: .9),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: .13)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: _brokerGold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Security settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'REVIEW REGULARLY',
                  style: TextStyle(
                    color: _brokerGold,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _securityPanel(List<Widget> children) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
    decoration: BoxDecoration(
      color: _isDark ? const Color(0xFF101F33) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: _isDark ? const Color(0xFF263B57) : const Color(0xFFE1E9F3),
      ),
      boxShadow: [
        BoxShadow(
          color: _isDark
              ? Colors.black.withValues(alpha: .12)
              : const Color(0x0B17365C),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _securitySectionLabel(String title) => Row(
    children: [
      Container(
        width: 4,
        height: 16,
        decoration: BoxDecoration(
          color: _brokerGold,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 9),
      Text(
        title,
        style: TextStyle(
          color: _mutedColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.05,
        ),
      ),
    ],
  );

  Widget _securityToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    bool showDivider = true,
  }) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      border: showDivider
          ? Border(
              bottom: BorderSide(
                color: _isDark
                    ? const Color(0xFF26384F)
                    : const Color(0xFFEDF1F6),
                width: .8,
              ),
            )
          : null,
    ),
    child: Row(
      children: [
        _securityLeadingIcon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _mutedColor,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch.adaptive(
          value: value,
          onChanged: (newValue) {
            AppHaptics.selectionClick();
            onChanged(newValue);
          },
          activeThumbColor: _brokerGold,
          activeTrackColor: _blueRoyal,
        ),
      ],
    ),
  );

  Widget _securityActionRow({
    required String title,
    required String trailing,
    String? subtitle,
    Color? trailingColor,
    required VoidCallback? onTap,
    required IconData icon,
    bool showDivider = true,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: _isDark
                      ? const Color(0xFF26384F)
                      : const Color(0xFFEDF1F6),
                  width: .8,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          _securityLeadingIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing.isNotEmpty || onTap != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      trailing,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: trailingColor ?? _mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (onTap != null) ...[
                  const SizedBox(width: 7),
                  Icon(LucideIcons.chevronRight, color: _brokerGold, size: 19),
                ],
              ],
            ),
        ],
      ),
    ),
  );

  Widget _securityLeadingIcon(IconData icon) => Container(
    width: 39,
    height: 39,
    decoration: BoxDecoration(
      color: _isDark ? const Color(0xFF1A3555) : const Color(0xFFEAF2FC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: _isDark ? const Color(0xFF345274) : const Color(0xFFD6E4F5),
      ),
    ),
    child: Icon(
      icon,
      color: _isDark ? const Color(0xFF9BC5F4) : _bluePrimary,
      size: 18,
    ),
  );

  Future<void> _openSecuritySubPage(String page) async {
    if (page == 'Device Management') {
      unawaited(_loadTrustedDevices());
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _SecurityReferenceSubPage(
          title: page,
          content: page == 'Device Management'
              ? ValueListenableBuilder<int>(
                  valueListenable: _devicePageRevision,
                  builder: (context, revision, child) =>
                      _buildLiveTrustedDevicesContent(),
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _loadTrustedDevices() async {
    if (mounted) {
      setState(() {
        _devicesLoading = true;
        _devicesError = null;
      });
      _devicePageRevision.value++;
    }
    try {
      final response = await AuthApi.instance.getTrustedDevices();
      final raw = response['devices'] ??
          (response['data'] is Map
              ? (response['data'] as Map)['devices']
              : null);
      final devices = raw is List
          ? raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList()
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _trustedDevices = devices;
        _devicesLoading = false;
      });
      _devicePageRevision.value++;
    } on AuthApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _devicesError = error.message;
        _devicesLoading = false;
      });
      _devicePageRevision.value++;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _devicesError = 'Could not load trusted devices.';
        _devicesLoading = false;
      });
      _devicePageRevision.value++;
    }
  }

  Widget _buildLiveTrustedDevicesContent() {
    final activeDevices = _trustedDevices
        .where((device) => device['status'] == 'trusted')
        .toList();
    final activeDeviceLabel = activeDevices.length == 1
        ? '1 active device'
        : '${activeDevices.length} active devices';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trusted devices',
                      style: TextStyle(color: _textColor, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(activeDeviceLabel,
                      style: TextStyle(color: _mutedColor, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Refresh devices',
              onPressed: _devicesLoading ? null : _loadTrustedDevices,
              icon: const Icon(LucideIcons.refreshCw),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_devicesLoading)
          AppSkeletonizer(
            enabled: true,
            child: Column(
              children: [
                for (var index = 0; index < 2; index++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: _insetCardDecoration(),
                    child: const Row(
                      children: [
                        SizedBox(width: 40, height: 40),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Trusted device'),
                              SizedBox(height: 4),
                              Text('Device details and last active time'),
                            ],
                          ),
                        ),
                        Text('TRUSTED'),
                      ],
                    ),
                  ),
              ],
            ),
          )
        else if (_devicesError != null)
          _deviceMessageCard(_devicesError!, action: TextButton(
            onPressed: _loadTrustedDevices,
            child: const Text('Try again'),
          ), icon: LucideIcons.triangleAlert, iconColor: _redAccent)
        else if (_trustedDevices.isEmpty)
          _deviceMessageCard(
            'No trusted devices are registered yet.',
            icon: LucideIcons.monitorSmartphone,
            action: OutlinedButton.icon(
              onPressed: _loadTrustedDevices,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Refresh devices'),
            ),
          )
        else
          ..._trustedDevices.map(_buildLiveDeviceCard),
        const SizedBox(height: 18),
        _buildSecurityFooterActions(),
      ],
    );
  }

  Widget _deviceMessageCard(
    String message, {
    Widget? action,
    IconData icon = LucideIcons.info,
    Color? iconColor,
  }) => Container(
    padding: const EdgeInsets.all(18),
    decoration: _insetCardDecoration(),
    child: Column(
      children: [
        Icon(icon, color: iconColor ?? _mutedColor, size: 26),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center,
            style: TextStyle(color: _mutedColor, fontSize: 13)),
        if (action != null) const SizedBox(height: 8),
        ?action,
      ],
    ),
  );

  Widget _buildLiveDeviceCard(Map<String, dynamic> device) {
    final id = int.tryParse('${device['id'] ?? ''}');
    final name = (device['device_name'] ?? 'Unknown device').toString();
    final type = (device['device_type'] ?? 'Device').toString();
    final status = (device['status'] ?? 'unknown').toString();
    final current = device['current'] == true;
    final ip = (device['ip_address'] ?? '').toString();
    final lastSeen = (device['last_seen_at'] ?? '').toString();
    final userAgent = (device['user_agent'] ?? '').toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _insetCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _securityLeadingIcon(type.toLowerCase().contains('mobile')
                  ? LucideIcons.smartphone
                  : LucideIcons.monitor),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(type, style: TextStyle(color: _mutedColor, fontSize: 11)),
                  ],
                ),
              ),
              _deviceStatusBadge(
                icon: status == 'trusted' ? LucideIcons.shieldCheck : LucideIcons.clock,
                label: status.toUpperCase(),
                background: status == 'trusted' ? _greenLight : _goldLight,
                foreground: status == 'trusted' ? _greenAccent : _goldAccent,
                border: status == 'trusted' ? _greenBorder : _goldBorder,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (current) _buildDeviceDetailRow(icon: LucideIcons.checkCircle2, label: 'Session:', value: 'Current device'),
          if (ip.isNotEmpty) _buildDeviceDetailRow(icon: LucideIcons.mapPin, label: 'IP address:', value: ip),
          if (lastSeen.isNotEmpty) _buildDeviceDetailRow(icon: LucideIcons.clock, label: 'Last active:', value: lastSeen),
          if (userAgent.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(userAgent, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _mutedColor, fontSize: 10, height: 1.35)),
          ],
          if (status == 'trusted' && id != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmRemoveDevice(deviceId: id),
                icon: const Icon(LucideIcons.shieldOff, size: 15),
                label: const Text('Revoke this device'),
              ),
            ),
          ],
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
            style: TextStyle(
              color: foreground,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveDevice({int? deviceId}) async {
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
                    color: _isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF382326)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.shieldAlert,
                  color: _redAccent,
                  size: 28,
                ),
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
      AppHaptics.heavyImpact();
      if (deviceId == null) {
        setState(() {
          _trustedDevices = [];
        });
        _showSnack('Trusted device removed');
        return;
      }
      try {
        await AuthApi.instance.revokeTrustedDevice(deviceId: deviceId);
        if (!mounted) return;
        await _loadTrustedDevices();
        if (!mounted) return;
        _showSnack('Trusted device revoked');
      } on AuthApiException catch (error) {
        _showSnack(error.message);
      } catch (_) {
        _showSnack('Could not revoke this device.');
      }
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
            Text(label, style: TextStyle(color: _mutedColor, fontSize: 12)),
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
                    color: _isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _isDark
                      ? const Color(0xFF382326)
                      : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.shieldAlert,
                  color: _redAccent,
                  size: 28,
                ),
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
      AppHaptics.heavyImpact();
      try {
        await AuthApi.instance.revokeTrustedDevice();
        if (!mounted) return;
        setState(() {
          _trustedDevices = [];
        });
        Navigator.of(context).pop();
        _showSnack('All trusted devices have been revoked');
      } on AuthApiException catch (error) {
        _showSnack(error.message);
      } catch (_) {
        _showSnack('Could not revoke trusted devices.');
      }
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
              color: _isDark
                  ? const Color(0xFF382326)
                  : const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isDark
                    ? const Color(0xFF693B42)
                    : const Color(0xFFFCA5A5),
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

  Future<void> _showChangeLoginPassword() async {
    final biometricSignIn = widget.biometricSignIn ?? BiometricSignIn.instance;
    final draft = await showModalBottomSheet<_PasswordDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => _NewPasswordFormSheet(
        biometricSignIn: biometricSignIn,
        emailAddress: _emailAddress,
      ),
    );
    if (!mounted || draft == null) return;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const _PasswordChangeConfirmSheet(),
    );
    if (!mounted || confirmed != true) return;

    try {
      await AuthApi.instance.changeClientLoginPassword(
        currentPassword: draft.currentPassword,
        newPassword: draft.newPassword,
        confirmPassword: draft.newPassword,
      );
      try {
        await biometricSignIn.rememberSessionCredentials(
          identifier: draft.identifier ?? _emailAddress,
          password: draft.newPassword,
        );
      } catch (_) {
        if (mounted) {
          showAppMessage(
            'Password updated, but biometric sign-in credentials could not be refreshed.',
          );
        }
      }
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _PasswordChangeSuccessSheet(),
      );
    } catch (error) {
      if (mounted) showAppMessage(error.toString());
    }
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
  State<VerifySecurityPasswordModal> createState() =>
      _VerifySecurityPasswordModalState();
}

typedef VerifySecurityPasswordSheet = VerifySecurityPasswordModal;

class _VerifySecurityPasswordModalState
    extends State<VerifySecurityPasswordModal> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _surfaceColor => _isDark ? const Color(0xFF101D31) : Colors.white;
  Color get _textColor =>
      _isDark ? const Color(0xFFF2F5FA) : const Color(0xFF10264A);
  Color get _mutedColor =>
      _isDark ? const Color(0xFF94A3B8) : const Color(0xFF62738E);
  Color get _borderColor =>
      _isDark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0);
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                        color: _isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header top row with shield badge and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              LucideIcons.shield,
                              color: _blueRoyal,
                              size: 39,
                            ),
                            Positioned(
                              right: 5,
                              bottom: 7,
                              child: Icon(
                                LucideIcons.check,
                                color: _brokerGold,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          AppHaptics.lightImpact();
                          Navigator.of(context).pop(false);
                        },
                        icon: Icon(LucideIcons.x, color: _mutedColor, size: 20),
                        splashRadius: 20,
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title & Subtitle
                  Text(
                    'Verify your identity',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Confirm it is you before setting a new login password.',
                    style: TextStyle(
                      color: _mutedColor,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Label: "CRM Password"
                  Text(
                    'CURRENT PASSWORD',
                    style: TextStyle(
                      color: _textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .9,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Password input container
                  Container(
                    decoration: BoxDecoration(
                      color: _fieldBg,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _fieldBorder, width: 1.2),
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? LucideIcons.eye
                                : LucideIcons.eyeOff,
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
                  if (widget.isBiometricAvailable &&
                      widget.isBiometricEnabled) ...[
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
                          color: _isDark
                              ? const Color(0xFF60A5FA)
                              : _bluePrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        side: BorderSide(
                          color: _isDark
                              ? const Color(0xFF2A3A53)
                              : const Color(0xFFDCE5F1),
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
                          Icon(
                            LucideIcons.arrowRight,
                            size: 16,
                            color: Colors.white,
                          ),
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
                        child: const Icon(
                          LucideIcons.shieldCheck,
                          color: _bluePrimary,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Preview only: password verification is not connected to the authentication service.',
                          style: TextStyle(color: _mutedColor, fontSize: 12),
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

class _PasswordDraft {
  const _PasswordDraft(
    this.currentPassword,
    this.newPassword, {
    this.identifier,
  });
  final String currentPassword;
  final String newPassword;
  final String? identifier;
}

class _NewPasswordFormSheet extends StatefulWidget {
  const _NewPasswordFormSheet({
    required this.biometricSignIn,
    required this.emailAddress,
  });

  final BiometricSignIn biometricSignIn;
  final String emailAddress;

  @override
  State<_NewPasswordFormSheet> createState() => _NewPasswordFormSheetState();
}

class _NewPasswordFormSheetState extends State<_NewPasswordFormSheet> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();
  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _biometricAvailable = false;
  bool _biometricBusy = false;
  BiometricCredentials? _biometricCredentials;
  String? _error;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;
  Color get _text => Theme.of(context).colorScheme.onSurface;
  Color get _muted => Theme.of(context).colorScheme.onSurfaceVariant;
  Color get _outline =>
      _dark ? const Color(0xFF2A3A53) : const Color(0xFFDCE5F1);

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadBiometricAvailability());
    });
  }

  Future<void> _loadBiometricAvailability() async {
    try {
      final bio = widget.biometricSignIn;
      final enabled = await bio.isEnabled();
      final available = enabled && await bio.isAvailable();
      final hasCredentials = available && await bio.hasStoredCredentials();
      if (!mounted) return;
      setState(() => _biometricAvailable = hasCredentials);
      if (hasCredentials) await _verifyWithBiometrics();
    } catch (error) {
      debugPrint('Password change biometric availability check failed: $error');
      if (mounted) setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _verifyWithBiometrics() async {
    setState(() {
      _biometricBusy = true;
      _error = null;
    });
    try {
      final authenticated = await widget.biometricSignIn.authenticate(
        localizedReason: 'Verify your identity to change your login password',
      );
      if (!mounted) return;
      if (!authenticated) {
        setState(() => _error = 'Biometric verification was not completed.');
        return;
      }
      final credentials = await widget.biometricSignIn.readCredentials();
      if (!mounted) return;
      if (credentials == null) {
        setState(() {
          _error = 'No saved biometric login credentials were found. Enter your current password instead.';
        });
        return;
      }
      final email = widget.emailAddress.trim().toLowerCase();
      if (email.isNotEmpty &&
          credentials.identifier.contains('@') &&
          credentials.identifier.trim().toLowerCase() != email) {
        setState(() {
          _error = 'Saved biometric credentials belong to a different account. Enter your current password instead.';
        });
        return;
      }
      setState(() => _biometricCredentials = credentials);
    } catch (error) {
      debugPrint('Password change biometric verification failed: $error');
      if (mounted) {
        setState(
          () => _error = 'Biometric verification failed. Enter your current password instead.',
        );
      }
    } finally {
      if (mounted) setState(() => _biometricBusy = false);
    }
  }

  Widget _passwordField(
    String label,
    String hint,
    TextEditingController controller,
    bool hidden,
    VoidCallback toggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: _text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _dark ? const Color(0xFF16253D) : const Color(0xFFF4F7FC),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _outline),
          ),
          child: TextField(
            controller: controller,
            obscureText: hidden,
            style: TextStyle(color: _text, fontSize: 14),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: _muted, fontSize: 13),
              prefixIcon: Icon(
                LucideIcons.lockKeyhole,
                color: _muted,
                size: 18,
              ),
              suffixIcon: IconButton(
                onPressed: toggle,
                icon: Icon(
                  hidden ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: _muted,
                  size: 18,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _continue() {
    final credentials = _biometricCredentials;
    final currentPassword = credentials?.password ?? _currentPassword.text;
    if (currentPassword.isEmpty) {
      _showValidationError('Enter your current login password.');
    } else if (_newPassword.text.length < 8) {
      _showValidationError('Use at least 8 characters for your new password.');
    } else if (_newPassword.text != _confirm.text) {
      _showValidationError('The new passwords do not match.');
    } else {
      Navigator.of(context).pop(
        _PasswordDraft(
          currentPassword,
          _newPassword.text,
          identifier: credentials?.identifier,
        ),
      );
    }
  }

  void _showValidationError(String message) {
    AppHaptics.heavyImpact();
    setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(
            color: _dark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _muted.withValues(alpha: .35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF174A8B), Color(0xFF0B2C55)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _brokerGold),
                      ),
                      child: const Icon(
                        LucideIcons.lockKeyhole,
                        color: _brokerGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create a new password',
                            style: TextStyle(
                              color: _text,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Choose a strong password you have not used before',
                            style: TextStyle(color: _muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(LucideIcons.x, color: _muted),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _dark
                        ? const Color(0xFF162744)
                        : const Color(0xFFF2F6FC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.info,
                        color: _brokerGold,
                        size: 17,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Use at least 8 characters. A mix of letters, numbers and symbols is recommended.',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (_biometricCredentials == null) ...[
                  _passwordField(
                    'Current password',
                    'Enter your current CRM password',
                    _currentPassword,
                    _hideCurrent,
                    () => setState(() => _hideCurrent = !_hideCurrent),
                  ),
                  if (_biometricAvailable) ...[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _biometricBusy ? null : _verifyWithBiometrics,
                      icon: Icon(
                        LucideIcons.fingerprint,
                        size: 18,
                        color: _bluePrimary,
                      ),
                      label: Text(
                        _biometricBusy
                            ? 'Verifying...'
                            : 'Use biometrics instead',
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                _passwordField(
                  'New password',
                  'Enter your new password',
                  _newPassword,
                  _hideNew,
                  () => setState(() => _hideNew = !_hideNew),
                ),
                const SizedBox(height: 16),
                _passwordField(
                  'Confirm new password',
                  'Re-enter your new password',
                  _confirm,
                  _hideConfirm,
                  () => setState(() => _hideConfirm = !_hideConfirm),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        alignment: Alignment.topCenter,
                        child: child,
                      ),
                    ),
                    child: Text(
                      _error!,
                      key: ValueKey(_error),
                      style: const TextStyle(
                        color: _redAccent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: _bluePrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      side: const BorderSide(color: _brokerGold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordChangeConfirmSheet extends StatelessWidget {
  const _PasswordChangeConfirmSheet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: dark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const SizedBox(
              width: 66,
              height: 66,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(LucideIcons.shield, color: _blueRoyal, size: 53),
                  Positioned(
                    right: 9,
                    bottom: 11,
                    child: Icon(
                      LucideIcons.check,
                      color: _brokerGold,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Review password change',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are about to confirm a new login password for this account. Do you want to continue?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: BorderSide(
                        color: dark
                            ? const Color(0xFF40536D)
                            : const Color(0xFFCBD8E8),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: FilledButton.styleFrom(
                      backgroundColor: _bluePrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: _brokerGold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordChangeSuccessSheet extends StatelessWidget {
  const _PasswordChangeSuccessSheet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(
          color: dark ? const Color(0xFF23354E) : const Color(0xFFE2E8F0),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 66,
              height: 66,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(LucideIcons.circle, color: _bluePrimary, size: 52),
                  const Icon(LucideIcons.check, color: _brokerGold, size: 29),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Confirmation complete',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your login password has been updated successfully.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: _bluePrimary,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: _brokerGold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
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
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(LucideIcons.arrowLeft, color: scheme.onSurface, size: 21),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          if (title == 'Device Management') ...[
            ?content,
            if (content == null) ...[
              for (final device in const [
                (
                  'Android / App 2.19.1',
                  'Current Device',
                  'Logged In',
                  'Primary Device',
                  '2026/10/29 12:16:30',
                  '210.18.*.*',
                  'India Chennai',
                  '968200012202147840',
                  true,
                ),
                (
                  'Windows / Chrome 153.0.0.0',
                  'Logged Out',
                  '',
                  '',
                  '2026/09/26 16:14:54',
                  '2a00:f29:10e0:31ec:947:e027:***:*',
                  'United Arab Emirates Dubai',
                  '961725672053043200',
                  false,
                ),
                (
                  'Windows / Edge 153.0.0.0',
                  'Logged Out',
                  '',
                  '',
                  '2026/09/26 10:30:18',
                  '210.18.*.*',
                  'India Chennai',
                  '962373710482104320',
                  false,
                ),
                (
                  'Windows / Edge 153.0.0.0',
                  'Logged Out',
                  '',
                  '',
                  '2026/09/25 15:42:02',
                  '210.18.*.*',
                  'India Chennai',
                  '962088947942121472',
                  false,
                ),
              ])
                _subCard(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: device.$9
                                  ? const Color(0xFFE3FFF3)
                                  : const Color(0xFFEAF1FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              device.$9
                                  ? LucideIcons.smartphone
                                  : LucideIcons.monitor,
                              color: device.$9
                                  ? const Color(0xFF00B96B)
                                  : const Color(0xFF245BFF),
                              size: 29,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.$1,
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _tag(
                                      device.$2,
                                      device.$9
                                          ? const Color(0xFFE0FFF1)
                                          : const Color(0xFFFFF0F0),
                                      device.$9
                                          ? const Color(0xFF00B96B)
                                          : const Color(0xFFFF3152),
                                    ),
                                    if (device.$3.isNotEmpty)
                                      _tag(
                                        device.$3,
                                        const Color(0xFFEAF1FF),
                                        const Color(0xFF245BFF),
                                      ),
                                    if (device.$4.isNotEmpty)
                                      _tag(
                                        device.$4,
                                        const Color(0xFFE0FFF1),
                                        const Color(0xFF00B96B),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  device.$5,
                                  style: TextStyle(color: muted, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _dateRow('IP', device.$6, muted),
                      const SizedBox(height: 12),
                      _dateRow('Region', device.$7, muted),
                      const SizedBox(height: 12),
                      _dateRow('Device ID', device.$8, muted),
                      if (!device.$9) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: _dangerButton(
                            context,
                            'Remove',
                            () => _message(
                              context,
                              'Device removal is not connected yet.',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ] else if (title == 'Account Management') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF123B70),
                    Color(0xFF0A2850),
                    Color(0xFF071C38),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFF4C84A).withValues(alpha: .55),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1810244A),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              LucideIcons.shield,
                              color: Color(0xFFF4C84A),
                              size: 37,
                            ),
                            Positioned(
                              right: 5,
                              bottom: 7,
                              child: Icon(
                                LucideIcons.check,
                                color: Color(0xFF8FD9B5),
                                size: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Account status',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Your VTIndex account access',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .72),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const _AccountStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.info,
                          color: Color(0xFFF4C84A),
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your account remains active while a request is pending staff review.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .86),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account actions',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose how you want to manage account access',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.settings2,
                  color: Color(0xFFB18418),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _accountRequestRow(
              context,
              title: 'Deactivate account',
              subtitle: 'Temporarily suspend account access',
              icon: LucideIcons.pauseCircle,
              destructive: false,
              onTap: () => _confirmAccountRequest(context, deactivate: true),
            ),
            const SizedBox(height: 10),
            _accountRequestRow(
              context,
              title: 'Delete account',
              subtitle: 'Permanently close your account',
              icon: LucideIcons.trash2,
              destructive: true,
              onTap: () => _confirmAccountRequest(context, deactivate: false),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF18283D) : const Color(0xFFFFF8E8),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: dark
                      ? const Color(0xFF354760)
                      : const Color(0xFFF0DFAF),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.lockKeyhole,
                    color: Color(0xFFB18418),
                    size: 17,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Both actions require your CRM password. Requests are reviewed by our support team; your account remains active until approval.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _subCard(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent account activity',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No account log records are connected in this preview.',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _accountRequestRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool destructive,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = destructive
        ? const Color(0xFFE04452)
        : const Color(0xFF174A8B);
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: destructive
                  ? const Color(0xFFE04452).withValues(alpha: dark ? .42 : .24)
                  : (dark ? const Color(0xFF344A65) : const Color(0xFFDCE5F1)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? .10 : .035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: dark ? .18 : .09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: .16)),
                ),
                child: Icon(icon, color: accent, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: destructive ? accent : scheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: dark ? .16 : .08),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.chevronRight, color: accent, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _confirmAccountRequest(
    BuildContext context, {
    required bool deactivate,
  }) async {
    final title = deactivate
        ? 'Confirm deactivation request'
        : 'Confirm account deletion request';
    final description = deactivate
        ? 'Your account will remain active until the deactivation request is reviewed and approved.'
        : 'Account deletion is permanent once approved. Your account remains active while the request is pending.';
    final passwordController = TextEditingController();
    final reasonController = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(sheetContext).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'CRM login password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.lockKeyhole),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE04452),
                        ),
                        onPressed: () {
                          if (passwordController.text.isEmpty) {
                            showAppMessage('Enter your CRM login password.');
                            return;
                          }
                          Navigator.pop(sheetContext, true);
                        },
                        child: const Text('Submit request'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await AuthApi.instance.submitAccountClosureRequest(
          password: passwordController.text,
          reason: reasonController.text.trim(),
          requestType: deactivate ? 'deactivate' : 'delete',
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              deactivate
                  ? 'Deactivation request submitted for review.'
                  : 'Account deletion request submitted for review.',
            ),
          ),
        );
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
    passwordController.dispose();
    reasonController.dispose();
  }

  static Widget _subCard(BuildContext context, Widget child) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );

  static Widget _tag(String text, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );

  static Widget _dateRow(String label, String value, Color muted) => Row(
    children: [
      Expanded(
        child: Text(label, style: TextStyle(color: muted, fontSize: 13)),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );

  static Widget _dangerButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
  ) => SizedBox(
    height: 48,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFFFE4E4),
        foregroundColor: const Color(0xFFFF1744),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    ),
  );

  static void _message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}


class _AccountStatusBadge extends StatefulWidget {
  const _AccountStatusBadge();

  @override
  State<_AccountStatusBadge> createState() => _AccountStatusBadgeState();
}

class _AccountStatusBadgeState extends State<_AccountStatusBadge> {
  late Future<Map<String, dynamic>> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = AuthApi.instance.getAccountClosureRequest();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statusFuture,
      builder: (context, snapshot) {
        final request = snapshot.data?['request'];
        final status = request is Map ? request['status']?.toString() : null;
        final label = snapshot.hasError
            ? 'Status unavailable'
            : status == 'pending'
                ? 'Pending review'
                : status == 'approved'
                    ? 'Approved'
                    : status == 'rejected'
                        ? 'Rejected'
                        : 'Active';
        final active = status == null || status == 'rejected' || status == 'cancelled';
        final color = active ? const Color(0xFF6EE7B7) : const Color(0xFFF4C84A);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .65)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status == 'pending'
                    ? LucideIcons.clock3
                    : active
                        ? LucideIcons.checkCircle2
                        : LucideIcons.alertCircle,
                color: color,
                size: 13,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
