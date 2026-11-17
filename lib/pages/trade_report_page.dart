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
  String _symbolFilter = 'All Symbols';
  String _timeframe = 'Day';
  bool _hideNetDeposit = false;

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
    _startDate = DateTime(2026, 11, 1);
    _endDate = DateTime(2026, 11, 17);
  }

  @override
  void didUpdateWidget(covariant TradeReportPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAccountLogin != null &&
        widget.selectedAccountLogin != oldWidget.selectedAccountLogin) {
      _selectedLogin = widget.selectedAccountLogin!;
    }
  }

  List<BrokerAccount> get _allAccounts {
    if (widget.accounts != null && widget.accounts!.isNotEmpty) {
      return widget.accounts!;
    }
    return const [
      BrokerAccount(
        'V Tamizharasan',
        '52132132',
        '1:500',
        r'$0.00',
        r'$0.00',
        'Live MT5',
        server: 'GTCGlobalSA-Server 2(MT5)',
      ),
      BrokerAccount(
        'XRSIM-USD-1',
        '3315',
        '1:100',
        r'$10,000.00',
        r'$10,000.00',
        'Demo MT5',
        server: 'GTCGlobalSA-Demo(MT5)',
      ),
      BrokerAccount(
        'Main MT5',
        '8820412',
        '1:200',
        r'$2,450.00',
        r'$2,450.00',
        'Live MT5',
        server: 'GTCGlobalSA-Live 1(MT5)',
      ),
    ];
  }

  BrokerAccount get _currentAccount {
    final list = _allAccounts;
    return list.firstWhere(
      (a) => a.login == _selectedLogin,
      orElse: () => list.first,
    );
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

  Future<void> _selectDateRange() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF131D2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  'Select Trade Time Range',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.calendarCheck, size: 20, color: Color(0xFF2563EB)),
                  title: const Text('Today', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onTap: () => Navigator.pop(ctx, 'today'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.calendarRange, size: 20, color: Color(0xFF2563EB)),
                  title: const Text('Last 7 Days', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onTap: () => Navigator.pop(ctx, '7days'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.calendarDays, size: 20, color: Color(0xFF2563EB)),
                  title: const Text('Last 30 Days', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onTap: () => Navigator.pop(ctx, '30days'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.calendar, size: 20, color: Color(0xFF2563EB)),
                  title: const Text('Custom Range...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onTap: () => Navigator.pop(ctx, 'custom'),
                ),
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
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day);
      });
    } else if (action == '7days') {
      setState(() {
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
      });
    } else if (action == '30days') {
      setState(() {
        _startDate = now.subtract(const Duration(days: 30));
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
          _startDate = picked.start;
          _endDate = picked.end;
        });
      }
    }
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
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF131D2E) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final mutedText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final titleText = isDark ? Colors.white : const Color(0xFF0F172A);

    final currentAcc = _currentAccount;
    final balanceStr = _formatCurrency(currentAcc.balance);
    final equityStr = _formatCurrency(currentAcc.equity);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: _handleBack,
        ),
        title: Text(
          'Trade Report',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: titleText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Date Range Filter Row
            _buildDateRangeFilterRow(cardBg, cardBorder, mutedText, titleText),
            const SizedBox(height: 12),

            // 2. Hero Account Summary Card (Royal Blue Gradient)
            _buildHeroAccountCard(currentAcc, balanceStr, equityStr),
            const SizedBox(height: 16),

            // 3. Closed Order Statistics Section
            _buildClosedOrderStatisticsSection(cardBg, cardBorder, mutedText, titleText, isDark),
            const SizedBox(height: 16),

            // 4. Order P&L & Total P&L Card
            _buildOrderAndTotalPnLCard(cardBg, cardBorder, mutedText, titleText, isDark),
            const SizedBox(height: 16),

            // 5. Deposit / Withdraw 2x2 Grid Cards
            _buildDepositWithdrawGrid(cardBg, cardBorder, mutedText, titleText, isDark),
            const SizedBox(height: 20),

            // 6. Equity Curve Section
            _buildEquityCurveSection(cardBg, cardBorder, titleText, isDark),
            const SizedBox(height: 20),

            // 7. P&L Analysis Section
            _buildPnLAnalysisSection(cardBg, cardBorder, mutedText, titleText, isDark),
          ],
        ),
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

  // --- Hero Account Summary Card (Royal Blue Gradient) ---
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Account selector pill
          InkWell(
            onTap: () => _showAccountPicker(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
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
          const SizedBox(height: 8),
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
                        'Trade Volume (Million USD)',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '0.0000',
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
                    width: 90,
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
                        Text('0.00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
                        const SizedBox(height: 14),
                        Text('Trade Count', style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 4),
                        Text('0', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trade Lots', style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 4),
                        Text('0.00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
                        const SizedBox(height: 14),
                        Text('Interest (USD)', style: TextStyle(fontSize: 12, color: muted)),
                        const SizedBox(height: 4),
                        Text('0.00', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: title)),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.barChart2, size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 8),
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
                    Text('0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title)),
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
                    Text('0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title)),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.pieChart, size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 8),
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
                    Text('0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title)),
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
                    Text('0.00', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title)),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Net Deposit (USD)', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(LucideIcons.creditCard, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _hideNetDeposit ? '••••••' : '0.00',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: title),
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _hideNetDeposit = !_hideNetDeposit),
                          child: Icon(
                            _hideNetDeposit ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 15,
                            color: muted,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deposit/Withdraw Count', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(LucideIcons.refreshCw, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 6),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Deposit (USD)', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(LucideIcons.arrowDownToLine, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 6),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Withdraw (USD)', style: TextStyle(fontSize: 11, color: muted)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(LucideIcons.arrowUpFromLine, size: 14, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 6),
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

  // --- Equity Curve Section ---
  Widget _buildEquityCurveSection(
    Color bg,
    Color border,
    Color title,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Equity Curve',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: title,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 180,
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
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
          child: CustomPaint(
            size: Size.infinite,
            painter: _EquityCurvePainter(isDark: isDark),
          ),
        ),
      ],
    );
  }

  // --- P&L Analysis Section ---
  Widget _buildPnLAnalysisSection(
    Color bg,
    Color border,
    Color muted,
    Color title,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title and Symbol Selector Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'P&L Analysis',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: title,
              ),
            ),
            PopupMenuButton<String>(
              initialValue: _symbolFilter,
              onSelected: (val) => setState(() => _symbolFilter = val),
              color: bg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: border, width: 0.8),
              ),
              itemBuilder: (ctx) => _symbolOptions
                  .map(
                    (s) => PopupMenuItem<String>(
                      value: s,
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: s == _symbolFilter ? FontWeight.w700 : FontWeight.w500,
                          color: s == _symbolFilter ? const Color(0xFF2563EB) : title,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _symbolFilter,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: title),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.chevronDown, size: 13, color: muted),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Day / Hour Pill Switch
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                children: [
                  _buildTimeframePill('Day', _timeframe == 'Day'),
                  _buildTimeframePill('Hour', _timeframe == 'Hour'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // P&L Chart Container
        Container(
          height: 190,
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
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
          child: CustomPaint(
            size: Size.infinite,
            painter: _PnLAnalysisChartPainter(isDark: isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframePill(String label, bool active) {
    return InkWell(
      onTap: () => setState(() => _timeframe = label),
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
            color: active ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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

    // Inner vertical volume bars
    final barColors = [
      const Color(0xFF93C5FD),
      const Color(0xFF2563EB),
      const Color(0xFF60A5FA),
      const Color(0xFFBFDBFE),
    ];
    final barHeights = [14.0, 26.0, 19.0, 9.0];
    const barWidth = 4.5;
    const barSpacing = 4.0;
    final totalWidth = (barHeights.length * barWidth) + ((barHeights.length - 1) * barSpacing);
    var startX = (size.width - totalWidth) / 2;
    final baseY = size.height - 2;

    for (int i = 0; i < barHeights.length; i++) {
      final h = barHeights[i];
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(startX, baseY - h, barWidth, h),
        const Radius.circular(2),
      );
      final p = Paint()..color = barColors[i % barColors.length];
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
  const _EquityCurvePainter({required this.isDark});
  final bool isDark;

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

    // Solid blue curve/line across baseline
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final baselineY = chartHeight;
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
  }

  @override
  bool shouldRepaint(covariant _EquityCurvePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// -----------------------------------------------------------------------------
// P&L Analysis Chart Painter (dashed blue baseline across 8 dates)
// -----------------------------------------------------------------------------
class _PnLAnalysisChartPainter extends CustomPainter {
  const _PnLAnalysisChartPainter({required this.isDark});
  final bool isDark;

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

    // X-axis dates: 10/18, 10/22, 10/26, 10/30, 11/03, 11/07, 11/11, 11/15
    final dates = [
      '10/18',
      '10/22',
      '10/26',
      '10/30',
      '11/03',
      '11/07',
      '11/11',
      '11/15',
    ];
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
  }

  @override
  bool shouldRepaint(covariant _PnLAnalysisChartPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
