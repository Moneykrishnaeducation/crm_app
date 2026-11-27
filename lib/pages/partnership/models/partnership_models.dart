import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../services/auth_api.dart';

// ============================================================================
// SHARED PARSING & URL HELPERS
// ============================================================================

/// Safely parses numbers, stringified decimals, and comma-formatted strings.
double parseDouble(dynamic value, [double fallback = 0.0]) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final cleaned = value.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return fallback;
    return double.tryParse(cleaned) ?? fallback;
  }
  return fallback;
}

/// Safely parses integers, numeric values, and comma-formatted strings.
int parseInt(dynamic value, [int fallback = 0]) {
  if (value is num) return value.toInt();
  if (value is String) {
    final cleaned = value.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return fallback;
    return int.tryParse(cleaned) ?? double.tryParse(cleaned)?.toInt() ?? fallback;
  }
  return fallback;
}

/// Canonical 3-letter uppercase month labels in calendar order.
const List<String> partnershipMonthNames = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

/// Normalizes numeric (`1..12`), named (`"Jan"`, `"January"`), or ISO
/// (`"2026-04"`, `"2026-04-01T00:00:00Z"`) month values into `"JAN".."DEC"`.
String? normalizePartnershipMonth(dynamic rawMonth) {
  if (rawMonth is num) {
    final idx = rawMonth.toInt();
    if (idx >= 1 && idx <= 12) return partnershipMonthNames[idx - 1];
    return null;
  }
  final str = (rawMonth ?? '').toString().trim();
  if (str.isEmpty) return null;

  final asInt = int.tryParse(str);
  if (asInt != null && asInt >= 1 && asInt <= 12) {
    return partnershipMonthNames[asInt - 1];
  }

  final isoMatch = RegExp(r'^(\d{4})[-/](\d{1,2})(?:$|[-/T])').firstMatch(str);
  if (isoMatch != null) {
    final monthNum = int.tryParse(isoMatch.group(2) ?? '');
    if (monthNum != null && monthNum >= 1 && monthNum <= 12) {
      return partnershipMonthNames[monthNum - 1];
    }
  }

  final parsedDate = DateTime.tryParse(str);
  if (parsedDate != null) {
    return partnershipMonthNames[parsedDate.month - 1];
  }

  final upper = str.toUpperCase();
  for (final m in partnershipMonthNames) {
    if (upper == m || upper.startsWith(m)) return m;
  }
  return null;
}

/// Unwraps list payloads from top-level or nested `data` / `result` / `payload`
/// response envelopes.
List<Map<String, dynamic>> extractPartnershipList(
  Map<String, dynamic> response, {
  List<String> keys = const [
    'results',
    'data',
    'clients',
    'transactions',
    'accounts',
    'items',
  ],
}) {
  final containers = <Map<String, dynamic>>[
    response,
    for (final envelopeKey in const ['data', 'result', 'payload'])
      if (response[envelopeKey] is Map)
        (response[envelopeKey] as Map).cast<String, dynamic>(),
  ];

  for (final container in containers) {
    for (final key in keys) {
      final raw = container[key];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((item) => item.cast<String, dynamic>())
            .toList();
      }
    }
  }
  return const [];
}

/// Returns the active API origin when available, falling back to the legacy
/// VT Index portal origin only if no valid host is configured.
String get partnershipBaseOrigin {
  final uri = AuthApi.instance.baseUri;
  if (uri.hasScheme && uri.host.isNotEmpty) {
    return uri.origin;
  }
  return 'https://client.vtindex.com';
}

/// Builds a fallback referral URL using [partnershipBaseOrigin].
String buildPartnershipReferralUrl([String referralCode = '']) {
  final origin = partnershipBaseOrigin;
  final code = referralCode.trim();
  return code.isNotEmpty ? '$origin/?ref=$code' : '$origin/';
}

String _cleanString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  final str = value.toString();
  return str == 'null' ? fallback : str;
}

// ============================================================================
// LEVEL THEMING HELPER
// ============================================================================

class IbLevelTheme {
  const IbLevelTheme({
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

IbLevelTheme getIbLevelTheme(int level, bool isDark) {
  final lvl = level <= 0 ? 1 : level;
  switch (lvl) {
    case 1:
      return IbLevelTheme(
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
      return IbLevelTheme(
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
      return IbLevelTheme(
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
      return IbLevelTheme(
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
      return IbLevelTheme(
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

class IbDashboardData {
  IbDashboardData({
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

  factory IbDashboardData.fromJson(Map<String, dynamic> json) {
    final rawClients = json['earnings_per_client'];
    final clientList = <Map<String, dynamic>>[];
    if (rawClients is List) {
      for (final item in rawClients.whereType<Map>()) {
        clientList.add(item.cast<String, dynamic>());
      }
    }
    clientList.sort((a, b) =>
        parseDouble(b['total_commission']).compareTo(parseDouble(a['total_commission'])));

    // Normalize monthly trajectory for all 12 months JAN..DEC
    final monthlyMap = <String, double>{};
    final rawMonths = json['earnings_per_month'];
    if (rawMonths is List) {
      for (final item in rawMonths.whereType<Map>()) {
        final mName = normalizePartnershipMonth(item['month']);
        if (mName != null) {
          final val = parseDouble(
            item['total'] ??
                item['earnings'] ??
                item['amount'] ??
                item['commission'],
          );
          monthlyMap[mName] = (monthlyMap[mName] ?? 0.0) + val;
        }
      }
    }
    final normalizedMonthly = partnershipMonthNames
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

    return IbDashboardData(
      totalClients: parseInt(json['total_clients']),
      directClients: parseInt(json['direct_clients']),
      totalEarnings: parseDouble(json['total_earnings']),
      totalWithdrawals: parseDouble(json['total_withdrawals']),
      commissionBalance: parseDouble(json['commission_balance']),
      currentMonthEarnings: parseDouble(json['current_month_earnings']),
      currentMonthVolume: parseDouble(json['current_month_volume_traded']),
      totalVolume: parseDouble(json['total_volume_traded']),
      referralLink: _cleanString(json['referralLink'] ?? json['referral_link']),
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

  static IbDashboardData demo() => IbDashboardData(
        totalClients: 42,
        directClients: 28,
        totalEarnings: 8420.50,
        totalWithdrawals: 5200.00,
        commissionBalance: 3220.50,
        currentMonthEarnings: 1840.25,
        currentMonthVolume: 320.5,
        totalVolume: 1420.8,
        referralLink: buildPartnershipReferralUrl('VT-DEMO'),
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

class IbReferralLink {
  IbReferralLink({
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

  String get effectiveUrl => referralLink.isNotEmpty
      ? referralLink
      : buildPartnershipReferralUrl(referralCode);

  static const List<Color> _palette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFA855F7), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
  ];

  static List<IbReferralLink> demoList() => [
        IbReferralLink(
          profileName: 'Standard Rebate (Direct)',
          referralLink: buildPartnershipReferralUrl('VT-DIRECT'),
          referralCode: 'VT-DIRECT',
          isPrimary: true,
          clientsCount: 28,
          color: const Color(0xFF3B82F6),
        ),
        IbReferralLink(
          profileName: 'VIP Scalpers Profile',
          referralLink: buildPartnershipReferralUrl('VT-SCALP'),
          referralCode: 'VT-SCALP',
          clientsCount: 14,
          color: const Color(0xFFF59E0B),
        ),
      ];

  factory IbReferralLink.fromJson(Map<String, dynamic> json, {int index = 0}) {
    final profileRaw = json['profile'];
    final profileFromMap = profileRaw is Map
        ? (profileRaw['profile_name'] ?? profileRaw['name'] ?? profileRaw['title'])
        : (profileRaw is String ? profileRaw : null);
    final rawName = json['profile_name'] ??
        json['commission_profile_name'] ??
        json['profile_title'] ??
        json['name'] ??
        json['title'] ??
        json['label'] ??
        profileFromMap;
    final profileName = (rawName != null && rawName.toString().trim().isNotEmpty)
        ? rawName.toString().trim()
        : (index == 0 ? 'Default Profile' : 'Profile ${index + 1}');

    final rawLink = json['referral_link'] ??
        json['link'] ??
        json['url'] ??
        json['share_url'] ??
        json['link_url'] ??
        json['invite_link'];
    final referralLink = rawLink is String ? rawLink.trim() : '';

    final rawCode = json['referral_code'] ??
        json['code'] ??
        json['ref_code'] ??
        json['referralCode'];
    var referralCode = rawCode != null ? rawCode.toString().trim() : '';
    if (referralCode.isEmpty && referralLink.isNotEmpty) {
      final parsedUri = Uri.tryParse(referralLink);
      final queryCode =
          parsedUri?.queryParameters['ref'] ?? parsedUri?.queryParameters['code'];
      if (queryCode != null && queryCode.trim().isNotEmpty) {
        referralCode = queryCode.trim();
      }
    }

    final rawCount =
        json['clients_count'] ?? json['client_count'] ?? json['total_clients'];
    final clientsCount = parseInt(rawCount);

    return IbReferralLink(
      profileName: profileName,
      referralLink: referralLink,
      referralCode: referralCode,
      isPrimary: json['is_primary'] == true || json['primary'] == true,
      isLegacy: json['is_legacy'] == true,
      clientsCount: clientsCount,
      color: _palette[index % _palette.length],
    );
  }

  /// Parses referral links across all supported backend envelope formats
  /// (top-level or nested `data`/`result` lists, single link maps, legacy
  /// string fields, or fallback stats payloads).
  static List<IbReferralLink> listFromResponse(
    Map<String, dynamic> response, {
    Map<String, dynamic>? statsResponse,
  }) {
    final parsed = <IbReferralLink>[];
    final seen = <String>{};

    void addCandidate(IbReferralLink item) {
      if (item.referralLink.isEmpty && item.referralCode.isEmpty) return;
      final normalizedUrl = item.effectiveUrl.toLowerCase();
      final normalizedCode = item.referralCode.toLowerCase();
      final key = '$normalizedUrl|$normalizedCode';
      if (seen.add(key)) {
        parsed.add(
          IbReferralLink(
            profileName: item.profileName,
            referralLink: item.referralLink.isNotEmpty
                ? item.referralLink
                : item.effectiveUrl,
            referralCode: item.referralCode,
            isPrimary: item.isPrimary,
            isLegacy: item.isLegacy,
            clientsCount: item.clientsCount,
            color: _palette[(parsed.length) % _palette.length],
          ),
        );
      }
    }

    void extractFromMap(Map<String, dynamic> map) {
      final containers = <Map<String, dynamic>>[
        map,
        for (final key in const ['data', 'result', 'payload'])
          if (map[key] is Map) (map[key] as Map).cast<String, dynamic>(),
      ];

      for (final container in containers) {
        for (final listKey in const [
          'referral_links',
          'links',
          'results',
          'data',
          'profiles',
          'profile_links',
          'items',
        ]) {
          final rawList = container[listKey];
          if (rawList is List && rawList.isNotEmpty) {
            for (var i = 0; i < rawList.length; i++) {
              final entry = rawList[i];
              if (entry is Map) {
                addCandidate(
                  IbReferralLink.fromJson(entry.cast<String, dynamic>(), index: parsed.length),
                );
              } else if (entry is String && entry.trim().isNotEmpty) {
                addCandidate(
                  IbReferralLink.fromJson(
                    <String, dynamic>{'referral_link': entry.trim()},
                    index: parsed.length,
                  ),
                );
              }
            }
          }
        }

        if (container['referral_link'] is Map) {
          addCandidate(
            IbReferralLink.fromJson(
              (container['referral_link'] as Map).cast<String, dynamic>(),
              index: parsed.length,
            ),
          );
        }

        if (container.containsKey('referral_link') ||
            container.containsKey('link') ||
            container.containsKey('url') ||
            container.containsKey('referralLink') ||
            container.containsKey('referral_code') ||
            container.containsKey('code')) {
          final rawLink = container['referral_link'] ??
              container['referralLink'] ??
              container['link'] ??
              container['url'];
          final linkStr = rawLink is String ? rawLink.trim() : '';
          final codeStr = (container['referral_code'] ?? container['code'] ?? '')
              .toString()
              .trim();
          if (linkStr.isNotEmpty || codeStr.isNotEmpty) {
            addCandidate(
              IbReferralLink.fromJson(<String, dynamic>{
                'profile_name': container['profile_name'] ??
                    container['commission_profile_name'] ??
                    'Default Profile',
                'referral_link': linkStr,
                'referral_code': codeStr,
                'is_primary': container['is_primary'] ?? true,
              }, index: parsed.length),
            );
          }
        }
      }
    }

    extractFromMap(response);

    if (statsResponse != null) {
      final rawStatsLinks = statsResponse['earnings_per_link'];
      if (rawStatsLinks is List) {
        for (final entry in rawStatsLinks.whereType<Map>()) {
          addCandidate(
            IbReferralLink.fromJson(entry.cast<String, dynamic>(), index: parsed.length),
          );
        }
      }
      final fallbackLink =
          statsResponse['referralLink'] ?? statsResponse['referral_link'];
      if (fallbackLink is String && fallbackLink.trim().isNotEmpty) {
        addCandidate(
          IbReferralLink.fromJson(<String, dynamic>{
            'profile_name': 'Default Profile',
            'referral_link': fallbackLink.trim(),
            'is_primary': parsed.isEmpty,
          }, index: parsed.length),
        );
      }
    }

    return parsed;
  }
}

class IbTradingAccount {
  IbTradingAccount({
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

  factory IbTradingAccount.fromJson(Map<String, dynamic> json) {
    return IbTradingAccount(
      accountId: _cleanString(json['account_id'] ?? json['id']),
      accountType: _cleanString(json['account_type'], 'MT5 Account'),
      groupAlias: _cleanString(json['group_alias'] ?? json['group_name'], 'Standard'),
      groupName: _cleanString(json['group_name']),
      totalLots: parseDouble(json['total_lots']),
      totalDeposits: parseDouble(json['total_deposits']),
      totalWithdrawals: parseDouble(json['total_withdrawals']),
      totalCommission: parseDouble(json['total_commission']),
    );
  }
}

class IbClient {
  IbClient({
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
  final List<IbTradingAccount> accounts;
  final List<IbClient> clients;

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

  factory IbClient.fromJson(Map<String, dynamic> json, {int inheritedLevel = 1}) {
    final parsedLvl = parseInt(json['level'], inheritedLevel);
    final lvl = parsedLvl > 0 ? parsedLvl : inheritedLevel;

    final rawAccounts = json['accounts'];
    final accList = <IbTradingAccount>[];
    if (rawAccounts is List) {
      for (final a in rawAccounts.whereType<Map>()) {
        accList.add(IbTradingAccount.fromJson(a.cast<String, dynamic>()));
      }
    }

    final rawChildren = json['clients'] ?? json['children'];
    final childList = <IbClient>[];
    if (rawChildren is List) {
      for (final c in rawChildren.whereType<Map>()) {
        childList.add(IbClient.fromJson(c.cast<String, dynamic>(), inheritedLevel: lvl + 1));
      }
    }

    final refLinkMap = json['referral_link'] is Map ? json['referral_link'] as Map : null;
    final refCode = _cleanString(json['referral_code'] ?? refLinkMap?['code']);
    final profName = _cleanString(
      json['commission_profile_name'] ??
          json['profile_name'] ??
          json['plan_name'] ??
          json['plan'] ??
          json['tag'] ??
          refLinkMap?['profile_name'],
    );
    final regDate = _cleanString(
      json['registered_date'] ??
          json['date_joined'] ??
          json['created_at'] ??
          json['joined_at'],
    );

    return IbClient(
      id: _cleanString(json['id'] ?? json['client_id']),
      name: _cleanString(json['name'], 'Client'),
      email: _cleanString(json['email']),
      phone: _cleanString(json['phone']),
      registeredDate: regDate,
      referralCode: refCode,
      commissionProfileName: profName,
      level: lvl,
      isIb: json['is_ib'] == true || json['role'] == 'ib' || json['is_partner'] == true,
      ibRequestStatus: _cleanString(
        json['ib_request_status'] ?? (json['status'] == 'pending' ? 'pending' : null),
      ),
      accounts: accList,
      clients: childList,
    );
  }

  static List<IbClient> demoTree() => [
        IbClient(
          id: 'CL-101',
          name: 'Alexander Wright',
          email: 'alex.wright@example.com',
          level: 1,
          isIb: true,
          accounts: [
            IbTradingAccount(
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
            IbClient(
              id: 'CL-201',
              name: 'Marcus Vance',
              email: 'marcus.v@example.com',
              level: 2,
              accounts: [
                IbTradingAccount(
                  accountId: '884102',
                  totalLots: 78.0,
                  totalDeposits: 12000.0,
                  totalCommission: 980.5,
                ),
              ],
            ),
          ],
        ),
        IbClient(
          id: 'CL-102',
          name: 'Sophia Chen',
          email: 'sophia.c@example.com',
          level: 1,
          accounts: [
            IbTradingAccount(
              accountId: '883995',
              totalLots: 110.5,
              totalDeposits: 18000.0,
              totalCommission: 1420.0,
            ),
          ],
        ),
      ];
}

class IbCommissionTxn {
  IbCommissionTxn({
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

  factory IbCommissionTxn.fromJson(Map<String, dynamic> json) {
    final amt = parseDouble(
      json['amount'] ?? json['commission_to_ib'] ?? json['total_commission'],
    );
    return IbCommissionTxn(
      id: _cleanString(json['id'] ?? json['deal_ticket']),
      clientUser: _cleanString(json['client_user'] ?? json['client_name'], 'Client'),
      clientTradingAccount: _cleanString(json['client_trading_account']),
      positionSymbol: _cleanString(json['position_symbol'] ?? json['symbol'], '—'),
      dealTicket: _cleanString(json['deal_ticket']),
      orderTicket: _cleanString(json['order_ticket']),
      volumeLots: parseDouble(json['volume_lots'] ?? json['lots']),
      profit: parseDouble(json['profit']),
      commission: amt,
      createdAt: _cleanString(json['created_at']),
      referralCode: _cleanString(json['referral_code']),
      commissionProfileName: _cleanString(json['commission_profile_name']),
    );
  }
}
