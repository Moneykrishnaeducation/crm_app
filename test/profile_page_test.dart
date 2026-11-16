import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/pages/profile_page.dart';

void main() {
  testWidgets('BrokerProfilePage renders hero banner, tabs, and overview cards correctly', (tester) async {
    bool backPressed = false;
    String? selectedPage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrokerProfilePage(
            onBack: () => backPressed = true,
            onSelectPage: (p) => selectedPage = p,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(selectedPage, isNull);

    // Verify Avatar initial and Name (found in Hero and in Personal Info)
    expect(find.text('I'), findsOneWidget);
    expect(find.text('INR-DEVOP B'), findsWidgets);
    expect(find.text('Verified'), findsWidgets);
    expect(find.text('Client   VT Index'), findsOneWidget);

    // Verify contact chips
    expect(find.text('iyyanar@vtindex.com'), findsWidgets);
    expect(find.text('7894561235'), findsWidgets);
    expect(find.text('kattu edaiyar, india'), findsOneWidget);

    // Verify Banner button
    expect(find.text('Change banner'), findsOneWidget);

    // Verify Tabs
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.text('Verification'), findsOneWidget);

    // 1. Profile Completion Card
    expect(find.text('Profile Completion'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('100% COMPLETE'), findsOneWidget);
    expect(find.text('Profile Completed'), findsOneWidget);

    // 2. Account Status Card
    expect(find.text('Account Status'), findsOneWidget);
    expect(find.text('Verified Account'), findsOneWidget);
    expect(find.text('All verifications completed'), findsOneWidget);

    // 3. Quick Actions Card
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Upload Documents'), findsOneWidget);
    expect(find.text('Bank Details'), findsOneWidget);
    expect(find.text('Crypto Wallet'), findsWidgets); // Quick action & payment method

    // 4. Personal Information Card
    expect(find.text('Personal Information'), findsWidgets); // Checklist & Card header
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Date of birth'), findsOneWidget);
    expect(find.text('24 Aug 2003'), findsOneWidget);
    expect(find.text('No 3 south street kattu edaiyar villupuram, kattu edaiyar, tamil nadu, india, 605751'), findsWidgets);

    // 5. Identity Verification Card
    expect(find.text('Identity Verification'), findsWidgets); // Checklist & Card header
    expect(find.text('View all'), findsOneWidget);
    expect(find.text('Identity Proof'), findsOneWidget);
    expect(find.text('Address Proof'), findsOneWidget);

    // 6. Payment Methods Card
    expect(find.text('Payment Methods'), findsWidgets); // Checklist & Card header
    expect(find.text('Manage'), findsOneWidget);
    expect(find.text('Bank Account'), findsOneWidget);
    expect(find.text('****3456'), findsOneWidget);
    expect(find.text('UNANG · 123456789asd'), findsOneWidget);

    // 7. Promo / Platform Journey Card
    expect(find.text('Your Journey with VT Index'), findsOneWidget);
    expect(find.text('Explore platform'), findsOneWidget);

    // Test Quick action: Bank details bottom sheet
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bank Details'));
    await tester.pumpAndSettle();
    expect(find.text('Bank Account Details'), findsOneWidget);
    expect(find.text('State Bank of India (SBI)'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Scroll down to test explore platform action
    await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore platform'));
    await tester.pumpAndSettle();
    expect(selectedPage, equals('Trading Accounts'));

    // Scroll back to top for navigation and tabs
    await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(backPressed, isTrue);

    // Switch to Personal Details Tab
    await tester.tap(find.text('Personal Details'));
    await tester.pumpAndSettle();

    expect(find.text('Full Legal Name'), findsOneWidget);
    expect(find.text('Edit Details'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Residential Address'), findsOneWidget);

    // Switch to Verification Tab
    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();

    expect(find.text('KYC Level 3: Verified'), findsOneWidget);
    expect(find.text('Identity Document'), findsOneWidget);
    expect(find.text('Proof of Residence'), findsOneWidget);
    expect(find.text('Bank Account & Settlement'), findsOneWidget);
  });

  testWidgets('BrokerProfilePage renders cleanly on narrow screens (320px) without overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrokerProfilePage(
            onBack: () {},
            onSelectPage: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 7 card headers are present and rendered on narrow screens
    expect(find.text('Profile Completion'), findsOneWidget);
    expect(find.text('Account Status'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Personal Information'), findsWidgets);
    expect(find.text('Identity Verification'), findsWidgets);
    expect(find.text('Payment Methods'), findsWidgets);
    expect(find.text('Your Journey with VT Index'), findsOneWidget);
  });

  testWidgets('BrokerProfilePage renders cleanly on tablet/desktop screens (1024px)', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrokerProfilePage(
            onBack: () {},
            onSelectPage: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profile Completion'), findsOneWidget);
    expect(find.text('Account Status'), findsOneWidget);
    expect(find.text('Your Journey with VT Index'), findsOneWidget);
  });
}
