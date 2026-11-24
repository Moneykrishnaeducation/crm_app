part of '../main.dart';

class TradeReportPage extends StatefulWidget {
  const TradeReportPage({
    super.key,
    this.accounts,
    this.selectedAccountLogin,
    this.onAccountChanged,
    this.onBack,
  });

  final List<BrokerAccount>? accounts;
  final String? selectedAccountLogin;
  final ValueChanged<String>? onAccountChanged;
  final VoidCallback? onBack;

  @override
  State<TradeReportPage> createState() => _TradeReportPageState();
}

class _TradeReportPageState extends State<TradeReportPage> {
  late String _selectedLogin;
  late DateTime _startDate;
  late DateTime _endDate;
  String _selectedPreset = 'custom';
  String _symbolFilter = 'All Symbols';
  String _timeframe = 'Day';
  bool _hideNetDeposit = false;
  bool _loadingTrades = false;
  String? _tradeLoadError;
  List<BrokerTradeRecord> _loadedTrades = <BrokerTradeRecord>[];
  int _requestGeneration = 0;

  Offset? _equityScrubOffset;
  Offset? _pnlScrubOffset;

  final List<String> _symbolOptions = const [
    'All Symbols',
    'EURUSD',
    'GBPUSD',
    'XAUUSD',
    'BTCUSD',
    'USDJPY',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLogin = widget.selectedAccountLogin ?? '52132132';
    final today = DateTime.now();
    _endDate = DateTime(today.year, today.month, today.day);
    _startDate = _endDate.subtract(const Duration(days: 6));
    _selectedPreset = '7days';
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTrades());
  }

  @override
  void didUpdateWidget(covariant TradeReportPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAccountLogin != null &&
        widget.selectedAccountLogin != oldWidget.selectedAccountLogin) {
      _selectedLogin = widget.selectedAccountLogin!;
      _loadedTrades = <BrokerTradeRecord>[];
      _loadTrades();
    } else if (widget.accounts != oldWidget.accounts) {
      _loadTrades();
    }
  }

  List<BrokerAccount> get _allAccounts => widget.accounts ?? const <BrokerAccount>[];

  BrokerAccount? get _currentAccountOrNull {
    for (final account in _allAccounts) {
      if (account.login == _selectedLogin) return account;
    }
    return _allAccounts.isEmpty ? null : _allAccounts.first;
  }

  BrokerAccount get _currentAccount => _currentAccountOrNull ??
      const BrokerAccount('Trading account', '', '—', r'$0.00', r'$0.00', 'Live MT5');

  String _apiDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  double _tradeNumber(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString().replaceAll(',', '').trim()) ?? 0;
  }

  Future<void> _loadTrades() async {
    final account = _currentAccountOrNull;
    if (account == null || account.login.isEmpty) {
      if (mounted) setState(() {
        _loadedTrades = <BrokerTradeRecord>[];
        _loadingTrades = false;
        _tradeLoadError = null;
      });
      return;
    }
    final generation = ++_requestGeneration;
    if (mounted) setState(() { _loadingTrades = true; _tradeLoadError = null; });
    try {
      final rawTrades = await AuthApi.instance.getClosedPositions(
        account.login,
        fromDate: _apiDate(_startDate),
        toDate: _apiDate(_endDate),
      );
      final parsed = <BrokerTradeRecord>[];
      for (final item in rawTrades) {
        final symbol = (item['symbol'] ?? '').toString().trim();
        if (symbol.isEmpty) continue;
        final type = (item['type'] ?? item['side'] ?? 'buy').toString().toLowerCase();
        final closedAt = (item['close_time'] ?? item['closed_at'] ?? item['closeTime'] ?? '').toString();
        final commission = _tradeNumber(item['commission']);
        final swap = _tradeNumber(item['swap']);
        parsed.add(BrokerTradeRecord(
          symbol: symbol,
          side: type,
          volume: _tradeNumber(item['volume']).toStringAsFixed(2),
          closedAt: closedAt,
          profit: _tradeNumber(item['profit']) + commission + swap,
          commission: commission,
          swap: swap,
        ));
      }
      if (!mounted || generation != _requestGeneration) return;
      setState(() { _loadedTrades = parsed; _loadingTrades = false; _tradeLoadError = null; });
    } on AuthApiException catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() { _loadingTrades = false; _tradeLoadError = error.message; _loadedTrades = <BrokerTradeRecord>[]; });
    } catch (_) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _loadingTrades = false;
        _tradeLoadError = 'Unable to load closed trades. Check your connection and retry.';
        _loadedTrades = <BrokerTradeRecord>[];
      });
    }
  }

  String _formatCurrency(String raw) {
    final cleaned = raw.replaceAll(r'$', '').replaceAll(',', '').trim();
    final val = double.tryParse(cleaned) ?? 0.0;
    return val.toStringAsFixed(2);
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y / $m / $day';
  }

  Color _getPnLColor(double val, Color defaultColor) {
    if (val > 0) return const Color(0xFF16A34A);
    if (val < 0) return const Color(0xFFDC2626);
    return defaultColor;
  }

  Future<void> _selectDateRange() async {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131D2E) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final mutedText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final titleText = isDark ? Colors.white : const Color(0xFF0F172A);

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Trade Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildPresetTile(
                  ctx: ctx,
                  key: 'today',
                  title: 'Today',
                  icon: LucideIcons.calendarCheck,
                  isSelected: _selectedPreset == 'today',
                  isDark: isDark,
                  cardBorder: cardBorder,
                  titleText: titleText,
                ),
                const SizedBox(height: 8),
                _buildPresetTile(
                  ctx: ctx,
                  key: '7days',
                  title: 'Last 7 Days',
                  icon: LucideIcons.calendarRange,
                  isSelected: _selectedPreset == '7days',
                  isDark: isDark,
                  cardBorder: cardBorder,
                  titleText: titleText,
                ),
                const SizedBox(height: 8),
                _buildPresetTile(
                  ctx: ctx,
                  key: 'month',
                  title: 'This Month',
                  icon: LucideIcons.calendarClock,
                  isSelected: _selectedPreset == 'month',
                  isDark: isDark,
                  cardBorder: cardBorder,
                  titleText: titleText,
                ),
                const SizedBox(height: 8),
                _buildPresetTile(
                  ctx: ctx,
                  key: '30days',
                  title: 'Last 30 Days',
                  icon: LucideIcons.calendarDays,
                  isSelected: _selectedPreset == '30days',
                  isDark: isDark,
                  cardBorder: cardBorder,
                  titleText: titleText,
                ),
                const SizedBox(height: 8),
                _buildPresetTile(
                  ctx: ctx,
                  key: 'custom',
                  title: 'Custom Range...',
                  icon: LucideIcons.slidersHorizontal,
                  isSelected: _selectedPreset == 'custom',
                  isDark: isDark,
                  cardBorder: cardBorder,
                  titleText: titleText,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    final now = DateTime.now();
    if (action == 'today') {
      setState(() {
        _selectedPreset = 'today';
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day);
      });
    } else if (action == '7days') {
      setState(() {
        _selectedPreset = '7days';
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        _endDate = now;
      });
    } else if (action == 'month') {
      setState(() {
        _selectedPreset = 'month';
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
      });
    } else if (action == '30days') {
      setState(() {
        _selectedPreset = '30days';
        _startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        _endDate = now;
      });
    } else if (action == 'custom') {
      if (!mounted) return;
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      );
      if (picked != null && mounted) {
        setState(() {
          _selectedPreset = 'custom';
          _startDate = picked.start;
          _endDate = picked.end;
        });
      }
    }
    if (mounted) _loadTrades();
  }

  Widget _buildPresetTile({
    required BuildContext ctx,
    required String key,
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color cardBorder,
    required Color titleText,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(ctx, key);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.4) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : cardBorder,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2563EB).withValues(alpha: 0.18)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 17,
                color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white70 : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF2563EB) : titleText,
                ),
              ),
            ),
            if (isSelected)
              const Icon(LucideIcons.check, size: 18, color: Color(0xFF2563EB)),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF131D2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final accounts = _allAccounts;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Switch Trading Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: accounts.length,
                    separatorBuilder: (ctx, idx) => Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    ),
                    itemBuilder: (context, i) {
                      final acc = accounts[i];
                      final isSelected = acc.login == _selectedLogin;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: isSelected
                              ? const Color(0xFF2563EB)
                              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          child: Icon(
                            LucideIcons.wallet,
                            size: 18,
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                          ),
                        ),
                        title: Text(
                          '${acc.server ?? 'GTCGlobalSA-Server 2(MT5)'} - ${acc.login}',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                            color: isSelected ? const Color(0xFF2563EB) : null,
                          ),
                        ),
                        subtitle: Text(
                          'Balance: ${acc.balance}  •  ${acc.type}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(LucideIcons.check, color: Color(0xFF2563EB), size: 20)
                            : null,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedLogin = acc.login;
                          });
                          widget.onAccountChanged?.call(acc.login);
                          Navigator.pop(ctx);
                        },
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

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _requestGeneration++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF131D2E) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF243247) : const Color(0xFFE7ECF3);
    final mutedText = isDark ? const Color(0xFF91A0B5) : const Color(0xFF718096);
    final titleText = isDark ? const Color(0xFFF7FAFF) : const Color(0xFF142033);
    final currentAcc = _currentAccount;
    final balanceStr = _formatCurrency(currentAcc.balance);
    final equityStr = _formatCurrency(currentAcc.equity);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: _handleBack,
        ),
        title: Text(
          'Trade Report',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: titleText),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF3B82F6),
        backgroundColor: cardBg,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await _loadTrades();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                  _buildDateRangeFilterRow(cardBg, cardBorder, mutedText, titleText),
                  const SizedBox(height: 14),
                  if (_loadingTrades)
                    const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator(minHeight: 2)),
                  if (_tradeLoadError != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFDC2626).withValues(alpha: .08), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: .25))),
                      child: Row(children: [
                        const Icon(LucideIcons.alertCircle, color: Color(0xFFDC2626), size: 17),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_tradeLoadError!, style: const TextStyle(fontSize: 11))),
                        TextButton(onPressed: _loadTrades, child: const Text('Retry')),
                      ]),
                    ),
                  if (_allAccounts.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: cardBorder)),
                      child: Text('No trading accounts are available for this report.', style: TextStyle(color: mutedText, fontSize: 12)),
                    )
                  else
                    _buildHeroAccountCard(currentAcc, balanceStr, equityStr),
                  const SizedBox(height: 22),
                  _buildReportSectionHeading(
                    'Trading activity',
                    'Closed orders and execution costs',
                    isDark,
                  ),
                  const SizedBox(height: 11),
                  _buildClosedOrderStatisticsSection(
                    cardBg, cardBorder, mutedText, titleText, isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildOrderAndTotalPnLCard(
                    cardBg, cardBorder, mutedText, titleText, isDark,
                  ),
                  const SizedBox(height: 22),
                  _buildReportSectionHeading(
                    'Cash flow',
                    'Deposits and withdrawals for this period',
                    isDark,
                  ),
                  const SizedBox(height: 11),
                  _buildDepositWithdrawGrid(
                    cardBg, cardBorder, mutedText, titleText, isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildReportSectionHeading(
                    'Performance',
                    'Track account value and trading results',
                    isDark,
                  ),
                  const SizedBox(height: 11),
                  _buildEquityCurveSection(cardBg, cardBorder, titleText, isDark),
                  const SizedBox(height: 18),
                  _buildPnLAnalysisSection(
                    cardBg, cardBorder, mutedText, titleText, isDark,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSectionHeading(String heading, String subtitle, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: isDark ? const Color(0xFFF7FAFF) : const Color(0xFF142033),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF8190A5) : const Color(0xFF8995A7),
            ),
          ),
        ],
      ),
    );
  }

  // --- Date Range Filter Bar ---
  Widget _buildDateRangeFilterRow(
    Color bg,
    Color border,
    Color muted,
    Color title,
  ) {
    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar, size: 16, color: muted),
            const SizedBox(width: 8),
            Text(
              'Trade Time',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
            const Spacer(),
            Text(
              '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: title,
              ),
            ),
            const SizedBox(width: 4),
            Icon(LucideIcons.chevronDown, size: 14, color: muted),
          ],
        ),
      ),
    );
  }

  // --- Hero Account Summary Card (Royal Blue Gradient with Radiant Glow) ---
  Widget _buildHeroAccountCard(
    BrokerAccount acc,
    String balance,
    String equity,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF071941),
            Color(0xFF0C2B68),
            Color(0xFF144EA5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF071941).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Ambient glow radial background
            Positioned(
              right: -40,
              top: -40,
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
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account selector pill
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showAccountPicker(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MT5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${acc.server ?? 'GTCGlobalSA-Server 2(MT5)'} - ${acc.login}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.chevronDown, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.12),
                    height: 20,
                    thickness: 0.8,
                  ),
                  const SizedBox(height: 4),

                  // Account Balance (USD)
                  Text(
                    'Account Balance (USD)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    balance,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Equity and Credit Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Equity (USD)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              equity,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Credit (USD)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '0.00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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

  // --- Closed Order Statistics Section ---
  Widget _buildClosedOrderStatisticsSection(
    Color bg,
    Color border,
    Color muted,
    Color title,
    bool isDark,
  ) {
    final trades = _filteredTrades;
    final lots = trades.fold<double>(0, (sum, trade) => sum + (double.tryParse(trade.volume) ?? 0));
    final commission = trades.fold<double>(0, (sum, trade) => sum + trade.commission);
    final swap = trades.fold<double>(0, (sum, trade) => sum + trade.swap);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Closed Order Statistics',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: Trade Volume & Speedometer/Arc Gauge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Trade Lots',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lots.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: title,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 92,
                    height: 52,
                    child: CustomPaint(
                      painter: _VolumeArcGaugePainter(isDark: isDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                thickness: 0.8,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              ),
              const SizedBox(height: 14),

              // 2x2 grid stats
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Commissions', style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 4),
                        Text(commission.abs().toStringAsFixed(2), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
                        const SizedBox(height: 14),
                        Text('Trade Count', style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 4),
                        Text('${trades.length}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trade Lots', style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 4),
                        Text(lots.toStringAsFixed(2), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
                        const SizedBox(height: 14),
                        Text('Swap (USD)', style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 4),
                        Text(swap.toStringAsFixed(2), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Order P&L & Total P&L Card ---
  Widget _buildOrderAndTotalPnLCard(
    Color bg,
    Color border,
    Color muted,
    Color title,
    bool isDark,
  ) {
    final closedPnL = _filteredTrades.fold<double>(0, (sum, trade) => sum + trade.profit);
    const posPnL = 0.00;
    const posTotalPnL = 0.00;
    final closedTotalPnL = closedPnL;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Order P&L
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.barChart2, size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Text(
                  'Order P&L (USD)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: title,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Position P&L', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 2),
                    Text(
                      '0.00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _getPnLColor(posPnL, title),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Closed P&L', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 2),
                    Text(
                      '0.00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _getPnLColor(closedPnL, title),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 0.8,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 12),

          // Row 2: Total P&L
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.pieChart, size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Text(
                  'Total P&L (USD)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: title,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Position Total P&L', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 2),
                    Text(
                      '0.00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _getPnLColor(posTotalPnL, title),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Closed Total P&L', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 2),
                    Text(
                      '0.00',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _getPnLColor(closedTotalPnL, title),
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

  // --- Deposit / Withdraw 2x2 Grid Cards ---
  Widget _buildDepositWithdrawGrid(
    Color bg,
    Color border,
    Color muted,
    Color title,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(16)),
      child: Text('Cash flow is not included in closed-trade history.', style: TextStyle(color: muted, fontSize: 11)),
    );
  }

  Widget _buildDepositWithdrawGrid_UNUSED(
    Color bg,
    Color border,
    Color muted,
    Color title,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net Deposit (USD)', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.creditCard, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _hideNetDeposit ? '••••••' : '0.00',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _hideNetDeposit = !_hideNetDeposit);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              _hideNetDeposit ? LucideIcons.eyeOff : LucideIcons.eye,
                              size: 15,
                              color: muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deposit/Withdraw Count', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.refreshCw, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        Text('0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Deposit (USD)', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.arrowDownToLine, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        Text('0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Withdraw (USD)', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.arrowUpFromLine, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        Text('0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Data-driven account analytics ---
  DateTime? _tradeClosedDate(String value) {
    final lower = value.trim().toLowerCase();
    final now = DateTime.now();
    if (lower.startsWith('today')) {
      return DateTime(now.year, now.month, now.day);
    }
    if (lower.startsWith('yesterday')) {
      final yesterday = now.subtract(const Duration(days: 1));
      return DateTime(yesterday.year, yesterday.month, yesterday.day);
    }
    final isoDate = value.trim().replaceFirstMapped(
      RegExp(r'^(\d{4})\.(\d{2})\.(\d{2})'),
      (match) => '${match[1]}-${match[2]}-${match[3]}',
    );
    return DateTime.tryParse(isoDate);
  }

  List<BrokerTradeRecord> get _filteredTrades {
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endExclusive = DateTime(_endDate.year, _endDate.month, _endDate.day)
        .add(const Duration(days: 1));
    return _loadedTrades.where((trade) {
      if (_symbolFilter != 'All Symbols' && trade.symbol != _symbolFilter) {
        return false;
      }
      final closedDate = _tradeClosedDate(trade.closedAt);
      if (closedDate == null) return false;
      final day = DateTime(closedDate.year, closedDate.month, closedDate.day);
      return !day.isBefore(start) && day.isBefore(endExclusive);
    }).toList();
  }

  double _sumProfit(Iterable<BrokerTradeRecord> trades) =>
      trades.fold<double>(0, (sum, trade) => sum + trade.profit);

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String helper,
    required Color bg,
    required Color border,
    required Color title,
    required Color muted,
    required bool isDark,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w500)),
          const SizedBox(height: 7),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.4,
              color: valueColor ?? title)),
          const SizedBox(height: 3),
          Text(helper, style: TextStyle(fontSize: 10, color: muted)),
        ],
      ),
    );
  }

  Widget _buildEquityCurveSection(Color bg, Color border, Color title, bool isDark) {
    final history = <double>[];
    final muted = isDark ? const Color(0xFF8190A5) : const Color(0xFF8995A7);
    final start = history.isEmpty ? 0.0 : history.first;
    final end = history.isEmpty ? 0.0 : history.last;
    final change = end - start;
    final changeColor = change > 0 ? const Color(0xFF16A36A)
        : change < 0 ? const Color(0xFFEF5350) : muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Equity Curve', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: title)),
            const SizedBox(height: 3),
            Text('Account-provided equity snapshots', style: TextStyle(fontSize: 11, color: muted)),
          ])),
          if (history.length > 1)
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${change >= 0 ? '+' : '-'}${_currentAccount.currency} ${change.abs().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: changeColor)),
              Text('First to latest snapshot', style: TextStyle(fontSize: 9, color: muted)),
            ]),
        ]),
        const SizedBox(height: 11),
        Container(
          key: const Key('equity_curve_gesture'),
          height: 205,
          padding: const EdgeInsets.fromLTRB(12, 16, 14, 12),
          decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: history.length < 2
              ? _buildChartEmptyState(
                  'Equity history unavailable',
                  'This account has not supplied enough equity snapshots to draw a curve.',
                  isDark, muted,
                )
              : CustomPaint(
                  painter: _TradeReportLinePainter(
                    values: history,
                    lineColor: const Color(0xFF3B82F6),
                    gridColor: isDark ? const Color(0xFF29384D) : const Color(0xFFE9EEF5),
                    labelColor: muted,
                    currency: _currentAccount.currency,
                  ),
                  child: const SizedBox.expand(),
                ),
        ),
      ],
    );
  }

  Widget _buildChartEmptyState(String heading, String detail, bool isDark, Color muted) {
    final title = isDark ? const Color(0xFFF7FAFF) : const Color(0xFF142033);
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(LucideIcons.barChart2, size: 27, color: muted),
      const SizedBox(height: 9),
      Text(heading, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: title)),
      const SizedBox(height: 4),
      Text(detail, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, height: 1.4, color: muted)),
    ]));
  }

  Widget _buildPnLAnalysisSection(
    Color bg,
    Color border,
    Color muted,
    Color title,
    bool isDark,
  ) {
    final trades = _filteredTrades;
    final winners = trades.where((trade) => trade.profit > 0).toList();
    final losers = trades.where((trade) => trade.profit < 0).toList();
    final totalProfit = _sumProfit(trades);
    final grossProfit = _sumProfit(winners);
    final grossLoss = _sumProfit(losers).abs();
    final winRate = trades.isEmpty ? 0.0 : winners.length / trades.length * 100;
    final averageWin = winners.isEmpty ? 0.0 : grossProfit / winners.length;
    final averageLoss = losers.isEmpty ? 0.0 : grossLoss / losers.length;
    final profitFactor = grossLoss == 0 ? (grossProfit > 0 ? null : 0.0) : grossProfit / grossLoss;
    final pnlColor = totalProfit > 0 ? const Color(0xFF16A36A)
        : totalProfit < 0 ? const Color(0xFFEF5350) : title;
    final currency = _currentAccount.currency;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('P&L Analysis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: title)),
          const SizedBox(height: 3),
          Text('Closed trade results · ${_symbolFilter}', style: TextStyle(fontSize: 11, color: muted)),
        ])),
        PopupMenuButton<String>(
          initialValue: _symbolFilter,
          tooltip: 'Filter by symbol',
          onSelected: (value) => setState(() => _symbolFilter = value),
          color: bg,
          itemBuilder: (_) => _symbolOptions.map((symbol) => PopupMenuItem(
            value: symbol, child: Text(symbol),
          )).toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_symbolFilter, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: title)),
              const SizedBox(width: 5),
              Icon(LucideIcons.chevronDown, size: 14, color: muted),
            ]),
          ),
        ),
      ]),
      const SizedBox(height: 13),
      Row(children: [
        Expanded(child: _buildMetricTile(label: 'Net closed P&L',
          value: '${totalProfit < 0 ? '-' : ''}$currency ${totalProfit.abs().toStringAsFixed(2)}',
          helper: '${trades.length} supplied trade records', bg: bg, border: border,
          title: title, muted: muted, isDark: isDark, valueColor: pnlColor)),
        const SizedBox(width: 9),
        Expanded(child: _buildMetricTile(label: 'Win rate',
          value: '${winRate.toStringAsFixed(1)}%',
          helper: '${winners.length} wins · ${losers.length} losses',
          bg: bg, border: border, title: title, muted: muted, isDark: isDark,
          valueColor: const Color(0xFF16A36A))),
      ]),
      const SizedBox(height: 9),
      Row(children: [
        Expanded(child: _buildMetricTile(label: 'Average win',
          value: '$currency ${averageWin.toStringAsFixed(2)}', helper: 'Per winning trade',
          bg: bg, border: border, title: title, muted: muted, isDark: isDark,
          valueColor: const Color(0xFF16A36A))),
        const SizedBox(width: 9),
        Expanded(child: _buildMetricTile(label: 'Average loss',
          value: '$currency ${averageLoss.toStringAsFixed(2)}', helper: 'Per losing trade',
          bg: bg, border: border, title: title, muted: muted, isDark: isDark,
          valueColor: const Color(0xFFEF5350))),
      ]),
      const SizedBox(height: 9),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Profit factor', style: TextStyle(fontSize: 12, color: muted))),
            Text(grossLoss == 0 ? (grossProfit > 0 ? 'No losses recorded' : '—') : profitFactor!.toStringAsFixed(2),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: title)),
          ]),
          const SizedBox(height: 10),
          if (trades.isNotEmpty)
            ClipRRect(borderRadius: BorderRadius.circular(6), child: Row(children: [
              if (winners.isNotEmpty) Expanded(flex: winners.length, child: Container(height: 8, color: const Color(0xFF16A36A))),
              if (losers.isNotEmpty) Expanded(flex: losers.length, child: Container(height: 8, color: const Color(0xFFEF5350))),
              if (trades.length == winners.length + losers.length && winners.isEmpty && losers.isEmpty)
                Expanded(child: Container(height: 8, color: muted.withValues(alpha: .35))),
            ]))
          else
            Text('No closed trade records for this symbol.', style: TextStyle(fontSize: 11, color: muted)),
          const SizedBox(height: 7),
          Row(children: [
            _buildLegendDot(const Color(0xFF16A36A), 'Winning trades', muted),
            const SizedBox(width: 14),
            _buildLegendDot(const Color(0xFFEF5350), 'Losing trades', muted),
          ]),
        ]),
      ),
      const SizedBox(height: 13),
      Row(children: [
        Expanded(child: Text('Trade P&L breakdown', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: title))),
        Text(currency, style: TextStyle(fontSize: 10, color: muted)),
      ]),
      const SizedBox(height: 8),
      Container(
        key: const Key('pnl_chart_gesture'),
        height: 190,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(17),
          border: Border.all(color: border)),
        child: trades.isEmpty
            ? _buildChartEmptyState('No P&L data for this selection',
                'Closed trade results will appear here when supplied by the account.', isDark, muted)
            : CustomPaint(
                painter: _TradeReportBarPainter(
                  values: trades.map((trade) => trade.profit).toList(),
                  labels: trades.map((trade) => trade.symbol).toList(),
                  positiveColor: const Color(0xFF16A36A),
                  negativeColor: const Color(0xFFEF5350),
                  gridColor: isDark ? const Color(0xFF29384D) : const Color(0xFFE9EEF5),
                  labelColor: muted,
                ),
                child: const SizedBox.expand(),
              ),
      ),
      const SizedBox(height: 13),
      Text('Recent closed trades', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: title)),
      const SizedBox(height: 7),
      if (trades.isEmpty)
        Text('No recent trades available.', style: TextStyle(fontSize: 11, color: muted))
      else
        ...trades.take(5).map((trade) {
          final positive = trade.profit >= 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13),
              border: Border.all(color: border)),
            child: Row(children: [
              Container(width: 34, height: 34,
                decoration: BoxDecoration(color: (positive ? const Color(0xFF16A36A) : const Color(0xFFEF5350)).withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(trade.side.toLowerCase() == 'buy' ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                  size: 16, color: positive ? const Color(0xFF16A36A) : const Color(0xFFEF5350))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trade.symbol, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: title)),
                const SizedBox(height: 2),
                Text('${trade.side.toUpperCase()} · ${trade.volume} lots · ${trade.closedAt}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: muted)),
              ])),
              Text('${positive ? '+' : '-'}\$${trade.profit.abs().toStringAsFixed(2)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: positive ? const Color(0xFF16A36A) : const Color(0xFFEF5350))),
            ]),
          );
        }),
      const SizedBox(height: 6),
      Text('Analytics are calculated from the trade records and equity snapshots supplied to this account. They are not a substitute for a complete MT5 deal-history feed.',
        style: TextStyle(fontSize: 9, height: 1.4, color: muted)),
    ]);
  }

  Widget _buildLegendDot(Color color, String label, Color muted) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(fontSize: 9, color: muted)),
  ]);

  Widget _buildTimeframePill(String label, bool active) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _timeframe = label;
          _pnlScrubOffset = null;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Speedometer / Arc Gauge Painter with volume bars inside
// -----------------------------------------------------------------------------
class _VolumeArcGaugePainter extends CustomPainter {
  const _VolumeArcGaugePainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width / 2) - 4;

    // Track arc
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      trackPaint,
    );

    // Active arc (blue)
    final activePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      activePaint,
    );

    // Inner vertical volume bars with pleasant blue gradients
    final barGradients = [
      [const Color(0xFF93C5FD), const Color(0xFF60A5FA)],
      [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      [const Color(0xFF60A5FA), const Color(0xFF2563EB)],
      [const Color(0xFFBFDBFE), const Color(0xFF93C5FD)],
    ];
    final barHeights = [13.0, 26.0, 19.0, 10.0];
    const barWidth = 4.5;
    const barSpacing = 4.0;
    final totalWidth = (barHeights.length * barWidth) + ((barHeights.length - 1) * barSpacing);
    var startX = (size.width - totalWidth) / 2;
    final baseY = size.height - 2;

    for (int i = 0; i < barHeights.length; i++) {
      final h = barHeights[i];
      final rect = Rect.fromLTWH(startX, baseY - h, barWidth, h);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.5));
      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: barGradients[i % barGradients.length],
      ).createShader(rect);
      final p = Paint()..shader = shader;
      canvas.drawRRect(rrect, p);
      startX += barWidth + barSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant _VolumeArcGaugePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// -----------------------------------------------------------------------------
// Equity Curve Painter (solid blue curve line with Y-grid and X-dates)
// -----------------------------------------------------------------------------
class _EquityCurvePainter extends CustomPainter {
  const _EquityCurvePainter({
    required this.isDark,
    this.scrubOffset,
  });
  final bool isDark;
  final Offset? scrubOffset;

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 28.0;
    const bottomMargin = 22.0;
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin;

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // Y-axis grid and labels: 1, 0.8, 0.6, 0.4, 0.2, 0
    final yLabels = ['1', '0.8', '0.6', '0.4', '0.2', '0'];
    for (int i = 0; i < yLabels.length; i++) {
      final y = (chartHeight / (yLabels.length - 1)) * i;

      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 6, y - tp.height / 2));
    }

    final baselineY = chartHeight;

    // Smooth blue gradient fill beneath the curve down to baseline
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF2563EB).withValues(alpha: 0.16),
        const Color(0xFF2563EB).withValues(alpha: 0.0),
      ],
    );
    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(leftMargin, baselineY - 26, chartWidth, 26))
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(leftMargin, baselineY - 26, chartWidth, 26), fillPaint);

    // Solid blue curve/line across baseline
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(leftMargin, baselineY),
      Offset(size.width, baselineY),
      linePaint,
    );

    // X-axis dates: 10/18, 11/02, 11/17
    final dates = ['10/18', '11/02', '11/17'];
    for (int i = 0; i < dates.length; i++) {
      final x = leftMargin + (chartWidth / (dates.length - 1)) * i;
      final tp = TextPainter(
        text: TextSpan(text: dates[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      var dx = x - tp.width / 2;
      if (i == 0) dx = leftMargin;
      if (i == dates.length - 1) dx = size.width - tp.width;

      tp.paint(canvas, Offset(dx, chartHeight + 6));
    }

    // Touch scrubbing indicator
    if (scrubOffset != null) {
      final clampedX = scrubOffset!.dx.clamp(leftMargin, size.width);

      // Guide line
      final guidePaint = Paint()
        ..color = const Color(0xFF2563EB).withValues(alpha: 0.45)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(clampedX, 0),
        Offset(clampedX, baselineY),
        guidePaint,
      );

      // Glowing dot at baseline
      final haloPaint = Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.25);
      canvas.drawCircle(Offset(clampedX, baselineY), 8.0, haloPaint);

      final dotOuterPaint = Paint()..color = const Color(0xFF2563EB);
      canvas.drawCircle(Offset(clampedX, baselineY), 4.5, dotOuterPaint);

      final dotInnerPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(clampedX, baselineY), 2.0, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EquityCurvePainter oldDelegate) =>
      oldDelegate.isDark != isDark || oldDelegate.scrubOffset != scrubOffset;
}

// -----------------------------------------------------------------------------
// P&L Analysis Chart Painter (dashed blue baseline across intervals)
// -----------------------------------------------------------------------------
class _PnLAnalysisChartPainter extends CustomPainter {
  const _PnLAnalysisChartPainter({
    required this.isDark,
    required this.timeframe,
    this.scrubOffset,
  });
  final bool isDark;
  final String timeframe;
  final Offset? scrubOffset;

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 28.0;
    const bottomMargin = 22.0;
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin;

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // Y-axis grid and labels: 1, 0.8, 0.6, 0.4, 0.2, 0
    final yLabels = ['1', '0.8', '0.6', '0.4', '0.2', '0'];
    for (int i = 0; i < yLabels.length; i++) {
      final y = (chartHeight / (yLabels.length - 1)) * i;

      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(size.width, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 6, y - tp.height / 2));
    }

    // Dashed blue baseline along 0
    final baselineY = chartHeight;
    final dotPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const dashWidth = 3.5;
    const dashSpace = 4.0;
    double curX = leftMargin;
    while (curX < size.width) {
      canvas.drawLine(
        Offset(curX, baselineY),
        Offset(math.min(curX + dashWidth, size.width), baselineY),
        dotPaint,
      );
      curX += dashWidth + dashSpace;
    }

    // X-axis intervals
    final labels = timeframe == 'Hour'
        ? const ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:59']
        : const [
            '10/18',
            '10/22',
            '10/26',
            '10/30',
            '11/03',
            '11/07',
            '11/11',
            '11/15',
          ];

    for (int i = 0; i < labels.length; i++) {
      final x = leftMargin + (chartWidth / (labels.length - 1)) * i;
      final tp = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      var dx = x - tp.width / 2;
      if (i == 0) dx = leftMargin;
      if (i == labels.length - 1) dx = size.width - tp.width;

      tp.paint(canvas, Offset(dx, chartHeight + 6));
    }

    // Touch scrubbing indicator
    if (scrubOffset != null) {
      final clampedX = scrubOffset!.dx.clamp(leftMargin, size.width);

      // Guide line
      final guidePaint = Paint()
        ..color = const Color(0xFF2563EB).withValues(alpha: 0.45)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(clampedX, 0),
        Offset(clampedX, baselineY),
        guidePaint,
      );

      // Glowing dot
      final haloPaint = Paint()..color = const Color(0xFF2563EB).withValues(alpha: 0.25);
      canvas.drawCircle(Offset(clampedX, baselineY), 8.0, haloPaint);

      final dotOuterPaint = Paint()..color = const Color(0xFF2563EB);
      canvas.drawCircle(Offset(clampedX, baselineY), 4.5, dotOuterPaint);

      final dotInnerPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(clampedX, baselineY), 2.0, dotInnerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PnLAnalysisChartPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.timeframe != timeframe ||
      oldDelegate.scrubOffset != scrubOffset;
}


class _TradeReportLinePainter extends CustomPainter {
  const _TradeReportLinePainter({
    required this.values, required this.lineColor, required this.gridColor,
    required this.labelColor, required this.currency,
  });
  final List<double> values;
  final Color lineColor, gridColor, labelColor;
  final String currency;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2 || size.isEmpty) return;
    const left = 48.0, right = 5.0, top = 8.0, bottom = 22.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final spread = (maxValue - minValue).abs();
    final pad = spread == 0 ? math.max(1.0, maxValue.abs() * .02).toDouble() : spread * .16;
    final low = minValue - pad, high = maxValue + pad;
    final y = (double v) => chart.bottom - ((v - low) / (high - low)) * chart.height;
    final grid = Paint()..color = gridColor..strokeWidth = 1;
    final textStyle = TextStyle(color: labelColor, fontSize: 9);
    for (var i = 0; i <= 3; i++) {
      final gy = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, gy), Offset(chart.right, gy), grid);
      final value = high - (high - low) * i / 3;
      final tp = TextPainter(text: TextSpan(text: value.toStringAsFixed(0), style: textStyle),
        textDirection: TextDirection.ltr)..layout(maxWidth: left - 5);
      tp.paint(canvas, Offset(0, gy - tp.height / 2));
    }
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = chart.left + chart.width * i / (values.length - 1);
      final point = Offset(x, y(values[i]));
      if (i == 0) { path.moveTo(point.dx, point.dy); } else { path.lineTo(point.dx, point.dy); }
    }
    final fillPath = Path.from(path)..lineTo(chart.right, chart.bottom)..lineTo(chart.left, chart.bottom)..close();
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(
      colors: [lineColor.withValues(alpha: .22), lineColor.withValues(alpha: .01)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(chart));
    canvas.drawPath(path, Paint()..color = lineColor..strokeWidth = 2.4
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
    for (final index in [0, values.length - 1]) {
      final x = chart.left + chart.width * index / (values.length - 1);
      canvas.drawCircle(Offset(x, y(values[index])), 3.5, Paint()..color = lineColor);
    }
    final first = TextPainter(text: TextSpan(text: 'First', style: textStyle), textDirection: TextDirection.ltr)..layout();
    final last = TextPainter(text: TextSpan(text: 'Latest', style: textStyle), textDirection: TextDirection.ltr)..layout();
    first.paint(canvas, Offset(chart.left, chart.bottom + 7));
    last.paint(canvas, Offset(chart.right - last.width, chart.bottom + 7));
  }

  @override
  bool shouldRepaint(covariant _TradeReportLinePainter old) =>
      old.values != values || old.lineColor != lineColor || old.gridColor != gridColor;
}

class _TradeReportBarPainter extends CustomPainter {
  const _TradeReportBarPainter({
    required this.values, required this.labels, required this.positiveColor,
    required this.negativeColor, required this.gridColor, required this.labelColor,
  });
  final List<double> values;
  final List<String> labels;
  final Color positiveColor, negativeColor, gridColor, labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) return;
    const left = 8.0, right = 6.0, top = 8.0, bottom = 27.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final maxAbs = values.map((v) => v.abs()).reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity).toDouble();
    final zeroY = chart.top + chart.height / 2;
    final grid = Paint()..color = gridColor..strokeWidth = 1;
    canvas.drawLine(Offset(chart.left, zeroY), Offset(chart.right, zeroY), grid);
    final slot = chart.width / values.length;
    final barWidth = math.min(25.0, slot * .52).toDouble();
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      final barHeight = (value.abs() / maxAbs) * (chart.height * .43);
      final x = chart.left + slot * i + (slot - barWidth) / 2;
      final rect = value >= 0
          ? Rect.fromLTWH(x, zeroY - barHeight, barWidth, barHeight)
          : Rect.fromLTWH(x, zeroY, barWidth, barHeight);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        Paint()..color = value >= 0 ? positiveColor : negativeColor);
      final label = labels[i].length > 7 ? labels[i].substring(0, 7) : labels[i];
      final tp = TextPainter(text: TextSpan(text: label,
        style: TextStyle(color: labelColor, fontSize: math.min(9.0, slot * .24).toDouble())),
        textDirection: TextDirection.ltr)..layout(maxWidth: slot);
      tp.paint(canvas, Offset(x + (barWidth - tp.width) / 2, chart.bottom + 7));
    }
  }

  @override
  bool shouldRepaint(covariant _TradeReportBarPainter old) =>
      old.values != values || old.labels != labels || old.gridColor != gridColor;
}
