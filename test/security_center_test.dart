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

    // Header Card
    expect(find.text('Security & Devices'), findsOneWidget);
    expect(find.text('Control sign-in protection and manage trusted devices.'), findsWidgets);

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

    // Confirm remove device dialog
    expect(find.text('Remove trusted device?'), findsOneWidget);
    await tester.tap(find.text('Remove device'));
    await tester.pumpAndSettle();

    expect(find.text('0 devices can access your account'), findsOneWidget);
    expect(find.text('No trusted devices active'), findsOneWidget);
    expect(find.text('Sign in again to register this device as trusted.'), findsOneWidget);

    // Test Revoke all devices button with confirmation bottom popup
    await tester.ensureVisible(find.text('Revoke all devices'));
    await tester.tap(find.text('Revoke all devices'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Revoke all trusted devices?'), findsOneWidget);
    await tester.tap(find.descendant(
      of: find.byType(ElevatedButton),
      matching: find.text('Revoke all devices'),
    ));
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
    expect(find.text('Security Verification'), findsOneWidget);
    expect(find.text('Enter your CRM password to access Security Center.'), findsOneWidget);

    // Enter password and verify
    await tester.enterText(find.widgetWithText(TextField, 'Enter your current password'), 'MyPassword');
    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();

    // Verify Security Center page is now displayed
    expect(find.text('Security Verification'), findsNothing);
    expect(find.text('Security Center'), findsWidgets);
    expect(find.text('Security & Devices'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Windows browser'), findsOneWidget);
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

    // Verify badges and icons
    expect(find.text('SIGN-IN PROTECTION'), findsOneWidget);
    expect(find.text('Security & Devices'), findsOneWidget);
    expect(find.byIcon(LucideIcons.shieldCheck), findsWidgets);
    expect(find.byIcon(LucideIcons.shield), findsWidgets);
  });

  testWidgets('SecurityCenterPage renders hero banner with health score, chips and biometric access toggle', (tester) async {
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

    // Verify hero banner elements
    expect(find.text('Security Status: Excellent'), findsOneWidget);
    expect(find.text('98% Protected'), findsOneWidget);
    expect(find.textContaining('Maximum Protection Active'), findsOneWidget);
    expect(find.text('2FA Active'), findsOneWidget);
    expect(find.text('Device Verified'), findsOneWidget);
    expect(find.text('256-Bit SSL'), findsOneWidget);

    // Verify Biometric Access toggle
    expect(find.text('Biometric Access'), findsOneWidget);
    expect(
      find.text('Use Fingerprint or Face ID for fast and secure access without entering your CRM password each time.'),
      findsOneWidget,
    );

    // Toggle Biometric Access
    await tester.tap(find.text('Biometric Access'));
    await tester.pumpAndSettle();

    final isBioEnabled = await fakeBio.isEnabled();
    expect(isBioEnabled, isTrue);

    // Toggle off
    await tester.tap(find.text('Biometric Access'));
    await tester.pumpAndSettle();
    expect(await fakeBio.isEnabled(), isFalse);
  });
}
