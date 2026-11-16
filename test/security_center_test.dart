import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:crm_app/main.dart';
import 'package:crm_app/pages/security_center_page.dart';

void main() {
  testWidgets('VerifySecurityPasswordModal renders correctly, toggles obscure text, and validates', (tester) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                dialogResult = await showSecurityPasswordModal(context);
              },
              child: const Text('Open Modal'),
            ),
          ),
        ),
      ),
    );

    // 1. Open modal and test dismiss via X
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();

    expect(find.text("Verify it's you"), findsOneWidget);
    expect(find.text('Enter your CRM password to open the Security & Devices tab.'), findsOneWidget);
    expect(find.text('CRM password'), findsOneWidget);
    expect(find.text('Your password is checked securely and is not stored.'), findsOneWidget);
    expect(find.text('Verify password →'), findsOneWidget);

    // Toggle password visibility
    expect(find.byIcon(LucideIcons.eye), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.eye));
    await tester.pumpAndSettle();
    expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);

    // Dismiss with X
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();
    expect(find.text("Verify it's you"), findsNothing);
    expect(dialogResult, isFalse);

    // 2. Open modal and verify with password
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();
    expect(find.text("Verify it's you"), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Enter your current password'), 'Secret123');
    await tester.tap(find.text('Verify password →'));
    await tester.pumpAndSettle();

    expect(find.text("Verify it's you"), findsNothing);
    expect(dialogResult, isTrue);
  });

  testWidgets('SecurityCenterPage renders header, cards, stats, and handles toggles and device actions', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool backPressed = false;
    String? selectedPage;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecurityCenterPage(
            onBack: () => backPressed = true,
            onSelectPage: (p) => selectedPage = p,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(selectedPage, isNull);

    // Top Navigation
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Security Center'), findsOneWidget);
    expect(find.text('Protected'), findsOneWidget);

    await tester.tap(find.text('Back'));
    expect(backPressed, isTrue);

    // Header Card
    expect(find.text('Security & Devices'), findsOneWidget);
    expect(find.text('Control sign-in protection and manage trusted devices.'), findsWidgets);
    expect(find.text('Refresh devices'), findsOneWidget);

    // Test Refresh devices button
    await tester.tap(find.text('Refresh devices'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Devices refreshed'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Sign-In Protection Card
    expect(find.text('SIGN-IN PROTECTION'), findsOneWidget);
    expect(find.text('Your account, your devices'), findsOneWidget);
    expect(find.text('New browsers verify with an email one-time code before becoming trusted.'), findsOneWidget);
    expect(find.text('TRUSTED DEVICES'), findsOneWidget);
    expect(find.text('Active trusted device'), findsOneWidget);
    expect(find.text('EXPIRED SESSIONS'), findsOneWidget);
    expect(find.text('No longer trusted after 7 days'), findsOneWidget);

    // Scroll down to toggles
    await tester.drag(find.byType(ListView).first, const Offset(0, -250));
    await tester.pumpAndSettle();

    // Toggles
    expect(find.text('Login CAPTCHA'), findsOneWidget);
    expect(find.text('Email two-factor verification'), findsOneWidget);
    expect(find.text('Enabled'), findsNWidgets(2));

    // Toggle Login CAPTCHA
    await tester.tap(find.text('Login CAPTCHA'));
    await tester.pumpAndSettle();

    // Toggle Email two-factor
    await tester.tap(find.text('Email two-factor verification'));
    await tester.pumpAndSettle();

    // Trusted Devices Section Header
    expect(find.text('Trusted devices'), findsOneWidget);
    expect(find.text('1 device can access your account'), findsOneWidget);
    expect(find.text('Protection active'), findsOneWidget);

    // Scroll to Active Trusted Device Card
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();

    // Active Trusted Device Card
    expect(find.text('TRUSTED DEVICE'), findsOneWidget);
    expect(find.text('This device'), findsOneWidget);
    expect(find.text('Windows browser'), findsOneWidget);
    expect(find.text('Windows'), findsOneWidget);
    expect(find.text('104.22.224.94'), findsNWidgets(2));
    expect(find.text('16/11/2026, 9:17:26 am'), findsOneWidget);
    expect(find.textContaining('Mozilla/5.0'), findsOneWidget);

    // Test Remove trust action
    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Remove trust'), findsOneWidget);
    await tester.tap(find.text('Remove trust'));
    await tester.pumpAndSettle();

    expect(find.text('0 devices can access your account'), findsOneWidget);
    expect(find.text('No trusted devices active. Sign in again to register a trusted device.'), findsOneWidget);

    // Test Revoke all devices button
    await tester.ensureVisible(find.text('Revoke all devices'));
    await tester.tap(find.text('Revoke all devices'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('0 devices can access your account'), findsOneWidget);
  });

  testWidgets('AppShell navigates to Security Center after password verification', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AppShell(),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to 'More' page
    final moreNav = find.text('More');
    expect(moreNav, findsOneWidget);
    await tester.tap(moreNav);
    await tester.pumpAndSettle();

    // Find and tap Security Center menu item
    final securityCenterRow = find.text('Security Center');
    expect(securityCenterRow, findsOneWidget);
    await tester.tap(securityCenterRow);
    await tester.pumpAndSettle();

    // Verify Password Popup appears
    expect(find.text("Verify it's you"), findsOneWidget);
    expect(find.text('Enter your CRM password to open the Security & Devices tab.'), findsOneWidget);

    // Enter password and verify
    await tester.enterText(find.widgetWithText(TextField, 'Enter your current password'), 'MyPassword');
    await tester.tap(find.text('Verify password →'));
    await tester.pumpAndSettle();

    // Verify Security Center page is now displayed
    expect(find.text("Verify it's you"), findsNothing);
    expect(find.text('Security Center'), findsWidgets);
    expect(find.text('Security & Devices'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Windows browser'), findsOneWidget);
  });
}
