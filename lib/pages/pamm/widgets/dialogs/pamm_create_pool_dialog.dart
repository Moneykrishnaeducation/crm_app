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

  String _leverage = '1:500';
  bool _showMasterPassword = false;
  bool _showInvestorPassword = false;
  bool _isCreating = false;

  @override
  void dispose() {
    _name.dispose();
    _share.dispose();
    _masterPassword.dispose();
    _investorPassword.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefix, Widget? suffix}) {
    final card = PammColors.card(context);
    final border = PammColors.border(context);
    final muted = PammColors.muted(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: muted, fontSize: 12.5),
      prefixIcon: prefix,
      suffixIcon: suffix,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      filled: true,
      fillColor: card,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: PammColors.blue, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: PammColors.rose),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: PammColors.rose),
      ),
    );
  }

  Widget _sectionTitle(String number, String title, {String? hint}) {
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: PammColors.blue.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: PammColors.blue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: .25,
            ),
          ),
          const Spacer(),
          if (hint != null)
            Flexible(
              child: Text(
                hint,
                textAlign: TextAlign.right,
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false, String? suffix}) {
    final text = PammColors.text(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
              style: const TextStyle(
                color: PammColors.blue,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.lock, size: 13, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: text,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(access, style: TextStyle(color: muted, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            obscureText: !visible,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_]')),
            ],
            maxLength: 12,
            style: TextStyle(color: text, fontSize: 11),
            decoration: _inputDecoration(
              'Enter password',
              suffix: IconButton(
                onPressed: toggle,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  visible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 14,
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
          const SizedBox(height: 5),
          Text(
            '6–12 characters, uppercase + lowercase + number; letters, numbers and underscore only.',
            style: TextStyle(color: muted, fontSize: 8.5, height: 1.35),
          ),
          const SizedBox(height: 5),
          Wrap(
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: toggle,
                icon: Icon(
                  visible ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 12,
                ),
                label: Text(
                  visible ? 'Hide' : 'Reveal',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  controller.text = generatePammPassword();
                },
                icon: const Icon(LucideIcons.refreshCw, size: 12),
                label: const Text('Regenerate', style: TextStyle(fontSize: 9)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isCreating = true);
    try {
      final response = await AuthApi.instance.createPammAccount(
        name: _name.text.trim(),
        profitShare: double.tryParse(_share.text) ?? 20,
        leverage: int.tryParse(_leverage.split(':').last) ?? 500,
        masterPassword: _masterPassword.text,
        investorPassword: _investorPassword.text,
      );
      final createdPamm = response['pamm'] is Map
          ? (response['pamm'] as Map).cast<String, dynamic>()
          : <String, dynamic>{};
      final credentials = <String, String>{
        'name': pammStringValue(
          createdPamm,
          const ['name'],
          fallback: _name.text.trim(),
        ),
        'login': pammStringValue(
          createdPamm,
          const ['mt5_account_id'],
          fallback: 'Pending',
        ),
        'masterPassword': _masterPassword.text,
        'investorPassword': pammStringValue(
          response,
          const ['invest_password'],
          fallback: _investorPassword.text,
        ),
      };
      await widget.onPoolCreated();
      if (mounted) Navigator.pop(context, credentials);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      final message =
          pammRequestError(error, 'Could not create the PAMM account.');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final wide = MediaQuery.sizeOf(context).width >= 620;
    final card = PammColors.card(context);
    final border = PammColors.border(context);
    final text = PammColors.text(context);
    final muted = PammColors.muted(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 980,
              maxHeight: screenHeight * .82,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(22)),
                border: Border(top: BorderSide(color: border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .14),
                    blurRadius: 24,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: PammColors.blue.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.usersRound, color: PammColors.blue, size: 19),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create PAMM account',
                                style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Configure pool, trading preferences and credentials',
                                style: TextStyle(color: muted, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(LucideIcons.x, size: 17, color: muted),
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
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _sectionTitle('01', 'Account details'),
                            TextFormField(
                              controller: _name,
                              style: TextStyle(color: text, fontSize: 12),
                              decoration: _inputDecoration(
                                'Enter PAMM account name',
                                prefix: Icon(
                                  LucideIcons.userRound,
                                  size: 15,
                                  color: muted,
                                ),
                              ),
                              validator: (value) =>
                                  (value?.trim().isNotEmpty ?? false)
                                      ? null
                                      : 'Account name is required',
                            ),
                            const SizedBox(height: 12),
                            _sectionTitle('02', 'Trading preferences'),
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          onChanged: (_) => setState(() {}),
                                          style: TextStyle(
                                            color: text,
                                            fontSize: 11,
                                          ),
                                          decoration: _inputDecoration(
                                            '20',
                                            prefix: Icon(
                                              LucideIcons.percent,
                                              size: 14,
                                              color: muted,
                                            ),
                                          ),
                                          validator: (value) {
                                            final n =
                                                double.tryParse(value ?? '');
                                            return n != null &&
                                                    n >= 0 &&
                                                    n <= 100
                                                ? null
                                                : 'Enter 0–100';
                                          },
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 5,
                                          children: [10, 20, 30, 40, 50]
                                              .map(
                                                (v) => ChoiceChip(
                                                  label: Text('$v%', style: const TextStyle(fontSize: 9)),
                                                  selected: _share.text == '$v',
                                                  onSelected: (_) => setState(() => _share.text = '$v'),
                                                  visualDensity: VisualDensity.compact,
                                                  padding: EdgeInsets.zero,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _fieldLabel('Account leverage', required: true, suffix: _leverage),
                                        Row(
                                          children: ['1:100', '1:200', '1:500']
                                              .map(
                                                (v) => Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 5),
                                                    child: OutlinedButton(
                                                      onPressed: () => setState(() => _leverage = v),
                                                      style: OutlinedButton.styleFrom(
                                                        backgroundColor: _leverage == v ? PammColors.blue : card,
                                                        foregroundColor: _leverage == v ? Colors.white : text,
                                                        side: BorderSide(color: _leverage == v ? PammColors.blue : border),
                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                        minimumSize: const Size(0, 34),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                                      ),
                                                      child: Text(v, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          initialValue: _leverage,
                                          isDense: true,
                                          decoration: _inputDecoration('Custom leverage'),
                                          dropdownColor: card,
                                          style: TextStyle(color: text, fontSize: 10),
                                          items: const ['1:50', '1:100', '1:200', '1:300', '1:500', '1:1000']
                                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                                              .toList(),
                                          onChanged: (v) => setState(() => _leverage = v ?? _leverage),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _fieldLabel('Performance fee', required: true),
                              TextFormField(
                                controller: _share,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                style: TextStyle(
                                  color: text,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration('20'),
                                validator: (value) {
                                  final textVal = value?.trim() ?? '';
                                  if (textVal.isEmpty) return 'Required';
                                  final parsed = double.tryParse(textVal);
                                  if (parsed == null ||
                                      parsed < 0 ||
                                      parsed > 100) {
                                    return 'Enter a value from 0 to 100';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              _fieldLabel(
                                'Account leverage',
                                required: true,
                                suffix: _leverage,
                              ),
                              Wrap(
                                spacing: 6,
                                children: ['1:100', '1:200', '1:500']
                                    .map(
                                      (v) => ChoiceChip(
                                        label: Text(
                                          v,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        selected: _leverage == v,
                                        onSelected: (_) =>
                                            setState(() => _leverage = v),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _sectionTitle(
                              '03',
                              'Security credentials',
                              hint: 'Keep master password private',
                            ),
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _passwordCard(
                                      title: 'Master password',
                                      access: 'Full access',
                                      controller: _masterPassword,
                                      visible: _showMasterPassword,
                                      toggle: () => setState(() {
                                        _showMasterPassword =
                                            !_showMasterPassword;
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _passwordCard(
                                      title: 'Investor password',
                                      access: 'Read-only',
                                      controller: _investorPassword,
                                      visible: _showInvestorPassword,
                                      toggle: () => setState(() {
                                        _showInvestorPassword =
                                            !_showInvestorPassword;
                                      }),
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
                                toggle: () => setState(() {
                                  _showMasterPassword = !_showMasterPassword;
                                }),
                              ),
                              const SizedBox(height: 8),
                              _passwordCard(
                                title: 'Investor password',
                                access: 'Read-only',
                                controller: _investorPassword,
                                visible: _showInvestorPassword,
                                toggle: () => setState(() {
                                  _showInvestorPassword =
                                      !_showInvestorPassword;
                                }),
                              ),
                            ],
                            const SizedBox(height: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: PammColors.blue.withValues(alpha: .055),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    LucideIcons.info,
                                    color: PammColors.blue,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      'PAMM allocations are based on investor equity ratios. Review details before creating.',
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 9,
                                        height: 1.35,
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
                  Divider(height: 1, color: border),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 9, 16, 10 + MediaQuery.viewInsetsOf(context).bottom),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(LucideIcons.shieldCheck, color: PammColors.green, size: 14),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Review details before submitting.',
                                  style: TextStyle(color: muted, fontSize: 9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: text,
                            side: BorderSide(color: border),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 10)),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: _isCreating ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: PammColors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          ),
                          icon: const Icon(LucideIcons.arrowRight, size: 13),
                          label: Text(
                            _isCreating ? 'Creating…' : 'Create account',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
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
      ],
    );
  }
}
