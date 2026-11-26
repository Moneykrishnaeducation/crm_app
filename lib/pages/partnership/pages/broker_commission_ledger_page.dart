import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../services/auth_api.dart';
import '../models/partnership_models.dart';
import '../widgets/partnership_theme.dart';

// ============================================================================
// SUB-PAGE: BROKERCOMMISSIONLEDGERPAGE (COMMISSION LEDGER)
// ============================================================================

class BrokerCommissionLedgerPage extends StatefulWidget {
  const BrokerCommissionLedgerPage({super.key});

  @override
  State<BrokerCommissionLedgerPage> createState() => _BrokerCommissionLedgerPageState();
}

class _BrokerCommissionLedgerPageState extends State<BrokerCommissionLedgerPage> {
  bool _loading = true;
  List<IbCommissionTxn> _txns = [];
  String _searchQuery = '';
  String _symbolFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchLedger();
  }

  Future<void> _fetchLedger() async {
    setState(() => _loading = true);
    try {
      final res = await AuthApi.instance.getIbCommissionTransactions();
      final rawList = res['results'] ?? res['data'] ?? res['transactions'];
      final parsed = <IbCommissionTxn>[];
      if (rawList is List) {
        for (final item in rawList.whereType<Map>()) {
          parsed.add(IbCommissionTxn.fromJson(item.cast<String, dynamic>()));
        }
      }
      if (mounted) {
        setState(() {
          _txns = parsed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final symbols = {
      'All',
      ..._txns.map((t) => t.positionSymbol).where((s) => s.isNotEmpty && s != '—'),
    }.toList();

    final filtered = _txns.where((t) {
      if (_symbolFilter != 'All' && t.positionSymbol != _symbolFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return t.dealTicket.contains(q) ||
            t.clientTradingAccount.contains(q) ||
            t.clientUser.toLowerCase().contains(q) ||
            t.positionSymbol.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final totalComm = filtered.fold(0.0, (sum, t) => sum + t.commission);
    final totalLots = filtered.fold(0.0, (sum, t) => sum + t.volumeLots);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Commission Ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _fetchLedger,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: PartnershipBackdrop(
        colors: colors,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
          children: [
            // Search box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.search, size: 16, color: colors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: colors.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by deal ticket, account, client or symbol...',
                        hintStyle: TextStyle(color: colors.muted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Symbols row
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: symbols.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final s = symbols[i];
                  final isSelected = _symbolFilter == s;
                  return InkWell(
                    onTap: () => setState(() => _symbolFilter = s),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.blue : colors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? colors.blue : colors.border),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colors.text,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            // Summary banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.subCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.subBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${filtered.length} Deals', style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('Volume: ${totalLots.toStringAsFixed(2)} Lots', style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w800)),
                  Text('Total: \$${totalComm.toStringAsFixed(2)}', style: TextStyle(color: colors.green, fontSize: 13, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: colors.blue)),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No commission transactions matching filter',
                    style: TextStyle(color: colors.muted, fontSize: 12.5),
                  ),
                ),
              )
            else
              ...filtered.map((txn) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(LucideIcons.receipt, color: colors.blue, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${txn.positionSymbol} · Deal #${txn.dealTicket}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: colors.text, fontSize: 12.5, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Acc: ${txn.clientTradingAccount} · ${txn.clientUser}',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+\$${txn.commission.toStringAsFixed(2)}',
                            style: TextStyle(color: colors.green, fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${txn.volumeLots.toStringAsFixed(2)} Lots',
                            style: TextStyle(color: colors.muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
