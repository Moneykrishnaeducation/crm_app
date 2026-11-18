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

  @override
  void dispose() {
    _amountController.dispose();
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
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 740;
    final narrow = size.width < 380;
    final horizontal = size.width >= 520;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomReserve = 104.0;
        return SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.fromLTRB(narrow ? 12 : 16, compact ? 8 : 14, narrow ? 12 : 16, bottomReserve),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [colors.primary, colors.primary.withValues(alpha: .78)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(LucideIcons.arrowLeftRight, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Move funds', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.5)),
                              const SizedBox(height: 2),
                              Text('Between your live trading accounts', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Transfer information',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showGuidelines(context),
                          icon: Icon(LucideIcons.info, color: muted, size: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 12 : 18),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(compact ? 14 : 18),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: .8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: dark ? .16 : .045),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text('TRANSFER', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: muted)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: .09),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      Text('LIVE MT5', style: theme.textTheme.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w800, letterSpacing: .5)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 12 : 16),
                            if (horizontal)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(child: _TransferAccountPicker(label: 'FROM ACCOUNT', value: _source, accountIds: _accountIds, onChanged: (v) => setState(() => _source = v), compact: true)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: _SwapButton(onPressed: _swapAccounts, icon: LucideIcons.arrowLeftRight, compact: true),
                                  ),
                                  Expanded(child: _TransferAccountPicker(label: 'TO ACCOUNT', value: _destination, accountIds: _accountIds, onChanged: (v) => setState(() => _destination = v), compact: true)),
                                ],
                              )
                            else ...[
                              _TransferAccountPicker(label: 'FROM ACCOUNT', value: _source, accountIds: _accountIds, onChanged: (v) => setState(() => _source = v), compact: true),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 17),
                                  child: SizedBox(
                                    height: 30,
                                    child: _SwapButton(onPressed: _swapAccounts, icon: LucideIcons.arrowDownUp, compact: true),
                                  ),
                                ),
                              ),
                              _TransferAccountPicker(label: 'TO ACCOUNT', value: _destination, accountIds: _accountIds, onChanged: (v) => setState(() => _destination = v), compact: true),
                            ],
                            SizedBox(height: compact ? 14 : 18),
                            Container(height: 1, color: theme.dividerColor),
                            SizedBox(height: compact ? 13 : 17),
                            Row(
                              children: [
                                Text('Amount to transfer', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                const Spacer(),
                                Text('USD', style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w800, letterSpacing: .8)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: dark ? colors.surfaceContainerHighest.withValues(alpha: .35) : colors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(color: _amountController.text.isNotEmpty ? colors.primary.withValues(alpha: .55) : theme.dividerColor),
                              ),
                              child: TextField(
                                controller: _amountController,
                                onChanged: (_) => setState(() {}),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
                                decoration: InputDecoration(
                                  prefixText: '\$ ',
                                  prefixStyle: theme.textTheme.headlineMedium?.copyWith(color: const Color(0xFFD69B16), fontWeight: FontWeight.w800),
                                  hintText: '0.00',
                                  hintStyle: theme.textTheme.headlineMedium?.copyWith(color: muted.withValues(alpha: .45), fontWeight: FontWeight.w700),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                Icon(LucideIcons.wallet, size: 15, color: muted),
                                const SizedBox(width: 7),
                                Expanded(child: Text('Available to transfer', style: theme.textTheme.bodySmall?.copyWith(color: muted))),
                                Text('\$' + _availableBalance.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed: _availableBalance > 0 ? () => _setAmount(_availableBalance) : null,
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 7)),
                                  child: const Text('MAX'),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 11, vertical: compact ? 9 : 11),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: .065),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: colors.primary.withValues(alpha: .15)),
                              ),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.shieldCheck, color: colors.primary, size: 17),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Please verify the receiving account before proceeding.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.25),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: compact ? 10 : 14),
                            SizedBox(
                              height: compact ? 48 : 52,
                              child: FilledButton(
                                onPressed: _submitTransfer,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC533),
                                  foregroundColor: const Color(0xFF10213A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('REVIEW TRANSFER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .6)),
                                    const SizedBox(width: 9),
                                    const Icon(LucideIcons.arrowRight, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 5 : 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.lockKeyhole, size: 13, color: muted),
                        const SizedBox(width: 6),
                        Text('Secure account-to-account transfer', style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                      ],
                    ),
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
            items: accountIds.map((id) => DropdownMenuItem(value: id, child: Text('MT5 · ' + id, maxLines: 1, overflow: TextOverflow.clip))).toList(),
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
