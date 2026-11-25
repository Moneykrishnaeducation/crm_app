import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_notifications.dart';
import '../../../services/auth_api.dart';
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

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AuthApi.instance.getIbStats().catchError((_) => <String, dynamic>{}),
        AuthApi.instance.getUserTradingAccounts().catchError((_) => <String, dynamic>{}),
      ]);

      final stats = results[0];
      final accRes = results[1];

      final rawAccounts = accRes['accounts'] ?? (accRes['data'] is List ? accRes['data'] : []);
      final accList = <Map<String, dynamic>>[];
      if (rawAccounts is List) {
        for (final item in rawAccounts.whereType<Map>()) {
          accList.add(item.cast<String, dynamic>());
        }
      }

      double bal = 0.0;
      if (stats['commission_balance'] is num) {
        bal = (stats['commission_balance'] as num).toDouble();
      } else if (stats['commission_balance'] is String) {
        bal = double.tryParse(stats['commission_balance']) ?? 0.0;
      }

      if (mounted) {
        setState(() {
          _availableBalance = bal;
          _tradingAccounts = accList;
          if (accList.isNotEmpty) {
            _selectedAccountId = (accList[0]['account_id'] ?? '').toString();
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setPercent(double percent) {
    final amt = (_availableBalance * percent).clamp(0.0, _availableBalance);
    _amountController.text = amt.toStringAsFixed(2);
    setState(() {});
  }

  Future<void> _submitWithdrawal() async {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (_selectedAccountId == null || _selectedAccountId!.isEmpty) {
      showAppMessage('Please select a destination MT5 trading account.');
      return;
    }
    if (amt <= 0 || amt > _availableBalance) {
      showAppMessage('Please enter a valid withdrawal amount up to \$${_availableBalance.toStringAsFixed(2)}');
      return;
    }

    setState(() => _submitting = true);
    try {
      await AuthApi.instance.requestIbWithdrawal(
        amount: amt,
        accountId: _selectedAccountId!,
        comment: _commentController.text.trim(),
      );
      showAppMessage('Withdrawal request submitted successfully!');
      _amountController.clear();
      _commentController.clear();
      await _loadData();
    } catch (e) {
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

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Commission Withdrawal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
      body: PartnershipBackdrop(
        colors: colors,
        child: _loading
            ? Center(child: CircularProgressIndicator(color: colors.blue))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
                children: [
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
                        value: _tradingAccounts.any((a) => (a['account_id'] ?? '').toString() == _selectedAccountId)
                            ? _selectedAccountId
                            : null,
                        isExpanded: true,
                        dropdownColor: colors.card,
                        iconEnabledColor: colors.blue,
                        hint: Text(
                          _tradingAccounts.isEmpty ? 'No MT5 accounts found' : 'Select Destination Account',
                          style: TextStyle(color: colors.muted, fontSize: 13),
                        ),
                        style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w700),
                        items: _tradingAccounts.map((a) {
                          final id = (a['account_id'] ?? '').toString();
                          final type = (a['account_type'] ?? 'Standard').toString();
                          final bal = (a['balance'] ?? '0.00').toString();
                          return DropdownMenuItem(
                            value: id,
                            child: Text('$id ($type) · Bal: \$$bal', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedAccountId = val);
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
                      border: Border.all(color: colors.border),
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
                  const SizedBox(height: 10),
                  // Percentage Presets
                  Row(
                    children: [
                      _percentBtn(colors, '25%', () => _setPercent(0.25)),
                      const SizedBox(width: 8),
                      _percentBtn(colors, '50%', () => _setPercent(0.50)),
                      const SizedBox(width: 8),
                      _percentBtn(colors, '75%', () => _setPercent(0.75)),
                      const SizedBox(width: 8),
                      _percentBtn(colors, '100% (Max)', () => _setPercent(1.0)),
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
                    onPressed: _submitting ? null : _submitWithdrawal,
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
    );
  }

  Widget _percentBtn(PartnershipColors colors, String label, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: TextStyle(color: colors.text, fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
