part of '../main.dart';

const _fundInk = Color(0xFF10213E);
const _fundSurface = Color(0xFFF7F9FC);
const _fundBorder = Color(0xFFE1E7F0);

class BrokerFundsPage extends StatefulWidget {
  const BrokerFundsPage({
    super.key,
    required this.withdrawal,
    required this.onBack,
    required this.onSelectPage,
  });

  final bool withdrawal;
  final VoidCallback onBack;
  final ValueChanged<String> onSelectPage;

  @override
  State<BrokerFundsPage> createState() => _BrokerFundsPageState();
}

class _BrokerFundsPageState extends State<BrokerFundsPage> {
  final TextEditingController _amount = TextEditingController();
  int _method = 0;
  int _currency = 0;
  int _payout = 0;
  final String _selectedAccount = 'Mohanprasath R - 3311 - \$0.00';
  final String _withdrawSourceAccount = '3311     STANDARD     Available:  \$0.00';

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWithdraw = widget.withdrawal;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? const Color(0xFF223656) : const Color(0xFFE2E8F1);

    return Container(
      color: scaffoldBg,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroBanner(context, isWithdraw, isDark),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: isWithdraw
                          ? _buildWithdrawForm(context, isDark, constraints)
                          : _buildDepositForm(context, isDark, constraints),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isWithdraw, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isWithdraw
              ? const [Color(0xFF0E2866), Color(0xFF1D52B8)]
              : const [Color(0xFF0F1E36), Color(0xFF16356B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isWithdraw ? const Color(0xFF2E63D9) : const Color(0xFF1E3A6E),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isWithdraw ? const Color(0xFF1D52B8) : const Color(0xFF0F1E36))
                .withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: InkWell(
                  onTap: widget.onBack,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Back to Dashboard',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.shieldCheck, color: Color(0xFF16D994), size: 12),
                    SizedBox(width: 5),
                    Text(
                      'SSL Secured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isWithdraw ? const Color(0xFF2F4FE0) : _gold,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isWithdraw ? const Color(0xFF2F4FE0) : _gold)
                          .withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  isWithdraw ? LucideIcons.arrowUpRight : LucideIcons.wallet,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWithdraw ? 'Withdraw Funds' : 'Deposit Funds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWithdraw
                          ? 'Transfer funds from your trading account'
                          : 'Add funds to your trading account securely',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.shieldCheck,
                          color: Color(0xFF16D994),
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Account: ',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 10,
                                  ),
                                ),
                                const TextSpan(
                                  text: '3311 (Live MT5)',
                                  style: TextStyle(
                                    color: Color(0xFF8DB9FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildDepositForm(BuildContext context, bool isDark, BoxConstraints constraints) {
    final isCompact = constraints.maxWidth < 440;
    final textPrimary = isDark ? Colors.white : _fundInk;
    final textMuted = isDark ? const Color(0xFF8E9EB5) : _muted;
    final badgeBg = isDark ? const Color(0xFF1E2D47) : const Color(0xFFEAF0F8);

    final currencyCard = _infoCard(
      'Deposit Currency',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _segmented(
            ['USD', 'INR'],
            _currency,
            (i) => setState(() => _currency = i),
            compact: true,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          Text(
            _currency == 0
                ? 'You will pay in US Dollars (USD)'
                : 'You will pay in Indian Rupees (INR)',
            style: TextStyle(
              color: textMuted,
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    final exchangeRateCard = _infoCard(
      'Live Exchange Rate',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1 USD = 94.29 INR',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF16D994),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Latest available rate',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 9.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _segmented(
          ['CHEESE PAY', 'MANUAL', 'USDT'],
          _method,
          (i) => setState(() => _method = i),
          isDark: isDark,
          icons: [LucideIcons.creditCard, LucideIcons.wallet, LucideIcons.coins],
        ),
        const SizedBox(height: 18),
        _fieldLabel('SELECT TRADING ACCOUNT', isDark),
        const SizedBox(height: 7),
        _accountSelect(_selectedAccount, isDark),
        const SizedBox(height: 16),
        if (_method == 0) ...[
          if (isCompact) ...[
            currencyCard,
            const SizedBox(height: 10),
            exchangeRateCard,
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: currencyCard),
                const SizedBox(width: 10),
                Expanded(child: exchangeRateCard),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _fieldLabel(
                  'DEPOSIT AMOUNT (${_currency == 0 ? 'USD' : 'INR'})',
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'YOU WILL GET (USD)',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E9EB5) : const Color(0xFF687991),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _moneyInput(
                  _currency == 0 ? '\$' : '₹',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              _valueBadge(
                '\$ ${_getEstimatedUsd()}',
                isDark: isDark,
                badgeBg: badgeBg,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [1000, 5000, 10000, 25000, 50000, 100000]
                .map((val) => _amountChip('₹ ${_formatAmount(val)}', '$val', isDark))
                .toList(),
          ),
          const SizedBox(height: 14),
          _notice(
            'Minimum deposit amount is Rs.1000',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _fundButton(
            'PAY NOW',
            onPressed: () => _submit(context, false),
          ),
        ] else if (_method == 1) ...[
          _notice(
            'INSTRUCTIONS\nContact support for verified bank details, then upload your transaction proof for review.',
            icon: LucideIcons.info,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _fieldLabel('DEPOSIT AMOUNT (INR)', isDark)),
              Text(
                'USD EQUIVALENT',
                style: TextStyle(
                  color: isDark ? const Color(0xFF8E9EB5) : const Color(0xFF687991),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(child: _moneyInput('₹', isDark: isDark)),
              const SizedBox(width: 10),
              _valueBadge('\$ ${_getEstimatedUsd()}', isDark: isDark, badgeBg: badgeBg),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              showAppMessage('Choose a transaction proof file.');
            },
            icon: const Icon(LucideIcons.cloudUpload, size: 16),
            label: const Text('Upload transaction proof (JPG, PNG or PDF)'),
            style: _outlineStyle(isDark),
          ),
          const SizedBox(height: 16),
          _fundButton(
            'SUBMIT FOR VERIFICATION',
            onPressed: () => _submit(context, false),
          ),
        ] else ...[
          _notice(
            'USDT TRC20 PROTOCOL\nEnter the amount you wish to fund. You will be securely redirected to our payment gateway.',
            icon: LucideIcons.globe,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _fieldLabel('DEPOSIT AMOUNT (USDT)', isDark),
          const SizedBox(height: 7),
          _moneyInput('\$', suffix: 'USDT', isDark: isDark),
          const SizedBox(height: 16),
          _fundButton(
            'PAY NOW',
            onPressed: () => _submit(context, false),
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: Text(
            '♢  PROTECTED',
            style: TextStyle(
              color: isDark ? const Color(0xFF687991) : const Color(0xFF53617A),
              fontSize: 8.5,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawForm(BuildContext context, bool isDark, BoxConstraints constraints) {
    final isCompact = constraints.maxWidth < 440;
    final textPrimary = isDark ? Colors.white : _fundInk;
    final badgeBg = isDark ? const Color(0xFF1E2D47) : const Color(0xFFEAF0F8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14243B) : const Color(0xFFF1F6FE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF1D3557) : const Color(0xFFD6E4FA),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16D994),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'WITHDRAWABLE TREASURY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF4B83FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _valueBadge(
                    'Active Account: 3311',
                    isDark: isDark,
                    badgeBg: badgeBg,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '\$0.00',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 28,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _stepTitle('1', 'SELECT SOURCE ACCOUNT', isDark),
        const SizedBox(height: 7),
        _accountSelect(_withdrawSourceAccount, isDark),
        const SizedBox(height: 18),
        _stepTitle('2', 'CHOOSE PAYOUT METHOD', isDark),
        const SizedBox(height: 8),
        if (isCompact) ...[
          _payoutCard(
            0,
            LucideIcons.landmark,
            'Bank Transfer',
            'ocbc bank •••• 0111',
            'Linked',
            '1–3 Business Days',
            isDark,
          ),
          const SizedBox(height: 8),
          _payoutCard(
            1,
            LucideIcons.wallet,
            'Crypto Wallet',
            'Connect your wallet',
            'Setup Needed',
            'Near-Instant (~10–30m)',
            isDark,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _payoutCard(
                  0,
                  LucideIcons.landmark,
                  'Bank Transfer',
                  'ocbc bank •••• 0111',
                  'Linked',
                  '1–3 Business Days',
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _payoutCard(
                  1,
                  LucideIcons.wallet,
                  'Crypto Wallet',
                  'Connect your wallet',
                  'Setup Needed',
                  'Near-Instant (~10–30m)',
                  isDark,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: _stepTitle('3', 'ENTER WITHDRAWAL AMOUNT', isDark)),
            const SizedBox(width: 8),
            Text(
              'Min: \$10.00',
              style: TextStyle(
                color: isDark ? const Color(0xFF8E9EB5) : _muted,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        _moneyInput('\$', suffix: 'USD', isDark: isDark),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...[50, 100, 250, 500].map((v) => _amountChip('\$$v', '$v', isDark)),
            _amountChip('MAX', '0', isDark),
          ],
        ),
        const SizedBox(height: 14),
        _infoCard(
          'Net Payout Amount',
          isDark: isDark,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Credited to your destination',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF8E9EB5) : _muted,
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                '\$${_amount.text.isEmpty ? '0.00' : _amount.text}',
                style: const TextStyle(
                  color: Color(0xFF00D7A1),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _fundButton(
          'CONFIRM WITHDRAWAL',
          onPressed: () => _submit(context, true),
        ),
      ],
    );
  }

  Widget _payoutCard(
    int index,
    IconData icon,
    String title,
    String detail,
    String status,
    String timing,
    bool isDark,
  ) {
    final selected = _payout == index;
    final accent = selected
        ? const Color(0xFF4B83FF)
        : (isDark ? const Color(0xFF2B3C58) : const Color(0xFFE2E8F1));
    final surface = isDark ? const Color(0xFF16253E) : _fundSurface;
    final textPrimary = isDark ? Colors.white : _fundInk;
    final textMuted = isDark ? const Color(0xFF8E9EB5) : _muted;

    return InkWell(
      onTap: () => setState(() => _payout = index),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? const Color(0xFF4B83FF) : accent,
            width: selected ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B83FF).withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF5990FF), size: 18),
                ),
                const Spacer(),
                Icon(
                  selected ? LucideIcons.circleCheck : LucideIcons.circle,
                  color: selected ? const Color(0xFF4B83FF) : textMuted,
                  size: 17,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textMuted, fontSize: 8.5),
            ),
            const SizedBox(height: 6),
            Text(
              '$status  •  $timing',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? const Color(0xFF16D994) : textMuted,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepTitle(String number, String title, bool isDark) => Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF3458E8),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : _fundInk,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
        ],
      );

  Widget _fieldLabel(String label, bool isDark) => Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(0xFF8E9EB5) : const Color(0xFF687991),
          fontSize: 9.5,
          letterSpacing: .55,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _accountSelect(String value, bool isDark) {
    final surface = isDark ? const Color(0xFF16253E) : _fundSurface;
    final border = isDark ? const Color(0xFF223656) : _fundBorder;
    final textPrimary = isDark ? Colors.white : _fundInk;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.users, color: Color(0xFF416FFF), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(
            LucideIcons.chevronDown,
            color: isDark ? const Color(0xFF8E9EB5) : _muted,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _segmented(
    List<String> labels,
    int selected,
    ValueChanged<int> onSelect, {
    List<IconData>? icons,
    bool compact = false,
    required bool isDark,
  }) {
    final surface = isDark ? const Color(0xFF142137) : _fundSurface;
    final border = isDark ? const Color(0xFF223656) : _fundBorder;
    final textMuted = isDark ? const Color(0xFF8E9EB5) : _muted;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  height: compact ? 32 : 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? const Color(0xFF425CC5)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icons != null) ...[
                            Icon(
                              icons[i],
                              color: i == selected ? Colors.white : textMuted,
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            labels[i],
                            style: TextStyle(
                              color: i == selected ? Colors.white : textMuted,
                              fontSize: compact ? 8.5 : 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoCard(
    String title, {
    required Widget child,
    required bool isDark,
  }) {
    final surface = isDark ? const Color(0xFF16253E) : _fundSurface;
    final border = isDark ? const Color(0xFF223656) : _fundBorder;
    final textPrimary = isDark ? Colors.white : _fundInk;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _moneyInput(
    String symbol, {
    String? suffix,
    required bool isDark,
  }) {
    final inputBg = isDark ? const Color(0xFF142137) : Colors.white;
    final border = isDark ? const Color(0xFF263750) : _fundBorder;
    final textPrimary = isDark ? Colors.white : _fundInk;
    final suffixBg = isDark ? const Color(0xFF1E2D47) : const Color(0xFFEAF0F8);

    return Container(
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(
            symbol,
            style: const TextStyle(
              color: Color(0xFF59A4FF),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Color(0xFF61718C)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (suffix != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: suffixBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                suffix,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _valueBadge(
    String value, {
    required bool isDark,
    required Color badgeBg,
    bool compact = false,
  }) {
    final textPrimary = isDark ? Colors.white : _fundInk;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 11,
        vertical: compact ? 6 : 13,
      ),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(compact ? 8 : 13),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: textPrimary,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _amountChip(String label, String value, bool isDark) {
    final surface = isDark ? const Color(0xFF16253E) : _fundSurface;
    final border = isDark ? const Color(0xFF223656) : _fundBorder;
    final textPrimary = isDark ? Colors.white : _fundInk;

    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: textPrimary,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: surface,
      side: BorderSide(color: border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () => setState(() => _amount.text = value),
    );
  }

  Widget _notice(
    String text, {
    IconData icon = LucideIcons.info,
    required bool isDark,
  }) {
    final bg = isDark ? const Color(0xFF2E2412) : const Color(0xFFFFF9E8);
    final border = isDark ? const Color(0xFF5E481D) : const Color(0xFFF1D98A);
    final fg = isDark ? const Color(0xFFFFE082) : const Color(0xFF594A26);
    final iconColor = isDark ? const Color(0xFFFFC107) : const Color(0xFFAE7B00);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontSize: 10.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _outlineStyle(bool isDark) => OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : _fundInk,
        side: BorderSide(
          color: isDark ? const Color(0xFF2E4261) : _fundBorder,
        ),
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
      );

  Widget _fundButton(String label, {required VoidCallback onPressed}) => SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          onPressed: onPressed,
          iconAlignment: IconAlignment.end,
          icon: const Icon(LucideIcons.arrowRight, size: 16),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              letterSpacing: .8,
              fontWeight: FontWeight.w900,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF345CE5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  String _getEstimatedUsd() {
    if (_amount.text.isEmpty) return '0.00';
    if (_currency == 0) return _amount.text;
    final val = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0.0;
    return (val / 94.29).toStringAsFixed(2);
  }

  void _submit(BuildContext context, bool withdrawal) {
    if (_amount.text.isEmpty ||
        (withdrawal && (double.tryParse(_amount.text) ?? 0) < 10)) {
      showAppMessage(withdrawal ? 'Enter a withdrawal amount of at least \$10.' : 'Enter an amount to continue.');
      return;
    }
    showAppMessage(withdrawal ? 'Withdrawal request is ready for review.' : 'Deposit request is ready for processing.');
  }

  String _formatAmount(int value) => value >= 100000
      ? '1,00,000'
      : value >= 1000
          ? value.toString().replaceAllMapped(
                RegExp(r'(?=(\d{3})+$)'),
                (m) => ',',
              )
          : '$value';
}

/// Backwards compatibility dialog wrapper
class FundsActionDialog extends StatelessWidget {
  const FundsActionDialog({super.key, required this.withdrawal});
  final bool withdrawal;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: BrokerFundsPage(
            withdrawal: withdrawal,
            onBack: () => Navigator.of(context).pop(),
            onSelectPage: (_) => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
