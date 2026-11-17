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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final muted = cs.onSurfaceVariant;
    final border = theme.dividerColor;
    final surface = cs.surface;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        final summaryColumns = constraints.maxWidth < 390 ? 1 : (compact ? 2 : 3);
        return ListView(
          padding: EdgeInsets.fromLTRB(compact ? 14 : 22, 14, compact ? 14 : 22, 116),
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PRACTICE TRADING', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.15)),
                const SizedBox(height: 5),
                Text('Demo Accounts', style: TextStyle(color: cs.onSurface, fontSize: compact ? 24 : 28, height: 1.12, fontWeight: FontWeight.w800, letterSpacing: -.6)),
                const SizedBox(height: 5),
                Text('Explore the markets in a simulated MT5 environment.', style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
              ])),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(15), border: Border.all(color: cs.primary.withValues(alpha: .16))),
                child: Icon(LucideIcons.flaskConical, color: cs.primary, size: 23),
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: dark ? .10 : .025), blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: compact
                  ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      _DemoIntroCopy(muted: muted, foreground: cs.onSurface),
                      const SizedBox(height: 12),
                      _CreateDemoButton(onPressed: () => _showCreateDialog(context), block: true),
                    ])
                  : Row(children: [
                      Expanded(child: _DemoIntroCopy(muted: muted, foreground: cs.onSurface)),
                      const SizedBox(width: 12),
                      _CreateDemoButton(onPressed: () => _showCreateDialog(context)),
                    ]),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (context, gridConstraints) {
              final spacing = 9.0;
              final width = (gridConstraints.maxWidth - spacing * (summaryColumns - 1)) / summaryColumns;
              return Wrap(spacing: spacing, runSpacing: 9, children: [
                SizedBox(width: width, child: const _DemoSummary(icon: LucideIcons.wallet, title: 'VIRTUAL BALANCE', value: r'$0.00', detail: 'Combined demo equity', tone: _DemoTone.blue)),
                SizedBox(width: width, child: const _DemoSummary(icon: LucideIcons.activity, title: 'ACTIVE ACCOUNTS', value: '0', detail: 'Currently available', tone: _DemoTone.gold)),
                SizedBox(width: width, child: const _DemoSummary(icon: LucideIcons.shieldCheck, title: 'TRADING MODE', value: 'Simulated', detail: 'No live funds at risk', tone: _DemoTone.neutral)),
              ]);
            }),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Your practice accounts', style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('Review and manage your virtual trading accounts.', style: TextStyle(color: muted, fontSize: 10)),
                    const SizedBox(height: 13),
                    if (compact) ...[
                      _DemoSearch(controller: _searchController, onChanged: (value) => setState(() => _query = value)),
                      const SizedBox(height: 10),
                      _DemoFilters(filter: _filter, onSelect: (value) => setState(() => _filter = value)),
                    ] else
                      Row(children: [
                        Expanded(child: _DemoFilters(filter: _filter, onSelect: (value) => setState(() => _filter = value))),
                        const SizedBox(width: 12),
                        SizedBox(width: 240, child: _DemoSearch(controller: _searchController, onChanged: (value) => setState(() => _query = value))),
                      ]),
                  ]),
                ),
                Divider(height: 1, color: border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 30, 18, 30),
                  child: Column(children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(color: cs.primary.withValues(alpha: .08), shape: BoxShape.circle, border: Border.all(color: cs.primary.withValues(alpha: .13))),
                      child: Icon(_query.isEmpty ? LucideIcons.chartNoAxesCombined : LucideIcons.searchX, color: cs.primary, size: 28),
                    ),
                    const SizedBox(height: 14),
                    Text(_query.isEmpty ? 'Your demo workspace is ready' : 'No matching demo accounts', textAlign: TextAlign.center, style: TextStyle(color: cs.onSurface, fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 330),
                      child: Text(
                        _query.isEmpty
                            ? 'Create a virtual MT5 account to practise strategies and explore market conditions without using real funds.'
                            : 'Try another account name or login ID, or clear your search to view all demo accounts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 11, height: 1.55),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_query.isNotEmpty)
                      OutlinedButton.icon(
                        onPressed: () { _searchController.clear(); setState(() => _query = ''); },
                        icon: const Icon(LucideIcons.x, size: 15),
                        label: const Text('Clear search'),
                      )
                    else
                      _CreateDemoButton(onPressed: () => _showCreateDialog(context)),
                    const SizedBox(height: 10),
                    Text('Demo trading only · No real-money transactions', style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ]),
            ),
          ],
        );
      }),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.viewInsetsOf(sheetContext).bottom),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: cs.onSurfaceVariant.withValues(alpha: .4), borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 18),
          Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: cs.primary.withValues(alpha: .09), borderRadius: BorderRadius.circular(13)), child: Icon(LucideIcons.flaskConical, color: cs.primary, size: 21)),
            const SizedBox(width: 11),
            Expanded(child: Text('Create demo account', style: TextStyle(color: cs.onSurface, fontSize: 17, fontWeight: FontWeight.w800))),
            IconButton(onPressed: () => Navigator.pop(sheetContext), icon: Icon(LucideIcons.x, color: cs.onSurfaceVariant)),
          ]),
          const SizedBox(height: 10),
          Text('A demo account uses virtual funds for simulated trading. No deposit is required.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.5)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo account creation is not connected to the MT5 service yet.')));
              },
              style: FilledButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
              child: const Text('Continue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _DemoIntroCopy extends StatelessWidget {
  const _DemoIntroCopy({required this.muted, required this.foreground});
  final Color muted, foreground;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Practise before you trade live', style: TextStyle(color: foreground, fontSize: 14, fontWeight: FontWeight.w800)),
    const SizedBox(height: 4),
    Text('Use a simulated account to get familiar with MT5 tools and market execution.', style: TextStyle(color: muted, fontSize: 10, height: 1.45)),
  ]);
}

class _CreateDemoButton extends StatelessWidget {
  const _CreateDemoButton({required this.onPressed, this.block = false});
  final VoidCallback onPressed;
  final bool block;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: block ? double.infinity : null,
      height: 44,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(LucideIcons.plus, size: 17),
        label: const Text('Create Demo Account', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        style: FilledButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
      ),
    );
  }
}

enum _DemoTone { blue, gold, neutral }

class _DemoSummary extends StatelessWidget {
  const _DemoSummary({required this.icon, required this.title, required this.value, required this.detail, required this.tone});
  final IconData icon;
  final String title, value, detail;
  final _DemoTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (tone) {
      _DemoTone.blue => cs.primary,
      _DemoTone.gold => const Color(0xFFD5A52C),
      _DemoTone.neutral => cs.onSurfaceVariant,
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .35))),
        ]),
        const SizedBox(height: 9),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(value, style: TextStyle(color: cs.onSurface, fontSize: 19, fontWeight: FontWeight.w800))),
        const SizedBox(height: 3),
        Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 9, height: 1.35)),
      ]),
    );
  }
}

class _DemoFilters extends StatelessWidget {
  const _DemoFilters({required this.filter, required this.onSelect});
  final String filter;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(children: [
      _DemoFilter(label: 'All Accounts', selected: filter == 'All Accounts', onTap: () => onSelect('All Accounts')),
      const SizedBox(width: 6),
      _DemoFilter(label: 'Active', selected: filter == 'Active', onTap: () => onSelect('Active')),
      const SizedBox(width: 6),
      _DemoFilter(label: 'Suspended', selected: filter == 'Suspended', onTap: () => onSelect('Suspended')),
    ]),
  );
}

class _DemoFilter extends StatelessWidget {
  const _DemoFilter({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: .10) : Colors.transparent,
          border: Border.all(color: selected ? cs.primary.withValues(alpha: .45) : Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: selected ? cs.primary : cs.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _DemoSearch extends StatelessWidget {
  const _DemoSearch({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor;
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: cs.onSurface, fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Search account ID or name',
          hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
          prefixIcon: Icon(LucideIcons.search, color: cs.onSurfaceVariant, size: 17),
          isDense: true,
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary, width: 1.3)),
        ),
      ),
    );
  }
}
