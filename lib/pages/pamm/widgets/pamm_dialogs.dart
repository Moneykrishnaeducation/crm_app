import 'package:crm_app/pages/pamm/models/pamm_models.dart';
import 'package:flutter/material.dart';

export 'package:crm_app/pages/pamm/widgets/dialogs/pamm_create_pool_dialog.dart';
export 'package:crm_app/pages/pamm/widgets/dialogs/pamm_deposit_dialog.dart';
export 'package:crm_app/pages/pamm/widgets/dialogs/pamm_join_dialog.dart';
export 'package:crm_app/pages/pamm/widgets/dialogs/pamm_withdraw_dialog.dart';

Future<void> showPammCreatedCredentialsDialog(
  BuildContext context, {
  required String title,
  required String accountName,
  required String login,
  required String investorPassword,
  String? masterPassword,
}) async {
  if (!context.mounted) return;
  final muted = PammColors.muted(context);

  Widget credentialLine(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: muted, fontSize: 11)),
                  SelectableText(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Copy $label',
              onPressed: () => copyPammValue(context, value),
              icon: const Icon(Icons.copy_outlined, size: 17),
            ),
          ],
        ),
      );

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(accountName, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          credentialLine('MT5 login', login),
          if (masterPassword != null)
            credentialLine('Master password', masterPassword),
          credentialLine('Investor password', investorPassword),
          const SizedBox(height: 8),
          Text(
            'Save these credentials securely. You may not be able to view them again.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
