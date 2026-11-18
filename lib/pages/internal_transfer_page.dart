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
    final compact = size.height < 760;
    final narrow = size.width < 380;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.fromLTRB(narrow ? 12 : 16, compact ? 8 : 14, narrow ? 12 : 16, 104),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Internal transfer', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.7)),
                              const SizedBox(height: 3),
                              Text('Move funds between your trading accounts', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Transfer information',
                          onPressed: () => _showGuidelines(context),
                          icon: Icon(LucideIcons.circleHelp, color: muted),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 12 : 18),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(compact ? 14 : 20),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: theme.dividerColor.withValues(alpha: .75)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: dark ? .18 : .045),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Text('TRANSFER ROUTE', style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: .09),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 6, height: 6, decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle)),
                                      const SizedBox(width: 6),
                                      Text('LIVE ACCOUNTS', style: theme.textTheme.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w800, letterSpacing: .45)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 13 : 18),
                            _TransferAccountPicker(
                              label: 'FROM',
                              value: _source,
                              accountIds: _accountIds,
                              onChanged: (v) => setState(() => _source = v),
                              compact: true,
                            ),
                            SizedBox(
                              height: compact ? 38 : 46,
                              child: Row(
                                children: [
                                  const SizedBox(width: 24),
                                  Container(width: 1, height: double.infinity, color: colors.primary.withValues(alpha: .22)),
                                  const Spacer(),
                                  _SwapButton(onPressed: _swapAccounts, icon: LucideIcons.arrowDownUp, compact: true),
                                  const Spacer(),
                                  const SizedBox(width: 24),
                                ],
                              ),
                            ),
                            _TransferAccountPicker(
                              label: 'TO',
                              value: _destination,
                              accountIds: _accountIds,
                              onChanged: (v) => setState(() => _destination = v),
                              compact: true,
                            ),
                            SizedBox(height: compact ? 15 : 20),
                            Container(
                              height: 1,
                              color: theme.dividerColor,
                            ),
                            SizedBox(height: compact ? 13 : 18),
                            Row(
                              children: [
                                Text('Transfer amount', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                const Spacer(),
                                Text('USD', style: theme.textTheme.labelSmall?.copyWith(color: muted, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ],
                            ),
                            const SizedBox(height: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                              decoration: BoxDecoration(
                                color: dark ? colors.surfaceContainerHighest.withValues(alpha: .42) : colors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _amountController.text.isNotEmpty ? colors.primary.withValues(alpha: .65) : theme.dividerColor,
                                  width: _amountController.text.isNotEmpty ? 1.4 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text('\$', style: theme.textTheme.headlineMedium?.copyWith(color: const Color(0xFFD69B16), fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _amountController,
                                      onChanged: (_) => setState(() {}),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.8),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        hintStyle: theme.textTheme.headlineMedium?.copyWith(color: muted.withValues(alpha: .42), fontWeight: FontWeight.w700),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 9),
                            Row(
                              children: [
                                Icon(LucideIcons.wallet, size: 15, color: muted),
                                const SizedBox(width: 7),
                                Expanded(child: Text('Available balance', style: theme.textTheme.bodySmall?.copyWith(color: muted))),
                                Text('\$' + _availableBalance.toStringAsFixed(2), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                                TextButton(
                                  onPressed: _availableBalance > 0 ? () => _setAmount(_availableBalance) : null,
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.only(left: 8)),
                                  child: const Text('MAX'),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 11, vertical: compact ? 9 : 11),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: .055),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.info, color: colors.primary, size: 17),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      'Make sure the destination account is correct before reviewing.',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(color: muted, height: 1.25),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: compact ? 11 : 15),
                            SizedBox(
                              height: compact ? 49 : 54,
                              child: FilledButton(
                                onPressed: _submitTransfer,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC533),
                                  foregroundColor: const Color(0xFF10213A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: .8)),
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
                    SizedBox(height: compact ? 6 : 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.shieldCheck, size: 13, color: muted),
                        const SizedBox(width: 6),
                        Text('Protected account transfer', style: theme.textTheme.labelSmall?.copyWith(color: muted)),
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
  const _TransferAccountPicker({
    required this.label,
    required this.value,
    required this.accountIds,
    required this.onChanged,
    this.compact = false,
  });

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 11),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.walletCards, color: colors.primary, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MT5 Trading account',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: value,
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: colors.surface,
                        icon: Icon(LucideIcons.chevronDown, color: muted, size: 18),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                        items: accountIds.map((id) => DropdownMenuItem(
                          value: id,
                          child: Text('Account #$id', maxLines: 1, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (next) {
                          if (next != null) onChanged(next);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
