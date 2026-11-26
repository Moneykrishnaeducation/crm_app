import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../app_notifications.dart';
import '../pages/funds_action_dialog.dart';
import '../pages/mam_investor_live_positions_page.dart';
import '../services/auth_api.dart';
import 'pool_trades_modal.dart';

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
    this.pendingRelease = 0.00,
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
  bool _profitSummaryLoading = false;
  bool _settlementInProgress = false;
  bool _statusUpdating = false;

  @override
  void initState() {
    super.initState();
    _master = widget.master;
    _loadProfitSummary();
  }

  Future<void> _loadProfitSummary() async {
    if (_profitSummaryLoading) return;
    _profitSummaryLoading = true;
    try {
      final data = await AuthApi.instance.getMamProfitSummary(mamAccountId: _master.login);
      if (!mounted) return;
      setState(() {
        final pending = double.tryParse(data['pending_amount']?.toString() ?? '') ?? 0.0;
        final settled = double.tryParse(data['total_settled']?.toString() ?? '') ?? 0.0;
        _master.pendingWallet = pending;
        _master.pendingRelease = pending;
        _master.totalSettled = settled;
        _master.releasedPayout = settled;
        _master.tradesProcessed = int.tryParse(data['trade_count']?.toString() ?? '') ?? 0;
      });
      widget.onUpdate?.call(_master);
    } catch (error) {
      debugPrint('Could not load MAM profit summary: $error');
    } finally {
      if (mounted) {
        setState(() => _profitSummaryLoading = false);
      } else {
        _profitSummaryLoading = false;
      }
    }
  }

  void _notifyUpdate() {
    setState(() {});
    widget.onUpdate?.call(_master);
  }

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    showAppMessage('$label copied to clipboard', type: AppFeedbackType.success);
  }

  Future<void> _toggleNodeStatus() async {
    if (_statusUpdating) return;
    HapticFeedback.selectionClick();
    final wasActive = _master.status == 'Active';
    setState(() => _statusUpdating = true);
    try {
      final response = await AuthApi.instance.setMamTradingEnabled(
        mamId: _master.login,
        enabled: !wasActive,
      );
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _master.status = !wasActive ? 'Active' : 'Paused';
      });
      widget.onUpdate?.call(_master);
      showAppMessage(
        response['message']?.toString() ??
            (!wasActive ? 'Master node resumed successfully.' : 'Master node paused successfully.'),
        type: AppFeedbackType.success,
      );
    } catch (error) {
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      showAppMessage(
        error is AuthApiException
            ? error.message
            : 'Could not update the MAM master trading status.',
        type: AppFeedbackType.error,
      );
    } finally {
      if (mounted) setState(() => _statusUpdating = false);
    }
  }

  void _toggleMasterStatus() => _toggleNodeStatus();

  // ---------------------------------------------------------------------------
  // INTERACTIVE MODALS
  // ---------------------------------------------------------------------------
  void _openDepositSheet(MamWorkspaceColors c) {
    showFundsActionDialog(
      context,
      withdrawal: false,
      accountId: _master.login,
      accountLabel: '${_master.name} · Master #${_master.login}',
      // Deposit requests are pending until backend/payment confirmation. Do not
      // optimistically add the requested amount to the MT5 balance.

    );
  }

  void _openQuickFundSheet(MamWorkspaceColors c) => _openDepositSheet(c);

  void _openWithdrawSheet(MamWorkspaceColors c) {
    showFundsActionDialog(
      context,
      withdrawal: true,
      accountId: _master.login,
      accountLabel: '${_master.name} · Master #${_master.login}',
      // Withdrawal requests are pending approval. Keep the MT5 balance unchanged
      // until the backend confirms the actual debit.

    );
  }

  void _openSecuritySettingsSheet(MamWorkspaceColors c) {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool saving = false;
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border)),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Text('Update Investor Password',
                    style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: c.text))),
                  IconButton(onPressed: () => Navigator.pop(ctx),
                    icon: Icon(LucideIcons.x, color: c.muted)),
                ]),
                Text('Set a new MT5 investor (read-only) password for master account #${_master.login}.',
                  style: TextStyle(fontSize: 12, color: c.muted)),
                const SizedBox(height: 16),
                Text('NEW INVESTOR PASSWORD',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: c.muted)),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController, obscureText: obscurePassword,
                  enableSuggestions: false, autocorrect: false,
                  style: GoogleFonts.inter(fontSize: 14, color: c.text),
                  decoration: InputDecoration(
                    hintText: 'Minimum 8 characters', filled: true, fillColor: c.subCard,
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18, color: c.muted),
                      onPressed: () => setModalState(() => obscurePassword = !obscurePassword)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: c.border)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 48,
                  child: FilledButton(
                    onPressed: saving ? null : () async {
                      final password = passwordController.text.trim();
                      if (password.length < 8) {
                        showAppMessage('Password must be at least 8 characters long.');
                        return;
                      }
                      setModalState(() => saving = true);
                      try {
                        final response = await AuthApi.instance.updateTradingAccountPassword(
                          accountId: _master.login, newPassword: password);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        showAppMessage(response['message']?.toString() ??
                          'Investor password updated successfully.');
                      } catch (error) {
                        setModalState(() => saving = false);
                        showAppMessage(error is AuthApiException ? error.message :
                          'Could not update the MT5 investor password.');
                      }
                    },
                    style: FilledButton.styleFrom(backgroundColor: c.navy, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Update MT5 Password', style: TextStyle(fontWeight: FontWeight.w700)),
                  )),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(passwordController.dispose);
  }

  void _openRiskSettingsSheet(MamWorkspaceColors c) {
    const allowed = ['50', '100', '200', '300', '400', '500'];
    final current = _master.leverage.replaceAll('1:', '').trim();
    String selected = allowed.contains(current) ? current : '500';
    bool saving = false;
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Text('Risk & Leverage Configuration',
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: c.text))),
                IconButton(onPressed: () => Navigator.pop(ctx),
                  icon: Icon(LucideIcons.x, color: c.muted)),
              ]),
              Text('Master account #${_master.login} · Current leverage 1:${current.isEmpty ? '—' : current}',
                style: TextStyle(color: c.muted, fontSize: 12)),
              const SizedBox(height: 16),
              Text('SELECT LEVERAGE',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: c.muted)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selected,
                decoration: InputDecoration(filled: true, fillColor: c.subCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: allowed.map((value) => DropdownMenuItem(value: value, child: Text('1:$value'))).toList(),
                onChanged: saving ? null : (value) {
                  if (value != null) setModalState(() => selected = value);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 48,
                child: FilledButton(
                  onPressed: saving ? null : () async {
                    setModalState(() => saving = true);
                    try {
                      final response = await AuthApi.instance.updateTradingAccountLeverage(
                        accountId: _master.login, leverage: selected);
                      if (!ctx.mounted) return;
                      setState(() => _master.leverage = '1:$selected');
                      _notifyUpdate();
                      Navigator.pop(ctx);
                      showAppMessage(response['message']?.toString() ?? 'Leverage updated successfully.');
                    } catch (error) {
                      setModalState(() => saving = false);
                      showAppMessage(error is AuthApiException ? error.message : 'Could not update MT5 leverage.');
                    }
                  },
                  style: FilledButton.styleFrom(backgroundColor: c.blue, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Leverage', style: TextStyle(fontWeight: FontWeight.w700)),
                )),
            ],
          ),
        ),
      ),
    );
  }

  void _openManageInvestorsSheet(MamWorkspaceColors c) {
    final investorsFuture = AuthApi.instance.getMamInvestors(_master.login);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final screenHeight = MediaQuery.sizeOf(ctx).height;
        String field(Map<String, dynamic> item, List<String> keys,
            {String fallback = '—'}) {
          for (final key in keys) {
            final value = item[key];
            if (value != null && value.toString().trim().isNotEmpty) {
              return value.toString();
            }
          }
          return fallback;
        }

        double number(Map<String, dynamic> item, List<String> keys) {
          for (final key in keys) {
            final value = item[key];
            if (value is num) return value.toDouble();
            final parsed = double.tryParse(value?.toString() ?? '');
            if (parsed != null) return parsed;
          }
          return 0;
        }

        String money(double value) => '\$${value.toStringAsFixed(2)}';

        Widget detailLine(String label, String value) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 112, child: Text(label,
                  style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Expanded(child: Text(value, textAlign: TextAlign.right,
                  style: GoogleFonts.inter(color: c.text, fontSize: 11, fontWeight: FontWeight.w700))),
              ],
            ),
          );
        }

        Widget investorCard(Map<String, dynamic> investor, int index) {
          final accountId = field(investor, ['account_id', 'investor_account_id', 'login']);
          final name = field(investor, ['account_name', 'username', 'name'],
              fallback: 'Investor ${index + 1}');
          final email = field(investor, ['email', 'user_email']);
          final balance = number(investor, ['balance']);
          final equity = number(investor, ['equity', 'balance']);
          final credit = number(investor, ['credit']);
          final profit = number(investor, ['profit', 'floating_profit']);
          final leverage = field(investor, ['leverage']);
          final group = field(investor, ['group_name', 'group', 'trade_group']);
          final country = field(investor, ['country']);
          final created = field(investor, ['created_at', 'created', 'reg_date']);
          final rawCopy = investor['manager_allow_copy'] ??
              investor['manage_allow_copy'] ??
              investor['investor_allow_copy'];
          bool copyEnabled = rawCopy == true ||
              ['true', '1', 'yes', 'enabled', 'active'].contains(
                rawCopy?.toString().toLowerCase(),
              );
          bool copyUpdating = false;
          bool expanded = false;

          return StatefulBuilder(
            builder: (tileContext, setTileState) {
              Future<void> changeCopy(bool enabled) async {
                setTileState(() => copyUpdating = true);
                try {
                  final response = await AuthApi.instance.toggleMamInvestorCopy(accountId);
                  final returned = response['manager_allow_copy'] ??
                      response['manage_allow_copy'];
                  final nextValue = returned is bool
                      ? returned
                      : (returned == null
                          ? enabled
                          : ['true', '1', 'yes', 'enabled', 'active'].contains(
                              returned.toString().toLowerCase(),
                            ));
                  setTileState(() {
                    copyEnabled = nextValue;
                    copyUpdating = false;
                  });
                  investor['manager_allow_copy'] = nextValue;
                  showAppMessage(response['message']?.toString() ??
                      (nextValue ? 'Copy trading enabled.' : 'Copy trading paused.'));
                } catch (error) {
                  setTileState(() => copyUpdating = false);
                  showAppMessage(error is AuthApiException
                      ? error.message
                      : 'Could not update copy-trading status.');
                }
              }

              void openPositions() {
                Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => MamInvestorLivePositionsPage(
                      accountId: accountId,
                      accountName: name,
                    ),
                  ),
                );
              }

              return Container(
            margin: const EdgeInsets.only(bottom: 9),
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Ink(
                decoration: BoxDecoration(
                  color: c.subCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.subBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setTileState(() => expanded = !expanded),
                        borderRadius: BorderRadius.circular(10),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: c.greenLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(LucideIcons.userRound, color: c.green, size: 19),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: c.text, fontSize: 13, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text('MT5 Account #$accountId',
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: c.muted, fontSize: 10, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                              size: 18,
                              color: c.muted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: copyEnabled
                                    ? c.greenLight.withValues(alpha: 0.55)
                                    : c.subCard,
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: copyEnabled
                                      ? c.green.withValues(alpha: 0.28)
                                      : c.subBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: copyEnabled ? c.green : c.muted,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      copyEnabled ? 'COPY ON' : 'COPY OFF',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: copyEnabled ? c.green : c.muted,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.35,
                                      ),
                                    ),
                                  ),
                                  if (copyUpdating)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    Transform.scale(
                                      scale: 0.82,
                                      child: Switch.adaptive(
                                        value: copyEnabled,
                                        activeTrackColor: c.green.withValues(alpha: 0.5),
                                        activeThumbColor: c.green,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        onChanged: changeCopy,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton.icon(
                                onPressed: openPositions,
                                icon: const Icon(LucideIcons.activity, size: 15),
                                label: Text(
                                  'Live Positions',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: c.blue,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  side: BorderSide(color: c.blue.withValues(alpha: 0.28)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (expanded) ...[
                        const SizedBox(height: 12),
                        Container(height: 1, color: c.subBorder),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _investorMetric(c, 'BALANCE', money(balance))),
                          const SizedBox(width: 8),
                          Expanded(child: _investorMetric(c, 'EQUITY', money(equity))),
                          const SizedBox(width: 8),
                          Expanded(child: _investorMetric(c, 'FLOATING P/L',
                            '${profit >= 0 ? '+' : '-'}\$${profit.abs().toStringAsFixed(2)}',
                            valueColor: profit >= 0 ? c.green : c.red)),
                        ]),
                        const SizedBox(height: 10),
                        detailLine('Email', email),
                        detailLine('Credit', money(credit)),
                        detailLine('Leverage', leverage == '—' ? '—' : '1:$leverage'),
                        detailLine('Trading Group', group),
                        detailLine('Country', country),
                        detailLine('Created', created),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
            },
          );
        }

        return Container(
          height: screenHeight * 0.92,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: c.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Investor Pool & Allocations',
                  style: GoogleFonts.inter(color: c.text, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text('Master #${_master.login} · Connected investor account details',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.muted, fontSize: 11)),
              ])),
              IconButton(onPressed: () => Navigator.pop(ctx),
                icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44)),
            ]),
            const SizedBox(height: 10),
            Expanded(child: FutureBuilder<List<Map<String, dynamic>>>(
              future: investorsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.alertCircle, color: c.red, size: 28),
                    const SizedBox(height: 8),
                    Text('Could not load investor accounts',
                      style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center,
                      style: TextStyle(color: c.muted, fontSize: 10)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () { Navigator.pop(ctx); _openManageInvestorsSheet(c); },
                      icon: const Icon(LucideIcons.refreshCw, size: 14),
                      label: const Text('Retry')),
                  ]));
                }

                final investors = snapshot.data ?? const <Map<String, dynamic>>[];
                final totalBalance = investors.fold<double>(0,
                  (sum, item) => sum + number(item, ['balance']));
                final totalEquity = investors.fold<double>(0,
                  (sum, item) => sum + number(item, ['equity', 'balance']));
                final totalProfit = investors.fold<double>(0,
                  (sum, item) => sum + number(item, ['profit', 'floating_profit']));
                final activeCount = investors.where((item) {
                  final copyState = item['manager_allow_copy'] ??
                      item['manage_allow_copy'] ??
                      item['investor_allow_copy'];
                  return copyState == true ||
                      ['true', '1', 'yes', 'enabled', 'active'].contains(
                        copyState?.toString().toLowerCase(),
                      );
                }).length;

                return Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: c.subCard,
                      borderRadius: BorderRadius.circular(12), border: Border.all(color: c.subBorder)),
                    child: Column(children: [
                      Row(children: [
                        Expanded(child: _investorMetric(c, 'TOTAL INVESTORS', '${investors.length}')),
                        Expanded(child: _investorMetric(c, 'ACTIVE MIRRORS', '$activeCount')),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _investorMetric(c, 'POOLED BALANCE', money(totalBalance))),
                        Expanded(child: _investorMetric(c, 'TOTAL EQUITY', money(totalEquity))),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(child: _investorMetric(c, 'AGGREGATE FLOATING P/L',
                          '${totalProfit >= 0 ? '+' : '-'}\$ ${totalProfit.abs().toStringAsFixed(2)}'.replaceAll('\$ ', '\$'),
                          valueColor: totalProfit >= 0 ? c.green : c.red)),
                        Expanded(child: _investorMetric(c, 'ALLOCATION METHOD', _master.allocationMethod)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Text('CONNECTED INVESTOR ACCOUNTS',
                      style: GoogleFonts.inter(color: c.muted, fontSize: 10,
                        fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    const Spacer(),
                    Text('${investors.length} accounts',
                      style: TextStyle(color: c.muted, fontSize: 10)),
                  ]),
                  const SizedBox(height: 8),
                  Expanded(child: investors.isEmpty
                    ? Center(child: Text('No investor accounts are connected to this MAM node.',
                        textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12)))
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: investors.length,
                        itemBuilder: (context, index) => investorCard(investors[index], index))),
                ]);
              },
            )),
          ]),
        );
      },
    );
  }

  Widget _investorMetric(MamWorkspaceColors c, String label, String value,
      {Color? valueColor}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
        style: TextStyle(color: c.muted, fontSize: 9, fontWeight: FontWeight.w700)),
      const SizedBox(height: 3),
      Text(value, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(color: valueColor ?? c.text, fontSize: 12, fontWeight: FontWeight.w800)),
    ]);
  }

  void _triggerSettlementDialog(MamWorkspaceColors c) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool inProgress = false;
        final hasPending = _master.pendingWallet > 0.00;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
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
                    hasPending
                        ? 'Execute weekly performance fee distribution for node #${_master.login}.'
                        : 'No pending performance fees available to settle for node #${_master.login}.',
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
                            Text('Pending wallet balance', style: TextStyle(fontSize: 12, color: c.muted)),
                            Text(
                              '\$${_master.pendingWallet.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w800,
                                color: hasPending ? c.blue : c.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Master account', style: TextStyle(fontSize: 12, color: c.muted)),
                            Text('#${_master.login}',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: c.text)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: inProgress ? null : () => Navigator.pop(ctx),
                  child: Text('Cancel', style: TextStyle(color: c.muted)),
                ),
                FilledButton(
                  onPressed: (!inProgress && hasPending) ? () async {
                    HapticFeedback.mediumImpact();
                    setDialogState(() => inProgress = true);
                    setState(() => _settlementInProgress = true);
                    try {
                      final response = await AuthApi.instance.triggerMamProfitSettlement(
                        mamAccountId: _master.login,
                      );
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      HapticFeedback.lightImpact();
                      await _loadProfitSummary();
                      HapticFeedback.heavyImpact();
                      showAppMessage(
                        response['message']?.toString() ??
                        response['detail']?.toString() ??
                        'Settlement request completed. Wallet summary refreshed.',
                        type: AppFeedbackType.success,
                      );
                    } catch (error) {
                      if (ctx.mounted) {
                        setDialogState(() => inProgress = false);
                        HapticFeedback.heavyImpact();
                        showAppMessage(
                          error is AuthApiException
                            ? error.message
                            : 'Could not trigger MAM settlement.',
                          type: AppFeedbackType.error,
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _settlementInProgress = false);
                    }
                  } : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: inProgress
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Execute Now', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openPerformanceSheet(MamWorkspaceColors c) {
    // Show actual MT5 MAM positions and live trade metrics instead of
    // placeholder ROI / win-rate figures.
    PoolTradesModal.show(
      context,
      poolLogin: _master.login,
      poolName: _master.name,
      isManager: true,
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
                // 2. Hero Balance & Action Card
                _buildHeroBalanceCard(c),
                const SizedBox(height: 14),

                // 3. Card 1: Master Specifications
                _buildSpecificationsCard(c),
                const SizedBox(height: 14),

                // 4. Card 2: Security & Credentials
                _buildSecurityCard(c),
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
                onTap: () { HapticFeedback.selectionClick(); _copyToClipboard(_master.login, 'Master Login ID'); },
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

          // Responsive Balance & Action Controls Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 440;
              final isActive = _master.status == 'Active';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Large Balance Display
                  FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '\$${_master.balance.toStringAsFixed(2)} USD',
                      style: GoogleFonts.inter(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: c.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isMobile) ...[
                    // Row 1 (Primary Financial Actions)
                    Row(
                      children: [
                        // [+ Quick Fund]
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: FilledButton.icon(
                              onPressed: () { HapticFeedback.lightImpact(); _openQuickFundSheet(c); },
                              icon: const Icon(LucideIcons.plus, size: 16),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Quick Fund',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: c.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // [↗ Withdraw]
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: () { HapticFeedback.lightImpact(); _openWithdrawSheet(c); },
                              icon: Icon(
                                LucideIcons.arrowUpRight,
                                size: 16,
                                color: c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Withdraw',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 2 (Master Node Status & Broadcast Control Strip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? c.greenLight.withValues(alpha: 0.5)
                            : c.goldLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive ? c.greenBorder : c.goldBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? LucideIcons.radio : LucideIcons.pause,
                            size: 16,
                            color: isActive ? c.green : c.gold,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isActive
                                      ? 'Master Node Active'
                                      : 'Master Node Paused',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: c.text,
                                  ),
                                ),
                                Text(
                                  isActive
                                      ? 'Broadcasting orders to ${_master.investorsCount} followers'
                                      : 'Broadcasting suspended by manager',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: c.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: OutlinedButton.icon(
                              onPressed: _statusUpdating ? null : () { HapticFeedback.mediumImpact(); _toggleMasterStatus(); },
                              icon: _statusUpdating
                                  ? const SizedBox(
                                      width: 13,
                                      height: 13,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
                                      isActive ? LucideIcons.pause : LucideIcons.play,
                                      size: 13,
                                      color: isActive ? c.gold : c.green,
                                    ),
                              label: Text(
                                _statusUpdating ? 'Updating…' : (isActive ? 'Pause' : 'Resume'),
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: isActive ? c.gold : c.green,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: c.card,
                                side: BorderSide(
                                  color: isActive ? c.goldBorder : c.greenBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                minimumSize: const Size(0, 36),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Row 3 (Workspace Navigation Actions)
                    Row(
                      children: [
                        // [Performance]
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: () { HapticFeedback.lightImpact(); _openPerformanceSheet(c); },
                              icon: Icon(
                                LucideIcons.barChart2,
                                size: 15,
                                color: c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Performance',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // [Investor Pool]
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: () { HapticFeedback.lightImpact(); _openManageInvestorsSheet(c); },
                              icon: Icon(
                                LucideIcons.users,
                                size: 15,
                                color: c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Investor Pool',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Tablet / Desktop screens (maxWidth >= 440): 4-button 2x2 grid
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: FilledButton.icon(
                              onPressed: () => _openDepositSheet(c),
                              icon: const Icon(LucideIcons.plus, size: 16),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Quick Fund',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: c.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                elevation: 0,
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
                              icon: Icon(
                                LucideIcons.arrowUpRight,
                                size: 16,
                                color: c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Withdraw',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                              icon: Icon(
                                LucideIcons.barChart2,
                                size: 16,
                                color: c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Performance',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
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
                              icon: Icon(
                                LucideIcons.users,
                                size: 16,
                                color: c.text,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Investor Pool',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: c.text,
                                  ),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: c.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
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
                    if (_master.risk.trim().isNotEmpty) ...[
                      Container(width: 1, height: 32, color: c.subBorder),
                      Expanded(
                        child: _metricCell(
                          'RISK PROFILE',
                          _master.risk,
                          valueColor: c.blue,
                        ),
                      ),
                    ],
                  ],
                ),
                if (_master.leverage.trim().isNotEmpty ||
                    _master.payout.trim().isNotEmpty) ...[
                  Divider(height: 16, thickness: 1, color: c.subBorder),
                  Row(
                    children: [
                      if (_master.leverage.trim().isNotEmpty)
                        Expanded(
                          child: _metricCell(
                            'LEVERAGE',
                            _master.leverage,
                            valueColor: c.text,
                          ),
                        ),
                      if (_master.leverage.trim().isNotEmpty &&
                          _master.payout.trim().isNotEmpty)
                        Container(width: 1, height: 32, color: c.subBorder),
                      if (_master.payout.trim().isNotEmpty)
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
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF94A3B8),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    softWrap: false,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                    ),
                  ),
                ),
              ),
            ],
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
                  onTap: () { HapticFeedback.selectionClick(); _copyToClipboard(value, label); },
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
                    onPressed: () { HapticFeedback.mediumImpact(); _openSecuritySettingsSheet(c); },
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
                  'Current master leverage: ${_master.leverage}. Update the leverage supported by your MT5 account.',
                  style: TextStyle(fontSize: 11.5, color: c.muted, height: 1.3),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () { HapticFeedback.mediumImpact(); _openRiskSettingsSheet(c); },
                    icon: const Icon(LucideIcons.slidersHorizontal, size: 15),
                    label: const Text('Configure Leverage',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.blue,
                      side: BorderSide(color: c.blue.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
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
                  onPressed: _settlementInProgress ? null : () { HapticFeedback.mediumImpact(); _triggerSettlementDialog(c); },
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
                        _profitSummaryLoading ? 'Loading…' : '\$${_master.pendingWallet.toStringAsFixed(2)}',
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
                        _profitSummaryLoading ? 'Loading…' : '\$${_master.totalSettled.toStringAsFixed(2)}',
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
                        _profitSummaryLoading ? '…' : '${_master.tradesProcessed}',
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
