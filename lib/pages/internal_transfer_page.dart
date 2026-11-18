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
    final compact = MediaQuery.sizeOf(context).height < 720;
    final horizontalAccounts = width >= 360;
    final horizontalPadding = width < 360 ? 12.0 : 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The bottom navigation is layered over the page. Reserve space for it
        // so the transfer action remains visible without making this page scroll.
        final usableHeight = (constraints.maxHeight - 104).clamp(0.0, constraints.maxHeight);
        return SizedBox(
          height: constraints.maxHeight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, compact ? 8 : 14, horizontalPadding, 104),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 760, maxHeight: usableHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Container(
                        width: compact ? 40 : 44,
                        height: compact ? 40 : 44,
                        decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)),
                        child: Icon(LucideIcons.arrowLeftRight, color: colors.primary, size: 21),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Internal Transfer', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.4)),
                        Text('Move funds between live trading accounts', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                      ])),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Transfer information',
                        onPressed: () => _showGuidelines(context),
                        icon: Icon(LucideIcons.info, color: muted, size: 20),
                      ),
                    ]),
                    SizedBox(height: compact ? 10 : 16),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(compact ? 13 : 17),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.dividerColor),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .14 : .035), blurRadius: 18, offset: const Offset(0, 6))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(children: [
                              Expanded(child: Text('TRANSFER DETAILS', style: theme.textTheme.labelMedium?.copyWith(color: muted, fontWeight: FontWeight.w800, letterSpacing: .9))),
                              _StatusPill(label: 'MT5 LIVE', color: colors.primary),
                            ]),
                            SizedBox(height: compact ? 12 : 16),
                            if (horizontalAccounts)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: _TransferAccountPicker(label: 'FROM', value: _source, accountIds: _accountIds, onChanged: (v) => setState(() => _source = v), compact: true)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: _SwapButton(onPressed: _swapAccounts, icon: LucideIcons.arrowLeftRight, compact: true),
                                  ),
                                  Expanded(child: _TransferAccountPicker(label: 'TO', value: _destination, accountIds: _accountIds, onChanged: (v) => setState(() => _destination = v), compact: true)),
                                ],
                              )
                            else ...[
                              _TransferAccountPicker(label: 'FROM ACCOUNT', value: _source, accountIds: _accountIds, onChanged: (v) => setState(() => _source = v), compact: true),
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 30,
                                  child: _SwapButton(onPressed: _swapAccounts, icon: LucideIcons.arrowDownUp, compact: true),
                                ),
                              ),
                              _TransferAccountPicker(label: 'TO ACCOUNT', value: _destination, accountIds: _accountIds, onChanged: (v) => setState(() => _destination = v), compact: true),
                            ],
                            SizedBox(height: compact ? 12 : 16),
                            Divider(color: theme.dividerColor, height: 1),
                            SizedBox(height: compact ? 12 : 16),
                            Row(children: [
                              Expanded(child: Text('Transfer amount', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
                              Text('USD', style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w800, letterSpacing: .8)),
                            ]),
                            const SizedBox(height: 7),
                            Container(
                              decoration: BoxDecoration(
                                color: dark ? colors.surfaceContainerHighest.withValues(alpha: .4) : colors.surfaceContainerLowest,
                                border: Border.all(color: theme.dividerColor),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                controller: _amountController,
                                onChanged: (_) => setState(() {}),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.6),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  prefixStyle: theme.textTheme.titleLarge?.copyWith(color: const Color(0xFFD69B16), fontWeight: FontWeight.w800),
                                  hintText: '0.00',
                                  hintStyle: theme.textTheme.headlineSmall?.copyWith(color: muted.withValues(alpha: .55), fontWeight: FontWeight.w700),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(children: [
                              Icon(LucideIcons.wallet, size: 14, color: muted),
                              const SizedBox(width: 5),
                              Expanded(child: Text('Available balance', style: theme.textTheme.bodySmall?.copyWith(color: muted))),
                              Text('\$' + _availableBalance.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(width: 4),
                              SizedBox(
                                height: 30,
                                child: TextButton(
                                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), visualDensity: VisualDensity.compact),
                                  onPressed: _availableBalance > 0 ? () => _setAmount(_availableBalance) : null,
                                  child: const Text('MAX'),
                                ),
                              ),
                            ]),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.all(compact ? 9 : 11),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: .065),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.primary.withValues(alpha: .16)),
                              ),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                Icon(LucideIcons.info, size: 16, color: colors.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(
                                  'Check both account numbers and the amount. Only eligible live accounts can receive transfers.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.25),
                                )),
                              ]),
                            ),
                            SizedBox(height: compact ? 10 : 14),
                            SizedBox(
                              height: compact ? 46 : 50,
                              child: FilledButton.icon(
                                onPressed: _submitTransfer,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC533),
                                  foregroundColor: const Color(0xFF10213A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                icon: const Icon(LucideIcons.arrowRight, size: 18),
                                label: const Text('REVIEW TRANSFER', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 5 : 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(LucideIcons.shieldCheck, size: 14, color: muted),
                      const SizedBox(width: 6),
                      Text('Secure account-to-account transfer', style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
  const _TransferAccountPicker({required this.label, required this.value, required this.accountIds, required this.onChanged, this.compact = false});
  final String label;
  final String value;
  final List<String> accountIds;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurfaceVariant;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(label, style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w800, letterSpacing: .7)),
      SizedBox(height: compact ? 5 : 8),
      Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 1 : 3),
        decoration: BoxDecoration(color: colors.surfaceContainerLowest, borderRadius: BorderRadius.circular(15), border: Border.all(color: theme.dividerColor)),
        child: Row(children: [
          Container(width: compact ? 29 : 36, height: compact ? 29 : 36, decoration: BoxDecoration(color: colors.primary.withValues(alpha: .10), borderRadius: BorderRadius.circular(11)), child: Icon(LucideIcons.walletCards, color: colors.primary, size: 18)),
          SizedBox(width: compact ? 6 : 10),
          Expanded(child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            isDense: compact,
            dropdownColor: colors.surface,
            iconEnabledColor: muted,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            items: accountIds.map((id) => DropdownMenuItem(value: id, child: Text('MT5 Account  •  ' + id, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (next) { if (next != null) onChanged(next); },
          ))),
        ]),
      ),
      const SizedBox(height: 5),
      if (!compact) Text('USD account  ·  Balance data unavailable', style: theme.textTheme.labelSmall?.copyWith(color: muted, fontSize: 10)),
    ]);
  }
}

class _SwapButton extends StatelessWidget {
  const _SwapButton({required this.onPressed, required this.icon, this.compact = false});
  final VoidCallback onPressed;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      constraints: compact ? const BoxConstraints.tightFor(width: 34, height: 34) : null,
      padding: compact ? EdgeInsets.zero : null,
      visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
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
