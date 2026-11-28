import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../app_notifications.dart';
import '../services/auth_api.dart';
import '../widgets/pool_trades_modal.dart';

class MamInvestorLivePositionsPage extends StatefulWidget {
  const MamInvestorLivePositionsPage({
    super.key,
    required this.accountId,
    required this.accountName,
  });

  final String accountId;
  final String accountName;

  @override
  State<MamInvestorLivePositionsPage> createState() =>
      _MamInvestorLivePositionsPageState();
}

class _MamInvestorLivePositionsPageState
    extends State<MamInvestorLivePositionsPage> {
  static const blue = Color(0xFF2459D3);
  static const green = Color(0xFF10B981);
  static const red = Color(0xFFEF476F);

  List<PoolOpenPosition> positions = [];
  bool loading = true;
  String? error;
  Timer? poller;
  bool fetching = false;
  DateTime? lastUpdated;

  bool get dark => Theme.of(context).brightness == Brightness.dark;
  Color get background => dark ? const Color(0xFF08152D) : const Color(0xFFF4F7FB);
  Color get surface => dark ? const Color(0xFF102143) : Colors.white;
  Color get border => dark ? const Color(0xFF203A67) : const Color(0xFFE2EAF4);
  Color get textColor => dark ? const Color(0xFFF3F6FC) : const Color(0xFF14213D);
  Color get muted => dark ? const Color(0xFF9AAAC4) : const Color(0xFF71819B);

  @override
  void initState() {
    super.initState();
    loadPositions();
    poller = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!loading) loadPositions(silent: true);
    });
  }

  @override
  void dispose() {
    poller?.cancel();
    super.dispose();
  }

  double number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
  }

  Future<void> loadPositions({bool silent = false}) async {
    if (fetching) return;
    fetching = true;
    if (!silent && mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }
    try {
      final response = await AuthApi.instance.getPammOpenPositions(
        widget.accountId,
        isManager: false,
      );
      dynamic data = response;
      for (var depth = 0; depth < 5 && data is Map; depth++) {
        final map = data.cast<String, dynamic>();
        final rows = map['positions'] ?? map['results'];
        if (rows is List) {
          data = rows;
          break;
        }
        data = map['data'] ?? map['result'] ?? map['payload'];
      }
      if (data is! List) {
        throw const AuthApiException('Unexpected investor positions response.');
      }
      final loaded = data.whereType<Map>().map((raw) {
        final item = raw.cast<String, dynamic>();
        return PoolOpenPosition(
          ticket: (item['ticket'] ?? item['position'] ?? item['id'] ?? '').toString(),
          symbol: (item['symbol'] ?? 'Unknown symbol').toString(),
          type: (item['type'] ?? item['side'] ?? 'UNKNOWN').toString(),
          volume: number(item['volume']).toStringAsFixed(2),
          openPrice: number(item['open_price'] ?? item['price']).toString(),
          currentPrice: number(item['current_price'] ?? item['price'] ?? item['open_price']).toString(),
          profit: number(item['profit']),
          swap: number(item['swap']).toStringAsFixed(2),
          openTime: (item['open_time'] ?? item['time'] ?? item['created_at'] ?? '').toString(),
          comment: (item['comment'] ?? '').toString(),
        );
      }).toList(growable: false);

      if (!mounted) { fetching = false; return; }
      setState(() {
        positions = loaded;
        loading = false;
        error = null;
        lastUpdated = DateTime.now();
      });
      fetching = false;
    } catch (e) {
      fetching = false;
      if (!mounted) return;
      setState(() {
        loading = false;
        if (!silent || positions.isEmpty) {
          error = e is AuthApiException ? e.message : 'Unable to load investor positions.';
        }
      });
    }
  }

  double get floating => positions.fold(0, (sum, item) => sum + item.profit);
  double get volume => positions.fold(0, (sum, item) => sum + number(item.volume));
  int get buys => positions.where((item) => item.isBuy).length;
  int get sells => positions.length - buys;

  String get updatedLabel {
    final value = lastUpdated;
    if (value == null) return 'Waiting for first update';
    final h = value.hour.toString().padLeft(2, '0');
    final m = value.minute.toString().padLeft(2, '0');
    final sec = value.second.toString().padLeft(2, '0');
    return 'Updated $h:$m:$sec';
  }

  String cash(double value) =>
      (value >= 0 ? '+' : '-') + r'$' + value.abs().toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(LucideIcons.arrowLeft, color: textColor),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Position Monitor',
              style: GoogleFonts.inter(color: textColor, fontSize: 16, fontWeight: FontWeight.w800)),
            Text('${widget.accountName} · ${widget.accountId}',
              style: GoogleFonts.inter(color: muted, fontSize: 10)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: loading
                ? null
                : () {
                    AppHaptics.selectionClick();
                    loadPositions();
                  },
            icon: Icon(LucideIcons.refreshCw, color: muted, size: 19),
            tooltip: 'Refresh positions',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: surface,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: green, shape: BoxShape.circle)),
                  const SizedBox(width: 7),
                  Text('LIVE FEED',
                    style: GoogleFonts.inter(color: green, fontSize: 10,
                      fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                  const Spacer(),
                  Text(updatedLabel, style: GoogleFonts.inter(color: muted, fontSize: 10)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadPositions,
                color: blue,
                child: loading && positions.isEmpty
                    ? _positionsLoadingSkeleton()
                    : error != null && positions.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.55,
                                child: messageState(LucideIcons.alertCircle,
                                  'Unable to load positions', error!, retry: true),
                              ),
                            ],
                          )
                        : CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      summaryGrid(),
                                      const SizedBox(height: 16),
                                      Row(children: [
                                        Text('OPEN POSITIONS',
                                          style: GoogleFonts.inter(color: muted, fontSize: 10,
                                            fontWeight: FontWeight.w900, letterSpacing: 0.7)),
                                        const Spacer(),
                                        Text('${positions.length} positions',
                                          style: GoogleFonts.inter(color: muted, fontSize: 10)),
                                      ]),
                                      const SizedBox(height: 9),
                                      if (positions.isEmpty)
                                        SizedBox(height: 280,
                                          child: messageState(LucideIcons.layers,
                                            'No Active Open Positions',
                                            'There are currently no open trades for this investor account.')),
                                    ],
                                  ),
                                ),
                              ),
                              if (positions.isNotEmpty)
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                                  sliver: SliverList.builder(
                                    itemCount: positions.length,
                                    itemBuilder: (context, index) => positionCard(positions[index]),
                                  ),
                                ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _positionsLoadingSkeleton() {
    return AppSkeletonizer(
      enabled: true,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
        children: [
          summaryGrid(),
          const SizedBox(height: 16),
          Text(
            'OPEN POSITIONS',
            style: GoogleFonts.inter(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 9),
          for (var index = 0; index < 3; index++) ...[
            _positionLoadingCard(),
            if (index < 2) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _positionLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('EURUSD')),
              Text('BUY'),
              SizedBox(width: 8),
              Text('+\$0.00'),
            ],
          ),
          SizedBox(height: 6),
          Text('Ticket 000000'),
          SizedBox(height: 12),
          Row(
            children: [
              detail('VOLUME', '0.00 lots'),
              detail('OPEN PRICE', '0.0000'),
              detail('CURRENT PRICE', '0.0000'),
            ],
          ),
        ],
      ),
    );
  }

  Widget summaryGrid() {
    final metrics = <(String, String, Color)>[
      ('FLOATING P/L', cash(floating), floating >= 0 ? green : red),
      ('TOTAL VOLUME', '${volume.toStringAsFixed(2)} Lots', blue),
      ('OPEN ORDERS', '${positions.length} Positions', textColor),
      ('ORDER TYPES', '$buys BUY · $sells SELL', muted),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surface, borderRadius: BorderRadius.circular(13),
            border: Border.all(color: border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(metric.$1, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: muted, fontSize: 9, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(metric.$2, maxLines: 1,
                  style: GoogleFonts.inter(color: metric.$3, fontSize: 14, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget positionCard(PoolOpenPosition position) {
    final side = position.isBuy ? blue : red;
    final pnl = position.isProfit ? green : red;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(position.symbol, maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w900))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(color: side.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20)),
              child: Text(position.type.toUpperCase(),
                style: GoogleFonts.inter(color: side, fontSize: 9, fontWeight: FontWeight.w900))),
            const SizedBox(width: 8),
            Text(cash(position.profit),
              style: GoogleFonts.inter(color: pnl, fontSize: 13, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 5),
          Text('Ticket ${position.ticket}',
            style: GoogleFonts.inter(color: muted, fontSize: 10)),
          const SizedBox(height: 12),
          Row(children: [
            detail('VOLUME', '${position.volume} lots'),
            detail('OPEN PRICE', position.openPrice),
            detail('CURRENT PRICE', position.currentPrice, color: blue),
          ]),
          const SizedBox(height: 10),
          Divider(height: 1, color: border),
          const SizedBox(height: 9),
          Row(children: [
            detail('SWAP', position.swap),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('OPEN TIME', style: GoogleFonts.inter(
                  color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(position.openTime.isEmpty ? '—' : position.openTime,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(color: textColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            )),
          ]),
          if (position.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(position.comment, style: GoogleFonts.inter(color: muted, fontSize: 10)),
          ],
        ],
      ),
    );
  }

  Widget detail(String label, String value, {Color? color}) {
    return Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(color: muted, fontSize: 8, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(color: color ?? textColor, fontSize: 10, fontWeight: FontWeight.w800)),
      ],
    ));
  }

  Widget messageState(IconData icon, String title, String message, {bool retry = false}) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 38, color: muted),
        const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: textColor, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: muted, fontSize: 11, height: 1.4)),
        if (retry) ...[
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: loadPositions,
            icon: const Icon(LucideIcons.refreshCw, size: 15), label: const Text('Retry')),
        ],
      ]),
    ));
  }
}
