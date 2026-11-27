import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app_notifications.dart';
import '../../../services/auth_api.dart';
import '../models/partnership_models.dart';
import 'account_detail_sheet.dart';
import 'partnership_theme.dart';
import 'vtindex_qr_view.dart';

export 'account_detail_sheet.dart';
export 'client_accounts_sheet.dart';
export 'client_registration_dialog.dart';

/// Opens the native platform share sheet for a partner referral link.
Future<void> shareReferralLink(
  BuildContext context, {
  required String url,
  String? profileName,
}) async {
  AppHaptics.lightImpact();
  final box = context.findRenderObject() as RenderBox?;
  final shareOrigin =
      box != null ? box.localToGlobal(Offset.zero) & box.size : null;
  final title = profileName != null && profileName.trim().isNotEmpty
      ? 'VT Index Partner Referral — ${profileName.trim()}'
      : 'VT Index Partner Referral';
  try {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Join my VT Index partner network: $url',
        subject: title,
        sharePositionOrigin: shareOrigin,
      ),
    );
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: url));
    showAppMessage(
      'Unable to open share sheet. Referral link copied instead.',
      type: AppFeedbackType.info,
    );
  }
}

// ============================================================================
// MODALS & DIALOGS
// ============================================================================

void showAccountDetailModal(
  BuildContext context,
  IbTradingAccount account, {
  String? clientName,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colors = PartnershipColors.of(sheetContext);
      return AccountDetailSheet(account: account, clientName: clientName, colors: colors);
    },
  );
}

void showConfirmIbModal(
  BuildContext context,
  IbClient client, {
  VoidCallback? onIbChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final colors = PartnershipColors.of(dialogContext);
      var submitting = false;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colors.border),
            ),
            contentPadding: const EdgeInsets.all(22),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(LucideIcons.shieldCheck, color: colors.blue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirm IB Request',
                            style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Nominate client for IB status',
                            style: TextStyle(color: colors.muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.subCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.subBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client: ${client.name}',
                        style: TextStyle(color: colors.text, fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      if (client.email.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Email: ${client.email}',
                            style: TextStyle(color: colors.muted, fontSize: 12),
                          ),
                        ),
                      if (client.referralCode.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Code: ${client.referralCode}',
                            style: TextStyle(color: colors.muted, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'The request will be sent to the admin team for review. IB status remains pending until approved.',
                  style: TextStyle(color: colors.muted, fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: submitting
                          ? null
                          : () {
                              AppHaptics.selectionClick();
                              Navigator.pop(dialogContext);
                            },
                      child: Text('Cancel', style: TextStyle(color: colors.muted, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: submitting
                          ? null
                          : () async {
                              AppHaptics.mediumImpact();
                              setDialogState(() => submitting = true);
                              try {
                                await AuthApi.instance.requestClientIb(client.id);
                                showAppMessage('IB request submitted successfully!');
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                                onIbChanged?.call();
                              } catch (e) {
                                showAppMessage('Failed to submit IB request: $e');
                                if (dialogContext.mounted) {
                                  setDialogState(() => submitting = false);
                                }
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: submitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.send, size: 14),
                      label: Text(
                        submitting ? 'Submitting...' : 'Confirm',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showReferralQrModal(BuildContext context, IbReferralLink link) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colors = PartnershipColors.of(sheetContext);
      final url = link.effectiveUrl;

      return SafeArea(
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Referral QR & Link',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      AppHaptics.selectionClick();
                      Navigator.pop(sheetContext);
                    },
                    icon: Icon(LucideIcons.x, color: colors.muted, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: VtIndexQrView(
                  data: url,
                  size: 190,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                link.profileName,
                style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              SelectableText(
                url,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.muted, fontSize: 11),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppCopyButton.outlined(
                      value: url,
                      label: 'Referral link',
                      buttonLabel: 'Copy link',
                      size: 15,
                      buttonStyle: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Builder(
                      builder: (buttonContext) => FilledButton.icon(
                        onPressed: () => shareReferralLink(
                          buttonContext,
                          url: url,
                          profileName: link.profileName,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(LucideIcons.share2, size: 15),
                        label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showIbTermsModal(
  BuildContext context, {
  required bool initialAgreed,
  required ValueChanged<bool> onAgreedChanged,
  required Future<void> Function() onSubmit,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colors = PartnershipColors.of(sheetContext);
      var agreed = initialAgreed;
      var submitting = false;
      String? errorMessage;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
              ),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.muted.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(LucideIcons.fileCheck2, color: colors.blue, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IB Partnership Agreement',
                                style: TextStyle(color: colors.text, fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Review guidelines and confirm your application',
                                style: TextStyle(color: colors.muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, size: 20),
                          onPressed: submitting ? null : () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.subCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.subBorder),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Program Terms & Rebate Structure',
                                style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '1. The standard commission pool is calculated up to \$8.00 per standard lot traded by eligible clients on MT5.\n\n'
                                '2. Multi-tier commissions are allocated at 50% for Level 1 (Direct Clients), 20% for Level 2 (Sub-IBs), and 10% for Level 3 (Extended Network).\n\n'
                                '3. Commissions are calculated upon position closure and deposited to your Partner Commission Ledger daily.\n\n'
                                '4. Internal transfers to your own live MT5 trading account and external withdrawals carry zero processing fees.\n\n'
                                '5. Partner activity is monitored for spam, deceptive advertising, or abusive market manipulation. Violation may result in partner status revocation.',
                                style: TextStyle(color: colors.muted, fontSize: 12.5, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        AppHaptics.selectionClick();
                        setSheetState(() => agreed = !agreed);
                        onAgreedChanged(agreed);
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: agreed,
                            activeColor: colors.blue,
                            onChanged: (val) {
                              AppHaptics.selectionClick();
                              setSheetState(() => agreed = val ?? false);
                              onAgreedChanged(agreed);
                            },
                          ),
                          Expanded(
                            child: Text(
                              'I agree to the VT-Index Introducing Broker Terms & Guidelines',
                              style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.red.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(
                            color: colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (!agreed || submitting)
                            ? null
                            : () async {
                                AppHaptics.mediumImpact();
                                setSheetState(() {
                                  submitting = true;
                                  errorMessage = null;
                                });
                                try {
                                  await onSubmit();
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                } catch (e) {
                                  final msg = e is AuthApiException
                                      ? e.message
                                      : 'Failed to submit IB application.';
                                  if (sheetContext.mounted) {
                                    setSheetState(() {
                                      submitting = false;
                                      errorMessage = msg;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(LucideIcons.send, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Submit IB Application',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
