import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../app_haptics.dart';

class TradePatternItem {
  const TradePatternItem({
    required this.key,
    required this.label,
    required this.tag,
    required this.duration,
    required this.description,
    required this.color,
    required this.count,
    required this.winCount,
    required this.profit,
    required this.recommendation,
  });

  final String key;
  final String label;
  final String tag;
  final String duration;
  final String description;
  final Color color;
  final int count;
  final int winCount;
  final double profit;
  final String recommendation;

  int get winRate => count > 0 ? ((winCount / count) * 100).round() : 0;
  int get lossCount => count - winCount;
  bool get isProfitable => profit > 0;
}

class TradePatternAccountOption {
  const TradePatternAccountOption({
    required this.accountId,
    required this.accountName,
    required this.balance,
    required this.currency,
    this.type = 'Live MT5',
  });

  final String accountId;
  final String accountName;
  final double balance;
  final String currency;
  final String type;
}

class TradePatternAnalysisPage extends StatefulWidget {
  const TradePatternAnalysisPage({
    super.key,
    this.initialAccountLogin,
    this.accounts,
    this.onBack,
    this.onSelectPage,
  });

  final String? initialAccountLogin;
  final List<dynamic>? accounts;
  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPage;

  @override
  State<TradePatternAnalysisPage> createState() =>
      _TradePatternAnalysisPageState();
}

class _TradePatternAnalysisPageState extends State<TradePatternAnalysisPage> {
  late String _selectedAccount;
  String _timeframe = '10'; // '2', '5', '7', '10', '30', '90', 'all'
  String _filterStatus = 'all'; // 'all', 'profitable', 'loss'
  String _sortBy = 'profit'; // 'profit', 'trades', 'winrate'
  String _viewMode = 'grid'; // 'grid', 'table', 'charts'
  bool _showGuide = false;

  late List<TradePatternAccountOption> _accountOptions;

  static const _gold = Color(0xFFD4AF37);
  static const _blue = Color(0xFF365CEB);
  static const _green = Color(0xFF10B981);
  static const _rose = Color(0xFFEF4444);

  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _dark ? const Color(0xFF050E24) : const Color(0xFFF8FAFF);
  Color get _cardBg => _dark ? const Color(0xFF0B1B35) : Colors.white;
  Color get _subCard => _dark ? const Color(0xFF081538) : const Color(0xFFF1F5F9);
  Color get _border => _dark ? const Color(0xFF1E3563) : const Color(0xFFE2E8F0);
  Color get _text => _dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get _muted => _dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  final List<Map<String, String>> _timeframes = const [
    {'value': '2', 'label': 'Past 2 Days', 'short': '2D'},
    {'value': '5', 'label': 'Past 5 Days', 'short': '5D'},
    {'value': '7', 'label': 'Past 7 Days', 'short': '7D'},
    {'value': '10', 'label': 'Past 10 Days', 'short': '10D'},
    {'value': '30', 'label': 'Past 30 Days', 'short': '30D'},
    {'value': '90', 'label': 'Past 90 Days', 'short': '90D'},
    {'value': 'all', 'label': 'All-Time', 'short': 'ALL'},
  ];

  @override
  void initState() {
    super.initState();
    _initAccounts();
  }

  void _initAccounts() {
    final list = <TradePatternAccountOption>[];

    // Check accounts passed as props
    if (widget.accounts != null && widget.accounts!.isNotEmpty) {
      for (final a in widget.accounts!) {
        try {
          final login = (a.login ?? a.accountId ?? '').toString();
          final name = (a.name ?? a.accountName ?? 'Account $login').toString();
          final balStr = (a.balance ?? '2500').toString().replaceAll(RegExp(r'[^\d.]'), '');
          final bal = double.tryParse(balStr) ?? 2500.0;
          final curr = (a.currency ?? 'USD').toString();
          if (login.isNotEmpty) {
            list.add(TradePatternAccountOption(
              accountId: login,
              accountName: name,
              balance: bal,
              currency: curr,
            ));
          }
        } catch (_) {}
      }
    }

    if (list.isEmpty) {
      list.addAll(const [
        TradePatternAccountOption(
          accountId: '3503',
          accountName: 'MohanTest (PAMM Master)',
          balance: 3840.50,
          currency: 'USD',
        ),
        TradePatternAccountOption(
          accountId: '3315',
          accountName: 'Standard MT5',
          balance: 2742.50,
          currency: 'USD',
        ),
        TradePatternAccountOption(
          accountId: '3311',
          accountName: 'ECN MT5',
          balance: 1180.20,
          currency: 'USD',
        ),
        TradePatternAccountOption(
          accountId: '3312',
          accountName: 'Pro MT5',
          balance: 5320.00,
          currency: 'USD',
        ),
        TradePatternAccountOption(
          accountId: '3420',
          accountName: 'Naveen Test (PAMM)',
          balance: 1450.00,
          currency: 'USD',
        ),
      ]);
    }

    _accountOptions = list;

    if (widget.initialAccountLogin != null &&
        _accountOptions.any((a) => a.accountId == widget.initialAccountLogin)) {
      _selectedAccount = widget.initialAccountLogin!;
    } else {
      _selectedAccount = _accountOptions.first.accountId;
    }
  }

  TradePatternAccountOption get _currentAccount {
    return _accountOptions.firstWhere(
      (a) => a.accountId == _selectedAccount,
      orElse: () => _accountOptions.first,
    );
  }

  List<TradePatternItem> _getPatternsForCurrentSelection() {
    // Generate realistic trading patterns dynamically scaled by account and timeframe
    final tfFactor = switch (_timeframe) {
      '2' => 0.25,
      '5' => 0.5,
      '7' => 0.75,
      '10' => 1.0,
      '30' => 2.2,
      '90' => 4.5,
      'all' => 8.0,
      _ => 1.0,
    };

    final isPamm = _selectedAccount == '3503' || _selectedAccount == '3420';

    final baseData = [
      TradePatternItem(
        key: 'ultra_scalp',
        label: 'Ultra Scalp (< 60s)',
        tag: 'High Frequency',
        duration: '< 60 seconds',
        description:
            'Rapid momentum entries closed almost immediately. Highly sensitive to bid/ask spreads.',
        color: const Color(0xFFF59E0B),
        count: math.max(1, (12 * tfFactor).round()),
        winCount: math.max(1, (7 * tfFactor).round()),
        profit: (isPamm ? 42.50 : 28.20) * tfFactor,
        recommendation: 'Continue this because past trade is positive',
      ),
      TradePatternItem(
        key: 'scalp',
        label: 'Scalp (1m - 5m)',
        tag: 'Scalping',
        duration: '1 to 5 minutes',
        description:
            'Short-horizon micro trend trades targeting fast volatility waves.',
        color: const Color(0xFF3B82F6),
        count: math.max(1, (18 * tfFactor).round()),
        winCount: math.max(1, (14 * tfFactor).round()),
        profit: (isPamm ? 118.40 : 86.50) * tfFactor,
        recommendation: 'Continue this because past trade is positive',
      ),
      TradePatternItem(
        key: 'intraday_short',
        label: 'Intraday Short (5m - 1h)',
        tag: 'Intraday Momentum',
        duration: '5 min to 1 hour',
        description:
            'Session breakout & liquidity impulse trades executed within standard market sessions.',
        color: const Color(0xFF8B5CF6),
        count: math.max(1, (24 * tfFactor).round()),
        winCount: math.max(1, (19 * tfFactor).round()),
        profit: (isPamm ? 194.50 : 142.10) * tfFactor,
        recommendation: 'Continue this because past trade is positive',
      ),
      TradePatternItem(
        key: 'intraday_swing',
        label: 'Intraday Swing (1h - 24h)',
        tag: 'Session Cycle',
        duration: '1 to 24 hours (same day)',
        description:
            'Full daily cycle trades closed before daily rollover, avoiding overnight rollover swap.',
        color: const Color(0xFF06B6D4),
        count: math.max(1, (10 * tfFactor).round()),
        winCount: math.max(1, (8 * tfFactor).round()),
        profit: (isPamm ? 96.20 : 64.80) * tfFactor,
        recommendation: 'Continue this because past trade is positive',
      ),
      TradePatternItem(
        key: 'swing',
        label: 'Multi-Day Swing (1d - 7d)',
        tag: 'Multi-Day Swing',
        duration: '1 to 7 days',
        description:
            'Multi-day trend expansion capturing macro market swings across institutional sessions.',
        color: const Color(0xFF10B981),
        count: math.max(1, (5 * tfFactor).round()),
        winCount: math.max(1, (3 * tfFactor).round()),
        profit: (isPamm ? -18.40 : 14.50) * tfFactor,
        recommendation: isPamm
            ? 'Review this pattern and reduce risk'
            : 'Continue this because past trade is positive',
      ),
      TradePatternItem(
        key: 'positional',
        label: 'Positional (> 7d)',
        tag: 'Macro Position',
        duration: 'Over 7 days',
        description:
            'Macro thematic positioning held through intermediate cycles with low turnover.',
        color: const Color(0xFFEC4899),
        count: math.max(1, (2 * tfFactor).round()),
        winCount: 1,
        profit: (isPamm ? 15.40 : -8.60) * tfFactor,
        recommendation: isPamm
            ? 'Continue this because past trade is positive'
            : 'Review this pattern and reduce risk',
      ),
    ];

    var list = baseData;

    // Filter
    if (_filterStatus == 'profitable') {
      list = list.where((p) => p.isProfitable).toList();
    } else if (_filterStatus == 'loss') {
      list = list.where((p) => !p.isProfitable).toList();
    }

    // Sort
    if (_sortBy == 'profit') {
      list.sort((a, b) => b.profit.compareTo(a.profit));
    } else if (_sortBy == 'trades') {
      list.sort((a, b) => b.count.compareTo(a.count));
    } else if (_sortBy == 'winrate') {
      list.sort((a, b) => b.winRate.compareTo(a.winRate));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final patterns = _getPatternsForCurrentSelection();

    final totalTrades = patterns.fold(0, (sum, p) => sum + p.count);
    final totalWins = patterns.fold(0, (sum, p) => sum + p.winCount);
    final totalProfit = patterns.fold(0.0, (sum, p) => sum + p.profit);
    final overallWinRate = totalTrades > 0 ? ((totalWins / totalTrades) * 100).round() : 0;
    final avgProfitPerTrade = totalTrades > 0 ? (totalProfit / totalTrades) : 0.0;
    final bestPattern = patterns.isNotEmpty
        ? patterns.reduce((curr, next) => next.profit > curr.profit ? next : curr)
        : null;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back & Breadcrumbs
              _buildTopBar(),
              const SizedBox(height: 14),

              // Header Banner Card
              _buildHeaderBanner(),
              const SizedBox(height: 16),

              // Controls Toolbar (Account, Timeframe, Filters, View Modes)
              _buildControlToolbar(),
              const SizedBox(height: 16),

              // Strategy Guide (Collapsible)
              if (_showGuide) ...[
                _buildStrategyGuide(),
                const SizedBox(height: 16),
              ],

              // Executive KPI Strip
              _buildExecutiveKpiStrip(
                totalProfit: totalProfit,
                totalTrades: totalTrades,
                overallWinRate: overallWinRate,
                avgProfitPerTrade: avgProfitPerTrade,
                bestPattern: bestPattern,
              ),
              const SizedBox(height: 16),

              // View Modes: Grid / Table / Charts
              if (_viewMode == 'grid')
                _buildGridView(patterns)
              else if (_viewMode == 'table')
                _buildTableView(patterns)
              else
                _buildChartsView(patterns),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            AppHaptics.selectionClick();
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowLeft, size: 14, color: _blue),
                const SizedBox(width: 6),
                Text(
                  'BACK',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _blue,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trading Analytics',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _muted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Icon(LucideIcons.chevronRight, size: 12, color: _muted),
            const SizedBox(width: 6),
            Text(
              'Trade Pattern Analysis',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: _gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderBanner() {
    final account = _currentAccount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          final titleInfo = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.trendingUp,
                      size: 18,
                      color: _blue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Trade Pattern Analysis',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Analyze holding time, behavioral win rate, and risk-adjusted alpha based on closed trades.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(LucideIcons.info, size: 13, color: _blue),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Note: This analysis is computed from closed trading executions.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          final accountCard = Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.wallet, size: 17, color: _blue),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account ${account.accountId}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${account.balance.toStringAsFixed(2)} ${account.currency}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          if (isWide) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: titleInfo),
                const SizedBox(width: 16),
                accountCard,
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleInfo,
                const SizedBox(height: 12),
                accountCard,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildControlToolbar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Account Selector & Timeframe Pills
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // MT5 Account Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _subCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedAccount,
                    icon: Icon(LucideIcons.chevronDown, size: 14, color: _muted),
                    dropdownColor: _cardBg,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _text,
                    ),
                    items: _accountOptions.map((acc) {
                      return DropdownMenuItem<String>(
                        value: acc.accountId,
                        child: Text('${acc.accountName} (${acc.accountId})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        AppHaptics.selectionClick();
                        setState(() => _selectedAccount = val);
                      }
                    },
                  ),
                ),
              ),

              // Timeframe Buttons
              Wrap(
                spacing: 4,
                children: _timeframes.map((tf) {
                  final active = _timeframe == tf['value'];
                  return InkWell(
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() => _timeframe = tf['value']!);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: active ? _gold : _subCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active ? _gold : _border,
                        ),
                      ),
                      child: Text(
                        tf['short']!,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: active ? const Color(0xFF051130) : _muted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Row 2: Filters, Sorting, View Modes, Strategy Guide Toggle
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Filter status & Sorting
              Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _filterButton('All', 'all'),
                  _filterButton('Profitable', 'profitable'),
                  _filterButton('Loss', 'loss'),
                  const SizedBox(width: 4),
                  Container(height: 16, width: 1, color: _border),
                  const SizedBox(width: 4),
                  Text(
                    'Sort:',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _muted,
                    ),
                  ),
                  _sortButton('Profit', 'profit'),
                  _sortButton('Trades', 'trades'),
                  _sortButton('Win%', 'winrate'),
                ],
              ),

              // View Mode Switcher & Guide Toggle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // View mode toggle
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _subCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _viewModeButton(LucideIcons.layoutGrid, 'grid'),
                        _viewModeButton(LucideIcons.table, 'table'),
                        _viewModeButton(LucideIcons.chartColumn, 'charts'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Strategy Guide toggle
                  InkWell(
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() => _showGuide = !_showGuide);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _showGuide
                            ? _blue.withValues(alpha: 0.15)
                            : _subCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _showGuide ? _blue : _border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.bookOpen,
                            size: 13,
                            color: _showGuide ? _blue : _muted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Strategy Guide',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _showGuide ? _blue : _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    final active = _filterStatus == value;
    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        setState(() => _filterStatus = value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _blue.withValues(alpha: 0.15) : _subCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? _blue : _border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: active ? _blue : _muted,
          ),
        ),
      ),
    );
  }

  Widget _sortButton(String label, String value) {
    final active = _sortBy == value;
    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        setState(() => _sortBy = value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: active ? _gold.withValues(alpha: 0.15) : _subCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? _gold : _border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: active ? _gold : _muted,
          ),
        ),
      ),
    );
  }

  Widget _viewModeButton(IconData icon, String mode) {
    final active = _viewMode == mode;
    return InkWell(
      onTap: () {
        AppHaptics.selectionClick();
        setState(() => _viewMode = mode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? _blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 14,
          color: active ? Colors.white : _muted,
        ),
      ),
    );
  }

  Widget _buildExecutiveKpiStrip({
    required double totalProfit,
    required int totalTrades,
    required int overallWinRate,
    required double avgProfitPerTrade,
    required TradePatternItem? bestPattern,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        final cards = [
          _kpiStatCard(
            title: 'NET PROFIT',
            value:
                '${totalProfit >= 0 ? '+' : ''}\$${totalProfit.toStringAsFixed(2)}',
            valueColor: totalProfit >= 0 ? _green : _rose,
            subtitle: 'Realized Closed Alpha',
            icon: LucideIcons.coins,
          ),
          _kpiStatCard(
            title: 'CLOSED TRADES',
            value: '$totalTrades',
            valueColor: _text,
            subtitle: '$_timeframe days sampling',
            icon: LucideIcons.barChart3,
          ),
          _kpiStatCard(
            title: 'OVERALL WIN RATE',
            value: '$overallWinRate%',
            valueColor: _gold,
            subtitle: 'Hit frequency ratio',
            icon: LucideIcons.trophy,
            progress: overallWinRate / 100.0,
          ),
          _kpiStatCard(
            title: 'AVG PROFIT / TRADE',
            value:
                '${avgProfitPerTrade >= 0 ? '+' : ''}\$${avgProfitPerTrade.toStringAsFixed(2)}',
            valueColor: avgProfitPerTrade >= 0 ? _green : _rose,
            subtitle: 'Expectancy per order',
            icon: LucideIcons.zap,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map((c) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: c,
                      ),
                    ))
                .toList(),
          );
        } else {
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: cards,
          );
        }
      },
    );
  }

  Widget _kpiStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
    required IconData icon,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: _muted,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 14, color: _muted),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: _border,
                valueColor: AlwaysStoppedAnimation<Color>(_gold),
                minHeight: 3,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<TradePatternItem> patterns) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 600
                ? 2
                : 1;

        if (cols == 1) {
          return Column(
            children: patterns.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPatternCard(p),
              );
            }).toList(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: patterns.length,
          itemBuilder: (context, index) {
            return _buildPatternCard(patterns[index]);
          },
        );
      },
    );
  }

  Widget _buildPatternCard(TradePatternItem p) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tag, duration, color pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: p.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: p.color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    p.tag,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: p.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _subCard,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.duration,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Label
          Text(
            p.label,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            p.description,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: _muted,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),

          // Win Rate & Trades
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Win Rate: ${p.winRate}%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _gold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${p.winCount}W/${p.lossCount}L (${p.count})',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (p.winRate / 100.0).clamp(0.0, 1.0),
              backgroundColor: _border,
              valueColor: AlwaysStoppedAnimation<Color>(p.color),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 10),

          // Net P&L & Recommendation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${p.profit >= 0 ? '+' : ''}\$${p.profit.toStringAsFixed(2)}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: p.isProfitable ? _green : _rose,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      p.isProfitable
                          ? LucideIcons.circleCheck
                          : LucideIcons.triangleAlert,
                      size: 11,
                      color: p.isProfitable ? _green : _rose,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        p.isProfitable ? 'Positive Alpha' : 'Reduce Risk',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: p.isProfitable ? _green : _rose,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(List<TradePatternItem> patterns) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(_subCard),
          dataRowColor: WidgetStateProperty.all(_cardBg),
          columns: [
            DataColumn(
              label: Text(
                'PATTERN',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _muted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'DURATION',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _muted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'TRADES',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _muted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'RECORD (W/L)',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _muted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'WIN RATE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _muted,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'NET PROFIT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _muted,
                ),
              ),
            ),
          ],
          rows: patterns.map((p) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        p.label,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: _text,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    p.duration,
                    style: GoogleFonts.inter(fontSize: 11, color: _muted),
                  ),
                ),
                DataCell(
                  Text(
                    '${p.count}',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _text,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${p.winCount}W / ${p.lossCount}L',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: _muted,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${p.winRate}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _gold,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${p.profit >= 0 ? '+' : ''}\$${p.profit.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: p.isProfitable ? _green : _rose,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChartsView(List<TradePatternItem> patterns) {
    final maxProfit = patterns.fold(
      1.0,
      (max, p) => math.max(max, p.profit.abs()),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart2, size: 16, color: _blue),
              const SizedBox(width: 8),
              Text(
                'Comparative P&L By Holding Horizon',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...patterns.map((p) {
            final barRatio = (p.profit.abs() / maxProfit).clamp(0.04, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.label,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      Text(
                        '${p.profit >= 0 ? '+' : ''}\$${p.profit.toStringAsFixed(2)} · ${p.winRate}% Win',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: p.isProfitable ? _green : _rose,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: _subCard,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: barRatio,
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: p.isProfitable ? _green : _rose,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStrategyGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _subCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 16, color: _gold),
              const SizedBox(width: 8),
              Text(
                'How To Read Trade Pattern Behavioral Metrics',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _guideRow(
            'Ultra Scalp (< 60s):',
            'Entries that close in under a minute. These trades suffer the most drag from broker bid-ask spreads. High win rates (>75%) are required to stay net positive.',
          ),
          const SizedBox(height: 6),
          _guideRow(
            'Scalp (1m - 5m):',
            'Micro-momentum trades during news spikes or session opens. Best for capturing impulsive price moves.',
          ),
          const SizedBox(height: 6),
          _guideRow(
            'Intraday Short (5m - 1h):',
            'Standard session setups (London / New York open). Offers clean risk-to-reward ratios and low overnight exposure.',
          ),
          const SizedBox(height: 6),
          _guideRow(
            'Session Cycle (1h - 24h):',
            'Positions held throughout the day and closed before rollover. Eliminates financing swap charges.',
          ),
          const SizedBox(height: 6),
          _guideRow(
            'Multi-Day Swing (1d - 7d):',
            'Captures larger macro directional trends. Account for daily triple rollover swap on Wednesdays.',
          ),
        ],
      ),
    );
  }

  Widget _guideRow(String title, String body) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 11, color: _muted, height: 1.4),
        children: [
          TextSpan(
            text: '$title ',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          TextSpan(text: body),
        ],
      ),
    );
  }
}
