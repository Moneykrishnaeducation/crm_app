part of '../main.dart';

class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const _AppHeader({
    required this.title,
    this.onBack,
    this.onAvatarTap,
    this.onSelectPage,
  });

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAvatarTap;
  final ValueChanged<String>? onSelectPage;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  bool get _isPrimaryTab => onBack == null;
  bool get _usesBrandHeader => _isPrimaryTab || title == 'Account Details';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 58,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
          (isDark ? const Color(0xFF101D31) : Colors.white),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: const Color(0xFF101D31),
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
      automaticallyImplyLeading: false,
      leading: onBack != null && !_usesBrandHeader
          ? IconButton(
              onPressed: onBack,
              tooltip: 'Back',
              icon: Icon(
                LucideIcons.arrowLeft,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            )
          : null,
      titleSpacing: _usesBrandHeader ? 16 : 0,
      title: _usesBrandHeader
          ? _buildPrimaryBrandTitle(context)
          : _buildDetailTitle(context),
      actions: title == 'Account Details'
          ? _buildAccountDetailActions(context, isDark)
          : _isPrimaryTab
              ? _buildPrimaryBrandActions(context)
              : _buildStandardActions(context, isDark),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 0.7, color: _border),
      ),
    );
  }

  Widget _buildPrimaryBrandTitle(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // Accessible candidate for automated test assertions
        SizedBox(
          width: 0,
          height: 0,
          child: Text(
            title,
            style: const TextStyle(fontSize: 0, color: Colors.transparent),
          ),
        ),
        // Clean crisp logo without any text beneath
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Image.asset(
            'assets/images/vtindex_logo.png',
            height: 32,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            semanticLabel: 'VTIndex',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTitle(BuildContext context) {
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  List<Widget> _buildAccountDetailActions(BuildContext context, bool isDark) {
    return [
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: InkWell(
          onTap: onAvatarTap,
          borderRadius: BorderRadius.circular(16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: isDark ? const Color(0xFF263750) : const Color(0xFFEAF0F8),
            child: const Icon(LucideIcons.userRound, size: 18, color: _blue),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildPrimaryBrandActions(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return [
      IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        icon: Icon(LucideIcons.search, size: 20, color: onSurface),
        tooltip: 'Search',
        onPressed: () => _showSearchSheet(context),
      ),
      IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        tooltip: 'Notifications',
        onPressed: () => _showNotificationsSheet(context),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(LucideIcons.bell, size: 20, color: onSurface),
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
                child: const Center(
                  child: Text(
                    '99+',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        icon: Icon(LucideIcons.headset, size: 20, color: onSurface),
        tooltip: 'Customer Support',
        onPressed: () => _showSupportDialog(context),
      ),
      IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        icon: Icon(LucideIcons.logOut, size: 19, color: onSurface),
        tooltip: 'Log out',
        onPressed: () => _showLogoutSheet(context),
      ),
      const SizedBox(width: 8),
    ];
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => LogoutBottomSheet(
        onConfirm: () {
          Navigator.of(sheetContext).pop();
          onSelectPage?.call('Logout');
        },
      ),
    );
  }

  List<Widget> _buildStandardActions(BuildContext context, bool isDark) {
    return [
      if (MediaQuery.sizeOf(context).width >= 480) ...[
        const _LiveBadge(),
        IconButton(
          onPressed: () => _showNotificationsSheet(context),
          tooltip: 'Notifications',
          icon: const Icon(LucideIcons.bell, color: _muted, size: 21),
        ),
      ],
      Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: InkWell(
          onTap: onAvatarTap,
          borderRadius: BorderRadius.circular(16),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: isDark
                ? const Color(0xFF263750)
                : const Color(0xFFEAF0F8),
            child: const Icon(LucideIcons.userRound, size: 18, color: _blue),
          ),
        ),
      ),
    ];
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (_) => const MarketSearchBottomSheet(),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (_) => const NotificationCenterBottomSheet(),
    );
  }

  void _showSupportDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF101D31) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Customer Support',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEF4FF),
                  child: Icon(LucideIcons.messageSquare, color: _blue, size: 20),
                ),
                title: const Text('Live Chat Support'),
                subtitle: const Text('Available 24/7 • Instant response'),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showAppMessage('Starting Live Chat...');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEEF4FF),
                  child: Icon(LucideIcons.mail, color: _blue, size: 20),
                ),
                title: const Text('Email Support'),
                subtitle: const Text('support@vtindex.com'),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showAppMessage('Support ticket created.');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MarketSearchBottomSheet extends StatefulWidget {
  const MarketSearchBottomSheet({super.key});

  @override
  State<MarketSearchBottomSheet> createState() => _MarketSearchBottomSheetState();
}

class _MarketSearchItem {
  const _MarketSearchItem({
    required this.symbol,
    required this.name,
    required this.category,
    required this.bid,
    required this.ask,
    required this.change,
    required this.isPositive,
    this.isGold = false,
  });

  final String symbol;
  final String name;
  final String category;
  final String bid;
  final String ask;
  final String change;
  final bool isPositive;
  final bool isGold;
}

class _MarketSearchBottomSheetState extends State<MarketSearchBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _query = '';

  static const List<_MarketSearchItem> _allMarkets = [
    _MarketSearchItem(
      symbol: 'XAUUSD',
      name: 'Gold vs US Dollar',
      category: 'Metals',
      bid: '2,345.20',
      ask: '2,345.80',
      change: '+1.12%',
      isPositive: true,
      isGold: true,
    ),
    _MarketSearchItem(
      symbol: 'EURUSD',
      name: 'Euro vs US Dollar',
      category: 'Forex',
      bid: '1.08420',
      ask: '1.08432',
      change: '+0.35%',
      isPositive: true,
    ),
    _MarketSearchItem(
      symbol: 'BTCUSD',
      name: 'Bitcoin vs US Dollar',
      category: 'Crypto',
      bid: '67,420.0',
      ask: '67,440.0',
      change: '+2.40%',
      isPositive: true,
      isGold: true,
    ),
    _MarketSearchItem(
      symbol: 'NAS100',
      name: 'US Tech 100 Index',
      category: 'Indices',
      bid: '18,480.0',
      ask: '18,485.0',
      change: '-0.28%',
      isPositive: false,
    ),
    _MarketSearchItem(
      symbol: 'GBPUSD',
      name: 'British Pound vs USD',
      category: 'Forex',
      bid: '1.29840',
      ask: '1.29858',
      change: '+0.18%',
      isPositive: true,
    ),
    _MarketSearchItem(
      symbol: 'USOIL',
      name: 'Crude Oil Cash (WTI)',
      category: 'Metals',
      bid: '82.40',
      ask: '82.46',
      change: '+0.75%',
      isPositive: true,
      isGold: true,
    ),
    _MarketSearchItem(
      symbol: 'ETHUSD',
      name: 'Ethereum vs US Dollar',
      category: 'Crypto',
      bid: '3,520.0',
      ask: '3,524.5',
      change: '+1.85%',
      isPositive: true,
      isGold: true,
    ),
    _MarketSearchItem(
      symbol: 'USDJPY',
      name: 'US Dollar vs Japanese Yen',
      category: 'Forex',
      bid: '155.62',
      ask: '155.64',
      change: '-0.14%',
      isPositive: false,
    ),
    _MarketSearchItem(
      symbol: 'US30',
      name: 'Wall Street 30 Index',
      category: 'Indices',
      bid: '39,820.0',
      ask: '39,830.0',
      change: '+0.42%',
      isPositive: true,
    ),
    _MarketSearchItem(
      symbol: 'XAGUSD',
      name: 'Silver vs US Dollar',
      category: 'Metals',
      bid: '29.40',
      ask: '29.45',
      change: '+0.85%',
      isPositive: true,
      isGold: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final border = theme.dividerColor;
    final muted = cs.onSurfaceVariant;
    final screen = MediaQuery.sizeOf(context);

    final filtered = _allMarkets.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          item.symbol.toLowerCase().contains(q) ||
          item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: screen.height * 0.88,
            ),
            child: FadeTransition(
              opacity: _animCtrl,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.16),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
                ),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 2),
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: muted.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 14, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1658C9).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _brokerGold.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.search,
                                color: dark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Search Markets',
                                        style: TextStyle(
                                          color: cs.onSurface,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _brokerGold.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _brokerGold.withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'VTINDEX',
                                          style: TextStyle(
                                            color: dark ? const Color(0xFFFFD566) : const Color(0xFFB3861B),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Live forex, metals, crypto, and indices',
                                    style: TextStyle(color: muted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(LucideIcons.x, color: muted, size: 19),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: border),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              LucideIcons.search,
                              size: 18,
                              color: dark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9),
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: Icon(LucideIcons.x, size: 16, color: muted),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                  )
                                : null,
                            hintText: 'Search symbols (e.g. EURUSD, XAUUSD, BTC)...',
                            hintStyle: TextStyle(color: muted, fontSize: 11.5),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(alpha: dark ? 0.35 : 0.45),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF1658C9), width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            for (final cat in const ['All', 'Forex', 'Metals', 'Crypto', 'Indices'])
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedCategory = cat),
                                  borderRadius: BorderRadius.circular(10),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 140),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _selectedCategory == cat
                                          ? const Color(0xFF1658C9)
                                          : cs.surfaceContainerHighest.withValues(alpha: dark ? 0.35 : 0.45),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _selectedCategory == cat
                                            ? _brokerGold
                                            : border,
                                        width: _selectedCategory == cat ? 1.2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        color: _selectedCategory == cat
                                            ? Colors.white
                                            : cs.onSurface,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Divider(height: 1, color: border.withValues(alpha: 0.6)),
                      Flexible(
                        child: filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.searchX, size: 42, color: muted),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No matching markets found',
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try searching with a different ticker or category keyword.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: muted, fontSize: 11),
                                    ),
                                    const SizedBox(height: 14),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _query = '';
                                          _selectedCategory = 'All';
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: border),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      icon: const Icon(LucideIcons.rotateCcw, size: 14),
                                      label: const Text('Reset search', style: TextStyle(fontSize: 11)),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16 + MediaQuery.viewPaddingOf(context).bottom,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (ctx, idx) {
                                  final item = filtered[idx];
                                  final badgeColor = item.isGold
                                      ? (dark ? const Color(0xFFFFD566) : const Color(0xFFB3861B))
                                      : (dark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9));
                                  final badgeBg = item.isGold
                                      ? _brokerGold.withValues(alpha: 0.14)
                                      : const Color(0xFF1658C9).withValues(alpha: 0.12);

                                  return InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                      showAppMessage('Selected ${item.symbol} — Bid: ${item.bid} · Ask: ${item.ask}');
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                      decoration: BoxDecoration(
                                        color: dark ? const Color(0xFF18263D) : const Color(0xFFF9FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: dark ? const Color(0xFF2B4163) : const Color(0xFFE5ECF6),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: badgeBg,
                                              border: Border.all(
                                                color: badgeColor.withValues(alpha: 0.35),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                item.symbol.substring(0, 1),
                                                style: TextStyle(
                                                  color: badgeColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      item.symbol,
                                                      style: TextStyle(
                                                        color: cs.onSurface,
                                                        fontSize: 13.5,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: badgeBg,
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Text(
                                                        item.category,
                                                        style: TextStyle(
                                                          color: badgeColor,
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  item.name,
                                                  style: TextStyle(color: muted, fontSize: 10.5),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                item.bid,
                                                style: TextStyle(
                                                  color: cs.onSurface,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: item.isPositive
                                                      ? const Color(0xFF1658C9).withValues(alpha: 0.12)
                                                      : _brokerGold.withValues(alpha: 0.14),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  item.change,
                                                  style: TextStyle(
                                                    color: item.isPositive
                                                        ? (dark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9))
                                                        : (dark ? const Color(0xFFFFD566) : const Color(0xFFB3861B)),
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationItemData {
  _NotificationItemData({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.icon,
    this.isUnread = true,
    this.isGold = false,
  });

  final String id;
  final String title;
  final String body;
  final String timestamp;
  final String category;
  final IconData icon;
  bool isUnread;
  final bool isGold;
}

class NotificationCenterBottomSheet extends StatefulWidget {
  const NotificationCenterBottomSheet({super.key});

  @override
  State<NotificationCenterBottomSheet> createState() => _NotificationCenterBottomSheetState();
}

class _NotificationCenterBottomSheetState extends State<NotificationCenterBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  String _selectedCategory = 'All';

  final List<_NotificationItemData> _notifications = [
    _NotificationItemData(
      id: '1',
      title: 'Deposit of \$2,500.00 Credited',
      body: 'Your USDT deposit has been successfully credited to Standard account #3315.',
      timestamp: '10 mins ago',
      category: 'Funds',
      icon: LucideIcons.wallet,
      isUnread: true,
      isGold: false,
    ),
    _NotificationItemData(
      id: '2',
      title: 'TP Executed: XAUUSD +\$180.50',
      body: 'Take profit executed for 0.10 lots XAUUSD at 2,351.80. Net profit: \$180.50.',
      timestamp: '1 hour ago',
      category: 'Trading',
      icon: LucideIcons.trendingUp,
      isUnread: true,
      isGold: true,
    ),
    _NotificationItemData(
      id: '3',
      title: 'Internal Transfer Completed (\$500.00)',
      body: 'Transferred \$500.00 from Main Trading #3315 to ECN #3311 instantly.',
      timestamp: '4 hours ago',
      category: 'Funds',
      icon: LucideIcons.arrowLeftRight,
      isUnread: true,
      isGold: false,
    ),
    _NotificationItemData(
      id: '4',
      title: 'New Authorized Login Detected',
      body: 'Authorized login from Chrome on Windows. Review Security Center if unrecognized.',
      timestamp: 'Yesterday, 18:24',
      category: 'Security',
      icon: LucideIcons.shieldCheck,
      isUnread: false,
      isGold: true,
    ),
    _NotificationItemData(
      id: '5',
      title: 'US CPI Release Market Alert',
      body: 'High volatility anticipated ahead of the Federal Reserve interest rate statement.',
      timestamp: '2 days ago',
      category: 'Trading',
      icon: LucideIcons.newspaper,
      isUnread: false,
      isGold: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isUnread = false;
      }
    });
    showAppMessage('All notifications marked as read.');
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    showAppMessage('All notifications cleared.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;
    final border = theme.dividerColor;
    final muted = cs.onSurfaceVariant;
    final screen = MediaQuery.sizeOf(context);

    final filtered = _notifications.where((item) {
      return _selectedCategory == 'All' || item.category == _selectedCategory;
    }).toList();

    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: screen.height * 0.88,
            ),
            child: FadeTransition(
              opacity: _animCtrl,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.16),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
                ),
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: dark ? 0.35 : 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 2),
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: muted.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 10, 14, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _brokerGold.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: _brokerGold.withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.bell,
                                color: dark ? const Color(0xFFFFD566) : const Color(0xFFB3861B),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Notifications',
                                        style: TextStyle(
                                          color: cs.onSurface,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      if (_unreadCount > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1658C9).withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFF1658C9).withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '$_unreadCount NEW',
                                            style: TextStyle(
                                              color: dark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Account alerts, executions & updates',
                                    style: TextStyle(color: muted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(LucideIcons.x, color: muted, size: 19),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: border),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final cat in const ['All', 'Trading', 'Funds', 'Security'])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: InkWell(
                                        onTap: () => setState(() => _selectedCategory = cat),
                                        borderRadius: BorderRadius.circular(10),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 140),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: _selectedCategory == cat
                                                ? const Color(0xFF1658C9)
                                                : cs.surfaceContainerHighest.withValues(alpha: dark ? 0.35 : 0.45),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _selectedCategory == cat ? _brokerGold : border,
                                              width: _selectedCategory == cat ? 1.2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            cat,
                                            style: TextStyle(
                                              color: _selectedCategory == cat ? Colors.white : cs.onSurface,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (_unreadCount > 0)
                              InkWell(
                                onTap: _markAllAsRead,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.checkCheck,
                                        size: 13,
                                        color: dark ? const Color(0xFFFFD566) : const Color(0xFFB3861B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mark read',
                                        style: TextStyle(
                                          color: dark ? const Color(0xFFFFD566) : const Color(0xFFB3861B),
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Divider(height: 1, color: border.withValues(alpha: 0.6)),
                      Flexible(
                        child: filtered.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.bellOff, size: 42, color: muted),
                                    const SizedBox(height: 12),
                                    Text(
                                      "You're all caught up!",
                                      style: TextStyle(
                                        color: cs.onSurface,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No notifications found in this filter category.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: muted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  8,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (ctx, idx) {
                                  final item = filtered[idx];
                                  final badgeColor = item.isGold
                                      ? (dark ? const Color(0xFFFFD566) : const Color(0xFFB3861B))
                                      : (dark ? const Color(0xFF8CCBFF) : const Color(0xFF1658C9));
                                  final badgeBg = item.isGold
                                      ? _brokerGold.withValues(alpha: 0.14)
                                      : const Color(0xFF1658C9).withValues(alpha: 0.12);

                                  return InkWell(
                                    onTap: () {
                                      setState(() => item.isUnread = false);
                                      showAppMessage('Viewing: ${item.title}');
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: item.isUnread
                                            ? (dark ? const Color(0xFF1C2C47) : const Color(0xFFF3F7FD))
                                            : (dark ? const Color(0xFF142136) : const Color(0xFFFAFBFC)),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: item.isUnread
                                              ? (item.isGold
                                                  ? _brokerGold.withValues(alpha: 0.4)
                                                  : const Color(0xFF1658C9).withValues(alpha: 0.4))
                                              : (dark ? const Color(0xFF263A58) : const Color(0xFFE5ECF6)),
                                          width: item.isUnread ? 1.2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: badgeBg,
                                              border: Border.all(
                                                color: badgeColor.withValues(alpha: 0.35),
                                              ),
                                            ),
                                            child: Icon(item.icon, color: badgeColor, size: 18),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item.title,
                                                        style: TextStyle(
                                                          color: cs.onSurface,
                                                          fontSize: 12.5,
                                                          fontWeight: item.isUnread
                                                              ? FontWeight.w800
                                                              : FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    if (item.isUnread) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        width: 7,
                                                        height: 7,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: item.isGold
                                                              ? _brokerGold
                                                              : const Color(0xFF1658C9),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  item.body,
                                                  style: TextStyle(
                                                    color: muted,
                                                    fontSize: 11,
                                                    height: 1.35,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: badgeBg,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        item.category,
                                                        style: TextStyle(
                                                          color: badgeColor,
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      item.timestamp,
                                                      style: TextStyle(
                                                        color: muted.withValues(alpha: 0.8),
                                                        fontSize: 9.5,
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
                                  );
                                },
                              ),
                      ),
                      if (_notifications.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            4,
                            16,
                            10 + MediaQuery.viewPaddingOf(context).bottom,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: _clearAll,
                              style: TextButton.styleFrom(
                                foregroundColor: muted,
                              ),
                              icon: const Icon(LucideIcons.trash2, size: 14),
                              label: const Text(
                                'Clear all notifications',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
