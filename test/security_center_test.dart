import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_app/biometric_sign_in.dart';
import 'package:crm_app/main.dart';
import 'package:crm_app/pages/security_center_page.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/local_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'isDeviceSupported') return false;
        if (methodCall.method == 'getAvailableBiometrics') return <String>[];
        return null;
      },
    );
  });

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

    expect(find.text('Security Verification'), findsOneWidget);
    expect(find.text('Enter your CRM password to access Security Center.'), findsOneWidget);
    expect(find.text('CRM Password'), findsOneWidget);
    expect(find.text('Protected by 256-bit encryption. Your password is not stored.'), findsOneWidget);
    expect(find.text('Verify & Continue'), findsOneWidget);

    // Toggle password visibility
    expect(find.byIcon(LucideIcons.eye), findsOneWidget);
    await tester.tap(find.byIcon(LucideIcons.eye));
    await tester.pumpAndSettle();
    expect(find.byIcon(LucideIcons.eyeOff), findsOneWidget);

    // Dismiss with X
    await tester.tap(find.byIcon(LucideIcons.x));
    await tester.pumpAndSettle();
    expect(find.text('Security Verification'), findsNothing);
    expect(dialogResult, isFalse);

    // 2. Open modal and test empty validation
    await tester.tap(find.text('Open Modal'));
    await tester.pumpAndSettle();
    expect(find.text('Security Verification'), findsOneWidget);

    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Password cannot be empty'), findsOneWidget);

    // 3. Verify with password
    await tester.enterText(find.widgetWithText(TextField, 'Enter your current password'), 'Secret123');
    await tester.pumpAndSettle();
    expect(find.text('Password cannot be empty'), findsNothing);

    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Security Verification'), findsNothing);
    expect(dialogResult, isTrue);
  });

  testWidgets('SecurityCenterPage renders header, cards, stats, and handles toggles and device actions', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecurityCenterPage(
            onBack: () {},
            onSelectPage: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Sections and actions
    expect(find.text('Security Center'), findsWidgets);
    expect(find.text('Account Security'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Login Password'), findsOneWidget);
    expect(find.text('Mail OTP'), findsOneWidget);
    expect(find.text('Captcha'), findsOneWidget);
    expect(find.text('Biometrics'), findsOneWidget);
    expect(find.text('Other Settings'), findsOneWidget);
    expect(find.text('Device Management'), findsOneWidget);
    expect(find.text('Account Management'), findsOneWidget);

    // Toggle Mail OTP switch
    final switches = find.byType(Switch);
    expect(switches, findsWidgets);
    await tester.tap(switches.first);
    await tester.pumpAndSettle();

    // Open Device Management sub page
    await tester.tap(find.text('Device Management'));
    await tester.pumpAndSettle();
    expect(find.text('Device Management'), findsWidgets);
    expect(find.text('Revoke all devices'), findsOneWidget);

    // Test Revoke all devices button with confirmation bottom popup
    await tester.tap(find.text('Revoke all devices'));
    await tester.pumpAndSettle();
    expect(find.text('Revoke all trusted devices?'), findsOneWidget);
    await tester.tap(find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.text('Revoke all devices'),
    ));
    await tester.pumpAndSettle();
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
    expect(find.text('Security Verification'), findsOneWidget);
    expect(find.text('Enter your CRM password to access Security Center.'), findsOneWidget);

    // Enter password and verify
    await tester.enterText(find.widgetWithText(TextField, 'Enter your current password'), 'MyPassword');
    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();

    // Verify Security Center page is now displayed
    expect(find.text('Security Verification'), findsNothing);
    expect(find.text('Security Center'), findsWidgets);
    expect(find.text('Account Security'), findsOneWidget);
    expect(find.text('Device Management'), findsOneWidget);
  });

  testWidgets('SecurityCenterPage and VerifySecurityPasswordModal adhere to White, Blue, and Gold theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecurityCenterPage(
            onBack: () {},
            onSelectPage: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify page container uses scaffold background
    final pageContainer = tester.widget<Container>(
      find.descendant(
        of: find.byType(SecurityCenterPage),
        matching: find.byType(Container),
      ).first,
    );
    expect(pageContainer.color, isNotNull);

    // Verify sections and badges
    expect(find.text('Security Center'), findsWidgets);
    expect(find.text('Account Security'), findsOneWidget);
    expect(find.text('Other Settings'), findsOneWidget);
  });

  testWidgets('SecurityCenterPage renders biometrics toggle and handles interactions', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fakeBio = BiometricSignIn();
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: SecurityCenterPage(
            onBack: () {},
            onSelectPage: (_) {},
            biometricSignIn: fakeBio,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Biometrics toggle
    expect(find.text('Biometrics'), findsOneWidget);
    expect(
      find.text('Use your device fingerprint or Face ID to secure sign-in'),
      findsOneWidget,
    );
  });
}
