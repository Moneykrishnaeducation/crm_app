import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
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

    // Verify Personal Details card structure and header
    expect(find.text('Full Legal Name'), findsOneWidget);
    expect(find.text('Edit Details'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Residential Address'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Tax Residency'), findsOneWidget);

    // Switch to Verification Tab
    await tester.tap(find.text('Verification'));
    await tester.pumpAndSettle();

    // Verify Header Section
    expect(find.text('Verification Documents'), findsOneWidget);
    expect(
      find.textContaining('View, upload or update your identity and address documents.'),
      findsOneWidget,
    );

    // Verify Card 1: Identity Verification
    expect(find.text('Identity Verification'), findsWidgets);
    expect(find.text('IDENTITY PROOF'), findsOneWidget);
    expect(find.text('Aadhaar, PAN, passport or driving licence'), findsOneWidget);

    // Verify Card 2: Address Verification
    expect(find.text('Address Verification'), findsWidgets);
    expect(find.text('ADDRESS PROOF'), findsOneWidget);
    expect(find.text('Bank statement or utility bill'), findsOneWidget);

    // Verify Common Badges and Rows across both cards
    expect(find.text('Approved'), findsNWidgets(2));
    expect(find.text('Document file'), findsNWidgets(2));
    expect(find.text('Verification complete'), findsNWidgets(2));
    expect(find.text('Your document has been approved.'), findsNWidgets(2));
    expect(find.text('View document'), findsNWidgets(2));

    // Verify Security / Privacy Footer Card
    expect(find.text('Your documents stay protected.'), findsOneWidget);
    expect(
      find.textContaining('You must verify your CRM password before viewing a document.'),
      findsOneWidget,
    );
    expect(find.text('Secure document access'), findsOneWidget);

    // Scroll down to bring Verification Card into view
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    // Test Interactive "View document" Bottom Sheet
    await tester.tap(find.text('View document').first);
    await tester.pumpAndSettle();

    // Verify Document Viewer Sheet elements
    expect(find.text('CRM Password Authentication'), findsOneWidget);
    expect(find.text('Document Details & Metadata'), findsOneWidget);
    expect(find.text('AI Matching Score'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    // Close the document viewer modal via top close icon or Close button
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();
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

  testWidgets('BrokerProfilePage Personal Details tab renders cleanly without overflow on narrow screens (320px)', (tester) async {
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

    // Switch to Personal Details Tab
    await tester.tap(find.text('Personal Details'));
    await tester.pumpAndSettle();

    expect(find.text('Full Legal Name'), findsOneWidget);
    expect(find.text('Edit Details'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Residential Address'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Tax Residency'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BrokerProfilePage Payment Methods works on narrow screens and Security tab is not in profile', (tester) async {
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

    final paymentMethodsTab = find.text('Payment Methods').first;
    await tester.ensureVisible(paymentMethodsTab);
    await tester.tap(paymentMethodsTab);
    await tester.pumpAndSettle();
    expect(find.text('Add, manage or update your payment destinations.'), findsOneWidget);
    expect(find.text('NONE BANK'), findsOneWidget);
    expect(find.text('789456123456'), findsOneWidget);
    expect(find.text('IDIB000R101D'), findsOneWidget);
    expect(find.text('Kallakurichi'), findsOneWidget);
    expect(find.text('UNANG'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Verify Security tab is NOT present on profile page
    expect(find.text('Security'), findsNothing);
  });

  testWidgets('BrokerProfilePage Verification tab renders cleanly without overflow on narrow screens (320px)', (tester) async {
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

    // Tap Verification Tab
    final verificationTab = find.text('Verification').first;
    await tester.ensureVisible(verificationTab);
    await tester.tap(verificationTab);
    await tester.pumpAndSettle();

    expect(find.text('Verification Documents'), findsOneWidget);
    expect(find.text('IDENTITY PROOF'), findsOneWidget);
    expect(find.text('ADDRESS PROOF'), findsOneWidget);
    expect(find.text('Secure document access'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BrokerProfilePage Payment Methods tab renders cards, fields, and interactive modals correctly', (tester) async {
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

    // Tap Payment Methods tab
    final paymentMethodsTab = find.text('Payment Methods').first;
    await tester.ensureVisible(paymentMethodsTab);
    await tester.tap(paymentMethodsTab);
    await tester.pumpAndSettle();

    // Verify Header Section
    expect(find.text('Payment Methods'), findsWidgets);
    expect(find.text('Add, manage or update your payment destinations.'), findsOneWidget);

    // Verify Card 1: Bank Account
    expect(find.text('Bank Account'), findsOneWidget);
    expect(find.text('For bank-based withdrawals and eligible payouts.'), findsOneWidget);
    expect(find.text('Bank name'), findsOneWidget);
    expect(find.text('NONE BANK'), findsOneWidget);
    expect(find.text('Account number'), findsOneWidget);
    expect(find.text('789456123456'), findsOneWidget);
    expect(find.text('IFSC code'), findsOneWidget);
    expect(find.text('IDIB000R101D'), findsOneWidget);
    expect(find.text('Branch name'), findsOneWidget);
    expect(find.text('Kallakurichi'), findsOneWidget);

    // Verify Card 2: Crypto Wallet
    expect(find.text('Crypto Wallet'), findsOneWidget);
    expect(find.text('Manage a supported digital asset destination.'), findsOneWidget);
    expect(find.text('Wallet address'), findsOneWidget);
    expect(find.text('123456789asdfghjklrgq094i50i3i45kjdfjweir099iwe9f'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('UNANG'), findsOneWidget);

    // Verify Both Cards have Connected badges and action buttons
    expect(find.text('Connected'), findsNWidgets(2));
    expect(find.text('View Details'), findsNWidgets(2));
    expect(find.text('Edit Details'), findsNWidgets(2));

    // Verify Security Footer
    expect(find.text('Keep your destinations up to date.'), findsOneWidget);

    // Test 1: Open View Details modal for Bank Account
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();
    expect(find.text('Bank Account Details'), findsOneWidget);
    expect(find.text('Beneficiary Name'), findsOneWidget);
    expect(find.text('INR-DEVOP B'), findsOneWidget);
    expect(find.text('Branch Name'), findsOneWidget);
    expect(find.text('Kallakurichi'), findsWidgets);
    expect(find.text('Routing Channel'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Test 2: Open Edit Details modal for Bank Account and update details
    await tester.tap(find.text('Edit Details').first);
    await tester.pumpAndSettle();
    expect(find.text('Bank Details'), findsWidgets);
    expect(find.text('Bank account information'), findsOneWidget);
    expect(find.text('Branch name'), findsWidgets);
    expect(find.widgetWithText(TextField, 'Kallakurichi'), findsOneWidget);

    // Enter new bank name and branch
    final bankNameField = find.widgetWithText(TextField, 'NONE BANK');
    await tester.enterText(bankNameField, 'FEDERAL BANK');
    final branchField = find.widgetWithText(TextField, 'Kallakurichi');
    await tester.enterText(branchField, 'Salem Branch');
    final saveBtn = find.text('Save bank details');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify instant state synchronization
    expect(find.text('FEDERAL BANK'), findsOneWidget);
    expect(find.text('Salem Branch'), findsOneWidget);
    expect(find.text('Bank details updated successfully'), findsOneWidget);

    // Scroll to bring Crypto Wallet card and its buttons into view if needed
    await tester.drag(find.byType(ListView).first, const Offset(0, -450));
    await tester.pumpAndSettle();

    // Test 3: Open View Details modal for Crypto Wallet
    await tester.tap(find.text('View Details').last);
    await tester.pumpAndSettle();
    expect(find.text('Crypto Wallet Details'), findsOneWidget);
    expect(find.text('Whitelist Status'), findsOneWidget);
    expect(find.text('Settlement Speed'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Test 4: Open Edit Details modal for Crypto Wallet and update currency
    await tester.tap(find.text('Edit Details').last);
    await tester.pumpAndSettle();
    expect(find.text('Edit Crypto Wallet'), findsOneWidget);

    final currencyField = find.widgetWithText(TextField, 'UNANG');
    await tester.enterText(currencyField, 'USDT');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();

    // Verify instant state synchronization
    expect(find.text('USDT'), findsOneWidget);
    expect(find.text('Crypto wallet updated successfully'), findsOneWidget);

    // Test 5: Ellipsis popup menu action
    await tester.drag(find.byType(ListView).first, const Offset(0, 450));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(LucideIcons.ellipsis).first);
    await tester.pumpAndSettle();
    expect(find.text('Set as primary'), findsOneWidget);
    await tester.tap(find.text('Set as primary'));
    await tester.pumpAndSettle();
    expect(find.text('Bank Account set as primary payout destination'), findsOneWidget);
  });

  testWidgets('BrokerProfilePage header has Tier 3 badge and strictly 4 tabs without Security', (tester) async {
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

    // Verify top header
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Account settings, verification & preferences'), findsOneWidget);
    expect(find.text('Tier 3'), findsOneWidget);

    // Verify exactly the 4 tabs exist and Security does not exist
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.text('Verification'), findsOneWidget);
    expect(find.text('Payment Methods'), findsWidgets);
    expect(find.text('Security'), findsNothing);
  });
}
