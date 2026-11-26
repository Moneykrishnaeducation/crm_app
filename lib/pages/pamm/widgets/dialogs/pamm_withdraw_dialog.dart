import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';

typedef PammWithdrawalEligibility = ({
  bool approved,
  bool hasBank,
  bool hasCrypto,
  String bankName,
  String bankAccount,
  String wallet,
  String currency,
});

Future<PammWithdrawalEligibility> _fetchPammWithdrawalEligibility() async {
  Map<String, dynamic> profile = {};
  List<Map<String, dynamic>> documents = const [];
  Map<String, dynamic> bank = {};
  Map<String, dynamic> crypto = {};
  try {
    profile = unwrapPammApiMap(await AuthApi.instance.getProfile());
  } catch (_) {}
  try {
    documents = extractPammRows(await AuthApi.instance.getProfileDocuments());
  } catch (_) {}
  try {
    bank = unwrapPammApiMap(await AuthApi.instance.getBankDetails());
  } catch (_) {}
  try {
    crypto = unwrapPammApiMap(await AuthApi.instance.getCryptoDetails());
  } catch (_) {}

  bool approvedDocument(String type) => documents.any((document) {
        final docType =
            pammStringValue(document, const ['document_type']).toLowerCase();
        final status = pammStringValue(
          document,
          const ['status', 'verification_status'],
        ).toLowerCase();
        return docType == type &&
            (status == 'approved' || status == 'verified');
      });

  final identityVerified = approvedDocument('identity') ||
      pammStringValue(profile, const ['id_status']).toLowerCase() == 'approved';
  final residenceVerified = approvedDocument('residence') ||
      pammStringValue(profile, const ['address_status']).toLowerCase() ==
          'approved';
  final phone =
      pammStringValue(profile, const ['phone', 'phone_number']).trim();
  final dob = pammStringValue(profile, const ['dob', 'date_of_birth']).trim();
  final hasLocation =
      pammStringValue(profile, const ['address']).trim().isNotEmpty ||
          pammStringValue(profile, const ['city']).trim().isNotEmpty ||
          pammStringValue(profile, const ['country']).trim().isNotEmpty;
  final personallyComplete = phone.isNotEmpty && dob.isNotEmpty && hasLocation;
  final verifiedFlag = profile['user_verified'] == true ||
      (identityVerified && residenceVerified && personallyComplete);
  final bankAccount = pammStringValue(bank, const ['account_number']).trim();
  final wallet = pammStringValue(
    crypto,
    const ['wallet_address', 'wallet_id', 'wallet'],
  ).trim();
  return (
    approved: verifiedFlag,
    hasBank: bankAccount.isNotEmpty,
    hasCrypto: wallet.isNotEmpty,
    bankName:
        pammStringValue(bank, const ['bank_name'], fallback: 'Bank account'),
    bankAccount: bankAccount,
    wallet: wallet,
    currency: pammStringValue(crypto, const ['currency'], fallback: 'USDT'),
  );
}

Future<void> showPammWithdrawDialog(
  BuildContext context, {
  required String accountName,
  required String pammId,
  required bool isManager,
  required double availableBalance,
  required Future<void> Function() onSuccess,
}) async {
  if (pammId.trim().isEmpty) {
    showPammMessage(
      context,
      'The PAMM identifier is missing. Refresh the account list and try again.',
    );
    return;
  }
  final parsedPammId = int.tryParse(pammId);
  if (parsedPammId == null) {
    showPammMessage(
      context,
      'The PAMM identifier is invalid. Refresh the account list and try again.',
    );
    return;
  }
  final eligibility = await _fetchPammWithdrawalEligibility();
  if (!context.mounted) return;
  if (!eligibility.approved) {
    showPammMessage(
      context,
      'Withdrawals are available after identity and address verification are approved.',
    );
    return;
  }
  if (!eligibility.hasBank && !eligibility.hasCrypto) {
    showPammMessage(
      context,
      'Add a bank account or crypto wallet in Profile payment methods before withdrawing.',
    );
    return;
  }

  final submitted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PammWithdrawSheet(
      accountName: accountName,
      parsedPammId: parsedPammId,
      isManager: isManager,
      availableBalance: availableBalance,
      eligibility: eligibility,
    ),
  );
  if (submitted == true && context.mounted) {
    await onSuccess();
    if (context.mounted) {
      showPammMessage(context, 'Withdrawal request submitted successfully.');
    }
  }
}

class _PammWithdrawSheet extends StatefulWidget {
  const _PammWithdrawSheet({
    required this.accountName,
    required this.parsedPammId,
    required this.isManager,
    required this.availableBalance,
    required this.eligibility,
  });

  final String accountName;
  final int parsedPammId;
  final bool isManager;
  final double availableBalance;
  final PammWithdrawalEligibility eligibility;

  @override
  State<_PammWithdrawSheet> createState() => _PammWithdrawSheetState();
}

class _PammWithdrawSheetState extends State<_PammWithdrawSheet> {
  final _amount = TextEditingController();
  late String _method = widget.eligibility.hasCrypto ? 'usdt' : 'bank';
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final value = double.tryParse(_amount.text.trim().replaceAll(',', ''));
    if (value == null || !value.isFinite || value <= 0) {
      AppHaptics.lightImpact();
      setState(
        () => _errorMessage = 'Enter a valid amount greater than zero.',
      );
      return;
    }
    if (value > widget.availableBalance) {
      AppHaptics.lightImpact();
      setState(
        () => _errorMessage = 'Amount exceeds your available balance.',
      );
      return;
    }
    AppHaptics.mediumImpact();
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await AuthApi.instance.requestPammWithdrawal(
        pammId: widget.parsedPammId,
        amount: value,
        method: _method == 'bank' ? 'manual' : _method,
        isManager: widget.isManager,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      AppHaptics.lightImpact();
      setState(() {
        _submitting = false;
        _errorMessage = error is AuthApiException
            ? error.message
            : 'Withdrawal request could not be submitted.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final card = PammColors.card(context);
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    final eligibility = widget.eligibility;
    final currency = eligibility.currency;
    final destination = _method == 'usdt'
        ? '$currency wallet ending ${eligibility.wallet.length > 4 ? eligibility.wallet.substring(eligibility.wallet.length - 4) : eligibility.wallet}'
        : '${eligibility.bankName} ending ${eligibility.bankAccount.length > 4 ? eligibility.bankAccount.substring(eligibility.bankAccount.length - 4) : eligibility.bankAccount}';

    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight =
        (screenHeight - keyboardBottom).clamp(240.0, screenHeight * .9);

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardBottom),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: maxHeight,
        ),
        decoration: BoxDecoration(
          color: card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: border),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Withdraw funds',
                            style: TextStyle(
                              color: text,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.accountName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: muted, fontSize: 12),
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
                      icon: Icon(Icons.close, color: muted),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B328D), Color(0xFF315FEA)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AVAILABLE TO WITHDRAW',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              formatPammMoney(widget.availableBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              destination,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'PAYOUT METHOD',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (eligibility.hasCrypto)
                            ChoiceChip(
                              label: Text('$currency wallet'),
                              selected: _method == 'usdt',
                              onSelected: (_) {
                                AppHaptics.selectionClick();
                                FocusScope.of(context).unfocus();
                                setState(() => _method = 'usdt');
                              },
                            ),
                          if (eligibility.hasBank)
                            ChoiceChip(
                              label: const Text('Bank transfer'),
                              selected: _method == 'bank',
                              onSelected: (_) {
                                AppHaptics.selectionClick();
                                FocusScope.of(context).unfocus();
                                setState(() => _method = 'bank');
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AMOUNT (USD)',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() => _errorMessage = null),
                        style: TextStyle(
                          color: text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: r'$ ',
                          filled: true,
                          fillColor: surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: border),
                          ),
                        ),
                      ),
                      if (widget.availableBalance > 0) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: const [
                            (label: '25%', factor: 0.25),
                            (label: '50%', factor: 0.50),
                            (label: '75%', factor: 0.75),
                            (label: '100%', factor: 1.00),
                          ].map((preset) {
                            final presetText =
                                (widget.availableBalance * preset.factor)
                                    .toStringAsFixed(2);
                            return ChoiceChip(
                              label: Text(preset.label),
                              selected: _amount.text.trim() == presetText,
                              onSelected: (_) {
                                AppHaptics.selectionClick();
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _amount.text = presetText;
                                  _errorMessage = null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _submitting ? null : _submit,
                          icon: _submitting
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_upward, size: 17),
                          label: Text(
                            _submitting ? 'Submitting…' : 'Submit withdrawal',
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'The server will verify your KYC, payout details, and available balance.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
