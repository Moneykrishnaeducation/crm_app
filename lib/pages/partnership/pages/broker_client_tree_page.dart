import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../app_notifications.dart';
import '../../../services/auth_api.dart';
import '../models/partnership_models.dart';
import '../widgets/partnership_modals.dart';
import '../widgets/partnership_theme.dart';

// ============================================================================
// SUB-PAGE: BROKERCLIENTTREEPAGE (CLIENT LIST & HIERARCHY)
// ============================================================================

class BrokerClientTreePage extends StatefulWidget {
  const BrokerClientTreePage({super.key});

  @override
  State<BrokerClientTreePage> createState() => _BrokerClientTreePageState();
}

class _BrokerClientTreePageState extends State<BrokerClientTreePage> {
  bool _loading = true;
  List<IbClient> _clients = [];
  final Set<String> _expandedIds = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTree();
  }

  Future<void> _fetchTree() async {
    setState(() => _loading = true);
    try {
      final res = await AuthApi.instance.getIbClientTree(page: 1, perPage: 1000);
      final rawList = res['clients'] ?? res['results'] ?? res['data'];
      final parsed = <IbClient>[];
      if (rawList is List) {
        for (final item in rawList.whereType<Map>()) {
          parsed.add(IbClient.fromJson(item.cast<String, dynamic>()));
        }
      }
      if (mounted) {
        setState(() {
          _clients = parsed;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _countAll(List<IbClient> list) {
    int total = 0;
    for (final c in list) {
      total += 1 + _countAll(c.clients);
    }
    return total;
  }

  int _maxDepth(List<IbClient> list, int current) {
    int m = current;
    for (final c in list) {
      if (c.clients.isNotEmpty) {
        m = math.max(m, _maxDepth(c.clients, current + 1));
      }
    }
    return m;
  }

  List<IbClient> _filterClients(List<IbClient> list, String q) {
    if (q.isEmpty) return list;
    final res = <IbClient>[];
    for (final c in list) {
      final matches = c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.referralCode.toLowerCase().contains(q) ||
          c.accounts.any((a) => a.accountId.contains(q));
      final subMatches = _filterClients(c.clients, q);
      if (matches || subMatches.isNotEmpty) {
        res.add(IbClient(
          id: c.id,
          name: c.name,
          email: c.email,
          phone: c.phone,
          registeredDate: c.registeredDate,
          referralCode: c.referralCode,
          commissionProfileName: c.commissionProfileName,
          level: c.level,
          isIb: c.isIb,
          ibRequestStatus: c.ibRequestStatus,
          accounts: c.accounts,
          clients: subMatches,
        ));
      }
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    final colors = PartnershipColors.of(context);
    final totalNetwork = _countAll(_clients);
    final direct = _clients.length;
    final subTier = math.max(0, totalNetwork - direct);
    final depth = _maxDepth(_clients, 1);
    final filtered = _filterClients(_clients, _searchQuery.trim().toLowerCase());

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: colors.appBarBg,
        foregroundColor: colors.text,
        elevation: 0,
        title: const Text('Client Network Hierarchy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: _showAddClientModal,
            icon: const Icon(LucideIcons.userPlus),
            tooltip: 'Add Client',
          ),
          IconButton(
            onPressed: _fetchTree,
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: PartnershipBackdrop(
        colors: colors,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
          children: [
            // Search Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.search, size: 16, color: colors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: colors.text, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search client by name, email, code or account...',
                        hintStyle: TextStyle(color: colors.muted, fontSize: 12),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 14),
                      onPressed: () => setState(() => _searchQuery = ''),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Network stat badges
            Row(
              children: [
                _treeStatChip(colors, 'TOTAL NETWORK', '$totalNetwork', LucideIcons.users, colors.gold),
                const SizedBox(width: 8),
                _treeStatChip(colors, 'DIRECT (L1)', '$direct', LucideIcons.user, colors.blue),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _treeStatChip(colors, 'SUB-TIER (L2+)', '$subTier', LucideIcons.network, colors.green),
                const SizedBox(width: 8),
                _treeStatChip(colors, 'MAX DEPTH', 'L$depth', LucideIcons.gitBranch, const Color(0xFFA855F7)),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(color: colors.blue)),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.users, size: 40, color: colors.muted),
                      const SizedBox(height: 10),
                      Text(
                        'No clients found in this network',
                        style: TextStyle(color: colors.muted, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map((client) => _buildClientNode(client, colors, 0)),
          ],
        ),
      ),
    );
  }

  Widget _treeStatChip(
    PartnershipColors colors,
    String label,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientNode(IbClient client, PartnershipColors colors, int depth) {
    final theme = getIbLevelTheme(client.level, colors.isDark);
    final hasChildren = client.clients.isNotEmpty;
    final isExpanded = _expandedIds.contains(client.id);

    final avatarWidget = Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: theme.avatarBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.avatarBorder),
      ),
      alignment: Alignment.center,
      child: Text(
        client.initials,
        style: TextStyle(color: theme.avatarText, fontWeight: FontWeight.w900, fontSize: 13),
      ),
    );

    final clientInfoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line 1: Name + Level + Plan/Tag Badge
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              client.name,
              style: TextStyle(color: colors.text, fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.badgeBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: theme.badgeBg.withValues(alpha: 0.5)),
              ),
              child: Text(
                'L${client.level}',
                style: TextStyle(color: theme.badgeBg, fontSize: 9.5, fontWeight: FontWeight.w900),
              ),
            ),
            if (client.commissionProfileName.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: colors.gold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  client.commissionProfileName,
                  style: TextStyle(color: colors.gold, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        // Line 2: email · phone · Joined YYYY-MM-DD · Code
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 3,
          children: [
            if (client.email.isNotEmpty)
              Text(
                client.email,
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
            if (client.phone.isNotEmpty)
              Text(
                client.phone,
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
            if (client.registeredDate.isNotEmpty)
              Text(
                'Joined ${client.registeredDate.split("T").first}',
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
            if (client.referralCode.isNotEmpty)
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: client.referralCode));
                  showAppMessage('Referral code copied: ${client.referralCode}');
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.link2, size: 11.5, color: colors.blue),
                      const SizedBox(width: 3),
                      Text(
                        client.referralCode,
                        style: TextStyle(color: colors.blue, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 3),
                      Icon(LucideIcons.copy, size: 11, color: colors.muted),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );

    final actionItems = <Widget>[
      if (client.isIb) ...[
        // Referrals badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.isDark ? colors.subCard : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.users, size: 12, color: colors.muted),
              const SizedBox(width: 4),
              Text(
                '${client.clients.length} ${client.clients.length == 1 ? 'referral' : 'referrals'}',
                style: TextStyle(color: colors.muted, fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        // Lots badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.green.withValues(alpha: 0.4)),
          ),
          child: Text(
            '${client.totalLots.toStringAsFixed(2)} lots',
            style: TextStyle(color: colors.green, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        // Earned badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.green.withValues(alpha: 0.4)),
          ),
          child: Text(
            '\$${client.totalCommission.toStringAsFixed(2)} earned',
            style: TextStyle(color: colors.green, fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
        // IB Partner badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
          decoration: BoxDecoration(
            color: colors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.green.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.shieldCheck, size: 12, color: colors.green),
              const SizedBox(width: 4),
              Text(
                'IB Partner',
                style: TextStyle(color: colors.green, fontSize: 10.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ] else ...[
        if (client.ibRequestStatus == 'pending')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.gold.withValues(alpha: 0.45)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.clock, size: 12, color: colors.gold),
                const SizedBox(width: 4),
                Text('IB Pending', style: TextStyle(color: colors.gold, fontSize: 10.5, fontWeight: FontWeight.w800)),
              ],
            ),
          )
        else
          // Request IB Button
          OutlinedButton.icon(
            onPressed: () => showConfirmIbModal(
              context,
              client,
              onIbChanged: _fetchTree,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colors.blue, width: 1.2),
              backgroundColor: colors.blue.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: Icon(LucideIcons.userPlus, size: 12.5, color: colors.blue),
            label: Text(
              'Request IB',
              style: TextStyle(fontSize: 11, color: colors.blue, fontWeight: FontWeight.w800),
            ),
          ),
      ],
      // Accounts button
      OutlinedButton.icon(
        onPressed: () => showClientAccountsModal(
          context,
          client,
          onIbChanged: _fetchTree,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: colors.border),
          backgroundColor: colors.isDark ? colors.subCard : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(LucideIcons.creditCard, size: 12, color: colors.text),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Accounts', style: TextStyle(fontSize: 11, color: colors.text, fontWeight: FontWeight.w700)),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: colors.muted.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${client.accounts.length}',
                style: TextStyle(fontSize: 10, color: colors.text, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      if (hasChildren)
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              if (isExpanded) {
                _expandedIds.remove(client.id);
              } else {
                _expandedIds.add(client.id);
              }
            });
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: colors.border),
            backgroundColor: colors.isDark ? colors.subCard : Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 13, color: colors.text),
          label: Text(
            isExpanded ? 'Hide team' : 'View team',
            style: TextStyle(fontSize: 11, color: colors.text, fontWeight: FontWeight.w700),
          ),
        ),
    ];

    final cardWidget = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: theme.color),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 720;
                if (isWide) {
                  return Row(
                    children: [
                      avatarWidget,
                      const SizedBox(width: 12),
                      Expanded(child: clientInfoColumn),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < actionItems.length; i++) ...[
                            if (i > 0) const SizedBox(width: 6),
                            actionItems[i],
                          ],
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          avatarWidget,
                          const SizedBox(width: 10),
                          Expanded(child: clientInfoColumn),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: actionItems,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: (depth * 20.0).clamp(0.0, 60.0), bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (depth > 0)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 1.5,
                  color: colors.border,
                  margin: const EdgeInsets.only(right: 6),
                ),
                Expanded(child: cardWidget),
              ],
            )
          else
            cardWidget,
          if (hasChildren && isExpanded) ...[
            const SizedBox(height: 10),
            ...client.clients.map((child) => _buildClientNode(child, colors, depth + 1)),
          ],
        ],
      ),
    );
  }

  void _showAddClientModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const ClientRegistrationDialog(),
    ).then((_) {
      if (mounted) _fetchTree();
    });
  }
}
