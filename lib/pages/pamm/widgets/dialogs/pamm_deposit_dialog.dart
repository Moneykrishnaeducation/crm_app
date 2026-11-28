import 'dart:async';
import 'dart:typed_data';

import 'package:crm_app/app_notifications.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const _pammDepositMinUsd = 10.0;
const _pammMaxProofBytes = 10 * 1024 * 1024;
const _pammAllowedProofExtensions = <String>{
  'jpg',
  'jpeg',
  'png',
  'webp',
  'heic',
  'heif',
};

Future<void> showPammDepositDialog(
  BuildContext context, {
  required String accountName,
  required String pammId,
  required bool isManager,
  required Future<void> Function() onSuccess,
  @visibleForTesting Future<XFile?> Function()? pickProofForTesting,
}) async {
  if (pammId.trim().isEmpty) {
    showPammMessage(
      context,
      'The PAMM identifier is missing. Refresh the account list and try again.',
      isError: true,
    );
    return;
  }
  final submitted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x9907132D),
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _PammDepositSheet(
      accountName: accountName,
      pammId: pammId,
      isManager: isManager,
      pickProofForTesting: pickProofForTesting,
    ),
  );
  if (submitted == true && context.mounted) {
    await onSuccess();
    if (context.mounted) {
      showPammMessage(context, 'Deposit request submitted successfully.');
    }
  }
}

class _PammDepositSheet extends StatefulWidget {
  const _PammDepositSheet({
    required this.accountName,
    required this.pammId,
    required this.isManager,
    this.pickProofForTesting,
  });

  final String accountName;
  final String pammId;
  final bool isManager;
  final Future<XFile?> Function()? pickProofForTesting;

  @override
  State<_PammDepositSheet> createState() => _PammDepositSheetState();
}

class _PammDepositSheetState extends State<_PammDepositSheet> {
  final _amount = TextEditingController();
  final _picker = ImagePicker();

  int _method = 0;
  String _manualCurrency = 'INR';
  double _usdInrRate = 0.0;
  bool _rateLoadFailed = false;
  Map<String, dynamic>? _bankDetails;
  Map<String, dynamic>? _cryptoDetails;
  int _paymentMethodSeq = 0;
  XFile? _proof;
  Uint8List? _proofBytes;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initialSeq = _paymentMethodSeq;
    unawaited(
      AuthApi.instance.getCryptoDetails().then((response) {
        if (mounted && initialSeq == _paymentMethodSeq) {
          setState(() => _cryptoDetails = unwrapPammApiMap(response));
        }
      }).catchError((_) {}),
    );
    unawaited(
      AuthApi.instance.getUsdInrRate().then((rate) {
        if (!mounted) return;
        setState(() {
          if (rate > 0) {
            _usdInrRate = rate;
            _rateLoadFailed = false;
          } else {
            _rateLoadFailed = true;
          }
        });
      }).catchError((_) {
        if (mounted) {
          setState(() => _rateLoadFailed = true);
        }
      }),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _selectPaymentMethod(int index) async {
    if (_submitting) return;
    AppHaptics.selectionClick();
    FocusScope.of(context).unfocus();
    final seq = ++_paymentMethodSeq;
    setState(() {
      _method = index;
      _errorMessage = null;
    });
    try {
      final response = index == 0
          ? await AuthApi.instance.getCryptoDetails()
          : await AuthApi.instance.getBankDetails();
      if (!mounted || seq != _paymentMethodSeq || _method != index) return;
      setState(() {
        if (index == 0) {
          _cryptoDetails = unwrapPammApiMap(response);
        } else {
          _bankDetails = unwrapPammApiMap(response);
        }
      });
    } catch (_) {
      // Preserve any previously fetched payment instructions instead of wiping them.
    }
  }

  String? _validateProofFile(XFile file, Uint8List bytes) {
    final name = file.name.trim();
    final dot = name.lastIndexOf('.');
    final ext = (dot != -1 && dot < name.length - 1)
        ? name.substring(dot + 1).toLowerCase()
        : '';
    if (ext.isNotEmpty) {
      if (!_pammAllowedProofExtensions.contains(ext)) {
        return 'Unsupported file type. Upload a JPG, PNG, or WEBP image.';
      }
    } else {
      final mime = file.mimeType?.toLowerCase().trim() ?? '';
      if (mime.isNotEmpty && !mime.startsWith('image/')) {
        return 'Unsupported file type. Upload a JPG, PNG, or WEBP image.';
      }
    }
    if (bytes.isEmpty) {
      return 'The selected payment proof file is empty. Please choose another image.';
    }
    if (bytes.length > _pammMaxProofBytes) {
      return 'Payment proof image must be 10 MB or smaller.';
    }
    return null;
  }

  Future<void> _pickProof() async {
    if (_submitting) return;
    AppHaptics.selectionClick();
    FocusScope.of(context).unfocus();
    try {
      final selected = widget.pickProofForTesting != null
          ? await widget.pickProofForTesting!()
          : await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 90,
            );
      if (selected == null || !mounted) return;
      final bytes = await selected.readAsBytes();
      if (!mounted) return;
      final fileError = _validateProofFile(selected, bytes);
      if (fileError != null) {
        AppHaptics.lightImpact();
        setState(() => _errorMessage = fileError);
        return;
      }
      AppHaptics.lightImpact();
      setState(() {
        _proof = selected;
        _proofBytes = bytes;
        _errorMessage = null;
      });
    } catch (_) {
      if (mounted) {
        AppHaptics.lightImpact();
        setState(
          () => _errorMessage =
              'Unable to open the image picker. Please try again.',
        );
      }
    }
  }

  double get _minInrAmount =>
      _usdInrRate > 0 ? (_pammDepositMinUsd * _usdInrRate * 100).ceilToDouble() / 100 : 0;

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    final isInrManual = _method == 1 && _manualCurrency == 'INR';
    final value = parsePammDouble(_amount.text);
    if (value == null || value <= 0) {
      AppHaptics.lightImpact();
      setState(
        () => _errorMessage = 'Enter a valid deposit amount greater than zero.',
      );
      return;
    }
    if (isInrManual && _usdInrRate <= 0) {
      AppHaptics.lightImpact();
      setState(
        () => _errorMessage =
            'The USD to INR exchange rate is unavailable. Please try again shortly.',
      );
      return;
    }
    final usdAmount = isInrManual ? value / _usdInrRate : value;
    if (usdAmount < _pammDepositMinUsd) {
      AppHaptics.lightImpact();
      setState(() {
        _errorMessage = isInrManual
            ? 'Minimum deposit is ₹${_minInrAmount.toStringAsFixed(2)} INR (\$10.00 USD at ${_usdInrRate.toStringAsFixed(2)} INR/USD).'
            : r'Enter a valid deposit amount of at least $10.00 USD.';
      });
      return;
    }
    if (_proof == null) {
      AppHaptics.lightImpact();
      setState(() => _errorMessage = 'Please upload your payment proof.');
      return;
    }
    final selectedProof = _proof!;
    final bytes = _proofBytes ?? await selectedProof.readAsBytes();
    if (!mounted) return;
    final proofError = _validateProofFile(selectedProof, bytes);
    if (proofError != null) {
      AppHaptics.lightImpact();
      setState(() => _errorMessage = proofError);
      return;
    }
    AppHaptics.mediumImpact();
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await AuthApi.instance.submitPammDeposit(
        pammId: widget.pammId,
        amountUsd: usdAmount,
        method: _method == 0 ? 'usdt' : 'manual',
        proofBytes: bytes,
        proofFileName: selectedProof.name,
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
            : 'Deposit request could not be submitted. Please try again.';
      });
    }
  }

  Widget _paymentTab({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool compact,
  }) {
    final selected = _method == index;
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final card = PammColors.card(context);
    final border = PammColors.border(context);

    return Expanded(
      child: InkWell(
        onTap: _submitting ? null : () => _selectPaymentMethod(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [PammColors.deepBlue, PammColors.blue],
                  )
                : null,
            color: selected ? null : card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? PammColors.blue : border,
              width: selected ? 1.2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: PammColors.blue.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: selected ? Colors.white : text,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: PammType.body(
                        context,
                        size: 13,
                        weight: FontWeight.w700,
                        color: selected ? Colors.white : text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PammType.body(
                  context,
                  size: 11,
                  weight: FontWeight.w500,
                  color: selected ? Colors.white.withValues(alpha: 0.9) : muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerItem(IconData icon, String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: PammType.body(
              context,
              size: 11.5,
              weight: FontWeight.w600,
              color: PammColors.muted(context),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final compact = screen.width < 600;
    final maxHeight =
        (screen.height - keyboardBottom).clamp(240.0, screen.height * .94);
    final isDark = PammColors.isDark(context);
    final card = PammColors.card(context);
    final surface = PammColors.surface(context);
    final subtle = PammColors.subtle(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final negative = PammColors.negative(context);

    final walletAddress = _cryptoDetails?['wallet_address']?.toString() ?? '';
    final bankAccount = _bankDetails?['account_number']?.toString() ?? '';
    final bankName =
        _bankDetails?['bank_name']?.toString() ?? 'saved bank account';
    final isInrManual = _method == 1 && _manualCurrency == 'INR';
    final quickAmounts = isInrManual
        ? const [1000, 5000, 10000, 25000]
        : const [50, 100, 500, 1000];
    final currencySymbol = isInrManual ? '₹' : r'$';
    final hasCopyableDetail = (_method == 0 && walletAddress.isNotEmpty) ||
        (_method == 1 && bankAccount.isNotEmpty);

    Widget sectionLabel(String labelText) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            labelText.toUpperCase(),
            style: PammType.label(context, size: 11, letterSpacing: 0.6),
          ),
        );

    return PopScope(
      canPop: !_submitting,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _submitting
                  ? null
                  : () {
                      AppHaptics.lightImpact();
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).maybePop();
                    },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardBottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 680, maxHeight: maxHeight),
                child: Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Institutional modal header
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 16 : 22,
                          16,
                          12,
                          14,
                        ),
                        decoration: BoxDecoration(
                          color: card,
                          border: Border(bottom: BorderSide(color: border)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [PammColors.navy, PammColors.blue],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Deposit Funds',
                                        style: PammType.heading(
                                          context,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Add funds to your PAMM account using your preferred payment method.',
                                        style: PammType.body(
                                          context,
                                          size: 12,
                                          weight: FontWeight.w400,
                                          color: muted,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  tooltip: 'Close',
                                  constraints: const BoxConstraints(
                                    minWidth: 44,
                                    minHeight: 44,
                                  ),
                                  onPressed: _submitting
                                      ? null
                                      : () {
                                          AppHaptics.lightImpact();
                                          FocusScope.of(context).unfocus();
                                          Navigator.pop(context);
                                        },
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: muted,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: border),
                              ),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: PammColors.positive(context),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Account: ${widget.accountName}',
                                        style: PammType.body(
                                          context,
                                          size: 11.5,
                                          weight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.shield_outlined,
                                        color: PammColors.blue,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Secure request',
                                        style: PammType.body(
                                          context,
                                          size: 11.5,
                                          weight: FontWeight.w600,
                                          color: muted,
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
                      Flexible(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            compact ? 16 : 22,
                            16,
                            compact ? 16 : 22,
                            14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Method selector tabs
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: [
                                    _paymentTab(
                                      index: 0,
                                      icon: Icons.currency_bitcoin_rounded,
                                      title: 'USDT',
                                      subtitle: 'Crypto payment',
                                      compact: compact,
                                    ),
                                    const SizedBox(width: 6),
                                    _paymentTab(
                                      index: 1,
                                      icon: Icons.account_balance_outlined,
                                      title: 'MANUAL',
                                      subtitle: 'Bank transfer',
                                      compact: compact,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Bank / wallet instructions card
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: subtle,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: PammColors.blue
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline_rounded,
                                        color: PammColors.blue,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'PAYMENT INSTRUCTIONS',
                                            style: PammType.label(
                                              context,
                                              size: 10.5,
                                              color: text,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _method == 0
                                                ? 'Send USDT using the TRC20 network${walletAddress.isEmpty ? '' : ' to $walletAddress'} and upload your transaction screenshot.'
                                                : 'Contact Live Support for official bank details${bankAccount.isEmpty ? '' : ' for $bankName, account $bankAccount'} before transferring, then upload your payment proof.',
                                            style: PammType.body(
                                              context,
                                              size: 12.5,
                                              weight: FontWeight.w400,
                                              color: muted,
                                              height: 1.45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (hasCopyableDetail) ...[
                                      const SizedBox(width: 4),
                                      IconButton(
                                        tooltip: 'Copy payment details',
                                        constraints: const BoxConstraints(
                                          minWidth: 44,
                                          minHeight: 44,
                                        ),
                                        onPressed: () => copyPammValue(
                                          context,
                                          _method == 0
                                              ? walletAddress
                                              : bankAccount,
                                        ),
                                        icon: const Icon(
                                          Icons.copy_outlined,
                                          color: PammColors.blue,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              sectionLabel(
                                'Deposit amount (${_method == 0 ? 'USD' : _manualCurrency})',
                              ),
                              if (_method == 1) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    for (final currency in const ['INR', 'USD'])
                                      ChoiceChip(
                                        label: Text(
                                          currency,
                                          style: PammType.label(
                                            context,
                                            size: 11.5,
                                            color: _manualCurrency == currency
                                                ? PammColors.blue
                                                : text,
                                          ),
                                        ),
                                        selected: _manualCurrency == currency,
                                        selectedColor: PammColors.blue
                                            .withValues(alpha: 0.14),
                                        backgroundColor: surface,
                                        side: BorderSide(
                                          color: _manualCurrency == currency
                                              ? PammColors.blue
                                              : border,
                                        ),
                                        onSelected: _submitting
                                            ? null
                                            : (_) {
                                                AppHaptics.selectionClick();
                                                FocusScope.of(context)
                                                    .unfocus();
                                                setState(() {
                                                  _manualCurrency = currency;
                                                  _errorMessage = null;
                                                });
                                              },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                              TextField(
                                controller: _amount,
                                enabled: !_submitting,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                onChanged: (_) =>
                                    setState(() => _errorMessage = null),
                                style: PammType.figure(
                                  context,
                                  size: 16,
                                  weight: FontWeight.w700,
                                ),
                                decoration: PammDecorations.input(
                                  context,
                                  hint: '0.00',
                                  prefixIcon: Icon(
                                    isInrManual
                                        ? Icons.currency_rupee_rounded
                                        : Icons.attach_money_rounded,
                                    color: PammColors.blue,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: quickAmounts.map((amount) {
                                  final amountText = '$amount';
                                  final isSelected =
                                      parsePammDouble(_amount.text) ==
                                          amount.toDouble();
                                  return ChoiceChip(
                                    label: Text(
                                      '$currencySymbol$amountText',
                                      style: PammType.figure(
                                        context,
                                        size: 12.5,
                                        weight: FontWeight.w600,
                                        color: isSelected
                                            ? PammColors.blue
                                            : text,
                                      ),
                                    ),
                                    selected: isSelected,
                                    selectedColor:
                                        PammColors.blue.withValues(alpha: 0.14),
                                    backgroundColor: surface,
                                    side: BorderSide(
                                      color: isSelected
                                          ? PammColors.blue
                                          : border,
                                    ),
                                    onSelected: _submitting
                                        ? null
                                        : (_) {
                                            AppHaptics.selectionClick();
                                            FocusScope.of(context).unfocus();
                                            setState(() {
                                              _amount.text = amountText;
                                              _errorMessage = null;
                                            });
                                          },
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                !isInrManual
                                    ? r'Minimum deposit: $10.00 USD'
                                    : _usdInrRate > 0
                                        ? 'Minimum deposit: ₹${_minInrAmount.toStringAsFixed(2)} INR (\$10.00 USD · rate ${_usdInrRate.toStringAsFixed(2)} INR/USD)'
                                        : _rateLoadFailed
                                            ? 'Exchange rate unavailable. Please try again shortly.'
                                            : 'Loading USD to INR exchange rate...',
                                style: PammType.body(
                                  context,
                                  size: 11.5,
                                  weight: FontWeight.w500,
                                  color: muted,
                                ),
                              ),
                              const SizedBox(height: 16),
                              sectionLabel('Upload payment proof'),
                              InkWell(
                                onTap: _submitting ? null : _pickProof,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: subtle,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _proof != null
                                          ? PammColors.positive(context)
                                              .withValues(alpha: 0.6)
                                          : border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: (_proof != null
                                                  ? PammColors.positive(context)
                                                  : PammColors.blue)
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                        child: Icon(
                                          _proof != null
                                              ? Icons.check_circle_outline_rounded
                                              : Icons.cloud_upload_outlined,
                                          color: _proof != null
                                              ? PammColors.positive(context)
                                              : PammColors.blue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _proof?.name ??
                                                  'Choose transaction proof',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: PammType.body(
                                                context,
                                                size: 13,
                                                weight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _proof == null
                                                  ? 'JPG, PNG or WEBP · Tap to browse'
                                                  : 'Selected · Tap to change file',
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
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: PammColors.blue
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _proof == null ? 'Browse' : 'Change',
                                          style: PammType.label(
                                            context,
                                            size: 11,
                                            color: PammColors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                      : const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 17,
                                        ),
                                  label: Text(
                                    _submitting
                                        ? 'SUBMITTING...'
                                        : 'SUBMIT DEPOSIT',
                                    style: PammType.body(
                                      context,
                                      size: 13.5,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 16 : 22,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: subtle,
                          border: Border(top: BorderSide(color: border)),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runSpacing: 8,
                          spacing: 12,
                          children: [
                            _footerItem(
                              Icons.verified_user_outlined,
                              'Secure payments',
                              PammColors.blue,
                            ),
                            _footerItem(
                              Icons.schedule_rounded,
                              'Verification required',
                              PammColors.gold,
                            ),
                            _footerItem(
                              Icons.layers_outlined,
                              'PAMM funding',
                              PammColors.blue,
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
        ],
      ),
    );
  }
}
