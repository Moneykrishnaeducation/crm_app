import 'package:crm_app/app_haptics.dart';
import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_dialogs.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

Future<void> showCreatePammPoolDialog(
  BuildContext context, {
  required Future<void> Function() onPoolCreated,
}) async {
  final credentials = await showModalBottomSheet<Map<String, String>?>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x660B1730),
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    builder: (_) => _CreatePammPoolSheet(onPoolCreated: onPoolCreated),
  );
  if (credentials != null && context.mounted) {
    await showPammCreatedCredentialsDialog(
      context,
      title: 'PAMM manager account created',
      accountName: credentials['name']!,
      login: credentials['login']!,
      masterPassword: credentials['masterPassword'],
      investorPassword: credentials['investorPassword']!,
    );
  }
}

class _CreatePammPoolSheet extends StatefulWidget {
  const _CreatePammPoolSheet({required this.onPoolCreated});

  final Future<void> Function() onPoolCreated;

  @override
  State<_CreatePammPoolSheet> createState() => _CreatePammPoolSheetState();
}

class _CreatePammPoolSheetState extends State<_CreatePammPoolSheet> {
  final _name = TextEditingController();
  final _share = TextEditingController(text: '20');
  late final _masterPassword =
      TextEditingController(text: generatePammPassword());
  late final _investorPassword =
      TextEditingController(text: generatePammPassword());
  final _formKey = GlobalKey<FormState>();

  static const _leverageOptions = <String>[
    '1:50',
    '1:100',
    '1:200',
    '1:300',
    '1:500',
    '1:1000',
  ];

  String _leverage = '1:500';
  bool _showMasterPassword = false;
  bool _showInvestorPassword = false;
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _name.dispose();
    _share.dispose();
    _masterPassword.dispose();
    _investorPassword.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(
    String hint, {
    Widget? prefix,
    Widget? suffix,
  }) =>
      PammDecorations.input(
        context,
        hint: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
      );

  Widget _sectionTitle(String number, String title, {String? hint}) {
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: PammColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              number,
              style: PammType.figure(
                context,
                size: 11,
                weight: FontWeight.w700,
                color: PammColors.blue,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: PammType.label(
                context,
                size: 11,
                color: text,
                letterSpacing: 0.6,
              ),
            ),
          ),
          if (hint != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                hint,
                textAlign: TextAlign.right,
                style: PammType.body(context, size: 11, color: muted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false, String? suffix}) {
    final text = PammColors.text(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: PammType.body(
                  context,
                  size: 12.5,
                  weight: FontWeight.w700,
                  color: text,
                ),
                children: [
                  TextSpan(text: label),
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: PammColors.rose),
                    ),
                ],
              ),
            ),
          ),
          if (suffix != null)
            Text(
              suffix,
              style: PammType.figure(
                context,
                size: 12,
                weight: FontWeight.w700,
                color: PammColors.blue,
              ),
            ),
        ],
      ),
    );
  }

  Widget _sharePresetChips() => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [10, 20, 30, 40, 50].map((v) {
          final selected = _share.text.trim() == '$v';
          return ChoiceChip(
            label: Text(
              '$v%',
              style: PammType.figure(
                context,
                size: 11.5,
                weight: FontWeight.w700,
                color: selected ? Colors.white : PammColors.text(context),
              ),
            ),
            selected: selected,
            selectedColor: PammColors.blue,
            backgroundColor: PammColors.subtle(context),
            side: BorderSide(
              color: selected ? PammColors.blue : PammColors.border(context),
            ),
            showCheckmark: false,
            onSelected: _isCreating
                ? null
                : (_) {
                    AppHaptics.selectionClick();
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _share.text = '$v';
                      _errorMessage = null;
                    });
                  },
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          );
        }).toList(),
      );

  Widget _leverageSelector(Color card, Color text, Color border) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Account leverage', required: true, suffix: _leverage),
          Row(
            children: const ['1:100', '1:200', '1:500'].map((v) {
              final selected = _leverage == v;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: OutlinedButton(
                    onPressed: _isCreating
                        ? null
                        : () {
                            AppHaptics.selectionClick();
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _leverage = v;
                              _errorMessage = null;
                            });
                          },
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          selected ? PammColors.blue : PammColors.subtle(context),
                      foregroundColor: selected ? Colors.white : text,
                      side: BorderSide(
                        color: selected ? PammColors.blue : border,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      v,
                      style: PammType.figure(
                        context,
                        size: 12,
                        weight: FontWeight.w700,
                        color: selected ? Colors.white : text,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey('pamm_leverage_$_leverage'),
            initialValue: _leverage,
            isDense: true,
            decoration: _inputDecoration('Custom leverage'),
            dropdownColor: card,
            style: PammType.figure(
              context,
              size: 13,
              weight: FontWeight.w600,
              color: text,
            ),
            items: _leverageOptions
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: _isCreating
                ? null
                : (v) {
                    AppHaptics.selectionClick();
                    FocusScope.of(context).unfocus();
                    if (v != null) {
                      setState(() {
                        _leverage = v;
                        _errorMessage = null;
                      });
                    }
                  },
          ),
        ],
      );

  void _closeSheet() {
    if (_isCreating) return;
    AppHaptics.lightImpact();
    FocusScope.of(context).unfocus();
    Navigator.of(context).maybePop();
  }

  Widget _passwordCard({
    required String title,
    required String access,
    required TextEditingController controller,
    required bool visible,
    required VoidCallback toggle,
  }) {
    final surface = PammColors.surface(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lock, size: 14, color: PammColors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: PammType.body(
                    context,
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: text,
                  ),
                ),
              ),
              Text(
                access,
                style: PammType.label(
                  context,
                  size: 10,
                  color: muted,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: !_isCreating,
            obscureText: !visible,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]')),
            ],
            maxLength: 12,
            style: PammType.figure(
              context,
              size: 13,
              weight: FontWeight.w600,
              color: text,
            ),
            decoration: _inputDecoration(
              'Enter password',
              suffix: IconButton(
                onPressed: toggle,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(
                  visible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 16,
                  color: muted,
                ),
              ),
            ),
            validator: (value) {
              final textValue = value ?? '';
              return RegExp(
                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d_]{6,12}$',
              ).hasMatch(textValue)
                  ? null
                  : '6–12 chars, uppercase, lowercase and number';
            },
          ),
          const SizedBox(height: 6),
          Text(
            '6–12 characters, uppercase + lowercase + number; letters, numbers and underscore only.',
            style: PammType.body(
              context,
              size: 11,
              color: muted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: toggle,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: Icon(
                  visible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 14,
                ),
                label: Text(
                  visible ? 'Hide' : 'Reveal',
                  style: PammType.body(
                    context,
                    size: 12,
                    weight: FontWeight.w600,
                    color: PammColors.blue,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _isCreating
                    ? null
                    : () {
                        AppHaptics.lightImpact();
                        FocusScope.of(context).unfocus();
                        controller.text = generatePammPassword();
                      },
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(LucideIcons.refreshCw, size: 14),
                label: Text(
                  'Regenerate',
                  style: PammType.body(
                    context,
                    size: 12,
                    weight: FontWeight.w600,
                    color: PammColors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_isCreating) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppHaptics.lightImpact();
      return;
    }
    AppHaptics.mediumImpact();
    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });
    try {
      final response = await AuthApi.instance.createPammAccount(
        name: _name.text.trim(),
        profitShare: parsePammDouble(_share.text) ?? 20,
        leverage: int.tryParse(_leverage.split(':').last) ?? 500,
        masterPassword: _masterPassword.text,
        investorPassword: _investorPassword.text,
      );
      final unwrapped = unwrapPammApiMap(response);
      final createdPamm = unwrapped['pamm'] is Map
          ? (unwrapped['pamm'] as Map).cast<String, dynamic>()
          : unwrapped;
      final credentials = <String, String>{
        'name': pammStringValue(
          createdPamm,
          const ['name', 'pam_account_name'],
          fallback: _name.text.trim(),
        ),
        'login': pammStringValue(
          createdPamm,
          const ['mt5_account_id', 'pamm_mt5_account_id', 'login'],
          fallback: pammStringValue(
            unwrapped,
            const ['mt5_account_id', 'pamm_mt5_account_id', 'login'],
            fallback: 'Pending',
          ),
        ),
        'masterPassword': _masterPassword.text,
        'investorPassword': pammStringValue(
          unwrapped,
          const ['invest_password', 'investor_password'],
          fallback: pammStringValue(
            createdPamm,
            const ['invest_password', 'investor_password'],
            fallback: _investorPassword.text,
          ),
        ),
      };
      await widget.onPoolCreated();
      if (mounted) Navigator.pop(context, credentials);
    } catch (error) {
      if (!mounted) return;
      AppHaptics.lightImpact();
      final message =
          pammRequestError(error, 'Could not create the PAMM account.');
      setState(() {
        _isCreating = false;
        _errorMessage = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final wide = MediaQuery.sizeOf(context).width >= 620;
    final card = PammColors.card(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    final dark = PammColors.isDark(context);

    return PopScope(
      canPop: !_isCreating,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _isCreating ? null : _closeSheet,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            heightFactor: 1,
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardBottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 920,
                  maxHeight: (screenHeight - keyboardBottom)
                      .clamp(240.0, screenHeight * 0.88),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(
                      top: BorderSide(color: border),
                      left: BorderSide(color: border),
                      right: BorderSide(color: border),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
                        blurRadius: 28,
                        offset: const Offset(0, -6),
                      ),
                    ],
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
                                    color:
                                        PammColors.blue.withValues(alpha: 0.28),
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
                                    'Create PAMM account',
                                    style: PammType.heading(context, size: 17),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Configure pool, trading preferences and credentials',
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
                              onPressed: _isCreating ? null : _closeSheet,
                              constraints: const BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                              icon: Icon(LucideIcons.x, size: 18, color: muted),
                              tooltip: 'Close',
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: border),
                      Flexible(
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _sectionTitle('01', 'Account details'),
                                TextFormField(
                                  controller: _name,
                                  enabled: !_isCreating,
                                  onChanged: (_) {
                                    if (_errorMessage != null) {
                                      setState(() => _errorMessage = null);
                                    }
                                  },
                                  style: PammType.body(
                                    context,
                                    size: 13.5,
                                    weight: FontWeight.w600,
                                    color: text,
                                  ),
                                  decoration: _inputDecoration(
                                    'Enter PAMM account name',
                                    prefix: Icon(
                                      LucideIcons.userRound,
                                      size: 16,
                                      color: muted,
                                    ),
                                  ),
                                  validator: (value) =>
                                      (value?.trim().isNotEmpty ?? false)
                                          ? null
                                          : 'Account name is required',
                                ),
                                const SizedBox(height: 18),
                                _sectionTitle('02', 'Trading preferences'),
                                if (wide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _fieldLabel(
                                              'Performance fee',
                                              required: true,
                                              suffix: '${_share.text}%',
                                            ),
                                            TextFormField(
                                              controller: _share,
                                              enabled: !_isCreating,
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                              onChanged: (_) => setState(
                                                () => _errorMessage = null,
                                              ),
                                              style: PammType.figure(
                                                context,
                                                size: 14,
                                                color: text,
                                              ),
                                              decoration: _inputDecoration(
                                                '20',
                                                prefix: Icon(
                                                  LucideIcons.percent,
                                                  size: 15,
                                                  color: muted,
                                                ),
                                              ),
                                              validator: (value) {
                                                final n = parsePammDouble(
                                                  value ?? '',
                                                );
                                                return n != null &&
                                                        n >= 0 &&
                                                        n <= 100
                                                    ? null
                                                    : 'Enter 0–100';
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                            _sharePresetChips(),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _leverageSelector(
                                          card,
                                          text,
                                          border,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _fieldLabel(
                                    'Performance fee',
                                    required: true,
                                    suffix: '${_share.text}%',
                                  ),
                                  TextFormField(
                                    controller: _share,
                                    enabled: !_isCreating,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    onChanged: (_) =>
                                        setState(() => _errorMessage = null),
                                    style: PammType.figure(
                                      context,
                                      size: 14,
                                      color: text,
                                    ),
                                    decoration: _inputDecoration(
                                      '20',
                                      prefix: Icon(
                                        LucideIcons.percent,
                                        size: 15,
                                        color: muted,
                                      ),
                                    ),
                                    validator: (value) {
                                      final textVal = value?.trim() ?? '';
                                      if (textVal.isEmpty) return 'Required';
                                      final parsed = parsePammDouble(textVal);
                                      if (parsed == null ||
                                          parsed < 0 ||
                                          parsed > 100) {
                                        return 'Enter a value from 0 to 100';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  _sharePresetChips(),
                                  const SizedBox(height: 12),
                                  _leverageSelector(card, text, border),
                                ],
                                const SizedBox(height: 18),
                                _sectionTitle(
                                  '03',
                                  'Security credentials',
                                  hint: 'Keep master password private',
                                ),
                                if (wide)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _passwordCard(
                                          title: 'Master password',
                                          access: 'Full access',
                                          controller: _masterPassword,
                                          visible: _showMasterPassword,
                                          toggle: () {
                                            AppHaptics.selectionClick();
                                            FocusScope.of(context).unfocus();
                                            setState(() {
                                              _showMasterPassword =
                                                  !_showMasterPassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _passwordCard(
                                          title: 'Investor password',
                                          access: 'Read-only',
                                          controller: _investorPassword,
                                          visible: _showInvestorPassword,
                                          toggle: () {
                                            AppHaptics.selectionClick();
                                            FocusScope.of(context).unfocus();
                                            setState(() {
                                              _showInvestorPassword =
                                                  !_showInvestorPassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  _passwordCard(
                                    title: 'Master password',
                                    access: 'Full access',
                                    controller: _masterPassword,
                                    visible: _showMasterPassword,
                                    toggle: () {
                                      AppHaptics.selectionClick();
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _showMasterPassword =
                                            !_showMasterPassword;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  _passwordCard(
                                    title: 'Investor password',
                                    access: 'Read-only',
                                    controller: _investorPassword,
                                    visible: _showInvestorPassword,
                                    toggle: () {
                                      AppHaptics.selectionClick();
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _showInvestorPassword =
                                            !_showInvestorPassword;
                                      });
                                    },
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: PammColors.blue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: PammColors.blue
                                          .withValues(alpha: 0.22),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 1),
                                        child: Icon(
                                          LucideIcons.info,
                                          color: PammColors.blue,
                                          size: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'PAMM allocations are based on investor equity ratios. Review details before creating.',
                                          style: PammType.body(
                                            context,
                                            size: 11.5,
                                            color: muted,
                                            height: 1.4,
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
                            if (wide) ...[
                              const Icon(
                                LucideIcons.shieldCheck,
                                color: PammColors.green,
                                size: 15,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Review details before submitting.',
                                  style: PammType.body(
                                    context,
                                    size: 11.5,
                                    color: muted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              flex: wide ? 0 : 1,
                              child: OutlinedButton(
                                onPressed: _isCreating ? null : _closeSheet,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: text,
                                  side: BorderSide(color: border),
                                  minimumSize: const Size(100, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
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
                              flex: wide ? 0 : 2,
                              child: FilledButton.icon(
                                onPressed: _isCreating ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: PammColors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  minimumSize: const Size(180, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: _isCreating
                                    ? const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        LucideIcons.arrowRight,
                                        size: 15,
                                      ),
                                label: Text(
                                  _isCreating
                                      ? 'Creating…'
                                      : 'Create account',
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
