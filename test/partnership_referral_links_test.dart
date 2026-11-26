import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crm_app/pages/partnership/models/partnership_models.dart';
import 'package:crm_app/pages/partnership/widgets/leaderboard_card.dart';
import 'package:crm_app/pages/partnership/widgets/partnership_theme.dart';

void main() {
  group('IbReferralLink.listFromResponse parsing', () {
    test('parses referral_links list with profile_name and code', () {
      final links = IbReferralLink.listFromResponse({
        'referral_links': [
          {
            'profile_name': 'Direct VIP',
            'referral_link': 'https://client.vtindex.com/?ref=VIP123',
            'referral_code': 'VIP123',
            'is_primary': true,
            'clients_count': 12,
          },
          {
            'name': 'Sub Partner',
            'url': 'https://client.vtindex.com/?ref=SUB456',
            'code': 'SUB456',
          },
        ],
      });

      expect(links.length, 2);
      expect(links[0].profileName, 'Direct VIP');
      expect(links[0].referralCode, 'VIP123');
      expect(links[0].isPrimary, isTrue);
      expect(links[0].clientsCount, 12);
      expect(links[1].profileName, 'Sub Partner');
      expect(links[1].referralCode, 'SUB456');
    });

    test('parses AuthApi-wrapped array responses (data: [...]) and nested data maps', () {
      final wrappedList = IbReferralLink.listFromResponse({
        'data': [
          {
            'commission_profile_name': 'TEST5',
            'link': 'https://client.vtindex.com/?ref=KCO1DAFK',
          },
        ],
      });
      expect(wrappedList.length, 1);
      expect(wrappedList[0].profileName, 'TEST5');
      expect(wrappedList[0].referralCode, 'KCO1DAFK');
      expect(wrappedList[0].effectiveUrl, 'https://client.vtindex.com/?ref=KCO1DAFK');

      final nestedMap = IbReferralLink.listFromResponse({
        'data': {
          'results': [
            {'profile_name': 'Standard', 'referral_code': 'STD99'},
          ],
        },
      });
      expect(nestedMap.length, 1);
      expect(nestedMap[0].referralCode, 'STD99');
      expect(nestedMap[0].effectiveUrl, 'https://client.vtindex.com/?ref=STD99');
    });

    test('parses single Map referral_link, ignores empty strings, and uses stats fallback', () {
      final mapObj = IbReferralLink.listFromResponse({
        'referral_link': {
          'profile_name': 'Pro Partner',
          'url': 'https://client.vtindex.com/?ref=PRO1',
          'code': 'PRO1',
        },
      });
      expect(mapObj.length, 1);
      expect(mapObj[0].profileName, 'Pro Partner');

      final emptyPrimaryWithStats = IbReferralLink.listFromResponse(
        {'referral_link': ''},
        statsResponse: {
          'earnings_per_link': [
            {'profile_name': 'From Stats', 'referral_code': 'STAT1'},
          ],
        },
      );
      expect(emptyPrimaryWithStats.length, 1);
      expect(emptyPrimaryWithStats[0].profileName, 'From Stats');
      expect(emptyPrimaryWithStats[0].referralCode, 'STAT1');
    });
  });

  testWidgets('LeaderboardCard Links tab displays all parsed referral links without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final links = IbReferralLink.listFromResponse({
      'data': [
        {
          'profile_name': 'Standard Direct',
          'referral_link': 'https://client.vtindex.com/?ref=CODE1',
          'referral_code': 'CODE1',
          'clients_count': 8,
        },
        {
          'profile_name': 'Raw ECN',
          'referral_code': 'CODE2',
        },
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: LeaderboardCard(
                colors: PartnershipColors.of(context),
                dashboardData: IbDashboardData.demo(),
                referralLinks: links,
                clientTree: const [],
                onIbChanged: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Links'));
    await tester.pumpAndSettle();

    expect(find.text('Standard Direct'), findsOneWidget);
    expect(find.text('Raw ECN'), findsOneWidget);
    expect(find.textContaining('CODE1'), findsOneWidget);
    expect(find.textContaining('CODE2'), findsOneWidget);
  });
}
