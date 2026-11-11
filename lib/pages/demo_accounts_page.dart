part of '../main.dart';

class BrokerDemoAccountsPage extends StatefulWidget {
  const BrokerDemoAccountsPage({super.key});
  @override
  State<BrokerDemoAccountsPage> createState() => _BrokerDemoAccountsPageState();
}

class _BrokerDemoAccountsPageState extends State<BrokerDemoAccountsPage> {
  String _filter = 'All Accounts';
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF071428),
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF081A3A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2462C4)),
                ),
                child: Row(children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF33B7FF), Color(0xFF3858F5)]), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 20)),
                  const SizedBox(width: 9),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Demo Accounts', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)), SizedBox(height: 3), Text('Manage your virtual MT5 accounts.', style: TextStyle(color: _brokerMuted, fontSize: 9))])),
                  IconButton(onPressed: () => setState(() {}), tooltip: 'Refresh', style: IconButton.styleFrom(backgroundColor: const Color(0xFF132849), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))), icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 17)),
                  if (!compact) ...[
                    const SizedBox(width: 6),
                    FilledButton.icon(onPressed: () => _showCreateDialog(context), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4059E9), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11)), icon: const Icon(Icons.add_rounded, size: 16), label: const Text('Create Demo Account', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))),
                  ],
                ]),
              ),
              if (compact) ...[
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _showCreateDialog(context), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4059E9), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 11)), icon: const Icon(Icons.add_rounded, size: 16), label: const Text('Create Demo Account', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)))),
              ],
              const SizedBox(height: 13),
              Row(children: [
                const Expanded(child: _DemoSummary(icon: Icons.account_balance_wallet_outlined, title: 'VIRTUAL PORTFOLIO', value: '\$0.00', detail: 'Combined simulated trading equity', iconColor: _brokerBlue)),
                const SizedBox(width: 8),
                const Expanded(child: _DemoSummary(icon: Icons.desktop_windows_outlined, title: 'ACTIVE SIMULATIONS', value: '0', detail: '0 active / 0 total demo accounts', iconColor: Color(0xFF8065E8), valueColor: Color(0xFF00D59A))),
                const SizedBox(width: 8),
                const Expanded(child: _DemoSummary(icon: Icons.auto_awesome_outlined, title: 'EXECUTION ENVIRONMENT', value: 'Risk-Free', detail: 'Real-time market feeds & MT5 spread dynamics', iconColor: _brokerGold, gold: true)),
              ]),
              const SizedBox(height: 14),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(color: const Color(0xFF11184F), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF222D8A))),
                child: Column(children: [
                  Padding(padding: const EdgeInsets.all(10), child: compact
                      ? Column(children: [
                          _DemoFilters(filter: _filter, onSelect: (value) => setState(() => _filter = value)),
                          const SizedBox(height: 8),
                          _DemoSearch(controller: _searchController, onChanged: (value) => setState(() => _query = value)),
                        ])
                      : Row(children: [
                          Expanded(child: _DemoFilters(filter: _filter, onSelect: (value) => setState(() => _filter = value))),
                          const SizedBox(width: 10),
                          SizedBox(width: 225, child: _DemoSearch(controller: _searchController, onChanged: (value) => setState(() => _query = value))),
                        ])),
                  const Divider(height: 1, color: Color(0xFF252D75)),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 280),
                    child: Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 56, height: 56, decoration: const BoxDecoration(color: Color(0xFF1B225F), shape: BoxShape.circle), child: const Icon(Icons.search_rounded, color: _brokerMuted, size: 27)),
                      const SizedBox(height: 12),
                      Text(_query.isEmpty ? 'No Demo Accounts Found' : 'No matching demo accounts', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      const Text("You don't have any virtual practice accounts yet. Create your first practice account to get started.", textAlign: TextAlign.center, style: TextStyle(color: _brokerMuted, fontSize: 9, height: 1.4)),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () => _showCreateDialog(context), style: FilledButton.styleFrom(backgroundColor: const Color(0xFF344FCE), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)), child: const Text('Open Practice Account', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700))),
                    ]))),
                  ),
                ]),
              ),
            ],
          );
        }),
      );

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _brokerPanel,
        title: const Text('Create Demo Account', style: TextStyle(color: Colors.white)),
        content: const Text('A virtual MT5 practice account will be created for this client.', style: TextStyle(color: _brokerMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () { Navigator.pop(dialogContext); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo account request created.'))); }, style: FilledButton.styleFrom(backgroundColor: _brokerBlue), child: const Text('Create')),
        ],
      ),
    );
  }
}

class _DemoSummary extends StatelessWidget {
  const _DemoSummary({required this.icon, required this.title, required this.value, required this.detail, required this.iconColor, this.valueColor = Colors.white, this.gold = false});
  final IconData icon; final String title, value, detail; final Color iconColor, valueColor; final bool gold;
  @override
  Widget build(BuildContext context) => Container(
    height: 106,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: gold ? const Color(0xFF33290D) : const Color(0xFF172257), borderRadius: BorderRadius.circular(15), border: Border.all(color: gold ? const Color(0xFF574614) : const Color(0xFF293B8D))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: iconColor, size: 16), const SizedBox(width: 5), Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700)))]),
      const SizedBox(height: 8),
      FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(color: valueColor, fontSize: 20, fontWeight: FontWeight.w800))),
      const SizedBox(height: 4),
      Expanded(child: Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _brokerMuted, fontSize: 7))),
    ]),
  );
}

class _DemoFilters extends StatelessWidget {
  const _DemoFilters({required this.filter, required this.onSelect});
  final String filter; final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
    _DemoFilter(label: 'All Accounts', count: '0', selected: filter == 'All Accounts', onTap: () => onSelect('All Accounts')),
    const SizedBox(width: 6), _DemoFilter(label: 'Active', count: '0', selected: filter == 'Active', onTap: () => onSelect('Active')),
    const SizedBox(width: 6), _DemoFilter(label: 'Suspended', count: '0', selected: filter == 'Suspended', onTap: () => onSelect('Suspended')),
  ]));
}
class _DemoFilter extends StatelessWidget {
  const _DemoFilter({required this.label, required this.count, required this.selected, required this.onTap});
  final String label, count; final bool selected; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: selected ? const Color(0xFF4054D8) : const Color(0xFF20295B), borderRadius: BorderRadius.circular(18)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)), const SizedBox(width: 5), Text(count, style: const TextStyle(color: Colors.white70, fontSize: 8))])));
}
class _DemoSearch extends StatelessWidget {
  const _DemoSearch({required this.controller, required this.onChanged});
  final TextEditingController controller; final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(controller: controller, onChanged: onChanged, style: const TextStyle(color: Colors.white, fontSize: 9), decoration: InputDecoration(hintText: 'Search ID, holder, leverage...', hintStyle: const TextStyle(color: _brokerMuted, fontSize: 8), prefixIcon: const Icon(Icons.search_rounded, color: _brokerMuted, size: 14), isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 8), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF3A4AB4))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _brokerBlue))));
}
