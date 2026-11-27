import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_available_detail_view.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_dialogs.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_pool_cards.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_shared_widgets.dart';
import 'package:crm_app/pages/pamm/widgets/pamm_tab_views.dart';
import 'package:crm_app/pages/pamm_page.dart';
import 'package:crm_app/services/auth_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await AuthApi.instance.resetForTesting();
    AuthApi.instance.setSessionForTesting(
      accessToken: 'test-token',
      cookies: <String, String>{'client_access_token': 'test-token'},
    );
    // Warm up the cached RSA response keypair outside FakeAsync so widget tests
    // using MockClient never block on background Isolate.run key generation.
    AuthApi.instance.setHttpClientForTesting(
      MockClient((_) async => http.Response('{}', 200)),
    );
    await AuthApi.instance.getProfile().catchError((_) => <String, dynamic>{});
    AuthApi.instance.setHttpClientForTesting(null);
  });

  tearDown(() async {
    await AuthApi.instance.resetForTesting();
  });

  Widget wrap(Widget child) => MaterialApp(home: child);

  Future<void> pumpAsync(WidgetTester tester, {int ticks = 5}) async {
    for (var i = 0; i < ticks; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  group('pamm_models.dart', () {
    test('formatPammMoney formats positive, zero, and negative values', () {
      expect(formatPammMoney(0), r'$0.00');
      expect(formatPammMoney(25.5), r'$25.50');
      expect(formatPammMoney(-25.5), r'-$25.50');
      expect(formatPammMoney(-0.001), r'$0.00');
    });

    test('parsePammDouble strips commas and rejects invalid inputs', () {
      expect(parsePammDouble('1,250.50'), 1250.5);
      expect(parsePammDouble('  10,000 '), 10000.0);
      expect(parsePammDouble(''), isNull);
      expect(parsePammDouble('abc'), isNull);
    });

    test(
      'pammInvestmentFromMap prioritizes pool name keys and extracts pammId safely',
      () {
        final investment = pammInvestmentFromMap(<String, dynamic>{
          'id': 99,
          'pamm_id': 42,
          'user_name': 'Alice',
          'investor_name': 'Alice Inv',
          'pam_account_name': 'Alpha Pool',
          'pamm_mt5_account_id': '88001',
        });
        expect(investment.name, 'Alpha Pool');
        expect(investment.id, '99');
        expect(investment.pammId, '42');
        expect(investment.login, '88001');

        final nestedInvestment = pammInvestmentFromMap(<String, dynamic>{
          'id': 105,
          'investor_name': 'Bob Alias',
          'pamm': <String, dynamic>{
            'id': 77,
            'pamm_name': 'Quant Growth',
            'mt5_account_id': '88002',
          },
        });
        expect(nestedInvestment.id, '105');
        expect(nestedInvestment.pammId, '77');
        expect(nestedInvestment.name, 'Quant Growth');
        expect(nestedInvestment.login, '88002');

        final rowWithoutPammId = pammInvestmentFromMap(<String, dynamic>{
          'id': 55,
          'user_name': 'Connected Investor',
        });
        expect(rowWithoutPammId.id, '55');
        expect(rowWithoutPammId.pammId, '');
        expect(rowWithoutPammId.name, 'Connected Investor');
      },
    );

    test('pammPoolFromMap maps closed, disabled, inactive, and is_active=false to Closed', () {
      expect(
        pammPoolFromMap(<String, dynamic>{'id': 1, 'status': 'closed'}).status,
        'Closed',
      );
      expect(
        pammPoolFromMap(<String, dynamic>{'id': 2, 'status': 'disabled'}).status,
        'Closed',
      );
      expect(
        pammPoolFromMap(<String, dynamic>{'id': 3, 'status': 'inactive'}).status,
        'Closed',
      );
      expect(
        pammPoolFromMap(<String, dynamic>{
          'id': 4,
          'is_accepting_investors': true,
          'is_active': false,
        }).status,
        'Closed',
      );
      expect(
        pammPoolFromMap(<String, dynamic>{
          'id': 5,
          'status': 'open',
          'is_active': true,
        }).status,
        'Open',
      );
    });
  });

  group('PammPoolCard & PammAvailableDetailView', () {
    testWidgets('PammPoolCard displays CLOSED badge and disables actions when Closed', (
      tester,
    ) async {
      final closedPool = PammPool(
        'Closed Pool',
        '1001',
        '1:500',
        25000,
        20,
        id: '1',
        status: 'Closed',
      );
      final openPool = PammPool(
        'Open Pool',
        '1002',
        '1:500',
        30000,
        20,
        id: '2',
        status: 'Open',
      );

      await tester.pumpWidget(
        wrap(
          Scaffold(
            body: ListView(
              children: [
                PammPoolCard(
                  pool: closedPool,
                  managed: true,
                  onDetails: () {},
                  onDeposit: () {},
                ),
                PammPoolCard(
                  pool: closedPool,
                  managed: false,
                  onInvest: () {},
                ),
                PammPoolCard(
                  pool: openPool,
                  managed: false,
                  onInvest: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('CLOSED'), findsNWidgets(2));
      expect(find.text('OPEN'), findsOneWidget);
      expect(find.text('ACTIVE'), findsNothing);

      final depositButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Deposit'),
      );
      expect(depositButton.onPressed, isNull);

      final investButtons = tester
          .widgetList<FilledButton>(find.widgetWithText(FilledButton, 'Invest Now'))
          .toList();
      expect(investButtons[0].onPressed, isNull);
      expect(investButtons[1].onPressed, isNotNull);
    });

    testWidgets(
      'PammAvailableDetailView disables Deposit funds on Closed pool and shows Not joined when joinedOn is empty',
      (tester) async {
        final closedPool = PammPool(
          'Closed Pool',
          '2001',
          '—',
          10000,
          0,
          id: '10',
          status: 'Closed',
          hasPoolDetails: false,
        );
        final investment = PammInvestment(
          '2001',
          'Closed Pool',
          'Manager',
          1500,
          100,
          1400,
          15,
          id: '99',
          pammId: '10',
          joinedOn: '',
        );

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: PammAvailableDetailView(
                pool: closedPool,
                investment: investment,
                onBack: () {},
                onJoin: () {},
                onDeposit: (_) {},
                onWithdraw: (_) {},
                onOpenPoolTrades: () {},
              ),
            ),
          ),
        );

        expect(find.text('Closed'), findsWidgets);

        final depositButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Deposit funds'),
        );
        expect(depositButton.onPressed, isNull);

        await tester.scrollUntilVisible(
          find.text('Not joined'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Not joined'), findsOneWidget);
      },
    );
  });

  group('Deposit dialog', () {
    testWidgets(
      'validates INR minimum in USD equivalent, strips commas, validates proof, and locks while submitting',
      (tester) async {
        tester.view.physicalSize = const Size(900, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final submitCompleter = Completer<void>();
        var depositRequests = 0;

        AuthApi.instance.setHttpClientForTesting(
          MockClient.streaming((request, bodyStream) async {
            final path = request.url.path;
            if (path.endsWith('/get-usd-inr-rate/')) {
              return http.StreamedResponse(
                Stream.value(utf8.encode(jsonEncode({'rate': 83.5}))),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            if (path.endsWith('/profile/crypto-details/')) {
              return http.StreamedResponse(
                Stream.value(
                  utf8.encode(jsonEncode({'wallet_address': 'TRC20WALLET'})),
                ),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            if (path.endsWith('/profile/bank-details/')) {
              return http.StreamedResponse(
                Stream.value(
                  utf8.encode(
                    jsonEncode({
                      'bank_name': 'HDFC Bank',
                      'account_number': '12345678',
                    }),
                  ),
                ),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            if (path.endsWith('/pamm/deposit/')) {
              depositRequests++;
              await submitCompleter.future;
              return http.StreamedResponse(
                Stream.value(utf8.encode(jsonEncode({'success': true}))),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            return http.StreamedResponse(Stream.value(utf8.encode('{}')), 200);
          }),
        );

        XFile nextProof = XFile.fromData(
          Uint8List(0),
          name: 'empty.png',
        );

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showPammDepositDialog(
                    context,
                    accountName: 'Alpha Pool',
                    pammId: '42',
                    isManager: false,
                    onSuccess: () async {},
                    pickProofForTesting: () async => nextProof,
                  ),
                  child: const Text('Open Deposit'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Deposit'));
        await pumpAsync(tester);

        // Switch to MANUAL (INR default)
        await tester.tap(find.text('MANUAL'));
        await pumpAsync(tester);

        expect(find.textContaining('₹835.00 INR'), findsOneWidget);

        // 500 INR is below $10.00 USD at 83.5 -> should reject!
        await tester.enterText(find.byType(TextField), '500');
        await tester.tap(find.text('SUBMIT DEPOSIT'));
        await tester.pump();

        expect(find.textContaining('Minimum deposit is ₹835.00 INR'), findsOneWidget);
        expect(depositRequests, 0);

        // 1,000 INR (with comma) passes minimum and asks for proof
        await tester.enterText(find.byType(TextField), '1,000');
        await tester.tap(find.text('SUBMIT DEPOSIT'));
        await tester.pump();

        expect(find.text('Please upload your payment proof.'), findsOneWidget);

        // Empty proof bytes rejected
        await tester.tap(find.text('Choose transaction proof'));
        await tester.pumpAndSettle();
        expect(
          find.text('The selected payment proof file is empty. Please choose another image.'),
          findsOneWidget,
        );

        // Invalid extension rejected
        nextProof = XFile.fromData(
          Uint8List.fromList([1, 2, 3]),
          name: 'receipt.txt',
          path: 'receipt.txt',
          mimeType: 'text/plain',
        );
        await tester.tap(find.text('Choose transaction proof'));
        await tester.pumpAndSettle();
        expect(
          find.text('Unsupported file type. Upload a JPG, PNG, or WEBP image.'),
          findsOneWidget,
        );

        // Valid PNG proof
        nextProof = XFile.fromData(
          Uint8List.fromList([137, 80, 78, 71]),
          name: 'receipt.png',
          path: 'receipt.png',
          mimeType: 'image/png',
        );
        await tester.tap(find.text('Choose transaction proof'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('SUBMIT DEPOSIT'));
        await tester.pump();

        // Submitting state locks controls & shows spinner
        expect(find.text('SUBMITTING...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        final closeBtn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.close_rounded),
        );
        expect(closeBtn.onPressed, isNull);

        // PopScope blocks dismissal while submitting
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.text('SUBMITTING...'), findsOneWidget);

        submitCompleter.complete();
        await pumpAsync(tester);
        expect(depositRequests, 1);
        expect(find.text('SUBMITTING...'), findsNothing);
      },
    );

    testWidgets(
      '_selectPaymentMethod sequence guard prevents older async calls from overwriting newer selection',
      (tester) async {
        final bankCompleter = Completer<http.Response>();

        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            final path = request.url.path;
            if (path.endsWith('/get-usd-inr-rate/')) {
              return http.Response(jsonEncode({'rate': 83.5}), 200);
            }
            if (path.endsWith('/profile/crypto-details/')) {
              return http.Response(
                jsonEncode({'wallet_address': 'TRC20_KEEP_ME'}),
                200,
              );
            }
            if (path.endsWith('/profile/bank-details/')) {
              return bankCompleter.future;
            }
            return http.Response('{}', 200);
          }),
        );

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showPammDepositDialog(
                    context,
                    accountName: 'Alpha Pool',
                    pammId: '42',
                    isManager: false,
                    onSuccess: () async {},
                  ),
                  child: const Text('Open Deposit'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Deposit'));
        await pumpAsync(tester);

        // Tap MANUAL (starts slow bank request), then immediately tap USDT back
        await tester.tap(find.text('MANUAL'));
        await tester.pump();
        await tester.tap(find.text('USDT'));
        await tester.pump();

        // Older bank request fails later — should NOT clear USDT wallet instructions
        bankCompleter.complete(http.Response('Server error', 500));
        await pumpAsync(tester);

        expect(find.textContaining('TRC20_KEEP_ME'), findsOneWidget);
      },
    );
  });

  group('Withdrawal eligibility & dialog', () {
    test(
      'fetchPammWithdrawalEligibility returns explicit error on 5xx instead of false KYC rejection',
      () async {
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            if (request.url.path.endsWith('/profile/')) {
              return http.Response(
                jsonEncode({'detail': 'Internal server error'}),
                500,
                headers: {'content-type': 'application/json'},
              );
            }
            return http.Response('{}', 200);
          }),
        );

        final eligibility = await fetchPammWithdrawalEligibility();
        expect(eligibility.error, isNotNull);
        expect(
          eligibility.error,
          isNot(contains('identity and address verification')),
        );
      },
    );

    test(
      'fetchPammWithdrawalEligibility returns approved=false with null error on unverified KYC',
      () async {
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            final path = request.url.path;
            if (path.endsWith('/profile/')) {
              return http.Response(
                jsonEncode({'user_verified': false}),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            if (path.endsWith('/profile/documents/')) {
              return http.Response(
                jsonEncode({'documents': []}),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            return http.Response('{}', 200);
          }),
        );

        final eligibility = await fetchPammWithdrawalEligibility();
        expect(eligibility.error, isNull);
        expect(eligibility.approved, isFalse);
      },
    );

    testWidgets(
      'showPammWithdrawDialog shows explicit API error on 500, guards re-entrancy, and floors 100% preset',
      (tester) async {
        // 1. API failure shows explicit error, not KYC message
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            if (request.url.path.endsWith('/profile/')) {
              return http.Response('Internal Server Error', 500);
            }
            return http.Response('{}', 200);
          }),
        );

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showPammWithdrawDialog(
                    context,
                    accountName: 'Alpha Pool',
                    pammId: '42',
                    isManager: false,
                    availableBalance: 10.125,
                    onSuccess: () async {},
                  ),
                  child: const Text('Withdraw'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Withdraw'));
        await pumpAsync(tester);

        expect(
          find.textContaining('Unable to verify withdrawal eligibility'),
          findsOneWidget,
        );
        expect(
          find.textContaining('identity and address verification'),
          findsNothing,
        );

        // 2. Re-entrancy guard & 100% preset floor
        final profileCompleter = Completer<http.Response>();
        var profileCalls = 0;

        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            final path = request.url.path;
            if (path.endsWith('/profile/')) {
              profileCalls++;
              if (profileCalls == 1) {
                return profileCompleter.future;
              }
              return http.Response(jsonEncode({'user_verified': true}), 200);
            }
            if (path.endsWith('/profile/documents/')) {
              return http.Response(jsonEncode({'documents': []}), 200);
            }
            if (path.endsWith('/profile/crypto-details/')) {
              return http.Response(
                jsonEncode({'wallet_address': 'T999888777', 'currency': 'USDT'}),
                200,
              );
            }
            if (path.endsWith('/profile/bank-details/')) {
              return http.Response('{}', 404);
            }
            return http.Response('{}', 200);
          }),
        );

        // Rapid double tap before eligibility resolves
        await tester.tap(find.text('Withdraw'));
        await tester.tap(find.text('Withdraw'));
        await pumpAsync(tester, ticks: 2);
        expect(profileCalls, 1);

        profileCompleter.complete(
          http.Response(jsonEncode({'user_verified': true}), 200),
        );
        await pumpAsync(tester);

        expect(find.text('Withdraw funds'), findsOneWidget);

        // 100% of 10.125 must floor to 10.12 (never 10.13)
        await tester.tap(find.text('100%'));
        await tester.pump();
        final amountField = tester.widget<TextField>(find.byType(TextField));
        expect(amountField.controller?.text, '10.12');
      },
    );
  });

  group('Create/Join dialogs & PammPage navigation/search', () {
    testWidgets(
      'showCreatePammPoolDialog syncs dropdown with quick leverage chips and unwraps nested data',
      (tester) async {
        tester.view.physicalSize = const Size(900, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            if (request.url.path.endsWith('/pamm/create/')) {
              return http.Response(
                jsonEncode({
                  'data': {
                    'pamm': {
                      'name': 'Nested Pool',
                      'mt5_account_id': '990011',
                    },
                    'invest_password': 'Inv_999',
                  },
                }),
                200,
                headers: {'content-type': 'application/json'},
              );
            }
            return http.Response('{}', 200);
          }),
        );

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showCreatePammPoolDialog(
                    context,
                    onPoolCreated: () async {},
                  ),
                  child: const Text('Create Pool'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Create Pool'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('1:200'));
        await tester.pump();

        final dropdown = tester.widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        );
        expect(dropdown.initialValue, '1:200');

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter PAMM account name'),
          'Nested Pool',
        );
        await tester.tap(find.text('Create account'));
        await pumpAsync(tester);

        expect(find.text('PAMM manager account created'), findsOneWidget);
        expect(find.text('990011'), findsOneWidget);
        expect(find.text('Inv_999'), findsOneWidget);
      },
    );

    testWidgets(
      'PammInvestmentsTabView omits redundant PammSnapshotCard and searches login case-insensitively',
      (tester) async {
        final controller = TextEditingController(text: 'abc');
        addTearDown(controller.dispose);

        final investments = [
          PammInvestment('AbC990', 'Alpha', 'Mgr', 1000, 50, 950, 10),
          PammInvestment('XYZ111', 'Beta', 'Mgr', 2000, -50, 2050, 20),
        ];

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: PammInvestmentsTabView(
                investments: investments,
                loading: false,
                query: 'abc',
                selectedFilter: 'All Investments',
                searchController: controller,
                onQueryChanged: (_) {},
                onClearQuery: () {},
                onSelectFilter: (_) {},
                onOpenDetails: (_) {},
                onDeposit: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(PammSnapshotCard), findsNothing);
        expect(find.text('Alpha'), findsOneWidget);
        expect(find.text('Beta'), findsNothing);
      },
    );

    testWidgets(
      'showJoinPammInvestmentDialog unwraps nested data and locks dismissal while joining',
      (tester) async {
        tester.view.physicalSize = const Size(900, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final joinCompleter = Completer<http.Response>();
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            if (request.url.path.endsWith('/pamm/invest/')) {
              return joinCompleter.future;
            }
            return http.Response('{}', 200);
          }),
        );

        final pool = PammPool('Join Pool', '3001', '1:500', 40000, 20, id: '12');

        await tester.pumpWidget(
          wrap(
            Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showJoinPammInvestmentDialog(
                    context,
                    pool: pool,
                    onJoined: () async {},
                  ),
                  child: const Text('Join Pool Btn'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Join Pool Btn'));
        await pumpAsync(tester);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'e.g. My PAMM Investment'),
          'My Alias',
        );
        await tester.tap(find.text('Confirm Investment'));
        await tester.pump();

        expect(find.text('Joining…'), findsOneWidget);
        final closeBtn = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.close),
        );
        expect(closeBtn.onPressed, isNull);

        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.text('Joining…'), findsOneWidget);

        joinCompleter.complete(
          http.Response(
            jsonEncode({
              'data': {
                'pamm_name': 'Join Pool',
                'mt5_account_id': '555666',
                'invest_password': 'Inv_555',
              },
            }),
            200,
          ),
        );
        await pumpAsync(tester);

        expect(find.text('PAMM investment account created'), findsOneWidget);
        expect(find.text('555666'), findsOneWidget);
        expect(find.text('Inv_555'), findsOneWidget);
      },
    );

    testWidgets(
      'PammPage popSubView closes detail view and _syncPammEquity does not reopen it',
      (tester) async {
        tester.view.physicalSize = const Size(900, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final syncCompleter = Completer<http.Response>();
        AuthApi.instance.setHttpClientForTesting(
          MockClient((request) async {
            final path = request.url.path;
            if (path.endsWith('/pamm/managed/')) {
              return http.Response(
                jsonEncode({
                  'results': [
                    {
                      'id': 1,
                      'name': 'Alpha Managed',
                      'mt5_account_id': '7001',
                      'leverage': 500,
                      'total_equity': 5000,
                      'manager_balance': 2000,
                      'profit_share': 20,
                      'status': 'open',
                    },
                  ],
                }),
                200,
              );
            }
            if (path.endsWith('/sync-equity/')) {
              return syncCompleter.future;
            }
            return http.Response(jsonEncode({'results': []}), 200);
          }),
        );

        final pammKey = GlobalKey<PammPageState>();
        await tester.pumpWidget(wrap(PammPage(key: pammKey)));
        await pumpAsync(tester);

        await tester.scrollUntilVisible(
          find.text('Details'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Details'));
        await pumpAsync(tester);
        expect(pammKey.currentState!.hasActiveSubView, isTrue);

        // Start Sync MT5, then immediately popSubView before sync finishes
        await tester.tap(find.text('Sync MT5'));
        await tester.pump();
        expect(pammKey.currentState!.popSubView(), isTrue);
        await tester.pump();
        expect(pammKey.currentState!.hasActiveSubView, isFalse);

        syncCompleter.complete(http.Response(jsonEncode({'ok': true}), 200));
        await pumpAsync(tester);

        // Detail view stays closed!
        expect(pammKey.currentState!.hasActiveSubView, isFalse);
        expect(find.text('Managed PAMM Pools'), findsOneWidget);
      },
    );
  });
}
