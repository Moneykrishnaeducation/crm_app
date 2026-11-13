part of '../main.dart';

class BrokerAccountsPage extends StatefulWidget {
  const BrokerAccountsPage({super.key, required this.onSelectPage});
  final ValueChanged<String> onSelectPage;
  @override
  State<BrokerAccountsPage> createState() => _BrokerAccountsPageState();
}

class _BrokerAccountsPageState extends State<BrokerAccountsPage> {
  final _searchController = TextEditingController();
  String _filter = 'All Accounts';
  String _query = '';

  static const _accounts = [
    _BrokerAccount('XRSIM-USD-1', '3315', '1:500', '\$0.00', '\$0.00', 'Live MT5'),
    _BrokerAccount('XRSIM-USD-2', '3311', '1:500', '\$0.00', '\$0.00', 'Live MT5'),
    _BrokerAccount('XRSIM-USD-3', '3312', '1:500', '\$0.00', '\$0.00', 'Live MT5'),
    _BrokerAccount('XRSIM-USD-4', '3327', '1:500', '\$0.00', '\$0.00', 'Live MT5'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = _accounts.where((account) {
      final matchesQuery = account.login.toLowerCase().contains(_query.toLowerCase()) ||
          account.name.toLowerCase().contains(_query.toLowerCase());
      final matchesFilter = _filter == 'All Accounts' ||
          (_filter == 'Standard' && account.type == 'Live MT5');
      return matchesQuery && matchesFilter;
    }).toList();

    return Container(
      color: _brokerNavy,
      child: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
          children: [
            Row(children: [
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Trading Accounts', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                SizedBox(height: 3),
                Text('Manage your live, demo and investment accounts', style: TextStyle(color: _brokerMuted, fontSize: 9)),
              ])),
              IconButton(onPressed: () {}, icon: const Icon(LucideIcons.bell, color: Colors.white)),
            ]),
            const SizedBox(height: 11),
            Row(children: [
              _AccountAction(
                icon: LucideIcons.circlePlus,
                label: 'Open Account',
                highlighted: true,
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => const _OpenLiveAccountDialog(),
                ),
              ),
              const SizedBox(width: 7),
              _AccountAction(icon: LucideIcons.arrowLeftRight, label: 'Internal Transfer', onTap: () => widget.onSelectPage('Internal Transfer')),
              const SizedBox(width: 7),
              _AccountAction(icon: LucideIcons.monitor, label: 'Demo Account', onTap: () => widget.onSelectPage('Demo Accounts')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Expanded(child: _AccountSummary(icon: LucideIcons.wallet, title: 'Total Balance', value: '\$0.00', detail: 'Combined real account balance', accent: Color(0xFF24C6F4))),
              const SizedBox(width: 8),
              const Expanded(child: _AccountSummary(icon: LucideIcons.layers, title: 'Total Equity', value: '\$0.00', detail: 'Net asset value', accent: Color(0xFF9A75F7))),
              const SizedBox(width: 8),
              const Expanded(child: _AccountSummary(icon: LucideIcons.usersRound, title: 'Active Accounts', value: '4 Live', detail: 'All activated MT5 accounts', accent: _brokerGold)),
            ]),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _AccountFilter(label: 'All Accounts', count: '4', selected: _filter == 'All Accounts', onTap: () => setState(() => _filter = 'All Accounts')),
                const SizedBox(width: 7),
                _AccountFilter(label: 'Standard', count: '4', selected: _filter == 'Standard', onTap: () => setState(() => _filter = 'Standard')),
                const SizedBox(width: 7),
                _AccountFilter(label: 'VIP / ECN', count: '0', selected: _filter == 'VIP / ECN', onTap: () => setState(() => _filter = 'VIP / ECN')),
              ]),
            ),
            const SizedBox(height: 9),
            Row(children: [
              Expanded(child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(color: Colors.white, fontSize: 11),
                decoration: InputDecoration(
                  hintText: 'Search account, login ID...',
                  hintStyle: const TextStyle(color: _brokerMuted, fontSize: 10),
                  prefixIcon: const Icon(LucideIcons.search, color: _brokerMuted, size: 17),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  filled: true,
                  fillColor: const Color(0xFF081B40),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF194C90))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF3187F8))),
                ),
              )),
              const SizedBox(width: 7),
              IconButton(onPressed: () {}, style: IconButton.styleFrom(backgroundColor: const Color(0xFF0B2452), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), icon: const Icon(LucideIcons.listFilter, color: Colors.white, size: 18)),
            ]),
            const SizedBox(height: 10),
            if (compact)
              ...accounts.map((account) => _AccountCard(account: account))
            else
              _AccountTable(accounts: accounts),
          ],
        );
      }),
    );
  }
}

class _BrokerAccount {
  const _BrokerAccount(this.name, this.login, this.leverage, this.balance, this.equity, this.type);
  final String name, login, leverage, balance, equity, type;
}

class _OpenLiveAccountDialog extends StatefulWidget {
  const _OpenLiveAccountDialog();
  @override
  State<_OpenLiveAccountDialog> createState() => _OpenLiveAccountDialogState();
}

class _OpenLiveAccountDialogState extends State<_OpenLiveAccountDialog> {
  final _nameController = TextEditingController(text: 'Mohanprasath R');
  final _masterPassword = TextEditingController();
  final _investorPassword = TextEditingController();
  String _group = 'VIP - Recommended (Default)';
  String _leverage = '1:500';

  @override
  void dispose() {
    _nameController.dispose();
    _masterPassword.dispose();
    _investorPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: SizedBox(
        width: 420,
        height: (screen.height * .84).clamp(400.0, 700.0).toDouble(),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF091735),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1766C8)),
            boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 26, offset: Offset(0, 12))],
          ),
          child: Column(children: [
            _dialogHeader(),
            Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _sectionLabel('ACCOUNT NAME', required: true),
              const SizedBox(height: 5),
              _textInput(_nameController, hint: 'Enter account name', prefix: LucideIcons.userRound),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: _sectionLabel('TRADING GROUP', required: true)), const Text('VIP', style: TextStyle(color: Color(0xFF5DB5FF), fontSize: 9, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 5),
              _groupPicker(),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: _sectionLabel('ACCOUNT LEVERAGE', required: true)), const Text('MAX 1:500', style: TextStyle(color: _brokerGold, fontSize: 9, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 6),
              _leverageSelector(),
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF0C1A3B), borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0xFF1B376B))), child: Row(children: [const Expanded(child: Text('Custom Leverage: 1:500', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600))), Text('Selected:  $_leverage', style: const TextStyle(color: _brokerGold, fontSize: 9, fontWeight: FontWeight.w700))])),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0C2145), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF234A84))), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(LucideIcons.info, color: Color(0xFF64B9FF), size: 15), SizedBox(width: 7), Expanded(child: Text('SECURITY NOTICE: Master password executes trades; Investor password provides read-only monitoring.', style: TextStyle(color: _brokerMuted, fontSize: 9, height: 1.35)))])),
              const SizedBox(height: 12),
              _sectionLabel('MASTER PASSWORD', required: true, trailing: 'FULL TRADING CONTROL'),
              const SizedBox(height: 5),
              _PasswordInput(controller: _masterPassword),
              const SizedBox(height: 10),
              _sectionLabel('INVESTOR PASSWORD', required: true, trailing: 'READ-ONLY (MONITORING)'),
              const SizedBox(height: 5),
              _PasswordInput(controller: _investorPassword),
            ]))),
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: SizedBox(width: double.infinity, height: 42, child: FilledButton.icon(onPressed: _createAccount, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3F61F3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))), icon: const Icon(LucideIcons.arrowRight, size: 16), label: const Text('CREATE LIVE ACCOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .5))))),
            Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: const BoxDecoration(color: Color(0xFF06132C), borderRadius: BorderRadius.vertical(bottom: Radius.circular(17))), child: const Row(children: [Icon(LucideIcons.shieldCheck, color: Color(0xFF10D6B2), size: 14), SizedBox(width: 6), Text('SECURE MT5', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)), Spacer(), Icon(LucideIcons.zap, color: Color(0xFF45A8FF), size: 15), SizedBox(width: 5), Text('INSTANT SETUP', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)), Spacer(), Icon(LucideIcons.lockKeyhole, color: Color(0xFF45A8FF), size: 14), SizedBox(width: 5), Text('REGULATED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))])),
          ]),
        ),
      ),
    );
  }

  Widget _dialogHeader() => Container(padding: const EdgeInsets.fromLTRB(16, 12, 10, 10), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF1A2D55)))), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF3478FF)), borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.wallet, color: Color(0xFF5EA3FF), size: 19)), const SizedBox(width: 10), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Open Live Account', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)), SizedBox(height: 3), Row(children: [Icon(LucideIcons.circle, color: Color(0xFF00D98A), size: 7), SizedBox(width: 5), Text('Live MT5 Engine', style: TextStyle(color: Color(0xFF00D98A), fontSize: 8, fontWeight: FontWeight.w700)), SizedBox(width: 8), Text('•  Direct STP Execution', style: TextStyle(color: _brokerMuted, fontSize: 8))])])), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x, color: Colors.white70, size: 18), visualDensity: VisualDensity.compact)]));

  Widget _sectionLabel(String label, {bool required = false, String? trailing}) => Row(children: [Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .2)), if (required) const Padding(padding: EdgeInsets.only(left: 5), child: Text('*', style: TextStyle(color: Color(0xFFFF5867), fontSize: 10, fontWeight: FontWeight.w800))), const Spacer(), if (trailing != null) Text(trailing, style: const TextStyle(color: Color(0xFF59AFFF), fontSize: 8, fontWeight: FontWeight.w700))]);

  Widget _textInput(TextEditingController controller, {required String hint, required IconData prefix}) => TextField(controller: controller, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600), decoration: _inputDecoration(hint, prefix));

  InputDecoration _inputDecoration(String hint, IconData prefix) => InputDecoration(prefixIcon: Icon(prefix, size: 16, color: const Color(0xFF5E8BD5)), hintText: hint, hintStyle: const TextStyle(color: _brokerMuted, fontSize: 10), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), filled: true, fillColor: const Color(0xFF07132E), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1A376C))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3478FF))));

  Widget _groupPicker() => Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: const Color(0xFF07132E), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1A376C))), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _group, isExpanded: true, dropdownColor: _brokerPanel, iconEnabledColor: _brokerMuted, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600), items: const [DropdownMenuItem(value: 'VIP - Recommended (Default)', child: Text('VIP - Recommended (Default)')), DropdownMenuItem(value: 'Standard', child: Text('Standard')), DropdownMenuItem(value: 'ECN', child: Text('ECN'))], onChanged: (value) { if (value != null) setState(() => _group = value); })));

  Widget _leverageSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF07132E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1A376C)),
      ),
      child: Row(
        children: [
          for (final value in const ['1:100', '1:200', '1:500'])
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _leverage = value),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: _leverage == value
                        ? const Color(0xFF3E5EF0)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    value == '1:500' ? '$value (Max)' : value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _leverage == value ? Colors.white : _brokerMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _createAccount() {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Live account request submitted.')));
  }
}

class _PasswordInput extends StatefulWidget {
  const _PasswordInput({required this.controller});
  final TextEditingController controller;
  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}
class _PasswordInputState extends State<_PasswordInput> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => TextField(controller: widget.controller, obscureText: !_visible, style: const TextStyle(color: Colors.white, fontSize: 11), decoration: InputDecoration(prefixIcon: const Icon(LucideIcons.lockKeyhole, size: 15, color: Color(0xFF5E8BD5)), suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () {}, icon: const Icon(LucideIcons.copy, size: 14, color: _brokerMuted), visualDensity: VisualDensity.compact), IconButton(onPressed: () {}, icon: const Icon(LucideIcons.refreshCw, size: 14, color: _brokerMuted), visualDensity: VisualDensity.compact), IconButton(onPressed: () => setState(() => _visible = !_visible), icon: Icon(_visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 14, color: _brokerMuted), visualDensity: VisualDensity.compact)]), isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), filled: true, fillColor: const Color(0xFF07132E), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1A376C))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF3478FF)))));
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({required this.icon, required this.label, required this.onTap, this.highlighted = false});
  final IconData icon; final String label; final VoidCallback onTap; final bool highlighted;
  @override
  Widget build(BuildContext context) => Expanded(child: SizedBox(height: 38, child: FilledButton.icon(
    onPressed: onTap,
    style: FilledButton.styleFrom(backgroundColor: highlighted ? _brokerGold : const Color(0xFF0B2452), foregroundColor: highlighted ? _brokerNavy : Colors.white, padding: const EdgeInsets.symmetric(horizontal: 4), side: BorderSide(color: highlighted ? const Color(0xFFFFE991) : const Color(0xFF1473DA)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
    icon: Icon(icon, size: 14),
    label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))),
  )));
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary({required this.icon, required this.title, required this.value, required this.detail, required this.accent});
  final IconData icon; final String title, value, detail; final Color accent;
  @override
  Widget build(BuildContext context) => Container(
    height: 83,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: const Color(0xFF0B2452), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF1B4D8C))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: accent, size: 15), const SizedBox(width: 4), Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 8)))]),
      const SizedBox(height: 5),
      FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
      const Spacer(),
      Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _brokerMuted, fontSize: 6)),
    ]),
  );
}

class _AccountFilter extends StatelessWidget {
  const _AccountFilter({required this.label, required this.count, required this.selected, required this.onTap});
  final String label, count; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: selected ? const Color(0xFF174DBA) : const Color(0xFF0A204A), borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? const Color(0xFF398CFF) : const Color(0xFF1A467D))), child: Row(children: [Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)), const SizedBox(width: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), shape: BoxShape.circle), child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 8)))])));
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account}); final _BrokerAccount account;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFF0B2452), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF174783))), child: Column(children: [
    Row(children: [const CircleAvatar(radius: 14, backgroundColor: Color(0xFF173B73), child: Text('STD', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700))), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(account.name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('● ${account.type}', style: const TextStyle(color: Color(0xFF32E789), fontSize: 8))])), Text('Login ${account.login}', style: const TextStyle(color: _brokerMuted, fontSize: 8))]),
    const Divider(height: 16, color: Color(0xFF1B3B68)),
    Row(children: [Expanded(child: _AccountValue(label: 'LEVERAGE', value: account.leverage)), Expanded(child: _AccountValue(label: 'BALANCE (USD)', value: account.balance)), Expanded(child: _AccountValue(label: 'EQUITY (USD)', value: account.equity, green: true)), FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: _brokerGold, foregroundColor: _brokerNavy, padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(0, 29)), child: const Text('Deposit', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700)))]),
  ]));
}
class _AccountValue extends StatelessWidget {
  const _AccountValue({required this.label, required this.value, this.green = false});
  final String label, value; final bool green;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: _brokerMuted, fontSize: 6)), const SizedBox(height: 4), Text(value, style: TextStyle(color: green ? const Color(0xFF00E78A) : Colors.white, fontSize: 9, fontWeight: FontWeight.w700))]);
}

class _AccountTable extends StatelessWidget {
  const _AccountTable({required this.accounts}); final List<_BrokerAccount> accounts;
  @override
  Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: const Color(0xFF081B40), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF174783))), child: Column(children: [
    const Padding(padding: EdgeInsets.all(10), child: Row(children: [Expanded(flex: 3, child: Text('ACCOUNT / LOGIN', style: TextStyle(color: _brokerMuted, fontSize: 8))), Expanded(child: Text('LEVERAGE', style: TextStyle(color: _brokerMuted, fontSize: 8))), Expanded(child: Text('BALANCE', style: TextStyle(color: _brokerMuted, fontSize: 8))), Expanded(child: Text('EQUITY', style: TextStyle(color: _brokerMuted, fontSize: 8))), Text('ACTIONS', style: TextStyle(color: _brokerMuted, fontSize: 8))])),
    for (final account in accounts) _AccountTableRow(account: account),
  ]));
}
class _AccountTableRow extends StatelessWidget {
  const _AccountTableRow({required this.account}); final _BrokerAccount account;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF174783)))), child: Row(children: [
    Expanded(flex: 3, child: Row(children: [const CircleAvatar(radius: 12, backgroundColor: Color(0xFF173B73), child: Text('STD', style: TextStyle(color: Colors.white, fontSize: 6))), const SizedBox(width: 6), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(account.name, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)), Text('● ${account.type}', style: const TextStyle(color: Color(0xFF32E789), fontSize: 7))]))])),
    Expanded(child: Text('${account.login}  ${account.leverage}', style: const TextStyle(color: Colors.white, fontSize: 8))),
    Expanded(child: Text(account.balance, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
    Expanded(child: Text(account.equity, style: const TextStyle(color: Color(0xFF00E78A), fontSize: 8, fontWeight: FontWeight.w700))),
    FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: _brokerGold, foregroundColor: _brokerNavy, minimumSize: const Size(48, 24), padding: const EdgeInsets.symmetric(horizontal: 6)), child: const Text('Deposit', style: TextStyle(fontSize: 7))),
  ]));
}
