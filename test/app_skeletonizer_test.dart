import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_app/main.dart';
import 'package:crm_app/pages/mam_page.dart';
import 'package:crm_app/pages/mam_investor_live_positions_page.dart';
import 'package:crm_app/pages/mam_manager_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestable(Widget child) {
    return MaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('AppSkeletonizer renders cleanly with shimmer effect', (tester) async {
    await tester.pumpWidget(
      buildTestable(
        const AppSkeletonizer(
          enabled: true,
          child: Text('Placeholder content'),
        ),
      ),
    );

    expect(find.byType(AppSkeletonizer), findsOneWidget);
    final skeletonizer = tester.widget<AppSkeletonizer>(find.byType(AppSkeletonizer));
    expect(skeletonizer.enabled, isTrue);
  });

  testWidgets('BrokerAccountsPage renders AppSkeletonizer cleanly while loading', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      buildTestable(
        BrokerAccountsPage(
          isLoading: true,
          accounts: const [],
          favoriteLogins: const {},
          onAccountCreated: (_) {},
          onAccountSelected: (_) {},
          onSelectPage: (_) {},
          onToggleFavorite: (_) {},
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(AppSkeletonizer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MamPage renders AppSkeletonizer cleanly while loading master nodes', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      buildTestable(
        const MamPage(initialTab: 0),
      ),
    );

    await tester.pump();
    expect(find.byType(AppSkeletonizer), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MamManagerPage shows skeleton cards while loading masters', (tester) async {
    await tester.pumpWidget(buildTestable(const MamManagerPage()));

    expect(find.byType(AppSkeletonizer), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.pumpWidget(buildTestable(const SizedBox.shrink()));
  });

  testWidgets('Live positions show skeleton cards during the initial load', (tester) async {
    await tester.pumpWidget(
      buildTestable(
        const MamInvestorLivePositionsPage(
          accountId: '3311',
          accountName: 'Test account',
        ),
      ),
    );

    expect(find.byType(AppSkeletonizer), findsOneWidget);
    expect(find.text('OPEN POSITIONS'), findsOneWidget);

    await tester.pumpWidget(buildTestable(const SizedBox.shrink()));
  });

  testWidgets('Support tickets show skeleton cards during the initial load', (tester) async {
    await tester.pumpWidget(buildTestable(const BrokerTicketsPage()));

    expect(find.byType(AppSkeletonizer), findsOneWidget);
    expect(find.text('TICKET #000000'), findsWidgets);

    await tester.pumpWidget(buildTestable(const SizedBox.shrink()));
  });
}
