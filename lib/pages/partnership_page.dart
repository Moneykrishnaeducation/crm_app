import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_notifications.dart';

/// Centralized adaptive design tokens aligned with VTIndex Dashboard and Transactions
class _PartnershipColors {
  const _PartnershipColors({
    required this.isDark,
    required this.canvas,
    required this.card,
    required this.subCard,
    required this.border,
    required this.subBorder,
    required this.text,
    required this.muted,
    required this.navy,
    required this.blue,
    required this.gold,
    required this.green,
    required this.red,
    required this.cardShadow,
    required this.inputBg,
    required this.chipBg,
    required this.appBarBg,
  });

  final bool isDark;
  final Color canvas;
  final Color card;
  final Color subCard;
  final Color border;
  final Color subBorder;
  final Color text;
  final Color muted;
  final Color navy;
  final Color blue;
  final Color gold;
  final Color green;
  final Color red;
  final Color cardShadow;
  final Color inputBg;
  final Color chipBg;
  final Color appBarBg;

  factory _PartnershipColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _PartnershipColors(
      isDark: isDark,
      canvas: Theme.of(context).scaffoldBackgroundColor,
      card: isDark ? const Color(0xFF17243A) : Colors.white,
      subCard: isDark ? const Color(0xFF132238) : const Color(0xFFF3F6FB),
      border: isDark ? const Color(0xFF2A3A53) : const Color(0xFFE2E8F1),
      subBorder: isDark ? const Color(0xFF22354E) : const Color(0xFFEAF1FA),
      text: isDark ? const Color(0xFFF2F5FA) : const Color(0xFF10264B),
      muted: isDark ? const Color(0xFF94A3B8) : const Color(0xFF71809A),
      navy: isDark ? const Color(0xFF1E3A5F) : const Color(0xFF10264B),
      blue: const Color(0xFF174A8B),
      gold: const Color(0xFFD8A82E),
      green: const Color(0xFF13C7A1),
      red: const Color(0xFFEF4444),
      cardShadow: isDark ? const Color(0x33000000) : const Color(0x0A0B1D35),
      inputBg: isDark ? const Color(0xFF132238) : const Color(0xFFF3F6FB),
      chipBg: isDark ? const Color(0xFF1F2F4A) : const Color(0xFFEAF2FD),
      appBarBg: isDark ? const Color(0xFF101D31) : Colors.white,
    );
  }

  Color get glassFill => isDark
      ? const Color(0xCC17263B)
      : const Color(0xDFFFFFFF);
  Color get glassBorder => isDark
      ? const Color(0x663E5A7A)
      : const Color(0xBFFFFFFF);
  Color get accentGlow => isDark
      ? const Color(0xFF173B65)
      : const Color(0xFFD6E8FF);
}

class _PartnershipBackdrop extends StatelessWidget {
  const _PartnershipBackdrop({required this.colors, required this.child});

  final _PartnershipColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors.isDark
                      ? const [Color(0xFF0B1424), Color(0xFF101E32)]
                      : const [Color(0xFFF6F9FF), Color(0xFFEAF1FB)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -170,
            right: -120,
            child: _ambientOrb(colors.accentGlow),
          ),
          Positioned(
            bottom: 40,
            left: -210,
            child: _ambientOrb(colors.blue.withValues(alpha: .12)),
          ),
          child,
        ],
      );

  Widget _ambientOrb(Color color) => Container(
        width: 420,
        height: 420,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: .52), color.withValues(alpha: 0)],
          ),
        ),
      );
}

class _PartnershipGlassPanel extends StatelessWidget {
  const _PartnershipGlassPanel({
    required this.colors,
    required this.child,
    this.padding,
    this.radius = 20,
    this.fillColor,
    this.borderColor,
  });

  final _PartnershipColors colors;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? fillColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor ?? colors.glassFill,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: borderColor ?? colors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      );
}

const _partnerProfiles = <_PartnerProfile>[
  _PartnerProfile(name: 'Gold', code: 'X0RCGYVH7A', clients: 0),
  _PartnerProfile(name: 'Gold-80', code: 'UENYAZWK4', clients: 0),
  _PartnerProfile(name: 'Test', code: '4Z7G7TKF4J', clients: 0, primary: true),
  _PartnerProfile(name: 'test', code: 'IQ57TSDY38', clients: 0),
  _PartnerProfile(name: 'crm', code: '9BSFFEGGTL', clients: 0),
  _PartnerProfile(name: 'test3', code: '6F81L1IUK5', clients: 0),
];

class BrokerPartnershipPage extends StatefulWidget {
  const BrokerPartnershipPage({super.key});

  @override
  State<BrokerPartnershipPage> createState() => _BrokerPartnershipPageState();
}

class _BrokerPartnershipPageState extends State<BrokerPartnershipPage> {
  static const _partners = _partnerProfiles;

  int _selectedPartnerIndex = 2;
  _PartnerProfile get _selectedPartner => _partners[_selectedPartnerIndex];

  void _showReferralQr() {
    var modalPartnerIndex = _selectedPartnerIndex;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setModalState) {
          final colors = _PartnershipColors.of(sheetContext);
          final partner = _partners[modalPartnerIndex];
          final referralUrl = 'https://client.vtindex.com/?ref=${partner.code}';
          return SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.zero,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Referral QR Code',
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: Icon(
                            LucideIcons.x,
                            color: colors.muted,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: colors.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: modalPartnerIndex,
                          isExpanded: true,
                          dropdownColor: colors.card,
                          iconEnabledColor: colors.blue,
                          style: TextStyle(color: colors.text, fontSize: 12),
                          items: [
                            for (var i = 0; i < _partners.length; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text(
                                  '${_partners[i].name} – ${_partners[i].code}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (index) {
                            if (index != null) {
                              setModalState(() => modalPartnerIndex = index);
                              setState(() => _selectedPartnerIndex = index);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x120B1D35),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: referralUrl,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(color: Color(0xFF071941)),
                        dataModuleStyle: const QrDataModuleStyle(
                          color: Color(0xFF071941),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      partner.name,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SelectableText(
                      referralUrl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: referralUrl),
                              );
                              showAppMessage('Referral link copied');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.text,
                              side: BorderSide(color: colors.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(LucideIcons.copy, size: 15),
                            label: const Text('Copy link'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(
                                'https://wa.me/?text=${Uri.encodeComponent('Join my VT Index partner network: $referralUrl')}',
                              );
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(LucideIcons.share2, size: 15),
                            label: const Text('Share'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return _PartnershipBackdrop(
      colors: colors,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          final stats = Column(
            children: [
              _PartnershipStat(
                icon: LucideIcons.usersRound,
                label: 'Network clients',
                value: '2,458',
              ),
              SizedBox(height: wide ? 12 : 0),
              _PartnershipStat(
                icon: LucideIcons.coins,
                label: 'IB earnings',
                value: r'$4,820.00',
                gold: true,
              ),
            ],
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  wide ? 28 : 16,
                  24,
                  wide ? 28 : 16,
                  120,
                ),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colors.blue.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: colors.glassBorder),
                        ),
                        child: Icon(
                          LucideIcons.network,
                          color: colors.blue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Partnership',
                              style: TextStyle(
                                color: colors.text,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Grow your network and track partner earnings.',
                              style: TextStyle(color: colors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (wide)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colors.glassFill,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: colors.glassBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.badgeCheck,
                                color: colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'IB PARTNER',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .4,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildHeroCard(context, colors)),
                        const SizedBox(width: 14),
                        Expanded(flex: 3, child: stats),
                      ],
                    )
                  else ...[
                    _buildHeroCard(context, colors),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PartnershipStat(
                            icon: LucideIcons.usersRound,
                            label: 'Network clients',
                            value: '2,458',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _PartnershipStat(
                            icon: LucideIcons.coins,
                            label: 'IB earnings',
                            value: r'$4,820.00',
                            gold: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  _PartnershipSectionLabel(
                    'REFERRAL & INVITATIONS',
                    subtitle:
                        'Choose a partner profile, share your referral link, or explore your network.',
                    colors: colors,
                  ),
                  const SizedBox(height: 12),
                  _buildToolsColumn(context, colors),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, _PartnershipColors colors) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B2256),
            Color(0xFF0F3678),
            Color(0xFF144EA1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1D45).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -30,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2D72E2).withValues(alpha: 0.35),
                      const Color(0xFF144EA5).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 14 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x6610B981),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'PARTNERSHIP PROGRAM',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 8 : 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _showReferralQr,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.qrCode, color: Colors.white, size: 13),
                              SizedBox(width: 5),
                              Text(
                                'Referral QR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 18),
                  Text(
                    'Total IB Earnings',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: compact ? 10 : 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r'$4,820.00 USD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 22 : 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 18),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Network Clients',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: compact ? 9 : 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '2,458 Clients',
                              style: TextStyle(
                                color: colors.gold,
                                fontSize: compact ? 13 : 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Executed Volume',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: compact ? 9 : 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '142.80 Lots',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compact ? 13 : 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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

  Widget _buildToolsColumn(BuildContext context, _PartnershipColors colors) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _PartnershipGlassPanel(
        colors: colors,
        padding: const EdgeInsets.all(18),
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.share2, color: colors.blue, size: 17),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your partner code',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share this code to invite and onboard new clients.',
                        style: TextStyle(color: colors.muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'SELECT PARTNER PROFILE',
              style: TextStyle(
                color: colors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.subCard,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: colors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedPartnerIndex,
                  isDense: true,
                  isExpanded: true,
                  dropdownColor: colors.card,
                  iconEnabledColor: colors.blue,
                  style: TextStyle(color: colors.text, fontSize: 12.5),
                  items: [
                    for (var i = 0; i < _partners.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          '${_partners[i].name} – ${_partners[i].code}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (index) {
                    if (index != null) {
                      setState(() => _selectedPartnerIndex = index);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: colors.subCard,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.link,
                    color: colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INVITATION CODE',
                          style: TextStyle(
                            color: colors.muted,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          _selectedPartner.code,
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy referral link',
                    constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                    onPressed: () async {
                      final url = 'https://client.vtindex.com/?ref=${_selectedPartner.code}';
                      await Clipboard.setData(ClipboardData(text: url));
                      showAppMessage('Referral link copied');
                    },
                    icon: Icon(
                      LucideIcons.copy,
                      color: colors.muted,
                      size: 18,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Show referral QR code',
                    constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                    onPressed: _showReferralQr,
                    icon: Icon(
                      LucideIcons.qrCode,
                      color: colors.blue,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _showReferralQr,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                icon: const Icon(LucideIcons.qrCode, size: 17),
                label: const Text('Show referral QR'),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      Text(
        'Quick shortcuts',
        style: TextStyle(
          color: colors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      _PartnershipShortcut(
        icon: LucideIcons.usersRound,
        label: 'Client list',
        subtitle: 'View network hierarchy, downline tiers, and accounts',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const BrokerClientTreePage()),
        ),
      ),
      const SizedBox(height: 8),
      _PartnershipShortcut(
        icon: LucideIcons.layers,
        label: 'Commission ledger',
        subtitle: 'Detailed trading deal records and commission generated',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BrokerCommissionLedgerPage(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      _PartnershipShortcut(
        icon: LucideIcons.qrCode,
        label: 'Referral & QR studio',
        subtitle: 'Custom marketing links, materials, and branded cards',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BrokerReferralStudioPage(),
          ),
        ),
      ),
      const SizedBox(height: 8),
      _PartnershipShortcut(
        icon: LucideIcons.wallet,
        label: 'Commission withdrawal',
        subtitle: 'Instant internal transfer to your live MT5 trading account',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const BrokerCommissionWithdrawalPage(),
          ),
        ),
      ),
    ],
  );
}

class BrokerReferralStudioPage extends StatefulWidget {
  const BrokerReferralStudioPage({super.key});
  @override
  State<BrokerReferralStudioPage> createState() =>
      _BrokerReferralStudioPageState();
}

class _BrokerReferralStudioPageState extends State<BrokerReferralStudioPage> {
  static const routes = <_ReferralRoute>[
    _ReferralRoute('Gold', 'X0RCGYVH7A'),
    _ReferralRoute('Gold-80', 'UENYAZWK4'),
    _ReferralRoute('Test', '4Z7G7TKF4J'),
    _ReferralRoute('test', 'IQ57TSDY38'),
    _ReferralRoute('crm', '9BSFFEGGTL'),
    _ReferralRoute('test3', '6F81L1IUK5'),
    _ReferralRoute('INR IB-LIVE', 'INRIBLIVE01'),
  ];
  int selected = 2;
  _ReferralRoute get route => routes[selected];
  String get referralUrl => 'https://client.vtindex.com/?ref=${route.code}';

  Future<void> copyText(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      showAppMessage('$label copied');
    }
  }

  Future<void> share(String platform) async {
    final encoded = Uri.encodeComponent(
      'Join my VT Index partner network: $referralUrl',
    );
    final uri = switch (platform) {
      'WhatsApp' => Uri.parse('https://wa.me/?text=$encoded'),
      'Telegram' => Uri.parse(
        'https://t.me/share/url?url=${Uri.encodeComponent(referralUrl)}',
      ),
      'X' => Uri.parse('https://twitter.com/intent/tweet?text=$encoded'),
      'LinkedIn' => Uri.parse(
        'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(referralUrl)}',
      ),
      'Email' => Uri(
        scheme: 'mailto',
        queryParameters: {
          'subject': 'My VT Index referral link',
          'body': referralUrl,
        },
      ),
      _ => Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(referralUrl)}',
      ),
    };
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return SingleChildScrollView(
              padding: EdgeInsets.all(wide ? 20 : 14),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: Icon(
                              LucideIcons.chevronLeft,
                              color: colors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dashboard  >  Marketing Tools  >  Referral Studio',
                                  style: TextStyle(
                                    color: colors.blue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Referral & QR Studio',
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Distribute profiles, share links and generate branded scannable cards.',
                                  style: TextStyle(
                                    color: colors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (wide)
                            FilledButton.icon(
                              onPressed: () => showAppMessage('Open Client List to add a client.'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(LucideIcons.userPlus, size: 14),
                              label: const Text('Add Client'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      GridView.count(
                        crossAxisCount: wide ? 4 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: wide ? 2.25 : 1.75,
                        children: const [
                          _ReferralMetric(
                            icon: LucideIcons.usersRound,
                            label: 'NETWORK CLIENTS',
                            value: '1',
                            note: 'Access all referral trees',
                            color: Color(0xFF3858EA),
                          ),
                          _ReferralMetric(
                            icon: LucideIcons.wallet,
                            label: 'TOTAL COMMISSION',
                            value: r'$0.00',
                            note: 'Earned lifetime payout',
                            color: Color(0xFF00B98B),
                          ),
                          _ReferralMetric(
                            icon: LucideIcons.trendingUp,
                            label: 'TRADED VOLUME',
                            value: '0.0 L',
                            note: 'Standard lots executed',
                            color: Color(0xFF9B4CF0),
                          ),
                          _ReferralMetric(
                            icon: LucideIcons.zap,
                            label: 'ACTIVE REFERRAL LINKS',
                            value: '7',
                            note: 'View commission profiles',
                            color: Color(0xFFFFA126),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _profileCard(colors)),
                            const SizedBox(width: 16),
                            SizedBox(width: 340, child: _qrCard(colors)),
                          ],
                        )
                      else ...[
                        _profileCard(colors),
                        const SizedBox(height: 14),
                        _qrCard(colors),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileCard(_PartnershipColors colors) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: colors.border),
      boxShadow: [
        BoxShadow(
          color: colors.cardShadow,
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.users, color: colors.blue, size: 17),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commission Profiles',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Select any profile to view its dedicated referral link, metrics, and shareable materials.',
                    style: TextStyle(color: colors.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const _ReferralPremiumPill(),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: colors.border),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 7,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'SELECT ROUTE:',
              style: TextStyle(
                color: colors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
            for (var i = 0; i < routes.length; i++)
              ChoiceChip(
                label: Text(routes[i].name),
                selected: selected == i,
                onSelected: (_) => setState(() => selected = i),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                side: BorderSide(
                  color: selected == i ? colors.blue : colors.border,
                ),
                backgroundColor: colors.subCard,
                selectedColor: colors.blue,
                labelStyle: TextStyle(
                  color: selected == i ? Colors.white : colors.text,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(height: 1, color: colors.border),
        const SizedBox(height: 18),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5578F6), Color(0xFF3152DE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                LucideIcons.chartNoAxesColumn,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          route.name.toUpperCase(),
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const _ReferralPremiumPill(),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tier 024',
                    style: TextStyle(color: colors.muted, fontSize: 10),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'REFERRAL CODE',
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        route.code,
                        style: TextStyle(
                          color: colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .7,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => copyText(route.code, 'Referral code'),
                        icon: Icon(
                          LucideIcons.copy,
                          color: colors.muted,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (MediaQuery.sizeOf(context).width > 600) ...[
              const _ReferralMiniStat(
                label: 'EARNINGS',
                value: r'$0.00',
                icon: LucideIcons.trendingUp,
                color: Color(0xFF00B98B),
              ),
              const SizedBox(width: 18),
              const _ReferralMiniStat(
                label: 'VOLUME',
                value: '0.0 L',
                icon: LucideIcons.activity,
                color: Color(0xFF4285F4),
              ),
              const SizedBox(width: 18),
              const _ReferralMiniStat(
                label: 'CLIENTS',
                value: '0',
                icon: LucideIcons.usersRound,
                color: Color(0xFFB54BEF),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.subCard,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Active Commission Route',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const _ReferralPremiumPill(),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Share this verified link or referral code to automatically route clients into this tier.',
                style: TextStyle(color: colors.muted, fontSize: 10),
              ),
              const SizedBox(height: 11),
              _ReferralLinkRow(
                label: 'DIRECT REFERRAL CODE',
                value: route.code,
                buttonLabel: 'Copy Code',
                onPressed: () => copyText(route.code, 'Referral code'),
              ),
              const SizedBox(height: 8),
              _ReferralLinkRow(
                label: 'DIRECT REGISTRATION URL',
                value: referralUrl,
                buttonLabel: 'Copy Link',
                onPressed: () => copyText(referralUrl, 'Referral link'),
                trailing: IconButton(
                  tooltip: 'Open link',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => launchUrl(
                    Uri.parse(referralUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: Icon(LucideIcons.externalLink, color: colors.blue, size: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _qrCard(_PartnershipColors colors) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: colors.border),
      boxShadow: [
        BoxShadow(
          color: colors.cardShadow,
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(LucideIcons.orbit, color: colors.gold, size: 27),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VT INDEX · REFERRAL STUDIO',
                    style: TextStyle(
                      color: colors.blue,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Share your partner QR',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Scan to join directly',
                    style: TextStyle(color: colors.muted, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140B1D35),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: QrImageView(
            key: ValueKey(referralUrl),
            data: referralUrl,
            version: QrVersions.auto,
            size: 178,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(color: Color(0xFF182C83)),
            dataModuleStyle: const QrDataModuleStyle(color: Color(0xFF182C83)),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'REFERRAL CODE',
          style: TextStyle(
            color: colors.muted,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          route.code,
          style: TextStyle(
            color: colors.gold,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 9,
          runSpacing: 8,
          children: [
            _ReferralSocialButton(
              icon: LucideIcons.messageCircle,
              color: const Color(0xFF00B98B),
              tooltip: 'WhatsApp',
              onTap: () => share('WhatsApp'),
            ),
            _ReferralSocialButton(
              icon: LucideIcons.send,
              color: const Color(0xFF25A9E8),
              tooltip: 'Telegram',
              onTap: () => share('Telegram'),
            ),
            _ReferralSocialButton(
              icon: LucideIcons.atSign,
              color: Colors.black87,
              tooltip: 'X',
              onTap: () => share('X'),
            ),
            _ReferralSocialButton(
              icon: LucideIcons.link,
              color: const Color(0xFF1769AA),
              tooltip: 'LinkedIn',
              onTap: () => share('LinkedIn'),
            ),
            _ReferralSocialButton(
              icon: LucideIcons.mail,
              color: const Color(0xFF8B28D9),
              tooltip: 'Email',
              onTap: () => share('Email'),
            ),
            _ReferralSocialButton(
              icon: LucideIcons.share2,
              color: colors.blue,
              tooltip: 'Copy share link',
              onTap: () => copyText(referralUrl, 'Referral link'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => showAppMessage('PDF export is ready for distribution.'),
            icon: const Icon(LucideIcons.download, size: 14),
            label: const Text(
              'DOWNLOAD PDF CARD',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ReferralRoute {
  const _ReferralRoute(this.name, this.code);
  final String name, code;
}

class _ReferralMetric extends StatelessWidget {
  const _ReferralMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.note,
    required this.color,
  });
  final IconData icon;
  final String label, value, note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralMiniStat extends StatelessWidget {
  const _ReferralMiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: colors.muted,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.text,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ReferralPremiumPill extends StatelessWidget {
  const _ReferralPremiumPill();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E7),
      border: Border.all(color: const Color(0xFFFFD76A)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      '★ PREMIUM',
      style: TextStyle(
        color: Color(0xFFB97800),
        fontSize: 8.5,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _ReferralLinkRow extends StatelessWidget {
  const _ReferralLinkRow({
    required this.label,
    required this.value,
    required this.buttonLabel,
    required this.onPressed,
    this.trailing,
  });
  final String label, value, buttonLabel;
  final VoidCallback onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.link, color: colors.blue, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(LucideIcons.copy, size: 11),
            label: Text(
              buttonLabel,
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
              minimumSize: Size.zero,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ReferralSocialButton extends StatelessWidget {
  const _ReferralSocialButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    ),
  );
}

class BrokerCommissionWithdrawalPage extends StatefulWidget {
  const BrokerCommissionWithdrawalPage({super.key});
  @override
  State<BrokerCommissionWithdrawalPage> createState() =>
      _BrokerCommissionWithdrawalPageState();
}

class _BrokerCommissionWithdrawalPageState
    extends State<BrokerCommissionWithdrawalPage> {
  static const double _availableBalance = 4820.00;
  static const String _account =
      '3327 – standard (KRSNA-USD-B) · Balance: USD 0.00';
  final TextEditingController _amountController = TextEditingController();
  double _amount = 0;
  String _selectedAccount = _account;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(double value) {
    final safeValue = value.clamp(0.0, _availableBalance).toDouble();
    _amountController.text = safeValue.toStringAsFixed(2);
    setState(() => _amount = safeValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    final remaining = (_availableBalance - _amount).clamp(0.0, double.infinity);
    final canSubmit = _amount > 0 && _amount <= _availableBalance;
    final wide = MediaQuery.sizeOf(context).width >= 850;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: const Text(
          'Commission Withdrawal',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BrokerCommissionLedgerPage(),
              ),
            ),
            icon: const Icon(LucideIcons.history, size: 16),
            label: const Text('Ledger'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(wide ? 24 : 14),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 380, child: _summaryCard(colors, remaining)),
                      const SizedBox(width: 22),
                      Expanded(child: _payoutForm(colors, canSubmit)),
                    ],
                  )
                : Column(
                    children: [
                      _summaryCard(colors, remaining),
                      const SizedBox(height: 16),
                      _payoutForm(colors, canSubmit),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(_PartnershipColors colors, double remaining) => Column(
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF071941), Color(0xFF144EA5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0C2B68).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.wallet, color: Colors.white, size: 20),
                const SizedBox(width: 9),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VT-INDEX VAULT',
                        style: TextStyle(
                          color: Color(0xFFDCE5FF),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Commission Balance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'USD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Available to Withdraw',
              style: TextStyle(color: Color(0xFFDCE5FF), fontSize: 10),
            ),
            const SizedBox(height: 5),
            Text(
              r'$' + _availableBalance.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Transfer Settlement',
                      style: TextStyle(color: Color(0xFFDCE5FF), fontSize: 10),
                    ),
                  ),
                  Text(
                    'Direct MT5 Account Credit',
                    style: TextStyle(
                      color: Color(0xFF00D7A2),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.calculator,
                  color: colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SETTLEMENT BREAKDOWN',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 22, color: colors.border),
            const _PayoutBreakdownRow(
              label: 'Source Vault',
              value: 'IB Commission Balance',
            ),
            const _PayoutBreakdownRow(
              label: 'Target Account',
              value: '3327 · standard',
            ),
            _PayoutBreakdownRow(
              label: 'Requested Payout',
              value: 'USD ${_amount.toStringAsFixed(2)}',
            ),
            const _PayoutBreakdownRow(label: 'Transfer Fee', value: 'USD 0.00'),
            Divider(height: 18, color: colors.border),
            _PayoutBreakdownRow(
              label: 'Net Credited to Trading Account',
              value: 'USD ${_amount.toStringAsFixed(2)}',
              strong: true,
            ),
            _PayoutBreakdownRow(
              label: 'Est. Remaining Commission',
              value: 'USD ${remaining.toStringAsFixed(2)}',
              strong: true,
            ),
          ],
        ),
      ),
      const SizedBox(height: 15),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.shieldCheck, color: Color(0xFF00B98B), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instant Internal Settlement Protocol',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Funds are credited directly to your standard trading account. No external banking delays or transaction fees.',
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _payoutForm(_PartnershipColors colors, bool canSubmit) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: colors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.zap, color: colors.gold, size: 13),
              const SizedBox(width: 6),
              Text(
                'COMMISSION PAYOUT DESK',
                style: TextStyle(
                  color: colors.gold,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Transfer to Trading Account',
          style: TextStyle(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select your live receiving account and specify the withdrawal amount.',
          style: TextStyle(color: colors.muted, fontSize: 11),
        ),
        const SizedBox(height: 23),
        Text(
          'RECEIVING TRADING ACCOUNT *',
          style: TextStyle(
            color: colors.text,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.inputBg,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAccount,
              isExpanded: true,
              dropdownColor: colors.card,
              items: [
                DropdownMenuItem(
                  value: _account,
                  child: Text(
                    _account,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: colors.text),
                  ),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedAccount = value ?? _account),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: colors.subCard,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Target Account Balance:',
                  style: TextStyle(color: colors.muted, fontSize: 10),
                ),
              ),
              Text(
                r'$0.00 USD',
                style: TextStyle(
                  color: colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: colors.border),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                'AMOUNT TO WITHDRAW *',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              'Max: USD ${_availableBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF00B98B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: colors.inputBg,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(
                'USD',
                style: TextStyle(
                  color: colors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) =>
                      setState(() => _amount = double.tryParse(value) ?? 0),
                  style: TextStyle(color: colors.text, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: colors.muted,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _setAmount(_availableBalance),
                child: Text(
                  'MAX',
                  style: TextStyle(
                    color: colors.gold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 7,
          runSpacing: 7,
          children: [
            Text(
              'QUICK PRESETS:',
              style: TextStyle(
                color: colors.muted,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
            for (final percent in [25, 50, 75, 100])
              _PayoutPreset(
                label: '$percent%',
                onTap: () => _setAmount(_availableBalance * percent / 100),
              ),
            for (final amount in [100, 250, 500, 1000])
              _PayoutPreset(
                label: 'USD $amount',
                onTap: () => _setAmount(amount.toDouble()),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Divider(color: colors.border),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 10,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.maybePop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.text,
                side: BorderSide(color: colors.border),
              ),
              child: const Text('Cancel & Return'),
            ),
            FilledButton.icon(
              onPressed: canSubmit
                  ? () {
                      showAppMessage('Withdrawal request for \$${_amount.toStringAsFixed(2)} submitted.');
                      Navigator.maybePop(context);
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: colors.blue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(LucideIcons.arrowRight, size: 14),
              label: const Text('Confirm Withdrawal'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PayoutBreakdownRow extends StatelessWidget {
  const _PayoutBreakdownRow({
    required this.label,
    required this.value,
    this.strong = false,
  });
  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? colors.text : colors.muted,
                fontSize: strong ? 10 : 9,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: strong ? 11 : 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutPreset extends StatelessWidget {
  const _PayoutPreset({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: colors.text,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      backgroundColor: colors.subCard,
      side: BorderSide(color: colors.border),
      shape: const StadiumBorder(),
    );
  }
}

class _PartnerProfile {
  const _PartnerProfile({
    required this.name,
    required this.code,
    required this.clients,
    this.primary = false,
  });
  final String name;
  final String code;
  final int clients;
  final bool primary;
}



class _PartnershipSectionLabel extends StatelessWidget {
  const _PartnershipSectionLabel(this.label, {this.subtitle, required this.colors});
  final String label;
  final String? subtitle;
  final _PartnershipColors colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 2),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(
        color: colors.text,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: .8,
      )),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(subtitle!, style: TextStyle(color: colors.muted, fontSize: 10)),
      ],
    ]),
  );
}

class _PartnershipStat extends StatelessWidget {
  const _PartnershipStat({
    required this.icon,
    required this.label,
    required this.value,
    this.gold = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    final accent = gold ? colors.gold : colors.blue;
    final compact = MediaQuery.sizeOf(context).width < 600;
    return _PartnershipGlassPanel(
      colors: colors,
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: accent, size: 14),
          ),
          const SizedBox(width: 9),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(
                color: colors.muted,
                fontSize: compact ? 8 : 10,
                fontWeight: FontWeight.w600,
              )),
              SizedBox(height: compact ? 2 : 4),
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(value, style: TextStyle(
                  color: colors.text,
                  fontSize: compact ? 13 : 16,
                  fontWeight: FontWeight.w800,
                )),
              ),
            ],
          )),
        ]),
    );
  }
}

class _PartnershipShortcut extends StatelessWidget {
  const _PartnershipShortcut({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return _PartnershipGlassPanel(
      colors: colors,
      radius: 17,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: colors.blue.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: colors.blue, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(
                  color: colors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: TextStyle(
                    color: colors.muted,
                    fontSize: 9,
                    height: 1.25,
                  )),
                ],
              ],
            )),
            Icon(LucideIcons.chevronRight, color: colors.muted, size: 17),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Client hierarchy shown from the partnership quick shortcuts.
class BrokerClientTreePage extends StatefulWidget {
  const BrokerClientTreePage({super.key});

  @override
  State<BrokerClientTreePage> createState() => _BrokerClientTreePageState();
}

class _BrokerClientTreePageState extends State<BrokerClientTreePage> {
  static const _ib = _ClientTreeMember(
    initials: 'IB',
    name: 'INR-DEVOP B',
    email: 'iyyanar@vtindex.com',
    phone: '7894561235',
    joined: '2026-01-20',
    referralCode: 'X0RCGYVH7A',
    level: 1,
    accountCount: 9,
    isPartner: true,
    children: [
      _ClientTreeMember(
        initials: 'SK',
        name: 'SHRAVAN KUMAR MADDKUNTA',
        email: 'elegantgrouplands@gmail.com',
        joined: '2026-10-23',
        level: 2,
        accountCount: 1,
      ),
      _ClientTreeMember(
        initials: 'TC',
        name: 'TEST CRN',
        email: 'crmsupportpro@gmail.com',
        phone: '7417417410',
        joined: '2026-07-25',
        referralCode: '8SEBSRFT',
        level: 2,
        accountCount: 4,
      ),
    ],
  );

  final _searchController = TextEditingController();
  String _query = '';
  bool _expanded = true;
  final bool _showAllReferralLinks = true;

  int get _networkCount => _ib.children.length + 1;
  int get _directCount =>
      _ib.children.where((member) => member.level == 2).length;
  int get _downstreamCount =>
      _ib.children.where((member) => member.level > 1).length;
  int get _depth => _ib.children.fold<int>(
    1,
    (max, member) => member.level > max ? member.level : max,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddClientDialog() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x660B1730),
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      useRootNavigator: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 980,
              maxHeight: MediaQuery.sizeOf(sheetContext).height * .76,
            ),
            child: const _ClientRegistrationDialog(),
          ),
        ),
      ),
    );
    if (created == true && mounted) {
      showAppMessage('Client profile created successfully.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    final query = _query.trim().toLowerCase();
    final visibleChildren = _ib.children.where((member) {
      if (query.isEmpty) return true;
      return <String>[
        member.name,
        member.email,
        member.phone ?? '',
        member.referralCode ?? '',
      ].any((value) => value.toLowerCase().contains(query));
    }).toList();
    final rootMatches =
        query.isEmpty ||
        <String>[
          _ib.name,
          _ib.email,
          _ib.phone ?? '',
          _ib.referralCode ?? '',
        ].any((value) => value.toLowerCase().contains(query));

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Client network',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width < 440)
            IconButton(
              tooltip: 'Add client',
              onPressed: _showAddClientDialog,
              icon: const Icon(LucideIcons.userRoundPlus),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: _showAddClientDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                ),
                icon: const Icon(LucideIcons.userRoundPlus, size: 16),
                label: const Text('Add client'),
              ),
            ),
        ],
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: _PartnershipBackdrop(
        colors: colors,
        child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final horizontal = wide ? 28.0 : 14.0;
          return ListView(
            padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 30),
            children: [
              _treeHeader(colors),
              const SizedBox(height: 14),
              _treeSearch(colors),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: wide ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: wide ? 2.25 : 2.05,
                children: [
                  _TreeStat(
                    label: 'TOTAL NETWORK',
                    value: '$_networkCount',
                    subtitle: 'All downline clients',
                    icon: LucideIcons.users,
                    accent: colors.gold,
                    dark: colors.isDark,
                  ),
                  _TreeStat(
                    label: 'DIRECT (L1)',
                    value: '$_directCount',
                    subtitle: 'Direct referrals',
                    icon: LucideIcons.userRound,
                    accent: colors.gold,
                    dark: colors.isDark,
                  ),
                  _TreeStat(
                    label: 'SUB-TIER (L2+)',
                    value: '$_downstreamCount',
                    subtitle: 'Downstream clients',
                    icon: LucideIcons.network,
                    accent: const Color(0xFF20A8E8),
                    dark: colors.isDark,
                  ),
                  _TreeStat(
                    label: 'NETWORK DEPTH',
                    value: 'L$_depth',
                    subtitle: 'Maximum depth',
                    icon: LucideIcons.gitBranch,
                    accent: const Color(0xFF13B981),
                    dark: colors.isDark,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(
                color: colors.border,
                height: 1,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'CLIENT HIERARCHY',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .45,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _expanded = true),
                        icon: const Icon(LucideIcons.maximize2, size: 13),
                        label: const Text('Expand all'),
                        style: _treeSmallButton(colors),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _expanded = false),
                        icon: const Icon(LucideIcons.minimize2, size: 13),
                        label: const Text('Collapse all'),
                        style: _treeSmallButton(colors),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (rootMatches)
                _TreeMemberCard(
                  member: _ib,
                  dark: colors.isDark,
                  root: true,
                  expanded: _expanded,
                  onToggle: () => setState(() => _expanded = !_expanded),
                  showReferralLink: _showAllReferralLinks,
                ),
              if (_expanded && visibleChildren.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colors.border,
                          width: 1.2,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        for (final member in visibleChildren)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 8),
                            child: _TreeMemberCard(
                              member: member,
                              dark: colors.isDark,
                              root: false,
                              showReferralLink: _showAllReferralLinks,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              if (!rootMatches && visibleChildren.isEmpty) _treeEmpty(colors),
              if (rootMatches && visibleChildren.isEmpty && query.isNotEmpty)
                _treeEmpty(colors),
              const SizedBox(height: 12),
              Divider(
                color: colors.border,
                height: 1,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'CLIENTS PER PAGE',
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Showing ${visibleChildren.length + (rootMatches ? 1 : 0)} of $_networkCount',
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _treeHeader(_PartnershipColors colors) => _PartnershipGlassPanel(
    colors: colors,
    padding: const EdgeInsets.all(20),
    radius: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTNER NETWORK',
          style: TextStyle(
            color: colors.blue,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your client network',
          style: TextStyle(
            color: colors.text,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Follow referrals, account activity, and each connection in your network.',
          style: TextStyle(
            color: colors.muted,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );

  Widget _treeSearch(_PartnershipColors colors) => _PartnershipGlassPanel(
    colors: colors,
    radius: 16,
    child: TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      style: TextStyle(color: colors.text, fontSize: 11.5),
      decoration: InputDecoration(
        hintText: 'Search name, email, referral code, profile or account...',
        hintStyle: TextStyle(
          color: colors.muted,
          fontSize: 10.5,
        ),
        prefixIcon: Icon(LucideIcons.search, color: colors.blue, size: 17),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: Icon(LucideIcons.x, color: colors.muted, size: 16),
              ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    ),
  );

  Widget _treeEmpty(_PartnershipColors colors) => _PartnershipGlassPanel(
    colors: colors,
    padding: const EdgeInsets.all(24),
    radius: 18,
    child: Column(
      children: [
        Icon(
          LucideIcons.users,
          color: colors.muted,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          'No matching clients',
          style: TextStyle(
            color: colors.text,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Try a different name, email or referral code.',
          style: TextStyle(
            color: colors.muted,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );

  ButtonStyle _treeSmallButton(_PartnershipColors colors) => OutlinedButton.styleFrom(
    foregroundColor: colors.text,
    side: BorderSide(color: colors.border),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    textStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    visualDensity: VisualDensity.compact,
  );
}

class _ClientRegistrationDialog extends StatefulWidget {
  const _ClientRegistrationDialog();

  @override
  State<_ClientRegistrationDialog> createState() =>
      _ClientRegistrationDialogState();
}

class _ClientRegistrationDialogState extends State<_ClientRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _birthDate = TextEditingController();
  String? _country;
  late int _partnerIndex;
  bool _primary = true;

  static const _countries = [
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Canada',
    'India',
    'Malaysia',
    'Singapore',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
  ];

  @override
  void initState() {
    super.initState();
    _partnerIndex = _partnerProfiles.indexWhere((partner) => partner.primary);
    if (_partnerIndex < 0) _partnerIndex = 0;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _birthDate.dispose();
    super.dispose();
  }

  void _reset() {
    _formKey.currentState?.reset();
    _name.clear();
    _email.clear();
    _phone.clear();
    _birthDate.clear();
    setState(() {
      _country = null;
      _partnerIndex = _partnerProfiles.indexWhere((partner) => partner.primary);
      if (_partnerIndex < 0) _partnerIndex = 0;
      _primary = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: colors.border)),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 24,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 7, 12, 8),
            child: Row(
              children: [
                _iconBadge(LucideIcons.userRound, colors),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PARTNER NETWORK ONBOARDING',
                        style: TextStyle(
                          color: colors.blue,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Client Registration Information',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _reset,
                  icon: Icon(LucideIcons.rotateCcw, size: 13, color: colors.muted),
                  label: Text('Reset', style: TextStyle(color: colors.muted)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.border),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    _responsive([
                      _textField(
                        _name,
                        'FULL NAME',
                        'e.g. Johnathan Miller',
                        LucideIcons.userRound,
                        colors,
                        required: true,
                      ),
                      _birthDateField(colors),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _textField(
                            _email,
                            'EMAIL ADDRESS',
                            'client@company.com',
                            LucideIcons.mail,
                            colors,
                            required: true,
                            email: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _textField(
                            _phone,
                            'PHONE NUMBER',
                            '+1 (555) 234-5678',
                            LucideIcons.phone,
                            colors,
                            required: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    _countryField(colors),
                    const SizedBox(height: 8),
                    _partnerField(colors),
                    Material(
                      color: colors.card,
                      child: SizedBox(
                        height: 34,
                        child: CheckboxListTile(
                          value: _primary,
                          onChanged: (value) => setState(() {
                            _primary = value ?? false;
                            if (_primary) {
                              final primaryIndex = _partnerProfiles.indexWhere(
                                (partner) => partner.primary,
                              );
                              if (primaryIndex >= 0) {
                                _partnerIndex = primaryIndex;
                              }
                            }
                          }),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            'Use primary referral profile',
                            style: TextStyle(color: colors.blue, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: colors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.of(context).pop(true);
                  }
                },
                icon: const Icon(LucideIcons.userRoundPlus, size: 15),
                label: const Text('Create Client Profile'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsive(List<Widget> fields) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 10.0;
      final halfWidth = (constraints.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: 7,
        children: [
          for (var i = 0; i < fields.length; i++)
            SizedBox(
              width: fields.length.isOdd && i == fields.length - 1
                  ? constraints.maxWidth
                  : halfWidth,
              child: fields[i],
            ),
        ],
      );
    },
  );

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    _PartnershipColors colors, {
    bool required = false,
    bool email = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldLabel(label, colors, required: required),
      const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        validator: required
            ? (value) => (value == null || value.trim().isEmpty)
                  ? 'Required'
                  : (email && !value.contains('@')
                        ? 'Enter a valid email'
                        : null)
            : null,
        style: TextStyle(color: colors.text, fontSize: 11),
        decoration: _decoration(hint, icon, colors),
      ),
    ],
  );

  Widget _birthDateField(_PartnershipColors colors) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldLabel('DATE OF BIRTH', colors, suffix: '(optional)'),
      const SizedBox(height: 5),
      TextFormField(
        controller: _birthDate,
        readOnly: true,
        onTap: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: DateTime(1995),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (selected != null) {
            _birthDate.text =
                '${selected.day.toString().padLeft(2, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.year}';
          }
        },
        style: TextStyle(color: colors.text, fontSize: 11),
        decoration: _decoration('dd-mm-yyyy', LucideIcons.calendarDays, colors),
      ),
    ],
  );

  Widget _countryField(_PartnershipColors colors) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldLabel('COUNTRY / REGION', colors, required: true),
      const SizedBox(height: 5),
      DropdownButtonFormField<String>(
        initialValue: _country,
        isExpanded: true,
        dropdownColor: colors.card,
        style: TextStyle(color: colors.text, fontSize: 11),
        validator: (value) => value == null ? 'Select a country' : null,
        decoration: _decoration('Search and select country', LucideIcons.globe, colors),
        items: [
          for (final country in _countries)
            DropdownMenuItem(
              value: country,
              child: Text(country, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (value) => setState(() => _country = value),
      ),
    ],
  );

  Widget _partnerField(_PartnershipColors colors) {
    final partner = _partnerProfiles[_partnerIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.inputBg,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          _iconBadge(LucideIcons.userRound, colors),
          const SizedBox(width: 9),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _partnerIndex,
                isExpanded: true,
                dropdownColor: colors.card,
                items: [
                  for (var i = 0; i < _partnerProfiles.length; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(
                        '${_partnerProfiles[i].name}  ${_partnerProfiles[i].primary ? 'PRIMARY  ' : ''}${_partnerProfiles[i].code}  ·  ${_partnerProfiles[i].clients} clients',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.text,
                        ),
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _partnerIndex = value;
                    _primary = _partnerProfiles[value].primary;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            partner.primary ? '✓ Assigned' : 'Assigned',
            style: const TextStyle(
              color: Color(0xFF0BAE7A),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, _PartnershipColors colors) => Container(
    width: 30,
    height: 30,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: colors.blue.withValues(alpha: 0.12),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: colors.blue, size: 15),
  );

  Widget _fieldLabel(String label, _PartnershipColors colors, {bool required = false, String? suffix}) =>
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.text,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (required)
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFFF5366),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (suffix != null)
            Text(
              suffix,
              style: TextStyle(color: colors.muted, fontSize: 8),
            ),
        ],
      );

  InputDecoration _decoration(String hint, IconData icon, _PartnershipColors colors) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: colors.muted, fontSize: 10),
    prefixIcon: Icon(icon, color: colors.muted, size: 14),
    isDense: true,
    filled: true,
    fillColor: colors.inputBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: colors.blue),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDA5969)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFDA5969)),
    ),
  );
}

class _ClientTreeMember {
  const _ClientTreeMember({
    required this.initials,
    required this.name,
    required this.email,
    required this.level,
    required this.accountCount,
    this.phone,
    this.joined,
    this.referralCode,
    this.isPartner = false,
    this.children = const [],
  });

  final String initials;
  final String name;
  final String email;
  final String? phone;
  final String? joined;
  final String? referralCode;
  final int level;
  final int accountCount;
  final bool isPartner;
  final List<_ClientTreeMember> children;
}

class _TreeStat extends StatelessWidget {
  const _TreeStat({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.dark,
  });
  final String label, value, subtitle;
  final IconData icon;
  final Color accent;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return _PartnershipGlassPanel(
      colors: colors,
      radius: 17,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .35,
                  ),
                ),
              ),
              Icon(icon, color: accent, size: 13),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.muted, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _TreeMemberCard extends StatelessWidget {
  const _TreeMemberCard({
    required this.member,
    required this.dark,
    required this.root,
    required this.showReferralLink,
    this.expanded = false,
    this.onToggle,
  });
  final _ClientTreeMember member;
  final bool dark;
  final bool root;
  final bool showReferralLink;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    final accent = root ? colors.blue : const Color(0xFF00BFA5);
    return _PartnershipGlassPanel(
      colors: colors,
      radius: 17,
      padding: const EdgeInsets.all(15),
      borderColor: root ? colors.blue.withValues(alpha: .55) : null,
      fillColor: root
          ? (colors.isDark ? const Color(0xDD183254) : const Color(0xDFFFFFFF))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: accent.withValues(alpha: .28)),
                ),
                child: Text(
                  member.initials,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 5,
                      runSpacing: 3,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          member.name,
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _TreePill(
                          label: 'L${member.level}',
                          color: root
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF00A991),
                          dark: dark,
                        ),
                        if (member.isPartner)
                          _TreePill(
                            label: 'Gold',
                            color: colors.gold,
                            dark: dark,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.muted, fontSize: 9),
                    ),
                    Wrap(
                      spacing: 9,
                      runSpacing: 3,
                      children: [
                        if (member.phone != null)
                          Text(
                            member.phone!,
                            style: TextStyle(color: colors.muted, fontSize: 9),
                          ),
                        if (member.joined != null)
                          Text(
                            'Joined ${member.joined}',
                            style: TextStyle(color: colors.muted, fontSize: 9),
                          ),
                        if (showReferralLink && member.referralCode != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.link,
                                color: colors.blue,
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                member.referralCode!,
                                style: TextStyle(
                                  color: colors.blue,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (root)
                IconButton(
                  tooltip: expanded ? 'Hide team' : 'Show team',
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggle,
                  icon: Icon(
                    expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: colors.muted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              if (member.isPartner)
                _TreePill(
                  label: '${member.children.length} referrals',
                  color: colors.blue,
                  dark: dark,
                ),
              const Spacer(),
              if (member.isPartner)
                _TreePill(
                  label: 'IB Partner',
                  color: const Color(0xFF00A870),
                  dark: dark,
                ),
              const SizedBox(width: 6),
              _TreePill(
                label: '${member.accountCount} Accounts',
                color: colors.muted,
                dark: dark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TreePill extends StatelessWidget {
  const _TreePill({
    required this.label,
    required this.color,
    required this.dark,
  });
  final String label;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: dark ? const Color(0xFFCFD8E7) : color,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Dedicated page for closed trading commission ledger records.
class BrokerCommissionLedgerPage extends StatefulWidget {
  const BrokerCommissionLedgerPage({super.key});

  @override
  State<BrokerCommissionLedgerPage> createState() =>
      _BrokerCommissionLedgerPageState();
}

class _BrokerCommissionLedgerPageState
    extends State<BrokerCommissionLedgerPage> {
  int _ledgerRows = 15;
  String _ledgerSearch = '';
  String _symbolFilter = 'All Symbols (7)';
  String _sort = 'Close Time (Newest First)';

  static const _ledger = <_CommissionLedgerEntry>[
    _CommissionLedgerEntry(
      name: 'TEST CRN',
      email: 'crmsupportpro@gmail.com',
      initials: 'TC',
      deal: '20922385',
      order: '678898116',
      account: '3384',
      symbol: 'XAUUSD',
      lots: '0.01',
      pnl: -96.87,
      commission: 0.06,
      close: '5 Nov 2026, 07:08 am',
    ),
    _CommissionLedgerEntry(
      name: 'TEST CRN',
      email: 'crmsupportpro@gmail.com',
      initials: 'TC',
      deal: '20776912',
      order: '678886341',
      account: '3384',
      symbol: 'EURUSD',
      lots: '0.01',
      pnl: -0.35,
      commission: 0.06,
      close: '27 Oct 2026, 06:54 pm',
    ),
    _CommissionLedgerEntry(
      name: 'Lakshminarayanan A',
      email: 'nanianandane@gmail.com',
      initials: 'LA',
      deal: '18338543',
      order: '227958624',
      account: '2141717622',
      symbol: 'XAUUSD.r',
      lots: '0.01',
      pnl: 1.65,
      commission: 0.03,
      close: '2 Jun 2026, 08:06 pm',
    ),
    _CommissionLedgerEntry(
      name: 'Lakshminarayanan A',
      email: 'nanianandane@gmail.com',
      initials: 'LA',
      deal: '18338199',
      order: '226590488',
      account: '2141717622',
      symbol: 'XAUUSD.r',
      lots: '0.01',
      pnl: 20.88,
      commission: 0.03,
      close: '2 Jun 2026, 07:52 pm',
    ),
    _CommissionLedgerEntry(
      name: 'Lakshminarayanan A',
      email: 'nanianandane@gmail.com',
      initials: 'LA',
      deal: '18338200',
      order: '227142739',
      account: '2141717622',
      symbol: 'XAUUSD.r',
      lots: '0.01',
      pnl: 37.90,
      commission: 0.03,
      close: '2 Jun 2026, 07:52 pm',
    ),
    _CommissionLedgerEntry(
      name: 'Lakshminarayanan A',
      email: 'nanianandane@gmail.com',
      initials: 'LA',
      deal: '18331796',
      order: '227088303',
      account: '2141717622',
      symbol: 'XAUUSD.r',
      lots: '0.01',
      pnl: 2.30,
      commission: 0.03,
      close: '2 Jun 2026, 02:16 pm',
    ),
    _CommissionLedgerEntry(
      name: 'Lakshminarayanan A',
      email: 'nanianandane@gmail.com',
      initials: 'LA',
      deal: '18331476',
      order: '226962801',
      account: '2141717622',
      symbol: 'XAUUSD.r',
      lots: '0.01',
      pnl: 15.20,
      commission: 0.03,
      close: '2 Jun 2026, 01:54 pm',
    ),
    _CommissionLedgerEntry(
      name: 'Lakshminarayanan A',
      email: 'nanianandane@gmail.com',
      initials: 'LA',
      deal: '18330920',
      order: '226811234',
      account: '2141717622',
      symbol: 'GBPUSD',
      lots: '0.02',
      pnl: 4.80,
      commission: 0.04,
      close: '2 Jun 2026, 11:20 am',
    ),
  ];

  List<_CommissionLedgerEntry> get _filteredLedger {
    var list = _ledger.toList();
    if (_symbolFilter != 'All Symbols (7)') {
      list = list.where((e) => e.symbol == _symbolFilter).toList();
    }
    if (_ledgerSearch.trim().isNotEmpty) {
      final q = _ledgerSearch.trim().toLowerCase();
      list = list
          .where(
            (e) =>
                e.name.toLowerCase().contains(q) ||
                e.email.toLowerCase().contains(q) ||
                e.account.toLowerCase().contains(q) ||
                e.deal.toLowerCase().contains(q) ||
                e.order.toLowerCase().contains(q) ||
                e.symbol.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Commission Ledger'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return ListView(
            padding: EdgeInsets.fromLTRB(
              wide ? 24 : 14,
              14,
              wide ? 24 : 14,
              28,
            ),
            children: [
              _commissionHeader(colors),
              const SizedBox(height: 12),
              _ledgerContent(colors, wide),
            ],
          );
        },
      ),
    );
  }

  Widget _commissionHeader(_PartnershipColors colors) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: colors.border),
      boxShadow: [
        BoxShadow(
          color: colors.cardShadow,
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IB PAYOUTS',
          style: TextStyle(
            color: colors.gold,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Commission Ledger',
          style: TextStyle(
            color: colors.text,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Review closed trading deals and the commission generated by your network.',
          style: TextStyle(color: colors.muted, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _ledgerContent(_PartnershipColors colors, bool wide) {
    final entries = _filteredLedger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: wide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          childAspectRatio: wide ? 2.05 : 1.45,
          children: const [
            _CommissionMetric(
              label: 'TOTAL EARNINGS',
              value: r'$197.39',
              subtitle: 'Calculated IB commission payouts',
              icon: LucideIcons.trendingUp,
              accent: Color(0xFF16B98B),
            ),
            _CommissionMetric(
              label: 'VOLUME TRADED',
              value: '0.02 L',
              subtitle: 'Executed standard lots',
              icon: LucideIcons.activity,
              accent: Color(0xFF5C9EEB),
            ),
            _CommissionMetric(
              label: 'LEDGER RECORDS',
              value: '47',
              subtitle: 'Closed commission deals',
              icon: LucideIcons.layers,
              accent: Color(0xFFB56CE2),
            ),
            _CommissionMetric(
              label: 'FILTERED SUM',
              value: r'$1.95',
              subtitle: '47 matching transactions',
              icon: LucideIcons.award,
              accent: Color(0xFFE8AD22),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(13),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: wide ? 390 : double.infinity,
                      child: TextField(
                        onChanged: (v) => setState(() => _ledgerSearch = v),
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 11,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search clients, emails, accounts, deal tickets, or symbols...',
                          hintStyle: TextStyle(
                            color: colors.muted,
                            fontSize: 10,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.search,
                            color: colors.blue,
                            size: 17,
                          ),
                          filled: true,
                          fillColor: colors.inputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: BorderSide(
                              color: colors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: BorderSide(
                              color: colors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: BorderSide(
                              color: colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _CommissionDropdown(
                      value: _symbolFilter,
                      values: const [
                        'All Symbols (7)',
                        'XAUUSD',
                        'EURUSD',
                        'XAUUSD.r',
                      ],
                      onChanged: (v) => setState(() => _symbolFilter = v),
                    ),
                    _CommissionDropdown(
                      value: _sort,
                      values: const [
                        'Close Time (Newest First)',
                        'Close Time (Oldest First)',
                      ],
                      onChanged: (v) => setState(() => _sort = v),
                    ),
                    _CommissionDropdown(
                      value: 'Show: $_ledgerRows rows',
                      values: const [
                        'Show: 15 rows',
                        'Show: 25 rows',
                        'Show: 50 rows',
                      ],
                      onChanged: (v) => setState(
                        () => _ledgerRows = int.parse(v.split(' ')[1]),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    colors.subCard,
                  ),
                  headingRowHeight: 40,
                  dataRowMinHeight: 55,
                  dataRowMaxHeight: 60,
                  horizontalMargin: 14,
                  columnSpacing: 23,
                  columns: const [
                    DataColumn(
                      label: _CommissionTableHeading('CLIENT PROFILE'),
                    ),
                    DataColumn(label: _CommissionTableHeading('DEAL TICKET')),
                    DataColumn(label: _CommissionTableHeading('ORDER TICKET')),
                    DataColumn(
                      label: _CommissionTableHeading('TRADING ACCOUNT'),
                    ),
                    DataColumn(label: _CommissionTableHeading('SYMBOL')),
                    DataColumn(label: _CommissionTableHeading('VOLUME (LOTS)')),
                    DataColumn(label: _CommissionTableHeading('CLIENT P/L')),
                    DataColumn(label: _CommissionTableHeading('IB COMMISSION')),
                    DataColumn(label: _CommissionTableHeading('CLOSE TIME')),
                  ],
                  rows: [
                    for (final e in entries.take(_ledgerRows))
                      DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 175,
                              child: Row(
                                children: [
                                  Container(
                                    width: 31,
                                    height: 31,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: colors.blue.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      e.initials,
                                      style: TextStyle(
                                        color: colors.blue,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: colors.text,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          e.email,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: colors.muted,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(_CommissionCell(e.deal, bold: true)),
                          DataCell(
                            _CommissionCell(
                              e.order,
                              color: colors.muted,
                            ),
                          ),
                          DataCell(
                            _CommissionPill(
                              e.account,
                              color: const Color(0xFF5596DF),
                              background: const Color(0xFF5596DF).withValues(alpha: 0.12),
                            ),
                          ),
                          DataCell(
                            _CommissionPill(
                              e.symbol,
                              color: colors.text,
                              background: colors.card,
                              outlined: true,
                            ),
                          ),
                          DataCell(
                            _CommissionCell('${e.lots} Lots', bold: true),
                          ),
                          DataCell(
                            _CommissionCell(
                              '${e.pnl < 0 ? '↓' : '↑'} ${e.pnl < 0 ? '-' : ''}\$${e.pnl.abs().toStringAsFixed(2)}',
                              color: e.pnl < 0
                                  ? colors.red
                                  : colors.green,
                              bold: true,
                            ),
                          ),
                          DataCell(
                            _CommissionCell(
                              '+\$${e.commission.toStringAsFixed(2)}',
                              color: colors.green,
                              bold: true,
                            ),
                          ),
                          DataCell(_CommissionCell(e.close)),
                        ],
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.border),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    Text(
                      'Showing 1–${entries.length} of 47',
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'PAGE 1 OF 4',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.chevronLeft,
                      color: colors.muted,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.chevronRight,
                      color: colors.gold,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CommissionLedgerEntry {
  const _CommissionLedgerEntry({
    required this.name,
    required this.email,
    required this.initials,
    required this.deal,
    required this.order,
    required this.account,
    required this.symbol,
    required this.lots,
    required this.pnl,
    required this.commission,
    required this.close,
  });
  final String name, email, initials, deal, order, account, symbol, lots, close;
  final double pnl, commission;
}

class _CommissionTableHeading extends StatelessWidget {
  const _CommissionTableHeading(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Text(
      label,
      style: TextStyle(
        color: colors.muted,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: .2,
      ),
    );
  }
}

class _CommissionCell extends StatelessWidget {
  const _CommissionCell(
    this.value, {
    this.bold = false,
    this.color,
  });
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Text(
      value,
      style: TextStyle(
        color: color ?? colors.text,
        fontSize: 10,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      ),
    );
  }
}

class _CommissionPill extends StatelessWidget {
  const _CommissionPill(
    this.label, {
    required this.color,
    this.background,
    this.outlined = false,
  });
  final String label;
  final Color color;
  final Color? background;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(8),
        border: outlined ? Border.all(color: colors.border) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CommissionMetric extends StatelessWidget {
  const _CommissionMetric({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
  final String label, value, subtitle;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: accent, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.muted, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _CommissionDropdown extends StatelessWidget {
  const _CommissionDropdown({
    required this.value,
    required this.values,
    required this.onChanged,
  });
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.inputBg,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          dropdownColor: colors.card,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 14,
            color: colors.muted,
          ),
          style: TextStyle(
            color: colors.text,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
          items: [
            for (final item in values)
              DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
