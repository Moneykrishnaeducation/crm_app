import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_app/pages/partnership/widgets/partnership_theme.dart';
import 'package:crm_app/pages/partnership_page.dart';

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

  final pages = <(String, Widget Function())>[
    ('BrokerPartnershipPage', () => const BrokerPartnershipPage()),
    ('BrokerClientTreePage', () => const BrokerClientTreePage()),
    ('BrokerCommissionLedgerPage', () => const BrokerCommissionLedgerPage()),
    ('BrokerCommissionWithdrawalPage', () => const BrokerCommissionWithdrawalPage()),
    ('BrokerReferralStudioPage', () => const BrokerReferralStudioPage()),
  ];

  for (final (name, builder) in pages) {
    testWidgets(
      '$name renders PartnershipSkeletonizer cleanly on mobile without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final brightness in [Brightness.light, Brightness.dark]) {
          await tester.pumpWidget(wrap(builder(), brightness: brightness));
          expect(find.byType(PartnershipSkeletonizer), findsWidgets);

          await tester.pump(const Duration(milliseconds: 50));
        }

        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
