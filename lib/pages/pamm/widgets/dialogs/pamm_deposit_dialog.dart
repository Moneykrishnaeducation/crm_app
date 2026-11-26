import 'dart:async';

import 'package:crm_app/app_notifications.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showPammDepositDialog(
  BuildContext context, {
  required String accountName,
  required String pammId,
  required bool isManager,
  required Future<void> Function() onSuccess,
}) async {
  if (pammId.trim().isEmpty) {
    showPammMessage(
      context,
      'The PAMM identifier is missing. Refresh the account list and try again.',
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
    ),
  );
  if (submitted == true && context.mounted) {
    await onSuccess();
    if (context.mounted) {
      showAppMessage('Deposit request submitted successfully.');
    }
  }
}

class _PammDepositSheet extends StatefulWidget {
  const _PammDepositSheet({
    required this.accountName,
    required this.pammId,
    required this.isManager,
  });

  final String accountName;
  final String pammId;
  final bool isManager;

  @override
  State<_PammDepositSheet> createState() => _PammDepositSheetState();
}

class _PammDepositSheetState extends State<_PammDepositSheet> {
  final _amount = TextEditingController();
  final _picker = ImagePicker();

  int _method = 0;
  String _manualCurrency = 'INR';
  double _usdInrRate = 0.0;
  Map<String, dynamic>? _bankDetails;
  Map<String, dynamic>? _cryptoDetails;
  XFile? _proof;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    unawaited(
      AuthApi.instance.getCryptoDetails().then((response) {
        if (mounted) {
          setState(() => _cryptoDetails = unwrapPammApiMap(response));
        }
      }).catchError((_) {}),
    );
    unawaited(
      AuthApi.instance.getUsdInrRate().then((rate) {
        if (rate > 0 && mounted) {
          setState(() => _usdInrRate = rate);
        }
      }).catchError((_) {}),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _selectPaymentMethod(int index) async {
    AppHaptics.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() => _method = index);
    try {
      final response = index == 0
          ? await AuthApi.instance.getCryptoDetails()
          : await AuthApi.instance.getBankDetails();
      if (!mounted) return;
      setState(() {
        if (index == 0) {
          _cryptoDetails = unwrapPammApiMap(response);
        } else {
          _bankDetails = unwrapPammApiMap(response);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (index == 0) {
          _cryptoDetails = null;
        } else {
          _bankDetails = null;
        }
      });
    }
  }

  Future<void> _pickProof() async {
    AppHaptics.selectionClick();
    FocusScope.of(context).unfocus();
    try {
      final selected = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (selected != null && mounted) {
        AppHaptics.lightImpact();
        setState(() => _proof = selected);
      }
    } catch (_) {
      if (mounted) {
        AppHaptics.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open the image picker. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final value = double.tryParse(_amount.text.trim());
    if (value == null || !value.isFinite || value < 10) {
      AppHaptics.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(r'Enter a valid deposit amount of at least $10.00.'),
        ),
      );
      return;
    }
    if (_proof == null) {
      AppHaptics.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your payment proof.')),
      );
      return;
    }
    if (_method == 1 && _manualCurrency == 'INR' && _usdInrRate <= 0) {
      AppHaptics.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The USD to INR exchange rate is unavailable. Please try again shortly.',
          ),
        ),
      );
      return;
    }
    AppHaptics.mediumImpact();
    setState(() => _submitting = true);
    try {
      final selectedProof = _proof!;
      final usdAmount = _method == 1 && _manualCurrency == 'INR'
          ? value / _usdInrRate
          : value;
      await AuthApi.instance.submitPammDeposit(
        pammId: widget.pammId,
        amountUsd: usdAmount,
        method: _method == 0 ? 'usdt' : 'manual',
        proofBytes: await selectedProof.readAsBytes(),
        proofFileName: selectedProof.name,
        isManager: widget.isManager,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      AppHaptics.lightImpact();
      setState(() => _submitting = false);
      final message = error is AuthApiException
          ? error.message
          : 'Deposit request could not be submitted. Please try again.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _paymentTab({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool compact,
    required Color modalText,
    required Color modalMuted,
    required Color modalCard,
    required Color modalBorder,
  }) {
    final selected = _method == index;
    return Expanded(
      child: InkWell(
        onTap: () => _selectPaymentMethod(index),
        borderRadius: BorderRadius.circular(13),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: compact ? 12 : 15,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF293FE1), Color(0xFF3569F6)],
                  )
                : null,
            color: selected ? null : modalCard,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: selected ? PammColors.blue : modalBorder,
              width: selected ? 1.3 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: PammColors.blue.withValues(alpha: .18),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: selected ? Colors.white : modalText,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : modalText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? Colors.white.withValues(alpha: .85)
                      : modalMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerItem(IconData icon, String label, Color color, Color muted) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
    final modalText = isDark ? Colors.white : const Color(0xFF091836);
    final modalMuted =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final modalCard = PammColors.card(context);
    final modalSurface = PammColors.surface(context);
    final modalBorder = PammColors.border(context);
    final muted = PammColors.muted(context);

    final walletAddress = _cryptoDetails?['wallet_address']?.toString() ?? '';
    final bankAccount = _bankDetails?['account_number']?.toString() ?? '';
    final bankName =
        _bankDetails?['bank_name']?.toString() ?? 'saved bank account';
    final isInrManual = _method == 1 && _manualCurrency == 'INR';
    final quickAmounts = isInrManual
        ? const [1000, 5000, 10000, 25000]
        : const [50, 100, 500, 1000];
    final currencySymbol = isInrManual ? '₹' : r'$';

    Widget sectionLabel(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: modalText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: .25,
            ),
          ),
        );

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
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
              constraints: BoxConstraints(maxWidth: 780, maxHeight: maxHeight),
            child: Container(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: modalCard,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(compact ? 16 : 22, compact ? 15 : 20, 12, 17),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1B328D), Color(0xFF315FEA), Color(0xFF356DF5)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -32,
                          bottom: -66,
                          child: Container(
                            width: 170,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: .055),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .13),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: .28)),
                                  ),
                                  child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Deposit Funds',
                                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Add funds to your PAMM account using your preferred payment method.',
                                        style: TextStyle(color: Colors.white.withValues(alpha: .88), fontSize: 10, height: 1.35),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: () {
                                    AppHaptics.lightImpact();
                                    FocusScope.of(context).unfocus();
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 19),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF071D57).withValues(alpha: .72),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: .2)),
                              ),
                              child: Wrap(
                                spacing: 9,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline, color: Color(0xFF2BE3B2), size: 13),
                                  Text(
                                    'Account:  ${widget.accountName}',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                  const Text('|', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                  const Icon(Icons.shield_outlined, color: Color(0xFF8DEED5), size: 13),
                                  const Text(
                                    'Secure request',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 14 : 20,
                        16,
                        compact ? 14 : 20,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? modalSurface
                                  : const Color(0xFFF7F9FE),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: modalBorder),
                            ),
                            child: Row(
                              children: [
                                _paymentTab(
                                  index: 0,
                                  icon: Icons.currency_bitcoin_rounded,
                                  title: 'USDT',
                                  subtitle: 'Crypto payment',
                                  compact: compact,
                                  modalText: modalText,
                                  modalMuted: modalMuted,
                                  modalCard: modalCard,
                                  modalBorder: modalBorder,
                                ),
                                const SizedBox(width: 6),
                                _paymentTab(
                                  index: 1,
                                  icon: Icons.account_balance_outlined,
                                  title: 'MANUAL',
                                  subtitle: 'Bank transfer',
                                  compact: compact,
                                  modalText: modalText,
                                  modalMuted: modalMuted,
                                  modalCard: modalCard,
                                  modalBorder: modalBorder,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? modalSurface
                                  : const Color(0xFFF3F7FF),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: const Color(0xFFD7E4FF),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: modalCard,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: PammColors.blue,
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'PAYMENT INSTRUCTIONS',
                                        style: TextStyle(
                                          color: modalText,
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _method == 0
                                            ? 'Send USDT using the TRC20 network${walletAddress.isEmpty ? '' : ' to $walletAddress'} and upload your transaction screenshot.'
                                            : 'Contact Live Support for official bank details${bankAccount.isEmpty ? '' : ' for $bankName, account $bankAccount'} before transferring, then upload your payment proof.',
                                        style: TextStyle(
                                          color: modalMuted,
                                          fontSize: 11.5,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if ((_method == 0 &&
                                        walletAddress.isNotEmpty) ||
                                    (_method == 1 && bankAccount.isNotEmpty))
                                  IconButton(
                                    tooltip: 'Copy payment details',
                                    onPressed: () => copyPammValue(
                                      context,
                                      _method == 0 ? walletAddress : bankAccount,
                                    ),
                                    icon: const Icon(
                                      Icons.copy_outlined,
                                      color: PammColors.blue,
                                      size: 17,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 17),
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
                                    label: Text(currency),
                                    selected: _manualCurrency == currency,
                                    onSelected: (_) {
                                      AppHaptics.selectionClick();
                                      FocusScope.of(context).unfocus();
                                      setState(
                                        () => _manualCurrency = currency,
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          TextField(
                            controller: _amount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(
                              color: modalText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: modalMuted,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              prefixIcon: Padding(
                                padding:
                                    const EdgeInsets.only(left: 14, right: 10),
                                child: Icon(
                                  isInrManual
                                      ? Icons.currency_rupee_rounded
                                      : Icons.attach_money_rounded,
                                  color: const Color(0xFF1D348A),
                                  size: 20,
                                ),
                              ),
                              prefixIconConstraints:
                                  const BoxConstraints(minWidth: 42),
                              filled: true,
                              fillColor: modalCard,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide(color: modalBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(
                                  color: PammColors.blue,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: quickAmounts.map((amount) {
                              final amountText = '$amount';
                              return ChoiceChip(
                                label: Text('$currencySymbol$amountText'),
                                selected: _amount.text.trim() == amountText,
                                onSelected: (_) {
                                  AppHaptics.selectionClick();
                                  FocusScope.of(context).unfocus();
                                  setState(() => _amount.text = amountText);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _method == 0
                                ? r'Minimum deposit: $10.00 USD'
                                : _usdInrRate > 0
                                    ? 'Minimum deposit: 10.00 $_manualCurrency (exchange rate ${_usdInrRate.toStringAsFixed(2)} INR per USD)'
                                    : 'Exchange rate unavailable. Please try again shortly.',
                            style: TextStyle(
                              color: modalMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 17),
                          sectionLabel('Upload payment proof'),
                          InkWell(
                            onTap: _pickProof,
                            borderRadius: BorderRadius.circular(13),
                            child: Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? modalSurface
                                    : const Color(0xFFF8FAFD),
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: modalBorder,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2ECFF),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(
                                      Icons.cloud_upload_outlined,
                                      color: PammColors.blue,
                                      size: 21,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
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
                                          style: TextStyle(
                                            color: modalText,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _proof == null
                                              ? 'JPG or PNG · Tap to browse'
                                              : 'Selected · Tap to change file',
                                          style: TextStyle(
                                            color: modalMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    'Browse',
                                    style: TextStyle(
                                      color: PammColors.blue,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 17),
                          SizedBox(
                            height: 45,
                            child: FilledButton.icon(
                              onPressed: _submitting ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: PammColors.blue,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    PammColors.blue.withValues(alpha: .45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'SUBMIT DEPOSIT',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 13 : 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: modalBorder)),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 8,
                      spacing: 12,
                      children: [
                        _footerItem(Icons.verified_user_outlined, 'Secure payments', const Color(0xFF3478FF), muted),
                        _footerItem(Icons.schedule_rounded, 'Verification required', const Color(0xFFFF9800), muted),
                        _footerItem(Icons.layers_outlined, 'PAMM funding', const Color(0xFF3478FF), muted),
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
    );
  }
}
