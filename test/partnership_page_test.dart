import 'dart:async';
import 'dart:convert';

import 'package:crm_app/pages/partnership/models/partnership_models.dart';
import 'package:crm_app/pages/partnership/widgets/partnership_dashboard_view.dart';
import 'package:crm_app/pages/partnership/widgets/partnership_modals.dart';
import 'package:crm_app/pages/partnership/widgets/partnership_theme.dart';
import 'package:crm_app/pages/partnership_page.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Response _jsonResponse(Object body, {int status = 200}) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: const {'content-type': 'application/json'},
  );
}

Map<String, dynamic> _sampleStatsPayload() => <String, dynamic>{
      'total_clients': 42,
      'direct_clients': 28,
      'total_earnings': '4820.00',
      'total_withdrawals': '1200.00',
      'commission_balance': '3620.00',
      'current_month_earnings': '840.25',
      'current_month_volume_traded': '142.80',
      'total_volume_traded': '980.50',
      'referral_link': 'https://client.vtindex.com/?ref=VT-TEST',
      'earnings_per_client': [
        {
          'client_id': 'CL-101',
          'name': 'Alexander Wright',
          'total_commission': '1850.50',
          'total_volume': '142.00',
        },
      ],
      'earnings_per_month': [
        {'month': 'Jan', 'total': '450.00'},
        {'month': '2026-04', 'total': '1150.25'},
      ],
    };

Map<String, dynamic> _sampleLinksPayload() => <String, dynamic>{
      'referral_links': [
        {
          'profile_name': 'Direct VIP',
          'referral_link': 'https://client.vtindex.com/?ref=VIP123',
          'referral_code': 'VIP123',
          'is_primary': true,
          'clients_count': 18,
        },
      ],
    };

Map<String, dynamic> _sampleLedgerPayload() => <String, dynamic>{
      'data': {
        'results': [
          {
            'id': 'txn-1',
            'client_user': 'Alexander Wright',
            'client_trading_account': '883921',
            'position_symbol': 'XAUUSD',
            'deal_ticket': '1048291',
            'order_ticket': '904821',
            'volume_lots': '1.50',
            'profit': '245.00',
            'amount': '18.50',
            'created_at': '2026-04-10T14:22:00Z',
            'commission_profile_name': 'VIP Scalpers',
          },
        ],
      },
    };

Map<String, dynamic> _sampleTreePayload() => <String, dynamic>{
      'data': {
        'clients': [
          {
            'id': 'CL-101',
            'name': 'Alexander Wright',
            'email': 'alex@example.com',
            'level': 1,
            'is_ib': true,
            'accounts': [
              {
                'account_id': '883921',
                'account_type': 'MT5 Pro ECN',
                'total_lots': '142.00',
                'total_deposits': '25000.00',
                'total_commission': '1850.50',
              },
            ],
            'clients': [
              {
                'id': 'CL-201',
                'name': 'Marcus Vance',
                'email': 'marcus@example.com',
                'level': 2,
                'accounts': [],
              },
            ],
          },
        ],
      },
    };

MockClient _approvedIbClient({
  List<String>? requestedPaths,
  Map<String, dynamic>? statusOverride,
  int statsStatusCode = 200,
  Map<String, dynamic>? accountsPayload,
}) {
  return MockClient((request) async {
    requestedPaths?.add(request.url.path);
    final path = request.url.path;
    if (path.endsWith('/ib/status/')) {
      return _jsonResponse(
        statusOverride ?? {'approved': true, 'status': 'approved'},
      );
    }
    if (path.endsWith('/ib/stats/')) {
      if (statsStatusCode != 200) {
        return _jsonResponse({'detail': 'Server error'}, status: statsStatusCode);
      }
      return _jsonResponse(_sampleStatsPayload());
    }
    if (path.endsWith('/ib/referral-link/')) {
      return _jsonResponse(_sampleLinksPayload());
    }
    if (path.endsWith('/ib/commission-transactions/')) {
      return _jsonResponse(_sampleLedgerPayload());
    }
    if (path.endsWith('/ib/client-tree/')) {
      return _jsonResponse(_sampleTreePayload());
    }
    if (path.endsWith('/non-demo-accounts/')) {
      return _jsonResponse(
        accountsPayload ??
            {
              'accounts': [
                {
                  'account_id': '900111',
                  'account_type': 'Standard',
                  'is_demo': false,
                  'group_name': 'real\\Standard',
                  'balance': '1500.00',
                },
              ],
            },
      );
    }
    return _jsonResponse({});
  });
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AuthApi.instance.resetForTesting();
    AuthApi.instance.setSessionForTesting(accessToken: 'test-token');
    AuthApi.instance.setHttpClientForTesting(
      MockClient((_) async => _jsonResponse({})),
    );
    // Pre-warm the RSA session keypair outside FakeAsync so widget tests
    // resolve MockClient requests in microtasks without Isolate stalls.
    await AuthApi.instance.getIbStatus();
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
  });

  Future<void> settleMockRequests(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Widget buildTestableWidget({
    Brightness brightness = Brightness.light,
    Widget child = const BrokerPartnershipPage(),
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        scaffoldBackgroundColor: brightness == Brightness.dark
            ? const Color(0xFF040D1E)
            : const Color(0xFFF7FAFF),
        cardColor: brightness == Brightness.dark
            ? const Color(0xFF0F2148)
            : Colors.white,
        dividerColor: brightness == Brightness.dark
            ? const Color(0xFF1E3F8A)
            : const Color(0xFFDCE5F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: brightness,
        ),
      ),
      home: child,
    );
  }

  group('BrokerPartnershipPage UI and Theme Tests', () {
    testWidgets('renders approved dashboard in Light Mode and invokes onBack', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthApi.instance.setHttpClientForTesting(_approvedIbClient());
      var backCalled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          brightness: Brightness.light,
          child: BrokerPartnershipPage(onBack: () => backCalled = true),
        ),
      );
      await settleMockRequests(tester);

      expect(find.text('Partnership Command Center'), findsOneWidget);
      expect(find.text('Liquid Available Balance'), findsOneWidget);
      expect(find.text(r'$3620.00'), findsWidgets);
      expect(find.text('FINANCIAL & VOLUME TELEMETRY'), findsOneWidget);
      expect(find.text('Total Earnings'), findsOneWidget);
      expect(find.text(r'$4820.00'), findsOneWidget);
      expect(find.text('Commission Trajectory'), findsOneWidget);
      expect(find.text('Top Client Performers'), findsOneWidget);
      expect(find.text('Alexander Wright'), findsOneWidget);
      expect(find.text('PARTNERSHIP TOOLS & REPORTS'), findsOneWidget);
      expect(find.text('Client Network Hierarchy'), findsOneWidget);
      expect(find.text('Commission Ledger & History'), findsOneWidget);
      expect(find.text('Commission Payout & Withdrawal'), findsOneWidget);
      expect(find.text('Referral Link & QR Studio'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      expect(backCalled, isTrue);
    });

    testWidgets('renders properly in Dark Mode without layout exceptions', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthApi.instance.setHttpClientForTesting(_approvedIbClient());

      await tester.pumpWidget(buildTestableWidget(brightness: Brightness.dark));
      await settleMockRequests(tester);

      expect(find.text('Partnership Command Center'), findsOneWidget);
      expect(find.text(r'$3620.00'), findsWidgets);
    });

    testWidgets('tapping Instant QR opens bottom sheet with referral QR and links', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthApi.instance.setHttpClientForTesting(_approvedIbClient());

      await tester.pumpWidget(buildTestableWidget());
      await settleMockRequests(tester);

      await tester.tap(find.text('Instant QR'));
      await tester.pumpAndSettle();

      expect(find.text('Referral QR & Link'), findsOneWidget);
      expect(find.text('Copy link'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });
  });

  group('403 & IB Status Gating', () {
    testWidgets(
      'pending IB status with has_ib_status=true does NOT call 403 endpoints or trigger logout',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final requestedPaths = <String>[];
        final unauthorizedEvents = <int>[];
        final sub = AuthApi.instance.onUnauthorizedSession.listen(unauthorizedEvents.add);
        addTearDown(sub.cancel);

        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            requestedPaths.add(request.url.path);
            if (request.url.path.endsWith('/ib/status/')) {
              return _jsonResponse({
                'approved': false,
                'has_ib_status': true,
                'status': 'pending',
              });
            }
            return _jsonResponse({'detail': 'Forbidden'}, status: 403);
          }),
        );

        await tester.pumpWidget(buildTestableWidget());
        await settleMockRequests(tester);

        expect(find.text('Application Pending Review'), findsOneWidget);
        expect(find.text('Under Review'), findsOneWidget);
        expect(requestedPaths.where((p) => p.endsWith('/ib/status/')).length, 1);
        expect(requestedPaths.any((p) => p.endsWith('/ib/stats/')), isFalse);
        expect(requestedPaths.any((p) => p.endsWith('/ib/referral-link/')), isFalse);
        expect(requestedPaths.any((p) => p.endsWith('/ib/commission-transactions/')), isFalse);
        expect(requestedPaths.any((p) => p.endsWith('/ib/client-tree/')), isFalse);
        expect(requestedPaths.any((p) => p.endsWith('/logout/')), isFalse);
        expect(unauthorizedEvents, isEmpty);
      },
    );

    testWidgets(
      'rejected IB status renders rejected view and does NOT call 403 endpoints',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final requestedPaths = <String>[];
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            requestedPaths.add(request.url.path);
            if (request.url.path.endsWith('/ib/status/')) {
              return _jsonResponse({'approved': false, 'status': 'rejected'});
            }
            return _jsonResponse({'detail': 'Forbidden'}, status: 403);
          }),
        );

        await tester.pumpWidget(buildTestableWidget());
        await settleMockRequests(tester);

        expect(find.text('Rejected'), findsOneWidget);
        expect(find.text('Application Not Approved'), findsOneWidget);
        expect(find.text('Re-apply for IB Partnership'), findsWidgets);
        expect(requestedPaths.any((p) => p.endsWith('/ib/stats/')), isFalse);
        expect(requestedPaths.any((p) => p.endsWith('/logout/')), isFalse);
      },
    );

    testWidgets(
      'getIbStatus error shows retry state and does NOT fall through to 403 endpoints',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        var statusCalls = 0;
        final requestedPaths = <String>[];
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            requestedPaths.add(request.url.path);
            if (request.url.path.endsWith('/ib/status/')) {
              statusCalls++;
              if (statusCalls == 1) {
                return _jsonResponse({'detail': 'Service unavailable'}, status: 500);
              }
              return _jsonResponse({'approved': true, 'status': 'approved'});
            }
            if (request.url.path.endsWith('/ib/stats/')) {
              return _jsonResponse(_sampleStatsPayload());
            }
            if (request.url.path.endsWith('/ib/referral-link/')) {
              return _jsonResponse(_sampleLinksPayload());
            }
            if (request.url.path.endsWith('/ib/commission-transactions/')) {
              return _jsonResponse(_sampleLedgerPayload());
            }
            if (request.url.path.endsWith('/ib/client-tree/')) {
              return _jsonResponse(_sampleTreePayload());
            }
            return _jsonResponse({});
          }),
        );

        await tester.pumpWidget(buildTestableWidget());
        await settleMockRequests(tester);

        expect(find.text('Unable to Load Partnership Status'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(requestedPaths.any((p) => p.endsWith('/ib/stats/')), isFalse);

        await tester.tap(find.text('Retry'));
        await settleMockRequests(tester);

        expect(find.text('Partnership Command Center'), findsOneWidget);
      },
    );

    testWidgets(
      'approved IB endpoint failure surfaces retry banner instead of silent \$0.00 dashboard',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        AuthApi.instance.setHttpClientForTesting(
          _approvedIbClient(statsStatusCode: 500),
        );

        await tester.pumpWidget(buildTestableWidget());
        await settleMockRequests(tester);

        expect(find.textContaining('failed to load'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'BrokerReferralStudioPage gates with getIbStatus and separates error vs IB Approval Required',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final requestedPaths = <String>[];
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            requestedPaths.add(request.url.path);
            if (request.url.path.endsWith('/ib/status/')) {
              return _jsonResponse({'approved': false, 'status': 'pending'});
            }
            return _jsonResponse({'detail': 'Forbidden'}, status: 403);
          }),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const BrokerReferralStudioPage()),
        );
        await settleMockRequests(tester);

        expect(find.text('IB Approval Required'), findsOneWidget);
        expect(requestedPaths.any((p) => p.endsWith('/ib/referral-link/')), isFalse);
        expect(requestedPaths.any((p) => p.endsWith('/ib/stats/')), isFalse);

        // Now verify API error state renders error + Retry instead of IB Approval Required
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            if (request.url.path.endsWith('/ib/status/')) {
              return _jsonResponse({'detail': 'Gateway timeout'}, status: 502);
            }
            return _jsonResponse({});
          }),
        );

        await tester.tap(find.text('Refresh Status'));
        await settleMockRequests(tester);

        expect(find.text('Unable to Load Referral Studio'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('IB Approval Required'), findsNothing);
      },
    );
  });

  group('Sub-pages & Demo Account Filtering', () {
    testWidgets(
      'BrokerCommissionWithdrawalPage uses non-demo-accounts and filters out demo/empty accounts',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final requestedPaths = <String>[];
        AuthApi.instance.setHttpClientForTesting(
          _approvedIbClient(
            requestedPaths: requestedPaths,
            accountsPayload: {
              'accounts': [
                {
                  'account_id': '',
                  'account_type': 'Standard',
                  'balance': '100.00',
                },
                {
                  'account_id': '700111',
                  'account_type': 'demo',
                  'is_demo': true,
                  'group_name': 'demo\\USD',
                  'balance': '10000.00',
                },
                {
                  'account_id': '700222',
                  'account_type': 'Standard',
                  'is_demo': false,
                  'group_name': 'demo\\Classic',
                  'balance': '5000.00',
                },
                {
                  'account_id': '900333',
                  'account_type': 'ECN Live',
                  'is_demo': false,
                  'group_name': 'real\\ECN',
                  'balance': '2500.00',
                },
              ],
            },
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const BrokerCommissionWithdrawalPage()),
        );
        await settleMockRequests(tester);

        expect(requestedPaths.any((p) => p.endsWith('/non-demo-accounts/')), isTrue);
        expect(find.textContaining('900333'), findsOneWidget);
        expect(find.textContaining('700111'), findsNothing);
        expect(find.textContaining('700222'), findsNothing);

        // Tap 50% preset (50% of 3620.00 = 1810.00)
        await tester.tap(find.text('50%'));
        await tester.pump();
        expect(find.text('1810.00'), findsOneWidget);
      },
    );

    testWidgets(
      'BrokerClientTreePage handles nested data and independent expansion of empty-id nodes',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            if (request.url.path.endsWith('/ib/client-tree/')) {
              return _jsonResponse({
                'data': {
                  'clients': [
                    {
                      'id': '',
                      'name': 'Parent One',
                      'email': 'p1@example.com',
                      'clients': [
                        {'id': '', 'name': 'Child One', 'email': 'c1@example.com'},
                      ],
                    },
                    {
                      'id': '',
                      'name': 'Parent Two',
                      'email': 'p2@example.com',
                      'clients': [
                        {'id': '', 'name': 'Child Two', 'email': 'c2@example.com'},
                      ],
                    },
                  ],
                },
              });
            }
            return _jsonResponse({});
          }),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const BrokerClientTreePage()),
        );
        await settleMockRequests(tester);

        expect(find.text('Parent One'), findsOneWidget);
        expect(find.text('Parent Two'), findsOneWidget);
        expect(find.text('Child One'), findsNothing);
        expect(find.text('Child Two'), findsNothing);

        await tester.tap(find.text('View team').first);
        await tester.pumpAndSettle();

        expect(find.text('Child One'), findsOneWidget);
        expect(find.text('Child Two'), findsNothing);
      },
    );

    testWidgets('BrokerCommissionLedgerPage renders unwrapped data.results deals', (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthApi.instance.setHttpClientForTesting(_approvedIbClient());

      await tester.pumpWidget(
        buildTestableWidget(child: const BrokerCommissionLedgerPage()),
      );
      await settleMockRequests(tester);

      expect(find.text('Commission Ledger'), findsOneWidget);
      expect(find.text('1 Deals'), findsOneWidget);
      expect(find.text('XAUUSD · Deal #1048291'), findsOneWidget);
    });

    testWidgets('renders all partnership pages on mobile (390x844) without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthApi.instance.setHttpClientForTesting(_approvedIbClient());

      for (final page in const <Widget>[
        BrokerPartnershipPage(),
        BrokerReferralStudioPage(),
        BrokerCommissionWithdrawalPage(),
        BrokerClientTreePage(),
        BrokerCommissionLedgerPage(),
      ]) {
        await tester.pumpWidget(buildTestableWidget(child: page));
        await settleMockRequests(tester);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Model Parsing, Safe Numerics, and Modal Lifecycle', () {
    test('IbDashboardData.fromJson handles string/ISO months and stringified decimals', () {
      final data = IbDashboardData.fromJson({
        'total_clients': '15',
        'direct_clients': 10,
        'total_earnings': '1234.56',
        'commission_balance': '450.25',
        'earnings_per_month': [
          {'month': 'Jan', 'total': '120.50'},
          {'month': 'February', 'total': '230.00'},
          {'month': '2026-04', 'total': '340.75'},
          {'month': 6, 'total': 500},
        ],
        'earnings_per_client': [
          {
            'name': 'Client A',
            'total_commission': '320.50',
            'total_volume': '12.25',
          },
        ],
      });

      expect(data.totalClients, 15);
      expect(data.totalEarnings, closeTo(1234.56, 0.001));
      expect(data.commissionBalance, closeTo(450.25, 0.001));

      final byMonth = {
        for (final m in data.earningsPerMonth) m['month']: m['total'],
      };
      expect(byMonth['JAN'], closeTo(120.50, 0.001));
      expect(byMonth['FEB'], closeTo(230.00, 0.001));
      expect(byMonth['APR'], closeTo(340.75, 0.001));
      expect(byMonth['JUN'], closeTo(500.00, 0.001));
    });

    test('IbClient.fromJson never stringifies null into "null" and unwraps nested data', () {
      final client = IbClient.fromJson({
        'id': '10',
        'name': 'Jane Doe',
        'referral_code': null,
        'commission_profile_name': null,
        'referral_link': {'code': null, 'profile_name': null},
      });

      expect(client.referralCode, '');
      expect(client.commissionProfileName, '');

      final clientsList = extractPartnershipList({
        'data': {
          'clients': [
            {'id': '1', 'name': 'Nested Client'},
          ],
        },
      });
      expect(clientsList.length, 1);
      expect(clientsList.first['name'], 'Nested Client');
    });

    testWidgets('LeaderboardCard safely parses stringified decimals and searches nested tree', (tester) async {
      final dashboard = IbDashboardData.fromJson({
        'earnings_per_client': [
          {
            'client_id': 'CL-NESTED',
            'name': 'Nested Performer',
            'total_commission': '980.50',
            'total_volume': '45.25',
          },
        ],
      });

      final nestedTree = [
        IbClient(
          id: 'CL-ROOT',
          name: 'Root IB',
          clients: [
            IbClient(
              id: 'CL-NESTED',
              name: 'Nested Performer',
              accounts: [IbTradingAccount(accountId: '998877')],
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          child: Scaffold(
            body: Builder(
              builder: (context) => LeaderboardCard(
                colors: PartnershipColors.of(context),
                dashboardData: dashboard,
                referralLinks: const [],
                clientTree: nestedTree,
                onIbChanged: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$980.50'), findsOneWidget);
      expect(find.text('45.25 Lots'), findsOneWidget);

      await tester.tap(find.text('Nested Performer'));
      await tester.pumpAndSettle();

      expect(find.text('998877'), findsOneWidget);
    });

    testWidgets('AccountDetailSheet formats negative profit as -\$50.00 and parses commas', (tester) async {
      AuthApi.instance.setHttpClientForTesting(
        MockClient((request) async {
          if (request.url.path.contains('/account-details/')) {
            return _jsonResponse({
              'balance': '1,250.00',
              'equity': '1,200.00',
              'margin': '100.00',
              'profit': '-50.00',
            });
          }
          if (request.url.path.contains('/open-positions/')) {
            return _jsonResponse({
              'positions': [
                {
                  'symbol': 'EURUSD',
                  'type': 'BUY',
                  'volume': '1.00',
                  'open_price': '1.0800',
                  'current_price': '1.0750',
                  'profit': '-1,250.50',
                },
              ],
            });
          }
          return _jsonResponse({});
        }),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: Scaffold(
            body: Builder(
              builder: (context) => AccountDetailSheet(
                account: IbTradingAccount(accountId: '883921'),
                colors: PartnershipColors.of(context),
              ),
            ),
          ),
        ),
      );
      await settleMockRequests(tester);

      expect(find.text(r'-$50.00'), findsOneWidget);
      expect(find.text(r'-$1250.50'), findsOneWidget);
      expect(find.text(r'$-50.0'), findsNothing);
    });

    testWidgets('PartnershipDashboardView invokes onBack when provided', (tester) async {
      var backTapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          child: PartnershipDashboardView(
            dashboardData: IbDashboardData.demo(),
            referralLinks: IbReferralLink.demoList(),
            clientTree: const [],
            commissionTxns: const [],
            loading: false,
            demoPreviewMode: false,
            onBack: () => backTapped = true,
            onRefresh: () async {},
            onExitDemoMode: () {},
            onIbChanged: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Back'));
      expect(backTapped, isTrue);
    });

    testWidgets('showIbTermsModal stays open with error when onSubmit fails and closes on success', (tester) async {
      var completer = Completer<void>();

      await tester.pumpWidget(
        buildTestableWidget(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showIbTermsModal(
                  context,
                  initialAgreed: true,
                  onAgreedChanged: (_) {},
                  onSubmit: () => completer.future,
                ),
                child: const Text('Open Terms'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Terms'));
      await tester.pumpAndSettle();

      expect(find.text('IB Partnership Agreement'), findsOneWidget);
      await tester.tap(find.text('Submit IB Application'));
      await tester.pump();

      // Modal stays open while submission is in flight
      expect(find.text('IB Partnership Agreement'), findsOneWidget);

      completer.completeError(const AuthApiException('Server rejected', statusCode: 400));
      await tester.pumpAndSettle();

      expect(find.text('IB Partnership Agreement'), findsOneWidget);
      expect(find.text('Server rejected'), findsOneWidget);

      // Retry with succeeding future closes the modal cleanly
      completer = Completer<void>();
      await tester.tap(find.text('Submit IB Application'));
      await tester.pump();
      expect(find.text('IB Partnership Agreement'), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
      expect(find.text('IB Partnership Agreement'), findsNothing);
    });
  });
}
