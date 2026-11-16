import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crm_app/main.dart';

void main() {
  testWidgets('LogoutBottomSheet renders correctly and handles actions', (tester) async {
    bool confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (sheetContext) => LogoutBottomSheet(
                    onConfirm: () {
                      confirmed = true;
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                );
              },
              child: const Text('Open Sheet'),
            ),
          ),
        ),
      ),
    );

    // Open bottom sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify elements
    expect(find.text('Log Out'), findsNWidgets(2)); // Title and Confirm Button
    expect(
      find.text('Are you sure you want to log out of your account? You will need to enter your credentials to sign back in.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Verify sheet dismissed
    expect(find.byType(LogoutBottomSheet), findsNothing);
    expect(confirmed, isFalse);

    // Open sheet again
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Tap confirm (FilledButton with 'Log Out')
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    // Verify confirm callback fired and sheet dismissed
    expect(confirmed, isTrue);
    expect(find.byType(LogoutBottomSheet), findsNothing);
  });
}
