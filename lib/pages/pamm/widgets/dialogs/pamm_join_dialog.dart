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
  String? _errorMessage;

  @override
  void dispose() {
    _alias.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefixIcon}) =>
      PammDecorations.input(
        context,
        hint: hint,
        prefixIcon: prefixIcon,
      );

  Future<void> _submit() async {
    if (_joining) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppHaptics.lightImpact();
      return;
    }
    final pammId = int.tryParse(widget.pool.id);
    if (pammId == null) {
      AppHaptics.lightImpact();
      setState(
        () => _errorMessage =
            'This pool is missing its account identifier. Refresh the list and try again.',
      );
      return;
    }
    AppHaptics.mediumImpact();
    setState(() {
      _joining = true;
      _errorMessage = null;
    });
    try {
      final response = await AuthApi.instance.investInPamm(
        pammId: pammId,
        investorName: _alias.text.trim(),
      );
      final unwrapped = unwrapPammApiMap(response);
      final investmentMap = unwrapped['investment'] is Map
          ? (unwrapped['investment'] as Map).cast<String, dynamic>()
          : unwrapped;
      final credentials = <String, String>{
        'name': pammStringValue(
          unwrapped,
          const ['pamm_name', 'pam_account_name', 'pool_name', 'name'],
          fallback: pammStringValue(
            investmentMap,
            const ['pamm_name', 'pam_account_name', 'pool_name', 'name'],
            fallback: widget.pool.name,
          ),
        ),
        'login': pammStringValue(
          investmentMap,
          const ['mt5_account_id', 'pamm_mt5_account_id', 'login'],
          fallback: pammStringValue(
            unwrapped,
            const ['mt5_account_id', 'pamm_mt5_account_id', 'login'],
            fallback: 'Pending',
          ),
        ),
        'investorPassword': pammStringValue(
          unwrapped,
          const ['invest_password', 'investor_password'],
          fallback: pammStringValue(
            investmentMap,
            const ['invest_password', 'investor_password'],
            fallback: 'Not returned',
          ),
        ),
      };
      await widget.onJoined();
      if (!mounted) return;
      Navigator.pop(context, credentials);
    } catch (error) {
      if (mounted) {
        AppHaptics.lightImpact();
        setState(() {
          _joining = false;
          _errorMessage = error is AuthApiException
              ? error.message
              : 'Unable to join this PAMM pool.';
        });
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
            style: PammType.label(
              context,
              size: 10.5,
              color: muted,
              letterSpacing: 0.5,
            ),
          ),
        );

    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: !_joining,
      child: Dialog(
        alignment: Alignment.bottomCenter,
        backgroundColor: card,
        insetPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: border),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 540,
            maxHeight: (screenHeight - keyboardBottom)
                .clamp(240.0, screenHeight * 0.9),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [PammColors.blue, PammColors.deepBlue],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: PammColors.blue.withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.usersRound,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Join PAMM Investment Pool',
                            style: PammType.heading(context, size: 17),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Review pool terms and create your investment account',
                            style: PammType.body(
                              context,
                              size: 12,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _joining
                          ? null
                          : () {
                              AppHaptics.lightImpact();
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            },
                      tooltip: 'Close',
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      icon: Icon(Icons.close, color: muted, size: 20),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: border),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fieldLabel('INVESTOR ACCOUNT ALIAS'),
                        TextFormField(
                          controller: _alias,
                          enabled: !_joining,
                          onChanged: (_) {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                          textCapitalization: TextCapitalization.words,
                          style: PammType.body(
                            context,
                            size: 13.5,
                            weight: FontWeight.w600,
                            color: text,
                          ),
                          decoration: _inputDecoration(
                            'e.g. My PAMM Investment',
                            prefixIcon: Icon(
                              LucideIcons.userCheck,
                              size: 16,
                              color: muted,
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter an account alias'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        fieldLabel('TARGET PAMM MT5 LOGIN'),
                        TextFormField(
                          initialValue: widget.pool.login,
                          readOnly: true,
                          style: PammType.figure(
                            context,
                            size: 14,
                            weight: FontWeight.w700,
                            color: text,
                          ),
                          decoration: _inputDecoration(
                            '',
                            prefixIcon: Icon(
                              LucideIcons.hash,
                              size: 16,
                              color: muted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: PammColors.blue
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        LucideIcons.info,
                                        color: PammColors.blue,
                                        size: 17,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pool details',
                                            style: PammType.heading(
                                              context,
                                              size: 14,
                                            ),
                                          ),
                                          Text(
                                            'Review the manager settings before joining',
                                            style: PammType.body(
                                              context,
                                              size: 11.5,
                                              color: muted,
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
                                        style: PammType.label(
                                          context,
                                          size: 10.5,
                                          color: muted,
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
                                    const SizedBox(height: 14),
                                    Divider(height: 1, color: border),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'INVESTMENT TERMS',
                                        style: PammType.label(
                                          context,
                                          size: 10.5,
                                          color: muted,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: PammPoolValue(
                                            label: 'Pool equity',
                                            value: formatPammMoney(
                                              widget.pool.equity,
                                            ),
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
                                    const SizedBox(height: 14),
                                    Divider(height: 1, color: border),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Investment availability',
                                            style: PammType.body(
                                              context,
                                              size: 12,
                                              weight: FontWeight.w600,
                                              color: muted,
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
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: PammColors.blue
                                            .withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Manager profit share is the percentage of eligible profits allocated to the manager, according to the platform’s PAMM rules. Trading returns are variable and are not guaranteed.',
                                        style: PammType.body(
                                          context,
                                          size: 11.5,
                                          color: muted,
                                          height: 1.45,
                                        ),
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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: PammColors.rose.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PammColors.rose.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: PammColors.negative(context),
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: PammType.body(
                              context,
                              size: 12.5,
                              weight: FontWeight.w600,
                              color: PammColors.negative(context),
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
                  20,
                  12,
                  20,
                  12 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _joining
                            ? null
                            : () {
                                AppHaptics.lightImpact();
                                FocusScope.of(context).unfocus();
                                Navigator.pop(context);
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: text,
                          side: BorderSide(color: border),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: PammType.body(
                            context,
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: widget.pool.status != 'Open' || _joining
                            ? null
                            : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: PammColors.gold,
                          foregroundColor: const Color(0xFF17233D),
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_joining) ...[
                              const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF17233D),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              _joining ? 'Joining…' : 'Confirm Investment',
                              style: PammType.body(
                                context,
                                size: 13.5,
                                weight: FontWeight.w700,
                                color: const Color(0xFF17233D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
