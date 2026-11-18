part of '../main.dart';

class BrokerInternalTransferPage extends StatefulWidget {
  const BrokerInternalTransferPage({super.key});
  @override
  State<BrokerInternalTransferPage> createState() => _BrokerInternalTransferPageState();
}

class _BrokerInternalTransferPageState extends State<BrokerInternalTransferPage> {
  static const _accountIds = ['3315', '3311', '3312', '3327'];
  static const double _availableBalance = 0;
  String _source = '3315';
  String _destination = '3312';
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

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
    final oldSource = _source;
    _source = _destination;
    _destination = oldSource;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurfaceVariant;
    final dark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 720;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.fromLTRB(width < 360 ? 12 : 16, 18, width < 360 ? 12 : 16, 120),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(15)),
                      child: Icon(LucideIcons.arrowLeftRight, color: colors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Internal Transfer', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.4)),
                      const SizedBox(height: 3),
                      Text('Move funds between your live trading accounts', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                    ])),
                    IconButton(tooltip: 'Transfer information', onPressed: () => _showGuidelines(context), icon: Icon(LucideIcons.info, color: muted)),
                  ]),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(wide ? 22 : 16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .16 : .045), blurRadius: 22, offset: const Offset(0, 8))],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Text('TRANSFER DETAILS', style: theme.textTheme.labelMedium?.copyWith(color: muted, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                        const Spacer(),
                        _StatusPill(label: 'MT5 LIVE', color: colors.primary),
                      ]),
                      const SizedBox(height: 18),
                      if (wide)
                        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Expanded(child: _TransferAccountPicker(label: 'FROM ACCOUNT', value: _source, accountIds: _accountIds, onChanged: (v) => setState(() => _source = v))),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _SwapButton(onPressed: _swapAccounts, icon: LucideIcons.arrowLeftRight)),
                          Expanded(child: _TransferAccountPicker(label: 'TO ACCOUNT', value: _destination, accountIds: _accountIds, onChanged: (v) => setState(() => _destination = v))),
                        ])
                      else ...[
                        _TransferAccountPicker(label: 'FROM ACCOUNT', value: _source, accountIds: _accountIds, onChanged: (v) => setState(() => _source = v)),
                        Align(alignment: Alignment.center, child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _SwapButton(onPressed: _swapAccounts, icon: LucideIcons.arrowDownUp),
                        )),
                        _TransferAccountPicker(label: 'TO ACCOUNT', value: _destination, accountIds: _accountIds, onChanged: (v) => setState(() => _destination = v)),
                      ],
                      const SizedBox(height: 22),
                      Divider(color: theme.dividerColor, height: 1),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: Text('Transfer amount', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                        Text('USD', style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w800, letterSpacing: .8)),
                      ]),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: dark ? colors.surfaceContainerHighest.withValues(alpha: .45) : colors.surfaceContainerLowest,
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _amountController,
                          onChanged: (_) => setState(() {}),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.8),
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            prefixStyle: theme.textTheme.headlineSmall?.copyWith(color: const Color(0xFFD69B16), fontWeight: FontWeight.w800),
                            hintText: '0.00',
                            hintStyle: theme.textTheme.headlineMedium?.copyWith(color: muted.withValues(alpha: .55), fontWeight: FontWeight.w700),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Row(children: [
                        Icon(LucideIcons.wallet, size: 15, color: muted),
                        const SizedBox(width: 6),
                        Expanded(child: Text('Available balance', style: theme.textTheme.bodySmall?.copyWith(color: muted))),
                        Text('\$' + _availableBalance.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                        TextButton(onPressed: _availableBalance > 0 ? () => _setAmount(_availableBalance) : null, child: const Text('MAX')),
                      ]),
                      const SizedBox(height: 14),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: colors.primary.withValues(alpha: .18)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(LucideIcons.info, size: 17, color: colors.primary),
                          const SizedBox(width: 9),
                          Expanded(child: Text(
                            'Review both account numbers and the amount before confirming. Transfers can only be made between eligible live accounts.',
                            style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.4),
                          )),
                        ]),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _submitTransfer,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC533),
                            foregroundColor: const Color(0xFF10213A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          icon: const Icon(LucideIcons.arrowRight, size: 18),
                          label: const Text('REVIEW TRANSFER', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .5)),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(LucideIcons.shieldCheck, size: 15, color: muted),
                    const SizedBox(width: 7),
                    Text('Secure account-to-account transfer', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitTransfer() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (_source == _destination) {
      showAppMessage('Select two different trading accounts.');
    } else if (amount <= 0) {
      showAppMessage('Enter a transfer amount greater than zero.');
    } else if (amount > _availableBalance) {
      showAppMessage('Insufficient available balance.');
    } else {
      showAppMessage('Transfer service is not connected yet. No funds have been moved.');
    }
  }

  void _showGuidelines(BuildContext context) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Transfer guidelines'),
        content: const Text('Transfers are intended for eligible live MT5 accounts. Verify the source account, destination account and available balance before confirming.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
      ),
    );
  }
}

class _TransferAccountPicker extends StatelessWidget {
  const _TransferAccountPicker({required this.label, required this.value, required this.accountIds, required this.onChanged});
  final String label;
  final String value;
  final List<String> accountIds;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurfaceVariant;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(label, style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w800, letterSpacing: .7)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(color: colors.surfaceContainerLowest, borderRadius: BorderRadius.circular(15), border: Border.all(color: theme.dividerColor)),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(11)), child: Icon(LucideIcons.walletCards, color: colors.primary, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: colors.surface,
            iconEnabledColor: muted,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            items: accountIds.map((id) => DropdownMenuItem(value: id, child: Text('MT5 Account  •  ' + id, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (next) { if (next != null) onChanged(next); },
          ))),
        ]),
      ),
      const SizedBox(height: 5),
      Text('USD account  ·  Balance data unavailable', style: theme.textTheme.labelSmall?.copyWith(color: muted, fontSize: 10)),
    ]);
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onPressed, required this.icon});
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: 'Swap accounts',
      style: IconButton.styleFrom(
        backgroundColor: colors.primary.withValues(alpha: .10),
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary.withValues(alpha: .18)),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

class _TransferChip extends StatelessWidget {
  const _TransferChip({required this.label, required this.selected, required this.enabled, required this.onTap});
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: selected ? colors.primary.withValues(alpha: .13) : colors.surfaceContainerHighest.withValues(alpha: enabled ? 1 : .45),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), border: Border.all(color: selected ? colors.primary : theme.dividerColor)),
          child: Text(label, style: theme.textTheme.labelMedium?.copyWith(
            color: enabled ? (selected ? colors.primary : colors.onSurface) : colors.onSurfaceVariant.withValues(alpha: .55),
            fontWeight: FontWeight.w700,
          )),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(30), border: Border.all(color: color.withValues(alpha: .22))),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w800, letterSpacing: .6)),
  );
}
