part of '../main.dart';

class BrokerInternalTransferPage extends StatefulWidget {
  const BrokerInternalTransferPage({super.key});
  @override
  State<BrokerInternalTransferPage> createState() => _BrokerInternalTransferPageState();
}

class _BrokerInternalTransferPageState extends State<BrokerInternalTransferPage> {
  static const _accountIds = ['3315', '3311', '3312', '3327'];
  String _source = '3315';
  String _destination = '3312';
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  static const double _available = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setAmount(double amount) {
    _amountController.text = amount.toStringAsFixed(2);
    setState(() {});
  }

  void _swapAccounts() => setState(() {
    final previous = _source;
    _source = _destination;
    _destination = previous;
  });

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFF5F7FB),
    child: LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth >= 680;
      final amount = double.tryParse(_amountController.text) ?? 0;
      return ListView(padding: const EdgeInsets.fromLTRB(14, 14, 14, 28), children: [
        Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F1))), child: const Icon(LucideIcons.arrowLeftRight, color: _brokerBlue, size: 23)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Internal Transfer', style: TextStyle(color: _brokerNavy, fontSize: 19, fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('Move funds between your verified MT5 live trading accounts.', style: TextStyle(color: _brokerMuted, fontSize: 9))])),
          IconButton(onPressed: () => _showGuidelines(context), tooltip: 'Transfer guidelines', icon: const Icon(LucideIcons.info, color: _brokerMuted)),
        ]),
        const SizedBox(height: 18),
        Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 920), child: Container(
          padding: EdgeInsets.all(wide ? 20 : 14),
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F1)), boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 18, offset: Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (wide)
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: _TransferAccountPicker(label: 'TRANSFER FROM (SOURCE)', value: _source, accountIds: _accountIds, onChanged: (value) => setState(() => _source = value))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: IconButton(onPressed: _swapAccounts, style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFFFFF), side: const BorderSide(color: Color(0xFFE2E8F1))), icon: const Icon(LucideIcons.arrowLeftRight, color: _brokerBlue))),
                Expanded(child: _TransferAccountPicker(label: 'TRANSFER TO (DESTINATION)', value: _destination, accountIds: _accountIds, onChanged: (value) => setState(() => _destination = value))),
              ])
            else ...[
              _TransferAccountPicker(label: 'TRANSFER FROM (SOURCE)', value: _source, accountIds: _accountIds, onChanged: (value) => setState(() => _source = value)),
              Align(alignment: Alignment.center, child: IconButton(onPressed: _swapAccounts, style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFFFFF), side: const BorderSide(color: Color(0xFFE2E8F1))), icon: const Icon(LucideIcons.arrowUpDown, color: _brokerBlue))),
              _TransferAccountPicker(label: 'TRANSFER TO (DESTINATION)', value: _destination, accountIds: _accountIds, onChanged: (value) => setState(() => _destination = value)),
            ],
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFE2E8F1)),
            const SizedBox(height: 14),
            Row(children: [const Expanded(child: Text('TRANSFER AMOUNT (USD)', style: TextStyle(color: _brokerMuted, fontSize: 9, fontWeight: FontWeight.w700))), Text('Available:  ', style: const TextStyle(color: _brokerMuted, fontSize: 9)), const Text('\$0.00', style: TextStyle(color: _brokerNavy, fontSize: 9, fontWeight: FontWeight.w700)), TextButton(onPressed: () => _setAmount(_available), child: const Text('MAX', style: TextStyle(color: _brokerGold, fontSize: 9, fontWeight: FontWeight.w700)))]),
            TextField(controller: _amountController, onChanged: (_) => setState(() {}), keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: _brokerNavy, fontSize: 24, fontWeight: FontWeight.w700), decoration: InputDecoration(prefixText: '\$ ', prefixStyle: const TextStyle(color: _brokerGold, fontSize: 21, fontWeight: FontWeight.w700), hintText: '0.00', hintStyle: const TextStyle(color: Color(0xFF6F7FA8)), filled: true, fillColor: const Color(0xFFFFFFFF), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFE2E8F1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: _brokerBlue)))),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              const Text('Quick Fill:', style: TextStyle(color: _brokerMuted, fontSize: 8)),
              for (final percent in [25, 50, 75, 100]) _TransferChip(label: percent == 100 ? '100% (Max)' : '$percent%', onTap: () => _setAmount(_available * percent / 100)),
              Container(width: 1, height: 17, color: const Color(0xFFE2E8F1)),
              for (final value in [50, 100, 500, 1000]) _TransferChip(label: '+\$$value', onTap: () => _setAmount(amount + value)),
            ]),
            const SizedBox(height: 18),
            const Text('TRANSFER NOTE / REFERENCE (OPTIONAL)', style: TextStyle(color: _brokerMuted, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 7),
            TextField(controller: _noteController, style: const TextStyle(color: _brokerNavy, fontSize: 11), decoration: InputDecoration(prefixIcon: const Icon(LucideIcons.messageCircle, size: 15, color: _brokerMuted), hintText: 'e.g. Funding, rebalance portfolio', hintStyle: const TextStyle(color: Color(0xFF7B88AD), fontSize: 10), isDense: true, filled: true, fillColor: const Color(0xFFFFFFFF), contentPadding: const EdgeInsets.symmetric(vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xFFE2E8F1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: _brokerBlue)))),
            const SizedBox(height: 18),
            Wrap(alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 12, children: [
              const Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.shieldCheck, color: Color(0xFF10D6B2), size: 14), SizedBox(width: 6), Text('Encrypted transfer protocol', style: TextStyle(color: _brokerMuted, fontSize: 9))]),
              FilledButton.icon(onPressed: _submitTransfer, style: FilledButton.styleFrom(backgroundColor: _brokerGold, foregroundColor: _brokerNavy, padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))), icon: const Icon(LucideIcons.arrowRight, size: 16), label: const Text('TRANSFER FUNDS NOW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800))),
            ]),
          ]),
        ))),
      ]);
    }),
  );

  void _submitTransfer() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final message = _source == _destination
        ? 'Choose two different accounts.'
        : amount <= 0
            ? 'Enter an amount greater than zero.'
            : amount > _available
                ? 'Insufficient available balance.'
                : 'Transfer submitted.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showGuidelines(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _brokerPanel,
          title: const Text('Transfer Guidelines', style: TextStyle(color: _brokerNavy)),
          content: const Text('Transfers are available between verified live trading accounts. Check the source balance and destination account before submitting.', style: TextStyle(color: _brokerMuted)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
        ),
      );
}

class _TransferAccountPicker extends StatelessWidget {
  const _TransferAccountPicker({required this.label, required this.value, required this.accountIds, required this.onChanged});
  final String label, value; final List<String> accountIds; final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [Expanded(child: Text(label, style: const TextStyle(color: _brokerMuted, fontSize: 9, fontWeight: FontWeight.w700))), Text('Bal: \$0.00', style: const TextStyle(color: _brokerGold, fontSize: 9, fontWeight: FontWeight.w700))]),
    const SizedBox(height: 7),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFE2E8F1))), child: Row(children: [const Icon(LucideIcons.wallet, color: _brokerBlue, size: 17), const SizedBox(width: 8), Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, dropdownColor: _brokerPanel, iconEnabledColor: _brokerMuted, style: const TextStyle(color: _brokerNavy, fontSize: 11), items: accountIds.map((id) => DropdownMenuItem(value: id, child: Text('$id   KRSNA-USD-B'))).toList(), onChanged: (next) { if (next != null) onChanged(next); }))),])),
  ]);
}

class _TransferChip extends StatelessWidget {
  const _TransferChip({required this.label, required this.onTap});
  final String label; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFF3F6FB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F1))), child: Text(label, style: const TextStyle(color: _brokerNavy, fontSize: 8, fontWeight: FontWeight.w600))));
}
