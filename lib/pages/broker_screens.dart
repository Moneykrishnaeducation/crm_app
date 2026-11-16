part of '../main.dart';

const _brokerNavy = Color(0xFF10264B);
const _brokerPanel = Colors.white;
const _brokerBlue = Color(0xFF174A8B);
const _brokerGold = Color(0xFFD8A82E);
const _brokerMuted = Color(0xFF71809A);

class BrokerDashboardPage extends StatelessWidget {
  const BrokerDashboardPage({
    super.key,
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onSelectPage,
  });
  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: 0,
            height: 0,
            child: Text(
              'Dashboard',
              style: TextStyle(fontSize: 0, color: Colors.transparent),
            ),
          ),
          _BrokerBalance(
            visible: balanceVisible,
            onToggle: onToggleBalance,
          ),
          const SizedBox(height: 14),
          _QuickActionsRow(onSelectPage: onSelectPage),
          const SizedBox(height: 14),
          _DualFeatureCards(onSelectPage: onSelectPage),
          const SizedBox(height: 14),
          const _MarketInsightsBanner(),
          const SizedBox(height: 20),
          _MarketsSection(onSelectPage: onSelectPage),
        ],
      ),
    ),
  );
}

class _BrokerBalance extends StatelessWidget {
  const _BrokerBalance({required this.visible, required this.onToggle});
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      gradient: const LinearGradient(
        colors: [
          Color(0xFF0B2256),
          Color(0xFF0F3678),
          Color(0xFF144EA1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: const Color(0xFF2A579A).withValues(alpha: 0.4),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x330A1D45),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  width: 0,
                  height: 0,
                  child: Text(
                    'Total portfolio balance',
                    style: TextStyle(fontSize: 0, color: Colors.transparent),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  visible ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          visible ? '\$125,800.00' : '••••••••',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: visible ? -0.5 : 2.5,
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              color: Color(0xFFD4E2F8),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
            children: [
              const TextSpan(text: 'Position Total P&L: '),
              TextSpan(
                text: visible ? '+\$1,248.50 USD' : '****** USD',
                style: TextStyle(
                  color: visible
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFD4E2F8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF223656) : const Color(0xFFE5EBF5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _QuickActionItem(
              icon: LucideIcons.arrowDownToLine,
              label: 'Deposit',
              onTap: () => onSelectPage('Deposit'),
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: LucideIcons.arrowUpRight,
              label: 'Withdraw',
              onTap: () => onSelectPage('Withdraw'),
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: LucideIcons.arrowLeftRight,
              label: 'Transfer',
              onTap: () => onSelectPage('Internal Transfer'),
            ),
          ),
          Expanded(
            child: _QuickActionItem(
              icon: LucideIcons.fileText,
              label: 'Report Center',
              onTap: () => onSelectPage('Transactions'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B2E4E) : const Color(0xFFEEF4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D5AFF),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DualFeatureCards extends StatelessWidget {
  const _DualFeatureCards({required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? const Color(0xFF223656) : const Color(0xFFE5EBF5);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.2 : 0.035);

    return Row(
      children: [
        // Quick Trade Card
        Expanded(
          child: InkWell(
            onTap: () => _showQuickTradeDialog(context),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2E4E) : const Color(0xFFEEF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.zap,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D5AFF),
                      size: 15,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Trade',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'EURUSD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _brokerMuted,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '1.10090',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '↘ 0.10%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Refer & Earn Card
        Expanded(
          child: InkWell(
            onTap: () => onSelectPage('Partnership'),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B2E4E) : const Color(0xFFEEF4FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.userPlus,
                      color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D5AFF),
                      size: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Refer & Earn',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Invite one friend',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _brokerMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MarketInsightsBanner extends StatelessWidget {
  const _MarketInsightsBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF223656) : const Color(0xFFE5EBF5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B2E4E) : const Color(0xFFEEF4FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.barChart2,
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D5AFF),
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Insights',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Stay informed with the latest market news and insights.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _brokerMuted,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const _StackedCoinsBadge(),
        ],
      ),
    );
  }
}

class _StackedCoinsBadge extends StatelessWidget {
  const _StackedCoinsBadge();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 58,
      height: 42,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _StackedCoinsPainter(),
        ),
      ),
    );
  }
}

class _StackedCoinsPainter extends CustomPainter {
  const _StackedCoinsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final coinWidth = size.width * 0.42;
    final coinHeight = size.height * 0.76;

    final coins = [
      (dx: size.width * 0.18, dy: size.height * 0.50, opacity: 0.45, scale: 0.82),
      (dx: size.width * 0.36, dy: size.height * 0.48, opacity: 0.70, scale: 0.90),
      (dx: size.width * 0.54, dy: size.height * 0.46, opacity: 0.90, scale: 0.97),
      (dx: size.width * 0.72, dy: size.height * 0.44, opacity: 1.00, scale: 1.00),
    ];

    for (final c in coins) {
      final dx = c.dx;
      final dy = c.dy;
      final op = c.opacity;
      final sc = c.scale;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(-0.16);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: coinWidth * sc,
        height: coinHeight * sc,
      );

      final shadowPaint = Paint()
        ..color = const Color(0xFF1D5AFF).withValues(alpha: 0.12 * op)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawOval(rect.shift(const Offset(2, 2)), shadowPaint);

      final gradient = LinearGradient(
        colors: [
          const Color(0xFFBFDBFE).withValues(alpha: op),
          const Color(0xFF60A5FA).withValues(alpha: op),
          const Color(0xFF2563EB).withValues(alpha: op),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      final bodyPaint = Paint()..shader = gradient.createShader(rect);
      canvas.drawOval(rect, bodyPaint);

      final borderPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.65 * op);
      canvas.drawOval(rect, borderPaint);

      final innerRect = rect.deflate(2.5);
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = Colors.white.withValues(alpha: 0.35 * op);
      canvas.drawOval(innerRect, innerPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MarketsSection extends StatefulWidget {
  const _MarketsSection({required this.onSelectPage});
  final ValueChanged<String> onSelectPage;

  @override
  State<_MarketsSection> createState() => _MarketsSectionState();
}

class _MarketsSectionState extends State<_MarketsSection> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Favorites',
    'Metals',
    'Energy',
    'FX Minors',
    'Index',
    'Cryptos',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Markets',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final active = _selectedTabIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedTabIndex = index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? (isDark ? const Color(0xFF1B3158) : const Color(0xFFEBF2FF))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D5AFF))
                            : _brokerMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: const [
              Text(
                'Product / Change',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _brokerMuted,
                ),
              ),
              Spacer(),
              SizedBox(
                width: 82,
                child: Text(
                  'Sell',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _brokerMuted,
                  ),
                ),
              ),
              SizedBox(width: 24),
              SizedBox(
                width: 82,
                child: Text(
                  'Buy',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _brokerMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 0.8, color: _border),
        ..._buildQuotesForTab(context),
        const SizedBox(height: 22),
        const Center(
          child: Text(
            'No more data',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _brokerMuted,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildQuotesForTab(BuildContext context) {
    if (_selectedTabIndex == 1) {
      // Metals
      return [
        _MarketQuoteRow(
          badge: const _USTECHBadge(),
          symbol: 'XAUUSD',
          change: '↗ 0.35%',
          isChangePositive: true,
          time: '14:35:28',
          sell: '2,654.12',
          buy: '2,654.48',
          sellColor: const Color(0xFF16A34A),
          buyColor: const Color(0xFF16A34A),
          onTap: () => _showQuickTradeDialog(
            context,
            symbol: 'XAUUSD',
            sellPrice: 2654.12,
            buyPrice: 2654.48,
          ),
        ),
        _MarketQuoteRow(
          badge: const _USTECHBadge(),
          symbol: 'XAGUSD',
          change: '↘ 0.22%',
          isChangePositive: false,
          time: '14:35:22',
          sell: '31.420',
          buy: '31.450',
          buyColor: const Color(0xFFDC2626),
          onTap: () => _showQuickTradeDialog(
            context,
            symbol: 'XAGUSD',
            sellPrice: 31.42,
            buyPrice: 31.45,
          ),
        ),
      ];
    }

    if (_selectedTabIndex == 2) {
      // Energy
      return [
        _MarketQuoteRow(
          badge: const _USTECHBadge(),
          symbol: 'USOIL',
          change: '↗ 0.82%',
          isChangePositive: true,
          time: '14:35:10',
          sell: '70.24',
          buy: '70.28',
          sellColor: const Color(0xFF16A34A),
          buyColor: const Color(0xFF16A34A),
          onTap: () => _showQuickTradeDialog(
            context,
            symbol: 'USOIL',
            sellPrice: 70.24,
            buyPrice: 70.28,
          ),
        ),
        _MarketQuoteRow(
          badge: const _UKFlagBadge(),
          symbol: 'UKOIL',
          change: '↗ 0.74%',
          isChangePositive: true,
          time: '14:35:12',
          sell: '74.15',
          buy: '74.19',
          sellColor: const Color(0xFF16A34A),
          buyColor: const Color(0xFF16A34A),
          onTap: () => _showQuickTradeDialog(
            context,
            symbol: 'UKOIL',
            sellPrice: 74.15,
            buyPrice: 74.19,
          ),
        ),
      ];
    }

    // Default Favorites
    return [
      _MarketQuoteRow(
        badge: const _EUFlagBadge(),
        symbol: 'EURUSD',
        change: '↘ 0.10%',
        isChangePositive: false,
        time: '14:35:30',
        sell: '1.10090',
        buy: '1.10103',
        buyColor: const Color(0xFFDC2626),
        onTap: () => _showQuickTradeDialog(
          context,
          symbol: 'EURUSD',
          sellPrice: 1.10090,
          buyPrice: 1.10103,
        ),
      ),
      _MarketQuoteRow(
        badge: const _UKFlagBadge(),
        symbol: 'GBPUSD',
        change: '↘ 0.10%',
        isChangePositive: false,
        time: '14:35:31',
        sell: '1.31966',
        buy: '1.31979',
        sellColor: const Color(0xFF16A34A),
        buyColor: const Color(0xFF16A34A),
        onTap: () => _showQuickTradeDialog(
          context,
          symbol: 'GBPUSD',
          sellPrice: 1.31966,
          buyPrice: 1.31979,
        ),
      ),
      _MarketQuoteRow(
        badge: const _HKFlagBadge(),
        symbol: 'HK50c',
        change: '↗ 0.41%',
        isChangePositive: true,
        time: '14:35:30',
        sell: '23,815.24',
        buy: '23,828.94',
        sellColor: const Color(0xFF16A34A),
        buyColor: const Color(0xFF16A34A),
        onTap: () => _showQuickTradeDialog(
          context,
          symbol: 'HK50c',
          sellPrice: 23815.24,
          buyPrice: 23828.94,
        ),
      ),
      _MarketQuoteRow(
        badge: const _USTECHBadge(),
        symbol: 'USTECHc',
        change: '↘ 0.98%',
        isChangePositive: false,
        time: '14:35:26',
        sell: '27,535.38',
        buy: '27,538.16',
        sellColor: const Color(0xFF16A34A),
        buyColor: const Color(0xFF16A34A),
        onTap: () => _showQuickTradeDialog(
          context,
          symbol: 'USTECHc',
          sellPrice: 27535.38,
          buyPrice: 27538.16,
        ),
      ),
    ];
  }
}

class _MarketQuoteRow extends StatelessWidget {
  const _MarketQuoteRow({
    required this.badge,
    required this.symbol,
    required this.change,
    required this.isChangePositive,
    required this.time,
    required this.sell,
    required this.buy,
    this.sellColor,
    this.buyColor,
    required this.onTap,
  });

  final Widget badge;
  final String symbol;
  final String change;
  final bool isChangePositive;
  final String time;
  final String sell;
  final String buy;
  final Color? sellColor;
  final Color? buyColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final changeColor =
        isChangePositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _border,
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          children: [
            badge,
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        change,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: _brokerMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 82,
              child: Text(
                sell,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: sellColor ?? onSurface,
                ),
              ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: 82,
              child: Text(
                buy,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: buyColor ?? onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EUFlagBadge extends StatelessWidget {
  const _EUFlagBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF003399),
      ),
      child: const CustomPaint(
        painter: _EUFlagPainter(),
      ),
    );
  }
}

class _EUFlagPainter extends CustomPainter {
  const _EUFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final starRadius = size.width * 0.33;
    final starPaint = Paint()..color = const Color(0xFFFFCC00);

    for (int i = 0; i < 10; i++) {
      final angle = (i * 2 * 3.1415926535) / 10;
      final pos = Offset(
        center.dx + starRadius * math.cos(angle),
        center.dy + starRadius * math.sin(angle),
      );
      canvas.drawCircle(pos, 0.9, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UKFlagBadge extends StatelessWidget {
  const _UKFlagBadge();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 22,
        height: 22,
        color: const Color(0xFF012169),
        child: const CustomPaint(
          painter: _UKFlagPainter(),
        ),
      ),
    );
  }
}

class _UKFlagPainter extends CustomPainter {
  const _UKFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final whiteDiag = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.6;
    canvas.drawLine(Offset.zero, Offset(w, h), whiteDiag);
    canvas.drawLine(Offset(0, h), Offset(w, 0), whiteDiag);

    final redDiag = Paint()
      ..color = const Color(0xFFC8102E)
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset.zero, Offset(w, h), redDiag);
    canvas.drawLine(Offset(0, h), Offset(w, 0), redDiag);

    final whiteCross = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.6;
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), whiteCross);
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), whiteCross);

    final redCross = Paint()
      ..color = const Color(0xFFC8102E)
      ..strokeWidth = 2.6;
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), redCross);
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), redCross);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HKFlagBadge extends StatelessWidget {
  const _HKFlagBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFDE2910),
      ),
      child: const Center(
        child: Icon(
          LucideIcons.flower2,
          size: 13,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _USTECHBadge extends StatelessWidget {
  const _USTECHBadge();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF263750) : const Color(0xFFE2E8F0),
      ),
      child: Center(
        child: Text(
          'U',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }
}

void _showQuickTradeDialog(
  BuildContext context, {
  String symbol = 'EURUSD',
  double sellPrice = 1.10090,
  double buyPrice = 1.10103,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  double lotSize = 0.10;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF101D31) : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334B6E) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B2E4E) : const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Spread: ${((buyPrice - sellPrice) * 10000).toStringAsFixed(1)} pips',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D5AFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'VOLUME (LOTS)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [0.01, 0.05, 0.10, 0.50, 1.00].map((val) {
                  final active = (lotSize - val).abs() < 0.001;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          backgroundColor: active ? _brokerBlue : Colors.transparent,
                          foregroundColor: active
                              ? Colors.white
                              : Theme.of(ctx).colorScheme.onSurface,
                          side: BorderSide(
                            color: active
                                ? _brokerBlue
                                : (isDark
                                    ? const Color(0xFF334B6E)
                                    : const Color(0xFFCBD5E1)),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => setModalState(() => lotSize = val),
                        child: Text(
                          val.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Instant SELL ${lotSize.toStringAsFixed(2)} $symbol @ ${sellPrice.toStringAsFixed(5)} executed',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Text(
                            'SELL',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sellPrice.toStringAsFixed(5),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D5AFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Instant BUY ${lotSize.toStringAsFixed(2)} $symbol @ ${buyPrice.toStringAsFixed(5)} executed',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Text(
                            'BUY',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            buyPrice.toStringAsFixed(5),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class BrokerTransactionsPage extends StatefulWidget {
  const BrokerTransactionsPage({super.key});
  @override
  State<BrokerTransactionsPage> createState() => _BrokerTransactionsPageState();
}

class _BrokerTransactionsPageState extends State<BrokerTransactionsPage> {
  String _filter = 'All';
  static const _groups = <(String, List<_TransactionData>)>[
    (
      'Today',
      [
        _TransactionData(
          LucideIcons.arrowDownLeft,
          'Deposit',
          'Account Funding',
          '+\$2,500.00',
          '10:30 AM',
          true,
        ),
        _TransactionData(
          LucideIcons.arrowUpRight,
          'Withdrawal',
          'Payout Request',
          '-\$850.00',
          '11:15 AM',
          false,
        ),
      ],
    ),
    (
      'Yesterday',
      [
        _TransactionData(
          LucideIcons.arrowLeftRight,
          'Internal Transfer',
          'Between Accounts',
          '+\$500.00',
          '06:20 PM',
          true,
        ),
        _TransactionData(
          LucideIcons.plus,
          'Account Opening',
          'New Live Account',
          '\$0.00',
          '04:10 PM',
          null,
        ),
      ],
    ),
    (
      'This Month',
      [
        _TransactionData(
          LucideIcons.gift,
          'IB Commission',
          'Partnership Earnings',
          '+\$120.00',
          'Yesterday',
          true,
        ),
        _TransactionData(
          LucideIcons.layers,
          'MAM Allocation',
          'Fund Allocation',
          '\$0.00',
          'Yesterday',
          null,
        ),
      ],
    ),
  ];

  bool _matches(_TransactionData item) => switch (_filter) {
    'Deposits' => item.title == 'Deposit',
    'Withdrawals' => item.title == 'Withdrawal',
    'Transfers' => item.title == 'Internal Transfer',
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Deposits', 'Withdrawals', 'Transfers'];
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width > 900 ? 860 : 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3E8F0)),
                ),
                child: Row(
                  children: [
                    for (final filter in filters)
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _filter = filter),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _filter == filter
                                  ? const Color(0xFF10284F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              filter,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _filter == filter
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE3E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRANSACTION ACTIVITY',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 9,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Your account movements',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2C8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.arrowDownUp,
                        color: Color(0xFF9A7000),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              for (final group in _groups) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      group.$1,
                      style: const TextStyle(
                        color: Color(0xFF10213E),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _TransactionGroup(items: group.$2.where(_matches).toList()),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionData {
  const _TransactionData(
    this.icon,
    this.title,
    this.detail,
    this.amount,
    this.time,
    this.incoming,
  );
  final IconData icon;
  final String title, detail, amount, time;
  final bool? incoming;
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({required this.items});
  final List<_TransactionData> items;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E7EF)),
    ),
    child: Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Divider(height: 1, indent: 14, endIndent: 14, color: Theme.of(context).dividerColor),
          _TransactionTile(data: items[i]),
        ],
      ],
    ),
  );
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data});
  final _TransactionData data;
  @override
  Widget build(BuildContext context) {
    final color = data.incoming == null
        ? const Color(0xFF10213E)
        : data.incoming!
        ? _brokerGold
        : _brokerBlue;
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: data.incoming == false
              ? const Color(0xFFF7F1E2)
              : const Color(0xFFEAF0F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          data.icon,
          color: data.incoming == false
              ? _brokerBlue
              : _brokerBlue,
          size: 19,
        ),
      ),
      title: Text(
        data.title,
        style: const TextStyle(
          color: Color(0xFF10213E),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        data.detail,
        style: const TextStyle(color: Color(0xFF7A8799), fontSize: 10),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            data.amount,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.time,
            style: const TextStyle(color: Color(0xFF8C97A7), fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class BrokerBottomNavigation extends StatelessWidget {
  const BrokerBottomNavigation({
    super.key,
    required this.selectedPage,
    required this.onSelect,
  });
  final String selectedPage;
  final ValueChanged<String> onSelect;

  void _showQuickActions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2E8F1), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A10264B),
                blurRadius: 28,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6DFEB),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33389BFF),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Quick actions',
                style: TextStyle(
                  color: Color(0xFF10264B),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              _QuickActionRow(
                icon: LucideIcons.wallet,
                title: 'Deposit funds',
                subtitle: 'Add money to your account',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Deposit');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.arrowUpRight,
                title: 'Withdraw funds',
                subtitle: 'Transfer funds to your bank',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Withdraw');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.userRoundPlus,
                title: 'Open live account',
                subtitle: 'Start trading with real capital',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Open Account');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.arrowLeftRight,
                title: 'Internal transfer',
                subtitle: 'Move balance between accounts',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Internal Transfer');
                },
              ),
              _QuickActionRow(
                icon: LucideIcons.monitor,
                title: 'Create demo account',
                subtitle: 'Practice strategies risk-free',
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSelect('Demo Accounts');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 7),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              margin: const EdgeInsets.fromLTRB(18, 2, 18, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: isDark ? 0.35 : 0.10,
                    ),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xEA0E1A2E)
                          : const Color(0xEAFFFFFF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x33475569)
                            : const Color(0x66CBD5E1),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _BrokerNavItem(
                          icon: LucideIcons.house,
                          label: 'Home',
                          selected: selectedPage == 'Dashboard',
                          onTap: () => onSelect('Dashboard'),
                        ),
                        _BrokerNavItem(
                          icon: LucideIcons.receiptText,
                          label: 'Activity',
                          selected: selectedPage == 'Transactions',
                          onTap: () => onSelect('Transactions'),
                        ),
                        SizedBox(
                          width: 62,
                          height: 54,
                          child: Center(
                            child: Transform.translate(
                              offset: const Offset(0, -9),
                              child: _CenterQuickActionButton(
                                onTap: () => _showQuickActions(context),
                              ),
                            ),
                          ),
                        ),
                        _BrokerNavItem(
                          icon: LucideIcons.layers,
                          label: 'Accounts',
                          selected: selectedPage == 'Trading Accounts',
                          onTap: () => onSelect('Trading Accounts'),
                        ),
                        _BrokerNavItem(
                          icon: LucideIcons.grid2x2,
                          label: 'More',
                          selected: selectedPage == 'More',
                          onTap: () => onSelect('More'),
                        ),
                      ],
                    ),
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

class _CenterQuickActionButton extends StatefulWidget {
  const _CenterQuickActionButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CenterQuickActionButton> createState() => _CenterQuickActionButtonState();
}

class _CenterQuickActionButtonState extends State<_CenterQuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onTap();
          },
          child: AnimatedScale(
            scale: _isPressed ? .93 : 1,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _brokerNavy,
                shape: BoxShape.circle,
                border: Border.all(color: _brokerGold, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2610244B),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(LucideIcons.plus, color: _brokerGold, size: 25),
              ),
            ),
          ),
        ),
      );
}

class _QuickActionRow extends StatefulWidget {
  const _QuickActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  State<_QuickActionRow> createState() => _QuickActionRowState();
}

class _QuickActionRowState extends State<_QuickActionRow> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isPressed || _isHovered;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFF2F6FC)
                  : const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFB9CEE9)
                    : const Color(0xFFE7EDF5),
                width: 1,
              ),
              boxShadow: isActive
                  ? const [
                      BoxShadow(
                        color: Color(0x220875F5),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isActive
                          ? const [Color(0x44389BFF), Color(0x280875F5)]
                          : const [Color(0x260875F5), Color(0x1A0875F5)],
                    ),
                    border: Border.all(
                      color: isActive
                          ? const Color(0x665CABFF)
                          : const Color(0x334B96FF),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: isActive
                          ? const Color(0xFF174A8B)
                          : const Color(0xFF5279A9),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Color(0xFF10264B),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: const TextStyle(
                            color: Color(0xFF71809A),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedSlide(
                  offset: isActive ? const Offset(0.08, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    LucideIcons.chevronRight,
                    color: isActive
                        ? const Color(0xFF174A8B)
                        : const Color(0xFF9AA9BC),
                    size: 18,
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

class _BrokerNavItem extends StatelessWidget {
  const _BrokerNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFFFFD166) : _brokerBlue;
    // Keep the selected item visually clear without a filled background.
    const activeBackground = Colors.transparent;
    const activeBorder = Colors.transparent;
    final inactiveColor = isDark
        ? const Color(0xFFB7C4D8)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      child: RepaintBoundary(
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: Tooltip(
            message: label,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: _brokerGold.withValues(alpha: .16),
              highlightColor: activeColor.withValues(alpha: .08),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                constraints: const BoxConstraints(minHeight: 54),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                decoration: BoxDecoration(
                  color: selected ? activeBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selected ? activeBorder : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedScale(
                      scale: selected ? 1.08 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        icon,
                        color: selected ? activeColor : inactiveColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? activeColor : inactiveColor,
                        fontSize: 9.5,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 17 : 4,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: selected ? _brokerGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
