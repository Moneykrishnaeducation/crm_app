import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../app_notifications.dart';
import '../services/auth_api.dart';
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
    this.isLive = false,
    this.accountBalance = 0.0,
    this.currentEquity = 0.0,
    this.performanceFee = 0.0,
    this.historicalGrowth = 0.0,
    this.riskProfile = 'Unknown',
    this.trackRecordDays = 0,
    this.execution = '',
    this.isVerified = false,
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

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
    }
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim()) ?? 0;
    return 0;
  }

  factory MamManagerProfileData.fromPool(dynamic pool) {
    try {
      final name = pool.name?.toString() ?? '';
      final rawLogin = pool.id?.toString() ?? '';
      final login = rawLogin.replaceAll(RegExp(r'[^0-9]'), '');
      final status = pool.status?.toString().toLowerCase() ?? '';

      return MamManagerProfileData(
        name: name,
        login: login,
        isLive: status == 'active',
        accountBalance: _toDouble(pool.totalAum),
        currentEquity: _toDouble(pool.currentEquity),
        performanceFee: _toDouble(pool.performanceFee),
        historicalGrowth: _toDouble(pool.monthlyRoi),
        riskProfile: pool.riskScore?.toString() ?? 'Unknown',
        trackRecordDays: _toInt(pool.trackRecordDays),
        execution: pool.execution?.toString() ?? '',
        isVerified: pool.isVerified == true,
      );
    } catch (error, stackTrace) {
      debugPrint('MAM manager profile parsing failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const MamManagerProfileData(name: '', login: '');
    }
  }

  factory MamManagerProfileData.fromMaster(MamMasterAccount master) {
    return MamManagerProfileData(
      name: master.name,
      login: master.login,
      isLive: master.status.toLowerCase() == 'active',
      accountBalance: master.balance,
      currentEquity: master.balance,
      performanceFee: master.profitShare,
      historicalGrowth: master.monthlyGain,
      riskProfile: master.risk,
      trackRecordDays: 0,
      execution: 'Unknown',
      isVerified: false,
    );
  }
}

// =============================================================================
// MODAL A: ESTABLISH MASTER MAM SHEET
// =============================================================================
class EstablishMasterMamSheet extends StatefulWidget {
  const EstablishMasterMamSheet({super.key, required this.onCreated});

  final ValueChanged<MamMasterAccount> onCreated;

  @override
  State<EstablishMasterMamSheet> createState() =>
      _EstablishMasterMamSheetState();
}

class _EstablishMasterMamSheetState extends State<EstablishMasterMamSheet> {
  final _strategyNameController = TextEditingController(
    text: '',
  );
  final _profitShareController = TextEditingController(text: '20');

  String _selectedRisk = 'Medium';
  String _selectedLeverage = '1:500';
  String _selectedPayout = 'Weekly (Default)';
  bool _isSubmitting = false;

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

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final strategyName = _strategyNameController.text.trim();
    final profitShare = double.tryParse(_profitShareController.text.trim());

    if (strategyName.isEmpty) {
      showAppMessage('Enter a name for your MAM master account.');
      return;
    }
    if (profitShare == null || !profitShare.isFinite ||
        profitShare < 0.01 || profitShare > 100) {
      showAppMessage('Enter a valid profit share percentage (0.01–100).');
      return;
    }

    final cleanPayout = _selectedPayout.replaceAll(' (Default)', '').toLowerCase();
    final payoutFrequency = switch (cleanPayout) {
      'daily' => 'weekly',
      'half-yearly' => 'half-yearly',
      'quarterly' => 'quarterly',
      'monthly' => 'monthly',
      _ => 'weekly',
    };

    setState(() => _isSubmitting = true);
    try {
      final response = await AuthApi.instance.createMamAccount(
        accountName: strategyName,
        leverage: _selectedLeverage,
        profitSharingPercentage: profitShare,
        riskLevel: _selectedRisk,
        payoutFrequency: payoutFrequency,
      );
      final accountId = (response['account_id'] ??
              (response['mam_account'] is Map
                  ? (response['mam_account'] as Map)['account_id']
                  : null))
          ?.toString();
      if (accountId == null || accountId.isEmpty) {
        throw const AuthApiException(
          'The server created no account ID in its response. Refresh your MAM accounts before retrying.',
        );
      }

      final newMaster = MamMasterAccount(
        name: (response['account_name'] ?? strategyName).toString(),
        login: accountId,
        profitShare: profitShare,
        leverage: _selectedLeverage,
        balance: 0.0,
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
        pendingRelease: 0.0,
        releasedPayout: 0.0,
        pendingWallet: 0.0,
        totalSettled: 0.0,
        tradesProcessed: 0,
      );

      if (!mounted) return;
      Navigator.pop(context);
      widget.onCreated(newMaster);
      // The sheet receives only the MT5 login generated by the backend.
      showAppMessage('MAM master account $accountId created successfully.');
    } catch (error) {
      if (!mounted) return;
      final message = error is AuthApiException
          ? error.message
          : 'MAM account could not be created. Please try again.';
      showAppMessage(message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: screen.height * .92,
            ),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
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
                                style: TextStyle(color: muted, fontSize: 11),
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
                          _sectionHeading('TRADING & RISK CONFIGURATION', '02'),
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
                            onPressed: _isSubmitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              foregroundColor: const Color(0xFF142238),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: _isSubmitting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF142238)))
                                : const Icon(LucideIcons.arrowRight, size: 18),
                            label: Text(
                              _isSubmitting ? 'CREATING MT5 ACCOUNT…' : 'ESTABLISH MASTER ACCOUNT',
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
                            Icon(
                              LucideIcons.shieldCheck,
                              color: muted,
                              size: 12,
                            ),
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
              color: isSelected
                  ? cs.primary.withValues(alpha: .10)
                  : cs.surface,
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
  }) => InputDecoration(
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
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
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
                          child: Icon(
                            LucideIcons.user,
                            color: c.blue,
                            size: 24,
                          ),
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
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: c.green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: c.green.withValues(alpha: 0.3),
                                      ),
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
                          value:
                              '\$${manager.accountBalance.toStringAsFixed(2)}',
                          valueColor: c.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'CURRENT EQUITY',
                          value:
                              '\$${manager.currentEquity.toStringAsFixed(2)}',
                          valueColor: c.text,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatBox(
                          c: c,
                          label: 'PERFORMANCE FEE',
                          value:
                              '${manager.performanceFee.toStringAsFixed(0)}%',
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
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    showAppMessage(
      'Successfully allocated to Manager (${widget.manager.login})!',
    );
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
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
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
                              child: Icon(
                                LucideIcons.user,
                                color: c.blue,
                                size: 20,
                              ),
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
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: c.green.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: c.green.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
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
                          _showConfirmPassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          color: c.muted,
                          size: 18,
                        ),
                        onPressed: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword,
                        ),
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

// -----------------------------------------------------------------------------
// EDIT COPY MULTIPLIERS / COEFFICIENT & SCALING CONFIGURATION MODAL
// -----------------------------------------------------------------------------
class EditCopyMultipliersModal extends StatefulWidget {
  const EditCopyMultipliersModal({
    super.key,
    this.accountId = '3511',
    this.initialMethod = 'BALANCE RATIO',
    this.initialFactor = 1.00,
    this.initialOrderCloning = false,
    this.initialCloneCount = 1,
    this.onDeploy,
  });

  final String accountId;
  final String initialMethod;
  final double initialFactor;
  final bool initialOrderCloning;
  final int initialCloneCount;
  final Future<void> Function(
    String method,
    double factor,
    bool orderCloning,
    int cloneCount,
  )?
  onDeploy;

  @override
  State<EditCopyMultipliersModal> createState() =>
      _EditCopyMultipliersModalState();
}

class _EditCopyMultipliersModalState extends State<EditCopyMultipliersModal> {
  late String _method;
  late double _factor;
  late bool _orderCloning;
  int _cloneCount = 1;
  bool _isDeploying = false;
  late final TextEditingController _factorController;

  static const List<double> _presets = [0.50, 1.00, 1.50, 2.00, 3.00];

  @override
  void initState() {
    super.initState();
    _method = widget.initialMethod;
    _factor = widget.initialFactor;
    _orderCloning = widget.initialOrderCloning;
    _cloneCount = widget.initialCloneCount < 1
        ? 1
        : widget.initialCloneCount > 5
        ? 5
        : widget.initialCloneCount;
    _factorController = TextEditingController(text: _factor.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _factorController.dispose();
    super.dispose();
  }

  Future<void> _deploy() async {
    if (_isDeploying) return;
    setState(() => _isDeploying = true);
    try {
      await widget.onDeploy?.call(
        _method,
        _factor,
        _orderCloning,
        _cloneCount,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isDeploying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _ModalColors.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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
          const SizedBox(height: 12),

          // Header: Icon + Title + Close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
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
                          color: c.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: c.blue.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          LucideIcons.shieldCheck,
                          size: 18,
                          color: c.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Coefficient & Scaling Configuration',
                          style: GoogleFonts.inter(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: c.muted, size: 20),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Target Account Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: c.subCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.subBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: c.card,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: c.border),
                              ),
                              child: Icon(
                                LucideIcons.sliders,
                                size: 16,
                                color: c.muted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TARGET ACCOUNT',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: c.muted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.accountId,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: c.text,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            'STP RISK ENGINE',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Section Label: SCALING METHODOLOGY
                  Text(
                    'SCALING METHODOLOGY',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: c.muted,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Segmented Switcher Pill
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: c.subCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.subBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _method = 'BALANCE RATIO';
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              decoration: BoxDecoration(
                                color: _method == 'BALANCE RATIO'
                                    ? c.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'BALANCE RATIO',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _method == 'BALANCE RATIO'
                                      ? Colors.white
                                      : c.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _method = 'FIXED RATIO';
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              decoration: BoxDecoration(
                                color: _method == 'FIXED RATIO'
                                    ? c.blue
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'FIXED RATIO',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _method == 'FIXED RATIO'
                                      ? Colors.white
                                      : c.muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Dynamic Subtext Box Directly Below Switcher
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: c.subCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.subBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.info, size: 16, color: c.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _method == 'BALANCE RATIO'
                                ? 'Trade sizes scale proportionally relative to your balance vs the manager\'s balance.'
                                : 'Executes fixed multiple of manager\'s lot size (e.g. 1.50 = 1.5x lot volume).',
                            style: GoogleFonts.inter(
                              color: c.text,
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Multiplication Factor Section (Rendered when FIXED RATIO is selected)
                  if (_method == 'FIXED RATIO') ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.subCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.subBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MULTIPLICATION FACTOR',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: c.muted,
                                ),
                              ),
                              Text(
                                'Default: 1.00x',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: c.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Field box
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: c.isDark
                                  ? const Color(0xFF0C1625)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: c.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _factorController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: c.text,
                                    ),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (val) {
                                      final parsed = double.tryParse(val);
                                      if (parsed != null && parsed > 0) {
                                        setState(() {
                                          _factor = parsed;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Text(
                                  'Multiple',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: c.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Quick factor chips row
                          Row(
                            children: _presets.map((f) {
                              final isSel = (_factor - f).abs() < 0.01;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.5,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _factor = f;
                                        _factorController.text = f
                                            .toStringAsFixed(2);
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 44,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSel ? c.blue : c.card,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isSel ? c.blue : c.border,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${f.toStringAsFixed(2)}x',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: isSel ? Colors.white : c.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Order Cloning (Multi-Execution) Tile
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: c.subCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: c.subBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order Cloning (Multi-Execution)',
                                    style: GoogleFonts.inter(
                                      color: c.text,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Clone each executed position into multiple distinct tickets',
                                    style: GoogleFonts.inter(
                                      color: c.muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _orderCloning,
                              activeThumbColor: c.blue,
                              onChanged: (val) {
                                setState(() {
                                  _orderCloning = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'POSITION CLONE COUNT',
                          style: GoogleFonts.inter(
                            color: c.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: _orderCloning ? 1 : 0.55,
                          child: Row(
                            children: [
                              for (var count = 1; count <= 5; count++) ...[
                                if (count > 1) const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 44,
                                    child: OutlinedButton(
                                      onPressed: _orderCloning
                                          ? () => setState(
                                              () => _cloneCount = count,
                                            )
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: _cloneCount == count
                                            ? c.blue
                                            : c.card,
                                        foregroundColor: _cloneCount == count
                                            ? Colors.white
                                            : c.text,
                                        side: BorderSide(
                                          color: _cloneCount == count
                                              ? c.blue
                                              : c.border,
                                        ),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '${count}x',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Footer Action Buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: c.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'DISMISS',
                              style: GoogleFonts.inter(
                                color: c.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _isDeploying ? null : _deploy,
                            icon: _isDeploying
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(LucideIcons.zap, size: 16),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isDeploying ? 'SAVING...' : 'DEPLOY CONFIGURATION',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: c.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
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
    isDismissible: true,
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
    isDismissible: true,
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
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) =>
        InvestInManagerModal(manager: manager, onConfirmed: onConfirmed),
  );
}

void showEditCopyMultipliersModal(
  BuildContext context, {
  String accountId = '3511',
  String initialMethod = 'BALANCE RATIO',
  double initialFactor = 1.00,
  bool initialOrderCloning = false,
  int initialCloneCount = 1,
  Future<void> Function(
    String method,
    double factor,
    bool orderCloning,
    int cloneCount,
  )?
  onDeploy,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => EditCopyMultipliersModal(
      accountId: accountId,
      initialMethod: initialMethod,
      initialFactor: initialFactor,
      initialOrderCloning: initialOrderCloning,
      initialCloneCount: initialCloneCount,
      onDeploy: onDeploy,
    ),
  );
}
