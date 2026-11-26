import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../services/auth_api.dart';
import '../models/partnership_models.dart';
import 'partnership_theme.dart';

// ============================================================================
// ACCOUNT DETAIL SHEET WITH LIVE POSITIONS
// ============================================================================

class AccountDetailSheet extends StatefulWidget {
  const AccountDetailSheet({
    super.key,
    required this.account,
    this.clientName,
    required this.colors,
  });

  final IbTradingAccount account;
  final String? clientName;
  final PartnershipColors colors;

  @override
  State<AccountDetailSheet> createState() => _AccountDetailSheetState();
}

class _AccountDetailSheetState extends State<AccountDetailSheet> {
  bool _loading = true;
  Map<String, dynamic> _details = {};
  List<Map<String, dynamic>> _positions = [];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AuthApi.instance.getAccountDetails(widget.account.accountId).catchError((_) => <String, dynamic>{}),
        AuthApi.instance.getOpenPositions(widget.account.accountId).catchError((_) => <Map<String, dynamic>>[]),
      ]);
      if (mounted) {
        setState(() {
          _details = results[0] as Map<String, dynamic>;
          _positions = results[1] as List<Map<String, dynamic>>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final balance = _details['balance']?.toString() ?? '0.00';
    final equity = _details['equity']?.toString() ?? '0.00';
    final margin = _details['margin']?.toString() ?? '0.00';
    final profit = _details['profit']?.toString() ?? '0.00';
    final profitNum = double.tryParse(profit) ?? 0.0;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Account ${widget.account.accountId}',
                            style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'MT5 Connected',
                              style: TextStyle(color: colors.green, fontSize: 9.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      if (widget.clientName != null)
                        Text('Client: ${widget.clientName}', style: TextStyle(color: colors.muted, fontSize: 11.5)),
                    ],
                  ),
                  IconButton(
                    onPressed: _loading ? null : _fetchDetails,
                    icon: _loading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: colors.blue),
                          )
                        : Icon(LucideIcons.refreshCw, color: colors.muted, size: 18),
                  ),
                ],
              ),
            ),
            // Metrics row: Balance, Equity, Margin, Floating P/L
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _metricBox(colors, 'Balance', '\$$balance', colors.text),
                  const SizedBox(width: 8),
                  _metricBox(colors, 'Equity', '\$$equity', colors.blue),
                  const SizedBox(width: 8),
                  _metricBox(colors, 'Margin', '\$$margin', colors.muted),
                  const SizedBox(width: 8),
                  _metricBox(colors, 'Floating P/L', '\$$profit', profitNum >= 0 ? colors.green : colors.red),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Divider(color: colors.border, height: 1),
            // Open Positions List
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Open Positions (${_positions.length})',
                    style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  Text('Real-time snapshot', style: TextStyle(color: colors.muted, fontSize: 10.5)),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Center(child: CircularProgressIndicator(color: colors.blue))
                  : _positions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.activity, size: 32, color: colors.muted),
                              const SizedBox(height: 8),
                              Text(
                                'No open positions on this account',
                                style: TextStyle(color: colors.muted, fontSize: 12.5),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _positions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final pos = _positions[index];
                            final sym = (pos['symbol'] ?? '—').toString();
                            final type = (pos['type'] ?? 'BUY').toString();
                            final isBuy = type.toUpperCase().contains('BUY');
                            final vol = pos['volume']?.toString() ?? '0.01';
                            final openPrice = pos['open_price']?.toString() ?? '0.00';
                            final curPrice = pos['current_price']?.toString() ?? '0.00';
                            final pnl = (pos['profit'] as num?)?.toDouble() ?? 0.0;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.subCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.subBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isBuy
                                                ? colors.green.withValues(alpha: 0.15)
                                                : colors.red.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isBuy ? 'BUY' : 'SELL',
                                            style: TextStyle(
                                              color: isBuy ? colors.green : colors.red,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sym,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800),
                                              ),
                                              Text(
                                                '$vol Lots · Open: $openPrice · Current: $curPrice',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(color: colors.muted, fontSize: 10.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${pnl >= 0 ? '+' : ''}\$${pnl.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: pnl >= 0 ? colors.green : colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricBox(PartnershipColors colors, String label, String value, Color valColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: colors.subCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.subBorder),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: colors.muted, fontSize: 9)),
            const SizedBox(height: 2),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: valColor, fontSize: 11.5, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
