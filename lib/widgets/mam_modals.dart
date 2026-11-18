import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../app_notifications.dart';
import 'mam_master_node_workspace.dart';

// -----------------------------------------------------------------------------
// DYNAMIC THEME COLORS HELPER FOR MODALS
// -----------------------------------------------------------------------------
class _ModalColors {
  const _ModalColors({
    required this.isDark,
    required this.card,
    required this.subCard,
    required this.border,
    required this.subBorder,
    required this.text,
    required this.muted,
    required this.blue,
    required this.gold,
    required this.green,
    required this.red,
  });

  final bool isDark;
  final Color card;
  final Color subCard;
  final Color border;
  final Color subBorder;
  final Color text;
  final Color muted;
  final Color blue;
  final Color gold;
  final Color green;
  final Color red;

  factory _ModalColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ModalColors(
      isDark: isDark,
      card: isDark ? const Color(0xFF17243A) : Colors.white,
      subCard: isDark ? const Color(0xFF101D31) : const Color(0xFFF7F9FC),
      border: isDark ? const Color(0xFF263750) : const Color(0xFFE2E8F0),
      subBorder: isDark ? const Color(0xFF1E2E48) : const Color(0xFFEDF2F7),
      text: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      muted: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      blue: const Color(0xFF2563EB),
      gold: const Color(0xFFF59E0B),
      green: const Color(0xFF10B981),
      red: const Color(0xFFEF4444),
    );
  }
}

// -----------------------------------------------------------------------------
// MANAGER PROFILE DATA MODEL (FOR PROFILE & ALLOCATION MODALS)
// -----------------------------------------------------------------------------
class MamManagerProfileData {
  const MamManagerProfileData({
    required this.name,
    required this.login,
    this.isLive = true,
    this.accountBalance = 37769.98,
    this.currentEquity = 11663.10,
    this.performanceFee = 25.0,
    this.historicalGrowth = 0.00,
    this.riskProfile = 'Medium',
    this.trackRecordDays = 1454,
    this.execution = 'Direct STP',
    this.isVerified = true,
  });

  final String name;
  final String login;
  final bool isLive;
  final double accountBalance;
  final double currentEquity;
  final double performanceFee;
  final double historicalGrowth;
  final String riskProfile;
  final int trackRecordDays;
  final String execution;
  final bool isVerified;

  factory MamManagerProfileData.fromPool(dynamic pool) {
    try {
      final name = (pool.name as String?) ?? 'Apex Global Pool';
      final rawLogin = (pool.id as String?) ?? '2100572979';
      final cleanLogin = rawLogin.replaceAll(RegExp(r'[^0-9]'), '');
      final login = cleanLogin.isEmpty ? '2100572979' : cleanLogin;
      final fee = (pool.performanceFee as num?)?.toDouble() ?? 25.0;
      final risk = (pool.riskScore?.toString()) ?? 'Medium';
      final aum = (pool.totalAum as num?)?.toDouble() ?? 37769.98;
      final roi = (pool.monthlyRoi as num?)?.toDouble() ?? 0.00;

      return MamManagerProfileData(
        name: name,
        login: login,
        isLive: true,
        accountBalance: aum > 0 ? aum : 37769.98,
        currentEquity: aum > 0 ? (aum * 0.31) : 11663.10,
        performanceFee: fee,
        historicalGrowth: roi,
        riskProfile: risk,
        trackRecordDays: 1454,
        execution: 'Direct STP',
        isVerified: true,
      );
    } catch (_) {
      return const MamManagerProfileData(
        name: 'Alpha Manager',
        login: '2100572979',
      );
    }
  }

  factory MamManagerProfileData.fromMaster(MamMasterAccount master) {
    return MamManagerProfileData(
      name: master.name,
      login: master.login,
      isLive: master.status.toLowerCase() == 'active',
      accountBalance: master.balance > 0 ? master.balance : 37769.98,
      currentEquity: master.balance > 0 ? master.balance : 11663.10,
      performanceFee: master.profitShare,
      historicalGrowth: master.monthlyGain,
      riskProfile: master.risk,
      trackRecordDays: 1454,
      execution: 'Direct STP',
      isVerified: true,
    );
  }
}

// =============================================================================
// MODAL A: ESTABLISH MASTER MAM SHEET
// =============================================================================
class EstablishMasterMamSheet extends StatefulWidget {
  const EstablishMasterMamSheet({
    super.key,
    required this.onCreated,
  });

  final ValueChanged<MamMasterAccount> onCreated;

  @override
  State<EstablishMasterMamSheet> createState() => _EstablishMasterMamSheetState();
}

class _EstablishMasterMamSheetState extends State<EstablishMasterMamSheet> {
  final _strategyNameController =
      TextEditingController(text: 'Apex Global Alpha Pool');
  final _profitShareController =
      TextEditingController(text: '20');

  String _selectedRisk = 'Medium';
  String _selectedLeverage = '1:500';
  String _selectedPayout = 'Weekly (Default)';

  final List<String> _leverages = const ['1:100', '1:200', '1:400', '1:500'];
  final List<String> _payoutOptions = const [
    'Weekly (Default)',
    'Daily',
    'Monthly',
    'Quarterly',
    'Half-Yearly',
    'Annually',
  ];

  @override
  void dispose() {
    _strategyNameController.dispose();
    _profitShareController.dispose();
    super.dispose();
  }

  void _submit() {
    final strategyName = _strategyNameController.text.trim().isEmpty
        ? 'Apex Global Alpha Pool'
        : _strategyNameController.text.trim();
    final profitShare =
        double.tryParse(_profitShareController.text.trim()) ?? 20.0;
    final randSuffix =
        (DateTime.now().millisecondsSinceEpoch % 900000 + 100000).toString();
    final login = '2100$randSuffix';
    final cleanPayout = _selectedPayout.replaceAll(' (Default)', '');

    final newMaster = MamMasterAccount(
      name: strategyName,
      login: login,
      profitShare: profitShare,
      leverage: _selectedLeverage,
      balance: 0.00,
      status: 'Active',
      risk: _selectedRisk,
      payout: cleanPayout,
      allocationMethod: 'Lot Proportional',
      investorsCount: 0,
      totalAum: 0.0,
      monthlyGain: 0.0,
      server: 'VTindex-MT5',
      tradingPlatform: 'MetaTrader 5 (MT5)',
      algoTrading: 'Manual',
      pendingRelease: 0.00,
      releasedPayout: 0.00,
      pendingWallet: 0.00,
      totalSettled: 0.00,
      tradesProcessed: 0,
    );

    Navigator.pop(context);
    widget.onCreated(newMaster);
    showAppMessage('Master MAM Account "$login" established successfully!');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final border = theme.dividerColor;
    final muted = cs.onSurfaceVariant;
    final screen = MediaQuery.sizeOf(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: 560, maxHeight: screen.height * .92),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? .34 : .12),
                    blurRadius: 30,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: muted.withValues(alpha: .45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 12, 15),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            LucideIcons.briefcaseBusiness,
                            color: cs.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Establish Master MAM',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Configure your new MAM master trading pool',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(LucideIcons.x, color: muted, size: 19),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: border),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeading('STRATEGY PROFILE', '01'),
                          const SizedBox(height: 10),
                          _fieldLabel('Master strategy name'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _strategyNameController,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration(
                              'Enter strategy name (e.g. Apex Alpha Pool)',
                              LucideIcons.briefcaseBusiness,
                              cs,
                              border,
                              muted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Performance profit share'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _profitShareController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _inputDecoration(
                              'Enter profit share percentage',
                              LucideIcons.percent,
                              cs,
                              border,
                              muted,
                              suffixText: '%',
                            ),
                          ),
                          const SizedBox(height: 18),
                          _sectionHeading(
                            'TRADING & RISK CONFIGURATION',
                            '02',
                          ),
                          const SizedBox(height: 10),
                          _fieldLabel('Risk profile'),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              _riskCard('Low', 'Conservative', cs, border),
                              const SizedBox(width: 8),
                              _riskCard('Medium', 'Balanced', cs, border),
                              const SizedBox(width: 8),
                              _riskCard('High', 'Aggressive', cs, border),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Account leverage'),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              for (final value in _leverages)
                                _leverageCard(
                                  value,
                                  cs,
                                  border,
                                  isLast: value == _leverages.last,
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _fieldLabel('Settlement payout frequency'),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(
                                alpha: dark ? .45 : .55,
                              ),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPayout,
                                isExpanded: true,
                                dropdownColor: cs.surface,
                                icon: Icon(
                                  LucideIcons.chevronDown,
                                  color: muted,
                                  size: 18,
                                ),
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                items: _payoutOptions
                                    .map(
                                      (pay) => DropdownMenuItem(
                                        value: pay,
                                        child: Text(pay),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedPayout = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: border),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      13,
                      18,
                      16 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              foregroundColor: const Color(0xFF142238),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(LucideIcons.arrowRight, size: 18),
                            label: const Text(
                              'ESTABLISH MASTER ACCOUNT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .35,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.shieldCheck, color: muted, size: 12),
                            const SizedBox(width: 5),
                            Text(
                              'Real-time MT5 allocation engine • Regulated STP',
                              style: TextStyle(color: muted, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title, String number) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          number,
          style: TextStyle(
            color: cs.primary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String value) => Text(
        value,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _riskCard(String level, String label, ColorScheme cs, Color border) {
    final isSelected = _selectedRisk == level;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRisk = level),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary.withValues(alpha: .10) : cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? cs.primary : border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                level,
                style: TextStyle(
                  color: isSelected ? cs.primary : cs.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '($label)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leverageCard(
    String value,
    ColorScheme cs,
    Color border, {
    bool isLast = false,
  }) {
    final isSelected = _selectedLeverage == value;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: isLast ? 0 : 8),
        child: InkWell(
          onTap: () => setState(() => _selectedLeverage = value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary.withValues(alpha: .10) : cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cs.primary : border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                color: isSelected ? cs.primary : cs.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
    ColorScheme cs,
    Color border,
    Color muted, {
    String? suffixText,
  }) =>
      InputDecoration(
        prefixIcon: Icon(icon, size: 17, color: muted),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          color: cs.primary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        hintText: hint,
        hintStyle: TextStyle(color: muted, fontSize: 11),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? .45 : .55,
        ),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
      );
}

// =============================================================================
// MODAL B: MANAGER PERFORMANCE PROFILE MODAL
// =============================================================================
class ManagerPerformanceProfileModal extends StatelessWidget {
  const ManagerPerformanceProfileModal({
    super.key,
    required this.manager,
    required this.onInvestTap,
  });

  final MamManagerProfileData manager;
  final VoidCallback onInvestTap;

  @override
  Widget build(BuildContext context) {
    final c = _ModalColors.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.muted.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.blue.withValues(alpha: 0.3)),
                  ),
                  child: Icon(LucideIcons.shieldCheck, color: c.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manager Performance Profile',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: c.border),

          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                children: [
                  // Profile Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.subCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: c.blue.withValues(alpha: 0.15),
                          child: Icon(LucideIcons.user, color: c.blue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '(${manager.login})',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: c.text,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: c.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'ID: ${manager.login}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: c.muted,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: c.green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: c.green.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'LIVE MANAGER',
                                      style: GoogleFonts.inter(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                        color: c.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 6 Stat Boxes (2 rows x 3 columns)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'ACCOUNT BALANCE',
                          value: '\$${manager.accountBalance.toStringAsFixed(2)}',
                          valueColor: c.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'CURRENT EQUITY',
                          value: '\$${manager.currentEquity.toStringAsFixed(2)}',
                          valueColor: c.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'PERFORMANCE FEE',
                          value: '${manager.performanceFee.toStringAsFixed(0)}%',
                          valueColor: c.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'HISTORICAL GROWTH',
                          value:
                              '${manager.historicalGrowth >= 0 ? '' : ''}${manager.historicalGrowth.toStringAsFixed(2)}%',
                          valueColor: c.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'RISK PROFILE',
                          value: manager.riskProfile.toLowerCase(),
                          valueColor: c.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'TRACK RECORD',
                          value: '${manager.trackRecordDays} days',
                          valueColor: c.text,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Bottom Action Buttons: CLOSE & + INVEST WITH THIS MANAGER
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.text,
                          side: BorderSide(color: c.border),
                          minimumSize: const Size(96, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'CLOSE',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onInvestTap,
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: Text(
                            'INVEST WITH THIS MANAGER',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: c.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required _ModalColors c,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: c.subCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: c.muted,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MODAL C: INVEST IN (LOGIN) PASSWORD ALLOCATION MODAL
// =============================================================================
class InvestInManagerModal extends StatefulWidget {
  const InvestInManagerModal({
    super.key,
    required this.manager,
    required this.onConfirmed,
  });

  final MamManagerProfileData manager;
  final ValueChanged<String> onConfirmed;

  @override
  State<InvestInManagerModal> createState() => _InvestInManagerModalState();
}

class _InvestInManagerModalState extends State<InvestInManagerModal> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.isEmpty) {
      showAppMessage('Please enter an investor terminal password');
      return;
    }
    if (password != confirm) {
      showAppMessage('Investor passwords do not match');
      return;
    }

    Navigator.pop(context);
    widget.onConfirmed(password);
    showAppMessage('Successfully allocated to Manager (${widget.manager.login})!');
  }

  @override
  Widget build(BuildContext context) {
    final c = _ModalColors.of(context);
    final manager = widget.manager;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: c.muted.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: c.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.blue.withValues(alpha: 0.3)),
                  ),
                  child: Icon(LucideIcons.shieldCheck, color: c.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Invest in (${manager.login})',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: c.text,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: c.border),

          // Body
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Manager Summary Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.subCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: c.blue.withValues(alpha: 0.15),
                              child: Icon(LucideIcons.user, color: c.blue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '(${manager.login})',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: c.text,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: c.green.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                              color: c.green.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          '• VERIFIED MAM',
                                          style: GoogleFonts.inter(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.3,
                                            color: c.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'ID: ${manager.login}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: c.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: c.border),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _buildSummaryPill(
                              c: c,
                              text:
                                  'PERFORMANCE FEE (${manager.performanceFee.toStringAsFixed(0)}%)',
                              color: c.gold,
                            ),
                            _buildSummaryPill(
                              c: c,
                              text: 'RISK PROFILE (${manager.riskProfile})',
                              color: c.blue,
                            ),
                            _buildSummaryPill(
                              c: c,
                              text: 'EXECUTION (${manager.execution})',
                              color: c.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Field 1: INVESTOR TERMINAL PASSWORD *
                  Text(
                    'INVESTOR TERMINAL PASSWORD *',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: c.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Set investment terminal password',
                      hintStyle: TextStyle(color: c.muted, fontSize: 13),
                      filled: true,
                      fillColor: c.subCard,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.blue, width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: c.muted,
                          size: 18,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Field 2: CONFIRM INVESTOR PASSWORD *
                  Text(
                    'CONFIRM INVESTOR PASSWORD *',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: c.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: c.text,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Re-enter investment password',
                      hintStyle: TextStyle(color: c.muted, fontSize: 13),
                      filled: true,
                      fillColor: c.subCard,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: c.blue, width: 1.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                          color: c.muted,
                          size: 18,
                        ),
                        onPressed: () => setState(
                            () => _showConfirmPassword = !_showConfirmPassword),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Bottom Action Buttons: CANCEL & CONFIRM & ALLOCATE ->
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.text,
                          side: BorderSide(color: c.border),
                          minimumSize: const Size(96, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: c.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CONFIRM & ALLOCATE',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(LucideIcons.arrowRight, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill({
    required _ModalColors c,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// CONVENIENCE SHOW FUNCTIONS
// =============================================================================

void showEstablishMasterMamSheet(
  BuildContext context, {
  required ValueChanged<MamMasterAccount> onCreated,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => EstablishMasterMamSheet(onCreated: onCreated),
  );
}

void showManagerPerformanceProfileModal(
  BuildContext context, {
  required MamManagerProfileData manager,
  required VoidCallback onInvestTap,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ManagerPerformanceProfileModal(
      manager: manager,
      onInvestTap: onInvestTap,
    ),
  );
}

void showInvestInManagerModal(
  BuildContext context, {
  required MamManagerProfileData manager,
  required ValueChanged<String> onConfirmed,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => InvestInManagerModal(
      manager: manager,
      onConfirmed: onConfirmed,
    ),
  );
}
