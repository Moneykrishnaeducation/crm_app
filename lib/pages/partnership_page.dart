import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_notifications.dart';
import '../services/auth_api.dart';

// ============================================================================
// DESIGN TOKENS & STYLING
// ============================================================================

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
      card: isDark ? const Color(0xFF0F2148) : Colors.white,
      subCard: isDark ? const Color(0xFF0A1838) : const Color(0xFFF6F9FF),
      border: isDark ? const Color(0xFF1E3F8A) : const Color(0xFFDCE5F2),
      subBorder: isDark ? const Color(0xFF193268) : const Color(0xFFE2E8F0),
      text: isDark ? Colors.white : const Color(0xFF091836),
      muted: isDark ? const Color(0xFF90A8CC) : const Color(0xFF576A88),
      navy: isDark ? const Color(0xFF071A57) : const Color(0xFF10264B),
      blue: const Color(0xFF2563EB),
      gold: const Color(0xFFF5C438),
      green: const Color(0xFF10B981),
      red: const Color(0xFFEF4444),
      cardShadow: isDark ? const Color(0x33000000) : const Color(0x0A0B1D35),
      inputBg: isDark ? const Color(0xFF0A1838) : const Color(0xFFF3F6FB),
      chipBg: isDark ? const Color(0xFF102758) : const Color(0xFFEBF2FD),
      appBarBg: isDark ? const Color(0xFF071426) : Colors.white,
    );
  }

  Color get glassFill =>
      isDark ? const Color(0xCC071A57) : const Color(0xEBFFFFFF);
  Color get glassBorder =>
      isDark ? const Color(0x66214FBF) : const Color(0xBBDCE5F2);
  Color get accentGlow =>
      isDark ? const Color(0xFF173B8A) : const Color(0xFFD6E8FF);
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
                      ? const [Color(0xFF040D1E), Color(0xFF071630)]
                      : const [Color(0xFFF7FAFF), Color(0xFFEDF3FD)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -160,
            right: -100,
            child: _ambientOrb(colors.accentGlow),
          ),
          Positioned(
            bottom: 60,
            left: -180,
            child: _ambientOrb(colors.blue.withValues(alpha: .14)),
          ),
          child,
        ],
      );

  Widget _ambientOrb(Color color) => Container(
        width: 380,
        height: 380,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: .5), color.withValues(alpha: 0)],
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
    this.onTap,
  });

  final _PartnershipColors colors;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colors.glassFill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: colors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: content,
      );
    }
    return content;
  }
}

// ============================================================================
// LEVEL THEMING HELPER
// ============================================================================

class _LevelTheme {
  const _LevelTheme({
    required this.level,
    required this.color,
    required this.badgeBg,
    required this.badgeText,
    required this.avatarBg,
    required this.avatarBorder,
    required this.avatarText,
    required this.roleLabel,
    required this.roleDescription,
  });

  final int level;
  final Color color;
  final Color badgeBg;
  final Color badgeText;
  final Color avatarBg;
  final Color avatarBorder;
  final Color avatarText;
  final String roleLabel;
  final String roleDescription;
}

_LevelTheme _getLevelTheme(int level, bool isDark) {
  final lvl = level <= 0 ? 1 : level;
  switch (lvl) {
    case 1:
      return _LevelTheme(
        level: 1,
        color: const Color(0xFF0284C7),
        badgeBg: const Color(0xFF0284C7),
        badgeText: Colors.white,
        avatarBg: isDark ? const Color(0xFF0C2A4A) : const Color(0xFFE0F2FE),
        avatarBorder: const Color(0xFF0284C7),
        avatarText: const Color(0xFF0284C7),
        roleLabel: 'Direct IB',
        roleDescription: 'Directly referred to your partnership network',
      );
    case 2:
      return _LevelTheme(
        level: 2,
        color: const Color(0xFF0D9488),
        badgeBg: const Color(0xFF0D9488),
        badgeText: Colors.white,
        avatarBg: isDark ? const Color(0xFF062E2A) : const Color(0xFFCCFBF1),
        avatarBorder: const Color(0xFF0D9488),
        avatarText: const Color(0xFF0D9488),
        roleLabel: 'Level 2 Sub-IB',
        roleDescription: 'Referred by one of your direct clients',
      );
    case 3:
      return _LevelTheme(
        level: 3,
        color: const Color(0xFFF5C438),
        badgeBg: const Color(0xFFD49D10),
        badgeText: Colors.white,
        avatarBg: isDark ? const Color(0xFF2E2405) : const Color(0xFFFEF9C3),
        avatarBorder: const Color(0xFFD49D10),
        avatarText: const Color(0xFFD49D10),
        roleLabel: 'Level 3 Network',
        roleDescription: 'Sub-tier affiliate in your multi-level tree',
      );
    case 4:
      return _LevelTheme(
        level: 4,
        color: const Color(0xFFC084FC),
        badgeBg: const Color(0xFF9333EA),
        badgeText: Colors.white,
        avatarBg: isDark ? const Color(0xFF28133E) : const Color(0xFFF3E8FF),
        avatarBorder: const Color(0xFF9333EA),
        avatarText: const Color(0xFF9333EA),
        roleLabel: 'Level 4 Network',
        roleDescription: 'Deep tier affiliate in your multi-level tree',
      );
    default:
      return _LevelTheme(
        level: lvl,
        color: const Color(0xFFFB7185),
        badgeBg: const Color(0xFFE11D48),
        badgeText: Colors.white,
        avatarBg: isDark ? const Color(0xFF34101A) : const Color(0xFFFFE4E6),
        avatarBorder: const Color(0xFFE11D48),
        avatarText: const Color(0xFFE11D48),
        roleLabel: 'Level $lvl Network',
        roleDescription: 'Deep tier affiliate in your multi-level tree',
      );
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

class _IbDashboardData {
  _IbDashboardData({
    this.totalClients = 0,
    this.directClients = 0,
    this.totalEarnings = 0.0,
    this.totalWithdrawals = 0.0,
    this.commissionBalance = 0.0,
    this.currentMonthEarnings = 0.0,
    this.currentMonthVolume = 0.0,
    this.totalVolume = 0.0,
    this.referralLink = '',
    this.earningsPerClient = const [],
    this.earningsPerMonth = const [],
    this.earningsPerLink = const [],
    this.monthlyEarningsPerLink = const [],
  });

  final int totalClients;
  final int directClients;
  final double totalEarnings;
  final double totalWithdrawals;
  final double commissionBalance;
  final double currentMonthEarnings;
  final double currentMonthVolume;
  final double totalVolume;
  final String referralLink;
  final List<Map<String, dynamic>> earningsPerClient;
  final List<Map<String, dynamic>> earningsPerMonth;
  final List<Map<String, dynamic>> earningsPerLink;
  final List<Map<String, dynamic>> monthlyEarningsPerLink;

  factory _IbDashboardData.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final rawClients = json['earnings_per_client'];
    final clientList = <Map<String, dynamic>>[];
    if (rawClients is List) {
      for (final item in rawClients.whereType<Map>()) {
        clientList.add(item.cast<String, dynamic>());
      }
    }
    clientList.sort((a, b) =>
        parseNum(b['total_commission']).compareTo(parseNum(a['total_commission'])));

    // Normalize monthly trajectory for all 12 months JAN..DEC
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final monthlyMap = <String, double>{};
    final rawMonths = json['earnings_per_month'];
    if (rawMonths is List) {
      for (final item in rawMonths.whereType<Map>()) {
        final mIdx = parseInt(item['month']);
        if (mIdx >= 1 && mIdx <= 12) {
          final mName = months[mIdx - 1];
          monthlyMap[mName] = (monthlyMap[mName] ?? 0.0) + parseNum(item['total']);
        }
      }
    }
    final normalizedMonthly = months
        .map((m) => {'month': m, 'total': monthlyMap[m] ?? 0.0})
        .toList();

    final linkList = <Map<String, dynamic>>[];
    final rawLinks = json['earnings_per_link'];
    if (rawLinks is List) {
      for (final item in rawLinks.whereType<Map>()) {
        linkList.add(item.cast<String, dynamic>());
      }
    }

    final monthlyLinks = <Map<String, dynamic>>[];
    final rawMonthlyLinks = json['monthly_earnings_per_link'];
    if (rawMonthlyLinks is List) {
      for (final item in rawMonthlyLinks.whereType<Map>()) {
        monthlyLinks.add(item.cast<String, dynamic>());
      }
    }

    return _IbDashboardData(
      totalClients: parseInt(json['total_clients']),
      directClients: parseInt(json['direct_clients']),
      totalEarnings: parseNum(json['total_earnings']),
      totalWithdrawals: parseNum(json['total_withdrawals']),
      commissionBalance: parseNum(json['commission_balance']),
      currentMonthEarnings: parseNum(json['current_month_earnings']),
      currentMonthVolume: parseNum(json['current_month_volume_traded']),
      totalVolume: parseNum(json['total_volume_traded']),
      referralLink: (json['referralLink'] ?? json['referral_link'] ?? '').toString(),
      earningsPerClient: clientList,
      earningsPerMonth: normalizedMonthly,
      earningsPerLink: linkList,
      monthlyEarningsPerLink: monthlyLinks,
    );
  }

  bool get isEmpty =>
      totalClients == 0 &&
      directClients == 0 &&
      totalEarnings == 0.0 &&
      commissionBalance == 0.0;

  static _IbDashboardData demo() => _IbDashboardData(
        totalClients: 42,
        directClients: 28,
        totalEarnings: 8420.50,
        totalWithdrawals: 5200.00,
        commissionBalance: 3220.50,
        currentMonthEarnings: 1840.25,
        currentMonthVolume: 320.5,
        totalVolume: 1420.8,
        referralLink: 'https://client.vtindex.com/?ref=VT-DEMO',
        earningsPerClient: [
          {'name': 'Alexander Wright', 'total_commission': 1850.0, 'total_volume': 142.0, 'level': 1},
          {'name': 'Sophia Chen', 'total_commission': 1420.0, 'total_volume': 110.5, 'level': 1},
          {'name': 'Marcus Vance', 'total_commission': 980.5, 'total_volume': 78.0, 'level': 2},
          {'name': 'Elena Rostova', 'total_commission': 740.0, 'total_volume': 55.0, 'level': 2},
          {'name': 'David Kim', 'total_commission': 520.0, 'total_volume': 42.0, 'level': 3},
        ],
        earningsPerMonth: [
          {'month': 'Jan', 'total': 450.0},
          {'month': 'Feb', 'total': 680.0},
          {'month': 'Mar', 'total': 920.0},
          {'month': 'Apr', 'total': 1150.0},
          {'month': 'May', 'total': 1420.0},
          {'month': 'Jun', 'total': 1840.0},
        ],
        earningsPerLink: [
          {'profile_name': 'VIP Scalpers', 'clients_count': 18, 'earnings': 4200.0},
          {'profile_name': 'Standard Rebate', 'clients_count': 14, 'earnings': 2800.0},
          {'profile_name': 'Crypto Influx', 'clients_count': 10, 'earnings': 1420.5},
        ],
      );
}

class _IbReferralLink {
  _IbReferralLink({
    required this.profileName,
    required this.referralLink,
    required this.referralCode,
    this.isPrimary = false,
    this.isLegacy = false,
    this.clientsCount = 0,
    this.color = const Color(0xFF3B82F6),
  });

  final String profileName;
  final String referralLink;
  final String referralCode;
  final bool isPrimary;
  final bool isLegacy;
  final int clientsCount;
  final Color color;

  static List<_IbReferralLink> demoList() => [
        _IbReferralLink(
          profileName: 'Standard Rebate (Direct)',
          referralLink: 'https://client.vtindex.com/?ref=VT-DIRECT',
          referralCode: 'VT-DIRECT',
          isPrimary: true,
          clientsCount: 28,
          color: const Color(0xFF3B82F6),
        ),
        _IbReferralLink(
          profileName: 'VIP Scalpers Profile',
          referralLink: 'https://client.vtindex.com/?ref=VT-SCALP',
          referralCode: 'VT-SCALP',
          clientsCount: 14,
          color: const Color(0xFFF59E0B),
        ),
      ];

  factory _IbReferralLink.fromJson(Map<String, dynamic> json, {int index = 0}) {
    const linkColors = [
      Color(0xFF3B82F6), // Blue
      Color(0xFFF59E0B), // Amber
      Color(0xFF10B981), // Emerald
      Color(0xFFA855F7), // Purple
      Color(0xFF06B6D4), // Cyan
      Color(0xFFEC4899), // Pink
    ];

    return _IbReferralLink(
      profileName: (json['profile_name'] ?? json['name'] ?? 'Default Profile').toString(),
      referralLink: (json['referral_link'] ?? json['link'] ?? json['url'] ?? '').toString(),
      referralCode: (json['referral_code'] ?? json['code'] ?? '').toString(),
      isPrimary: json['is_primary'] == true,
      isLegacy: json['is_legacy'] == true,
      clientsCount: (json['clients_count'] is num) ? (json['clients_count'] as num).toInt() : 0,
      color: linkColors[index % linkColors.length],
    );
  }
}

class _IbTradingAccount {
  _IbTradingAccount({
    required this.accountId,
    this.accountType = 'MT5 Account',
    this.groupAlias = 'Standard',
    this.groupName = '',
    this.totalLots = 0.0,
    this.totalDeposits = 0.0,
    this.totalWithdrawals = 0.0,
    this.totalCommission = 0.0,
  });

  final String accountId;
  final String accountType;
  final String groupAlias;
  final String groupName;
  final double totalLots;
  final double totalDeposits;
  final double totalWithdrawals;
  final double totalCommission;

  factory _IbTradingAccount.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return _IbTradingAccount(
      accountId: (json['account_id'] ?? json['id'] ?? '').toString(),
      accountType: (json['account_type'] ?? 'MT5 Account').toString(),
      groupAlias: (json['group_alias'] ?? json['group_name'] ?? 'Standard').toString(),
      groupName: (json['group_name'] ?? '').toString(),
      totalLots: parseNum(json['total_lots']),
      totalDeposits: parseNum(json['total_deposits']),
      totalWithdrawals: parseNum(json['total_withdrawals']),
      totalCommission: parseNum(json['total_commission']),
    );
  }
}

class _IbClient {
  _IbClient({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.registeredDate = '',
    this.referralCode = '',
    this.commissionProfileName = '',
    this.level = 1,
    this.isIb = false,
    this.ibRequestStatus = '',
    this.accounts = const [],
    this.clients = const [],
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String registeredDate;
  final String referralCode;
  final String commissionProfileName;
  final int level;
  final bool isIb;
  final String ibRequestStatus;
  final List<_IbTradingAccount> accounts;
  final List<_IbClient> clients;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'CL';
    if (parts.length == 1) return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  double get totalLots =>
      accounts.fold(0.0, (sum, a) => sum + a.totalLots);
  double get totalCommission =>
      accounts.fold(0.0, (sum, a) => sum + a.totalCommission);
  double get totalDeposits =>
      accounts.fold(0.0, (sum, a) => sum + a.totalDeposits);

  factory _IbClient.fromJson(Map<String, dynamic> json, {int inheritedLevel = 1}) {
    int lvl = inheritedLevel;
    if (json['level'] is num) {
      lvl = (json['level'] as num).toInt();
    } else if (json['level'] is String) {
      lvl = int.tryParse(json['level']) ?? inheritedLevel;
    }

    final rawAccounts = json['accounts'];
    final accList = <_IbTradingAccount>[];
    if (rawAccounts is List) {
      for (final a in rawAccounts.whereType<Map>()) {
        accList.add(_IbTradingAccount.fromJson(a.cast<String, dynamic>()));
      }
    }

    final rawChildren = json['clients'];
    final childList = <_IbClient>[];
    if (rawChildren is List) {
      for (final c in rawChildren.whereType<Map>()) {
        childList.add(_IbClient.fromJson(c.cast<String, dynamic>(), inheritedLevel: lvl + 1));
      }
    }

    final refCode = (json['referral_code'] ??
            (json['referral_link'] is Map ? json['referral_link']['code'] : ''))
        .toString();
    final profName = (json['commission_profile_name'] ??
            json['profile_name'] ??
            json['plan_name'] ??
            json['plan'] ??
            json['tag'] ??
            (json['referral_link'] is Map ? json['referral_link']['profile_name'] : ''))
        .toString();
    final regDate = (json['registered_date'] ??
            json['date_joined'] ??
            json['created_at'] ??
            json['joined_at'] ??
            '')
        .toString();

    return _IbClient(
      id: (json['id'] ?? json['client_id'] ?? '').toString(),
      name: (json['name'] ?? 'Client').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      registeredDate: regDate,
      referralCode: refCode,
      commissionProfileName: profName,
      level: lvl,
      isIb: json['is_ib'] == true || json['role'] == 'ib' || json['is_partner'] == true,
      ibRequestStatus: (json['ib_request_status'] ?? (json['status'] == 'pending' ? 'pending' : '')).toString(),
      accounts: accList,
      clients: childList,
    );
  }

  static List<_IbClient> demoTree() => [
        _IbClient(
          id: 'CL-101',
          name: 'Alexander Wright',
          email: 'alex.wright@example.com',
          level: 1,
          isIb: true,
          accounts: [
            _IbTradingAccount(
              accountId: '883921',
              accountType: 'MT5 Pro ECN',
              groupAlias: 'Raw Zero',
              totalLots: 142.0,
              totalDeposits: 25000.0,
              totalWithdrawals: 8000.0,
              totalCommission: 1850.0,
            ),
          ],
          clients: [
            _IbClient(
              id: 'CL-201',
              name: 'Marcus Vance',
              email: 'marcus.v@example.com',
              level: 2,
              accounts: [
                _IbTradingAccount(
                  accountId: '884102',
                  totalLots: 78.0,
                  totalDeposits: 12000.0,
                  totalCommission: 980.5,
                ),
              ],
            ),
          ],
        ),
        _IbClient(
          id: 'CL-102',
          name: 'Sophia Chen',
          email: 'sophia.c@example.com',
          level: 1,
          accounts: [
            _IbTradingAccount(
              accountId: '883995',
              totalLots: 110.5,
              totalDeposits: 18000.0,
              totalCommission: 1420.0,
            ),
          ],
        ),
      ];
}

class _IbCommissionTxn {
  _IbCommissionTxn({
    required this.id,
    this.clientUser = '',
    this.clientTradingAccount = '',
    this.positionSymbol = '',
    this.dealTicket = '',
    this.orderTicket = '',
    this.volumeLots = 0.0,
    this.profit = 0.0,
    this.commission = 0.0,
    this.createdAt = '',
    this.referralCode = '',
    this.commissionProfileName = '',
  });

  final String id;
  final String clientUser;
  final String clientTradingAccount;
  final String positionSymbol;
  final String dealTicket;
  final String orderTicket;
  final double volumeLots;
  final double profit;
  final double commission;
  final String createdAt;
  final String referralCode;
  final String commissionProfileName;

  factory _IbCommissionTxn.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    final amt = parseNum(json['amount'] ?? json['commission_to_ib'] ?? json['total_commission']);
    return _IbCommissionTxn(
      id: (json['id'] ?? json['deal_ticket'] ?? '').toString(),
      clientUser: (json['client_user'] ?? json['client_name'] ?? 'Client').toString(),
      clientTradingAccount: (json['client_trading_account'] ?? '').toString(),
      positionSymbol: (json['position_symbol'] ?? json['symbol'] ?? '—').toString(),
      dealTicket: (json['deal_ticket'] ?? '').toString(),
      orderTicket: (json['order_ticket'] ?? '').toString(),
      volumeLots: parseNum(json['volume_lots'] ?? json['lots']),
      profit: parseNum(json['profit']),
      commission: amt,
      createdAt: (json['created_at'] ?? '').toString(),
      referralCode: (json['referral_code'] ?? '').toString(),
      commissionProfileName: (json['commission_profile_name'] ?? '').toString(),
    );
  }
}

// ============================================================================
// CUSTOM VISUAL CHART PAINTERS
// ============================================================================

class _CommissionTrajectoryPainter extends CustomPainter {
  _CommissionTrajectoryPainter({
    required this.monthsData,
    required this.lineColor,
    required this.isDark,
    this.selectedIndex,
  });

  final List<Map<String, dynamic>> monthsData;
  final Color lineColor;
  final bool isDark;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (monthsData.isEmpty) return;

    final paddingBottom = 24.0;
    final paddingTop = 14.0;
    final chartHeight = size.height - paddingBottom - paddingTop;
    final chartWidth = size.width;

    double maxVal = 0.0;
    for (final item in monthsData) {
      final val = (item['total'] as num?)?.toDouble() ?? 0.0;
      if (val > maxVal) maxVal = val;
    }
    if (maxVal <= 0) maxVal = 100.0;
    maxVal *= 1.15; // Give 15% breathing room at the top

    // Grid lines
    final gridPaint = Paint()
      ..color = isDark ? const Color(0x1AFFFFFF) : const Color(0x12000000)
      ..strokeWidth = 1.0;

    const gridSteps = 4;
    for (int i = 0; i <= gridSteps; i++) {
      final y = paddingTop + (chartHeight / gridSteps) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // Points calculation
    final stepX = chartWidth / (monthsData.length - 1);
    final points = <Offset>[];
    for (int i = 0; i < monthsData.length; i++) {
      final val = (monthsData[i]['total'] as num?)?.toDouble() ?? 0.0;
      final x = i * stepX;
      final y = paddingTop + chartHeight - ((val / maxVal) * chartHeight);
      points.add(Offset(x, y));
    }

    // Build smooth cubic bezier curve
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = (p0.dx + p1.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Fill gradient under curve
    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height - paddingBottom)
      ..lineTo(points.first.dx, size.height - paddingBottom)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, paddingTop),
        Offset(0, size.height - paddingBottom),
        [
          lineColor.withValues(alpha: isDark ? 0.38 : 0.25),
          lineColor.withValues(alpha: 0.01),
        ],
      );
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw month label texts and dots
    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF88A4C8) : const Color(0xFF64748B),
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
    );

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = selectedIndex == i;

      // Draw dot
      final dotBgPaint = Paint()
        ..color = isDark ? const Color(0xFF071426) : Colors.white;
      final dotPaint = Paint()
        ..color = isSelected ? const Color(0xFFF5C438) : lineColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(p, isSelected ? 6.0 : 3.5, dotPaint);
      canvas.drawCircle(p, isSelected ? 3.0 : 1.8, dotBgPaint);

      // Draw label (skip alternate months on very small widths if crowded)
      if (size.width > 340 || i % 2 == 0 || i == points.length - 1) {
        final monthName = monthsData[i]['month']?.toString() ?? '';
        final textSpan = TextSpan(text: monthName, style: textStyle);
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(p.dx - tp.width / 2, size.height - paddingBottom + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CommissionTrajectoryPainter oldDelegate) =>
      oldDelegate.monthsData != monthsData ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.isDark != isDark ||
      oldDelegate.selectedIndex != selectedIndex;
}

// ============================================================================
// MAIN PARTNERSHIP PAGE: BROKERPARTNERSHIPPAGE
// ============================================================================

class BrokerPartnershipPage extends StatefulWidget {
  const BrokerPartnershipPage({
    super.key,
    this.onBack,
    this.onSelectPage,
  });

  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPage;

  @override
  State<BrokerPartnershipPage> createState() => _BrokerPartnershipPageState();
}

class _BrokerPartnershipPageState extends State<BrokerPartnershipPage> {
  bool _loading = true;
  bool _isIbApproved = false;
  String _ibStatus = ''; // 'pending', 'rejected', 'approved', ''
  bool _demoPreviewMode = false;

  // Earnings Calculator & FAQ state for partnership application view
  int _calcTraders = 25;
  int _calcLotsPerTrader = 10;
  final Set<int> _openFaqs = {0};
  bool _submittingApplication = false;
  bool _agreedToTerms = true;

  _IbDashboardData _dashboardData = _IbDashboardData();
  List<_IbReferralLink> _referralLinks = [];
  List<_IbClient> _clientTree = [];
  List<_IbCommissionTxn> _commissionTxns = [];

  // Interactive Trajectory Chart state
  String _chartMode = 'Consolidated'; // 'Consolidated' | 'Multi-Link'
  String _selectedLinkKey = 'all';
  int? _scrubbedMonthIndex;

  // Leaderboard toggle state: 'Ranked' | 'Links'
  String _leaderboardView = 'Ranked';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _loading = true);
    try {
      // 1. Fetch user's IB status first to avoid unauthorized 403 Forbidden queries
      Map<String, dynamic> statusRes = {};
      try {
        statusRes = await AuthApi.instance.getIbStatus();
      } catch (_) {}

      final isApproved = statusRes['approved'] == true ||
          statusRes['has_ib_status'] == true ||
          (statusRes['status'] != null &&
              statusRes['status'].toString().toLowerCase() == 'approved');
      final ibStatus = (statusRes['status'] ?? '').toString().toLowerCase();

      // If status explicitly says the user is not an approved IB, handle cleanly without calling 403 endpoints
      if (!isApproved && statusRes.isNotEmpty) {
        if (mounted) {
          setState(() {
            _isIbApproved = false;
            _ibStatus = ibStatus;
            _loading = false;
          });
        }
        return;
      }

      bool hit403 = false;
      final results = await Future.wait([
        AuthApi.instance.getIbStats().catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
        AuthApi.instance.getIbReferralLinks().catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
        AuthApi.instance.getIbCommissionTransactions().catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
        AuthApi.instance.getIbClientTree(page: 1, perPage: 1000).catchError((e) {
          if (e is AuthApiException && e.statusCode == 403) hit403 = true;
          return <String, dynamic>{};
        }),
      ]);

      if (hit403) {
        if (mounted) {
          setState(() {
            _isIbApproved = false;
            _ibStatus = ibStatus.isNotEmpty ? ibStatus : 'none';
            _loading = false;
          });
        }
        return;
      }

      final statsRes = results[0];
      final linksRes = results[1];
      final txnsRes = results[2];
      final treeRes = results[3];

      // Parse Dashboard Data
      final dbData = _IbDashboardData.fromJson(statsRes);

      // Parse Referral Links
      final parsedLinks = <_IbReferralLink>[];
      final rawLinks = linksRes['referral_links'] ??
          (linksRes['links'] is List ? linksRes['links'] : null);
      if (rawLinks is List && rawLinks.isNotEmpty) {
        for (var i = 0; i < rawLinks.length; i++) {
          if (rawLinks[i] is Map) {
            parsedLinks.add(_IbReferralLink.fromJson(rawLinks[i].cast<String, dynamic>(), index: i));
          }
        }
      } else {
        final legacyLink = linksRes['referral_link'] ?? linksRes['link'] ?? statsRes['referralLink'];
        if (legacyLink != null && legacyLink.toString().isNotEmpty) {
          parsedLinks.add(_IbReferralLink(
            profileName: 'Default Profile',
            referralLink: legacyLink.toString(),
            referralCode: (linksRes['referral_code'] ?? '').toString(),
            isPrimary: true,
          ));
        }
      }

      // Parse Commission Transactions
      final parsedTxns = <_IbCommissionTxn>[];
      final rawTxns = txnsRes['results'] ?? txnsRes['data'] ?? txnsRes['transactions'];
      if (rawTxns is List) {
        for (final item in rawTxns.whereType<Map>()) {
          parsedTxns.add(_IbCommissionTxn.fromJson(item.cast<String, dynamic>()));
        }
      }

      // Parse Client Tree
      final parsedClients = <_IbClient>[];
      final rawClients = treeRes['clients'] ?? treeRes['results'] ?? treeRes['data'];
      if (rawClients is List) {
        for (final item in rawClients.whereType<Map>()) {
          parsedClients.add(_IbClient.fromJson(item.cast<String, dynamic>()));
        }
      }

      if (mounted) {
        setState(() {
          _isIbApproved = true;
          _ibStatus = 'approved';
          _dashboardData = dbData;
          _referralLinks = parsedLinks;
          _commissionTxns = parsedTxns;
          _clientTree = parsedClients;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitIbApplication() async {
    setState(() => _submittingApplication = true);
    try {
      await AuthApi.instance.submitIbApplication();
      if (mounted) {
        setState(() {
          _ibStatus = 'pending';
          _submittingApplication = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: const [
                Icon(LucideIcons.checkCircle2, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'IB Application submitted! Compliance review is in progress.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submittingApplication = false);
        final msg = e is AuthApiException ? e.message : 'Failed to submit IB application.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(msg, style: const TextStyle(color: Colors.white)),
          ),
        );
      }
    }
  }

  // ==========================================================================
  // MODALS & DIALOGS
  // ==========================================================================

  void _showClientAccountsModal(_IbClient client) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = _PartnershipColors.of(sheetContext);
        final theme = _getLevelTheme(client.level, colors.isDark);
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.88,
            ),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                // Top drag bar
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.avatarBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.avatarBorder),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          client.initials,
                          style: TextStyle(
                            color: theme.avatarText,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.badgeBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'LEVEL ${client.level}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  theme.roleLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: colors.muted,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              client.name,
                              style: TextStyle(
                                color: colors.text,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (client.email.isNotEmpty)
                              Text(
                                client.email,
                                style: TextStyle(color: colors.muted, fontSize: 11.5),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(LucideIcons.x, color: colors.muted, size: 20),
                      ),
                    ],
                  ),
                ),
                // Badges row: Client ID, accounts count, IB status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.subCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.subBorder),
                        ),
                        child: Text(
                          'ID: ${client.id}',
                          style: TextStyle(color: colors.muted, fontSize: 10, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (client.isIb)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.green.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.shieldCheck, color: colors.green, size: 12),
                              const SizedBox(width: 4),
                              Text('IB Partner', style: TextStyle(color: colors.green, fontSize: 10, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        )
                      else if (client.ibRequestStatus == 'pending')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.gold.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.clock, color: colors.gold, size: 12),
                              const SizedBox(width: 4),
                              Text('IB Pending', style: TextStyle(color: colors.gold, fontSize: 10, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showConfirmIbModal(client);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide(color: colors.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: Icon(LucideIcons.userPlus, size: 12, color: colors.blue),
                          label: Text('Request IB', style: TextStyle(fontSize: 10, color: colors.blue, fontWeight: FontWeight.w800)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // 4-stat Portfolio Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _miniKpi(colors, 'Accounts', '${client.accounts.length}', LucideIcons.layers, colors.blue),
                      const SizedBox(width: 8),
                      _miniKpi(colors, 'Volume', '${client.totalLots.toStringAsFixed(2)} Lots', LucideIcons.activity, colors.green),
                      const SizedBox(width: 8),
                      _miniKpi(colors, 'Commission', '\$${client.totalCommission.toStringAsFixed(2)}', LucideIcons.coins, colors.gold),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: colors.border, height: 1),
                // Accounts list
                Expanded(
                  child: client.accounts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.creditCard, size: 36, color: colors.muted),
                              const SizedBox(height: 8),
                              Text('No trading accounts linked', style: TextStyle(color: colors.muted, fontSize: 13, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: client.accounts.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final acc = client.accounts[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colors.subCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: colors.subBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(LucideIcons.creditCard, size: 16, color: colors.blue),
                                          const SizedBox(width: 8),
                                          Text(
                                            acc.accountId,
                                            style: TextStyle(
                                              color: colors.text,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${acc.accountType} · ${acc.groupAlias}',
                                            style: TextStyle(color: colors.muted, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      FilledButton.tonalIcon(
                                        onPressed: () => _showAccountDetailModal(acc, clientName: client.name),
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(LucideIcons.arrowUpRight, size: 12),
                                        label: const Text('Positions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _accountStatPill('Volume', '${acc.totalLots.toStringAsFixed(2)} Lots', colors.muted, colors.text),
                                      _accountStatPill('Deposits', '\$${acc.totalDeposits.toStringAsFixed(2)}', colors.muted, colors.green),
                                      _accountStatPill('Commission', '\$${acc.totalCommission.toStringAsFixed(2)}', colors.muted, colors.gold),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniKpi(_PartnershipColors colors, String label, String value, IconData icon, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.subCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.subBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: accent),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(color: colors.muted, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountStatPill(String label, String value, Color labelColor, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 9.5)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: valColor, fontSize: 11.5, fontWeight: FontWeight.w800)),
      ],
    );
  }

  void _showAccountDetailModal(_IbTradingAccount account, {String? clientName}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = _PartnershipColors.of(sheetContext);
        return _AccountDetailSheet(account: account, clientName: clientName, colors: colors);
      },
    );
  }

  void _showConfirmIbModal(_IbClient client) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = _PartnershipColors.of(dialogContext);
        var submitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: colors.border)),
              contentPadding: const EdgeInsets.all(22),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(LucideIcons.shieldCheck, color: colors.blue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Confirm IB Request', style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text('Nominate client for IB status', style: TextStyle(color: colors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.subCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.subBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${client.name}', style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800)),
                        if (client.email.isNotEmpty)
                          Text('Email: ${client.email}', style: TextStyle(color: colors.muted, fontSize: 12)),
                        if (client.referralCode.isNotEmpty)
                          Text('Code: ${client.referralCode}', style: TextStyle(color: colors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'The request will be sent to the admin team for review. IB status remains pending until approved.',
                    style: TextStyle(color: colors.muted, fontSize: 11.5, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                        child: Text('Cancel', style: TextStyle(color: colors.muted, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: submitting
                            ? null
                            : () async {
                                setDialogState(() => submitting = true);
                                try {
                                  await AuthApi.instance.requestClientIb(client.id);
                                  showAppMessage('IB request submitted successfully!');
                                  if (mounted) {
                                    setState(() {
                                      _loadAllData();
                                    });
                                  }
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                } catch (e) {
                                  showAppMessage('Failed to submit IB request: $e');
                                  setDialogState(() => submitting = false);
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: submitting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(LucideIcons.send, size: 14),
                        label: Text(submitting ? 'Submitting...' : 'Confirm', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReferralQrModal(_IbReferralLink link) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = _PartnershipColors.of(sheetContext);
        final url = link.referralLink.isNotEmpty
            ? link.referralLink
            : 'https://client.vtindex.com/?ref=${link.referralCode}';

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Referral QR & Link', style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800)),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: Icon(LucideIcons.x, color: colors.muted, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
                    ],
                  ),
                  child: _VtIndexQrView(
                    data: url,
                    size: 190,
                  ),
                ),
                const SizedBox(height: 14),
                Text(link.profileName, style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                SelectableText(
                  url,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.muted, fontSize: 11),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: url));
                          showAppMessage('Referral link copied!');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(LucideIcons.copy, size: 15),
                        label: Text('Copy link', style: TextStyle(color: colors.text, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final shareUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent('Join my VT Index partner network: $url')}');
                          await launchUrl(shareUri, mode: LaunchMode.externalApplication);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(LucideIcons.share2, size: 15),
                        label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _enterDemoPreviewMode() {
    setState(() {
      _demoPreviewMode = true;
      if (_dashboardData.isEmpty) _dashboardData = _IbDashboardData.demo();
      if (_referralLinks.isEmpty) _referralLinks = _IbReferralLink.demoList();
      if (_clientTree.isEmpty) _clientTree = _IbClient.demoTree();
    });
  }

  void _exitDemoPreviewMode() {
    setState(() {
      _demoPreviewMode = false;
    });
  }

  // ==========================================================================
  // BUILD METHOD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);

    if (_loading) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: _PartnershipBackdrop(
          colors: colors,
          child: Center(
            child: CircularProgressIndicator(color: colors.blue),
          ),
        ),
      );
    }

    if (!_isIbApproved && !_demoPreviewMode) {
      return _buildIbApplicationScaffold(colors);
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      body: _PartnershipBackdrop(
        colors: colors,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAllData,
            color: colors.blue,
            backgroundColor: colors.card,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
              children: [
                if (_demoPreviewMode) _buildDemoPreviewBanner(colors),
                _buildTopBar(colors),
                const SizedBox(height: 14),
                _buildHeroCommandCenter(colors),
                const SizedBox(height: 16),
                _buildKpiMatrices(colors),
                const SizedBox(height: 16),
                _buildTrajectoryChartCard(colors),
                const SizedBox(height: 16),
                _buildLeaderboardCard(colors),
                const SizedBox(height: 18),
                _buildShortcutsSection(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // PARTNERSHIP APPLICATION & PROGRAM SECTIONS (NON-IB STATE)
  // ==========================================================================

  Widget _buildDemoPreviewBanner(_PartnershipColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD97706).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: Color(0xFFF59E0B), size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Demo Preview Mode • Real-time metrics will activate once your IB is approved.',
              style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          InkWell(
            onTap: _exitDemoPreviewMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Exit Demo', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIbApplicationScaffold(_PartnershipColors colors) {
    final isPending = _ibStatus == 'pending';

    return Scaffold(
      backgroundColor: colors.canvas,
      body: _PartnershipBackdrop(
        colors: colors,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAllData,
            color: colors.blue,
            backgroundColor: colors.card,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 116),
              children: [
                _buildIbAppTopBar(colors, isPending),
                const SizedBox(height: 14),
                _buildIbStatusAlert(colors, isPending),
                const SizedBox(height: 16),
                _buildIbHeroDeck(colors),
                const SizedBox(height: 18),
                _buildCalculatorSection(colors),
                const SizedBox(height: 18),
                _buildTierBreakdownSection(colors),
                const SizedBox(height: 18),
                _buildCoreBenefitsSection(colors),
                const SizedBox(height: 18),
                _buildIbFaqSection(colors),
                const SizedBox(height: 22),
                _buildApplyFooterCta(colors, isPending),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIbAppTopBar(_PartnershipColors colors, bool isPending) {
    return Row(
      children: [
        if (widget.onBack != null || Navigator.canPop(context))
          IconButton(
            onPressed: widget.onBack ?? () => Navigator.pop(context),
            icon: Icon(LucideIcons.arrowLeft, color: colors.text),
          )
        else
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.blue, const Color(0xFF1E3A8A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.network, color: Colors.white, size: 20),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Introducing Broker (IB)',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Multi-Tier Partnership Program',
                style: TextStyle(
                  color: colors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPending
                ? const Color(0xFFD97706).withValues(alpha: 0.15)
                : colors.blue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPending
                  ? const Color(0xFFD97706).withValues(alpha: 0.4)
                  : colors.blue.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPending ? LucideIcons.clock : LucideIcons.sparkles,
                size: 11,
                color: isPending ? const Color(0xFFF59E0B) : colors.blue,
              ),
              const SizedBox(width: 5),
              Text(
                isPending ? 'Under Review' : 'Enrolling',
                style: TextStyle(
                  color: isPending ? const Color(0xFFF59E0B) : colors.blue,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: _loadAllData,
          tooltip: 'Refresh Status',
          icon: Icon(LucideIcons.refreshCw, color: colors.muted, size: 18),
        ),
      ],
    );
  }

  Widget _buildIbStatusAlert(_PartnershipColors colors, bool isPending) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: colors.isDark
                ? const [Color(0xFF382305), Color(0xFF1E1404)]
                : const [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
          ),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.clock, color: Color(0xFFD97706), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Pending Review',
                        style: TextStyle(
                          color: colors.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Compliance review is actively in progress',
                        style: TextStyle(
                          color: colors.isDark ? const Color(0xFFD97706) : const Color(0xFFB45309),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your Introducing Broker application has been received and is awaiting compliance verification. We typically complete reviews within 2 to 24 business hours. Once approved, your commission wallet and referral links will be unlocked automatically.',
              style: TextStyle(
                color: colors.isDark ? const Color(0xFFFCD34D).withValues(alpha: 0.85) : const Color(0xFF78350F),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadAllData,
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: const Text('Check Approval Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 0,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _enterDemoPreviewMode,
                  icon: const Icon(LucideIcons.sparkles, size: 14),
                  label: const Text('Preview Command Center'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                    side: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: colors.isDark
              ? const [Color(0xFF0C246E), Color(0xFF071426)]
              : const [Color(0xFFE8EEF9), Color(0xFFF8FAFC)],
        ),
        border: Border.all(color: colors.blue.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colors.blue.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.shieldCheck, color: colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Become a Certified VT-Index Partner',
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Earn up to \$8.00 per standard lot across 3 tiers',
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Enroll as an Introducing Broker to start generating lifetime automated daily commissions on all trading volume generated by your clients and subordinate Sub-IB networks.',
            style: TextStyle(
              color: colors.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _showIbTermsModal,
                icon: const Icon(LucideIcons.send, size: 14),
                label: const Text('Apply for IB Partnership'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _enterDemoPreviewMode,
                icon: const Icon(LucideIcons.sparkles, size: 14),
                label: const Text('Preview Command Center'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.text,
                  side: BorderSide(color: colors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIbHeroDeck(_PartnershipColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.isDark
              ? const [Color(0xFF071A57), Color(0xFF0A2675), Color(0xFF0D338E)]
              : const [Color(0xFF0A255E), Color(0xFF103D88), Color(0xFF1652B0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('INSTITUTIONAL TIER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
              ),
              const Spacer(),
              const Icon(LucideIcons.zap, size: 14, color: Color(0xFFF5C438)),
              const SizedBox(width: 4),
              const Text('Instant Daily Rebate', style: TextStyle(color: Color(0xFFF5C438), fontSize: 11, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Accelerate Your Trading Revenue',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            'Partner with VT-Index to unlock multi-tiered override rebates on FX, Metals, Indices, and Crypto.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroStatCell('Base Rebate Pool', '\$8.00 / lot'),
              _heroStatCell('Level 1 Direct', '50% (\$4.00)'),
              _heroStatCell('Sub-IB Tiers', '20% + 10%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatCell(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9.5), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorSection(_PartnershipColors colors) {
    final directLots = _calcTraders * _calcLotsPerTrader;
    final l1Monthly = directLots * 4.0;
    final l2Lots = (directLots * 0.4).round();
    final l2Monthly = l2Lots * 1.6;
    final l3Lots = (directLots * 0.25).round();
    final l3Monthly = l3Lots * 0.8;
    final totalMonthly = l1Monthly + l2Monthly + l3Monthly;
    final totalAnnual = totalMonthly * 12;

    return _PartnershipGlassPanel(
      colors: colors,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.calculator, color: colors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Revenue Calculator',
                      style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Simulate potential earnings across 3 tiers',
                      style: TextStyle(color: colors.muted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Slider 1: Active Traders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Direct Traders', style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_calcTraders Traders', style: TextStyle(color: colors.blue, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.blue,
              thumbColor: colors.blue,
              inactiveTrackColor: colors.border,
              trackHeight: 4,
            ),
            child: Slider(
              value: _calcTraders.toDouble(),
              min: 1,
              max: 150,
              divisions: 149,
              onChanged: (val) => setState(() => _calcTraders = val.round()),
            ),
          ),
          const SizedBox(height: 12),
          // Slider 2: Lots per Trader
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Avg Lots / Trader / Month', style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_calcLotsPerTrader Lots', style: TextStyle(color: colors.gold, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.gold,
              thumbColor: colors.gold,
              inactiveTrackColor: colors.border,
              trackHeight: 4,
            ),
            child: Slider(
              value: _calcLotsPerTrader.toDouble(),
              min: 1,
              max: 50,
              divisions: 49,
              onChanged: (val) => setState(() => _calcLotsPerTrader = val.round()),
            ),
          ),
          const SizedBox(height: 16),
          // KPI Results Cards
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors.isDark
                    ? const [Color(0xFF0F275A), const Color(0xFF0A1C40)]
                    : const [Color(0xFFE8F0FE), const Color(0xFFD6E4FC)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Direct Monthly Volume', style: TextStyle(color: colors.muted, fontSize: 12)),
                    Text('$directLots Lots', style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Projected Monthly Revenue', style: TextStyle(color: colors.muted, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${totalMonthly.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: colors.blue,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Projected Annual', style: TextStyle(color: colors.muted, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${totalAnnual.toStringAsFixed(0)} / yr',
                          style: TextStyle(
                            color: colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tier breakdown chips
          Row(
            children: [
              _calcTierChip(colors, 'L1 Direct (50%)', '\$${l1Monthly.toStringAsFixed(0)}', colors.blue),
              const SizedBox(width: 8),
              _calcTierChip(colors, 'L2 Sub-IB (20%)', '\$${l2Monthly.toStringAsFixed(0)}', colors.gold),
              const SizedBox(width: 8),
              _calcTierChip(colors, 'L3 Extended (10%)', '\$${l3Monthly.toStringAsFixed(0)}', colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcTierChip(_PartnershipColors colors, String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: colors.subCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.subBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: colors.muted, fontSize: 9.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildTierBreakdownSection(_PartnershipColors colors) {
    final tiers = [
      {
        'level': 'Level 1',
        'title': 'Direct Client Network',
        'rate': '50% Pool Share (\$4.00/lot)',
        'desc': 'Earn direct commission on every closed position traded by clients you introduce.',
        'color': colors.blue,
        'icon': LucideIcons.user,
      },
      {
        'level': 'Level 2',
        'title': 'Sub-IB Network',
        'rate': '20% Pool Share (\$1.60/lot)',
        'desc': 'Receive automated sub-tier overrides on all volume generated by clients introduced by your Sub-IBs.',
        'color': colors.gold,
        'icon': LucideIcons.users,
      },
      {
        'level': 'Level 3',
        'title': 'Extended Ecosystem',
        'rate': '10% Pool Share (\$0.80/lot)',
        'desc': 'Compound continuous override revenue from third-generation clients referred across your downline network.',
        'color': colors.green,
        'icon': LucideIcons.globe,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3-TIER REBATE ARCHITECTURE',
          style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
        ...tiers.map((t) {
          final color = t['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PartnershipGlassPanel(
              colors: colors,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(t['icon'] as IconData, color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(t['title'] as String, style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w800)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(t['level'] as String, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(t['rate'] as String, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(t['desc'] as String, style: TextStyle(color: colors.muted, fontSize: 11.5, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCoreBenefitsSection(_PartnershipColors colors) {
    final benefits = [
      {'title': '\$8.00/Lot Pool', 'desc': 'Transparent multi-tier model across the complete rebate structure.', 'icon': LucideIcons.badgePercent},
      {'title': '3-Tier Sub-IB Tree', 'desc': 'Automated multi-level overrides on direct and subordinate networks.', 'icon': LucideIcons.network},
      {'title': 'Daily Settlements', 'desc': 'Instant commission credits with zero payout or transfer fees.', 'icon': LucideIcons.wallet},
      {'title': 'Partner CRM', 'desc': 'Real-time MT5 trading telemetry, conversion stats, and client drilldowns.', 'icon': LucideIcons.barChart3},
      {'title': 'QR & Link Studio', 'desc': 'Pre-built landing pages, campaign profiles, and dynamic QR generators.', 'icon': LucideIcons.qrCode},
      {'title': 'Dedicated Manager', 'desc': '1-on-1 strategic growth advice, custom profiles, and priority desk.', 'icon': LucideIcons.headphones},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTNER ADVANTAGES',
          style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.25,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, idx) {
            final b = benefits[idx];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(b['icon'] as IconData, size: 20, color: colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    b['title'] as String,
                    style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    b['desc'] as String,
                    style: TextStyle(color: colors.muted, fontSize: 10.5, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIbFaqSection(_PartnershipColors colors) {
    final faqs = [
      {
        'q': 'How does the commission split work across the 3 tiers?',
        'a': 'Commissions are distributed from an \$8.00/lot standard rebate pool across 3 tiers: Level 1 (Direct Referrals) receives 50%, Level 2 (Sub-IBs) receives 20%, and Level 3 (Extended Network) receives 10%. Overrides compound automatically without reducing your partners\' earnings.',
      },
      {
        'q': 'What is the VT-Index Introducing Broker (IB) Program?',
        'a': 'The VT-Index IB program enables traders, educators, fund managers, and digital marketers to earn lifetime recurring commissions by introducing clients to our institutional multi-asset MT5 platform.',
      },
      {
        'q': 'How and when are my commissions paid?',
        'a': 'Commissions are calculated automatically upon trade closure and credited on a daily basis directly to your Partner Commission Wallet. You can withdraw funds instantly to crypto, bank wire, or transfer to your trading account with zero fees.',
      },
      {
        'q': 'Are there any setup fees or minimum trading volume requirements?',
        'a': 'No. Becoming an IB partner at VT-Index is 100% free with no upfront setup costs, no mandatory deposit, and no restrictive quotas. You start earning from the very first lot traded by your referred clients.',
      },
      {
        'q': 'How long does the approval process take?',
        'a': 'Our compliance and partnership specialists review IB requests promptly—typically within 2 to 24 hours on business days. Once verified, your Partner Portal and unique referral links activate instantly.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
        ),
        const SizedBox(height: 10),
        ...faqs.asMap().entries.map((entry) {
          final idx = entry.key;
          final f = entry.value;
          final isOpen = _openFaqs.contains(idx);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isOpen ? colors.blue.withValues(alpha: 0.5) : colors.border),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: isOpen,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      if (expanded) {
                        _openFaqs.add(idx);
                      } else {
                        _openFaqs.remove(idx);
                      }
                    });
                  },
                  title: Text(
                    f['q']!,
                    style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  children: [
                    Text(
                      f['a']!,
                      style: TextStyle(color: colors.muted, fontSize: 11.5, height: 1.45),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildApplyFooterCta(_PartnershipColors colors, bool isPending) {
    if (isPending) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFD97706).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(LucideIcons.clock, size: 16, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text(
              'Application Submitted • Awaiting Compliance Approval',
              style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submittingApplication ? null : _showIbTermsModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
          shadowColor: colors.blue.withValues(alpha: 0.4),
        ),
        child: _submittingApplication
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.send, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Join VT-Index Partnership Program',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
      ),
    );
  }

  void _showIbTermsModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = _PartnershipColors.of(sheetContext);
        var agreed = _agreedToTerms;
        var submitting = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border.all(color: colors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.muted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colors.blue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(LucideIcons.fileCheck2, color: colors.blue, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('IB Partnership Agreement', style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text('Review guidelines and confirm your application', style: TextStyle(color: colors.muted, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.subCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.subBorder),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Program Terms & Rebate Structure', style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Text(
                                  '1. The standard commission pool is calculated up to \$8.00 per standard lot traded by eligible clients on MT5.\n\n'
                                  '2. Multi-tier commissions are allocated at 50% for Level 1 (Direct Clients), 20% for Level 2 (Sub-IBs), and 10% for Level 3 (Extended Network).\n\n'
                                  '3. Commissions are calculated upon position closure and deposited to your Partner Commission Ledger daily.\n\n'
                                  '4. Internal transfers to your own live MT5 trading account and external withdrawals carry zero processing fees.\n\n'
                                  '5. Partner activity is monitored for spam, deceptive advertising, or abusive market manipulation. Violation may result in partner status revocation.',
                                  style: TextStyle(color: colors.muted, fontSize: 12.5, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          setSheetState(() => agreed = !agreed);
                          setState(() => _agreedToTerms = agreed);
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: agreed,
                              activeColor: colors.blue,
                              onChanged: (val) {
                                setSheetState(() => agreed = val ?? false);
                                setState(() => _agreedToTerms = agreed);
                              },
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the VT-Index Introducing Broker Terms & Guidelines',
                                style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (!agreed || submitting)
                              ? null
                              : () async {
                                  setSheetState(() => submitting = true);
                                  Navigator.pop(sheetContext);
                                  await _submitIbApplication();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: submitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(LucideIcons.send, size: 16),
                                    SizedBox(width: 8),
                                    Text('Submit IB Application', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // UI SECTIONS
  // ==========================================================================

  Widget _buildTopBar(_PartnershipColors colors) {
    return Row(
      children: [
        if (widget.onBack != null)
          IconButton(
            onPressed: widget.onBack,
            icon: Icon(LucideIcons.arrowLeft, color: colors.text),
          )
        else
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.blue, const Color(0xFF1E3A8A)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.network, color: Colors.white, size: 20),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Partnership Command Center',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Manage clients, commissions and withdrawals',
                style: TextStyle(color: colors.muted, fontSize: 11.5),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: _loadAllData,
          icon: _loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colors.blue),
                )
              : Icon(LucideIcons.refreshCw, color: colors.muted, size: 18),
        ),
      ],
    );
  }

  Widget _buildHeroCommandCenter(_PartnershipColors colors) {
    final direct = _dashboardData.directClients;
    final total = _dashboardData.totalClients;
    final sub = math.max(0, total - direct);
    final velocityRatio = total > 0
        ? math.min(1.0, (_dashboardData.currentMonthVolume / math.max(1.0, _dashboardData.totalVolume)))
        : 0.5;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.isDark
              ? const [Color(0xFF071A57), Color(0xFF09246F), Color(0xFF0D338E)]
              : const [Color(0xFF0A255E), Color(0xFF103D88), Color(0xFF1652B0)],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x2E040F36), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: Text(
                          'PAYOUT READY',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      if (_referralLinks.isNotEmpty) {
                        _showReferralQrModal(_referralLinks[0]);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(LucideIcons.qrCode, size: 13),
                    label: const Text('Instant QR', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const BrokerCommissionWithdrawalPage()),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(LucideIcons.wallet, size: 13),
                    label: const Text('Withdraw', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Available Balance display
          Text(
            'Liquid Available Balance',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$${_dashboardData.commissionBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              const Text('USD', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 14),
          // 3-stat summary strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _heroStatCol('Month Earnings', '\$${_dashboardData.currentMonthEarnings.toStringAsFixed(2)}')),
                Expanded(child: _heroStatCol('Total Payouts', '\$${_dashboardData.totalWithdrawals.toStringAsFixed(2)}')),
                Expanded(child: _heroStatCol('Network Clients', '${_dashboardData.totalClients} ($direct Direct)')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Volume Velocity Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(LucideIcons.zap, size: 14, color: Color(0xFFF5C438)),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Volume Velocity Meter',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_dashboardData.currentMonthVolume.toStringAsFixed(2)} Lots (30D)',
                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: velocityRatio,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All-Time: ${_dashboardData.totalVolume.toStringAsFixed(2)} Lots',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10),
              ),
              Text(
                'Ratio: $direct Direct / $sub Sub-IB',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStatCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildKpiMatrices(_PartnershipColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FINANCIAL & VOLUME TELEMETRY',
          style: TextStyle(
            color: colors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.1,
          children: [
            _kpiCard(colors, 'Total Earnings', '\$${_dashboardData.totalEarnings.toStringAsFixed(2)}', LucideIcons.coins, colors.gold),
            _kpiCard(colors, 'Commission Balance', '\$${_dashboardData.commissionBalance.toStringAsFixed(2)}', LucideIcons.wallet, colors.blue),
            _kpiCard(colors, 'Total Clients', '${_dashboardData.totalClients}', LucideIcons.users, colors.green),
            _kpiCard(colors, 'Total Traded Volume', '${_dashboardData.totalVolume.toStringAsFixed(2)} Lots', LucideIcons.activity, const Color(0xFF06B6D4)),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(_PartnershipColors colors, String label, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.muted, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.text, fontSize: 13.5, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrajectoryChartCard(_PartnershipColors colors) {
    final months = _dashboardData.earningsPerMonth;

    return _PartnershipGlassPanel(
      colors: colors,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Commission Trajectory',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.text, fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '12-Month Performance Dynamics',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.muted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Mode switcher
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.subCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.subBorder),
                ),
                child: Row(
                  children: [
                    _togglePill(colors, 'Consolidated', _chartMode == 'Consolidated', () {
                      setState(() => _chartMode = 'Consolidated');
                    }),
                    _togglePill(colors, 'Multi-Link', _chartMode == 'Multi-Link', () {
                      setState(() => _chartMode = 'Multi-Link');
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Painter Canvas
          GestureDetector(
            onPanUpdate: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null && months.isNotEmpty) {
                final localX = details.localPosition.dx.clamp(0.0, box.size.width);
                final step = box.size.width / (months.length - 1);
                final index = (localX / step).round().clamp(0, months.length - 1);
                setState(() => _scrubbedMonthIndex = index);
              }
            },
            onPanEnd: (_) => setState(() => _scrubbedMonthIndex = null),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: _CommissionTrajectoryPainter(
                  monthsData: months,
                  lineColor: colors.blue,
                  isDark: colors.isDark,
                  selectedIndex: _scrubbedMonthIndex,
                ),
              ),
            ),
          ),
          if (_scrubbedMonthIndex != null && _scrubbedMonthIndex! < months.length)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${months[_scrubbedMonthIndex!]['month']}: \$${((months[_scrubbedMonthIndex!]['total'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          // Per link badges in Multi-Link mode
          if (_chartMode == 'Multi-Link' && _referralLinks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _referralLinks.map((link) {
                final isSelected = _selectedLinkKey == link.referralCode;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedLinkKey = isSelected ? 'all' : link.referralCode;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? link.color.withValues(alpha: 0.2) : colors.subCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? link.color : colors.subBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: link.color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(link.profileName, style: TextStyle(color: colors.text, fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _togglePill(_PartnershipColors colors, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : colors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardCard(_PartnershipColors colors) {
    final clients = _dashboardData.earningsPerClient;

    return _PartnershipGlassPanel(
      colors: colors,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _leaderboardView == 'Ranked' ? 'Top Client Performers' : 'Referral Links Share',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.text, fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: colors.subCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.subBorder),
                ),
                child: Row(
                  children: [
                    _togglePill(colors, 'Ranked', _leaderboardView == 'Ranked', () {
                      setState(() => _leaderboardView = 'Ranked');
                    }),
                    _togglePill(colors, 'Links', _leaderboardView == 'Links', () {
                      setState(() => _leaderboardView = 'Links');
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_leaderboardView == 'Ranked')
            clients.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No client performance records yet', style: TextStyle(color: colors.muted, fontSize: 12)),
                    ),
                  )
                : Column(
                    children: clients.take(6).map((item) {
                      final rank = clients.indexOf(item) + 1;
                      final name = (item['name'] ?? 'Client').toString();
                      final comm = ((item['total_commission'] as num?)?.toDouble() ?? 0.0);
                      final vol = ((item['total_volume'] as num?)?.toDouble() ?? 0.0);

                      return InkWell(
                        onTap: () {
                          final cId = (item['client_id'] ?? '').toString();
                          final matched = _clientTree.where((c) => c.id == cId || c.name.toLowerCase() == name.toLowerCase()).firstOrNull;
                          _showClientAccountsModal(matched ?? _IbClient(id: cId, name: name));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.subCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.subBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: rank == 1
                                      ? colors.gold
                                      : (rank == 2 ? const Color(0xFF94A3B8) : (rank == 3 ? const Color(0xFFB45309) : colors.border)),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '#$rank',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
                                    Text('${vol.toStringAsFixed(2)} Lots', style: TextStyle(color: colors.muted, fontSize: 10.5)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${comm.toStringAsFixed(2)}',
                                    style: TextStyle(color: colors.green, fontSize: 13, fontWeight: FontWeight.w900),
                                  ),
                                  Text('Yield', style: TextStyle(color: colors.muted, fontSize: 9.5)),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Icon(LucideIcons.chevronRight, size: 14, color: colors.muted),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )
          else
            _referralLinks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No referral links registered', style: TextStyle(color: colors.muted, fontSize: 12)),
                    ),
                  )
                : Column(
                    children: _referralLinks.map((link) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.subCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.subBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(width: 10, height: 10, decoration: BoxDecoration(color: link.color, shape: BoxShape.circle)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(link.profileName, style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
                                    Text('Code: ${link.referralCode}', style: TextStyle(color: colors.muted, fontSize: 10.5, fontFamily: 'monospace')),
                                  ],
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: link.referralCode));
                                showAppMessage('Code ${link.referralCode} copied!');
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                side: BorderSide(color: colors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              icon: const Icon(LucideIcons.copy, size: 11),
                              label: Text('Copy', style: TextStyle(fontSize: 10, color: colors.text)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
        ],
      ),
    );
  }

  Widget _buildShortcutsSection(_PartnershipColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PARTNERSHIP TOOLS & REPORTS',
          style: TextStyle(
            color: colors.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.users,
          label: 'Client Network Hierarchy',
          subtitle: 'View multi-level downline tiers, accounts, and client details',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BrokerClientTreePage()),
          ),
        ),
        const SizedBox(height: 8),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.creditCard,
          label: 'Commission Ledger & History',
          subtitle: '${_commissionTxns.isNotEmpty ? '${_commissionTxns.length} recorded deals' : 'Complete trade deal records'}, volume, and generated commissions',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BrokerCommissionLedgerPage()),
          ),
        ),
        const SizedBox(height: 8),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.wallet,
          label: 'Commission Payout & Withdrawal',
          subtitle: 'Instant internal transfer of available commission to live MT5 accounts',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BrokerCommissionWithdrawalPage()),
          ),
        ),
        const SizedBox(height: 8),
        _shortcutItem(
          colors: colors,
          icon: LucideIcons.qrCode,
          label: 'Referral Link & QR Studio',
          subtitle: 'Branded referral profiles, marketing links, and social sharing',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BrokerReferralStudioPage()),
          ),
        ),
      ],
    );
  }

  Widget _shortcutItem({
    required _PartnershipColors colors,
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _PartnershipGlassPanel(
      colors: colors,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 14,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: colors.blue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 1),
                Text(subtitle, style: TextStyle(color: colors.muted, fontSize: 11)),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 16, color: colors.muted),
        ],
      ),
    );
  }
}

// ============================================================================
// ACCOUNT DETAIL SHEET WITH LIVE POSITIONS
// ============================================================================

class _AccountDetailSheet extends StatefulWidget {
  const _AccountDetailSheet({
    required this.account,
    this.clientName,
    required this.colors,
  });

  final _IbTradingAccount account;
  final String? clientName;
  final _PartnershipColors colors;

  @override
  State<_AccountDetailSheet> createState() => _AccountDetailSheetState();
}

class _AccountDetailSheetState extends State<_AccountDetailSheet> {
  bool _loading = true;
  Map<String, dynamic> _details = {};
  List<Map<String, dynamic>> _positions = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AuthApi.instance.getAccountDetails(widget.account.accountId).catchError((_) => <String, dynamic>{}),
        AuthApi.instance.getOpenPositions(widget.account.accountId).catchError((_) => <Map<String, dynamic>>[]),
      ]);
      if (mounted) {
        setState(() {
          _details = results[0] as Map<String, dynamic>;
          _positions = results[1] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final balance = _details['balance']?.toString() ?? '0.00';
    final equity = _details['equity']?.toString() ?? '0.00';
    final margin = _details['margin']?.toString() ?? '0.00';
    final profit = _details['profit']?.toString() ?? '0.00';
    final profitNum = double.tryParse(profit) ?? 0.0;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Account ${widget.account.accountId}', style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('MT5 Connected', style: TextStyle(color: colors.green, fontSize: 9.5, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      if (widget.clientName != null)
                        Text('Client: ${widget.clientName}', style: TextStyle(color: colors.muted, fontSize: 11.5)),
                    ],
                  ),
                  IconButton(
                    onPressed: _loading ? null : _fetchDetails,
                    icon: _loading
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.blue))
                        : Icon(LucideIcons.refreshCw, color: colors.muted, size: 18),
                  ),
                ],
              ),
            ),
            // Metrics row: Balance, Equity, Margin, Floating P/L
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _metricBox(colors, 'Balance', '\$$balance', colors.text),
                  const SizedBox(width: 8),
                  _metricBox(colors, 'Equity', '\$$equity', colors.blue),
                  const SizedBox(width: 8),
                  _metricBox(colors, 'Margin', '\$$margin', colors.muted),
                  const SizedBox(width: 8),
                  _metricBox(colors, 'Floating P/L', '\$$profit', profitNum >= 0 ? colors.green : colors.red),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: colors.border, height: 1),
            // Open Positions List
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Open Positions (${_positions.length})', style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800)),
                  Text('Real-time snapshot', style: TextStyle(color: colors.muted, fontSize: 10.5)),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: colors.blue))
                  : _positions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.activity, size: 32, color: colors.muted),
                              const SizedBox(height: 8),
                              Text('No open positions on this account', style: TextStyle(color: colors.muted, fontSize: 12.5)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _positions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final pos = _positions[index];
                            final sym = (pos['symbol'] ?? '—').toString();
                            final type = (pos['type'] ?? 'BUY').toString();
                            final isBuy = type.toUpperCase().contains('BUY');
                            final vol = pos['volume']?.toString() ?? '0.01';
                            final openPrice = pos['open_price']?.toString() ?? '0.00';
                            final curPrice = pos['current_price']?.toString() ?? '0.00';
                            final pnl = (pos['profit'] as num?)?.toDouble() ?? 0.0;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.subCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.subBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isBuy ? colors.green.withValues(alpha: 0.15) : colors.red.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isBuy ? 'BUY' : 'SELL',
                                          style: TextStyle(
                                            color: isBuy ? colors.green : colors.red,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(sym, style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800)),
                                          Text('$vol Lots · Open: $openPrice · Current: $curPrice', style: TextStyle(color: colors.muted, fontSize: 10.5)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: pnl >= 0 ? colors.green : colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(_PartnershipColors colors, String label, String value, Color valColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: colors.subCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.subBorder),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: colors.muted, fontSize: 9)),
            const SizedBox(height: 2),
            Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: valColor, fontSize: 11.5, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SUB-PAGE: BROKERCLIENTTREEPAGE (CLIENT LIST & HIERARCHY)
// ============================================================================

class BrokerClientTreePage extends StatefulWidget {
  const BrokerClientTreePage({super.key});

  @override
  State<BrokerClientTreePage> createState() => _BrokerClientTreePageState();
}

class _BrokerClientTreePageState extends State<BrokerClientTreePage> {
  bool _loading = true;
  List<_IbClient> _clients = [];
  final Set<String> _expandedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTree();
  }

  Future<void> _fetchTree() async {
    setState(() => _loading = true);
    try {
      final res = await AuthApi.instance.getIbClientTree(page: 1, perPage: 1000);
      final rawList = res['clients'] ?? res['results'] ?? res['data'];
      final parsed = <_IbClient>[];
      if (rawList is List) {
        for (final item in rawList.whereType<Map>()) {
          parsed.add(_IbClient.fromJson(item.cast<String, dynamic>()));
        }
      }
      if (mounted) {
        setState(() {
          _clients = parsed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _countAll(List<_IbClient> list) {
    int total = 0;
    for (final c in list) {
      total += 1 + _countAll(c.clients);
    }
    return total;
  }

  int _maxDepth(List<_IbClient> list, int current) {
    int m = current;
    for (final c in list) {
      if (c.clients.isNotEmpty) {
        m = math.max(m, _maxDepth(c.clients, current + 1));
      }
    }
    return m;
  }

  List<_IbClient> _filterClients(List<_IbClient> list, String q) {
    if (q.isEmpty) return list;
    final res = <_IbClient>[];
    for (final c in list) {
      final matches = c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.referralCode.toLowerCase().contains(q) ||
          c.accounts.any((a) => a.accountId.contains(q));
      final subMatches = _filterClients(c.clients, q);
      if (matches || subMatches.isNotEmpty) {
        res.add(_IbClient(
          id: c.id,
          name: c.name,
          email: c.email,
          phone: c.phone,
          registeredDate: c.registeredDate,
          referralCode: c.referralCode,
          commissionProfileName: c.commissionProfileName,
          level: c.level,
          isIb: c.isIb,
          ibRequestStatus: c.ibRequestStatus,
          accounts: c.accounts,
          clients: subMatches,
        ));
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    final totalNetwork = _countAll(_clients);
    final direct = _clients.length;
    final subTier = math.max(0, totalNetwork - direct);
    final depth = _maxDepth(_clients, 1);
    final filtered = _filterClients(_clients, _searchQuery.trim().toLowerCase());

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Client Network Hierarchy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () => _showAddClientModal(colors),
            icon: const Icon(LucideIcons.userPlus),
            tooltip: 'Add Client',
          ),
          IconButton(
            onPressed: _fetchTree,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _PartnershipBackdrop(
        colors: colors,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
          children: [
            // Search Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.search, size: 16, color: colors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: colors.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search client by name, email, code or account...',
                        hintStyle: TextStyle(color: colors.muted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 14),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Network stat badges
            Row(
              children: [
                _treeStatChip(colors, 'TOTAL NETWORK', '$totalNetwork', LucideIcons.users, colors.gold),
                const SizedBox(width: 8),
                _treeStatChip(colors, 'DIRECT (L1)', '$direct', LucideIcons.user, colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _treeStatChip(colors, 'SUB-TIER (L2+)', '$subTier', LucideIcons.network, colors.green),
                const SizedBox(width: 8),
                _treeStatChip(colors, 'MAX DEPTH', 'L$depth', LucideIcons.gitBranch, const Color(0xFFA855F7)),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: colors.blue)),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.users, size: 40, color: colors.muted),
                      const SizedBox(height: 10),
                      Text('No clients found in this network', style: TextStyle(color: colors.muted, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map((client) => _buildClientNode(client, colors, 0)),
          ],
        ),
      ),
    );
  }

  Widget _treeStatChip(_PartnershipColors colors, String label, String value, IconData icon, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.muted, fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientNode(_IbClient client, _PartnershipColors colors, int depth) {
    final theme = _getLevelTheme(client.level, colors.isDark);
    final hasChildren = client.clients.isNotEmpty;
    final isExpanded = _expandedIds.contains(client.id);

    final avatarWidget = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: theme.avatarBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.avatarBorder),
      ),
      alignment: Alignment.center,
      child: Text(
        client.initials,
        style: TextStyle(color: theme.avatarText, fontWeight: FontWeight.w900, fontSize: 13),
      ),
    );

    final clientInfoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line 1: Name + Level + Plan/Tag Badge
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              client.name,
              style: TextStyle(color: colors.text, fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.badgeBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: theme.badgeBg.withValues(alpha: 0.5)),
              ),
              child: Text(
                'L${client.level}',
                style: TextStyle(color: theme.badgeBg, fontSize: 9.5, fontWeight: FontWeight.w900),
              ),
            ),
            if (client.commissionProfileName.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: colors.gold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  client.commissionProfileName,
                  style: TextStyle(color: colors.gold, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        // Line 2: email · phone · Joined YYYY-MM-DD · 🔗 Code 📋
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 3,
          children: [
            if (client.email.isNotEmpty)
              Text(
                client.email,
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
            if (client.phone.isNotEmpty)
              Text(
                client.phone,
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
            if (client.registeredDate.isNotEmpty)
              Text(
                'Joined ${client.registeredDate.split("T").first}',
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
            if (client.referralCode.isNotEmpty)
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: client.referralCode));
                  showAppMessage('Referral code copied: ${client.referralCode}');
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.link2, size: 11.5, color: colors.blue),
                      const SizedBox(width: 3),
                      Text(
                        client.referralCode,
                        style: TextStyle(color: colors.blue, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 3),
                      Icon(LucideIcons.copy, size: 11, color: colors.muted),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );

    final actionItems = <Widget>[
      if (client.isIb) ...[
        // Referrals badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.isDark ? colors.subCard : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.users, size: 12, color: colors.muted),
              const SizedBox(width: 4),
              Text(
                '${client.clients.length} ${client.clients.length == 1 ? 'referral' : 'referrals'}',
                style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        // Lots badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.green.withValues(alpha: 0.4)),
          ),
          child: Text(
            '${client.totalLots.toStringAsFixed(2)} lots',
            style: TextStyle(color: colors.green, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        // Earned badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.green.withValues(alpha: 0.4)),
          ),
          child: Text(
            '\$${client.totalCommission.toStringAsFixed(2)} earned',
            style: TextStyle(color: colors.green, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        // IB Partner badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.green.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.shieldCheck, size: 12, color: colors.green),
              const SizedBox(width: 4),
              Text(
                'IB Partner',
                style: TextStyle(color: colors.green, fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ] else ...[
        if (client.ibRequestStatus == 'pending')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.gold.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 12, color: colors.gold),
                const SizedBox(width: 4),
                Text('IB Pending', style: TextStyle(color: colors.gold, fontSize: 10.5, fontWeight: FontWeight.w800)),
              ],
            ),
          )
        else
          // Request IB Button!
          OutlinedButton.icon(
            onPressed: () => _showConfirmIbModal(client),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colors.blue, width: 1.2),
              backgroundColor: colors.blue.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: Icon(LucideIcons.userPlus, size: 12.5, color: colors.blue),
            label: Text(
              'Request IB',
              style: TextStyle(fontSize: 11, color: colors.blue, fontWeight: FontWeight.w800),
            ),
          ),
      ],
      // Accounts button
      OutlinedButton.icon(
        onPressed: () {
          final parentState = context.findAncestorStateOfType<_BrokerPartnershipPageState>();
          parentState?._showClientAccountsModal(client);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: colors.border),
          backgroundColor: colors.isDark ? colors.subCard : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(LucideIcons.creditCard, size: 12, color: colors.text),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Accounts', style: TextStyle(fontSize: 11, color: colors.text, fontWeight: FontWeight.w700)),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: colors.muted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${client.accounts.length}',
                style: TextStyle(fontSize: 10, color: colors.text, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      if (hasChildren)
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              if (isExpanded) {
                _expandedIds.remove(client.id);
              } else {
                _expandedIds.add(client.id);
              }
            });
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: colors.border),
            backgroundColor: colors.isDark ? colors.subCard : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 13, color: colors.text),
          label: Text(
            isExpanded ? 'Hide team' : 'View team',
            style: TextStyle(fontSize: 11, color: colors.text, fontWeight: FontWeight.w700),
          ),
        ),
    ];

    final cardWidget = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: theme.color),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 720;
                if (isWide) {
                  return Row(
                    children: [
                      avatarWidget,
                      const SizedBox(width: 12),
                      Expanded(child: clientInfoColumn),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < actionItems.length; i++) ...[
                            if (i > 0) const SizedBox(width: 6),
                            actionItems[i],
                          ],
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          avatarWidget,
                          const SizedBox(width: 10),
                          Expanded(child: clientInfoColumn),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: actionItems,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: (depth * 20.0).clamp(0.0, 60.0), bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (depth > 0)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 1.5,
                  color: colors.border,
                  margin: const EdgeInsets.only(right: 6),
                ),
                Expanded(child: cardWidget),
              ],
            )
          else
            cardWidget,
          if (hasChildren && isExpanded) ...[
            const SizedBox(height: 10),
            ...client.clients.map((child) => _buildClientNode(child, colors, depth + 1)),
          ],
        ],
      ),
    );
  }

  void _showConfirmIbModal(_IbClient client) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = _PartnershipColors.of(dialogContext);
        var submitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: colors.border)),
              contentPadding: const EdgeInsets.all(22),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(LucideIcons.shieldCheck, color: colors.blue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Confirm IB Request', style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text('Nominate client for IB status', style: TextStyle(color: colors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.subCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.subBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${client.name}', style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800)),
                        if (client.email.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text('Email: ${client.email}', style: TextStyle(color: colors.muted, fontSize: 12)),
                          ),
                        if (client.referralCode.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text('Code: ${client.referralCode}', style: TextStyle(color: colors.muted, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'The request will be sent to the admin team for review. IB status remains pending until approved.',
                    style: TextStyle(color: colors.muted, fontSize: 11.5, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                        child: Text('Cancel', style: TextStyle(color: colors.muted, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: submitting
                            ? null
                            : () async {
                                setDialogState(() => submitting = true);
                                try {
                                  await AuthApi.instance.requestClientIb(client.id);
                                  showAppMessage('IB request submitted successfully!');
                                  if (dialogContext.mounted) {
                                    Navigator.pop(dialogContext);
                                  }
                                  if (mounted) {
                                    _fetchTree();
                                  }
                                } catch (e) {
                                  showAppMessage('Failed to submit IB request: $e');
                                  setDialogState(() => submitting = false);
                                }
                              },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: submitting
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(LucideIcons.send, size: 14),
                        label: Text(submitting ? 'Submitting...' : 'Confirm', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddClientModal(_PartnershipColors colors) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const _ClientRegistrationDialog(),
    ).then((_) => _fetchTree());
  }
}

// ============================================================================
// SUB-PAGE: BROKERCOMMISSIONLEDGERPAGE (COMMISSION LEDGER)
// ============================================================================

class BrokerCommissionLedgerPage extends StatefulWidget {
  const BrokerCommissionLedgerPage({super.key});

  @override
  State<BrokerCommissionLedgerPage> createState() => _BrokerCommissionLedgerPageState();
}

class _BrokerCommissionLedgerPageState extends State<BrokerCommissionLedgerPage> {
  bool _loading = true;
  List<_IbCommissionTxn> _txns = [];
  String _searchQuery = '';
  String _symbolFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchLedger();
  }

  Future<void> _fetchLedger() async {
    setState(() => _loading = true);
    try {
      final res = await AuthApi.instance.getIbCommissionTransactions();
      final rawList = res['results'] ?? res['data'] ?? res['transactions'];
      final parsed = <_IbCommissionTxn>[];
      if (rawList is List) {
        for (final item in rawList.whereType<Map>()) {
          parsed.add(_IbCommissionTxn.fromJson(item.cast<String, dynamic>()));
        }
      }
      if (mounted) {
        setState(() {
          _txns = parsed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    final symbols = {'All', ..._txns.map((t) => t.positionSymbol).where((s) => s.isNotEmpty && s != '—')}.toList();

    final filtered = _txns.where((t) {
      if (_symbolFilter != 'All' && t.positionSymbol != _symbolFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return t.dealTicket.contains(q) ||
            t.clientTradingAccount.contains(q) ||
            t.clientUser.toLowerCase().contains(q) ||
            t.positionSymbol.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final totalComm = filtered.fold(0.0, (sum, t) => sum + t.commission);
    final totalLots = filtered.fold(0.0, (sum, t) => sum + t.volumeLots);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Commission Ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _fetchLedger,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _PartnershipBackdrop(
        colors: colors,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
          children: [
            // Search box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.search, size: 16, color: colors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: colors.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by deal ticket, account, client or symbol...',
                        hintStyle: TextStyle(color: colors.muted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Symbols row
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: symbols.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final s = symbols[i];
                  final isSelected = _symbolFilter == s;
                  return InkWell(
                    onTap: () => setState(() => _symbolFilter = s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.blue : colors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? colors.blue : colors.border),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colors.text,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            // Summary banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.subCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.subBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${filtered.length} Deals', style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('Volume: ${totalLots.toStringAsFixed(2)} Lots', style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w800)),
                  Text('Total: \$${totalComm.toStringAsFixed(2)}', style: TextStyle(color: colors.green, fontSize: 13, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: colors.blue)),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text('No commission transactions matching filter', style: TextStyle(color: colors.muted, fontSize: 12.5)),
                ),
              )
            else
              ...filtered.map((txn) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(LucideIcons.receipt, color: colors.blue, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${txn.positionSymbol} · Deal #${txn.dealTicket}', style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text('Acc: ${txn.clientTradingAccount} · ${txn.clientUser}', style: TextStyle(color: colors.muted, fontSize: 10.5)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('+\$${txn.commission.toStringAsFixed(2)}', style: TextStyle(color: colors.green, fontSize: 13, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 2),
                          Text('${txn.volumeLots.toStringAsFixed(2)} Lots', style: TextStyle(color: colors.muted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SUB-PAGE: BROKERCOMMISSIONWITHDRAWALPAGE (COMMISSION WITHDRAWAL)
// ============================================================================

class BrokerCommissionWithdrawalPage extends StatefulWidget {
  const BrokerCommissionWithdrawalPage({super.key});

  @override
  State<BrokerCommissionWithdrawalPage> createState() => _BrokerCommissionWithdrawalPageState();
}

class _BrokerCommissionWithdrawalPageState extends State<BrokerCommissionWithdrawalPage> {
  bool _loading = true;
  double _availableBalance = 0.0;
  List<Map<String, dynamic>> _tradingAccounts = [];
  String? _selectedAccountId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AuthApi.instance.getIbStats().catchError((_) => <String, dynamic>{}),
        AuthApi.instance.getUserTradingAccounts().catchError((_) => <String, dynamic>{}),
      ]);

      final stats = results[0];
      final accRes = results[1];

      final rawAccounts = accRes['accounts'] ?? (accRes['data'] is List ? accRes['data'] : []);
      final accList = <Map<String, dynamic>>[];
      if (rawAccounts is List) {
        for (final item in rawAccounts.whereType<Map>()) {
          accList.add(item.cast<String, dynamic>());
        }
      }

      double bal = 0.0;
      if (stats['commission_balance'] is num) {
        bal = (stats['commission_balance'] as num).toDouble();
      } else if (stats['commission_balance'] is String) {
        bal = double.tryParse(stats['commission_balance']) ?? 0.0;
      }

      if (mounted) {
        setState(() {
          _availableBalance = bal;
          _tradingAccounts = accList;
          if (accList.isNotEmpty) {
            _selectedAccountId = (accList[0]['account_id'] ?? '').toString();
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setPercent(double percent) {
    final amt = (_availableBalance * percent).clamp(0.0, _availableBalance);
    _amountController.text = amt.toStringAsFixed(2);
    setState(() {});
  }

  Future<void> _submitWithdrawal() async {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
      showAppMessage('Please select a destination MT5 trading account.');
      return;
    }
    if (amt <= 0 || amt > _availableBalance) {
      showAppMessage('Please enter a valid withdrawal amount up to \$${_availableBalance.toStringAsFixed(2)}');
      return;
    }

    setState(() => _submitting = true);
    try {
      await AuthApi.instance.requestIbWithdrawal(
        amount: amt,
        accountId: _selectedAccountId!,
        comment: _commentController.text.trim(),
      );
      showAppMessage('Withdrawal request submitted successfully!');
      _amountController.clear();
      _commentController.clear();
      await _loadData();
    } catch (e) {
      showAppMessage('Withdrawal failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final remaining = math.max(0.0, _availableBalance - amt);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Commission Withdrawal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: _PartnershipBackdrop(
        colors: colors,
        child: _loading
            ? Center(child: CircularProgressIndicator(color: colors.blue))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
                children: [
                  // Balance Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [colors.blue, const Color(0xFF1E3A8A)]),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available for Withdrawal', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('\$${_availableBalance.toStringAsFixed(2)} USD', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text('Remaining after transfer: \$${remaining.toStringAsFixed(2)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Destination Account Selector
                  Text('SELECT MT5 DESTINATION ACCOUNT', style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _tradingAccounts.any((a) => (a['account_id'] ?? '').toString() == _selectedAccountId)
                            ? _selectedAccountId
                            : null,
                        isExpanded: true,
                        dropdownColor: colors.card,
                        iconEnabledColor: colors.blue,
                        hint: Text(
                          _tradingAccounts.isEmpty ? 'No MT5 accounts found' : 'Select Destination Account',
                          style: TextStyle(color: colors.muted, fontSize: 13),
                        ),
                        style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w700),
                        items: _tradingAccounts.map((a) {
                          final id = (a['account_id'] ?? '').toString();
                          final type = (a['account_type'] ?? 'Standard').toString();
                          final bal = (a['balance'] ?? '0.00').toString();
                          return DropdownMenuItem(
                            value: id,
                            child: Text('$id ($type) · Bal: \$$bal', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAccountId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Amount Input
                  Text('WITHDRAWAL AMOUNT (USD)', style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.w800),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(color: colors.muted),
                        border: InputBorder.none,
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: colors.blue, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Percentage Presets
                  Row(
                    children: [
                      _percentBtn(colors, '25%', () => _setPercent(0.25)),
                      const SizedBox(width: 8),
                      _percentBtn(colors, '50%', () => _setPercent(0.50)),
                      const SizedBox(width: 8),
                      _percentBtn(colors, '75%', () => _setPercent(0.75)),
                      const SizedBox(width: 8),
                      _percentBtn(colors, '100% (Max)', () => _setPercent(1.0)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Comment
                  Text('TRANSFER COMMENT (OPTIONAL)', style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: colors.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. Weekly commission withdrawal',
                        hintStyle: TextStyle(color: colors.muted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  FilledButton.icon(
                    onPressed: _submitting ? null : _submitWithdrawal,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.blue,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _submitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.arrowUpRight, size: 18),
                    label: Text(
                      _submitting ? 'Transferring...' : 'Transfer to MT5 Account',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _percentBtn(_PartnershipColors colors, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: TextStyle(color: colors.text, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ============================================================================
// SUB-PAGE: BROKERREFERRALSTUDIOPAGE (REFERRAL & QR STUDIO)
// ============================================================================

class BrokerReferralStudioPage extends StatefulWidget {
  const BrokerReferralStudioPage({super.key});

  @override
  State<BrokerReferralStudioPage> createState() => _BrokerReferralStudioPageState();
}

class _BrokerReferralStudioPageState extends State<BrokerReferralStudioPage> {
  bool _loading = true;
  List<_IbReferralLink> _links = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    setState(() => _loading = true);
    try {
      final res = await AuthApi.instance.getIbReferralLinks();
      final rawList = res['referral_links'] ?? (res['links'] is List ? res['links'] : null);
      final parsed = <_IbReferralLink>[];
      if (rawList is List && rawList.isNotEmpty) {
        for (var i = 0; i < rawList.length; i++) {
          if (rawList[i] is Map) {
            parsed.add(_IbReferralLink.fromJson(rawList[i].cast<String, dynamic>(), index: i));
          }
        }
      } else {
        final legacy = res['referral_link'] ?? res['link'] ?? res['url'];
        if (legacy != null) {
          parsed.add(_IbReferralLink(
            profileName: 'Default Referral',
            referralLink: legacy.toString(),
            referralCode: (res['referral_code'] ?? '').toString(),
            isPrimary: true,
          ));
        }
      }
      if (mounted) {
        setState(() {
          _links = parsed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);

    if (!_loading && _links.isEmpty) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: colors.appBarBg,
          foregroundColor: colors.text,
          elevation: 0,
          title: const Text('Referral & QR Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        body: _PartnershipBackdrop(
          colors: colors,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.shieldAlert, size: 48, color: colors.gold),
                  const SizedBox(height: 16),
                  Text(
                    'IB Approval Required',
                    style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Multi-profile referral links and custom tracking QR codes are available once your Introducing Broker account is approved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.muted, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final link = _links.isNotEmpty && _selectedIndex < _links.length
        ? _links[_selectedIndex]
        : _IbReferralLink(profileName: 'Standard', referralLink: 'https://client.vtindex.com/', referralCode: '');
    final url = link.referralLink.isNotEmpty
        ? link.referralLink
        : 'https://client.vtindex.com/?ref=${link.referralCode}';

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Referral & QR Studio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: _PartnershipBackdrop(
        colors: colors,
        child: _loading
            ? Center(child: CircularProgressIndicator(color: colors.blue))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
                children: [
                  // Profile selector
                  Text('SELECT PARTNER PROFILE', style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedIndex,
                        isExpanded: true,
                        dropdownColor: colors.card,
                        iconEnabledColor: colors.blue,
                        style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800),
                        items: List.generate(_links.length, (i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Text('${_links[i].profileName} (${_links[i].referralCode})'),
                          );
                        }),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedIndex = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // QR Card
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, 8)),
                        ],
                      ),
                      child: _VtIndexQrView(
                        data: url,
                        size: 210,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(link.profileName, style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: SelectableText(url, style: TextStyle(color: colors.muted, fontSize: 11)),
                  ),
                  const SizedBox(height: 18),
                  // Copy buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: url));
                            showAppMessage('Referral link copied!');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(LucideIcons.copy, size: 14),
                          label: Text('Copy Link', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: link.referralCode));
                            showAppMessage('Referral code copied!');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(LucideIcons.code, size: 14),
                          label: Text('Copy Code', style: TextStyle(color: colors.text, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Social Share
                  Text('SHARE VIA MESSENGER', style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _socialBtn('WhatsApp', LucideIcons.messageCircle, const Color(0xFF25D366), () async {
                        final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent('Join my VT Index partner network: $url')}');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }),
                      _socialBtn('Telegram', LucideIcons.send, const Color(0xFF229ED9), () async {
                        final uri = Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(url)}');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }),
                      _socialBtn('Email', LucideIcons.mail, colors.blue, () async {
                        final uri = Uri(scheme: 'mailto', queryParameters: {'subject': 'Join VT Index', 'body': url});
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _socialBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CLIENT REGISTRATION MODAL
// ============================================================================

class _ClientRegistrationDialog extends StatefulWidget {
  const _ClientRegistrationDialog();

  @override
  State<_ClientRegistrationDialog> createState() => _ClientRegistrationDialogState();
}

class _ClientRegistrationDialogState extends State<_ClientRegistrationDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _codeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _countryController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      showAppMessage('Please fill all required fields.');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthApi.instance.addIbClient(
        name: name,
        email: email,
        phone: phone,
        dob: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
        referralCode: _codeController.text.trim().isNotEmpty ? _codeController.text.trim() : null,
      );
      showAppMessage('Client registered successfully!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      showAppMessage('Failed to register client: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _PartnershipColors.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.border),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Register Direct Client', style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, size: 20)),
                ],
              ),
              const SizedBox(height: 14),
              _field('Full Name *', _nameController, 'e.g. John Doe', colors),
              const SizedBox(height: 10),
              _field('Email Address *', _emailController, 'e.g. john@example.com', colors),
              const SizedBox(height: 10),
              _field('Phone Number *', _phoneController, 'e.g. +91 9876543210', colors),
              const SizedBox(height: 10),
              _field('Country', _countryController, 'e.g. India', colors),
              const SizedBox(height: 10),
              _field('Referral Code', _codeController, 'Optional referral code', colors),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.blue,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_loading ? 'Registering...' : 'Register Client', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, _PartnershipColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: colors.muted, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.subCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.subBorder),
          ),
          child: TextField(
            controller: ctrl,
            style: TextStyle(color: colors.text, fontSize: 13),
            decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: colors.muted, fontSize: 12), border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// BRANDED QR CODE WIDGET WITH VTINDEX LOGO IN CENTER
// ============================================================================

class _VtIndexQrView extends StatelessWidget {
  const _VtIndexQrView({
    required this.data,
    required this.size,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logoSize = (size * 0.22).clamp(38.0, 52.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        QrImageView(
          data: data,
          version: QrVersions.auto,
          size: size,
          backgroundColor: Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.H,
        ),
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(logoSize * 0.12),
          child: ClipOval(
            child: Image.asset(
              'assets/images/vtindex_logo_img.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
