import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/services/auth_api.dart';

class PoolOpenPosition {
  const PoolOpenPosition({
    required this.ticket,
    required this.symbol,
    required this.type,
    required this.volume,
    required this.openPrice,
    required this.currentPrice,
    required this.profit,
    this.swap = '0.00',
    this.openTime = '',
    this.comment = '',
  });

  final String ticket;
  final String symbol;
  final String type;
  final String volume;
  final String openPrice;
  final String currentPrice;
  final double profit;
  final String swap;
  final String openTime;
  final String comment;

  bool get isBuy => type.toUpperCase().contains('BUY');
  bool get isProfit => profit >= 0;
}

class PoolTradesModal extends StatefulWidget {
  const PoolTradesModal({
    super.key,
    required this.poolLogin,
    this.poolName,
    this.isManager = true,
    this.initialPositions,
  });

  final String poolLogin;
  final String? poolName;
  final bool isManager;
  final List<PoolOpenPosition>? initialPositions;

  static Future<void> show(
    BuildContext context, {
    required String poolLogin,
    String? poolName,
    bool isManager = true,
    List<PoolOpenPosition>? initialPositions,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => PoolTradesModal(
        poolLogin: poolLogin,
        poolName: poolName,
        isManager: isManager,
        initialPositions: initialPositions,
      ),
    );
  }

  @override
  State<PoolTradesModal> createState() => _PoolTradesModalState();
}

class _PoolTradesModalState extends State<PoolTradesModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _loading = false;
  late List<PoolOpenPosition> _positions;
  String? _error;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  Color get _bg => _dark ? const Color(0xFF0C1833) : Colors.white;
  Color get _subBg => _dark ? const Color(0xFF07142A) : const Color(0xFFF8FAFC);
  Color get _cardBg => _dark ? const Color(0xFF132244) : const Color(0xFFFFFFFF);
  Color get _border => _dark ? const Color(0xFF1E3563) : const Color(0xFFE2E8F0);
  Color get _text => _dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  Color get _muted => _dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static const _blue = Color(0xFF365CEB);
  static const _green = Color(0xFF10B981);
  static const _rose = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _positions = widget.initialPositions ?? [];
    _refreshPositions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _refreshPositions() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final response = await AuthApi.instance.getPammOpenPositions(
        widget.poolLogin,
        isManager: widget.isManager,
      );
      dynamic data = response;
      for (var depth = 0; depth < 5 && data is Map; depth++) {
        final map = data.cast<String, dynamic>();
        final positions = map['positions'] ?? map['results'];
        if (positions is List) {
          data = positions;
          break;
        }
        data = map['data'] ?? map['result'] ?? map['payload'];
      }
      if (data is! List) {
        throw const AuthApiException('The server returned an unexpected positions response.');
      }
      final positions = data.whereType<Map>().map((raw) {
        final item = raw.cast<String, dynamic>();
        double number(Object? value) {
          if (value is num) return value.toDouble();
          return double.tryParse(value?.toString().replaceAll(',', '') ?? '') ?? 0;
        }
        return PoolOpenPosition(
          ticket: (item['ticket'] ?? item['position'] ?? item['id'] ?? '').toString(),
          symbol: (item['symbol'] ?? 'Unknown symbol').toString(),
          type: (item['type'] ?? item['side'] ?? '').toString(),
          volume: number(item['volume']).toStringAsFixed(2),
          openPrice: number(item['open_price'] ?? item['price']).toString(),
          currentPrice: number(item['current_price'] ?? item['price'] ?? item['open_price']).toString(),
          profit: number(item['profit']),
          swap: number(item['swap']).toStringAsFixed(2),
          openTime: (item['open_time'] ?? item['time'] ?? item['created_at'] ?? '').toString(),
          comment: (item['comment'] ?? '').toString(),
        );
      }).toList(growable: false);
      if (!mounted) return;
      setState(() { _positions = positions; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is AuthApiException
            ? error.message
            : 'Unable to load open positions. Please try again.';
      });
    }
  }

  double get _totalProfit =>
      _positions.fold(0.0, (sum, p) => sum + p.profit);

  double get _totalVolume =>
      _positions.fold(0.0, (sum, p) => sum + (double.tryParse(p.volume) ?? 0.0));

  int get _buyCount =>
      _positions.where((p) => p.isBuy).length;

  int get _sellCount =>
      _positions.where((p) => !p.isBuy).length;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxHeight = mq.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: _muted.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A3A8C), Color(0xFF2155C4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            LucideIcons.activity,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Live Open Positions',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _green.withValues(
                                    alpha: 0.12 + (_pulseController.value * 0.08),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _green.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _green,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: _green.withValues(
                                              alpha: _pulseController.value * 0.8,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'LIVE FEED',
                                      style: GoogleFonts.inter(
                                        color: _green,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'MT5 execution for ${widget.poolName != null ? '${widget.poolName} · ' : ''}Account ${widget.poolLogin}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _muted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh positions',
                  onPressed: _loading ? null : _refreshPositions,
                  icon: Icon(
                    LucideIcons.refreshCw,
                    color: _muted,
                    size: 18,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    LucideIcons.x,
                    color: _muted,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Quick KPI Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _subBg,
              border: Border(
                top: BorderSide(color: _border),
                bottom: BorderSide(color: _border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    title: 'FLOATING P/L',
                    value:
                        '${_totalProfit >= 0 ? '+' : ''}\$${_totalProfit.toStringAsFixed(2)}',
                    color: _totalProfit >= 0 ? _green : _rose,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _kpiCard(
                    title: 'TOTAL VOLUME',
                    value: '${_totalVolume.toStringAsFixed(2)} Lots',
                    color: _blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _kpiCard(
                    title: 'OPEN ORDERS',
                    value: '${_positions.length} Positions',
                    color: _text,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _kpiCard(
                    title: 'ORDER TYPES',
                    value: '$_buyCount BUY • $_sellCount SELL',
                    color: _muted,
                    customChild: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_buyCount BUY',
                            style: GoogleFonts.inter(
                              color: _blue,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(color: _muted, fontSize: 11),
                          ),
                          Text(
                            '$_sellCount SELL',
                            style: GoogleFonts.inter(
                              color: _rose,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Positions List / Empty State
          Expanded(
            child: _loading && _positions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _positions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: _muted)),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                onPressed: _loading ? null : _refreshPositions,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _positions.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    itemCount: _positions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildPositionCard(_positions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required Color color,
    Widget? customChild,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: _muted,
              letterSpacing: 0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: customChild ??
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(PoolOpenPosition pos) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Symbol, Ticket, BUY/SELL, Floating PnL
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _blue.withValues(alpha: 0.25)),
                ),
                child: Text(
                  pos.symbol,
                  style: GoogleFonts.inter(
                    color: _blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _subBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${pos.ticket}',
                  style: GoogleFonts.jetBrainsMono(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: (pos.isBuy ? _blue : _rose).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (pos.isBuy ? _blue : _rose).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      pos.isBuy
                          ? LucideIcons.arrowUpRight
                          : LucideIcons.arrowDownLeft,
                      size: 11,
                      color: pos.isBuy ? _blue : _rose,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      pos.type,
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: pos.isBuy ? _blue : _rose,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (pos.isProfit ? _green : _rose).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (pos.isProfit ? _green : _rose).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${pos.profit >= 0 ? '+' : ''}\$${pos.profit.toStringAsFixed(2)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: pos.isProfit ? _green : _rose,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Volume, Open price, Current price
          Row(
            children: [
              _tradeDetailItem('Lots', '${pos.volume} lot'),
              _tradeDetailItem('Entry Price', pos.openPrice),
              _tradeDetailItem('Mark Price', pos.currentPrice, isHighlighted: true),
              _tradeDetailItem('Swap', pos.swap),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Open Time & Comment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 11, color: _muted),
                  const SizedBox(width: 4),
                  Text(
                    pos.openTime,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: _muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (pos.comment.isNotEmpty && pos.comment != '—')
                Text(
                  pos.comment,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: _muted.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tradeDetailItem(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: _muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isHighlighted ? _blue : _text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _subBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.layers,
                  size: 26,
                  color: _muted,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Active Open Positions',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'There are currently no live open positions for MT5 account ${widget.poolLogin}. Any executed pool orders will display here automatically in real time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: _muted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
