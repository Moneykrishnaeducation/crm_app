import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:crm_app/widgets/shake_feedback.dart';
import 'package:flutter/material.dart';

typedef PammWithdrawalEligibility = ({
  bool approved,
  bool hasBank,
  bool hasCrypto,
  String bankName,
  String bankAccount,
  String wallet,
  String currency,
  String? error,
});

bool _withdrawDialogActive = false;

String _pammEligibilityErrorMessage(Object error) {
  if (error is AuthApiException) {
    if (error.statusCode != null && error.statusCode! >= 500) {
      return 'Unable to verify withdrawal eligibility right now. Please try again shortly.';
    }
    if (error.message.trim().isNotEmpty) {
      return error.message;
    }
  }
  return 'Unable to verify withdrawal eligibility due to a network or server error. Please try again.';
}

@visibleForTesting
Future<PammWithdrawalEligibility> fetchPammWithdrawalEligibility() async {
  PammWithdrawalEligibility failure(Object error) => (
        approved: false,
        hasBank: false,
        hasCrypto: false,
        bankName: 'Bank account',
        bankAccount: '',
        wallet: '',
        currency: 'USDT',
        error: _pammEligibilityErrorMessage(error),
      );

  late final Map<String, dynamic> profile;
  late final List<Map<String, dynamic>> documents;
  var bank = <String, dynamic>{};
  var crypto = <String, dynamic>{};

  try {
    profile = unwrapPammApiMap(await AuthApi.instance.getProfile());
  } catch (error) {
    return failure(error);
  }
  try {
    documents = extractPammRows(await AuthApi.instance.getProfileDocuments());
  } catch (error) {
    return failure(error);
  }
  try {
    bank = unwrapPammApiMap(await AuthApi.instance.getBankDetails());
  } catch (error) {
    if (error is! AuthApiException || error.statusCode != 404) {
      return failure(error);
    }
  }
  try {
    crypto = unwrapPammApiMap(await AuthApi.instance.getCryptoDetails());
  } catch (error) {
    if (error is! AuthApiException || error.statusCode != 404) {
      return failure(error);
    }
  }

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
  final rawBankAccount = pammStringValue(bank, const ['account_number']).trim();
  final bankAccount = rawBankAccount == '—' ? '' : rawBankAccount;
  final rawWallet = pammStringValue(
    crypto,
    const ['wallet_address', 'wallet_id', 'wallet'],
  ).trim();
  final wallet = rawWallet == '—' ? '' : rawWallet;
  return (
    approved: verifiedFlag,
    hasBank: bankAccount.isNotEmpty,
    hasCrypto: wallet.isNotEmpty,
    bankName:
        pammStringValue(bank, const ['bank_name'], fallback: 'Bank account'),
    bankAccount: bankAccount,
    wallet: wallet,
    currency: pammStringValue(crypto, const ['currency'], fallback: 'USDT'),
    error: null,
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
  if (_withdrawDialogActive) return;
  if (pammId.trim().isEmpty) {
    showPammMessage(
      context,
      'The PAMM identifier is missing. Refresh the account list and try again.',
      isError: true,
    );
    return;
  }
  final parsedPammId = int.tryParse(pammId);
  if (parsedPammId == null) {
    showPammMessage(
      context,
      'The PAMM identifier is invalid. Refresh the account list and try again.',
      isError: true,
    );
    return;
  }

  _withdrawDialogActive = true;
  bool? submitted;
  try {
    final eligibility = await fetchPammWithdrawalEligibility();
    if (!context.mounted) return;
    if (eligibility.error != null) {
      showPammMessage(context, eligibility.error!, isError: true);
      return;
    }
    if (!eligibility.approved) {
      showPammMessage(
        context,
        'Withdrawals are available after identity and address verification are approved.',
        isError: true,
      );
      return;
    }
    if (!eligibility.hasBank && !eligibility.hasCrypto) {
      showPammMessage(
        context,
        'Add a bank account or crypto wallet in Profile payment methods before withdrawing.',
        isError: true,
      );
      return;
    }

    submitted = await showModalBottomSheet<bool>(
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
  } finally {
    _withdrawDialogActive = false;
  }
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
  final _shakeController = ShakeController();
  late String _method = widget.eligibility.hasCrypto ? 'usdt' : 'bank';
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _shakeController.dispose();
    _amount.dispose();
    super.dispose();
  }

  String _presetAmountText(double factor) {
    final raw =
        (widget.availableBalance * factor).clamp(0.0, widget.availableBalance);
    var cents = ((raw * 100) + 1e-9).floor();
    if (cents / 100.0 > widget.availableBalance && cents > 0) {
      cents -= 1;
    }
    return (cents / 100.0).toStringAsFixed(2);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    final value = parsePammDouble(_amount.text);
    if (value == null || value <= 0) {
      _shakeController.shake();
      setState(
        () => _errorMessage = 'Enter a valid amount greater than zero.',
      );
      return;
    }
    if (value > widget.availableBalance) {
      _shakeController.shake();
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
      _shakeController.shake();
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
    final screen = MediaQuery.sizeOf(context);
    final compact = screen.width < 600;
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = PammColors.isDark(context);
    final card = PammColors.card(context);
    final surface = PammColors.surface(context);
    final subtle = PammColors.subtle(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final positive = PammColors.positive(context);
    final negative = PammColors.negative(context);

    final eligibility = widget.eligibility;
    final currency = eligibility.currency;
    final destination = _method == 'usdt'
        ? '$currency wallet ending ${eligibility.wallet.length > 4 ? eligibility.wallet.substring(eligibility.wallet.length - 4) : eligibility.wallet}'
        : '${eligibility.bankName} ending ${eligibility.bankAccount.length > 4 ? eligibility.bankAccount.substring(eligibility.bankAccount.length - 4) : eligibility.bankAccount}';

    final maxHeight =
        (screen.height - keyboardBottom).clamp(240.0, screen.height * .92);

    final hasError = _shakeController.isError || _errorMessage != null;
    final baseInputDecoration = PammDecorations.input(
      context,
      hint: '0.00',
      prefixIcon: const Icon(
        Icons.attach_money_rounded,
        color: PammColors.blue,
        size: 20,
      ),
    );
    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: negative, width: 1.5),
    );

    return PopScope(
      canPop: !_submitting,
      child: Padding(
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                blurRadius: 28,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Institutional modal header
                Container(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 16 : 22,
                    12,
                    12,
                    12,
                  ),
                  decoration: BoxDecoration(
                    color: card,
                    border: Border(bottom: BorderSide(color: border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [PammColors.navy, PammColors.blue],
                          ),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.north_east_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Withdraw funds',
                              style: PammType.heading(context, size: 18),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.accountName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: PammType.body(
                                context,
                                size: 12.5,
                                weight: FontWeight.w400,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _submitting
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
                        icon: Icon(
                          Icons.close_rounded,
                          color: muted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 16 : 22,
                      12,
                      compact ? 16 : 22,
                      14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Balance summary card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                PammColors.navy,
                                PammColors.deepBlue,
                                PammColors.blue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AVAILABLE TO WITHDRAW',
                                style: PammType.label(
                                  context,
                                  size: 10.5,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatPammMoney(widget.availableBalance),
                                style: PammType.figure(
                                  context,
                                  size: 24,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    _method == 'usdt'
                                        ? Icons.account_balance_wallet_outlined
                                        : Icons.account_balance_outlined,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      destination,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: PammType.body(
                                        context,
                                        size: 12,
                                        weight: FontWeight.w500,
                                        color:
                                            Colors.white.withValues(alpha: 0.88),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // KYC / eligibility status banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: subtle,
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: positive,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'KYC & payout destination verified',
                                  style: PammType.body(
                                    context,
                                    size: 12,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'PAYOUT METHOD',
                          style: PammType.label(
                            context,
                            size: 11,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            if (eligibility.hasCrypto)
                              ChoiceChip(
                                label: Text(
                                  '$currency wallet',
                                  style: PammType.body(
                                    context,
                                    size: 12.5,
                                    weight: FontWeight.w600,
                                    color: _method == 'usdt'
                                        ? PammColors.blue
                                        : text,
                                  ),
                                ),
                                selected: _method == 'usdt',
                                selectedColor:
                                    PammColors.blue.withValues(alpha: 0.14),
                                backgroundColor: surface,
                                side: BorderSide(
                                  color: _method == 'usdt'
                                      ? PammColors.blue
                                      : border,
                                ),
                                onSelected: _submitting
                                    ? null
                                    : (_) {
                                        AppHaptics.selectionClick();
                                        FocusScope.of(context).unfocus();
                                        setState(() => _method = 'usdt');
                                      },
                              ),
                            if (eligibility.hasBank)
                              ChoiceChip(
                                label: Text(
                                  'Bank transfer',
                                  style: PammType.body(
                                    context,
                                    size: 12.5,
                                    weight: FontWeight.w600,
                                    color: _method == 'bank'
                                        ? PammColors.blue
                                        : text,
                                  ),
                                ),
                                selected: _method == 'bank',
                                selectedColor:
                                    PammColors.blue.withValues(alpha: 0.14),
                                backgroundColor: surface,
                                side: BorderSide(
                                  color: _method == 'bank'
                                      ? PammColors.blue
                                      : border,
                                ),
                                onSelected: _submitting
                                    ? null
                                    : (_) {
                                        AppHaptics.selectionClick();
                                        FocusScope.of(context).unfocus();
                                        setState(() => _method = 'bank');
                                      },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AMOUNT (USD)',
                          style: PammType.label(
                            context,
                            size: 11,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ShakeFeedbackWidget(
                          controller: _shakeController,
                          child: AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) => TextField(
                              controller: _amount,
                              enabled: !_submitting,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) {
                                _shakeController.clearError();
                                setState(() => _errorMessage = null);
                              },
                              style: PammType.figure(
                                context,
                                size: 16,
                                weight: FontWeight.w700,
                              ),
                              decoration: hasError
                                  ? baseInputDecoration.copyWith(
                                      border: errorBorder,
                                      enabledBorder: errorBorder,
                                      focusedBorder: errorBorder,
                                    )
                                  : baseInputDecoration,
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
                                  _presetAmountText(preset.factor);
                              final isSelected =
                                  _amount.text.trim() == presetText;
                              return ChoiceChip(
                                label: Text(
                                  preset.label,
                                  style: PammType.figure(
                                    context,
                                    size: 12.5,
                                    weight: FontWeight.w600,
                                    color:
                                        isSelected ? PammColors.blue : text,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor:
                                    PammColors.blue.withValues(alpha: 0.14),
                                backgroundColor: surface,
                                side: BorderSide(
                                  color:
                                      isSelected ? PammColors.blue : border,
                                ),
                                onSelected: _submitting
                                    ? null
                                    : (_) {
                                        AppHaptics.selectionClick();
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          _shakeController.clearError();
                                          _amount.text = presetText;
                                          _errorMessage = null;
                                        });
                                      },
                              );
                            }).toList(),
                          ),
                        ],
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: negative.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: negative.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: negative,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: PammType.body(
                                      context,
                                      size: 12,
                                      weight: FontWeight.w600,
                                      color: negative,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: PammColors.blue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  PammColors.blue.withValues(alpha: 0.45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                              elevation: 0,
                            ),
                            icon: _submitting
                                ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.arrow_upward_rounded, size: 17),
                            label: Text(
                              _submitting ? 'Submitting…' : 'Submit withdrawal',
                              style: PammType.body(
                                context,
                                size: 13.5,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The server will verify your KYC, payout details, and available balance.',
                          textAlign: TextAlign.center,
                          style: PammType.body(
                            context,
                            size: 11.5,
                            weight: FontWeight.w400,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
