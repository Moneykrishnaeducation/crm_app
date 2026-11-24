import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_notifications.dart';
import '../services/auth_api.dart';

const _fundInk = Color(0xFF10213E);
const _fundSurface = Color(0xFFF7FAFF);
const _fundBorder = Color(0xFFDCE5F2);
const _muted = Color(0xFF71809A);
const _gold = Color(0xFFD8A82E);
const _brokerGold = Color(0xFFD8A82E);

class BrokerFundsPage extends StatefulWidget {
  const BrokerFundsPage({
    super.key,
    required this.withdrawal,
    required this.onBack,
    required this.onSelectPage,
    this.accountId,
    this.accountLabel,
    this.initialAmount,
    this.onCompleted,
  });

  final bool withdrawal;
  final VoidCallback onBack;
  final ValueChanged<String> onSelectPage;
  final String? accountId;
  final String? accountLabel;
  final double? initialAmount;
  final ValueChanged<double>? onCompleted;

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
  List<int>? _proofBytes;
  int _selectedAccountIndex = 0;
  double _usdInrRate = 94.29;
  Map<String, dynamic>? _withdrawalInfo;
  Map<String, dynamic>? _bankDetails;
  Map<String, dynamic>? _cryptoDetails;

  late List<Map<String, dynamic>> _tradingAccounts;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _amount.text = widget.initialAmount!.toStringAsFixed(2);
    }

    final accounts = <Map<String, dynamic>>[
      {
        'id': '3311',
        'label': 'Live MT5 · 3311',
        'tier': 'STANDARD',
        'available': 2560.00,
        'equity': 3740.00,
        'margin': 1180.00,
        'leverage': '1:500',
      },
      {
        'id': '3312',
        'label': 'Live MT5 · 3312',
        'tier': 'PRO ZERO',
        'available': 5820.00,
        'equity': 7100.00,
        'margin': 1280.00,
        'leverage': '1:200',
      },
      {
        'id': '3315',
        'label': 'Live MT5 · 3315',
        'tier': 'ECN RAW',
        'available': 14100.00,
        'equity': 18500.00,
        'margin': 4400.00,
        'leverage': '1:500',
      },
    ];

    if (widget.accountId != null || widget.accountLabel != null) {
      final index = accounts.indexWhere((acc) {
        if (widget.accountId != null &&
            (acc['id'] == widget.accountId ||
             acc['label'].toString().contains(widget.accountId!))) {
          return true;
        }
        if (widget.accountLabel != null &&
            acc['label'].toString().toLowerCase().contains(widget.accountLabel!.toLowerCase())) {
          return true;
        }
        return false;
      });
      if (index != -1) {
        _selectedAccountIndex = index;
      } else {
        final id = widget.accountId ?? 'Custom';
        final label = widget.accountLabel ?? 'Live MT5 · $id';
        accounts.insert(0, {
          'id': id,
          'label': label,
          'tier': 'LIVE',
          'available': 10000.00,
          'equity': 10000.00,
          'margin': 0.00,
          'leverage': '1:500',
        });
        _selectedAccountIndex = 0;
      }
    }

    _tradingAccounts = accounts;
    _loadLiveRatesAndAccounts();
  }

  Future<void> _loadLiveRatesAndAccounts() async {
    try {
      final rate = await AuthApi.instance.getUsdInrRate();
      if (mounted && rate > 0) {
        setState(() => _usdInrRate = rate);
      }
    } catch (_) {}

    try {
      final res = await AuthApi.instance.getUserTradingAccounts();
      final accList = (res['accounts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (accList.isNotEmpty && mounted) {
        final parsed = <Map<String, dynamic>>[];
        for (final item in accList) {
          final id = item['account_id']?.toString() ?? '';
          if (id.isEmpty) continue;
          final bal = (item['balance'] as num?)?.toDouble() ?? 0.0;
          final eq = (item['equity'] as num?)?.toDouble() ?? bal;
          final accountType = (item['account_type'] ?? item['accountType'] ?? item['type'] ?? item['account_category'] ?? '').toString().trim().toLowerCase();
          final accountLabel = (item['account_label'] ?? item['label'] ?? '').toString().toLowerCase();
          if (accountType.contains('demo') || accountLabel.contains('demo')) continue;
          final tier = (item['group_name'] ?? item['account_type'] ?? 'STANDARD').toString().toUpperCase();
          parsed.add({
            'id': id,
            'label': 'Live MT5 · $id',
            'tier': tier,
            'available': bal,
            'equity': eq,
            'margin': (eq - bal).abs(),
            'leverage': item['leverage'] != null ? '1:${item['leverage']}' : '1:500',
          });
        }
        if (parsed.isNotEmpty) {
          setState(() {
            _tradingAccounts = parsed;
            if (widget.accountId != null) {
              final idx = _tradingAccounts.indexWhere((a) => a['id'] == widget.accountId);
              if (idx != -1) _selectedAccountIndex = idx;
            }
          });
        }
      }
    } catch (_) {}

    if (widget.withdrawal) {
      final currentAccId = _activeTradingAccount['id']?.toString() ?? '3311';
      try {
        final info = await AuthApi.instance.getWithdrawalInfo(currentAccId);
        if (mounted) setState(() => _withdrawalInfo = info);
      } catch (_) {}
      try {
        final bank = _unwrapProfilePaymentDetails(await AuthApi.instance.getBankDetails());
        if (mounted) {
          setState(() {
            _bankDetails = bank;
            if (!_hasBankDestination && _hasCryptoDestination) _payout = 1;
          });
        }
      } catch (_) {}
      try {
        final crypto = _unwrapProfilePaymentDetails(await AuthApi.instance.getCryptoDetails());
        if (mounted) {
          setState(() {
            _cryptoDetails = crypto;
            if (!_hasBankDestination && _hasCryptoDestination) _payout = 1;
          });
        }
      } catch (_) {}
    }
  }

  Map<String, dynamic> _unwrapProfilePaymentDetails(Map<String, dynamic> response) {
    dynamic value = response;
    for (var depth = 0; depth < 4 && value is Map; depth++) {
      final map = value.cast<String, dynamic>();
      if (map['data'] is Map) { value = map['data']; continue; }
      if (map['profile'] is Map) { value = map['profile']; continue; }
      if (map['result'] is Map) { value = map['result']; continue; }
      return map;
    }
    return <String, dynamic>{};
  }

  bool get _hasBankDestination =>
      (_bankDetails?['account_number'] ?? '').toString().trim().isNotEmpty &&
      (_bankDetails?['account_number'] ?? '').toString().trim() != '—';

  bool get _hasCryptoDestination =>
      (_cryptoDetails?['wallet_address'] ?? '').toString().trim().isNotEmpty &&
      (_cryptoDetails?['wallet_address'] ?? '').toString().trim() != '—';

  String get _bankDestinationLabel {
    final number = _bankDetails?['account_number'].toString() ?? '';
    return number.length > 4 ? 'Account ending ' + number.substring(number.length - 4) : 'Saved bank account';
  }

  String get _cryptoDestinationLabel {
    final address = _cryptoDetails?['wallet_address'].toString() ?? '';
    final currency = _cryptoDetails?['currency']?.toString() ?? 'USDT';
    return address.length > 12 ? currency + ' · ' + address.substring(0, 6) + '…' + address.substring(address.length - 4) : currency + ' · Saved wallet';
  }

  Map<String, dynamic> get _activeTradingAccount =>
      _tradingAccounts[_selectedAccountIndex.clamp(0, _tradingAccounts.length - 1)];

  String get _selectedAccount {
    final acc = _activeTradingAccount;
    final avail = (acc['available'] as double);
    final formattedAvail = avail >= 1000
        ? '${(avail / 1000).floor()},${(avail % 1000).toStringAsFixed(2).padLeft(6, '0')}'
        : avail.toStringAsFixed(2);
    final userLabel = widget.accountLabel ?? 'Mohanprasath R';
    return '$userLabel - ${acc['id']} - \$$formattedAvail';
  }

  String get _withdrawSourceAccount {
    final acc = _activeTradingAccount;
    final avail = (acc['available'] as double).toStringAsFixed(2);
    return '${acc['id']}     ${acc['tier']}     Available:  \$$avail';
  }

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
              onPressed: () async {
                try {
                  final files = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                  );
                  if (files.isNotEmpty) {
                    final file = files.first;
                    final bytes = await file.readAsBytes();
                    setState(() {
                      _uploadedProofName = file.name;
                      _proofBytes = bytes;
                    });
                    showAppMessage('Attached transaction proof: ${file.name}');
                    return;
                  }
                } catch (_) {}
                setState(() {
                  _uploadedProofName = 'bank_transfer_receipt_3311.pdf';
                  _proofBytes = [1, 2, 3, 4];
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
    final acc = _activeTradingAccount;
    final avail = acc['available'] as double;
    final equity = acc['equity'] as double;
    final margin = acc['margin'] as double;
    final accountId = acc['id'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Treasury Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14243B) : const Color(0xFFF1F6FE),
            borderRadius: BorderRadius.circular(16),
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
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6610B981),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'WITHDRAWABLE TREASURY',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF4B83FF),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _valueBadge(
                    'Active Account: $accountId',
                    isDark: isDark,
                    badgeBg: badgeBg,
                    compact: true,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '\$${avail.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 30,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'AVAILABLE NOW',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1B2E) : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1D3252) : const Color(0xFFDEE9F7),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _subMetric('Equity', '\$${equity.toStringAsFixed(2)}', isDark)),
                    _metricDivider(isDark),
                    Expanded(child: _subMetric('Margin Used', '\$${margin.toStringAsFixed(2)}', isDark)),
                    _metricDivider(isDark),
                    Expanded(child: _subMetric('Free Margin', '\$${avail.toStringAsFixed(2)}', isDark, isHighlight: true)),
                  ],
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
        if (!_hasBankDestination && !_hasCryptoDestination)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2B2418) : const Color(0xFFFFF8E8),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: isDark ? const Color(0xFF594625) : const Color(0xFFEEDBAA)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(LucideIcons.info, color: Color(0xFFC18B20), size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Add a bank account or crypto wallet in Profile → Payment Methods before requesting a withdrawal.', style: TextStyle(color: isDark ? const Color(0xFFF2D99A) : const Color(0xFF765719), fontSize: 12, height: 1.4))),
            ]),
          )
        else
          LayoutBuilder(builder: (context, methodConstraints) {
            final cards = <Widget>[
              if (_hasBankDestination) _payoutCard(0, LucideIcons.landmark, 'Bank Transfer', _bankDestinationLabel, (_bankDetails?['status'] ?? 'Saved').toString(), '1–3 Business Days', isDark),
              if (_hasCryptoDestination) _payoutCard(1, LucideIcons.wallet, 'Crypto Wallet', _cryptoDestinationLabel, (_cryptoDetails?['status'] ?? 'Saved').toString(), 'Near-Instant (~10–30m)', isDark),
            ];
            if (methodConstraints.maxWidth < 440 || cards.length == 1) {
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < cards.length; i++) ...[cards[i], if (i != cards.length - 1) const SizedBox(height: 8)],
              ]);
            }
            return Row(children: [
              for (var i = 0; i < cards.length; i++) ...[Expanded(child: cards[i]), if (i != cards.length - 1) const SizedBox(width: 10)],
            ]);
          }),
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
        _buildSecurityBadges(isDark),
        const SizedBox(height: 18),
        _fundButton(
          'CONFIRM WITHDRAWAL',
          onPressed: (!_hasBankDestination && !_hasCryptoDestination) ? null : () => _submit(true),
        ),
      ],
    );
  }

  Widget _subMetric(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isHighlight
                ? const Color(0xFF10B981)
                : (isDark ? Colors.white : _fundInk),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _metricDivider(bool isDark) {
    return Container(
      width: 1,
      height: 20,
      color: isDark ? const Color(0xFF22385C) : const Color(0xFFDEE7F4),
    );
  }

  Widget _buildSecurityBadges(bool isDark) {
    final border = isDark ? const Color(0xFF1D3557) : const Color(0xFFE2E8F0);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A2D) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _securityItem(LucideIcons.shieldCheck, '256-Bit SSL', muted),
          _securityItem(LucideIcons.landmark, 'Tier-1 Custody', muted),
          _securityItem(LucideIcons.lock, 'AML Regulated', muted),
        ],
      ),
    );
  }

  Widget _securityItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF2563EB)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
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
    final acc = _activeTradingAccount;

    return InkWell(
      onTap: () => _showAccountSelectorSheet(context, isDark),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
                        acc['label'] as String,
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
                        child: Text(
                          acc['tier'] as String,
                          style: const TextStyle(
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
      ),
    );
  }

  void _showAccountSelectorSheet(BuildContext context, bool isDark) {
    final sheetBg = isDark ? const Color(0xFF0F1E38) : Colors.white;
    final border = isDark ? const Color(0xFF1E355B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : _fundInk;
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: border),
        ),
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          18 + MediaQuery.viewPaddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Select Trading Account',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(LucideIcons.x, size: 18),
                  tooltip: 'Close',
                  color: muted,
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _tradingAccounts.length; i++) ...[
              _buildAccountOptionTile(i, isDark, () {
                setState(() => _selectedAccountIndex = i);
                Navigator.pop(ctx);
              }),
              if (i < _tradingAccounts.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOptionTile(int index, bool isDark, VoidCallback onSelect) {
    final selected = _selectedAccountIndex == index;
    final item = _tradingAccounts[index];
    final surface = selected
        ? (isDark ? const Color(0xFF193259) : const Color(0xFFEAF2FF))
        : (isDark ? const Color(0xFF13223A) : const Color(0xFFF8FAFC));
    final border = selected
        ? const Color(0xFF2563EB)
        : (isDark ? const Color(0xFF223656) : const Color(0xFFE2E8F0));
    final textPrimary = isDark ? Colors.white : _fundInk;
    final avail = (item['available'] as double).toStringAsFixed(2);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: selected ? 1.4 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (selected ? const Color(0xFF2563EB) : const Color(0xFF64748B)).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.wallet,
                size: 16,
                color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['tier'] as String,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Withdrawable: \$$avail USD  •  Leverage ${item['leverage']}',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
              size: 18,
            ),
          ],
        ),
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
    final rate = _usdInrRate > 0 ? _usdInrRate : 94.29;
    return (val / rate).toStringAsFixed(2);
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
      if ((_payout == 0 && !_hasBankDestination) || (_payout == 1 && !_hasCryptoDestination)) {
        showAppMessage('Select a saved payout method from Profile → Payment Methods.');
        return;
      }
      final available = _activeTradingAccount['available'] as double;
      if (parsedAmount > available) {
        showAppMessage(
          'Amount exceeds available withdrawable balance of \$${available.toStringAsFixed(2)}.',
        );
        return;
      }
      _showWithdrawConfirmationSheet(context, parsedAmount);
      return;
    }

    setState(() => _isSubmitting = true);

    final amountStr = parsedAmount.toStringAsFixed(2);
    final currencyStr = _method == 2 ? 'USDT' : (_currency == 0 ? 'USD' : 'INR');
    final estimatedUsd = _getEstimatedUsd();
    final methodName = switch (_method) {
      0 => 'Cheese Pay (Instant UPI / Cards)',
      1 => 'Manual Bank Wire',
      _ => 'USDT (TRC20 Crypto)',
    };
    final accId = _activeTradingAccount['id']?.toString() ?? '';
    String refId = 'VTX-DEP-${100000 + DateTime.now().millisecondsSinceEpoch % 900000}';
    String? redirectUrl;

    try {
      if (_method == 0) {
        final rate = _usdInrRate > 0 ? _usdInrRate : 83.5;
        final amountUsd = _currency == 1 ? parsedAmount / rate : parsedAmount;
        final amountInr = _currency == 0 ? parsedAmount * rate : parsedAmount;
        final res = await AuthApi.instance.initiateCheesePay(
          accountId: accId,
          amountUsd: amountUsd,
          amountInr: amountInr,
        );
        if (res['payment_url'] != null) {
          redirectUrl = res['payment_url'].toString();
        }
        if (res['transaction_id'] != null) {
          refId = 'VTX-DEP-${res['transaction_id']}';
        }
      } else if (_method == 1) {
        final rate = _usdInrRate > 0 ? _usdInrRate : 83.5;
        final amountUsd = _currency == 1 ? parsedAmount / rate : parsedAmount;
        final res = await AuthApi.instance.submitManualDeposit(
          accountId: accId,
          amountUsd: amountUsd,
          proofBytes: _proofBytes ?? [0],
          proofFileName: _uploadedProofName ?? 'proof.jpg',
        );
        if (res['transaction_id'] != null) {
          refId = 'VTX-DEP-${res['transaction_id']}';
        }
      } else {
        final res = await AuthApi.instance.initiateUsdtDeposit(
          accountId: accId,
          amountUsd: parsedAmount,
        );
        if (res['checkout_url'] != null) {
          redirectUrl = res['checkout_url'].toString();
        }
        if (res['transaction_id'] != null) {
          refId = 'VTX-DEP-${res['transaction_id']}';
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    unawaited(AppNotificationCenter.instance.sendNotification(
      title: 'Deposit Request Submitted',
      body: '$currencyStr $amountStr ($methodName) submitted for processing. Ref: $refId.',
      category: 'Funds',
      icon: LucideIcons.wallet,
      isGold: true,
      sendToMobilePanel: true,
    ));

    if (widget.onCompleted != null) {
      widget.onCompleted!(parsedAmount);
    }

    if (redirectUrl != null && redirectUrl.isNotEmpty) {
      unawaited(launchUrl(Uri.parse(redirectUrl), mode: LaunchMode.externalApplication));
    }

    _showDepositResponseModal(
      context,
      refId: refId,
      amount: amountStr,
      currency: currencyStr,
      estimatedUsd: estimatedUsd,
      method: methodName,
    );

    showAppMessage('Deposit request submitted successfully.');
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

  void _showWithdrawConfirmationSheet(BuildContext context, double amount) {
    final acc = _activeTradingAccount;
    final methodName = _payout == 0 ? 'Bank Transfer' : 'Crypto Wallet (USDT)';
    final fee = (_withdrawalInfo?['withdrawal_fee'] as num?)?.toDouble() ?? 0.0;
    final settlementTime =
        _payout == 0 ? '1–3 Business Days' : 'Near-Instant (~10–30m)';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => _WithdrawConfirmationSheet(
        amount: amount,
        accountName: acc['label'] as String,
        accountTier: acc['tier'] as String,
        methodName: fee > 0 ? '$methodName (Fee: \$$fee)' : methodName,
        settlementTime: settlementTime,
        onConfirm: () async {
          Navigator.pop(ctx);
          final accId = acc['id']?.toString() ?? '3311';
          final methodStr = _payout == 0 ? 'bank' : 'crypto';
          String refId =
              'VTX-WTH-${100000 + DateTime.now().millisecondsSinceEpoch % 900000}';

          try {
            final res = await AuthApi.instance.requestWithdrawal(
              accountId: accId,
              amount: amount,
              method: methodStr,
              description: 'Withdrawal via $methodName',
            );
            if (res['transaction_id'] != null) {
              refId = 'VTX-WTH-${res['transaction_id']}';
            }
          } catch (_) {}

          final amtStr = amount.toStringAsFixed(2);

          if (widget.onCompleted != null) {
            widget.onCompleted!(amount);
          }

          unawaited(AppNotificationCenter.instance.sendNotification(
            title: 'Withdrawal Request Submitted',
            body:
                'Withdrawal of \$$amtStr USD from ${acc['label']} submitted. Ref: $refId.',
            category: 'Funds',
            icon: LucideIcons.arrowUpRight,
            isGold: true,
            sendToMobilePanel: true,
          ));

          if (!mounted) return;
          _showWithdrawReceiptModal(
            this.context,
            refId: refId,
            amount: amtStr,
            accountLabel: acc['label'] as String,
            method: methodName,
            settlementTime: settlementTime,
          );
        },
      ),
    );
  }

  void _showWithdrawReceiptModal(
    BuildContext context, {
    required String refId,
    required String amount,
    required String accountLabel,
    required String method,
    required String settlementTime,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => _WithdrawReceiptSheet(
        refId: refId,
        amount: amount,
        accountLabel: accountLabel,
        method: method,
        settlementTime: settlementTime,
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
            'This is a local deposit preview. No payment or deposit request has been sent.',
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

class _WithdrawConfirmationSheet extends StatelessWidget {
  const _WithdrawConfirmationSheet({
    required this.amount,
    required this.accountName,
    required this.accountTier,
    required this.methodName,
    required this.settlementTime,
    required this.onConfirm,
  });

  final double amount;
  final String accountName;
  final String accountTier;
  final String methodName;
  final String settlementTime;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF0F1E38) : Colors.white;
    final cardBg = isDark ? const Color(0xFF152A4E) : const Color(0xFFF8FAFC);
    final border = isDark ? const Color(0xFF1E355B) : const Color(0xFFE2E8F0);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textPrimary = isDark ? Colors.white : _fundInk;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Review Withdrawal Request',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.x, size: 18),
                color: muted,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: Column(
              children: [
                Text(
                  'Withdrawal Amount',
                  style: TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${amount.toStringAsFixed(2)} USD',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                _detailRow('Source Account', '$accountName ($accountTier)', isDark, muted, textPrimary),
                const SizedBox(height: 10),
                _detailRow('Payout Method', methodName, isDark, muted, textPrimary),
                const SizedBox(height: 10),
                _detailRow('Broker Processing Fee', 'Free (\$0.00)', isDark, muted, const Color(0xFF10B981)),
                const SizedBox(height: 10),
                _detailRow('Estimated Settlement', settlementTime, isDark, muted, textPrimary),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Segregated Tier-1 Bank custody with instant AML risk clearance.',
                    style: TextStyle(
                      color: isDark ? const Color(0xFFB0C8ED) : const Color(0xFF1E40AF),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(LucideIcons.check, size: 17),
              label: const Text(
                'Authorize & Submit Request',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1658C9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark, Color muted, Color valColor) {
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: valColor, fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _WithdrawReceiptSheet extends StatelessWidget {
  const _WithdrawReceiptSheet({
    required this.refId,
    required this.amount,
    required this.accountLabel,
    required this.method,
    required this.settlementTime,
    required this.onViewActivity,
    required this.onBackToDashboard,
  });

  final String refId;
  final String amount;
  final String accountLabel;
  final String method;
  final String settlementTime;
  final VoidCallback onViewActivity;
  final VoidCallback onBackToDashboard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF0F1E38) : Colors.white;
    final border = isDark ? const Color(0xFF1E355B) : const Color(0xFFE2E8F0);
    final cardBg = isDark ? const Color(0xFF152A4E) : const Color(0xFFF8FAFC);
    final muted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final textPrimary = isDark ? Colors.white : _fundInk;

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
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF10B981), width: 2),
            ),
            child: const Icon(LucideIcons.checkCheck, color: Color(0xFF10B981), size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            'Withdrawal Request Submitted',
            style: TextStyle(
              color: textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'VTIndex Treasury is processing your payout request.',
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
                _receiptRow('Requested Amount', '\$$amount USD', isDark, isHighlight: true),
                const SizedBox(height: 10),
                _receiptRow('Source Account', accountLabel, isDark),
                const SizedBox(height: 10),
                _receiptRow('Payout Method', method, isDark),
                const SizedBox(height: 10),
                _receiptRow('Estimated Settlement', settlementTime, isDark),
                const SizedBox(height: 10),
                _receiptRow('Status', 'Processing', isDark, isStatus: true),
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
                foregroundColor: textPrimary,
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

  Widget _receiptRow(String label, String value, bool isDark, {bool isHighlight = false, bool isStatus = false}) {
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
                color: isHighlight
                    ? const Color(0xFF10B981)
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
  const FundsActionDialog({
    super.key,
    required this.withdrawal,
    this.accountId,
    this.accountLabel,
    this.initialAmount,
    this.onCompleted,
  });

  final bool withdrawal;
  final String? accountId;
  final String? accountLabel;
  final double? initialAmount;
  final ValueChanged<double>? onCompleted;

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
            accountId: accountId,
            accountLabel: accountLabel,
            initialAmount: initialAmount,
            onCompleted: onCompleted,
            onBack: () => Navigator.of(context).pop(),
            onSelectPage: (_) => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

Future<void> showFundsActionDialog(
  BuildContext context, {
  required bool withdrawal,
  String? accountId,
  String? accountLabel,
  double? initialAmount,
  ValueChanged<double>? onCompleted,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => FundsActionDialog(
      withdrawal: withdrawal,
      accountId: accountId,
      accountLabel: accountLabel,
      initialAmount: initialAmount,
      onCompleted: onCompleted,
    ),
  );
}
