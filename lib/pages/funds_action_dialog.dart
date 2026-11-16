part of '../main.dart';

class FundsActionDialog extends StatefulWidget {
  const FundsActionDialog({super.key, required this.withdrawal});
  final bool withdrawal;

  @override
  State<FundsActionDialog> createState() => _FundsActionDialogState();
}

class _FundsActionDialogState extends State<FundsActionDialog> {
  final _amount = TextEditingController();
  int _method = 0;
  int _currency = 0;
  int _payout = 0;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWithdraw = widget.withdrawal;
    final mediaQuery = MediaQuery.of(context);
    final compact = mediaQuery.size.width < 500;
    final availableHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: compact ? 12 : 28, vertical: 18),
      backgroundColor: const Color(0xFF091328),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFF23334E))),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 540, maxHeight: (availableHeight - 36).clamp(0.0, double.infinity).toDouble()),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _fundHeader(context, isWithdraw),
          Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 14, 16, 12), child: isWithdraw ? _withdrawForm() : _depositForm())),
          if (isWithdraw) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: _fundButton('CONFIRM WITHDRAWAL', onPressed: () => _submit(context, true))),
        ]),
      ),
    );
  }

  Widget _fundHeader(BuildContext context, bool withdrawal) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: withdrawal ? const [Color(0xFF132C70), Color(0xFF16498C)] : const [Color(0xFF101A34), Color(0xFF0A1327)]),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
      border: const Border(bottom: BorderSide(color: Color(0xFF1C2A43))),
    ),
    child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: withdrawal ? const Color(0xFF2F4FE0) : _gold, borderRadius: BorderRadius.circular(15)), child: Icon(withdrawal ? LucideIcons.arrowUpRight : LucideIcons.wallet, color: Colors.white, size: 24)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(withdrawal ? 'Withdraw Funds' : 'Deposit Funds', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: 3),
        Text(withdrawal ? 'Transfer funds from your trading account' : 'Add funds to your trading account securely', style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        const Row(children: [Icon(LucideIcons.shieldCheck, color: Color(0xFF16D994), size: 11), SizedBox(width: 4), Text('Account: ', style: TextStyle(color: _muted, fontSize: 9)), Text('3311', style: TextStyle(color: Color(0xFF73A4FF), fontSize: 9, fontWeight: FontWeight.w700))]),
      ])),
      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: Colors.white, size: 19), tooltip: 'Close'),
    ]),
  );

  Widget _depositForm() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _segmented(['CHEESE PAY', 'MANUAL', 'USDT'], _method, (i) => setState(() => _method = i), icons: [LucideIcons.creditCard, LucideIcons.wallet, LucideIcons.coins]),
    const SizedBox(height: 16),
    _fieldLabel('SELECT TRADING ACCOUNT'),
    const SizedBox(height: 7),
    _accountSelect('Mohanprasath R - 3311 - \$0.00'),
    const SizedBox(height: 15),
    if (_method == 0) ...[
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _infoCard('Deposit Currency', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _segmented(['USD', 'INR'], _currency, (i) => setState(() => _currency = i), compact: true),
          const SizedBox(height: 7), Text(_currency == 0 ? 'You will pay in US Dollars (USD)' : 'You will pay in Indian Rupees (INR)', style: const TextStyle(color: Color(0xFF8AB8FF), fontSize: 9)),
        ]))),
        const SizedBox(width: 9),
        Expanded(child: _infoCard('Live Exchange Rate', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('1 USD = 94.29 INR', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)), SizedBox(height: 11), Text('Latest available rate', style: TextStyle(color: _muted, fontSize: 9))]))),
      ]),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _fieldLabel('DEPOSIT AMOUNT (${_currency == 0 ? 'USD' : 'INR'})')), const SizedBox(width: 10), const Text('YOU WILL GET (USD)', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 7),
      Row(children: [Expanded(child: _moneyInput(_currency == 0 ? '\$' : '₹')), const SizedBox(width: 10), _valueBadge('\$ ${_amount.text.isEmpty ? '0.00' : _amount.text}')]),
      const SizedBox(height: 12),
      Wrap(spacing: 7, runSpacing: 7, children: [1000, 5000, 10000, 25000, 50000, 100000].map((value) => _amountChip('₹ ${_formatAmount(value)}', '$value')).toList()),
      const SizedBox(height: 12),
      _notice('Minimum deposit amount is Rs.1000'),
      const SizedBox(height: 14),
      _fundButton('PAY NOW', onPressed: () => _submit(context, false)),
    ] else if (_method == 1) ...[
      _notice('INSTRUCTIONS\nContact support for verified bank details, then upload your transaction proof for review.', icon: LucideIcons.info),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _fieldLabel('DEPOSIT AMOUNT (INR)')), const Text('USD EQUIVALENT', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 7),
      Row(children: [Expanded(child: _moneyInput('₹')), const SizedBox(width: 10), _valueBadge('\$ 0.00')]),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a transaction proof file.'))), icon: const Icon(LucideIcons.cloudUpload, size: 16), label: const Text('Upload transaction proof (JPG, PNG or PDF)'), style: _outlineStyle()),
      const SizedBox(height: 14),
      _fundButton('SUBMIT FOR VERIFICATION', onPressed: () => _submit(context, false)),
    ] else ...[
      _notice('USDT TRC20 PROTOCOL\nEnter the amount you wish to fund. You will be securely redirected to our payment gateway.', icon: LucideIcons.globe),
      const SizedBox(height: 16),
      _fieldLabel('DEPOSIT AMOUNT (USDT)'), const SizedBox(height: 7), _moneyInput('\$', suffix: 'USDT'),
      const SizedBox(height: 15),
      _fundButton('PAY NOW', onPressed: () => _submit(context, false)),
    ],
    const SizedBox(height: 12),
    const Center(child: Text('♢  PROTECTED', style: TextStyle(color: Color(0xFF53617A), fontSize: 8, letterSpacing: 1.3, fontWeight: FontWeight.w800))),
  ]);

  Widget _withdrawForm() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [const Icon(LucideIcons.circle, color: Color(0xFF16D994), size: 9), const SizedBox(width: 6), const Text('WITHDRAWABLE TREASURY', style: TextStyle(color: Color(0xFF8DB9FF), fontSize: 10, fontWeight: FontWeight.w700)), const Spacer(), _valueBadge('Active Account: 3311')]),
    const SizedBox(height: 3), const Text('\$0.00', style: TextStyle(color: Colors.white, fontSize: 29, height: 1.1, fontWeight: FontWeight.w800)),
    const SizedBox(height: 15), _stepTitle('1', 'SELECT SOURCE ACCOUNT'), const SizedBox(height: 7), _accountSelect('3311     STANDARD     Available:  \$0.00'),
    const SizedBox(height: 15), _stepTitle('2', 'CHOOSE PAYOUT METHOD'), const SizedBox(height: 8),
    Row(children: [Expanded(child: _payoutCard(0, LucideIcons.landmark, 'Bank Transfer', 'ocbc bank •••• 0111', 'Linked', '1–3 Business Days')), const SizedBox(width: 8), Expanded(child: _payoutCard(1, LucideIcons.wallet, 'Crypto Wallet', 'Connect your wallet', 'Setup Needed', 'Near-Instant (~10–30m)'))]),
    const SizedBox(height: 15), Row(children: [_stepTitle('3', 'ENTER WITHDRAWAL AMOUNT'), const Spacer(), const Text('Min: \$10.00', style: TextStyle(color: _muted, fontSize: 9))]),
    const SizedBox(height: 7), _moneyInput('\$', suffix: 'USD'),
    const SizedBox(height: 8), Wrap(spacing: 6, children: [50, 100, 250, 500].map((v) => _amountChip('\$$v', '$v')).toList()..add(_amountChip('MAX', '0'))),
    const SizedBox(height: 12), _infoCard('Net Payout Amount', child: Row(children: [const Expanded(child: Text('Credited to your destination', style: TextStyle(color: _muted, fontSize: 9))), Text('\$${_amount.text.isEmpty ? '0.00' : _amount.text}', style: const TextStyle(color: Color(0xFF00D7A1), fontSize: 17, fontWeight: FontWeight.w800))])),
  ]);

  Widget _payoutCard(int index, IconData icon, String title, String detail, String status, String timing) {
    final selected = _payout == index;
    final accent = selected ? const Color(0xFF4B83FF) : const Color(0xFF26354D);
    return InkWell(onTap: () => setState(() => _payout = index), borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF101B31), borderRadius: BorderRadius.circular(15), border: Border.all(color: accent, width: selected ? 1.3 : .8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(color: accent.withValues(alpha: .2), borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: const Color(0xFF75A8FF), size: 17)), const Spacer(), Icon(selected ? LucideIcons.circleCheck : LucideIcons.circle, color: selected ? const Color(0xFF4B83FF) : _muted, size: 16)]), const SizedBox(height: 8), Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)), Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 8)), const SizedBox(height: 6), Text('$status  •  $timing', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? const Color(0xFF16D994) : _muted, fontSize: 8, fontWeight: FontWeight.w700))])));
  }

  Widget _stepTitle(String number, String title) => Row(children: [Container(width: 18, height: 18, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF3458E8), shape: BoxShape.circle), child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))), const SizedBox(width: 7), Text(title, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .2))]);

  Widget _fieldLabel(String label) => Text(label, style: const TextStyle(color: Color(0xFF9AABC8), fontSize: 9, letterSpacing: .55, fontWeight: FontWeight.w800));

  Widget _accountSelect(String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13), decoration: BoxDecoration(color: const Color(0xFF0B1426), border: Border.all(color: const Color(0xFF26354D)), borderRadius: BorderRadius.circular(13)), child: Row(children: [const Icon(LucideIcons.users, color: Color(0xFF416FFF), size: 15), const SizedBox(width: 10), Expanded(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))), const Icon(LucideIcons.chevronDown, color: _muted, size: 16)]));

  Widget _segmented(List<String> labels, int selected, ValueChanged<int> onSelect, {List<IconData>? icons, bool compact = false}) => Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF1E293B))), child: Row(children: [for (var i = 0; i < labels.length; i++) Expanded(child: GestureDetector(onTap: () => onSelect(i), child: Container(height: compact ? 31 : 34, alignment: Alignment.center, decoration: BoxDecoration(color: i == selected ? const Color(0xFF425CC5) : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (icons != null) ...[Icon(icons[i], color: i == selected ? Colors.white : _muted, size: 12), const SizedBox(width: 5)], Text(labels[i], style: TextStyle(color: i == selected ? Colors.white : _muted, fontSize: compact ? 8 : 9, fontWeight: FontWeight.w800))]))))]));

  Widget _infoCard(String title, {required Widget child}) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFF101B30), border: Border.all(color: const Color(0xFF263B5A)), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 8), child]));

  Widget _moneyInput(String symbol, {String? suffix}) => Container(height: 49, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: const Color(0xFF091326), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF29466F))), child: Row(children: [Text(symbol, style: const TextStyle(color: Color(0xFF59A4FF), fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(width: 10), Expanded(child: TextField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), textInputAction: TextInputAction.done, onTapOutside: (_) => FocusScope.of(context).unfocus(), onSubmitted: (_) => FocusScope.of(context).unfocus(), onChanged: (_) => setState(() {}), style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800), decoration: const InputDecoration(hintText: '0.00', hintStyle: TextStyle(color: Color(0xFF61718C)), border: InputBorder.none, isDense: true))), if (suffix != null) Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF172941), borderRadius: BorderRadius.circular(12)), child: Text(suffix, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))]));

  Widget _valueBadge(String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13), decoration: BoxDecoration(color: const Color(0xFF132844), borderRadius: BorderRadius.circular(13)), child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)));

  Widget _amountChip(String label, String value) => ActionChip(label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)), backgroundColor: const Color(0xFF121C2E), side: const BorderSide(color: Color(0xFF28354A)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), onPressed: () => setState(() => _amount.text = value));

  Widget _notice(String text, {IconData icon = LucideIcons.info}) => Container(width: double.infinity, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFF111C30), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF36445A), style: BorderStyle.solid)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: _gold, size: 15), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: Color(0xFFCED6E4), fontSize: 10, height: 1.45, fontWeight: FontWeight.w600)))]));

  ButtonStyle _outlineStyle() => OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF29374E)), minimumSize: const Size.fromHeight(46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)), textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700));

  Widget _fundButton(String label, {required VoidCallback onPressed}) => SizedBox(width: double.infinity, height: 46, child: FilledButton.icon(onPressed: onPressed, iconAlignment: IconAlignment.end, icon: const Icon(LucideIcons.arrowRight, size: 15), label: Text(label, style: const TextStyle(fontSize: 12, letterSpacing: .8, fontWeight: FontWeight.w900)), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF345CE5), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))));

  void _submit(BuildContext context, bool withdrawal) {
    if (_amount.text.isEmpty || (withdrawal && (double.tryParse(_amount.text) ?? 0) < 10)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(withdrawal ? 'Enter a withdrawal amount of at least \$10.' : 'Enter an amount to continue.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(withdrawal ? 'Withdrawal request is ready for review.' : 'Deposit request is ready for processing.')));
  }

  String _formatAmount(int value) => value >= 100000 ? '1,00,000' : value >= 1000 ? value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+$)'), (m) => ',') : '$value';
}
