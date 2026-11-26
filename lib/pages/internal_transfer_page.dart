part of '../main.dart';

class _InternalTransferRecord {
  const _InternalTransferRecord({
    required this.id,
    required this.sourceLogin,
    required this.destinationLogin,
    required this.amount,
    required this.timestamp,
    required this.status,
  });

  final String id;
  final String sourceLogin;
  final String destinationLogin;
  final double amount;
  final DateTime timestamp;
  final String status;
}

class BrokerInternalTransferPage extends StatefulWidget {
  const BrokerInternalTransferPage({
    super.key,
    this.accounts,
    this.initialSourceLogin,
    this.initialDestinationLogin,
    this.onBack,
    this.onSelectPage,
    this.onTransferCompleted,
  });

  final List<BrokerAccount>? accounts;
  final String? initialSourceLogin;
  final String? initialDestinationLogin;
  final VoidCallback? onBack;
  final ValueChanged<String>? onSelectPage;
  final void Function(String fromLogin, String toLogin, double amount)? onTransferCompleted;

  @override
  State<BrokerInternalTransferPage> createState() => _BrokerInternalTransferPageState();
}

class _BrokerInternalTransferPageState extends State<BrokerInternalTransferPage> {


  late final List<BrokerAccount> _accountList;
  final Map<String, double> _balances = {};
  late String _source;
  late String _destination;
  final _amountController = TextEditingController();
  bool _isProcessing = false;

  static double _parseBalance(String balanceStr) {
    final clean = balanceStr.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  static String _formatMoney(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final parts = absAmount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    final len = intPart.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }
    return '${isNegative ? '-' : ''}\$${buffer.toString()}.$decPart';
  }

  @override
  void initState() {
    super.initState();
    final rawAccounts = widget.accounts ?? const <BrokerAccount>[];
    _accountList = List.from(rawAccounts);

    for (final acc in _accountList) {
      _balances[acc.login] = _parseBalance(acc.balance);
    }

    if (_accountList.isEmpty) {
      _source = '';
      _destination = '';
    } else {
      if (widget.initialSourceLogin != null &&
          _accountList.any((a) => a.login == widget.initialSourceLogin)) {
        _source = widget.initialSourceLogin!;
      } else {
        final firstWithFunds = _accountList.firstWhere(
          (a) => (_balances[a.login] ?? 0) > 0,
          orElse: () => _accountList.first,
        );
        _source = firstWithFunds.login;
      }

      if (widget.initialDestinationLogin != null &&
          _accountList.any((a) => a.login == widget.initialDestinationLogin) &&
          widget.initialDestinationLogin != _source) {
        _destination = widget.initialDestinationLogin!;
      } else {
        final other = _accountList.firstWhere(
          (a) => a.login != _source,
          orElse: () => _accountList.first,
        );
        _destination = other.login;
      }
    }

    _loadLiveAccounts();
  }

  Future<void> _loadLiveAccounts() async {
    try {
      final res = await AuthApi.instance.getNonDemoAccounts(fresh: true);
      final accs = (res['accounts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (accs.isNotEmpty && mounted) {
        final liveAccs = <BrokerAccount>[];
        for (final m in accs) {
          final id = m['account_id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final bal = (m['balance'] as num?)?.toDouble() ?? 0.0;
          final eq = (m['equity'] as num?)?.toDouble() ?? bal;
          final name = m['name'] ?? m['account_name'] ?? 'Live MT5';
          final lev = m['leverage'] != null ? '1:${m['leverage']}' : '1:500';
          liveAccs.add(BrokerAccount(
            name.toString(), id, lev, _formatMoney(bal), _formatMoney(eq), 'Live MT5',
            server: 'VTIndex-Live', currency: 'USD',
          ));
        }
        if (liveAccs.isNotEmpty) {
          setState(() {
            _accountList.clear();
            _accountList.addAll(liveAccs);
            for (final a in liveAccs) {
              _balances[a.login] = _parseBalance(a.balance);
            }
            if (!_accountList.any((a) => a.login == _source)) {
              _source = _accountList.first.login;
            }
            if (!_accountList.any((a) => a.login == _destination)) {
              _destination = _accountList.length > 1 ? _accountList[1].login : _accountList.first.login;
            }
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _availableBalance => _balances[_source] ?? 0.0;
  double get _destinationBalance => _balances[_destination] ?? 0.0;
  double get _parsedAmount => double.tryParse(_amountController.text.trim()) ?? 0.0;

  bool get _isRouteValid => _source != _destination;
  bool get _isAmountValid => _parsedAmount > 0 && _parsedAmount <= _availableBalance;
  bool get _canSubmit => _isRouteValid && _isAmountValid && !_isProcessing;

  BrokerAccount _accountFor(String login) {
    return _accountList.firstWhere(
      (a) => a.login == login,
      orElse: () => BrokerAccount('Account', login, '1:500', r'$0.00', r'$0.00', 'Live MT5'),
    );
  }

  void _setAmount(double amount) {
    AppHaptics.lightImpact();
    _amountController.text = amount.toStringAsFixed(2);
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
    setState(() {});
  }

  void _swapAccounts() {
    AppHaptics.lightImpact();
    setState(() {
      final temp = _source;
      _source = _destination;
      _destination = temp;
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;
    final isNarrow = MediaQuery.sizeOf(context).width < 380;

    final brandPrimary = colors.primary;
    final cardBorderColor = isDark
        ? Colors.white.withValues(alpha: .10)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF071941) : const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          'Internal Transfer',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0C2B68) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Transfer information',
            icon: const Icon(LucideIcons.circleHelp),
            onPressed: () => _showGuidelines(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.fromLTRB(isNarrow ? 12 : 16, 16, isNarrow ? 12 : 16, 120),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Subtitle & Header Tagline
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Internal Transfer',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Move funds between your trading accounts',
                                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: .3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'TRANSFER PREVIEW',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF10B981),
                                    letterSpacing: .5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_accountList.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.error.withValues(alpha: .25)),
                        ),
                        child: Text(
                          'No eligible live trading accounts are available. Refresh the page or contact support if you believe this is incorrect.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    // Main Transfer Route Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0C2B68) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: cardBorderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? .22 : .04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                'TRANSFER ROUTE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: brandPrimary.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'TRANSFER PREVIEW',
                                      style: TextStyle(
                                        color: brandPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // From Account Picker
                          _buildAccountTile(
                            context: context,
                            title: 'FROM ACCOUNT',
                            selectedLogin: _source,
                            balance: _availableBalance,
                            onTap: () => _showAccountPickerModal(context, isSource: true),
                          ),

                          // Central Swap Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: .12)
                                        : const Color(0xFFE2E8F0),
                                    thickness: 1,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Tooltip(
                                  message: 'Swap accounts',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      key: const ValueKey('swap_accounts_button'),
                                      onTap: _swapAccounts,
                                      borderRadius: BorderRadius.circular(24),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: brandPrimary.withValues(alpha: isDark ? .25 : .10),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: brandPrimary.withValues(alpha: .35),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Icon(
                                          LucideIcons.arrowDownUp,
                                          color: brandPrimary,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Divider(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: .12)
                                        : const Color(0xFFE2E8F0),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // To Account Picker
                          _buildAccountTile(
                            context: context,
                            title: 'TO ACCOUNT',
                            selectedLogin: _destination,
                            balance: _destinationBalance,
                            onTap: () => _showAccountPickerModal(context, isSource: false),
                          ),

                          // Route Error Banner if identical
                          if (!_isRouteValid) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: .3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(LucideIcons.circleAlert, color: Color(0xFFEF4444), size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Source and destination accounts must be different.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Transfer Amount Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0C2B68) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: cardBorderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? .22 : .04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                'TRANSFER AMOUNT',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: muted,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: .08) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'USD',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                                    letterSpacing: .5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Big Input Field
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF071941).withValues(alpha: .6)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _parsedAmount > _availableBalance
                                    ? const Color(0xFFEF4444)
                                    : (_parsedAmount > 0
                                        ? brandPrimary
                                        : (isDark ? Colors.white.withValues(alpha: .12) : const Color(0xFFCBD5E1))),
                                width: _parsedAmount > 0 ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  r'$',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: brandPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    onChanged: (_) => setState(() {}),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -.5,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      hintStyle: theme.textTheme.headlineMedium?.copyWith(
                                        color: muted.withValues(alpha: .35),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                if (_amountController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(LucideIcons.x, size: 18),
                                    color: muted,
                                    tooltip: 'Clear',
                                    onPressed: () {
                                      _amountController.clear();
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Available Balance Bar with MAX button
                          Row(
                            children: [
                              Icon(LucideIcons.wallet, size: 14, color: muted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Available: ${_formatMoney(_availableBalance)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _availableBalance > 0 ? () => _setAmount(_availableBalance) : null,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text(
                                  'MAX',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ),
                            ],
                          ),

                          // Inline Error / Valid indicator
                          if (_parsedAmount > _availableBalance) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(LucideIcons.circleAlert, size: 13, color: Color(0xFFEF4444)),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'Amount exceeds available balance (${_formatMoney(_availableBalance)})',
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Transfer Summary Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0C2B68).withValues(alpha: .7) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: cardBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.receipt, size: 15, color: Color(0xFF1658C9)),
                              const SizedBox(width: 8),
                              Text(
                                'Transfer Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildSummaryRow(
                            label: 'Fee',
                            value: 'Not verified',
                            valueColor: const Color(0xFF10B981),
                            isBold: true,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            label: 'Execution',
                            value: 'Not submitted',
                            valueColor: brandPrimary,
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            label: 'Exchange Rate',
                            value: 'Not applicable',
                            valueColor: muted,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              color: isDark ? Colors.white.withValues(alpha: .1) : const Color(0xFFE2E8F0),
                            ),
                          ),
                          _buildSummaryRow(
                            label: 'Source Balance',
                            value: '${_formatMoney(_availableBalance)} ➔ ${_formatMoney((_availableBalance - _parsedAmount).clamp(0.0, double.infinity))}',
                            valueColor: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            label: 'Destination Balance',
                            value: '${_formatMoney(_destinationBalance)} ➔ ${_formatMoney(_destinationBalance + _parsedAmount)}',
                            valueColor: const Color(0xFF10B981),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Continue Action Button
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _canSubmit ? _showConfirmationSheet : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: brandPrimary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: brandPrimary.withValues(alpha: .35),
                          disabledForegroundColor: Colors.white60,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: _canSubmit ? 3 : 0,
                          shadowColor: brandPrimary.withValues(alpha: .4),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'CONTINUE',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: .8,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(LucideIcons.arrowRight, size: 18),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Security Assurance Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.shieldCheck, size: 14, color: muted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Protected institutional internal transfer',
                            style: theme.textTheme.labelSmall?.copyWith(color: muted, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  void _showAccountPickerModal(BuildContext context, {required bool isSource}) {
    AppHaptics.lightImpact();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final selectedLogin = isSource ? _source : _destination;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C2B68) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isSource ? 'Select Source Account' : 'Select Destination Account',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isSource
                      ? 'Funds will be transferred out of this account'
                      : 'Funds will be deposited into this account',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.45,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _accountList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final acc = _accountList[idx];
                      final isSelected = acc.login == selectedLogin;
                      final bal = _balances[acc.login] ?? 0.0;

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            AppHaptics.selectionClick();
                            Navigator.pop(sheetContext);
                            setState(() {
                              if (isSource) {
                                if (acc.login == _destination) {
                                  _destination = _source;
                                }
                                _source = acc.login;
                              } else {
                                if (acc.login == _source) {
                                  _source = _destination;
                                }
                                _destination = acc.login;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withValues(alpha: isDark ? .2 : .08)
                                  : (isDark ? const Color(0xFF071941).withValues(alpha: .5) : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : (isDark ? Colors.white.withValues(alpha: .1) : const Color(0xFFE2E8F0)),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: .12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(LucideIcons.walletCards, color: colors.primary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            acc.name,
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: colors.primary.withValues(alpha: .1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              acc.type,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: colors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Login ${acc.login} • ${acc.server ?? 'VTIndex-Live'}',
                                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatMoney(bal),
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                    Text(
                                      'Available',
                                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  isSelected ? LucideIcons.circleCheck : LucideIcons.circle,
                                  color: isSelected ? colors.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: .4),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildAccountTile({
    required BuildContext context,
    required String title,
    required String selectedLogin,
    required double balance,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;
    final acc = _accountFor(selectedLogin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: .12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Balance: ${_formatMoney(balance)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF071941).withValues(alpha: .6) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: .12) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.walletCards, color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                acc.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                acc.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${acc.server ?? "VTIndex-MT5"} • Login ${acc.login}',
                          style: TextStyle(color: muted, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatMoney(balance),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        'Available',
                        style: TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(LucideIcons.chevronRight, size: 16, color: muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: muted, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  void _showGuidelines(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0C2B68) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Icon(LucideIcons.info, color: theme.colorScheme.primary, size: 22),
            const SizedBox(width: 10),
            const Text('Transfer Guidelines', style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuidelineItem(
              'Transfer Fees',
              'Any applicable fees are calculated by the trading platform before the transfer is confirmed.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineItem(
              'Instant Settlement',
              'Transfers are submitted to the trading platform and confirmed only after the server accepts the request.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineItem(
              'Open Position Margin',
              'Make sure sufficient free margin remains on your source account if you have open floating positions.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        const SizedBox(height: 2),
        Text(desc, style: const TextStyle(fontSize: 12, height: 1.35, color: Colors.grey)),
      ],
    );
  }

  void _showConfirmationSheet() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final amount = _parsedAmount;
    final fromAcc = _accountFor(_source);
    final toAcc = _accountFor(_destination);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C2B68) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Confirm Internal Transfer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // Amount Showcase
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.primary.withValues(alpha: .2)),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        _formatMoney(amount),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                          letterSpacing: -.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Total Transfer Amount (USD)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Flow from -> to
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF071941).withValues(alpha: .6) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: .1) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.arrowUpRight, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'From: ${fromAcc.name} (${fromAcc.login})',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                          Text(
                            '-${_formatMoney(amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          color: isDark ? Colors.white.withValues(alpha: .08) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(LucideIcons.arrowDownLeft, color: Color(0xFF10B981), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'To: ${toAcc.name} (${toAcc.login})',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                          ),
                          Text(
                            '+${_formatMoney(amount)}',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _buildSummaryRow(label: 'Transfer Fee', value: 'Free (\$0.00)', valueColor: const Color(0xFF10B981), isBold: true),
                const SizedBox(height: 6),
                _buildSummaryRow(label: 'Settlement Speed', value: 'Instant (< 1 sec)', valueColor: colors.primary),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _executeTransfer(amount);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Confirm & Transfer',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
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

  Future<void> _executeTransfer(double amount) async {
    if (_isProcessing) return;
    final fromLogin = _source;
    final toLogin = _destination;

    setState(() => _isProcessing = true);
    AppHaptics.mediumImpact();

    try {
      final response = await AuthApi.instance.createInternalTransfer(
        fromAccount: fromLogin,
        toAccount: toLogin,
        amount: amount,
      );

      if (!mounted) return;

      // The server is the source of truth. Never mutate balances or show a
      // receipt unless the transfer endpoint confirms completion.
      await _loadLiveAccounts();
      if (!mounted) return;

      final transactionId = response['transaction_id'];
      final record = _InternalTransferRecord(
        id: transactionId != null ? 'TRX-$transactionId' : 'TRX-PENDING',
        sourceLogin: fromLogin,
        destinationLogin: toLogin,
        amount: amount,
        timestamp: DateTime.now(),
        status: 'Completed',
      );

      widget.onTransferCompleted?.call(fromLogin, toLogin, amount);
      unawaited(AppNotificationCenter.instance.sendNotification(
        title: 'Internal Transfer Successful (${amount.toStringAsFixed(2)})',
        body: 'Transferred ${amount.toStringAsFixed(2)} from #$fromLogin to #$toLogin. Ref: ${record.id}.',
        category: 'Funds',
        icon: LucideIcons.arrowLeftRight,
        isGold: false,
        sendToMobilePanel: true,
      ));

      _amountController.clear();
      setState(() => _isProcessing = false);
      _showSuccessReceipt(record);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      final message = error is AuthApiException
          ? error.message
          : 'The transfer could not be completed. Please try again.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 5),
          ),
        );
    }
  }

  void _showSuccessReceipt(_InternalTransferRecord record) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C2B68) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (receiptContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: .14),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF10B981), width: 2),
                    ),
                    child: const Icon(LucideIcons.check, color: Color(0xFF10B981), size: 32),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Transfer Completed',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Your transfer has been confirmed by the server',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _formatMoney(record.amount),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF071941).withValues(alpha: .6) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: .1) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow(label: 'Reference ID', value: record.id, isBold: true),
                      const SizedBox(height: 8),
                      _buildSummaryRow(label: 'From Account', value: '#${record.sourceLogin}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow(label: 'To Account', value: '#${record.destinationLogin}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow(label: 'Status', value: record.status, valueColor: const Color(0xFF10B981), isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () => Navigator.pop(receiptContext),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
