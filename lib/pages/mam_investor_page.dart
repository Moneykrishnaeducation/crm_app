import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../app_notifications.dart';
import '../widgets/mam_modals.dart';
import 'funds_action_dialog.dart';

// -----------------------------------------------------------------------------
// DYNAMIC THEME COLORS HELPER FOR INVESTOR WORKSPACE
// -----------------------------------------------------------------------------
class _InvestorColors {
  const _InvestorColors({
    required this.isDark,
    required this.card,
    required this.subCard,
    required this.border,
    required this.subBorder,
    required this.text,
    required this.muted,
    required this.blue,
    required this.blueLight,
    required this.blueBorder,
    required this.gold,
    required this.goldLight,
    required this.goldBorder,
    required this.green,
    required this.greenLight,
    required this.greenBorder,
    required this.red,
    required this.redLight,
    required this.redBorder,
    required this.navy,
  });

  final bool isDark;
  final Color card;
  final Color subCard;
  final Color border;
  final Color subBorder;
  final Color text;
  final Color muted;
  final Color blue;
  final Color blueLight;
  final Color blueBorder;
  final Color gold;
  final Color goldLight;
  final Color goldBorder;
  final Color green;
  final Color greenLight;
  final Color greenBorder;
  final Color red;
  final Color redLight;
  final Color redBorder;
  final Color navy;

  factory _InvestorColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _InvestorColors(
      isDark: isDark,
      card: isDark ? const Color(0xFF17243A) : Colors.white,
      subCard: isDark ? const Color(0xFF101D31) : const Color(0xFFF7F9FC),
      border: isDark ? const Color(0xFF263750) : const Color(0xFFE2E8F0),
      subBorder: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEDF2F7),
      text: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      muted: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      blue: const Color(0xFF2563EB),
      blueLight: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEFF6FF),
      blueBorder: isDark
          ? const Color(0xFF2563EB).withValues(alpha: 0.35)
          : const Color(0xFFBFDBFE),
      gold: const Color(0xFFF59E0B),
      goldLight: isDark ? const Color(0xFF2D2619) : const Color(0xFFFEFCE8),
      goldBorder: isDark
          ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
          : const Color(0xFFFEF08A),
      green: const Color(0xFF10B981),
      greenLight: isDark ? const Color(0xFF132D28) : const Color(0xFFECFDF5),
      greenBorder: isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.35)
          : const Color(0xFFA7F3D0),
      red: const Color(0xFFEF4444),
      redLight: isDark ? const Color(0xFF3B2028) : const Color(0xFFFEF2F2),
      redBorder: isDark
          ? const Color(0xFFEF4444).withValues(alpha: 0.35)
          : const Color(0xFFFECACA),
      navy: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF10264A),
    );
  }
}

// -----------------------------------------------------------------------------
// INVESTOR ACCOUNT DATA MODEL
// -----------------------------------------------------------------------------
class InvestorAccountData {
  InvestorAccountData({
    required this.accountId,
    required this.masterAccountId,
    required this.alias,
    required this.platform,
    required this.server,
    required this.balance,
    required this.totalProfit,
    required this.profitShare,
    required this.riskLevel,
    required this.leverage,
    this.isCopying = true,
    this.scalingMethod = 'BALANCE RATIO',
    this.multiplicationFactor = 1.00,
    this.orderCloning = false,
    this.cloneCount = 1,
    this.tradingPassword = '••••••••••',
    this.investorPassword = '••••••••••',
    this.authToken = 'VT-MT5-LIVE-TOKEN-994102-SECURE',
  });

  final String accountId;
  final String masterAccountId;
  String alias;
  final String platform;
  final String server;
  double balance;
  double totalProfit;
  double profitShare;
  String riskLevel;
  String leverage;
  bool isCopying;
  String scalingMethod; // 'BALANCE RATIO' or 'FIXED RATIO'
  double multiplicationFactor;
  bool orderCloning;
  int cloneCount;
  String tradingPassword;
  String investorPassword;
  String authToken;
}

// Compatibility model if referenced externally
class MamInvestmentSubscription {
  MamInvestmentSubscription({
    required this.id,
    required this.poolName,
    required this.managerLogin,
    required this.initialCapital,
    required this.currentEquity,
    required this.unrealizedPnl,
    required this.allocationMethod,
    required this.feePercentage,
    required this.joinedDate,
    required this.isMirroringActive,
    required this.riskLevel,
  });

  final String id;
  final String poolName;
  final String managerLogin;
  final double initialCapital;
  double currentEquity;
  double unrealizedPnl;
  final String allocationMethod;
  final double feePercentage;
  final String joinedDate;
  bool isMirroringActive;
  final String riskLevel;

  double get returnPercentage => initialCapital == 0
      ? 0
      : ((currentEquity - initialCapital) / initialCapital) * 100;
}

// -----------------------------------------------------------------------------
// VISUAL RISK GAUGE METER (3-BAR SEGMENTED)
// -----------------------------------------------------------------------------
class _RiskMeter extends StatelessWidget {
  const _RiskMeter({
    required this.level,
    this.barWidth = 3.5,
    this.barSpacing = 2.5,
  });

  final int level; // 1 = Low, 2 = Med, 3 = High
  final double barWidth;
  final double barSpacing;

  @override
  Widget build(BuildContext context) {
    Color activeColor;
    if (level <= 1) {
      activeColor = const Color(0xFF10B981);
    } else if (level == 2) {
      activeColor = const Color(0xFFF59E0B);
    } else {
      activeColor = const Color(0xFFEF4444);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heights = [6.0, 9.5, 13.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < 3; i++)
          Container(
            width: barWidth,
            height: heights[i],
            margin: EdgeInsets.only(right: i < 2 ? barSpacing : 0),
            decoration: BoxDecoration(
              color: i < level
                  ? activeColor
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1)),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// MAM INVESTOR PAGE
// -----------------------------------------------------------------------------
class MamInvestorPage extends StatefulWidget {
  const MamInvestorPage({
    super.key,
    this.onBack,
    this.onExploreAvailable,
    this.showBackButton = true,
    this.initialAccountId,
  });

  final VoidCallback? onBack;
  final VoidCallback? onExploreAvailable;
  final bool showBackButton;
  final String? initialAccountId;

  @override
  State<MamInvestorPage> createState() => _MamInvestorPageState();
}

class _MamInvestorPageState extends State<MamInvestorPage> {
  late List<InvestorAccountData> _accounts;
  late int _selectedAccountIndex;

  @override
  void initState() {
    super.initState();
    _accounts = [
      InvestorAccountData(
        accountId: '3511',
        masterAccountId: '3510',
        alias: 'testtest1 - Investment',
        platform: 'MetaTrader 5 (MT5)',
        server: 'VTIndex-Live',
        balance: 0.00,
        totalProfit: 0.00,
        profitShare: 10.0,
        riskLevel: 'Medium',
        leverage: '1:1',
        isCopying: true,
        scalingMethod: 'BALANCE RATIO',
        multiplicationFactor: 1.00,
        orderCloning: false,
        cloneCount: 1,
      ),
      InvestorAccountData(
        accountId: '3520',
        masterAccountId: '3510',
        alias: 'testtest2 - Pro Copier',
        platform: 'MetaTrader 5 (MT5)',
        server: 'VTIndex-Live',
        balance: 2450.00,
        totalProfit: 348.50,
        profitShare: 10.0,
        riskLevel: 'Medium',
        leverage: '1:1',
        isCopying: true,
        scalingMethod: 'FIXED RATIO',
        multiplicationFactor: 1.50,
        orderCloning: true,
        cloneCount: 3,
      ),
    ];
    _selectedAccountIndex = 0;
    if (widget.initialAccountId != null) {
      final index = _accounts.indexWhere(
        (account) => account.accountId == widget.initialAccountId,
      );
      if (index >= 0) {
        _selectedAccountIndex = index;
      }
    }
  }

  InvestorAccountData get _currentAccount => _accounts[_selectedAccountIndex];
  _InvestorColors get _c => _InvestorColors.of(context);

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showAppMessage('$label copied: $text');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    children: [
                      _buildHeroBalanceCard(_currentAccount),
                      const SizedBox(height: 16),
                      _buildAllocationSpecificationsCard(),
                      const SizedBox(height: 16),
                      _buildSecurityCredentialsCard(),
                      const SizedBox(height: 16),
                      _buildLiveOrdersTradesCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. HERO BALANCE CARD
  // ---------------------------------------------------------------------------
  Widget _buildHeroBalanceCard([InvestorAccountData? account]) {
    final acc = account ?? _currentAccount;
    final isPos = acc.totalProfit >= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _c.isDark ? 0.28 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Alias Badge & ID with copy icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _c.blueBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.wallet, size: 12, color: _c.blue),
                    const SizedBox(width: 5),
                    Text(
                      acc.alias.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: _c.blue,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard(acc.accountId, 'Account ID'),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 44,
                    minWidth: 44,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ID: ${acc.accountId}',
                        style: GoogleFonts.inter(
                          color: _c.muted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.copy, size: 13, color: _c.muted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Label: NET AVAILABLE BALANCE
          Text(
            'NET AVAILABLE BALANCE',
            style: GoogleFonts.inter(
              color: _c.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),

          // Large Balance Display
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${acc.balance.toStringAsFixed(2)} USD',
              style: GoogleFonts.inter(
                color: _c.text,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons / Control Strip
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 440;

              if (isMobile) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1 (Primary Financial Actions)
                    Row(
                      children: [
                        // [+ Deposit Funds]
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: FilledButton.icon(
                              onPressed: _openDepositModal,
                              icon: const Icon(LucideIcons.plusCircle, size: 16),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Deposit Funds',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _c.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // [↗ Withdraw Funds]
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: _openWithdrawModal,
                              icon: Icon(
                                LucideIcons.arrowUpRight,
                                size: 16,
                                color: _c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Withdraw Funds',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    color: _c.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: _c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 2 (Copy Trading Status & Control Strip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: acc.isCopying
                            ? _c.greenLight.withValues(alpha: 0.5)
                            : _c.goldLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: acc.isCopying
                              ? _c.greenBorder
                              : _c.goldBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            acc.isCopying
                                ? LucideIcons.activity
                                : LucideIcons.circleSlash,
                            size: 16,
                            color: acc.isCopying ? _c.green : _c.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  acc.isCopying
                                      ? 'Trade Copying Active'
                                      : 'Trade Copying Paused',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _c.text,
                                  ),
                                ),
                                Text(
                                  acc.isCopying
                                      ? 'Orders mirrored automatically'
                                      : 'Mirroring paused by user',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: _c.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  acc.isCopying = !acc.isCopying;
                                });
                                showAppMessage(
                                  acc.isCopying
                                      ? 'Trade copying resumed for Account ${acc.accountId}'
                                      : 'Trade copying paused for Account ${acc.accountId}',
                                );
                              },
                              icon: Icon(
                                acc.isCopying
                                    ? LucideIcons.pause
                                    : LucideIcons.play,
                                size: 13,
                                color: acc.isCopying ? _c.gold : _c.green,
                              ),
                              label: Text(
                                acc.isCopying ? 'Pause' : 'Resume',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: acc.isCopying ? _c.gold : _c.green,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _c.card,
                                side: BorderSide(
                                  color: acc.isCopying
                                      ? _c.goldBorder
                                      : _c.greenBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                minimumSize: const Size(0, 36),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Tablet / Desktop screens (maxWidth >= 440)
              return Row(
                children: [
                  // + Deposit Funds (Filled primary button)
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton.icon(
                        onPressed: _openDepositModal,
                        icon: const Icon(LucideIcons.plusCircle, size: 15),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Deposit Funds',
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _c.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Pause / Resume Copy Toggle Button
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            acc.isCopying = !acc.isCopying;
                          });
                          showAppMessage(
                            acc.isCopying
                                ? 'Trade copying resumed for Account ${acc.accountId}'
                                : 'Trade copying paused for Account ${acc.accountId}',
                          );
                        },
                        icon: Icon(
                          acc.isCopying
                              ? LucideIcons.circleSlash
                              : LucideIcons.play,
                          size: 14,
                          color: acc.isCopying ? _c.gold : _c.green,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            acc.isCopying ? 'Pause Copy' : 'Resume Copy',
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.inter(
                              color: acc.isCopying ? _c.gold : _c.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: acc.isCopying
                                ? _c.goldBorder
                                : _c.greenBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Withdraw Funds Outlined Button
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _openWithdrawModal,
                        icon: Icon(
                          LucideIcons.arrowUpRight,
                          size: 14,
                          color: _c.text,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Withdraw Funds',
                            maxLines: 1,
                            softWrap: false,
                            style: GoogleFonts.inter(
                              color: _c.text,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _c.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // 2x2 Key Metrics Grid
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _metricBox(
                        label: 'TOTAL PROFIT',
                        value: '\$${acc.totalProfit.toStringAsFixed(2)}',
                        valueColor: isPos ? _c.green : _c.red,
                        icon: isPos
                            ? LucideIcons.trendingUp
                            : LucideIcons.trendingDown,
                      ),
                    ),
                    Container(width: 1, height: 36, color: _c.subBorder),
                    Expanded(
                      child: _metricBox(
                        label: 'PROFIT SHARE',
                        value: '${acc.profitShare.toStringAsFixed(0)}%',
                        valueColor: _c.blue,
                        icon: LucideIcons.percent,
                      ),
                    ),
                  ],
                ),
                Divider(height: 16, thickness: 1, color: _c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _metricBox(
                        label: 'RISK LEVEL',
                        value: acc.riskLevel,
                        valueColor: _c.gold,
                        trailing: const _RiskMeter(level: 2),
                        icon: LucideIcons.shieldAlert,
                      ),
                    ),
                    Container(width: 1, height: 36, color: _c.subBorder),
                    Expanded(
                      child: _metricBox(
                        label: 'LEVERAGE',
                        value: acc.leverage,
                        valueColor: _c.text,
                        icon: LucideIcons.scale,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    required Color valueColor,
    required IconData icon,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: valueColor.withValues(alpha: _c.isDark ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: valueColor),
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
                  style: GoogleFonts.inter(
                    color: _c.muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: valueColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 6),
                      trailing,
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. CARD 1: ALLOCATION SPECIFICATIONS
  // ---------------------------------------------------------------------------
  Widget _buildAllocationSpecificationsCard() {
    final acc = _currentAccount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.blueBorder),
                ),
                child: Icon(
                  LucideIcons.slidersHorizontal,
                  color: _c.blue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allocation Specifications',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Investor node connection parameters',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Specs Table
          Container(
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              children: [
                _specRow('Account ID', acc.accountId, copyable: true),
                _specDivider(),
                _specRow(
                  'Master Account ID',
                  acc.masterAccountId,
                  copyable: true,
                ),
                _specDivider(),
                _specRow('Account Alias', acc.alias),
                _specDivider(),
                _specRow('Trading Platform', acc.platform),
                _specDivider(),
                _specRow('Server', acc.server, copyable: true),
                _specDivider(),
                _specRow(
                  'Status',
                  acc.isCopying ? 'Active Copying' : 'Copying Paused',
                  isBadge: true,
                  badgeColor: acc.isCopying ? _c.green : _c.gold,
                ),
                _specDivider(),
                _specRow('Leverage', acc.leverage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specDivider() =>
      Divider(height: 1, thickness: 1, color: _c.subBorder);

  Widget _specRow(
    String label,
    String value, {
    bool copyable = false,
    bool isBadge = false,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: _c.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isBadge)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? _c.green).withValues(
                      alpha: _c.isDark ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: (badgeColor ?? _c.green).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: badgeColor ?? _c.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        value,
                        style: GoogleFonts.inter(
                          color: badgeColor ?? _c.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: _c.text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (copyable) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _copyToClipboard(value, label),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      minWidth: 44,
                    ),
                    alignment: Alignment.center,
                    child: Icon(LucideIcons.copy, size: 14, color: _c.blue),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CARD 2: SECURITY & CREDENTIALS
  // ---------------------------------------------------------------------------
  Widget _buildSecurityCredentialsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _c.greenLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.greenBorder),
                ),
                child: Icon(LucideIcons.shieldCheck, color: _c.green, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security & Credentials',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Investor sub-account credentials',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sub-card 1: Investor Password Settings
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.keyRound, size: 16, color: _c.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TERMINAL ACCESS CREDENTIALS',
                            style: GoogleFonts.inter(
                              color: _c.muted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Update your investor terminal password anytime. This does not interfere with the master manager\'s trade execution.',
                            style: TextStyle(
                              color: _c.text,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _openInvestorPasswordModal,
                    icon: Icon(LucideIcons.settings, size: 15, color: _c.text),
                    label: Text(
                      'Investor Password Settings',
                      style: TextStyle(
                        color: _c.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _c.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sub-card 2: Multiplier Scaling
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _c.subBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.sliders, size: 16, color: _c.gold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MULTIPLIER SCALING',
                                style: GoogleFonts.inter(
                                  color: _c.muted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _c.goldLight,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _c.goldBorder),
                                ),
                                child: Text(
                                  _currentAccount.scalingMethod ==
                                          'BALANCE RATIO'
                                      ? 'Balance Ratio'
                                      : '${_currentAccount.multiplicationFactor.toStringAsFixed(2)}x Ratio',
                                  style: GoogleFonts.inter(
                                    color: _c.gold,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Customize proportional trade volume or enable multi-order execution cloning.',
                            style: TextStyle(
                              color: _c.text,
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: _openScalingModal,
                    icon: Icon(
                      LucideIcons.arrowLeftRight,
                      size: 15,
                      color: _c.blue,
                    ),
                    label: Text(
                      'Edit Copy Multipliers',
                      style: TextStyle(
                        color: _c.blue,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _c.blueBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. CARD 3: LIVE ORDERS & TRADES
  // ---------------------------------------------------------------------------
  Widget _buildLiveOrdersTradesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _c.blueLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.blueBorder),
                ),
                child: Icon(LucideIcons.activity, color: _c.blue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Orders & Trades',
                      style: GoogleFonts.inter(
                        color: _c.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Real-time exposure & manager positions',
                      style: TextStyle(color: _c.muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tile 1: Investor Live Trades
          _tradeNavTile(
            icon: LucideIcons.barChart2,
            iconColor: _c.blue,
            title: 'Investor Live Trades',
            subtitle: 'Your open positions & floating P&L',
            badgeText: '3 Open',
            badgeColor: _c.green,
            onTap: _openLiveTradesSheet,
          ),
          const SizedBox(height: 10),

          // Tile 2: Master Manager Trades
          _tradeNavTile(
            icon: LucideIcons.usersRound,
            iconColor: _c.gold,
            title: 'Master Manager Trades',
            subtitle: 'Source orders executed by master node',
            badgeText: '5 Master Tickets',
            badgeColor: _c.blue,
            onTap: _openMasterTradesSheet,
          ),
          const SizedBox(height: 10),

          // Tile 3: Trade Pattern Analysis
          _tradeNavTile(
            icon: LucideIcons.lineChart,
            iconColor: _c.green,
            title: 'Trade Pattern Analysis',
            subtitle: 'AI behavioral metrics & win rate',
            badgeText: '78.4% Win',
            badgeColor: _c.green,
            onTap: _openTradePatternSheet,
          ),
        ],
      ),
    );
  }

  Widget _tradeNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _c.subCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _c.subBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: _c.isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: _c.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subtitle,
                    style: TextStyle(color: _c.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: _c.isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: badgeColor.withValues(alpha: 0.35)),
              ),
              child: Text(
                badgeText,
                style: GoogleFonts.inter(
                  color: badgeColor,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(LucideIcons.chevronRight, size: 16, color: _c.muted),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. INTERACTIVE MODAL: COEFFICIENT & SCALING MODAL
  // ---------------------------------------------------------------------------
  void _openScalingModal() {
    final acc = _currentAccount;
    showEditCopyMultipliersModal(
      context,
      accountId: acc.accountId,
      initialMethod: acc.scalingMethod,
      initialFactor: acc.multiplicationFactor,
      initialOrderCloning: acc.orderCloning,
      initialCloneCount: acc.cloneCount,
      onDeploy: (method, factor, orderCloning, cloneCount) {
        setState(() {
          acc.scalingMethod = method;
          acc.multiplicationFactor = factor;
          acc.orderCloning = orderCloning;
          acc.cloneCount = cloneCount;
        });
        showAppMessage('Configuration deployed to Account ${acc.accountId}!');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 7. INTERACTIVE MODAL: QUICK DEPOSIT
  // ---------------------------------------------------------------------------
  void _openDepositModal() {
    final acc = _currentAccount;
    showFundsActionDialog(
      context,
      withdrawal: false,
      accountId: acc.accountId,
      accountLabel: '${acc.alias} · MT5 Live #${acc.accountId}',
      onCompleted: (amt) {
        setState(() {
          acc.balance += amt;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 8. INTERACTIVE MODAL: QUICK WITHDRAW
  // ---------------------------------------------------------------------------
  void _openWithdrawModal() {
    final acc = _currentAccount;
    showFundsActionDialog(
      context,
      withdrawal: true,
      accountId: acc.accountId,
      accountLabel: '${acc.alias} · MT5 Live #${acc.accountId}',
      onCompleted: (amt) {
        setState(() {
          acc.balance = (acc.balance - amt).clamp(0.0, double.infinity);
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 9. INTERACTIVE MODAL: INVESTOR PASSWORD & CREDENTIALS
  // ---------------------------------------------------------------------------
  void _openInvestorPasswordModal() {
    final acc = _currentAccount;
    bool showTrading = false;
    bool showInvestor = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: _c.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(color: _c.border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _c.muted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _c.greenLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _c.greenBorder),
                              ),
                              child: Icon(
                                LucideIcons.keyRound,
                                size: 17,
                                color: _c.green,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Investor Credentials',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _c.text,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Security keys for Account #${acc.accountId} (${acc.server})',
                      style: TextStyle(fontSize: 11.5, color: _c.muted),
                    ),
                    const SizedBox(height: 16),

                    // Password Card 1: Trading Password
                    _credentialCard(
                      label: 'INVESTOR TRADING PASSWORD',
                      value: showTrading ? 'AlphaTrader@2025' : '••••••••••••',
                      description: 'Used for terminal execution permissions and account verification.',
                      isMasked: !showTrading,
                      onToggleVisibility: () {
                        setModalState(() {
                          showTrading = !showTrading;
                        });
                      },
                      onCopy: () => _copyToClipboard(
                        showTrading ? 'AlphaTrader@2025' : 'AlphaTrader@2025',
                        'Investor Trading Password',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password Card 2: Read-Only Investor Password
                    _credentialCard(
                      label: 'READ-ONLY (INVESTOR) PASSWORD',
                      value: showInvestor ? 'InvestView#8841' : '••••••••••••',
                      description: 'Safe for third-party auditing tools (Myfxbook, FXBlue, etc.).',
                      isMasked: !showInvestor,
                      onToggleVisibility: () {
                        setModalState(() {
                          showInvestor = !showInvestor;
                        });
                      },
                      onCopy: () => _copyToClipboard(
                        showInvestor ? 'InvestView#8841' : 'InvestView#8841',
                        'Read-Only Password',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Auth Token Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _c.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _c.subBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MT5 AUTH TOKEN',
                                style: GoogleFonts.inter(
                                  color: _c.muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              InkWell(
                                onTap: () => _copyToClipboard(
                                  acc.authToken,
                                  'MT5 Auth Token',
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 44,
                                    minWidth: 44,
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        LucideIcons.copy,
                                        size: 13,
                                        color: _c.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Copy Token',
                                        style: TextStyle(
                                          color: _c.blue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SelectableText(
                            acc.authToken,
                            style: GoogleFonts.robotoMono(
                              color: _c.text,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          showAppMessage('Credentials verified and secured');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _c.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Done',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _credentialCard({
    required String label,
    required String value,
    required String description,
    required bool isMasked,
    required VoidCallback onToggleVisibility,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _c.subCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.subBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: _c.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isMasked ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 16,
                      color: _c.muted,
                    ),
                    onPressed: onToggleVisibility,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.copy, size: 16, color: _c.blue),
                    onPressed: onCopy,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(description, style: TextStyle(color: _c.muted, fontSize: 10.5)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 10. INTERACTIVE MODAL: LIVE TRADES SHEET
  // ---------------------------------------------------------------------------
  void _openLiveTradesSheet() {
    final acc = _currentAccount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final trades = [
          {
            'symbol': 'EURUSD',
            'type': 'BUY',
            'lots': '0.20',
            'openPrice': '1.08450',
            'currentPrice': '1.08720',
            'pnl': '+54.00',
            'ticket': '98201',
            'time': '10:14:22',
            'isPos': true,
          },
          {
            'symbol': 'GBPUSD',
            'type': 'SELL',
            'lots': '0.15',
            'openPrice': '1.29800',
            'currentPrice': '1.29610',
            'pnl': '+28.50',
            'ticket': '98208',
            'time': '11:02:15',
            'isPos': true,
          },
          {
            'symbol': 'XAUUSD',
            'type': 'BUY',
            'lots': '0.05',
            'openPrice': '2685.10',
            'currentPrice': '2685.44',
            'pnl': '+1.70',
            'ticket': '98214',
            'time': '11:45:09',
            'isPos': true,
          },
        ];

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.82,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _c.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _c.blueLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _c.blueBorder),
                        ),
                        child: Icon(
                          LucideIcons.barChart2,
                          size: 17,
                          color: _c.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Investor Live Trades',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _c.text,
                            ),
                          ),
                          Text(
                            'Account #${acc.accountId} • 3 Active Orders',
                            style: TextStyle(fontSize: 11, color: _c.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Summary Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _c.greenLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.greenBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL FLOATING P&L',
                      style: GoogleFonts.inter(
                        color: _c.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '+\$84.20 USD',
                      style: GoogleFonts.inter(
                        color: _c.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: trades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final t = trades[index];
                    final isPos = t['isPos'] as bool;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _c.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _c.subBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: t['type'] == 'BUY'
                                  ? _c.blueLight
                                  : _c.redLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${t['type']} ${t['lots']}',
                              style: GoogleFonts.inter(
                                color: t['type'] == 'BUY' ? _c.blue : _c.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['symbol'] as String,
                                  style: GoogleFonts.inter(
                                    color: _c.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '#${t['ticket']} • ${t['openPrice']} → ${t['currentPrice']}',
                                  style: TextStyle(
                                    color: _c.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${t['pnl']}',
                            style: GoogleFonts.inter(
                              color: isPos ? _c.green : _c.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
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
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 11. INTERACTIVE MODAL: MASTER TRADES SHEET
  // ---------------------------------------------------------------------------
  void _openMasterTradesSheet() {
    final acc = _currentAccount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final masterTrades = [
          {
            'symbol': 'EURUSD',
            'type': 'BUY',
            'lots': '5.00',
            'ticket': '9812044',
            'pnl': '+270.00',
          },
          {
            'symbol': 'GBPUSD',
            'type': 'SELL',
            'lots': '3.50',
            'ticket': '9812110',
            'pnl': '+133.00',
          },
          {
            'symbol': 'USDJPY',
            'type': 'BUY',
            'lots': '2.00',
            'ticket': '9812239',
            'pnl': '-18.00',
          },
          {
            'symbol': 'XAUUSD',
            'type': 'BUY',
            'lots': '2.00',
            'ticket': '9812301',
            'pnl': '+35.00',
          },
        ];

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.82,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _c.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: _c.goldLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _c.goldBorder),
                        ),
                        child: Icon(
                          LucideIcons.usersRound,
                          size: 17,
                          color: _c.gold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Master Manager Trades',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _c.text,
                            ),
                          ),
                          Text(
                            'Master Node #${acc.masterAccountId} Live Source Orders',
                            style: TextStyle(fontSize: 11, color: _c.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Overview Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _c.subCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _c.subBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Master Volume: 12.50 Lots',
                      style: TextStyle(color: _c.muted, fontSize: 11.5),
                    ),
                    Text(
                      'Master Float: +\$420.00',
                      style: GoogleFonts.inter(
                        color: _c.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: masterTrades.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final mt = masterTrades[index];
                    final isPos = (mt['pnl'] as String).startsWith('+');
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _c.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _c.subBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: mt['type'] == 'BUY'
                                  ? _c.blueLight
                                  : _c.redLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${mt['type']} ${mt['lots']}',
                              style: GoogleFonts.inter(
                                color: mt['type'] == 'BUY' ? _c.blue : _c.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mt['symbol'] as String,
                                  style: GoogleFonts.inter(
                                    color: _c.text,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Master Ticket #${mt['ticket']}',
                                  style: TextStyle(
                                    color: _c.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${mt['pnl']}',
                            style: GoogleFonts.inter(
                              color: isPos ? _c.green : _c.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
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
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 12. INTERACTIVE MODAL: TRADE PATTERN ANALYSIS
  // ---------------------------------------------------------------------------
  void _openTradePatternSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.82,
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: _c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: _c.border),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _c.muted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _c.greenLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _c.greenBorder),
                          ),
                          child: Icon(
                            LucideIcons.lineChart,
                            size: 17,
                            color: _c.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trade Pattern Analysis',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _c.text,
                              ),
                            ),
                            Text(
                              'AI Behavioral Metrics & Historical Alpha',
                              style: TextStyle(fontSize: 11, color: _c.muted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(LucideIcons.x, color: _c.muted, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Win Rate Hero Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _c.subCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _c.subBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OVERALL WIN RATE',
                            style: GoogleFonts.inter(
                              color: _c.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '78.4%',
                            style: GoogleFonts.inter(
                              color: _c.green,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _c.greenLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _c.greenBorder),
                        ),
                        child: Text(
                          'CONSERVATIVE PROFILE',
                          style: GoogleFonts.inter(
                            color: _c.green,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2x3 Metric Grid
                Text(
                  'PERFORMANCE METRICS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _c.muted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _c.subCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _c.subBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _patternStat(
                              'Profit Factor',
                              '2.45',
                              _c.blue,
                            ),
                          ),
                          Container(width: 1, height: 32, color: _c.subBorder),
                          Expanded(
                            child: _patternStat(
                              'Sharpe Ratio',
                              '1.89',
                              _c.green,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 16, thickness: 1, color: _c.subBorder),
                      Row(
                        children: [
                          Expanded(
                            child: _patternStat(
                              'Max Drawdown',
                              '4.2%',
                              _c.gold,
                            ),
                          ),
                          Container(width: 1, height: 32, color: _c.subBorder),
                          Expanded(
                            child: _patternStat(
                              'Avg Trade Duration',
                              '3h 42m',
                              _c.text,
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 16, thickness: 1, color: _c.subBorder),
                      Row(
                        children: [
                          Expanded(
                            child: _patternStat(
                              'Total Closed Trades',
                              '342',
                              _c.text,
                            ),
                          ),
                          Container(width: 1, height: 32, color: _c.subBorder),
                          Expanded(
                            child: _patternStat(
                              'Avg Win / Loss',
                              '2.1x',
                              _c.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Asset Distribution
                Text(
                  'TOP TRADED ASSETS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _c.muted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _c.subCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _c.subBorder),
                  ),
                  child: Column(
                    children: [
                      _assetBar('EURUSD', 0.45, '45%'),
                      const SizedBox(height: 8),
                      _assetBar('GBPUSD', 0.30, '30%'),
                      const SizedBox(height: 8),
                      _assetBar('XAUUSD', 0.20, '20%'),
                      const SizedBox(height: 8),
                      _assetBar('Other', 0.05, '5%'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: FilledButton.styleFrom(
                      backgroundColor: _c.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Close Analysis',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _patternStat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: _c.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assetBar(String symbol, double fraction, String pct) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            symbol,
            style: GoogleFonts.inter(
              color: _c.text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: _c.isDark
                  ? const Color(0xFF263750)
                  : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(_c.blue),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            pct,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: _c.muted,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
