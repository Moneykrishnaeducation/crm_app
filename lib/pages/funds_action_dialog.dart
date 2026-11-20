part of '../main.dart';

const _fundInk = Color(0xFF10213E);
const _fundSurface = Color(0xFFF7FAFF);
const _fundBorder = Color(0xFFDCE5F2);

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
  bool _isSubmitting = false;
  String? _uploadedProofName;
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
    if (!isWithdraw) return _buildDepositPage(context, isDark);

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
                      child: _buildWithdrawForm(context, isDark, constraints),
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

  Widget _buildDepositPage(BuildContext context, bool isDark) {
    final page = isDark ? const Color(0xFF08152A) : const Color(0xFFF4F7FC);
    final panel = isDark ? const Color(0xFF10213E) : Colors.white;
    final border = isDark ? const Color(0xFF29436D) : const Color(0xFFDCE5F2);
    final muted = isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987);
    return Container(
      color: page,
      child: LayoutBuilder(builder: (context, viewport) {
        final compact = viewport.maxWidth < 760;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 20, compact ? 16 : 28, 110),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: widget.onBack,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.arrowLeft, size: 16, color: isDark ? Colors.white : _fundInk),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Back to Dashboard',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : _fundInk,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _secureBadge(isDark, label: 'SSL Secured'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF1A3154) : const Color(0xFFFFF3D2), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(LucideIcons.wallet, color: Color(0xFFC99A2E), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Deposit Funds', style: TextStyle(color: isDark ? Colors.white : _fundInk, fontSize: compact ? 24 : 30, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                    const SizedBox(height: 4),
                    Text('Add funds to your trading account securely.', style: TextStyle(color: muted, fontSize: 13)),
                  ])),
                ]),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, content) {
                  return _depositFormPanel(context, isDark, panel, border, content.maxWidth);
                }),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Widget _secureBadge(bool isDark, {String label = 'Secure checkout'}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF172B49) : const Color(0xFFFFF3D2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? const Color(0xFF3C5680) : const Color(0xFFEAD18F)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.shieldCheck, color: Color(0xFFC99A2E), size: 13),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: isDark ? const Color(0xFFF1CF78) : const Color(0xFF785912), fontSize: 10, fontWeight: FontWeight.w800)),
        ]),
      );

  Widget _depositFormPanel(BuildContext context, bool isDark, Color panel, Color border, double width) => Container(
        padding: EdgeInsets.all(width < 440 ? 16 : 24),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? .16 : .035), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: _buildDepositForm(context, isDark, BoxConstraints(maxWidth: width - (width < 440 ? 32 : 48))),
      );

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
    final textMuted = isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987);
    final badgeBg = isDark ? const Color(0xFF1D3557) : const Color(0xFFEAF0FF);

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
            selectedColor: const Color(0xFF153467),
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
                  color: Color(0xFFC99A2E),
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
        _depositSectionHeading('01', 'Payment method', isDark),
        const SizedBox(height: 10),
        _depositMethodPicker(isDark),
        const SizedBox(height: 18),
        _depositSectionHeading('02', 'Trading account', isDark),
        const SizedBox(height: 10),
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
          _depositSectionHeading('03', 'Deposit amount', isDark),
          const SizedBox(height: 10),
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
        color: isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987),
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
            onPressed: () => _submit(false),
            isLoading: _isSubmitting,
          ),
        ] else if (_method == 1) ...[
          _depositSectionHeading('03', 'Deposit amount', isDark),
          const SizedBox(height: 10),
          _notice(
            'INSTRUCTIONS\nContact support for verified bank details, then upload your transaction proof for review.',
            icon: LucideIcons.info,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildManualBankDetails(isDark),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _fieldLabel('DEPOSIT AMOUNT (INR)', isDark)),
              Text(
                'USD EQUIVALENT',
                style: TextStyle(
                  color: isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987),
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
          if (_uploadedProofName == null) ...[
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _uploadedProofName = 'bank_transfer_receipt_3311.pdf';
                });
                showAppMessage('Attached transaction proof: bank_transfer_receipt_3311.pdf (1.4 MB)');
              },
              icon: const Icon(LucideIcons.cloudUpload, size: 16),
              label: const Text('Upload transaction proof (JPG, PNG or PDF)'),
              style: _outlineStyle(isDark),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF142744) : const Color(0xFFF1F6FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF28487A) : const Color(0xFFC7DBF8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1658C9).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.fileText, size: 16, color: Color(0xFF1658C9)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _uploadedProofName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : _fundInk,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '1.4 MB · Ready for review',
                          style: TextStyle(
                            color: Color(0xFF16D994),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 16),
                    color: isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987),
                    tooltip: 'Remove',
                    onPressed: () => setState(() => _uploadedProofName = null),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _fundButton(
            'SUBMIT FOR VERIFICATION',
            onPressed: () => _submit(false),
            isLoading: _isSubmitting,
          ),
        ] else ...[
          _depositSectionHeading('03', 'Deposit amount', isDark),
          const SizedBox(height: 10),
          _notice(
            'USDT TRC20 PROTOCOL\nEnter the amount you wish to fund. You will be securely redirected to our payment gateway.',
            icon: LucideIcons.globe,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildUsdtWalletBox(isDark),
          const SizedBox(height: 14),
          _fieldLabel('DEPOSIT AMOUNT (USDT)', isDark),
          const SizedBox(height: 7),
          _moneyInput('\$', suffix: 'USDT', isDark: isDark),
          const SizedBox(height: 16),
          _fundButton(
            'PAY NOW',
            onPressed: () => _submit(false),
            isLoading: _isSubmitting,
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: Text(
            '♢  PROTECTED',
            style: TextStyle(
              color: isDark ? const Color(0xFFF1CF78) : const Color(0xFF9A741F),
              fontSize: 8.5,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _depositMethodPicker(bool isDark) {
    const items = [
      (label: 'CHEESE PAY', sub: 'Instant UPI / Cards', badge: '0% FEE', icon: LucideIcons.creditCard),
      (label: 'MANUAL', sub: 'Bank Wire / IMPS', badge: 'VERIFIED', icon: LucideIcons.landmark),
      (label: 'USDT', sub: 'TRC20 / ERC20', badge: 'INSTANT', icon: LucideIcons.coins),
    ];
    final muted = isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987);
    return Row(children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(child: InkWell(
          onTap: () => setState(() => _method = i),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: _method == i
                  ? (isDark ? const Color(0xFF193258) : const Color(0xFFFFF7E6))
                  : (isDark ? const Color(0xFF12223F) : const Color(0xFFF8FAFE)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _method == i ? const Color(0xFFD8A82E) : (isDark ? const Color(0xFF243B5E) : const Color(0xFFDCE5F2)),
                width: _method == i ? 1.6 : 1,
              ),
              boxShadow: _method == i
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD8A82E).withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(items[i].icon, size: 18, color: _method == i ? const Color(0xFFD8A82E) : muted),
              const SizedBox(height: 5),
              Text(items[i].label, maxLines: 1, style: TextStyle(
                color: _method == i ? (isDark ? const Color(0xFFF1CF78) : const Color(0xFF785912)) : (isDark ? Colors.white : _fundInk),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .25,
              )),
              const SizedBox(height: 2),
              Text(items[i].badge, maxLines: 1, style: TextStyle(
                color: _method == i ? const Color(0xFFD8A82E) : muted,
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
              )),
            ]),
          ),
        )),
      ],
    ]);
  }

  Widget _buildManualBankDetails(bool isDark) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13223A) : const Color(0xFFF7FAFE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF243B5E) : const Color(0xFFDEE7F4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(LucideIcons.shieldCheck, size: 14, color: Color(0xFFD8A82E)),
                SizedBox(width: 6),
                Text(
                  'OFFICIAL BENEFICIARY ACCOUNT',
                  style: TextStyle(
                    color: Color(0xFFD8A82E),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _copyableDetailRow('Beneficiary', 'VT Index Markets Ltd', isDark),
            const SizedBox(height: 6),
            _copyableDetailRow('Bank Name', 'HDFC Bank Ltd', isDark),
            const SizedBox(height: 6),
            _copyableDetailRow('Account No.', '5020 0084 9201 33', isDark),
            const SizedBox(height: 6),
            _copyableDetailRow('IFSC Code', 'HDFC0001048', isDark),
          ],
        ),
      );

  Widget _copyableDetailRow(String label, String value, bool isDark) => Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : _fundInk,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              showAppMessage('Copied $value to clipboard.');
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                LucideIcons.copy,
                size: 13,
                color: isDark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9),
              ),
            ),
          ),
        ],
      );

  Widget _buildUsdtWalletBox(bool isDark) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13223A) : const Color(0xFFF7FAFE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF243B5E) : const Color(0xFFDEE7F4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(LucideIcons.coins, size: 14, color: Color(0xFFD8A82E)),
                SizedBox(width: 6),
                Text(
                  'OFFICIAL TRC20 DEPOSIT ADDRESS',
                  style: TextStyle(
                    color: Color(0xFFD8A82E),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1658C9).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.qrCode, size: 16, color: Color(0xFF1658C9)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TX8nQ9xR4bH2mP7vW1kL3s9zY6V4m2Pq',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Network: TRON (TRC20) · Instant Auto-Credit',
                        style: TextStyle(
                          color: Color(0xFF16D994),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.copy, size: 14),
                  color: const Color(0xFF1658C9),
                  tooltip: 'Copy address',
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: 'TX8nQ9xR4bH2mP7vW1kL3s9zY6V4m2Pq'));
                    showAppMessage('Copied TRC20 address to clipboard.');
                  },
                ),
              ],
            ),
          ],
        ),
      );

  Widget _depositSectionHeading(String number, String title, bool isDark) => Row(children: [
        Container(
          width: 25,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A3154) : const Color(0xFFEAF0FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(number, style: const TextStyle(color: Color(0xFFC99A2E), fontSize: 10, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 9),
        Text(title, style: TextStyle(color: isDark ? Colors.white : _fundInk, fontSize: 14, fontWeight: FontWeight.w800)),
      ]);

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
                      color: Color(0xFFC99A2E),
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
                color: isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987),
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
        const SizedBox(height: 18),
        _fundButton(
          'CONFIRM WITHDRAWAL',
          onPressed: () => _submit(true),
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
        ? const Color(0xFFD3A638)
        : (isDark ? const Color(0xFF29436D) : const Color(0xFFDCE5F2));
    final surface = isDark ? const Color(0xFF142744) : _fundSurface;
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
            color: selected ? const Color(0xFFD3A638) : accent,
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
                    color: const Color(0xFF416FFF).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF416FFF), size: 18),
                ),
                const Spacer(),
                Icon(
                  selected ? LucideIcons.circleCheck : LucideIcons.circle,
                  color: selected ? const Color(0xFFC99A2E) : textMuted,
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
                color: selected ? (isDark ? const Color(0xFFF1CF78) : const Color(0xFF785912)) : textMuted,
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
              color: const Color(0xFF153467),
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
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : _fundInk,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: .3,
              ),
            ),
          ),
        ],
      );

  Widget _fieldLabel(String label, bool isDark) => Text(
        label,
        style: TextStyle(
          color: isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987),
          fontSize: 9.5,
          letterSpacing: .55,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _accountSelect(String value, bool isDark) {
    final surface = isDark ? const Color(0xFF13223A) : const Color(0xFFF7FAFE);
    final border = isDark ? const Color(0xFF243B5E) : const Color(0xFFDEE7F4);
    final textPrimary = isDark ? Colors.white : _fundInk;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1658C9).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(LucideIcons.wallet, color: Color(0xFF1658C9), size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    Text(
                      'Live MT5 · 3311',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1658C9).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'STANDARD',
                        style: TextStyle(
                          color: Color(0xFF1658C9),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
    Color selectedColor = const Color(0xFF425CC5),
  }) {
    final surface = isDark ? const Color(0xFF142137) : _fundSurface;
    final border = isDark ? const Color(0xFF223656) : _fundBorder;
    final textMuted = isDark ? const Color(0xFFB9C8DF) : const Color(0xFF536987);

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
                        ? selectedColor
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

  Widget _fundButton(
    String label, {
    required VoidCallback onPressed,
    bool isLoading = false,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1658C9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'PROCESSING...',
                      style: TextStyle(
                        fontSize: 11.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12.5,
                        letterSpacing: .8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.arrowRight, size: 16),
                  ],
                ),
        ),
      );

  String _getEstimatedUsd() {
    if (_amount.text.isEmpty) return '0.00';
    if (_currency == 0 && _method != 1) return _amount.text;
    final val = double.tryParse(_amount.text.replaceAll(',', '')) ?? 0.0;
    return (val / 94.29).toStringAsFixed(2);
  }

  void _submit(bool withdrawal) async {
    if (_isSubmitting) return;

    final normalizedAmount = _amount.text.trim().replaceAll(',', '');
    final parsedAmount = double.tryParse(normalizedAmount);
    if (parsedAmount == null || !parsedAmount.isFinite || parsedAmount <= 0) {
      showAppMessage('Enter a valid amount greater than zero.');
      return;
    }
    if (withdrawal && parsedAmount < 10) {
      showAppMessage('Enter a withdrawal amount of at least \$10.');
      return;
    }

    if (withdrawal) {
      final amt = parsedAmount.toStringAsFixed(2);
      unawaited(AppNotificationCenter.instance.sendNotification(
        title: 'Withdrawal Draft Created',
        body: 'A withdrawal draft for \$amt USD from MT5 #3311 is ready for review. No withdrawal has been submitted.',
        category: 'Funds',
        icon: LucideIcons.arrowUpRight,
        isGold: false,
        sendToMobilePanel: true,
      ));
      showAppMessage('Withdrawal details are ready for review. No request was submitted.');
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final amountStr = parsedAmount.toStringAsFixed(2);
    final currencyStr = _method == 2 ? 'USDT' : (_currency == 0 ? 'USD' : 'INR');
    final estimatedUsd = _getEstimatedUsd();
    final methodName = switch (_method) {
      0 => 'Cheese Pay (Instant UPI / Cards)',
      1 => 'Manual Bank Wire',
      _ => 'USDT (TRC20 Crypto)',
    };
    final refId = 'VTX-DEP-${100000 + DateTime.now().millisecondsSinceEpoch % 900000}';

    unawaited(AppNotificationCenter.instance.sendNotification(
      title: 'Deposit Request Preview Created',
      body: '$currencyStr $amountStr ($methodName) prepared locally. Ref: $refId. No payment or deposit request was sent.',
      category: 'Funds',
      icon: LucideIcons.wallet,
      isGold: true,
      sendToMobilePanel: true,
    ));

    _showDepositResponseModal(
      context,
      refId: refId,
      amount: amountStr,
      currency: currencyStr,
      estimatedUsd: estimatedUsd,
      method: methodName,
    );

    showAppMessage('Deposit details prepared locally. No payment was initiated.');
  }

  void _showDepositResponseModal(
    BuildContext context, {
    required String refId,
    required String amount,
    required String currency,
    required String estimatedUsd,
    required String method,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => _DepositResponseSheet(
        refId: refId,
        amount: amount,
        currency: currency,
        estimatedUsd: estimatedUsd,
        method: method,
        onViewActivity: () {
          Navigator.pop(ctx);
          widget.onSelectPage('activity');
        },
        onBackToDashboard: () {
          Navigator.pop(ctx);
          widget.onBack();
        },
      ),
    );
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

class _DepositResponseSheet extends StatelessWidget {
  const _DepositResponseSheet({
    required this.refId,
    required this.amount,
    required this.currency,
    required this.estimatedUsd,
    required this.method,
    required this.onViewActivity,
    required this.onBackToDashboard,
  });

  final String refId;
  final String amount;
  final String currency;
  final String estimatedUsd;
  final String method;
  final VoidCallback onViewActivity;
  final VoidCallback onBackToDashboard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF0F1E38) : Colors.white;
    final border = isDark ? const Color(0xFF1E355B) : const Color(0xFFE2E8F0);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF152A4E) : const Color(0xFFF8FAFC);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: border),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: muted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _brokerGold.withValues(alpha: 0.15),
              border: Border.all(color: _brokerGold, width: 2),
            ),
            child: const Icon(LucideIcons.checkCheck, color: _brokerGold, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Deposit Request Initiated',
            style: TextStyle(
              color: isDark ? Colors.white : _fundInk,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your deposit request has been submitted for processing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ref: $refId',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: refId));
                    showAppMessage('Copied reference ID $refId');
                  },
                  child: Icon(
                    LucideIcons.copy,
                    size: 13,
                    color: isDark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                _row('Amount to Deposit', '$currency $amount', isDark),
                const SizedBox(height: 10),
                _row('Estimated Credit', '\$$estimatedUsd USD', isDark, isGold: true),
                const SizedBox(height: 10),
                _row('Destination', 'Live MT5 · 3311', isDark),
                const SizedBox(height: 10),
                _row('Payment Method', method, isDark),
                const SizedBox(height: 10),
                _row('Status', 'Processing Gateway', isDark, isStatus: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              onPressed: onViewActivity,
              icon: const Icon(LucideIcons.activity, size: 16),
              label: const Text(
                'View in Activity & Orders',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1658C9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: onBackToDashboard,
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : _fundInk,
                side: BorderSide(color: border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, bool isDark, {bool isGold = false, bool isStatus = false}) {
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: const Color(0xFF1658C9).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1658C9),
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'Processing',
                  style: TextStyle(
                    color: Color(0xFF1658C9),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          )
        else
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isGold
                    ? _brokerGold
                    : (isDark ? Colors.white : _fundInk),
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
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
