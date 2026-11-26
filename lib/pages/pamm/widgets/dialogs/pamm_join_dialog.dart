import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_dialogs.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

Future<void> showJoinPammInvestmentDialog(
  BuildContext context, {
  required PammPool pool,
  required Future<void> Function() onJoined,
}) async {
  final credentials = await showDialog<Map<String, String>?>(
    context: context,
    barrierDismissible: true,
    useSafeArea: false,
    builder: (_) => _JoinPammInvestmentDialog(
      pool: pool,
      onJoined: onJoined,
    ),
  );
  if (credentials != null && context.mounted) {
    await showPammCreatedCredentialsDialog(
      context,
      title: 'PAMM investment account created',
      accountName: credentials['name']!,
      login: credentials['login']!,
      investorPassword: credentials['investorPassword']!,
    );
  }
}

class _JoinPammInvestmentDialog extends StatefulWidget {
  const _JoinPammInvestmentDialog({
    required this.pool,
    required this.onJoined,
  });

  final PammPool pool;
  final Future<void> Function() onJoined;

  @override
  State<_JoinPammInvestmentDialog> createState() =>
      _JoinPammInvestmentDialogState();
}

class _JoinPammInvestmentDialogState extends State<_JoinPammInvestmentDialog> {
  final _alias = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _joining = false;

  @override
  void dispose() {
    _alias.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final muted = PammColors.muted(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: muted.withValues(alpha: .75),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: PammColors.blue),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppHaptics.lightImpact();
      return;
    }
    final pammId = int.tryParse(widget.pool.id);
    if (pammId == null) {
      AppHaptics.lightImpact();
      showPammMessage(
        context,
        'This pool is missing its account identifier. Refresh the list and try again.',
      );
      return;
    }
    AppHaptics.mediumImpact();
    setState(() => _joining = true);
    try {
      final response = await AuthApi.instance.investInPamm(
        pammId: pammId,
        investorName: _alias.text.trim(),
      );
      await widget.onJoined();
      if (!mounted) return;
      Navigator.pop(context, <String, String>{
        'name': pammStringValue(
          response,
          const ['pamm_name'],
          fallback: widget.pool.name,
        ),
        'login': pammStringValue(
          response,
          const ['mt5_account_id'],
          fallback: 'Pending',
        ),
        'investorPassword': pammStringValue(
          response,
          const ['invest_password'],
          fallback: 'Not returned',
        ),
      });
    } catch (error) {
      if (mounted) {
        AppHaptics.lightImpact();
        setState(() => _joining = false);
        showPammMessage(
          context,
          error is AuthApiException
              ? error.message
              : 'Unable to join this PAMM pool.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = PammColors.card(context);
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    Widget fieldLabel(String label) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: .35,
            ),
          ),
        );

    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Dialog(
      alignment: Alignment.bottomCenter,
      backgroundColor: card,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: border),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: (screenHeight - keyboardBottom)
              .clamp(240.0, screenHeight * .9),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: PammColors.blue.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.usersRound,
                      color: PammColors.blue,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join PAMM Investment Pool',
                          style: TextStyle(
                            color: text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Review pool terms and create your investment account',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      AppHaptics.lightImpact();
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    },
                    tooltip: 'Close',
                    icon: Icon(Icons.close, color: muted, size: 18),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fieldLabel('INVESTOR ACCOUNT ALIAS'),
                      TextFormField(
                        controller: _alias,
                        textCapitalization: TextCapitalization.words,
                        style: TextStyle(
                          color: text,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _inputDecoration('e.g. My PAMM Investment'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter an account alias'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      fieldLabel('TARGET PAMM MT5 LOGIN'),
                      TextFormField(
                        initialValue: widget.pool.login,
                        readOnly: true,
                        style: TextStyle(
                          color: text,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _inputDecoration(''),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(13),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          PammColors.blue.withValues(alpha: .1),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: PammColors.blue,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pool details',
                                          style: TextStyle(
                                            color: text,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Review the manager settings before joining',
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: border),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'ACCOUNT DETAILS',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: .4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: PammPoolValue(
                                          label: 'Manager / pool name',
                                          value: widget.pool.name,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: PammPoolValue(
                                          label: 'Leverage',
                                          value: widget.pool.leverage,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: PammPoolValue(
                                          label: 'Platform',
                                          value: 'MetaTrader 5 (MT5)',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: PammPoolValue(
                                          label: 'MT5 server',
                                          value: widget.pool.server,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 13),
                                  Divider(height: 1, color: border),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'INVESTMENT TERMS',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: .4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: PammPoolValue(
                                          label: 'Pool equity',
                                          value:
                                              formatPammMoney(widget.pool.equity),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: PammPoolValue(
                                          label: 'Manager profit share',
                                          value:
                                              '${widget.pool.share.toStringAsFixed(2)}%',
                                          valueColor: PammColors.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 13),
                                  Divider(height: 1, color: border),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Investment availability',
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      PammStatusPill(
                                        status: widget.pool.status == 'Open'
                                            ? 'Open for investors'
                                            : 'Closed',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Manager profit share is the percentage of eligible profits allocated to the manager, according to the platform’s PAMM rules. Trading returns are variable and are not guaranteed.',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
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
            Divider(height: 1, color: border),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                9,
                16,
                10 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        AppHaptics.lightImpact();
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: text,
                        side: BorderSide(color: border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed:
                          widget.pool.status != 'Open' || _joining ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: PammColors.gold,
                        foregroundColor: const Color(0xFF17233D),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _joining ? 'Joining…' : 'Confirm Investment',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
