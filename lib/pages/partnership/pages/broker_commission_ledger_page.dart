import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_notifications.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _symbolFilter = 'All';

  static final List<IbCommissionTxn> _placeholderTxns = [
    IbCommissionTxn(
      id: 'demo-1',
      clientUser: 'Alexander Wright',
      clientTradingAccount: '883921',
      positionSymbol: 'XAUUSD',
      dealTicket: '1048291',
      orderTicket: '904821',
      volumeLots: 1.50,
      profit: 245.00,
      commission: 18.50,
      createdAt: '2026-04-10T14:22:00Z',
      commissionProfileName: 'VIP Scalpers',
    ),
    IbCommissionTxn(
      id: 'demo-2',
      clientUser: 'Sophia Chen',
      clientTradingAccount: '883995',
      positionSymbol: 'EURUSD',
      dealTicket: '1048292',
      orderTicket: '904822',
      volumeLots: 2.00,
      profit: 180.40,
      commission: 14.00,
      createdAt: '2026-04-10T13:15:00Z',
      commissionProfileName: 'Standard Rebate',
    ),
    IbCommissionTxn(
      id: 'demo-3',
      clientUser: 'Marcus Vance',
      clientTradingAccount: '884102',
      positionSymbol: 'GBPUSD',
      dealTicket: '1048293',
      orderTicket: '904823',
      volumeLots: 0.80,
      profit: 92.10,
      commission: 6.40,
      createdAt: '2026-04-09T19:40:00Z',
      commissionProfileName: 'Standard Rebate',
    ),
    IbCommissionTxn(
      id: 'demo-4',
      clientUser: 'Elena Rostova',
      clientTradingAccount: '884210',
      positionSymbol: 'US30',
      dealTicket: '1048294',
      orderTicket: '904824',
      volumeLots: 1.20,
      profit: 310.00,
      commission: 15.60,
      createdAt: '2026-04-09T16:05:00Z',
      commissionProfileName: 'VIP Scalpers',
    ),
    IbCommissionTxn(
      id: 'demo-5',
      clientUser: 'David Kim',
      clientTradingAccount: '884355',
      positionSymbol: 'BTCUSD',
      dealTicket: '1048295',
      orderTicket: '904825',
      volumeLots: 0.50,
      profit: 128.75,
      commission: 9.25,
      createdAt: '2026-04-08T11:50:00Z',
      commissionProfileName: 'Crypto Influx',
    ),
    IbCommissionTxn(
      id: 'demo-6',
      clientUser: 'Nadia Patel',
      clientTradingAccount: '884490',
      positionSymbol: 'USDJPY',
      dealTicket: '1048296',
      orderTicket: '904826',
      volumeLots: 1.00,
      profit: 74.20,
      commission: 8.00,
      createdAt: '2026-04-08T09:12:00Z',
      commissionProfileName: 'Standard Rebate',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchLedger();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        return t.dealTicket.toLowerCase().contains(q) ||
            t.clientTradingAccount.toLowerCase().contains(q) ||
            t.clientUser.toLowerCase().contains(q) ||
            t.positionSymbol.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final displayTxns = _loading ? _placeholderTxns : filtered;
    final totalComm = displayTxns.fold(0.0, (sum, t) => sum + t.commission);
    final totalLots = displayTxns.fold(0.0, (sum, t) => sum + t.volumeLots);
    final hasActiveFilters = _searchQuery.isNotEmpty || _symbolFilter != 'All';

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Commission Ledger', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    AppHaptics.lightImpact();
                    _fetchLedger();
                  },
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: PartnershipBackdrop(
        colors: colors,
        child: RefreshIndicator(
          color: colors.blue,
          backgroundColor: colors.card,
          onRefresh: _fetchLedger,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        controller: _searchController,
                        style: TextStyle(color: colors.text, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search by deal ticket, account, client or symbol...',
                          hintStyle: TextStyle(color: colors.muted, fontSize: 12),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 14),
                        tooltip: 'Clear search',
                        onPressed: () {
                          AppHaptics.selectionClick();
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
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
                      onTap: () {
                        AppHaptics.selectionClick();
                        setState(() => _symbolFilter = s);
                      },
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
              // Summary banner + Deal rows wrapped in PartnershipSkeletonizer
              PartnershipSkeletonizer(
                colors: colors,
                enabled: _loading,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.subBorder),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            Text('${displayTxns.length} Deals', style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                            Text('Volume: ${totalLots.toStringAsFixed(2)} Lots', style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w800)),
                            Text('Total: \$${totalComm.toStringAsFixed(2)}', style: TextStyle(color: colors.green, fontSize: 13, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (!_loading && filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(LucideIcons.receipt, size: 38, color: colors.muted),
                              const SizedBox(height: 10),
                              Text(
                                'No commission transactions matching filter',
                                style: TextStyle(color: colors.muted, fontSize: 12.5, fontWeight: FontWeight.w700),
                              ),
                              if (hasActiveFilters) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    AppHaptics.selectionClick();
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _symbolFilter = 'All';
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colors.border),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: Icon(LucideIcons.rotateCcw, size: 13, color: colors.text),
                                  label: Text(
                                    'Reset filters',
                                    style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      ...displayTxns.map((txn) => _buildTxnCard(txn, colors)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTxnCard(IbCommissionTxn txn, PartnershipColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _loading ? null : () => _showDealDetailSheet(txn, colors),
          child: Padding(
            padding: const EdgeInsets.all(12),
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
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(String raw) {
    if (raw.trim().isEmpty) return '—';
    final dt = DateTime.tryParse(raw.trim());
    if (dt == null) return raw;
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  void _showDealDetailSheet(IbCommissionTxn txn, PartnershipColors colors) {
    AppHaptics.selectionClick();
    final profitSign = txn.profit < 0 ? '-' : '';
    final profitText = '$profitSign\$${txn.profit.abs().toStringAsFixed(2)}';
    final profitColor = txn.profit >= 0 ? colors.green : colors.red;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.muted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(LucideIcons.receipt, color: colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Commission Deal Detail',
                              style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              '${txn.positionSymbol} · ${txn.clientUser}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colors.muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          AppHaptics.selectionClick();
                          Navigator.of(sheetContext).pop();
                        },
                        icon: Icon(LucideIcons.x, size: 18, color: colors.muted),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.subCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.subBorder),
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          colors,
                          'Deal Ticket',
                          txn.dealTicket.isEmpty ? '—' : '#${txn.dealTicket}',
                          trailing: txn.dealTicket.isEmpty
                              ? null
                              : InkWell(
                                  onTap: () {
                                    AppHaptics.lightImpact();
                                    Clipboard.setData(ClipboardData(text: txn.dealTicket));
                                    showAppMessage(
                                      'Deal ticket copied: ${txn.dealTicket}',
                                      type: AppFeedbackType.success,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(LucideIcons.copy, size: 14, color: colors.blue),
                                  ),
                                ),
                        ),
                        _detailRow(colors, 'Order Ticket', txn.orderTicket.isEmpty ? '—' : '#${txn.orderTicket}'),
                        _detailRow(colors, 'Client', txn.clientUser.isEmpty ? '—' : txn.clientUser),
                        _detailRow(colors, 'Trading Account', txn.clientTradingAccount.isEmpty ? '—' : txn.clientTradingAccount),
                        _detailRow(colors, 'Symbol', txn.positionSymbol.isEmpty ? '—' : txn.positionSymbol),
                        _detailRow(colors, 'Profile', txn.commissionProfileName.isEmpty ? '—' : txn.commissionProfileName),
                        _detailRow(colors, 'Volume Lots', '${txn.volumeLots.toStringAsFixed(2)} Lots'),
                        _detailRow(colors, 'Trade Profit', profitText, valueColor: profitColor),
                        _detailRow(
                          colors,
                          'IB Commission',
                          '+\$${txn.commission.toStringAsFixed(2)}',
                          valueColor: colors.green,
                        ),
                        _detailRow(colors, 'Timestamp', _formatTimestamp(txn.createdAt), isLast: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    PartnershipColors colors,
    String label,
    String value, {
    Color? valueColor,
    Widget? trailing,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: colors.subBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.muted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: valueColor ?? colors.text,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 6),
                  trailing,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
