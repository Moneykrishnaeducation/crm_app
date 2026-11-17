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
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
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
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TradeReportPage(),
                  ),
                );
              },
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
                      Text(
                        'EURUSD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  Text(
                    'Invite one friend',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                Text(
                  'Stay informed with the latest market news and insights.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                            : Theme.of(context).colorScheme.onSurfaceVariant,
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
            children: [
              Text(
                'Product / Change',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        Center(
          child: Text(
            'No more data',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class ActivityOpenPosition {
  const ActivityOpenPosition({
    required this.id,
    required this.symbol,
    required this.isBuy,
    required this.lots,
    required this.openPrice,
    required this.currentPrice,
    required this.profit,
    required this.sl,
    required this.tp,
    required this.openTime,
  });

  final String id;
  final String symbol;
  final bool isBuy;
  final double lots;
  final double openPrice;
  final double currentPrice;
  final double profit;
  final double sl;
  final double tp;
  final String openTime;

  ActivityOpenPosition copyWith({
    String? id,
    String? symbol,
    bool? isBuy,
    double? lots,
    double? openPrice,
    double? currentPrice,
    double? profit,
    double? sl,
    double? tp,
    String? openTime,
  }) {
    return ActivityOpenPosition(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      isBuy: isBuy ?? this.isBuy,
      lots: lots ?? this.lots,
      openPrice: openPrice ?? this.openPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      profit: profit ?? this.profit,
      sl: sl ?? this.sl,
      tp: tp ?? this.tp,
      openTime: openTime ?? this.openTime,
    );
  }
}

class ActivityPendingOrder {
  const ActivityPendingOrder({
    required this.id,
    required this.symbol,
    required this.orderType,
    required this.lots,
    required this.orderPrice,
    required this.currentPrice,
    required this.placedTime,
  });

  final String id;
  final String symbol;
  final String orderType;
  final double lots;
  final double orderPrice;
  final double currentPrice;
  final String placedTime;
}

class ActivityClosedPosition {
  const ActivityClosedPosition({
    required this.id,
    required this.symbol,
    required this.isBuy,
    required this.lots,
    required this.openPrice,
    required this.closePrice,
    required this.netProfit,
    required this.closeTime,
  });

  final String id;
  final String symbol;
  final bool isBuy;
  final double lots;
  final double openPrice;
  final double closePrice;
  final double netProfit;
  final String closeTime;
}

class ActivityFundTransaction {
  const ActivityFundTransaction({
    required this.id,
    required this.isDeposit,
    required this.method,
    required this.amount,
    required this.date,
    required this.status,
  });

  final String id;
  final bool isDeposit;
  final String method;
  final double amount;
  final String date;
  final String status;
}

class BrokerTransactionsPage extends StatefulWidget {
  const BrokerTransactionsPage({
    super.key,
    this.accounts,
    this.selectedAccountLogin,
    this.onAccountChanged,
  });

  final List<BrokerAccount>? accounts;
  final String? selectedAccountLogin;
  final ValueChanged<String>? onAccountChanged;

  @override
  State<BrokerTransactionsPage> createState() => _BrokerTransactionsPageState();
}

class _BrokerTransactionsPageState extends State<BrokerTransactionsPage> {
  late String _selectedLogin;
  bool _hideEquity = false;
  int _activeTab = 0; // 0: Open, 1: Pending, 2: Closed, 3: Funds
  String _fundsFilter = 'All'; // 'All', 'Deposits', 'Withdrawals'

  late final Map<String, List<ActivityOpenPosition>> _accountOpenPositions;
  late final Map<String, List<ActivityPendingOrder>> _accountPendingOrders;
  late final Map<String, List<ActivityClosedPosition>> _accountClosedPositions;
  late final Map<String, List<ActivityFundTransaction>> _accountFunds;
  late final Map<String, double> _accountBalances;

  @override
  void initState() {
    super.initState();
    _selectedLogin = widget.selectedAccountLogin ?? '52132132';

    _accountOpenPositions = {
      '52132132': [
        const ActivityOpenPosition(
          id: 'pos-101',
          symbol: 'EURUSD',
          isBuy: true,
          lots: 0.50,
          openPrice: 1.08500,
          currentPrice: 1.08820,
          profit: 160.00,
          sl: 1.08100,
          tp: 1.09200,
          openTime: '2026-11-17 09:15',
        ),
        const ActivityOpenPosition(
          id: 'pos-102',
          symbol: 'XAUUSD',
          isBuy: false,
          lots: 0.20,
          openPrice: 2635.40,
          currentPrice: 2635.89,
          profit: -9.80,
          sl: 2642.00,
          tp: 2620.00,
          openTime: '2026-11-17 10:02',
        ),
      ],
      '3315': [],
      '3311': [
        const ActivityOpenPosition(
          id: 'pos-201',
          symbol: 'USDJPY',
          isBuy: true,
          lots: 0.30,
          openPrice: 154.20,
          currentPrice: 154.55,
          profit: 85.50,
          sl: 153.80,
          tp: 155.00,
          openTime: '2026-11-17 10:11',
        ),
      ],
      '3312': [],
      '3327': [],
    };

    _accountPendingOrders = {
      '52132132': [
        const ActivityPendingOrder(
          id: 'ord-101',
          symbol: 'GBPUSD',
          orderType: 'Buy Limit',
          lots: 0.10,
          orderPrice: 1.29400,
          currentPrice: 1.29850,
          placedTime: '2026-11-17 08:30',
        ),
      ],
      '3315': [],
      '3311': [],
      '3312': [],
      '3327': [],
    };

    _accountClosedPositions = {
      '52132132': [
        const ActivityClosedPosition(
          id: 'cls-101',
          symbol: 'BTCUSD',
          isBuy: true,
          lots: 0.05,
          openPrice: 89200.00,
          closePrice: 91450.00,
          netProfit: 112.50,
          closeTime: '2026-11-16 19:40',
        ),
        const ActivityClosedPosition(
          id: 'cls-102',
          symbol: 'HK50c',
          isBuy: false,
          lots: 1.00,
          openPrice: 19850.00,
          closePrice: 19910.00,
          netProfit: -60.00,
          closeTime: '2026-11-16 15:10',
        ),
      ],
      '3315': [],
      '3311': [
        const ActivityClosedPosition(
          id: 'cls-201',
          symbol: 'EURUSD',
          isBuy: false,
          lots: 0.20,
          openPrice: 1.0880,
          closePrice: 1.0840,
          netProfit: 80.00,
          closeTime: '2026-11-16 16:22',
        ),
      ],
      '3312': [],
      '3327': [],
    };

    _accountFunds = {
      '52132132': [
        const ActivityFundTransaction(
          id: 'tx-101',
          isDeposit: true,
          method: 'Bank Transfer',
          amount: 5000.00,
          date: '2026-11-16 14:20',
          status: 'Completed',
        ),
        const ActivityFundTransaction(
          id: 'tx-102',
          isDeposit: false,
          method: 'USDT TRC20',
          amount: 1200.00,
          date: '2026-11-15 11:35',
          status: 'Completed',
        ),
        const ActivityFundTransaction(
          id: 'tx-103',
          isDeposit: true,
          method: 'Cheese Pay',
          amount: 2500.00,
          date: '2026-11-14 09:10',
          status: 'Completed',
        ),
      ],
      '3315': [],
      '3311': [
        const ActivityFundTransaction(
          id: 'tx-201',
          isDeposit: true,
          method: 'USDT TRC20',
          amount: 4820.00,
          date: '2026-11-15 14:00',
          status: 'Completed',
        ),
      ],
      '3312': [],
      '3327': [],
    };

    _accountBalances = {
      '52132132': 12300.00,
      '3315': 0.00,
      '3311': 4820.00,
      '3312': 1100.00,
      '3327': 0.00,
    };
  }

  @override
  void didUpdateWidget(covariant BrokerTransactionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAccountLogin != null &&
        widget.selectedAccountLogin != _selectedLogin) {
      setState(() => _selectedLogin = widget.selectedAccountLogin!);
    }
  }

  List<BrokerAccount> get _allAccounts {
    final list = <BrokerAccount>[];
    if (widget.accounts != null && widget.accounts!.isNotEmpty) {
      list.addAll(widget.accounts!);
    }
    final logins = list.map((a) => a.login).toSet();
    if (!logins.contains('52132132')) {
      list.insert(
        0,
        const BrokerAccount(
          'V Tamizharasan',
          '52132132',
          '1:500',
          '\$12,300.00',
          '\$12,450.00',
          'Live MT5',
        ),
      );
    }
    if (!logins.contains('3315')) {
      list.add(
        const BrokerAccount(
          'XRSIM-USD-1',
          '3315',
          '1:500',
          '\$0.00',
          '\$0.00',
          'Live MT5',
        ),
      );
    }
    return list;
  }

  BrokerAccount get _currentAccount {
    final accounts = _allAccounts;
    return accounts.firstWhere(
      (a) => a.login == _selectedLogin,
      orElse: () => accounts.first,
    );
  }

  List<ActivityOpenPosition> get _currentOpenPositions =>
      _accountOpenPositions[_selectedLogin] ?? [];

  List<ActivityPendingOrder> get _currentPendingOrders =>
      _accountPendingOrders[_selectedLogin] ?? [];

  List<ActivityClosedPosition> get _currentClosedPositions =>
      _accountClosedPositions[_selectedLogin] ?? [];

  List<ActivityFundTransaction> get _currentFunds =>
      _accountFunds[_selectedLogin] ?? [];

  double get _currentBalance => _accountBalances[_selectedLogin] ?? 0.0;

  double get _currentTotalPL =>
      _currentOpenPositions.fold(0.0, (sum, p) => sum + p.profit);

  double get _currentEquity => _currentBalance + _currentTotalPL;

  void _selectAccount(String login) {
    setState(() => _selectedLogin = login);
    widget.onAccountChanged?.call(login);
  }

  void _closePosition(ActivityOpenPosition position) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Close Position',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to close ${position.symbol} (${position.lots.toStringAsFixed(2)} Lots) at market price ${position.currentPrice}?\n\nRealized P&L: ${position.profit >= 0 ? '+' : '-'}\$${position.profit.abs().toStringAsFixed(2)} USD',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1658C9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _accountOpenPositions[_selectedLogin]?.removeWhere((p) => p.id == position.id);
                _accountClosedPositions[_selectedLogin]?.insert(
                  0,
                  ActivityClosedPosition(
                    id: 'cls-${DateTime.now().millisecondsSinceEpoch}',
                    symbol: position.symbol,
                    isBuy: position.isBuy,
                    lots: position.lots,
                    openPrice: position.openPrice,
                    closePrice: position.currentPrice,
                    netProfit: position.profit,
                    closeTime: 'Just now',
                  ),
                );
                _accountBalances[_selectedLogin] =
                    (_accountBalances[_selectedLogin] ?? 0.0) + position.profit;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Position ${position.symbol} closed successfully'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10264B),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Confirm Close'),
          ),
        ],
      ),
    );
  }

  void _cancelPendingOrder(ActivityPendingOrder order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Cancel Pending Order',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel ${order.orderType} order for ${order.symbol} (${order.lots.toStringAsFixed(2)} Lots)?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep Order',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _accountPendingOrders[_selectedLogin]?.removeWhere((o) => o.id == order.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pending order for ${order.symbol} cancelled'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF10264B),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  void _openAccountSwitchSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accounts = _allAccounts;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF131D2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Trading Account',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final acc in accounts) ...[
                InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _selectAccount(acc.login);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: acc.login == _selectedLogin
                          ? const Color(0xFF1658C9).withValues(alpha: 0.08)
                          : (isDark ? const Color(0xFF1A283E) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: acc.login == _selectedLogin
                            ? const Color(0xFF1658C9)
                            : (isDark ? const Color(0xFF283B58) : const Color(0xFFE2E9F3)),
                        width: acc.login == _selectedLogin ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: acc.login == _selectedLogin
                                ? const Color(0xFF1658C9)
                                : (isDark ? const Color(0xFF243650) : const Color(0xFFE5EDF7)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            LucideIcons.wallet,
                            color: acc.login == _selectedLogin
                                ? Colors.white
                                : const Color(0xFF1658C9),
                            size: 18,
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
                                    acc.name,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      acc.type,
                                      style: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Login: ${acc.login} • Lev: ${acc.leverage}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              acc.balance,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (acc.login == _selectedLogin)
                              const Icon(
                                LucideIcons.checkCircle2,
                                color: Color(0xFF1658C9),
                                size: 16,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openTradeReportModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final closed = _currentClosedPositions;
    final totalTrades = closed.length;
    final winTrades = closed.where((c) => c.netProfit > 0).length;
    final winRate = totalTrades == 0 ? 0.0 : (winTrades / totalTrades) * 100.0;
    final totalNet = closed.fold(0.0, (sum, c) => sum + c.netProfit);
    final totalVolume = closed.fold(0.0, (sum, c) => sum + c.lots);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF131D2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trade Performance Report',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Account: $_selectedLogin • Live MT5',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    'Total Net Profit',
                    '${totalNet >= 0 ? '+' : '-'}\$${totalNet.abs().toStringAsFixed(2)}',
                    totalNet >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    'Win Rate',
                    '${winRate.toStringAsFixed(1)}%',
                    const Color(0xFF1658C9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    context,
                    'Total Trades',
                    '$totalTrades',
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    context,
                    'Total Volume',
                    '${totalVolume.toStringAsFixed(2)} Lots',
                    Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1658C9),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close Report', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, String value, Color valueColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2B42) : const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF283B58) : const Color(0xFFE2E9F3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    BrokerAccount activeAccount,
    double equity,
    double balance,
    double totalPL,
  ) {
    final equityText = _hideEquity
        ? '•••••••• USD'
        : '${equity.toStringAsFixed(2)} USD';
    final balanceText = _hideEquity
        ? '••••••'
        : balance.toStringAsFixed(2);
    final plText = _hideEquity
        ? '••••••'
        : (totalPL == 0.0
            ? '0.00'
            : '${totalPL > 0 ? '+' : ''}${totalPL.toStringAsFixed(2)}');
    final plColor = totalPL > 0
        ? const Color(0xFF22C55E)
        : (totalPL < 0 ? const Color(0xFFEF4444) : Colors.white);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF071941),
            Color(0xFF0C2B68),
            Color(0xFF144EA5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C2B68).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2D72E2).withValues(alpha: 0.38),
                      const Color(0xFF144EA5).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: InkWell(
                          onTap: () => _openAccountSwitchSheet(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x6610B981),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    activeAccount.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Live | ${activeAccount.login}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.chevronDown,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TradeReportPage(
                                accounts: _allAccounts,
                                selectedAccountLogin: _selectedLogin,
                                onAccountChanged: _selectAccount,
                              ),
                            ),
                          );
                        },
                        onLongPress: () => _openTradeReportModal(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Trade Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                LucideIcons.chevronRight,
                                color: Colors.white,
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Equity',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _hideEquity = !_hideEquity),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            _hideEquity ? LucideIcons.eyeOff : LucideIcons.eye,
                            color: Colors.white.withValues(alpha: 0.75),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    equityText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Position Total P&L',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              plText,
                              style: TextStyle(
                                color: plColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              balanceText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
  }

  Widget _buildTabBar(BuildContext context, int openCount, int pendingCount) {
    final tabs = [
      'Open $openCount',
      'Pending $pendingCount',
      'Closed',
      'Funds',
    ];

    return Container(
      margin: const EdgeInsets.only(top: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _activeTab = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        tabs[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _activeTab == i
                              ? const Color(0xFF1658C9)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: _activeTab == i
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 2.5,
                      width: _activeTab == i ? 36 : 0,
                      decoration: BoxDecoration(
                        color: _activeTab == i
                            ? const Color(0xFF1658C9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 52, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 200,
            height: 180,
            child: CustomPaint(
              painter: _EmptyBoxPlanePainter(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Data',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenPositionsList(BuildContext context, bool isDark) {
    final positions = _currentOpenPositions;
    if (positions.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final pos = positions[index];
        final isProfit = pos.profit >= 0;
        final profitColor = isProfit ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162238) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF223452) : const Color(0xFFE2E7EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                    children: [
                      Text(
                        pos.symbol,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: pos.isBuy
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pos.isBuy ? 'BUY' : 'SELL',
                          style: TextStyle(
                            color: pos.isBuy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${pos.lots.toStringAsFixed(2)} Lots',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: profitColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isProfit ? '+' : '-'}\$${pos.profit.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: profitColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open Price',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${pos.openPrice}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Price',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${pos.currentPrice}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SL / TP',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${pos.sl} / ${pos.tp}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Opened: ${pos.openTime}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                  InkWell(
                    onTap: () => _closePosition(pos),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingOrdersList(BuildContext context, bool isDark) {
    final orders = _currentPendingOrders;
    if (orders.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isBuy = order.orderType.toLowerCase().contains('buy');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162238) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF223452) : const Color(0xFFE2E7EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                    children: [
                      Text(
                        order.symbol,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isBuy
                              ? const Color(0xFF1658C9).withValues(alpha: 0.15)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.orderType.toUpperCase(),
                          style: TextStyle(
                            color: isBuy ? const Color(0xFF1658C9) : const Color(0xFFD97706),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${order.lots.toStringAsFixed(2)} Lots',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Price',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.orderPrice}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Price',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.currentPrice}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Placed Time',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order.placedTime,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _cancelPendingOrder(order),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClosedPositionsList(BuildContext context, bool isDark) {
    final positions = _currentClosedPositions;
    if (positions.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final pos = positions[index];
        final isProfit = pos.netProfit >= 0;
        final profitColor = isProfit ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162238) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF223452) : const Color(0xFFE2E7EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
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
                    children: [
                      Text(
                        pos.symbol,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: pos.isBuy
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pos.isBuy ? 'BUY' : 'SELL',
                          style: TextStyle(
                            color: pos.isBuy ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${pos.lots.toStringAsFixed(2)} Lots',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: profitColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isProfit ? '+' : '-'}\$${pos.netProfit.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: profitColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Open Price',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${pos.openPrice}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Close Price',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${pos.closePrice}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Closed Time',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pos.closeTime,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFundsTab(BuildContext context, bool isDark) {
    final allFunds = _currentFunds;
    final filteredFunds = switch (_fundsFilter) {
      'Deposits' => allFunds.where((f) => f.isDeposit).toList(),
      'Withdrawals' => allFunds.where((f) => !f.isDeposit).toList(),
      _ => allFunds,
    };

    final filterOptions = ['All', 'Deposits', 'Withdrawals'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162238) : const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                for (final filter in filterOptions)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _fundsFilter = filter),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _fundsFilter == filter
                              ? const Color(0xFF1658C9)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          filter,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _fundsFilter == filter
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (filteredFunds.isEmpty)
          _buildEmptyState(context)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
            itemCount: filteredFunds.length,
            itemBuilder: (context, index) {
              final tx = filteredFunds[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162238) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF223452) : const Color(0xFFE2E7EF),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tx.isDeposit
                            ? const Color(0xFF10B981).withValues(alpha: 0.12)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tx.isDeposit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                        color: tx.isDeposit ? const Color(0xFF10B981) : const Color(0xFFD97706),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.isDeposit ? 'Deposit' : 'Withdrawal',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${tx.method} • ${tx.date}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${tx.isDeposit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: tx.isDeposit
                                ? const Color(0xFF16A34A)
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tx.status,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAccount = _currentAccount;
    final openCount = _currentOpenPositions.length;
    final pendingCount = _currentPendingOrders.length;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width > 900 ? 860 : 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 110),
            children: [
              // Accessible title tag for widget tests
              const SizedBox(
                width: 0,
                height: 0,
                child: Text(
                  'Transactions',
                  style: TextStyle(fontSize: 0, color: Colors.transparent),
                ),
              ),
              // Hero Equity & Balance Card
              _buildHeroCard(
                context,
                activeAccount,
                _currentEquity,
                _currentBalance,
                _currentTotalPL,
              ),
              // 4-Tab Navigation Bar
              _buildTabBar(context, openCount, pendingCount),
              // Tab Content Area
              switch (_activeTab) {
                0 => _buildOpenPositionsList(context, isDark),
                1 => _buildPendingOrdersList(context, isDark),
                2 => _buildClosedPositionsList(context, isDark),
                3 => _buildFundsTab(context, isDark),
                _ => _buildEmptyState(context),
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBoxPlanePainter extends CustomPainter {
  const _EmptyBoxPlanePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.48;
    final cy = size.height * 0.64;

    const strokeColor = Color(0xFFC5D6EC);
    const boxLeftFace = Color(0xFFDBE7F6);
    const boxRightFace = Color(0xFFC8DCF2);
    const boxInsideFloor = Color(0xFFA7C2E5);
    const flapColor = Color(0xFFE6EFFB);
    const airplaneBody = Colors.white;
    const airplaneWing = Color(0xFFD6E4F8);
    const airplaneCrease = Color(0xFF9CB8DD);
    const trailDotColor = Color(0xFFB5CDF0);
    const sparkleColor = Color(0xFFC7DDF8);
    const leafColor = Color(0xFFA4C2E9);

    final linePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Floor & inside cavity
    final floorPath = Path()
      ..moveTo(cx - 36, cy - 24)
      ..lineTo(cx, cy - 10)
      ..lineTo(cx + 36, cy - 24)
      ..lineTo(cx, cy - 38)
      ..close();
    canvas.drawPath(floorPath, Paint()..color = boxInsideFloor);
    canvas.drawPath(floorPath, linePaint);

    // Flaps
    final backLeftFlap = Path()
      ..moveTo(cx - 36, cy - 24)
      ..lineTo(cx - 48, cy - 36)
      ..lineTo(cx - 20, cy - 44)
      ..lineTo(cx, cy - 38)
      ..close();
    canvas.drawPath(backLeftFlap, Paint()..color = flapColor);
    canvas.drawPath(backLeftFlap, linePaint);

    final backRightFlap = Path()
      ..moveTo(cx, cy - 38)
      ..lineTo(cx + 20, cy - 44)
      ..lineTo(cx + 48, cy - 36)
      ..lineTo(cx + 36, cy - 24)
      ..close();
    canvas.drawPath(backRightFlap, Paint()..color = flapColor);
    canvas.drawPath(backRightFlap, linePaint);

    final frontLeftFlap = Path()
      ..moveTo(cx - 36, cy - 24)
      ..lineTo(cx - 52, cy - 16)
      ..lineTo(cx - 24, cy - 2)
      ..lineTo(cx, cy - 10)
      ..close();
    canvas.drawPath(frontLeftFlap, Paint()..color = flapColor);
    canvas.drawPath(frontLeftFlap, linePaint);

    final frontRightFlap = Path()
      ..moveTo(cx, cy - 10)
      ..lineTo(cx + 24, cy - 2)
      ..lineTo(cx + 52, cy - 16)
      ..lineTo(cx + 36, cy - 24)
      ..close();
    canvas.drawPath(frontRightFlap, Paint()..color = flapColor);
    canvas.drawPath(frontRightFlap, linePaint);

    // Front Faces
    final leftFace = Path()
      ..moveTo(cx, cy + 24)
      ..lineTo(cx - 36, cy + 10)
      ..lineTo(cx - 36, cy - 24)
      ..lineTo(cx, cy - 10)
      ..close();
    canvas.drawPath(leftFace, Paint()..color = boxLeftFace);
    canvas.drawPath(leftFace, linePaint);

    final rightFace = Path()
      ..moveTo(cx, cy + 24)
      ..lineTo(cx + 36, cy + 10)
      ..lineTo(cx + 36, cy - 24)
      ..lineTo(cx, cy - 10)
      ..close();
    canvas.drawPath(rightFace, Paint()..color = boxRightFace);
    canvas.drawPath(rightFace, linePaint);

    // Sprout Leaves
    final leafPaint = Paint()..color = leafColor;
    final leaf1 = Path()
      ..moveTo(cx + 43, cy + 17)
      ..quadraticBezierTo(cx + 53, cy + 10, cx + 58, cy + 13)
      ..quadraticBezierTo(cx + 51, cy + 21, cx + 43, cy + 17);
    canvas.drawPath(leaf1, leafPaint);

    final leaf2 = Path()
      ..moveTo(cx + 46, cy + 19)
      ..quadraticBezierTo(cx + 54, cy + 24, cx + 57, cy + 21)
      ..quadraticBezierTo(cx + 50, cy + 16, cx + 46, cy + 19);
    canvas.drawPath(leaf2, leafPaint);

    // Flight Dotted Trail
    final trailDots = <Offset>[
      Offset(cx - 2, cy - 24),
      Offset(cx - 5, cy - 36),
      Offset(cx - 7, cy - 50),
      Offset(cx - 4, cy - 64),
      Offset(cx + 3, cy - 78),
      Offset(cx + 14, cy - 90),
      Offset(cx + 28, cy - 98),
      Offset(cx + 42, cy - 102),
    ];
    final dotPaint = Paint()..color = trailDotColor;
    for (final dot in trailDots) {
      canvas.drawCircle(dot, 1.6, dotPaint);
    }

    // Paper Airplane
    final planeNose = Offset(cx + 68, cy - 118);
    final planeLeftWing = Offset(cx + 38, cy - 106);
    final planeTailCenter = Offset(cx + 46, cy - 98);
    final planeRightWing = Offset(cx + 54, cy - 92);

    final leftWingPath = Path()
      ..moveTo(planeNose.dx, planeNose.dy)
      ..lineTo(planeLeftWing.dx, planeLeftWing.dy)
      ..lineTo(planeTailCenter.dx, planeTailCenter.dy)
      ..close();
    canvas.drawPath(leftWingPath, Paint()..color = airplaneWing);
    canvas.drawPath(
      leftWingPath,
      Paint()
        ..color = airplaneCrease
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    final rightWingPath = Path()
      ..moveTo(planeNose.dx, planeNose.dy)
      ..lineTo(planeTailCenter.dx, planeTailCenter.dy)
      ..lineTo(planeRightWing.dx, planeRightWing.dy)
      ..close();
    canvas.drawPath(rightWingPath, Paint()..color = airplaneBody);
    canvas.drawPath(
      rightWingPath,
      Paint()
        ..color = airplaneCrease
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Sparkles
    _drawSparkle(canvas, Offset(cx - 40, cy - 65), 5.5, sparkleColor);
    _drawSparkle(canvas, Offset(cx - 15, cy - 78), 3.5, sparkleColor);
    _drawSparkle(canvas, Offset(cx + 60, cy - 70), 3.0, sparkleColor);
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final scheme = Theme.of(context).colorScheme;
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
            color: scheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
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
                    color: Theme.of(context).dividerColor,
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
              Text(
                'Quick actions',
                style: TextStyle(
                  color: scheme.onSurface,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
                  ? (isDark ? const Color(0xFF223656) : const Color(0xFFF2F6FC))
                  : (isDark ? const Color(0xFF1A283E) : const Color(0xFFF8FAFD)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334B6E)
                    : (isActive ? const Color(0xFFB9CEE9) : const Color(0xFFE7EDF5)),
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
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
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
                        : scheme.onSurfaceVariant,
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


// -----------------------------------------------------------------------------
// MAM MANAGER — mobile-first manager workspace.
// UI state is local/demo data until the MAM APIs are connected.
// -----------------------------------------------------------------------------
class BrokerMamManagerPage extends StatefulWidget {
  const BrokerMamManagerPage({super.key});

  @override
  State<BrokerMamManagerPage> createState() => _BrokerMamManagerPageState();
}

class _BrokerMamManagerPageState extends State<BrokerMamManagerPage> {
  String _filter = 'All Masters';
  String _search = '';
  bool _showGuide = false;
  final _searchController = TextEditingController();
  final List<_MamMaster> _masters = [
    _MamMaster(
      name: 'Devo-Testmam',
      login: '2141715173',
      profitShare: 40,
      leverage: '1:500',
      balance: 0,
      status: 'Disabled',
      risk: 'Medium',
      payout: 'Weekly',
    ),
  ];

  int get _activeCount => _masters.where((m) => m.status == 'Active').length;
  int get _disabledCount => _masters.where((m) => m.status == 'Disabled').length;
  List<_MamMaster> get _visibleMasters => _masters.where((m) {
    final statusMatch = _filter == 'All Masters' || m.status == _filter;
    final q = _search.trim().toLowerCase();
    return statusMatch && (q.isEmpty || m.name.toLowerCase().contains(q) || m.login.contains(q));
  }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Theme.of(context).dividerColor),
    boxShadow: const [BoxShadow(color: Color(0x080F2748), blurRadius: 12, offset: Offset(0, 4))],
  );

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
            children: [
              _buildSocialTradingHeader(),
              const SizedBox(height: 14),
              SizedBox(
                // The summary card content needs more vertical room on compact
                // screens to avoid a RenderFlex overflow.
                height: 156,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    SizedBox(width: 176, child: _buildSummaryCard(
                      title: 'TOTAL BALANCE', value: '\$0.00', suffix: 'USD',
                      caption: 'Master capital', icon: LucideIcons.wallet,
                      tint: dark ? const Color(0xFF1E2E48) : const Color(0xFFEAF2FF), accent: const Color(0xFF2563EB),
                    )),
                    const SizedBox(width: 10),
                    SizedBox(width: 176, child: _buildSummaryCard(
                      title: 'ACTIVE NODES', value: '$_activeCount', suffix: 'Live',
                      caption: 'Currently active', icon: LucideIcons.activity,
                      tint: dark ? const Color(0xFF132D28) : const Color(0xFFE9FBF4), accent: const Color(0xFF059669),
                    )),
                    const SizedBox(width: 10),
                    SizedBox(width: 176, child: _buildSummaryCard(
                      title: 'MASTER NODES', value: '${_masters.length}', suffix: 'MAM',
                      caption: 'Total accounts', icon: LucideIcons.usersRound,
                      tint: dark ? const Color(0xFF2D2619) : const Color(0xFFFFF7E6), accent: const Color(0xFFB7791F),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_showGuide) ...[
                _buildGuideCard(),
                const SizedBox(height: 16),
              ],
              _buildMasterList(dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialTradingHeader() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]), borderRadius: BorderRadius.circular(13)),
          child: const Icon(LucideIcons.usersRound, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Social Trading', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('Manage MAM accounts and investments.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10.5)),
        ])),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _headerAction('Create MAM', LucideIcons.plus, _showCreateMasterSheet, primary: true)),
        const SizedBox(width: 7),
        Expanded(child: _headerAction('Invest', LucideIcons.users, () => _showInfo('Investor discovery will be connected later.'))),
        const SizedBox(width: 7),
        Expanded(child: _headerAction(_showGuide ? 'Hide Guide' : 'Guide', LucideIcons.info, () => setState(() => _showGuide = !_showGuide), gold: true)),
      ]),
    ]),
  );

  Widget _headerAction(String label, IconData icon, VoidCallback action, {bool primary = false, bool gold = false}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 38,
      child: FilledButton.icon(
        onPressed: action,
        icon: Icon(icon, size: 14),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        style: FilledButton.styleFrom(
          backgroundColor: gold ? const Color(0xFFEAB308) : primary ? const Color(0xFF2563EB) : (dark ? const Color(0xFF1E2E48) : Colors.white),
          foregroundColor: gold || primary ? Colors.white : (dark ? Colors.white : const Color(0xFF17345D)),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11), side: BorderSide(color: primary || gold ? Colors.transparent : (dark ? const Color(0xFF2A3A53) : const Color(0xFFBFDBFE)))),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required String suffix, required String caption, required IconData icon, required Color tint, required Color accent}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 38, height: 38, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: accent, size: 19)),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .45))),
        Icon(LucideIcons.trendingUp, color: accent.withValues(alpha: .7), size: 20),
      ]),
      const SizedBox(height: 10),
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -.5)),
        const SizedBox(width: 9),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(20)), child: Text(suffix, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w800))),
      ]),
      const SizedBox(height: 10),
      Divider(height: 1, color: Theme.of(context).dividerColor),
      const SizedBox(height: 9),
      Text(caption, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10.5)),
    ]),
  );

  Widget _buildGuideCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: _cardDecoration,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('Understanding MAM Accounts', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14, fontWeight: FontWeight.w800))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2619) : const Color(0xFFFFF7E6), borderRadius: BorderRadius.circular(20)), child: const Text('PRO FEATURE', style: TextStyle(color: Color(0xFFB7791F), fontSize: 8, fontWeight: FontWeight.w800))),
      ]),
      const SizedBox(height: 5),
      Text('Multi-Account Management execution architecture', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
      const SizedBox(height: 13),
      _guideRow(LucideIcons.refreshCw, 'Auto-Mirroring Engine', 'Master trades are mirrored to connected investor accounts.'),
      const SizedBox(height: 10),
      _guideRow(LucideIcons.usersRound, 'Dynamic Lot Proportionality', 'Trade volumes scale according to each investor’s equity.'),
    ]),
  );

  Widget _guideRow(IconData icon, String title, String body) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 32, height: 32, decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2E48) : const Color(0xFFEAF2FF), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF2563EB), size: 16)),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(body, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, height: 1.35)),
    ])),
  ]);

  Widget _buildMasterList(bool dark) => Container(
    decoration: _cardDecoration,
    padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _filterChip('All Masters', _masters.length),
          const SizedBox(width: 6),
          _filterChip('Active', _activeCount),
          const SizedBox(width: 6),
          _filterChip('Disabled', _disabledCount),
        ]),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Search master, ID, leverage...',
          prefixIcon: const Icon(LucideIcons.search, size: 17),
          isDense: true,
          filled: true,
          fillColor: dark ? const Color(0xFF101D31) : const Color(0xFFF7F9FC),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
        ),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(flex: 4, child: Text('MASTER', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5))),
        Expanded(flex: 3, child: Text('LOGIN ID', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5))),
        Expanded(flex: 2, child: Text('SHARE', textAlign: TextAlign.end, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5))),
      ]),
      Divider(height: 16, color: Theme.of(context).dividerColor),
      if (_visibleMasters.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: 26), child: Center(child: Text('No master accounts found', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))))
      else
        ..._visibleMasters.map(_masterListTile),
    ]),
  );

  Widget _filterChip(String label, int count) {
    final selected = _filter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => setState(() => _filter = label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: selected ? const Color(0xFF1E4295) : (isDark ? const Color(0xFF1E2E48) : const Color(0xFFF0F4F9)), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(color: selected ? Colors.white : (isDark ? Theme.of(context).colorScheme.onSurface : const Color(0xFF425875)), fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: selected ? Colors.white24 : (isDark ? const Color(0xFF334B6E) : const Color(0xFFDDE5EF)), borderRadius: BorderRadius.circular(8)), child: Text('$count', style: TextStyle(color: selected ? Colors.white : (isDark ? Theme.of(context).colorScheme.onSurface : const Color(0xFF425875)), fontSize: 9, fontWeight: FontWeight.w800))),
        ]),
      ),
    );
  }

  Widget _masterListTile(_MamMaster master) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: () => _openMasterDetails(master),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, shape: BoxShape.circle), child: Center(child: Text(master.name.substring(0, 1).toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(master.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text('MT5 Master  ·  ID ${master.login}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
            ])),
            _masterStatusBadge(master.status),
            const SizedBox(width: 3),
            Icon(LucideIcons.chevronRight, size: 17, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ]),
          const SizedBox(height: 12),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _miniMetric('PROFIT SHARE', '${master.profitShare.toStringAsFixed(2)}%')),
            Expanded(child: _miniMetric('LEVERAGE', master.leverage)),
            Expanded(child: _miniMetric('BALANCE', '\$0.00')),
          ]),
        ]),
      ),
    ),
  );

  Widget _masterStatusBadge(String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: status == 'Active'
            ? (isDark ? const Color(0xFF132D28) : const Color(0xFFE9FBF4))
            : (isDark ? const Color(0xFF3B2028) : const Color(0xFFFFECEC)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status == 'Active'
              ? const Color(0xFF059669)
              : const Color(0xFFDC4444),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _miniMetric(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: .4)),
    const SizedBox(height: 4),
    Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 11, fontWeight: FontWeight.w800)),
  ]);

  Future<void> _showCreateMasterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateMamSheet(
        onCreate: (master) {
          if (!mounted) return;
          setState(() => _masters.insert(0, master));
          _showInfo('MAM setup saved in this demo screen. Backend creation is not connected yet.');
        },
      ),
    );
  }

  void _openMasterDetails(_MamMaster master) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => _MamMasterDetailsPage(master: master, onChanged: () => setState(() {}))));

  void _showInfo(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _CreateMamSheet extends StatefulWidget {
  const _CreateMamSheet({required this.onCreate});

  final ValueChanged<_MamMaster> onCreate;

  @override
  State<_CreateMamSheet> createState() => _CreateMamSheetState();
}

class _CreateMamSheetState extends State<_CreateMamSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _shareController;
  late final TextEditingController _masterPasswordController;
  late final TextEditingController _investorPasswordController;

  String _risk = 'Medium';
  String _leverage = '1:500';
  String _payout = 'Weekly';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _shareController = TextEditingController(text: '20');
    _masterPasswordController = TextEditingController();
    _investorPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shareController.dispose();
    _masterPasswordController.dispose();
    _investorPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .92),
        padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(LucideIcons.usersRound, color: Color(0xFF2563EB), size: 22),
                const SizedBox(width: 9),
                const Expanded(child: Text('Establish Master MAM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.x)),
              ]),
              Text('Live MT5 Engine  •  Direct STP Allocation', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
              const SizedBox(height: 18),
              _label('MASTER STRATEGY NAME'),
              TextField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(hintText: 'e.g. Apex Global Alpha Pool')),
              const SizedBox(height: 14),
              _label('PROFIT SHARE (%)'),
              TextField(controller: _shareController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(suffixText: '%', hintText: '1 - 50%')),
              const SizedBox(height: 14),
              _label('RISK PROFILE'),
              Wrap(
                spacing: 7,
                children: ['Low', 'Medium', 'High'].map((value) => ChoiceChip(
                  label: Text(value),
                  selected: _risk == value,
                  onSelected: (_) => setState(() => _risk = value),
                )).toList(),
              ),
              const SizedBox(height: 14),
              _label('ACCOUNT LEVERAGE'),
              DropdownButtonFormField<String>(
                initialValue: _leverage,
                items: ['1:100', '1:200', '1:400', '1:500'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (value) => setState(() => _leverage = value ?? _leverage),
              ),
              const SizedBox(height: 14),
              _label('SETTLEMENT PAYOUT FREQUENCY'),
              DropdownButtonFormField<String>(
                initialValue: _payout,
                items: ['Daily', 'Weekly', 'Monthly', 'Quarterly', 'Half-Yearly', 'Annually'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                onChanged: (value) => setState(() => _payout = value ?? _payout),
              ),
              const SizedBox(height: 14),
              _label('MASTER PASSWORD'),
              TextField(controller: _masterPasswordController, obscureText: true, decoration: const InputDecoration(hintText: 'Master trading password')),
              const SizedBox(height: 12),
              _label('INVESTOR PASSWORD'),
              TextField(controller: _investorPasswordController, obscureText: true, decoration: const InputDecoration(hintText: 'Investor read-only password')),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Establish Master Account →', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .55)),
  );

  void _submit() {
    final name = _nameController.text.trim();
    final share = double.tryParse(_shareController.text.trim());
    if (name.isEmpty || share == null || share < 1 || share > 50 ||
        _masterPasswordController.text.isEmpty || _investorPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete all fields. Profit share must be between 1% and 50%.')),
      );
      return;
    }

    widget.onCreate(_MamMaster(
      name: name,
      login: 'Pending setup',
      profitShare: share,
      leverage: _leverage,
      balance: 0,
      status: 'Disabled',
      risk: _risk,
      payout: _payout,
    ));
    Navigator.of(context).pop();
  }
}

class _MamMaster {
  _MamMaster({required this.name, required this.login, required this.profitShare, required this.leverage, required this.balance, required this.status, required this.risk, required this.payout});
  final String name;
  final String login;
  final double profitShare;
  final String leverage;
  final double balance;
  String status;
  final String risk;
  final String payout;
}

class _MamMasterDetailsPage extends StatefulWidget {
  const _MamMasterDetailsPage({required this.master, required this.onChanged});
  final _MamMaster master;
  final VoidCallback onChanged;

  @override
  State<_MamMasterDetailsPage> createState() => _MamMasterDetailsPageState();
}

class _MamMasterDetailsPageState extends State<_MamMasterDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final m = widget.master;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(LucideIcons.arrowLeft)), title: const Text('Master Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.fromLTRB(15, 10, 15, 30), children: [
        Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: Theme.of(context).dividerColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(m.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))), _statusBadge(m.status)]),
          const SizedBox(height: 7),
          Text('LOGIN ID  ${m.login}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
          const SizedBox(height: 16),
          Text('NET AVAILABLE BALANCE', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.w800)),
          const Text('\$0.00 USD', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _detailAction('Quick Fund', LucideIcons.plus, () => _message(context, 'Funding will be connected later.')),
            _detailAction('Withdraw', LucideIcons.wallet, () => _message(context, 'Withdrawal will be connected later.')),
            _detailAction('Performance', LucideIcons.chartNoAxesCombined, () => _message(context, 'Performance data will be connected later.')),
            _detailAction('Investor Pool', LucideIcons.users, () => _message(context, 'Investor allocation will be connected later.')),
          ]),
        ])),
        const SizedBox(height: 12),
        _detailSection(context, 'Master Specifications', LucideIcons.server, [
          _detailLine('Trading platform', 'MetaTrader 5 (MT5)'),
          _detailLine('Leverage', m.leverage),
          _detailLine('Payout cycle', m.payout),
          _detailLine('Risk profile', m.risk),
          _detailLine('Profit share', '${m.profitShare.toStringAsFixed(2)}%'),
        ]),
        const SizedBox(height: 12),
        _detailSection(context, 'Security & Credentials', LucideIcons.shieldCheck, [
          _detailLine('Trader password', '••••••••••'),
          _detailLine('Investor password', '••••••••••'),
        ]),
        const SizedBox(height: 12),
        _detailSection(context, 'Live Orders & Controls', LucideIcons.activity, [
          _detailLine('Open positions', '0'),
          _detailLine('Execution status', m.status),
        ]),
        const SizedBox(height: 12),
        _detailSection(context, 'Profit Share Wallet & Settlements', LucideIcons.wallet, [
          _detailLine('Pending wallet', '\$0.00'),
          _detailLine('Total settled', '\$0.00'),
          _detailLine('Trades processed', '0'),
        ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => m.status = m.status == 'Active' ? 'Disabled' : 'Active'),
          icon: Icon(m.status == 'Active' ? LucideIcons.pause : LucideIcons.play),
          label: Text(m.status == 'Active' ? 'Pause Master Node' : 'Activate Master Node'),
        ),
        const SizedBox(height: 8),
        Text('Demo UI only — balances, credentials, orders and settlements are placeholders until backend integration.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 9)),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: status == 'Active'
            ? (isDark ? const Color(0xFF132D28) : const Color(0xFFE9FBF4))
            : (isDark ? const Color(0xFF3B2028) : const Color(0xFFFFECEC)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status == 'Active'
              ? const Color(0xFF059669)
              : const Color(0xFFDC4444),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
  Widget _detailAction(String label, IconData icon, VoidCallback action) => OutlinedButton.icon(onPressed: action, icon: Icon(icon, size: 14), label: Text(label, style: const TextStyle(fontSize: 10)));
  Widget _detailSection(BuildContext context, String title, IconData icon, List<Widget> children) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Theme.of(context).dividerColor)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Icon(icon, color: const Color(0xFF2563EB), size: 17), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))]),
    const SizedBox(height: 9), const Divider(height: 1), ...children,
  ]));
  Widget _detailLine(String label, String value) => Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10))), Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700))]));
  void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
