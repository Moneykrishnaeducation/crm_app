import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_connected_portfolio_view.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_tab_views.dart';
import 'package:crm_app/pages/pamm_page.dart';

void main() {
  Widget wrap(Widget child, {Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF040D1E)
            : const Color(0xFFF7FAFF),
      ),
      home: child,
    );
  }

  testWidgets(
    'PammPage renders PammSkeletonizer cleanly on mobile without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(wrap(const PammPage(), brightness: brightness));
        expect(find.byType(PammSkeletonizer), findsWidgets);
        expect(find.byType(RefreshIndicator), findsWidgets);
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'PammConnectedPortfolioView shows PammSkeletonizer while loading on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pool = PammPool.skeletonSamples().first;

      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: PammConnectedPortfolioView(
                pool: pool,
                investors: const [],
                loading: true,
                error: null,
                onClose: () {},
                onRetry: () async {},
              ),
            ),
            brightness: brightness,
          ),
        );

        expect(find.byType(PammSkeletonizer), findsWidgets);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(RefreshIndicator), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 50));
      }

      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'PammAvailableTabView filters Profit Share pools and supports Reset filters',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pools = [
        PammPool('High Fee Pool', '1001', '1:500', 50000, 35, id: '1'),
        PammPool('Zero Fee Pool', '1002', '1:500', 20000, 0, id: '2'),
        PammPool('Low Fee Pool', '1003', '1:200', 80000, 15, id: '3'),
      ];
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: PammAvailableTabView(
              available: pools,
              loading: false,
              onRefresh: () async {},
              query: '',
              selectedFilter: 'Profit Share',
              searchController: controller,
              onQueryChanged: (_) {},
              onClearQuery: () {},
              onSelectFilter: (_) {},
              onInvest: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Low Fee Pool'), findsOneWidget);
      expect(find.text('High Fee Pool'), findsOneWidget);
      expect(find.text('Zero Fee Pool'), findsNothing);

      final lowY = tester.getTopLeft(find.text('Low Fee Pool')).dy;
      final highY = tester.getTopLeft(find.text('High Fee Pool')).dy;
      expect(lowY, lessThan(highY));

      var cleared = false;
      var resetFilter = '';
      controller.text = 'non-matching-pool';

      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: PammAvailableTabView(
              available: pools,
              loading: false,
              onRefresh: () async {},
              query: 'non-matching-pool',
              selectedFilter: 'All Pools',
              searchController: controller,
              onQueryChanged: (_) {},
              onClearQuery: () => cleared = true,
              onSelectFilter: (value) => resetFilter = value,
              onInvest: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Reset filters'), findsOneWidget);
      await tester.tap(find.text('Reset filters'));
      await tester.pump();

      expect(cleared, isTrue);
      expect(resetFilter, 'All Pools');
    },
  );
}
