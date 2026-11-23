import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../app_notifications.dart';
import '../pages/funds_action_dialog.dart';

// -----------------------------------------------------------------------------
// MAM MASTER ACCOUNT DATA MODEL
// -----------------------------------------------------------------------------
class MamMasterAccount {
  MamMasterAccount({
    required this.name,
    required this.login,
    required this.profitShare,
    required this.leverage,
    required this.balance,
    required this.status,
    required this.risk,
    required this.payout,
    this.allocationMethod = 'Lot Proportional',
    this.investorsCount = 0,
    this.totalAum = 0.0,
    this.monthlyGain = 0.0,
    this.server = 'VTindex-MT5',
    this.tradingPlatform = 'MetaTrader 5 (MT5)',
    this.algoTrading = 'Manual',
    this.pendingRelease = 4.03,
    this.releasedPayout = 0.00,
    this.pendingWallet = 0.00,
    this.totalSettled = 0.00,
    this.tradesProcessed = 0,
  });

  String name;
  String login;
  double profitShare;
  String leverage;
  double balance;
  String status; // 'Active', 'Paused', 'Disabled'
  String risk;
  String payout;
  String allocationMethod;
  int investorsCount;
  double totalAum;
  double monthlyGain;
  String server;
  String tradingPlatform;
  String algoTrading;
  double pendingRelease;
  double releasedPayout;
  double pendingWallet;
  double totalSettled;
  int tradesProcessed;
}

// -----------------------------------------------------------------------------
// THEME COLORS HELPER FOR WORKSPACE
// -----------------------------------------------------------------------------
class MamWorkspaceColors {
  const MamWorkspaceColors({
    required this.isDark,
    required this.card,
    required this.subCard,
    required this.border,
    required this.subBorder,
    required this.text,
    required this.muted,
    required this.blue,
    required this.blueLight,
    required this.blueBorder,
    required this.green,
    required this.greenLight,
    required this.greenBorder,
    required this.red,
    required this.redLight,
    required this.redBorder,
    required this.gold,
    required this.goldLight,
    required this.goldBorder,
    required this.navy,
  });

  final bool isDark;
  final Color card;
  final Color subCard;
  final Color border;
  final Color subBorder;
  final Color text;
  final Color muted;
  final Color blue;
  final Color blueLight;
  final Color blueBorder;
  final Color green;
  final Color greenLight;
  final Color greenBorder;
  final Color red;
  final Color redLight;
  final Color redBorder;
  final Color gold;
  final Color goldLight;
  final Color goldBorder;
  final Color navy;

  factory MamWorkspaceColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return MamWorkspaceColors(
      isDark: isDark,
      card: isDark ? const Color(0xFF17243A) : Colors.white,
      subCard: isDark ? const Color(0xFF101D31) : const Color(0xFFF8FAFC),
      border: isDark ? const Color(0xFF263750) : const Color(0xFFE2E8F0),
      subBorder: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEDF2F7),
      text: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      muted: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      blue: const Color(0xFF2563EB),
      blueLight: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEFF6FF),
      blueBorder: isDark
          ? const Color(0xFF2563EB).withValues(alpha: 0.35)
          : const Color(0xFFBFDBFE),
      green: const Color(0xFF10B981),
      greenLight: isDark ? const Color(0xFF132D28) : const Color(0xFFECFDF5),
      greenBorder: isDark
          ? const Color(0xFF10B981).withValues(alpha: 0.35)
          : const Color(0xFFA7F3D0),
      red: const Color(0xFFEF4444),
      redLight: isDark ? const Color(0xFF3B2028) : const Color(0xFFFEF2F2),
      redBorder: isDark
          ? const Color(0xFFEF4444).withValues(alpha: 0.35)
          : const Color(0xFFFECACA),
      gold: const Color(0xFFF59E0B),
      goldLight: isDark ? const Color(0xFF2D2619) : const Color(0xFFFEFCE8),
      goldBorder: isDark
          ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
          : const Color(0xFFFEF08A),
      navy: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF10264A),
    );
  }
}

// -----------------------------------------------------------------------------
// MASTER NODE DETAILS & MANAGEMENT WORKSPACE
// -----------------------------------------------------------------------------
class MamMasterNodeWorkspace extends StatefulWidget {
  const MamMasterNodeWorkspace({
    super.key,
    required this.master,
    required this.onBack,
    this.onUpdate,
  });

  final MamMasterAccount master;
  final VoidCallback onBack;
  final ValueChanged<MamMasterAccount>? onUpdate;

  @override
  State<MamMasterNodeWorkspace> createState() => _MamMasterNodeWorkspaceState();
}

class _MamMasterNodeWorkspaceState extends State<MamMasterNodeWorkspace> {
  late MamMasterAccount _master;

  @override
  void initState() {
    super.initState();
    _master = widget.master;
  }

  void _notifyUpdate() {
    setState(() {});
    widget.onUpdate?.call(_master);
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showAppMessage('$label copied to clipboard');
  }

  void _toggleNodeStatus() {
    final wasActive = _master.status == 'Active';
    setState(() {
      _master.status = wasActive ? 'Paused' : 'Active';
    });
    _notifyUpdate();
    showAppMessage(
      wasActive
          ? 'Master Node #${_master.login} Paused'
          : 'Master Node #${_master.login} Activated successfully',
    );
  }

  // ---------------------------------------------------------------------------
  // INTERACTIVE MODALS
  // ---------------------------------------------------------------------------
  void _openDepositSheet(MamWorkspaceColors c) {
    showFundsActionDialog(
      context,
      withdrawal: false,
      accountId: _master.login,
      accountLabel: '${_master.name} · Master #${_master.login}',
      onCompleted: (amt) {
        setState(() {
          _master.balance += amt;
        });
        widget.onUpdate?.call(_master);
      },
    );
  }

  void _openQuickFundSheet(MamWorkspaceColors c) => _openDepositSheet(c);

  void _openWithdrawSheet(MamWorkspaceColors c) {
    showFundsActionDialog(
      context,
      withdrawal: true,
      accountId: _master.login,
      accountLabel: '${_master.name} · Master #${_master.login}',
      onCompleted: (amt) {
        setState(() {
          _master.balance = (_master.balance - amt).clamp(0.0, double.infinity);
        });
        widget.onUpdate?.call(_master);
      },
    );
  }

  void _openSecuritySettingsSheet(MamWorkspaceColors c) {
    bool obscureInvestor = true;
    final investorPwdCtrl = TextEditingController(text: 'ReadOnly*Inv#99');
    final authKeyCtrl = TextEditingController(text: 'VTX-MT5-SEC-991204');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: c.border),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: c.muted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Master Security & Settings',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage investor read-only keys and MT5 credentials.',
                      style: TextStyle(fontSize: 12, color: c.muted),
                    ),
                    const SizedBox(height: 16),

                    // Investor Read-Only Password
                    Text(
                      'INVESTOR READ-ONLY PASSWORD',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: c.muted),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: investorPwdCtrl,
                      obscureText: obscureInvestor,
                      style: GoogleFonts.inter(fontSize: 14, color: c.text),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: c.subCard,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureInvestor ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: c.muted,
                          ),
                          onPressed: () => setModalState(() => obscureInvestor = !obscureInvestor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: c.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // MT5 Auth Token
                    Text(
                      'MT5 SERVER AUTH TOKEN',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: c.muted),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: authKeyCtrl,
                      readOnly: true,
                      style: GoogleFonts.inter(fontSize: 13, color: c.text),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: c.subCard,
                        suffixIcon: IconButton(
                          icon: Icon(LucideIcons.copy, size: 18, color: c.blue),
                          onPressed: () => _copyToClipboard(authKeyCtrl.text, 'MT5 Auth Token'),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: c.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          showAppMessage('Investor Security & Keys updated successfully');
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: c.navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Save Credentials & Sync MT5',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openLiveTradesSheet(MamWorkspaceColors c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final positions = [
          {'sym': 'EURUSD', 'type': 'BUY', 'lot': '1.00', 'open': '1.08520', 'pnl': '+\$180.00', 'pos': true},
          {'sym': 'GBPUSD', 'type': 'SELL', 'lot': '0.50', 'open': '1.29410', 'pnl': '+\$92.50', 'pos': true},
          {'sym': 'XAUUSD', 'type': 'BUY', 'lot': '0.20', 'open': '2650.30', 'pnl': '+\$70.00', 'pos': true},
          {'sym': 'USDJPY', 'type': 'SELL', 'lot': '0.30', 'open': '154.200', 'pnl': '-\$24.00', 'pos': false},
        ];

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Trades & Exposure',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      ),
                      Text(
                        'MT5 Node #${_master.login} • Real-time Stream',
                        style: TextStyle(fontSize: 12, color: c.muted),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Net PnL Header Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.greenLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.greenBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.trendingUp, size: 18, color: c.green),
                        const SizedBox(width: 8),
                        Text(
                          'Floating PnL',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.green,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '+\$318.50 USD',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: c.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'OPEN ORDERS (${positions.length})',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: c.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              ...positions.map((pos) {
                final isBuy = pos['type'] == 'BUY';
                final isPositive = pos['pos'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.subCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.subBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: isBuy ? c.blueLight : c.redLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              pos['type'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isBuy ? c.blue : c.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pos['sym'] as String,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: c.text,
                                ),
                              ),
                              Text(
                                '${pos['lot']} lots @ ${pos['open']}',
                                style: TextStyle(fontSize: 11, color: c.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        pos['pnl'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isPositive ? c.green : c.red,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showAppMessage('Orders list refreshed from MT5 Gateway');
                  },
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Refresh Orders', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: c.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openManageInvestorsSheet(MamWorkspaceColors c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final investors = [
          {'id': 'INV-90214', 'equity': '\$18,400.00', 'share': '22.4%', 'status': 'Connected'},
          {'id': 'INV-77182', 'equity': '\$12,500.00', 'share': '15.2%', 'status': 'Connected'},
          {'id': 'INV-65419', 'equity': '\$9,800.00', 'share': '11.9%', 'status': 'Connected'},
          {'id': 'INV-55102', 'equity': '\$6,200.00', 'share': '7.5%', 'status': 'Connected'},
        ];

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Investor Sub-Accounts',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      ),
                      Text(
                        'Connected Capital & Copy Multiplexers',
                        style: TextStyle(fontSize: 12, color: c.muted),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.subCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.subBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Pool Equity', style: TextStyle(color: c.muted, fontSize: 11)),
                        Text(
                          '\$${_master.totalAum > 0 ? _master.totalAum.toStringAsFixed(2) : "482,500.00"}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Allocation Method', style: TextStyle(color: c.muted, fontSize: 11)),
                        Text(
                          _master.allocationMethod,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'CONNECTED SUB-ACCOUNTS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: c.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              ...investors.map((inv) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: c.subCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.subBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.userCheck, size: 16, color: c.green),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inv['id']!,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: c.text,
                                ),
                              ),
                              Text(
                                'Allocation: ${inv['share']}',
                                style: TextStyle(fontSize: 11, color: c.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        inv['equity']!,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    showAppMessage('Investor invite link generated & copied to clipboard');
                  },
                  icon: const Icon(LucideIcons.userPlus, size: 16),
                  label: const Text('Invite / Connect New Investor', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _triggerSettlementDialog(MamWorkspaceColors c) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: c.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Icon(LucideIcons.zap, color: c.blue, size: 22),
              const SizedBox(width: 8),
              Text(
                'Trigger Settlement',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: c.text,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Execute weekly performance fee distribution for node #${_master.login}.',
                style: TextStyle(color: c.muted, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: c.subCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.subBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Accrued Gross Profit', style: TextStyle(fontSize: 12, color: c.muted)),
                        Text('\$810.00', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: c.text)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Profit Share (${_master.profitShare.toStringAsFixed(0)}%)',
                            style: TextStyle(fontSize: 12, color: c.muted)),
                        Text(
                          '+\$324.00',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: c.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cycle Status', style: TextStyle(fontSize: 12, color: c.muted)),
                        Text('Ready to settle', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: c.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: TextStyle(color: c.muted)),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _master.totalSettled += 324.00;
                  _master.tradesProcessed += 14;
                  _master.pendingRelease = 0.00;
                  _master.releasedPayout += 324.00;
                });
                _notifyUpdate();
                showAppMessage(
                  'Profit share settlement of \$324.00 successfully distributed and added to settled wallet!',
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: c.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Execute Now', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _openPerformanceSheet(MamWorkspaceColors c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Node Performance Stats',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2x2 Grid of Performance Metrics
              Row(
                children: [
                  Expanded(
                    child: _statBox(c, 'Monthly ROI', '+${_master.monthlyGain > 0 ? _master.monthlyGain.toStringAsFixed(1) : "14.8"}%', c.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(c, 'Win Rate', '78.4%', c.blue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _statBox(c, 'Max Drawdown', '6.2%', c.gold),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _statBox(c, 'Profit Factor', '2.34', c.text),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statBox(MamWorkspaceColors c, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.subCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.subBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: c.muted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final c = MamWorkspaceColors.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 90),
              children: [
                // 1. Navigation & Header
                _buildHeader(c),
                const SizedBox(height: 12),

                // 2. Hero Balance & Action Card
                _buildHeroBalanceCard(c),
                const SizedBox(height: 14),

                // 3. Card 1: Master Specifications
                _buildSpecificationsCard(c),
                const SizedBox(height: 14),

                // 4. Card 2: Security & Credentials
                _buildSecurityCard(c),
                const SizedBox(height: 14),

                // 5. Card 3: Live Orders & Controls
                _buildLiveOrdersCard(c),
                const SizedBox(height: 14),

                // 6. Card 4: Profit Share Wallet & Settlements
                _buildProfitWalletCard(c),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. NAVIGATION & HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(MamWorkspaceColors c) {
    final isActive = _master.status == 'Active';
    final statusColor = isActive ? c.green : c.red;
    final statusBg = isActive ? c.greenLight : c.redLight;
    final statusBorder = isActive ? c.greenBorder : c.redBorder;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Right-side Status Badge
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: statusBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: statusBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Node Status:',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: c.muted,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isActive ? 'Active' : 'Disabled / Paused',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. HERO BALANCE & ACTION CARD
  // ---------------------------------------------------------------------------
  Widget _buildHeroBalanceCard(MamWorkspaceColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.card,
            c.isDark ? const Color(0xFF142138) : const Color(0xFFF9FBFF),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: c.isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.blueLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.blueBorder),
                ),
                child: Text(
                  _master.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: c.blue,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _copyToClipboard(_master.login, 'Master Login ID'),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'ID: ${_master.login}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c.muted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.copy, size: 14, color: c.muted),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // NET AVAILABLE BALANCE DISPLAY
          Text(
            'NET AVAILABLE BALANCE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.muted,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_master.balance.toStringAsFixed(2)} USD',
            style: GoogleFonts.inter(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: c.text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons: 2x2 Mobile-Friendly Grid
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: () => _openDepositSheet(c),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: Text(
                      'Quick Fund',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => _openWithdrawSheet(c),
                    icon: Icon(LucideIcons.arrowUpRight, size: 16, color: c.text),
                    label: Text(
                      'Withdraw',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: c.text),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => _openPerformanceSheet(c),
                    icon: Icon(LucideIcons.barChart2, size: 16, color: c.text),
                    label: Text(
                      'Performance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: c.text),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => _openManageInvestorsSheet(c),
                    icon: Icon(LucideIcons.users, size: 16, color: c.text),
                    label: Text(
                      'Investor Pool',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: c.text),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Metrics Grid (2x3 Layout)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.subCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.subBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _metricCell(
                        'PENDING RELEASE',
                        '\$${_master.pendingRelease.toStringAsFixed(2)}',
                        valueColor: c.blue,
                      ),
                    ),
                    Container(width: 1, height: 32, color: c.subBorder),
                    Expanded(
                      child: _metricCell(
                        'RELEASED PAYOUT',
                        '\$${_master.releasedPayout.toStringAsFixed(2)}',
                        valueColor: c.green,
                      ),
                    ),
                  ],
                ),
                Divider(height: 16, thickness: 1, color: c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _metricCell(
                        'PROFIT SHARE',
                        '${_master.profitShare.toStringAsFixed(2)}%',
                        valueColor: c.text,
                      ),
                    ),
                    Container(width: 1, height: 32, color: c.subBorder),
                    Expanded(
                      child: _metricCell(
                        'RISK PROFILE',
                        _master.risk,
                        valueColor: c.blue,
                      ),
                    ),
                  ],
                ),
                Divider(height: 16, thickness: 1, color: c.subBorder),
                Row(
                  children: [
                    Expanded(
                      child: _metricCell(
                        'LEVERAGE',
                        _master.leverage,
                        valueColor: c.text,
                      ),
                    ),
                    Container(width: 1, height: 32, color: c.subBorder),
                    Expanded(
                      child: _metricCell(
                        'PAYOUT FREQUENCY',
                        _master.payout,
                        valueColor: c.text,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCell(String label, String value, {required Color valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. CARD 1: MASTER SPECIFICATIONS
  // ---------------------------------------------------------------------------
  Widget _buildSpecificationsCard(MamWorkspaceColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.cpu, size: 18, color: c.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Master Specifications',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    Text(
                      'MetaTrader 5 node specifications',
                      style: TextStyle(fontSize: 11, color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: c.border),
          const SizedBox(height: 8),

          _specRow(c, 'Account Name', _master.name),
          _specRow(c, 'Master Login ID', _master.login, copyable: true),
          _specRow(c, 'Trading Platform', _master.tradingPlatform),
          _specRow(c, 'Server', _master.server, copyable: true),
          _specRow(c, 'Payout Cycle', _master.payout.toLowerCase()),
          _specRow(c, 'Algo Trading', _master.algoTrading),
          _specRow(c, 'Current Leverage', _master.leverage),
        ],
      ),
    );
  }

  Widget _specRow(MamWorkspaceColors c, String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: c.muted),
          ),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
              if (copyable) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _copyToClipboard(value, label),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(LucideIcons.copy, size: 13, color: c.blue),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CARD 2: SECURITY & CREDENTIALS
  // ---------------------------------------------------------------------------
  Widget _buildSecurityCard(MamWorkspaceColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shieldCheck, size: 18, color: c.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security & Credentials',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    Text(
                      'Investor password & MT5 keys',
                      style: TextStyle(fontSize: 11, color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Box 1: INVESTOR READ-ONLY CREDENTIALS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.subCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.subBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVESTOR READ-ONLY CREDENTIALS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage investor read-only password and MT5 node keys securely.',
                  style: TextStyle(fontSize: 11.5, color: c.muted, height: 1.3),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: () => _openSecuritySettingsSheet(c),
                    icon: const Icon(LucideIcons.keyRound, size: 15),
                    label: Text(
                      'Master Security & Settings',
                      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Box 2: RISK & LEVERAGE CONFIGURATION
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.subCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.subBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RISK & LEVERAGE CONFIGURATION',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: c.text,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Adjust risk parameters and trade limits according to your strategy.',
                  style: TextStyle(fontSize: 11.5, color: c.muted, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. CARD 3: LIVE ORDERS & CONTROLS
  // ---------------------------------------------------------------------------
  Widget _buildLiveOrdersCard(MamWorkspaceColors c) {
    final isActive = _master.status == 'Active';

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sliders, size: 18, color: c.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Orders & Controls',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    Text(
                      'Execution & node availability',
                      style: TextStyle(fontSize: 11, color: c.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 1: View Live Trades & Exposure
          InkWell(
            onTap: () => _openLiveTradesSheet(c),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.subCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.subBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.blueLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.activity, size: 18, color: c.blue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View Live Trades & Exposure',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                        Text(
                          'Open positions and execution status',
                          style: TextStyle(fontSize: 11, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, size: 18, color: c.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Row 2: Manage Investor Sub-Accounts
          InkWell(
            onTap: () => _openManageInvestorsSheet(c),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.subCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.subBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.greenLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.users, size: 18, color: c.green),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Investor Sub-Accounts',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                        Text(
                          'Connected capital and allocations',
                          style: TextStyle(fontSize: 11, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(LucideIcons.chevronRight, size: 18, color: c.muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Primary Toggle Button (min height 48)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _toggleNodeStatus,
              icon: Icon(isActive ? LucideIcons.pause : LucideIcons.play, size: 18),
              label: Text(
                isActive ? 'Pause Master Node' : 'Activate Master Node',
                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isActive ? const Color(0xFFDC2626) : c.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. CARD 4: PROFIT SHARE WALLET & SETTLEMENTS
  // ---------------------------------------------------------------------------
  Widget _buildProfitWalletCard(MamWorkspaceColors c) {
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profit Share Wallet & Settlements',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: c.text,
                      ),
                    ),
                    Text(
                      'Manage and trigger performance fee distributions',
                      style: TextStyle(fontSize: 11, color: c.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 44,
                child: FilledButton.icon(
                  onPressed: () => _triggerSettlementDialog(c),
                  icon: const Icon(LucideIcons.zap, size: 14),
                  label: Text(
                    'Trigger Settlement',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Metrics (3 Cards)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.subCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.subBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PENDING WALLET',
                        style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: c.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_master.pendingWallet.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: c.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.subCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.subBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL SETTLED',
                        style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: c.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_master.totalSettled.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: c.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.subCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.subBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRADES PROCESSED',
                        style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: c.muted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_master.tradesProcessed}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
