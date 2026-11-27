import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_notifications.dart';
import '../../../services/auth_api.dart';
import '../models/partnership_models.dart';
import '../widgets/partnership_theme.dart';

// ============================================================================
// SUB-PAGE: BROKERCOMMISSIONWITHDRAWALPAGE (COMMISSION WITHDRAWAL)
// ============================================================================

class BrokerCommissionWithdrawalPage extends StatefulWidget {
  const BrokerCommissionWithdrawalPage({super.key});

  @override
  State<BrokerCommissionWithdrawalPage> createState() => _BrokerCommissionWithdrawalPageState();
}

class _BrokerCommissionWithdrawalPageState extends State<BrokerCommissionWithdrawalPage> {
  bool _loading = true;
  String? _loadError;
  double _availableBalance = 0.0;
  List<Map<String, dynamic>> _tradingAccounts = [];
  String? _selectedAccountId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool _isDemoAccount(Map<String, dynamic> account) {
    if (account['is_demo'] == true) return true;
    final accountType = (account['account_type'] ?? '').toString().trim().toLowerCase();
    if (accountType == 'demo' || accountType.contains('demo')) return true;
    final group = (account['group'] ??
            account['group_name'] ??
            account['group_alias'] ??
            account['server'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();
    return group.contains('demo');
  }

  String _accountIdOf(Map<String, dynamic> account) =>
      (account['account_id'] ?? account['id'] ?? '').toString().trim();

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      String? errorMsg;
      final results = await Future.wait([
        AuthApi.instance.getIbStats().catchError((Object e) {
          errorMsg ??= e is AuthApiException
              ? e.message
              : 'Unable to load IB commission balance.';
          return <String, dynamic>{};
        }),
        AuthApi.instance.getNonDemoAccounts(fresh: true).catchError((Object e) {
          errorMsg ??= e is AuthApiException
              ? e.message
              : 'Unable to load destination MT5 accounts.';
          return <String, dynamic>{};
        }),
      ]);

      final stats = results[0];
      final accRes = results[1];

      final rawAccounts = extractPartnershipList(
        accRes,
        keys: const ['accounts', 'results', 'data'],
      );
      final accList = <Map<String, dynamic>>[];
      final seenIds = <String>{};
      for (final item in rawAccounts) {
        final id = _accountIdOf(item);
        if (id.isEmpty || _isDemoAccount(item)) continue;
        if (seenIds.add(id)) {
          accList.add(<String, dynamic>{...item, 'account_id': id});
        }
      }

      final bal = parseDouble(stats['commission_balance']);
      final currentSelected = _selectedAccountId?.trim();
      final nextSelected = (currentSelected != null &&
              currentSelected.isNotEmpty &&
              seenIds.contains(currentSelected))
          ? currentSelected
          : (accList.isNotEmpty ? _accountIdOf(accList.first) : null);

      if (!mounted) return;
      setState(() {
        _availableBalance = bal;
        _tradingAccounts = accList;
        _selectedAccountId = nextSelected;
        _loadError = errorMsg;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Unable to load withdrawal details. Please try again.';
        _loading = false;
      });
    }
  }

  void _setPercent(double percent) {
    final amt = (_availableBalance * percent).clamp(0.0, _availableBalance);
    _amountController.text = amt.toStringAsFixed(2);
    setState(() {});
  }

  Future<void> _submitWithdrawal() async {
    FocusScope.of(context).unfocus();
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
      AppHaptics.lightImpact();
      showAppMessage('Please select a destination MT5 trading account.');
      return;
    }
    if (amt <= 0 || amt > _availableBalance) {
      AppHaptics.lightImpact();
      showAppMessage('Please enter a valid withdrawal amount up to \$${_availableBalance.toStringAsFixed(2)}');
      return;
    }

    AppHaptics.mediumImpact();
    setState(() => _submitting = true);
    try {
      await AuthApi.instance.requestIbWithdrawal(
        amount: amt,
        accountId: _selectedAccountId!,
        comment: _commentController.text.trim(),
      );
      showAppMessage('Withdrawal request submitted successfully!');
      if (!mounted) return;
      _amountController.clear();
      _commentController.clear();
      await _loadData();
    } catch (e) {
      AppHaptics.lightImpact();
      showAppMessage('Withdrawal failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final remaining = math.max(0.0, _availableBalance - amt);
    final exceedsBalance = !_loading && amt > _availableBalance;
    final hasAccount = _selectedAccountId != null && _selectedAccountId!.isNotEmpty;
    final canSubmit = !_loading && !_submitting && hasAccount && amt > 0 && !exceedsBalance;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Commission Withdrawal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    AppHaptics.lightImpact();
                    _loadData();
                  },
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: PartnershipBackdrop(
          colors: colors,
          child: RefreshIndicator(
            color: colors.blue,
            backgroundColor: colors.card,
            onRefresh: _loadData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
              children: [
                PartnershipSkeletonizer(
                  colors: colors,
                  enabled: _loading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_loading && _loadError != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.red.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.triangleAlert, size: 16, color: colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _loadError!,
                                  style: TextStyle(color: colors.red, fontSize: 11.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                              TextButton(
                                onPressed: _loadData,
                                child: Text('Retry', style: TextStyle(color: colors.red, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Balance Banner
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [colors.blue, const Color(0xFF1E3A8A)]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available for Withdrawal',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${_availableBalance.toStringAsFixed(2)} USD',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Remaining after transfer: \$${remaining.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Destination Account Selector
                      Text(
                        'SELECT MT5 DESTINATION ACCOUNT',
                        style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _tradingAccounts.any((a) => _accountIdOf(a) == _selectedAccountId)
                                ? _selectedAccountId
                                : null,
                            isExpanded: true,
                            dropdownColor: colors.card,
                            iconEnabledColor: colors.blue,
                            hint: Text(
                              _tradingAccounts.isEmpty ? 'No live MT5 accounts found' : 'Select Destination Account',
                              style: TextStyle(color: colors.muted, fontSize: 13),
                            ),
                            style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w700),
                            items: _tradingAccounts.map((a) {
                              final id = _accountIdOf(a);
                              final type = (a['account_type'] ?? 'Live MT5').toString();
                              final bal = (a['balance'] ?? '0.00').toString();
                              return DropdownMenuItem(
                                value: id,
                                child: Text('$id ($type) · Bal: \$$bal', overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                AppHaptics.selectionClick();
                                setState(() => _selectedAccountId = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Amount Input
                      Text(
                        'WITHDRAWAL AMOUNT (USD)',
                        style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: exceedsBalance ? colors.red : colors.border),
                        ),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.w800),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: colors.muted),
                            border: InputBorder.none,
                            prefixText: '\$ ',
                            prefixStyle: TextStyle(color: colors.blue, fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (exceedsBalance) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Exceeds available balance (\$${_availableBalance.toStringAsFixed(2)})',
                            style: TextStyle(
                              color: colors.red,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      // Percentage Presets
                      Row(
                        children: [
                          _percentBtn(colors, '25%', (_loading || _availableBalance <= 0) ? null : () => _setPercent(0.25)),
                          const SizedBox(width: 8),
                          _percentBtn(colors, '50%', (_loading || _availableBalance <= 0) ? null : () => _setPercent(0.50)),
                          const SizedBox(width: 8),
                          _percentBtn(colors, '75%', (_loading || _availableBalance <= 0) ? null : () => _setPercent(0.75)),
                          const SizedBox(width: 8),
                          _percentBtn(colors, '100% (Max)', (_loading || _availableBalance <= 0) ? null : () => _setPercent(1.0)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Comment
                      Text(
                        'TRANSFER COMMENT (OPTIONAL)',
                        style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.border),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(color: colors.text, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'e.g. Weekly commission withdrawal',
                            hintStyle: TextStyle(color: colors.muted, fontSize: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      FilledButton.icon(
                        onPressed: canSubmit ? _submitWithdrawal : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.blue,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(LucideIcons.arrowUpRight, size: 18),
                        label: Text(
                          _submitting ? 'Transferring...' : 'Transfer to MT5 Account',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _percentBtn(PartnershipColors colors, String label, VoidCallback? onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap == null
            ? null
            : () {
                AppHaptics.selectionClick();
                onTap();
              },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: onTap == null ? colors.muted : colors.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
